import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';

/// A themed sliver grid that wraps [SliverGrid] with design-system spacing
/// defaults and responsive column support.
///
/// Use [OiSliverGrid] inside a [CustomScrollView] or any sliver-based scroll
/// view to display a lazily-built grid of items.
///
/// The default constructor uses a fixed [crossAxisCount]. Use
/// [OiSliverGrid.extent] to let the framework calculate the column count
/// based on a [minItemWidth].
///
/// Spacing defaults to the theme's `sm` value (8 dp) when not explicitly set.
///
/// ```dart
/// OiSliverGrid(
///   crossAxisCount: 3,
///   itemCount: items.length,
///   itemBuilder: (context, index) => OiCard(child: OiLabel.body(items[index])),
/// )
/// ```
///
/// {@category Primitives}
class OiSliverGrid extends StatelessWidget {
  /// Creates an [OiSliverGrid] with a fixed [crossAxisCount].
  ///
  /// Items are built lazily via [itemBuilder]. Spacing between items defaults
  /// to the theme's `sm` spacing value.
  const OiSliverGrid({
    required this.itemCount,
    required this.itemBuilder,
    this.crossAxisCount = 2,
    this.mainAxisSpacing,
    this.crossAxisSpacing,
    this.childAspectRatio = 1.0,
    this.padding,
    this.semanticLabel,
    super.key,
  }) : minItemWidth = null;

  /// Creates an [OiSliverGrid] that auto-calculates columns from [minItemWidth].
  ///
  /// Uses [SliverGridDelegateWithMaxCrossAxisExtent] under the hood so that
  /// columns adjust when the viewport width changes (e.g. on window resize).
  const OiSliverGrid.extent({
    required this.itemCount,
    required this.itemBuilder,
    required double this.minItemWidth,
    this.mainAxisSpacing,
    this.crossAxisSpacing,
    this.childAspectRatio = 1.0,
    this.padding,
    this.semanticLabel,
    super.key,
  }) : crossAxisCount = 0;

  /// The total number of items in the grid.
  final int itemCount;

  /// Builds the widget for the item at the given index.
  final Widget Function(BuildContext, int) itemBuilder;

  /// The number of columns in the grid.
  ///
  /// Ignored when using the [OiSliverGrid.extent] constructor.
  final int crossAxisCount;

  /// The minimum width of each item.
  ///
  /// Only used by the [OiSliverGrid.extent] constructor to derive the column
  /// count via [SliverGridDelegateWithMaxCrossAxisExtent].
  final double? minItemWidth;

  /// Spacing along the main axis between items.
  ///
  /// Defaults to the theme's `sm` spacing when `null`.
  final double? mainAxisSpacing;

  /// Spacing along the cross axis between items.
  ///
  /// Defaults to the theme's `sm` spacing when `null`.
  final double? crossAxisSpacing;

  /// The ratio of the cross-axis extent to the main-axis extent of each child.
  final double childAspectRatio;

  /// Optional padding around the entire sliver.
  ///
  /// When non-null the sliver is wrapped in a [SliverPadding].
  final EdgeInsetsGeometry? padding;

  /// An optional semantic label for the grid.
  ///
  /// When non-null the sliver is wrapped in a [Semantics] widget.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final effectiveMainAxisSpacing = mainAxisSpacing ?? spacing.sm;
    final effectiveCrossAxisSpacing = crossAxisSpacing ?? spacing.sm;

    final SliverGridDelegate gridDelegate;

    if (minItemWidth != null) {
      gridDelegate = SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: minItemWidth!,
        mainAxisSpacing: effectiveMainAxisSpacing,
        crossAxisSpacing: effectiveCrossAxisSpacing,
        childAspectRatio: childAspectRatio,
      );
    } else {
      gridDelegate = SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: effectiveMainAxisSpacing,
        crossAxisSpacing: effectiveCrossAxisSpacing,
        childAspectRatio: childAspectRatio,
      );
    }

    Widget sliver = SliverGrid(
      delegate: SliverChildBuilderDelegate(
        itemBuilder,
        childCount: itemCount,
      ),
      gridDelegate: gridDelegate,
    );

    // Wrap in padding when requested.
    if (padding != null) {
      sliver = SliverPadding(
        padding: padding!,
        sliver: sliver,
      );
    }

    // Wrap in semantics when a label is provided.
    if (semanticLabel != null) {
      sliver = Semantics(
        label: semanticLabel,
        child: sliver,
      );
    }

    return sliver;
  }
}
