import 'package:flutter/widgets.dart';

/// A widget that forces its [child] to a given width-to-height [ratio].
///
/// Wraps Flutter's [AspectRatio] with a named [ratio] parameter for clarity.
///
/// {@category Primitives}
class OiAspectRatio extends StatelessWidget {
  /// Creates an [OiAspectRatio].
  const OiAspectRatio({required this.ratio, required this.child, super.key})
    : assert(ratio > 0, 'ratio must be positive');

  /// The width-to-height ratio (e.g. `16 / 9` for widescreen).
  final double ratio;

  /// The widget to constrain to [ratio].
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(aspectRatio: ratio, child: child);
  }
}
