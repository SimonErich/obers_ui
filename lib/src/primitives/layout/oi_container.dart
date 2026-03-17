import 'package:flutter/widgets.dart';

/// A content-width constraining wrapper with optional padding and centering.
///
/// Use [maxWidth] to cap the layout width, [padding] to add insets around
/// [child], and [centered] (default `true`) to center the content
/// horizontally.
///
/// {@category Primitives}
class OiContainer extends StatelessWidget {
  /// Creates an [OiContainer].
  const OiContainer({
    this.child,
    this.maxWidth,
    this.padding,
    this.centered = true,
    super.key,
  });

  /// Optional maximum width for the content area in logical pixels.
  final double? maxWidth;

  /// Optional padding around [child].
  final EdgeInsetsGeometry? padding;

  /// The widget to display inside the container.
  final Widget? child;

  /// Whether to center [child] horizontally. Defaults to `true`.
  final bool centered;

  @override
  Widget build(BuildContext context) {
    var content = child ?? const SizedBox.shrink() as Widget;

    if (padding != null) {
      content = Padding(padding: padding!, child: content);
    }

    content = ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth ?? double.infinity),
      child: content,
    );

    if (centered) {
      content = Center(child: content);
    }

    return content;
  }
}
