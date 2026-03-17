import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/overlay/oi_visibility.dart';

/// Animates a transition between two different [child] widgets.
///
/// When [child]'s key changes [OiMorph] runs the chosen [transition] using an
/// [AnimatedSwitcher] internally. This is equivalent to [AnimatedSwitcher] but
/// uses the shared [OiTransition] vocabulary so the animation style is
/// consistent with the rest of the design system.
///
/// The duration defaults to `context.animations.normal` (250 ms).
///
/// ```dart
/// OiMorph(
///   transition: OiTransition.fadeScale,
///   child: isLoggedIn
///       ? const Text('Welcome', key: ValueKey('welcome'))
///       : const Text('Sign in', key: ValueKey('signin')),
/// )
/// ```
///
/// {@category Primitives}
class OiMorph extends StatelessWidget {
  /// Creates an [OiMorph].
  const OiMorph({
    required this.child,
    this.duration,
    this.transition = OiTransition.fade,
    super.key,
  });

  /// The current widget to display.
  ///
  /// Give each distinct state a different [Key] so [AnimatedSwitcher] detects
  /// the change and runs the transition.
  final Widget child;

  /// Duration of the morphing transition.
  ///
  /// Defaults to `context.animations.normal` when null.
  final Duration? duration;

  /// The transition type used when switching between children.
  final OiTransition transition;

  Widget _buildTransition(
    OiTransition t,
    Widget child,
    Animation<double> animation,
  ) {
    switch (t) {
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
    final dur = duration ?? context.animations.normal;
    return AnimatedSwitcher(
      duration: dur,
      transitionBuilder: (child, animation) =>
          _buildTransition(transition, child, animation),
      child: child,
    );
  }
}
