import 'package:flutter/widgets.dart';

/// A virtualised, lazily-rendered grid of items.
///
/// Uses [GridView.builder] with a [SliverGridDelegateWithFixedCrossAxisCount]
/// for efficient rendering of large datasets arranged in a fixed-column grid.
/// Only cells near the visible viewport are built.
///
/// ```dart
/// OiVirtualGrid(
///   itemCount: photos.length,
///   crossAxisCount: 3,
///   itemBuilder: (context, index) => Image.network(photos[index]),
/// )
/// ```
///
/// {@category Primitives}
class OiVirtualGrid extends StatelessWidget {
  /// Creates an [OiVirtualGrid].
  const OiVirtualGrid({
    required this.itemCount,
    required this.itemBuilder,
    this.crossAxisCount = 2,
    this.mainAxisSpacing = 0,
    this.crossAxisSpacing = 0,
    this.childAspectRatio = 1,
    this.cacheExtent,
    this.controller,
    this.padding,
    this.shrinkWrap = false,
    super.key,
  });

  /// Number of items in the grid.
  final int itemCount;

  /// Builder for each item at the given index.
  final IndexedWidgetBuilder itemBuilder;

  /// Number of columns in the grid.
  final int crossAxisCount;

  /// Spacing in the main axis (vertical by default) between rows.
  final double mainAxisSpacing;

  /// Spacing in the cross axis between columns.
  final double crossAxisSpacing;

  /// Aspect ratio of each cell (width / height).
  final double childAspectRatio;

  /// Cache extent in pixels beyond the viewport.
  final double? cacheExtent;

  /// An optional scroll controller.
  final ScrollController? controller;

  /// Padding around the grid content.
  final EdgeInsetsGeometry? padding;

  /// Whether the grid should shrink-wrap its content.
  final bool shrinkWrap;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: itemCount,
      itemBuilder: itemBuilder,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: mainAxisSpacing,
        crossAxisSpacing: crossAxisSpacing,
        childAspectRatio: childAspectRatio,
      ),
      cacheExtent: cacheExtent,
      controller: controller,
      padding: padding,
      shrinkWrap: shrinkWrap,
    );
  }
}
