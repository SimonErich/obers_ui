import 'dart:ui' show SemanticsRole;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/oi_accessibility.dart';
import 'package:obers_ui/src/foundation/oi_focus_visibility.dart';
import 'package:obers_ui/src/foundation/theme/oi_effects_theme.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/interaction/oi_touch_target.dart';

/// What an [OiTappable] is announced as by assistive technology.
///
/// {@category Primitives}
enum OiTappableRole {
  /// A push button. The default.
  button,

  /// A checkbox. Pass its state as [OiTappable.checked] or
  /// [OiTappable.mixed].
  checkbox,

  /// One option of a radio group. Pass its state as [OiTappable.checked];
  /// [OiTappable.inMutuallyExclusiveGroup] defaults to `true`.
  radio,

  /// An on/off switch. Pass its state as [OiTappable.toggled].
  toggle,

  /// A tab of a tab bar. [OiTappable.selected] must be set, and the tappable
  /// needs an [OiTappable.onTap] unless it is disabled.
  tab,

  /// An item of a menu. An ancestor must carry the menu or menu bar role.
  menuItem,

  /// No role: only the enabled state, the actions and any state flags are
  /// announced. Use it when the child (or a parent) already carries a role.
  none,
}

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
/// The wrappers that draw these states are always in the tree, with neutral
/// values while a state is inactive, so [child] keeps its [State] when the
/// tappable is pressed, hovered, focused, dragged or disabled.
///
/// To assistive technology an [OiTappable] that can be activated (or is
/// disabled) is one node with a [role], its enabled state and, while enabled,
/// its tap and long-press actions. [checked], [mixed], [toggled], [selected],
/// [expanded] and [inMutuallyExclusiveGroup] add state to that node, which
/// makes it a base for checkboxes, radios, switches, tabs and disclosure
/// headers.
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
    this.touchTargetAlignment = Alignment.center,
    this.role = OiTappableRole.button,
    this.checked,
    this.mixed,
    this.toggled,
    this.selected,
    this.expanded,
    this.inMutuallyExclusiveGroup,
    this.onKeyEvent,
    this.skipTraversal = false,
    super.key,
  }) : assert(
         role != OiTappableRole.tab || selected != null,
         'An OiTappable with role OiTappableRole.tab needs `selected` '
         '(true or false): a tab is always announced as selected or not.',
       ),
       assert(
         role != OiTappableRole.tab || !enabled || onTap != null,
         'An enabled OiTappable with role OiTappableRole.tab needs `onTap`: '
         'a tab must offer a tap action. Pass enabled: false for a tab that '
         'cannot be activated.',
       ),
       assert(
         checked == null || toggled == null,
         'OiTappable cannot have both `checked` and `toggled`: a control is '
         'either a checkbox / radio (checked) or a switch (toggled).',
       );

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
  ///
  /// When set, everything [child] would announce is dropped, including
  /// interactive widgets nested in it.
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

  /// Where [child] sits in the minimum touch target when it is smaller
  /// (touch devices only; see [OiTouchTarget.alignment]).
  ///
  /// Defaults to [Alignment.center].
  final AlignmentGeometry touchTargetAlignment;

  /// What the tappable is announced as. Defaults to
  /// [OiTappableRole.button].
  ///
  /// An enabled tappable with the default role, no [onTap], [onDoubleTap] or
  /// [onLongPress], no [semanticLabel] and no state announces no role, so a
  /// wrapper that only tracks hover is not read out as a button.
  ///
  /// Requirements, checked in debug mode:
  /// - [OiTappableRole.tab] needs [selected] and, unless the tappable is
  ///   disabled, [onTap].
  /// - [OiTappableRole.menuItem] needs an ancestor announced with the menu
  ///   or menu bar role (`Semantics(role: SemanticsRole.menu)` or
  ///   `SemanticsRole.menuBar`). Flutter reports a missing one when it
  ///   builds the semantics tree, so only with assistive technology (or
  ///   `tester.ensureSemantics()` in a test) switched on.
  final OiTappableRole role;

  /// Whether the tappable is announced as checked (`true`) or unchecked
  /// (`false`). `null` (the default) announces no checked state.
  ///
  /// Must not be `true` together with [mixed].
  final bool? checked;

  /// Whether the tappable is announced as partially checked (a tristate
  /// checkbox). `null` (the default) announces nothing.
  final bool? mixed;

  /// Whether the tappable is announced as switched on (`true`) or off
  /// (`false`). `null` (the default) announces no toggled state.
  final bool? toggled;

  /// Whether the tappable is announced as selected. `null` (the default)
  /// announces no selected state.
  final bool? selected;

  /// Whether the tappable is announced as expanded (`true`) or collapsed
  /// (`false`). `null` (the default) announces no expanded state.
  final bool? expanded;

  /// Whether the tappable is announced as one of a group in which only one
  /// can be chosen. `null` (the default) means `true` for
  /// [OiTappableRole.radio] and nothing otherwise.
  final bool? inMutuallyExclusiveGroup;

  /// Called with every key event that reaches the tappable while it is
  /// [enabled], before the built-in Enter / Space activation.
  ///
  /// Return [KeyEventResult.ignored] to let the built-in handling run. Any
  /// other result is returned as is and the built-in handling is skipped.
  /// Use it for arrow keys, Home / End or Escape.
  final FocusOnKeyEventCallback? onKeyEvent;

  /// Whether Tab and directional traversal pass over the tappable.
  ///
  /// It can still be focused with a click or in code, which is what a
  /// roving-tab-index group needs for all but its current item. Defaults to
  /// `false`.
  final bool skipTraversal;

  @override
  State<OiTappable> createState() => _OiTappableState();
}

