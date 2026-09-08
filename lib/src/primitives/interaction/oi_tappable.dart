import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/oi_accessibility.dart';
import 'package:obers_ui/src/foundation/theme/oi_effects_theme.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/interaction/oi_touch_target.dart';

/// A foundational interactive widget that handles tap, double-tap, long-press,
/// hover, focus, and disabled states with animated visual feedback.
///
/// [OiTappable] reads interactive state effects from [OiEffectsTheme] and
/// applies background overlay, halo/glow, and scale transforms according to
/// the current state:
///
/// - **Pressed / active**: [OiEffectsTheme.active] (highest priority)
/// - **Hovered**: [OiEffectsTheme.hover] (pointer devices only)
/// - **Focused**: [OiEffectsTheme.focus]
/// - **Disabled**: 0.4 opacity, all interaction suppressed
///
/// On touch platforms (Android, iOS) a transparent padding region ensures a
/// minimum 48 × 48 dp tap target via [OiA11y.minTouchTarget].  On pointer
/// platforms no extra padding is added.
///
/// {@category Primitives}
class OiTappable extends StatefulWidget {
  /// Creates an [OiTappable].
  const OiTappable({
    required this.child,
    this.onTap,
    this.onDoubleTap,
    this.onLongPress,
    this.onHover,
    this.onFocusChange,
    this.enabled = true,
    this.focusable = true,
    this.dragging = false,
    this.applyBackgroundOverlay = true,
    this.dimWhenDisabled = true,
    this.semanticLabel,
    this.cursor,
    this.clipBorderRadius,
    super.key,
  });

  /// The widget to render inside the tappable area.
  final Widget child;

  /// Called when the widget is tapped.
  final VoidCallback? onTap;

  /// Called when the widget is double-tapped.
  final VoidCallback? onDoubleTap;

  /// Called when the widget is long-pressed.
  final VoidCallback? onLongPress;

  /// Called when the hover state changes (pointer devices only).
  final ValueChanged<bool>? onHover;

  /// Called when the focus state changes.
  final ValueChanged<bool>? onFocusChange;

  /// Whether the widget responds to interactions.
  ///
  /// When `false`, callbacks are suppressed. The widget also fades to 0.4
  /// opacity unless [dimWhenDisabled] is `false`.
  final bool enabled;

  /// Whether the widget participates in keyboard focus traversal.
  ///
  /// When `false`, the [Focus] node cannot receive focus.
  final bool focusable;

  /// Whether the widget is currently being dragged.
  ///
  /// This state is managed externally (e.g. by a parent [Draggable] or
  /// [LongPressDraggable]) and causes [OiEffectsTheme.dragging] to be applied.
  /// Dragging takes the highest visual priority among all interactive states.
  final bool dragging;

  /// Whether to paint [OiInteractiveStyle.backgroundOverlay] for the current
  /// state.
  ///
  /// Set to `false` when the child already paints a per-state fill so the
  /// overlay does not tint that colour. Ignored when the current style sets
  /// [OiInteractiveStyle.backgroundOverride] — a concrete fill always
  /// replaces the tint.
  final bool applyBackgroundOverlay;

  /// When [enabled] is `false`, whether to fade the child to 0.4 opacity.
  ///
  /// Set to `false` when the child already paints a disabled appearance.
  final bool dimWhenDisabled;

  /// An optional label announced by screen readers in place of the child's
  /// semantic content.
  final String? semanticLabel;

  /// The mouse cursor to display when hovering over this widget.
  ///
  /// Defaults to [SystemMouseCursors.click] when [enabled] is true and
  /// [SystemMouseCursors.basic] when disabled.
  final MouseCursor? cursor;

  /// Optional border radius used to clip the hover/active state fills.
  ///
  /// When non-null the background overlay, background override, and child are
  /// clipped to this radius so they match the visible shape of the child
  /// (e.g. a rounded button).
  final BorderRadius? clipBorderRadius;

  @override
  State<OiTappable> createState() => _OiTappableState();
}

class _OiTappableState extends State<OiTappable> {
  bool _isHovered = false;
  bool _isPressed = false;
  bool _isFocused = false;
  FocusHighlightMode _highlightMode = FocusHighlightMode.touch;

  /// Last non-transparent override colour, kept so [AnimatedOpacity] can fade
  /// the fill out instead of snapping to transparent.
  Color _overrideFill = const Color(0x00000000);

