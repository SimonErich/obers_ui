import 'package:flutter/widgets.dart';

/// A masonry-style layout that distributes [children] across [columns] vertical
/// columns, interleaving items by index (item 0 → column 0, item 1 → column 1,
/// …, item n → column n % columns).
///
/// Columns are separated by [gap] logical pixels of horizontal space.
///
/// {@category Primitives}
class OiMasonry extends StatelessWidget {
  /// Creates an [OiMasonry].
  const OiMasonry({
    required this.children,
    this.columns = 2,
    this.gap = 0,
    super.key,
  }) : assert(columns >= 1, 'columns must be at least 1');

  /// Number of vertical columns.
  final int columns;

  /// Horizontal and vertical gap between columns / items in logical pixels.
  final double gap;

  /// The child widgets to distribute across columns.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    // Build per-column child lists.
    final cols = List.generate(columns, (_) => <Widget>[]);
    for (var i = 0; i < children.length; i++) {
      cols[i % columns].add(children[i]);
    }

    // Build column widgets with vertical gap between items.
    final columnWidgets = <Widget>[];
    for (var c = 0; c < columns; c++) {
      final items = cols[c];
      final spacedItems = <Widget>[];
      for (var i = 0; i < items.length; i++) {
        spacedItems.add(items[i]);
        if (i < items.length - 1 && gap > 0) {
          spacedItems.add(SizedBox(height: gap));
        }
      }
      columnWidgets.add(
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: spacedItems,
          ),
        ),
      );
      if (c < columns - 1 && gap > 0) {
        columnWidgets.add(SizedBox(width: gap));
      }
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: columnWidgets,
    );
  }
}