class _OiTappableState extends State<OiTappable> {
  bool _isHovered = false;
  bool _isPressed = false;
  bool _isFocused = false;

  /// Last non-transparent override colour, kept so [AnimatedOpacity] can fade
  /// the fill out instead of snapping to transparent.
  Color _overrideFill = const Color(0x00000000);

  @override
  void initState() {
    super.initState();
    OiFocusVisibility.listenable.addListener(_handleFocusVisibilityChange);
    // Reports a change of FocusManager.highlightStrategy.
    FocusManager.instance.addHighlightModeListener(_handleHighlightModeChange);
  }

  @override
  void dispose() {
    OiFocusVisibility.listenable.removeListener(_handleFocusVisibilityChange);
    FocusManager.instance.removeHighlightModeListener(
      _handleHighlightModeChange,
    );
    super.dispose();
  }

  // Only a focused tappable shows the change, so only it rebuilds.
  void _handleFocusVisibilityChange() {
    if (_isFocused) setState(() {});
  }

  void _handleHighlightModeChange(FocusHighlightMode _) =>
      _handleFocusVisibilityChange();

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

    final custom = widget.onKeyEvent?.call(node, event);
    if (custom != null && custom != KeyEventResult.ignored) {
      // The built-in handling may have taken the key-down; release the
      // pressed state even though the hook takes the key-up.
      if (isActivationKey && event is KeyUpEvent) _setPressed(false);
      return custom;
    }

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
    // A label replaces what the child would announce. Always in the tree so
    // adding or dropping the label does not move the child.
    Widget content = ExcludeSemantics(
      excluding: widget.semanticLabel != null,
      child: widget.child,
    );

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
      final visibleOverride = override != null && override.a > 0
          ? override
          : null;
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

    // The four wrappers below are always built, with neutral values while
    // their state is inactive. Inserting them only when needed would change
    // the widget type at this position and rebuild the child from scratch,
    // losing its State, on every press, focus change or enable/disable.

