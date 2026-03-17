import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/oi_app.dart';

/// A scrollable list whose items can be reordered by drag and drop.
///
/// On touch devices ([OiDensity.comfortable]) items require a long-press to
/// start dragging; on pointer devices dragging starts immediately.
///
/// Each child must have a unique [Key] so Flutter can track identity across
/// reorders. [onReorder] is called with the old and new indices after the user
/// drops an item in a new position.
///
/// {@category Primitives}
class OiReorderable extends StatelessWidget {
  /// Creates an [OiReorderable].
  const OiReorderable({
    required this.children,
    required this.onReorder,
    this.scrollDirection = Axis.vertical,
    this.itemsAreFixed = false,
    this.padding,
    super.key,
  });

  /// The items to display in the list.
  final List<Widget> children;

  /// Called with the old and new indices when an item is moved.
  final void Function(int oldIndex, int newIndex) onReorder;

  /// The scroll direction of the list.
  ///
  /// Defaults to [Axis.vertical].
  final Axis scrollDirection;

  /// Whether all items have the same fixed size.
  ///
  /// Setting this to `true` improves rendering performance.
  final bool itemsAreFixed;

  /// Optional padding around the list.
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final density = OiDensityScope.of(context);
    final isTouch = density == OiDensity.comfortable;

    Widget wrapItem(int index, Widget child) {
      if (isTouch) {
        return ReorderableDelayedDragStartListener(
          key: child.key,
          index: index,
          child: child,
        );
      }
      return ReorderableDragStartListener(
        key: child.key,
        index: index,
        child: child,
      );
    }

    final sliver = SliverReorderableList(
      itemCount: children.length,
      itemExtent: itemsAreFixed ? null : null,
      onReorder: onReorder,
      itemBuilder: (context, index) => wrapItem(index, children[index]),
    );

    final sliverPadding = padding != null
        ? SliverPadding(padding: padding!, sliver: sliver)
        : sliver as Widget;

    return CustomScrollView(
      scrollDirection: scrollDirection,
      slivers: [sliverPadding],
    );
  }
}
