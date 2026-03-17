import 'package:flutter/widgets.dart';

/// A thin wrapper around Flutter's [Wrap] widget with explicitly named fields.
///
/// Use [OiWrapLayout] to flow [children] across multiple lines with consistent
/// [spacing] and [runSpacing].
///
/// {@category Primitives}
class OiWrapLayout extends StatelessWidget {
  /// Creates an [OiWrapLayout].
  const OiWrapLayout({
    required this.children,
    this.spacing = 0,
    this.runSpacing = 0,
    this.alignment = WrapAlignment.start,
    this.runAlignment = WrapAlignment.start,
    this.crossAxisAlignment = WrapCrossAlignment.start,
    this.direction = Axis.horizontal,
    super.key,
  });

  /// Horizontal gap between children along the main axis.
  final double spacing;

  /// Vertical gap between lines (runs).
  final double runSpacing;

  /// How children are aligned within each run along the main axis.
  final WrapAlignment alignment;

  /// How the runs themselves are aligned along the cross axis.
  final WrapAlignment runAlignment;

  /// How children within a run are aligned along the cross axis.
  final WrapCrossAlignment crossAxisAlignment;

  /// The primary axis along which children are laid out.
  final Axis direction;

  /// The child widgets to wrap.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: spacing,
      runSpacing: runSpacing,
      alignment: alignment,
      runAlignment: runAlignment,
      crossAxisAlignment: crossAxisAlignment,
      direction: direction,
      children: children,
    );
  }
}