    // Halo / glow rendered as a DecoratedBox behind the content.
    final halo = style.halo;
    final showHalo =
        halo != OiHaloStyle.none &&
        (halo.color.a > 0 || halo.spread > 0 || halo.blur > 0);
    content = DecoratedBox(
      decoration: showHalo
          ? BoxDecoration(boxShadow: [halo.toBoxShadow()])
          : const BoxDecoration(),
      child: content,
    );

    // Focus ring — foreground border rendered on top of content when keyboard
    // navigation is active. Suppressed after a click or tap, so a tappable
    // that gets focus from the pointer (e.g. the first item of a menu that
    // opens) shows none; reappears immediately on any keyboard event.
    final showFocusRing =
        _isFocused &&
        widget.focusable &&
        widget.enabled &&
        OiFocusVisibility.visible;
    final ring = effects.focusRing.enforced;
    content = DecoratedBox(
      position: DecorationPosition.foreground,
      decoration: showFocusRing
          ? BoxDecoration(
              border: Border.all(color: ring.color, width: ring.width),
              borderRadius: ring.borderRadius,
            )
          : const BoxDecoration(),
      child: content,
    );

    // Scale transform for pressed states (1 paints the child untouched).
    content = Transform.scale(scale: style.scale, child: content);

    // Reduced opacity when disabled (1 paints the child untouched). This is
    // the only opacity layer around the child: an Opacity composites a layer
    // even at 1, so there must not be a second one.
    content = Opacity(
      opacity: !widget.enabled && widget.dimWhenDisabled ? 0.4 : 1,
      child: content,
    );

    // Enforce minimum touch target. Always rendered (even when minTarget is
    // zero) so the widget-tree structure stays stable across input-modality
    // changes (pointer ↔ touch). With minTarget == 0, OiTouchTarget.custom
    // behaves as a no-op pass-through.
    content = OiTouchTarget.custom(
      minSize: minTarget,
      alignment: widget.touchTargetAlignment,
      child: content,
    );

    // Gesture detection. The recognisers stay registered while disabled so a
    // disabled tappable still swallows the tap instead of passing it to a
    // tappable ancestor; the callbacks themselves are suppressed. The actions
    // offered to assistive technology come from the Semantics node below,
    // which drops them while disabled.
    content = GestureDetector(
      excludeFromSemantics: true,
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
      skipTraversal: widget.skipTraversal,
      onFocusChange: (focused) {
        _setFocused(focused);
        widget.onFocusChange?.call(focused);
      },
      onKeyEvent: _handleKeyEvent,
      child: content,
    );

    // Semantics: role, enabled state, state flags and actions. Always in the
    // tree; an enabled tappable with nothing to activate, no label and no
    // state stays silent so a hover-only wrapper is not announced as a button.
    final role = widget.role;
    final inGroup =
        widget.inMutuallyExclusiveGroup ??
        (role == OiTappableRole.radio ? true : null);
    final hasState =
        widget.checked != null ||
        widget.mixed != null ||
        widget.toggled != null ||
        widget.selected != null ||
        widget.expanded != null ||
        inGroup != null;
    final announce =
        widget.onTap != null ||
        widget.onDoubleTap != null ||
        widget.onLongPress != null ||
        !widget.enabled ||
        widget.semanticLabel != null ||
        role != OiTappableRole.button ||
        hasState;
    return Semantics(
      label: widget.semanticLabel,
      button: announce && role == OiTappableRole.button ? true : null,
      role: switch (role) {
        OiTappableRole.tab => SemanticsRole.tab,
        OiTappableRole.menuItem => SemanticsRole.menuItem,
        _ => null,
      },
      enabled: announce ? widget.enabled : null,
      checked: widget.checked,
      mixed: widget.mixed,
      toggled: widget.toggled,
      selected: widget.selected,
      expanded: widget.expanded,
      inMutuallyExclusiveGroup: inGroup,
      onTap: widget.enabled && widget.onTap != null ? _handleTap : null,
      onLongPress: widget.enabled && widget.onLongPress != null
          ? _handleLongPress
          : null,
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
