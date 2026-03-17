import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/oi_accessibility.dart';

/// Applies a looping opacity and/or scale pulse animation to [child].
///
/// When [active] is true an [AnimationController] repeats in reverse,
/// driving [Opacity] and [Transform.scale] between their min and max values.
/// When [active] is false [child] is rendered without any wrapping.
///
/// Respects `MediaQuery.disableAnimations`: when the user has requested
/// reduced motion the animation is skipped and [child] is shown at full
/// opacity and scale.
///
/// ```dart
/// OiPulse(
///   active: isLoading,
///   minOpacity: 0.3,
///   child: Icon(Icons.circle),
/// )
/// ```
///
/// {@category Primitives}
class OiPulse extends StatefulWidget {
  /// Creates an [OiPulse].
  const OiPulse({
    required this.child,
    this.active = true,
    this.minOpacity = 0.4,
    this.maxOpacity = 1.0,
    this.minScale = 1.0,
    this.maxScale = 1.0,
    this.duration,
    super.key,
  });

  /// The child to pulse.
  final Widget child;

  /// Whether the pulse animation is active.
  ///
  /// When false, [child] is rendered directly without any animation wrapper.
  final bool active;

  /// Minimum opacity during the pulse. Defaults to 0.4.
  final double minOpacity;

  /// Maximum opacity during the pulse. Defaults to 1.0.
  final double maxOpacity;

  /// Minimum scale during the pulse. Defaults to 1.0.
  final double minScale;

  /// Maximum scale during the pulse.
  ///
  /// Set above 1.0 to add a scale component to the pulse. Defaults to 1.0.
  final double maxScale;

  /// Duration of one full pulse cycle. Defaults to 1000 ms.
  final Duration? duration;

  @override
  State<OiPulse> createState() => _OiPulseState();
}

class _OiPulseState extends State<OiPulse>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration ?? const Duration(milliseconds: 1000),
    );
    _buildAnimations();
    if (widget.active) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncAnimation();
  }

  @override
  void didUpdateWidget(OiPulse oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration) {
      _controller.duration =
          widget.duration ?? const Duration(milliseconds: 1000);
    }
    if (oldWidget.minOpacity != widget.minOpacity ||
        oldWidget.maxOpacity != widget.maxOpacity ||
        oldWidget.minScale != widget.minScale ||
        oldWidget.maxScale != widget.maxScale) {
      _buildAnimations();
    }
    _syncAnimation();
  }

  void _buildAnimations() {
    _opacityAnim = Tween<double>(
      begin: widget.minOpacity,
      end: widget.maxOpacity,
    ).animate(_controller);
    _scaleAnim = Tween<double>(
      begin: widget.minScale,
      end: widget.maxScale,
    ).animate(_controller);
  }

  void _syncAnimation() {
    final reduced = OiA11y.reducedMotion(context);
    if (widget.active && !reduced) {
      if (!_controller.isAnimating) _controller.repeat(reverse: true);
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

    final reduced = OiA11y.reducedMotion(context);
    if (reduced) return widget.child;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnim.value,
          child: Transform.scale(
            scale: _scaleAnim.value,
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}