  @override
  void initState() {
    super.initState();
    _highlightMode = FocusManager.instance.highlightMode;
    FocusManager.instance.addHighlightModeListener(_handleHighlightModeChange);
  }

  @override
  void dispose() {
    FocusManager.instance.removeHighlightModeListener(
      _handleHighlightModeChange,
    );
    super.dispose();
  }

  void _handleHighlightModeChange(FocusHighlightMode mode) {
    if (_highlightMode != mode) setState(() => _highlightMode = mode);
  }

  // ── State helpers ──────────────────────────────────────────────────────────

  void _setHovered(bool value) {
    if (_isHovered != value) setState(() => _isHovered = value);
  }

  void _setPressed(bool value) {
    if (_isPressed != value) setState(() => _isPressed = value);
  }

  void _setFocused(bool value) {
    if (_isFocused != value) setState(() => _isFocused = value);
  }

  // ── Effective style ────────────────────────────────────────────────────────

  OiInteractiveStyle _effectiveStyle(OiEffectsTheme effects) {
    if (!widget.enabled) return OiInteractiveStyle.none;
    if (widget.dragging) return effects.dragging;
    if (_isPressed) return effects.active;
    if (_isHovered) return effects.hover;
    if (_isFocused) return effects.focus;
    return OiInteractiveStyle.none;
  }

  // ── Gesture callbacks ──────────────────────────────────────────────────────

  void _handleTapDown(TapDownDetails _) => _setPressed(true);
  void _handleTapUp(TapUpDetails _) => _setPressed(false);
  void _handleTapCancel() => _setPressed(false);

  void _handleTap() {
    if (widget.enabled) widget.onTap?.call();
  }

  void _handleDoubleTap() {
    if (widget.enabled) widget.onDoubleTap?.call();
  }

  void _handleLongPress() {
    if (widget.enabled) widget.onLongPress?.call();
  }

  // ── Keyboard callbacks ─────────────────────────────────────────────────────

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (!widget.enabled) return KeyEventResult.ignored;

    final isActivationKey =
        event.logicalKey == LogicalKeyboardKey.enter ||
        event.logicalKey == LogicalKeyboardKey.space;

    if (!isActivationKey) return KeyEventResult.ignored;

    if (event is KeyDownEvent) {
      _setPressed(true);
      return KeyEventResult.handled;
    }

