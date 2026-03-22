import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/buttons/oi_button.dart';
import 'package:obers_ui/src/foundation/oi_icons.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/animation/oi_animated_list.dart';
import 'package:obers_ui/src/primitives/display/oi_divider.dart';
import 'package:obers_ui/src/primitives/display/oi_icon.dart';
import 'package:obers_ui/src/primitives/display/oi_label.dart';
import 'package:obers_ui/src/primitives/drag_drop/oi_reorderable.dart';

/// A repeatable form field group where each row contains a set of form inputs
/// with add, remove, and reorder controls.
///
/// Each row is built using [itemBuilder], which receives the current index,
/// item value, and an `onItemChanged` callback for in-place edits. New blank
/// rows are created via [createEmpty].
///
/// When [reorderable] is `true`, rows can be dragged to reorder via
/// [OiReorderable]. Rows animate in/out via [OiAnimatedList] when
/// [reorderable] is `false`.
///
/// {@category Components}
class OiArrayInput<T> extends StatefulWidget {
  /// Creates an [OiArrayInput].
  const OiArrayInput({
    required this.label,
    required this.items,
    required this.itemBuilder,
    required this.createEmpty,
    this.onChanged,
    this.error,
    this.reorderable = true,
    this.addable = true,
    this.removable = true,
    this.minItems,
    this.maxItems,
    this.addLabel = 'Add',
    super.key,
  });

  /// The current list of items.
  final List<T> items;

  /// Builds the UI for a single item row.
  ///
  /// Receives the [BuildContext], the item index, the item value, and a
  /// callback to update the item in place.
  final Widget Function(
    BuildContext context,
    int index,
    T item,
    ValueChanged<T> onItemChanged,
  )
  itemBuilder;

  /// Factory that returns a new blank item to append when the user taps Add.
  final T Function() createEmpty;

  /// Called with the updated list after any add, remove, reorder, or
  /// item-change operation.
  final ValueChanged<List<T>>? onChanged;

  /// Label rendered above the list.
  final String label;

  /// Validation error message rendered below the list.
  final String? error;

  /// Whether rows can be dragged to reorder. Defaults to `true`.
  final bool reorderable;

  /// Whether the Add button is shown. Defaults to `true`.
  final bool addable;

  /// Whether remove buttons are shown on rows. Defaults to `true`.
  final bool removable;

  /// Minimum number of items. Remove buttons are hidden at this count.
  final int? minItems;

  /// Maximum number of items. The Add button is hidden at this count.
  final int? maxItems;

  /// Label for the Add button. Defaults to `'Add'`.
  final String addLabel;

  @override
  State<OiArrayInput<T>> createState() => _OiArrayInputState<T>();
}

class _OiArrayInputState<T> extends State<OiArrayInput<T>> {
  OiAnimatedListController<T>? _animatedController;

  bool get _canAdd =>
      widget.maxItems == null || widget.items.length < widget.maxItems!;

  bool get _canRemove =>
      widget.minItems == null || widget.items.length > widget.minItems!;

  @override
  void initState() {
    super.initState();
    if (!widget.reorderable) {
      _animatedController = OiAnimatedListController<T>();
    }
  }

  @override
  void didUpdateWidget(OiArrayInput<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.reorderable != widget.reorderable) {
      if (widget.reorderable) {
        _animatedController = null;
      } else {
        _animatedController = OiAnimatedListController<T>();
      }
    }
  }

  void _handleAdd() {
    if (!_canAdd || widget.onChanged == null) return;
    final newItem = widget.createEmpty();
    final newList = [...widget.items, newItem];
    _animatedController?.insert(widget.items.length, newItem);
    widget.onChanged!(newList);
  }

  void _handleRemove(int index) {
    if (!_canRemove || widget.onChanged == null) return;
    _animatedController?.remove(index);
    final newList = [...widget.items]..removeAt(index);
    widget.onChanged!(newList);
  }

  void _handleReorder(int oldIndex, int newIndex) {
    if (widget.onChanged == null) return;
    final newList = [...widget.items];
    final adjustedIndex = newIndex > oldIndex ? newIndex - 1 : newIndex;
    final item = newList.removeAt(oldIndex);
    newList.insert(adjustedIndex, item);
    widget.onChanged!(newList);
  }

  void _handleItemChanged(int index, T newValue) {
    if (widget.onChanged == null) return;
    final newList = [...widget.items];
    newList[index] = newValue;
    widget.onChanged!(newList);
  }

  Widget _buildRow(
    BuildContext context,
    int index,
    T item,
    Animation<double> animation,
  ) {
    final colors = context.colors;
    final showRemove =
        widget.removable && _canRemove && widget.onChanged != null;

    final content = widget.itemBuilder(
      context,
      index,
      item,
      (newValue) => _handleItemChanged(index, newValue),
    );

    final row = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.reorderable)
          Padding(
            padding: const EdgeInsets.only(right: 4, top: 4),
            child: OiIcon(
              icon: OiIcons.ellipsisVertical,
              label: 'Drag to reorder',
              size: 20,
              color: colors.textMuted,
            ),
          ),
        Expanded(child: content),
        if (showRemove)
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: OiButton.ghost(
              label: 'Remove',
              icon: OiIcons.close,
              size: OiButtonSize.small,
              onTap: () => _handleRemove(index),
              semanticLabel: 'Remove item ${index + 1}',
            ),
          ),
      ],
    );

    if (animation == const AlwaysStoppedAnimation<double>(1) ||
        widget.reorderable) {
      return row;
    }

    return SizeTransition(
      sizeFactor: animation,
      child: FadeTransition(opacity: animation, child: row),
    );
  }

  Widget _buildAnimatedList() {
    return OiAnimatedList<T>(
      items: widget.items,
      controller: _animatedController,
      shrinkWrap: true,
      itemBuilder: (context, item, animation, index) {
        final children = <Widget>[_buildRow(context, index, item, animation)];
        if (index < widget.items.length - 1) {
          children.add(
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: OiDivider(),
            ),
          );
        }
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        );
      },
    );
  }

  Widget _buildReorderableList() {
    if (widget.items.isEmpty) return const SizedBox.shrink();

    final rowWidgets = <Widget>[];
    for (var i = 0; i < widget.items.length; i++) {
      final children = <Widget>[
        _buildRow(
          context,
          i,
          widget.items[i],
          const AlwaysStoppedAnimation<double>(1),
        ),
      ];
      if (i < widget.items.length - 1) {
        children.add(
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 4),
            child: OiDivider(),
          ),
        );
      }
      rowWidgets.add(
        Column(
          key: ValueKey<int>(i),
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      );
    }

    return OiReorderable(
      onReorder: _handleReorder,
      shrinkWrap: true,
      children: rowWidgets,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final hasError = widget.error != null && widget.error!.isNotEmpty;
    final showAdd = widget.addable && _canAdd && widget.onChanged != null;

    return Semantics(
      label: widget.label,
      container: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OiLabel.small(widget.label),
          const SizedBox(height: 4),
          if (widget.items.isNotEmpty)
            widget.reorderable ? _buildReorderableList() : _buildAnimatedList(),
          if (showAdd)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: OiButton.ghost(
                label: widget.addLabel,
                icon: OiIcons.add,
                size: OiButtonSize.small,
                onTap: _handleAdd,
                semanticLabel: widget.addLabel,
              ),
            ),
          if (hasError) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                OiIcon(
                  icon: OiIcons.exclamationCircle,
                  label: 'Error',
                  size: 14,
                  color: colors.error.base,
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: OiLabel.small(widget.error!, color: colors.error.base),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
