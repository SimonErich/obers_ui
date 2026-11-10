import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';

/// A horizontal media strip reserving room for external selection outlines.
///
/// The first item aligns with the surrounding content gutter. Outline padding
/// bleeds outside that gutter and increases the strip height, preventing scroll
/// clipping of focus/selection rings. Requires bounded width; caller owns items
/// and optional scroll controller.
///
/// {@category Components}
class OiMediaStrip extends StatelessWidget {
  /// Creates an outline-safe strip of uniformly sized items.
  const OiMediaStrip({
    required this.children,
    required this.itemExtent,
    this.itemAspectRatio = 1,
    this.gap,
    this.outlinePadding,
    this.horizontalBleed,
    this.contentPadding,
    this.controller,
    super.key,
  }) : assert(itemExtent > 0, 'itemExtent must be positive.'),
       assert(itemAspectRatio > 0, 'itemAspectRatio must be positive.'),
       assert(
         horizontalBleed == null || horizontalBleed >= 0,
         'horizontalBleed must not be negative.',
       );

  /// Media tiles; selection and keyboard behavior belong to each item.
  final List<Widget> children;

  /// Logical width of each item, excluding padding.
  final double itemExtent;

  /// Width divided by height; defaults to square items.
  final double itemAspectRatio;

  /// Item gap; defaults to the theme small spacing.
  final double? gap;

  /// Reserved external outline space; defaults to the theme extra-small spacing.
  final double? outlinePadding;

  /// How far the scroll viewport extends beyond each content gutter.
  ///
  /// Defaults to [outlinePadding]. Pair a larger bleed with matching horizontal
  /// [contentPadding] to retain the first/last item alignment with the gutter.
  final double? horizontalBleed;

  /// Scroll content padding; defaults to [outlinePadding] on every side.
  ///
  /// Supports directional padding and independent top/bottom space. The strip
  /// height includes the resolved vertical padding.
  final EdgeInsetsGeometry? contentPadding;

  /// Optional caller-owned scroll controller.
  final ScrollController? controller;

  @override
  Widget build(BuildContext context) {
    final outline = outlinePadding ?? context.spacing.xs;
    final bleed = horizontalBleed ?? outline;
    final padding = (contentPadding ?? EdgeInsets.all(outline)).resolve(
      Directionality.of(context),
    );
    final itemHeight = itemExtent / itemAspectRatio;
    return SizedBox(
      height: itemHeight + padding.vertical,
      child: LayoutBuilder(
        builder: (context, bounds) => OverflowBox(
          minWidth: bounds.maxWidth + bleed * 2,
          maxWidth: bounds.maxWidth + bleed * 2,
          child: SingleChildScrollView(
            controller: controller,
            scrollDirection: Axis.horizontal,
            padding: padding,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: gap ?? context.spacing.sm,
              children: [
                for (final child in children)
                  SizedBox(
                    width: itemExtent,
                    height: itemHeight,
                    child: child,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