    if (event is KeyUpEvent) {
      _setPressed(false);
      _handleTap();
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final effects = context.effects;
    final animations = context.animations;
    final reducedMotion =
        animations.reducedMotion || MediaQuery.disableAnimationsOf(context);
    final minTarget = OiA11y.minTouchTarget(context);
    final style = _effectiveStyle(effects);

    final effectiveCursor =
        widget.cursor ??
        (widget.enabled ? SystemMouseCursors.click : SystemMouseCursors.basic);

    // ── Build inner content with state overlay ───────────────────────────────
    // ignore: omit_local_variable_types
    Widget content = widget.child;

    // Background for the current state — both layers stay in the tree so
    // AnimatedOpacity can smoothly transition them in and out without shifting
    // the child's slot in the [Stack].
    //
    // `backgroundOverride` replaces the widget's background outright, so it is
    // painted opaquely *behind* the child; `backgroundOverlay` tints whatever
    // the child already draws, so it is layered on top. A concrete override
    // replaces the overlay tint — they do not stack.
    {
      final duration = reducedMotion ? Duration.zero : animations.fast;
      final override = style.backgroundOverride;
      final visibleOverride =
          override != null && override.a > 0 ? override : null;
      if (visibleOverride != null) {
        _overrideFill = visibleOverride;
      }

      final overlayColor = style.backgroundOverlay;
      final showOverlay =
          widget.applyBackgroundOverlay &&
          overlayColor.a > 0 &&
          visibleOverride == null;

      content = Stack(
        fit: StackFit.passthrough,
        children: [
          Positioned.fill(
            child: _stateFill(
              opacity: visibleOverride != null ? 1.0 : 0.0,
              color: visibleOverride ?? _overrideFill,
              duration: duration,
            ),
          ),
          content,
          Positioned.fill(
            child: _stateFill(
              opacity: showOverlay ? 1.0 : 0.0,
              color: showOverlay
                  ? overlayColor
                  : effects.hover.backgroundOverlay,
              duration: duration,
            ),
          ),
        ],
      );

      if (widget.clipBorderRadius != null) {
        content = ClipRRect(
          borderRadius: widget.clipBorderRadius!,
          child: content,
        );
      }
    }

    // Halo / glow rendered as a DecoratedBox behind the content.
    final halo = style.halo;
    if (halo != OiHaloStyle.none &&
        (halo.color.a > 0 || halo.spread > 0 || halo.blur > 0)) {
      content = DecoratedBox(
        decoration: BoxDecoration(boxShadow: [halo.toBoxShadow()]),
        child: content,
      );
    }

    // Focus ring — foreground border rendered on top of content when keyboard
    // navigation is active. Suppressed on touch-only interaction to reduce
    // visual noise; reappears immediately on any keyboard event.
    if (_isFocused &&
        widget.focusable &&
        widget.enabled &&
        _highlightMode == FocusHighlightMode.traditional) {
      final ring = effects.focusRing.enforced;
      content = DecoratedBox(
        position: DecorationPosition.foreground,
        decoration: BoxDecoration(
          border: Border.all(color: ring.color, width: ring.width),
          borderRadius: ring.borderRadius,
        ),
        child: content,
      );
    }

    // Scale transform for pressed states.
    if (style.scale != 1) {
      content = Transform.scale(scale: style.scale, child: content);
    }

    // Reduced opacity when disabled.
    if (!widget.enabled && widget.dimWhenDisabled) {
      content = Opacity(opacity: 0.4, child: content);
    }

    // Enforce minimum touch target. Always rendered (even when minTarget is
    // zero) so the widget-tree structure stays stable across input-modality
    // changes (pointer ↔ touch). With minTarget == 0, OiTouchTarget.custom
    // behaves as a no-op pass-through.
    content = OiTouchTarget.custom(minSize: minTarget, child: content);

    // Gesture detection.
    content = GestureDetector(
      onTap: widget.onTap != null ? _handleTap : null,
      onDoubleTap: widget.onDoubleTap != null ? _handleDoubleTap : null,
      onLongPress: widget.onLongPress != null ? _handleLongPress : null,
      // Only register tap down/up/cancel when onTap is set. When onTap is null,
      // registering these would create a competing TapGestureRecognizer that
      // prevents DoubleTapGestureRecognizer from firing.
      onTapDown: widget.onTap != null ? _handleTapDown : null,
      onTapUp: widget.onTap != null ? _handleTapUp : null,
      onTapCancel: widget.onTap != null ? _handleTapCancel : null,
      behavior: HitTestBehavior.opaque,
      child: content,
    );

    // Hover region. Always rendered to keep the widget-tree structure stable
    // across input-modality changes (pointer ↔ touch). MouseRegion callbacks
    // only fire for mouse/trackpad/stylus pointer events, so they are silent
    // no-ops on touch devices. Removing this widget conditionally (based on
    // minTarget) would move the GestureDetector within the element tree mid-
    // gesture, resetting in-flight DoubleTapGestureRecognisers.
    content = MouseRegion(
      cursor: effectiveCursor,
      onEnter: (_) {
        if (widget.enabled) {
          _setHovered(true);
          widget.onHover?.call(true);
        }
      },
      onExit: (_) {
        _setHovered(false);
        widget.onHover?.call(false);
      },
      child: content,
    );

    // Keyboard focus.
    content = Focus(
      canRequestFocus: widget.focusable && widget.enabled,
      onFocusChange: (focused) {
        _setFocused(focused);
        widget.onFocusChange?.call(focused);
      },
      onKeyEvent: _handleKeyEvent,
      child: content,
    );

    // Semantics label.
    if (widget.semanticLabel != null) {
      content = Semantics(
        label: widget.semanticLabel,
        button: true,
        enabled: widget.enabled,
        child: content,
      );
    }

    // Animated wrapper for smooth state transitions.
    return AnimatedOpacity(
      opacity: 1,
      duration: reducedMotion ? Duration.zero : animations.fast,
      child: content,
    );
  }
}

/// A non-hit-testable fill used for the hover/active overlay and override.
Widget _stateFill({
  required double opacity,
  required Color color,
  required Duration duration,
}) {
  return IgnorePointer(
    child: AnimatedOpacity(
      opacity: opacity,
      duration: duration,
      child: ColoredBox(color: color),
    ),
  );
}
