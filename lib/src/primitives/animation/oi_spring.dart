import 'package:flutter/physics.dart';
import 'package:flutter/widgets.dart';

/// A widget that drives a [builder] with a spring-physics animation toward a
/// target [value].
///
/// When [value] changes the widget uses a [SpringSimulation] to animate from
/// the current position to the new target, producing natural-feeling motion
/// with configurable [stiffness], [damping], and [mass].
///
/// The [builder] is called on every frame with the current animated value and
/// the optional [child] passthrough (which is not rebuilt on every frame,
/// improving performance for expensive sub-trees).
///
/// ```dart
/// OiSpring(
///   value: _expanded ? 1.0 : 0.0,
///   builder: (context, v, child) => Opacity(opacity: v, child: child),
///   child: const ExpensiveWidget(),
/// )
/// ```
///
/// {@category Primitives}
class OiSpring extends StatefulWidget {
  /// Creates an [OiSpring].
  const OiSpring({
    required this.value,
    required this.builder,
    this.child,
    this.stiffness = 300.0,
    this.damping = 30.0,
    this.mass = 1.0,
    super.key,
  });

  /// Target value (typically 0.0 to 1.0).
  ///
  /// When this changes the spring animates from the current position toward
  /// the new target.
  final double value;

  /// Builder that receives the current animated value on every frame.
  ///
  /// The optional [child] argument is the widget passed to [OiSpring.child],
  /// which is not rebuilt each frame.
  final Widget Function(BuildContext context, double value, Widget? child)
      builder;

  /// Optional child passed through to [builder] without being rebuilt on
  /// every animation frame.
  final Widget? child;

  /// Spring stiffness. Higher values produce a faster, bouncier spring.
  ///
  /// Defaults to 300.0.
  final double stiffness;

  /// Spring damping. Higher values reduce oscillation.
  ///
  /// Defaults to 30.0.
  final double damping;

  /// Spring mass. Higher values produce slower, heavier motion.
  ///
  /// Defaults to 1.0.
  final double mass;

  @override
  State<OiSpring> createState() => _OiSpringState();
}

class _OiSpringState extends State<OiSpring>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController.unbounded(vsync: this)
      ..value = widget.value;
  }

  @override
  void didUpdateWidget(OiSpring oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value ||
        oldWidget.stiffness != widget.stiffness ||
        oldWidget.damping != widget.damping ||
        oldWidget.mass != widget.mass) {
      _runSpring(
        from: _controller.value,
        to: widget.value,
        velocity: _controller.velocity,
      );
    }
  }

  void _runSpring({
    required double from,
    required double to,
    double velocity = 0,
  }) {
    final desc = SpringDescription(
      mass: widget.mass,
      stiffness: widget.stiffness,
      damping: widget.damping,
    );
    final sim = SpringSimulation(desc, from, to, velocity);
    _controller.animateWith(sim);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) =>
          widget.builder(context, _controller.value, child),
      child: widget.child,
    );
  }
}
