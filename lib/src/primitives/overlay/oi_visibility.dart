import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/oi_responsive.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';

/// Transition animations for showing/hiding widgets.
///
/// {@category Primitives}
enum OiTransition {
  /// No animation — the widget appears or disappears instantly.
  none,

  /// Fade in/out.
  fade,

  /// Fade combined with a scale from 0.9 to 1.0.
  fadeScale,

  /// Slide upward while fading in (slides down while fading out).
  slideUp,

  /// Slide downward while fading in (slides up while fading out).
  slideDown,

  /// Slide in from the left while fading in.
  slideLeft,

  /// Slide in from the right while fading in.
  slideRight,
}

/// Animates showing and hiding a [child] widget with configurable transitions.
///
/// When [visible] becomes true the widget runs a forward animation. When
/// [visible] becomes false the widget runs a reverse animation. Use
/// [transition] to control the animation style. Use [maintainState] to keep
/// the child widget in the tree even when hidden (default true).
///
/// Use the [OiVisibility.responsive] constructor to apply different transitions
/// at compact vs. expanded breakpoints.
///
/// ```dart
/// OiVisibility(
///   visible: _isOpen,
///   transition: OiTransition.fadeScale,
///   child: MyPanel(),
/// )
/// ```
///
/// {@category Primitives}
class OiVisibility extends StatefulWidget {
  /// Creates an [OiVisibility] with a single transition style.
  const OiVisibility({
    required this.visible,
    required this.child,
    this.transition = OiTransition.fade,
    this.maintainState = true,
    super.key,
  }) : _compactTransition = null,
       _expandedTransition = null,
       _breakpoint = null;

  /// Creates an [OiVisibility] with responsive transitions.
  ///
  /// Uses [compactTransition] when [breakpoint] occupies the compact tier
  /// (minWidth 0) and [expandedTransition] on all wider breakpoints.
  ///
  /// **Zero magic:** [breakpoint] is required — no implicit context lookup
  /// for breakpoint detection.
  const OiVisibility.responsive({
    required this.visible,
    required this.child,
    required OiBreakpoint breakpoint,
    OiTransition compactTransition = OiTransition.slideUp,
    OiTransition expandedTransition = OiTransition.fade,
    this.maintainState = true,
    super.key,
  }) : transition = expandedTransition,
       _compactTransition = compactTransition,
       _expandedTransition = expandedTransition,
       _breakpoint = breakpoint;

  /// Whether the child is visible.
  final bool visible;

  /// The child to show or hide.
  final Widget child;

  /// The transition animation to use.
  ///
  /// Ignored when this widget was created with [OiVisibility.responsive].
  final OiTransition transition;

  /// Whether to keep the child in the widget tree when hidden.
  ///
  /// When false, the child is removed from the tree after the hide animation
  /// completes. Defaults to true.
  final bool maintainState;

  // Internal fields for the responsive constructor.
  final OiTransition? _compactTransition;
  final OiTransition? _expandedTransition;
  final OiBreakpoint? _breakpoint;

  @override
  State<OiVisibility> createState() => _OiVisibilityState();
}

class _OiVisibilityState extends State<OiVisibility>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  /// Whether the child is currently in the tree (relevant when
  /// maintainState=false).
  bool _inTree = false;

  @override
  void initState() {
    super.initState();
    _inTree = widget.visible;
    _controller = AnimationController(
      vsync: this,
      value: widget.visible ? 1.0 : 0.0,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateDuration();
  }

  @override
  void didUpdateWidget(OiVisibility oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateDuration();
    if (widget.visible != oldWidget.visible) {
      if (widget.visible) {
        setState(() => _inTree = true);
        _controller.forward();
      } else {
        _controller.reverse().whenComplete(() {
          if (mounted && !widget.visible && !widget.maintainState) {
            setState(() => _inTree = false);
          }
        });
      }
    }
  }

  void _updateDuration() {
    final reducedMotion =
        context.animations.reducedMotion ||
        MediaQuery.disableAnimationsOf(context);
    if (reducedMotion) {
      _controller.duration = Duration.zero;
      _controller.reverseDuration = Duration.zero;
    } else {
      final dur = context.animations.normal;
      _controller.duration = dur;
      _controller.reverseDuration = dur;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  OiTransition _resolvedTransition() {
    if (widget._compactTransition != null &&
        widget._expandedTransition != null) {
      final isCompact =
          widget._breakpoint!.minWidth == OiBreakpoint.compact.minWidth;
      return isCompact
          ? widget._compactTransition!
          : widget._expandedTransition!;
    }
    return widget.transition;
  }

  Widget _buildTransitionedChild(OiTransition transition, Widget child) {
    switch (transition) {
      case OiTransition.none:
        return child;

      case OiTransition.fade:
        return FadeTransition(opacity: _animation, child: child);

      case OiTransition.fadeScale:
        final scaleTween = Tween<double>(begin: 0.9, end: 1);
        return FadeTransition(
          opacity: _animation,
          child: ScaleTransition(
            scale: scaleTween.animate(_animation),
            child: child,
          ),
        );

      case OiTransition.slideUp:
        final slideTween = Tween<Offset>(
          begin: const Offset(0, 0.1),
          end: Offset.zero,
        );
        return FadeTransition(
          opacity: _animation,
          child: SlideTransition(
            position: slideTween.animate(_animation),
            child: child,
          ),
        );

      case OiTransition.slideDown:
        final slideTween = Tween<Offset>(
          begin: const Offset(0, -0.1),
          end: Offset.zero,
        );
        return FadeTransition(
          opacity: _animation,
          child: SlideTransition(
            position: slideTween.animate(_animation),
            child: child,
          ),
        );

      case OiTransition.slideLeft:
        final slideTween = Tween<Offset>(
          begin: const Offset(0.1, 0),
          end: Offset.zero,
        );
        return FadeTransition(
          opacity: _animation,
          child: SlideTransition(
            position: slideTween.animate(_animation),
            child: child,
          ),
        );

      case OiTransition.slideRight:
        final slideTween = Tween<Offset>(
          begin: const Offset(-0.1, 0),
          end: Offset.zero,
        );
        return FadeTransition(
          opacity: _animation,
          child: SlideTransition(
            position: slideTween.animate(_animation),
            child: child,
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final transition = _resolvedTransition();

    // For OiTransition.none use a plain Visibility widget.
    if (transition == OiTransition.none) {
      if (!widget.maintainState) {
        return widget.visible ? widget.child : const SizedBox.shrink();
      }
      return Visibility(visible: widget.visible, child: widget.child);
    }

    // When maintainState=false and the child is not in tree, render nothing.
    if (!widget.maintainState && !_inTree) {
      return const SizedBox.shrink();
    }

    return _buildTransitionedChild(transition, widget.child);
  }
}
