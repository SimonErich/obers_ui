import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/overlay/oi_visibility.dart';

/// Animates a list of [children] in sequence, each one starting after a
/// [staggerDelay] offset from the previous.
///
/// A single [AnimationController] drives all children. Each child's visible
/// range is mapped to an [Interval] so that they appear one after another.
/// The transition style is controlled by [transition].
///
/// When [autoPlay] is true (the default) the stagger animation starts
/// automatically on mount. Set it to false and call [OiStaggerState.play]
/// to trigger the animation externally.
///
/// Respects `MediaQuery.disableAnimations`: when the user has requested reduced
/// motion all children are shown immediately without animation.
///
/// ```dart
/// OiStagger(
///   staggerDelay: const Duration(milliseconds: 80),
///   children: items.map((t) => Text(t)).toList(),
/// )
/// ```
///
/// {@category Primitives}
class OiStagger extends StatefulWidget {
  /// Creates an [OiStagger].
  const OiStagger({
    required this.children,
    this.staggerDelay = const Duration(milliseconds: 80),
    this.duration = const Duration(milliseconds: 300),
    this.transition = OiTransition.fade,
    this.autoPlay = true,
    super.key,
  });

  /// The children to animate in sequence.
  final List<Widget> children;

  /// Delay between each child's animation start.
  final Duration staggerDelay;

  /// Duration of each individual child's animation.
  final Duration duration;

  /// The transition to apply to each child.
  final OiTransition transition;

  /// Whether to trigger the animation automatically on mount.
  ///
  /// Set to false to control the animation externally.
  final bool autoPlay;

  @override
  State<OiStagger> createState() => OiStaggerState();
}

/// State for [OiStagger]. Exposed so that tests can call [play] directly.
///
/// {@category Primitives}
class OiStaggerState extends State<OiStagger>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    final totalMs = _totalDuration().inMilliseconds;
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: totalMs),
    );
    if (widget.autoPlay) {
      // Defer until after the first frame so the context is fully available.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) play();
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller.duration = _totalDuration();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Total controller duration: last child offset + one child duration.
  Duration _totalDuration() {
    final n = widget.children.length;
    if (n == 0) return widget.duration;
    final staggerMs = widget.staggerDelay.inMilliseconds * (n - 1);
    return Duration(milliseconds: staggerMs + widget.duration.inMilliseconds);
  }

  /// Starts the stagger animation from the beginning.
  void play() {
    if (!mounted) return;
    final reduced =
        context.animations.reducedMotion ||
        MediaQuery.disableAnimationsOf(context);
    if (reduced) {
      _controller.value = 1.0;
    } else {
      unawaited(_controller.forward(from: 0));
    }
  }

  Widget _applyTransition(
    OiTransition transition,
    Animation<double> animation,
    Widget child,
  ) {
    switch (transition) {
      case OiTransition.none:
        return child;
      case OiTransition.fade:
        return FadeTransition(opacity: animation, child: child);
      case OiTransition.fadeScale:
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.9, end: 1).animate(animation),
            child: child,
          ),
        );
      case OiTransition.slideUp:
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.1),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      case OiTransition.slideDown:
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, -0.1),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      case OiTransition.slideLeft:
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.1, 0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      case OiTransition.slideRight:
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(-0.1, 0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final reduced =
        context.animations.reducedMotion ||
        MediaQuery.disableAnimationsOf(context);
    final n = widget.children.length;
    if (n == 0) return const SizedBox.shrink();

    final totalMs = _totalDuration().inMilliseconds.toDouble();

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(n, (i) {
            if (reduced) {
              return widget.children[i];
            }
            final startMs = widget.staggerDelay.inMilliseconds * i;
            final endMs = startMs + widget.duration.inMilliseconds;
            final start = totalMs > 0 ? startMs / totalMs : 0.0;
            final end = totalMs > 0 ? endMs / totalMs : 1.0;
            final interval = CurvedAnimation(
              parent: _controller,
              curve: Interval(start, end, curve: Curves.easeOut),
            );
            return _applyTransition(
              widget.transition,
              interval,
              widget.children[i],
            );
          }),
        );
      },
    );
  }
}
