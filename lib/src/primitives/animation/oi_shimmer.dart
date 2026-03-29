import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';

/// A shimmer loading-placeholder effect that sweeps a gradient across [child].
///
/// When [active] is true a repeating [LinearGradient] animates from left to
/// right over the child's shape using a [ShaderMask]. When [active] is false
/// the child is rendered as-is.
///
/// Respects `MediaQuery.disableAnimations`: when the user has requested reduced
/// motion the shimmer is replaced with a static [baseColor] overlay.
///
/// ```dart
/// OiShimmer(
///   active: isLoading,
///   child: Container(width: 200, height: 20, color: Colors.white),
/// )
/// ```
///
/// {@category Primitives}
class OiShimmer extends StatefulWidget {
  /// Creates an [OiShimmer].
  const OiShimmer({
    required this.child,
    this.baseColor,
    this.highlightColor,
    this.duration,
    this.active = true,
    super.key,
  });

  /// The child widget that defines the shape of the shimmer.
  final Widget child;

  /// Base (dark) color of the shimmer gradient.
  ///
  /// Defaults to `Color(0xFFE0E0E0)`.
  final Color? baseColor;

  /// Highlight (light) color of the shimmer gradient.
  ///
  /// Defaults to `Color(0xFFF5F5F5)`.
  final Color? highlightColor;

  /// Duration of one shimmer sweep. Defaults to 1500 ms.
  final Duration? duration;

  /// Whether the shimmer animation is active.
  ///
  /// When false the child is rendered without any shimmer overlay.
  final bool active;

  @override
  State<OiShimmer> createState() => _OiShimmerState();
}

class _OiShimmerState extends State<OiShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration ?? const Duration(milliseconds: 1500),
    );
    if (widget.active) {
      unawaited(_controller.repeat());
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncAnimation();
  }

  @override
  void didUpdateWidget(OiShimmer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration) {
      _controller.duration =
          widget.duration ?? const Duration(milliseconds: 1500);
    }
    _syncAnimation();
  }

  void _syncAnimation() {
    final reduced =
        context.animations.reducedMotion ||
        MediaQuery.disableAnimationsOf(context);
    if (widget.active && !reduced) {
      if (!_controller.isAnimating) {
        unawaited(_controller.repeat());
      }
    } else {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.active) return widget.child;

    final colors = context.colors;
    final base = widget.baseColor ?? colors.surfaceActive;
    final highlight = widget.highlightColor ?? colors.surfaceHover;
    final reduced =
        context.animations.reducedMotion ||
        MediaQuery.disableAnimationsOf(context);

    if (reduced) {
      return ColorFiltered(
        colorFilter: ColorFilter.mode(base, BlendMode.srcATop),
        child: widget.child,
      );
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;
        // Sweep the gradient from well left (-1) to well right (2).
        final begin = Alignment(-2 + t * 4, 0);
        final end = Alignment(-1 + t * 4, 0);
        final gradient = LinearGradient(
          begin: begin,
          end: end,
          colors: [base, highlight, base],
          stops: const [0.0, 0.5, 1.0],
        );
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: gradient.createShader,
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
