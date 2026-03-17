import 'package:flutter/widgets.dart';

/// A widget that listens for double-tap and single-tap gestures on its child.
///
/// When [enabled] is `false`, all callbacks are suppressed and the [child] is
/// rendered without any gesture detection.
///
/// ```dart
/// OiDoubleTap(
///   onDoubleTap: () => print('double tapped'),
///   onTap: () => print('single tapped'),
///   child: const Text('tap me'),
/// )
/// ```
///
/// {@category Primitives}
class OiDoubleTap extends StatelessWidget {
  /// Creates an [OiDoubleTap].
  const OiDoubleTap({
    required this.child,
    this.onDoubleTap,
    this.onTap,
    this.enabled = true,
    super.key,
  });

  /// The child widget.
  final Widget child;

  /// Callback on double tap.
  ///
  /// When [enabled] is `false` this callback is not invoked.
  final VoidCallback? onDoubleTap;

  /// Callback on single tap (only fires if no double tap follows).
  ///
  /// When [enabled] is `false` this callback is not invoked.
  final VoidCallback? onTap;

  /// Whether double tap and single tap gestures are enabled.
  ///
  /// Defaults to `true`. When `false`, all callbacks are suppressed.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: enabled ? onDoubleTap : null,
      onTap: enabled ? onTap : null,
      child: child,
    );
  }
}
