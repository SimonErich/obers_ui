import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';

/// Controller that allows programmatic insert and remove operations on
/// an [OiAnimatedList].
///
/// Obtain a controller by passing it to the [OiAnimatedList] constructor.
/// The controller is bound to the list state during [State.initState] and
/// must not be used before the widget has been inserted into the tree.
///
/// {@category Primitives}
class OiAnimatedListController<T> {
  _OiAnimatedListState<T>? _state;

  /// Binds this controller to [state]. Called internally by
  /// [OiAnimatedList] in [State.initState].
  // A setter cannot accept a typed parameter distinct from the field type here;
  // a void method is clearer for an attach/detach lifecycle pair.
  // ignore: use_setters_to_change_properties
  void _attach(_OiAnimatedListState<T> state) {
    _state = state;
  }

  // Symmetric detach uses the same pattern as _attach above.
  // ignore: use_setters_to_change_properties
  void _detach() {
    _state = null;
  }

  /// Inserts [item] at [index] and runs the insert animation.
  void insert(int index, T item) {
    assert(_state != null, 'OiAnimatedListController is not attached.');
    _state!._insert(index, item);
  }

  /// Removes the item at [index] and runs the remove animation.
  void remove(int index) {
    assert(_state != null, 'OiAnimatedListController is not attached.');
    _state!._remove(index);
  }

  /// Inserts all [items] starting from the end of the current list.
  void insertAll(List<T> items) {
    assert(_state != null, 'OiAnimatedListController is not attached.');
    for (final item in items) {
      _state!._insert(_state!._items.length, item);
    }
  }
}

/// An animated list widget that supports inserting and removing items with
/// configurable transition animations.
///
/// Wrap with a [OiAnimatedListController] to insert and remove items
/// programmatically. Each insert uses a [SizeTransition] by default and each
/// remove uses a [FadeTransition] by default.
///
/// ```dart
/// final controller = OiAnimatedListController<String>();
///
/// OiAnimatedList<String>(
///   items: const ['a', 'b'],
///   controller: controller,
///   itemBuilder: (context, item, animation, index) =>
///       SizeTransition(sizeFactor: animation, child: Text(item)),
/// )
/// ```
///
/// {@category Primitives}
class OiAnimatedList<T> extends StatefulWidget {
  /// Creates an [OiAnimatedList].
  const OiAnimatedList({
    required this.items,
    required this.itemBuilder,
    this.controller,
    this.removeBuilder,
    this.scrollDirection = Axis.vertical,
    this.shrinkWrap = false,
    this.padding,
    super.key,
  });

  /// Initial list of items.
  final List<T> items;

  /// Builder for each item.
  ///
  /// Receives the [BuildContext], the item value, the insert [Animation], and
  /// the current index of the item.
  final Widget Function(BuildContext, T, Animation<double>, int) itemBuilder;

  /// Optional controller used to insert and remove items.
  final OiAnimatedListController<T>? controller;

  /// Builder for items that are being removed.
  ///
  /// When null a [FadeTransition] that fades from 1 to 0 is used.
  final Widget Function(BuildContext, T, Animation<double>)? removeBuilder;

  /// The scroll direction of the list. Defaults to [Axis.vertical].
  final Axis scrollDirection;

  /// Whether to shrink-wrap the list contents. Defaults to false.
  final bool shrinkWrap;

  /// Padding around the list contents.
  final EdgeInsetsGeometry? padding;

  @override
  State<OiAnimatedList<T>> createState() => _OiAnimatedListState<T>();
}

class _OiAnimatedListState<T> extends State<OiAnimatedList<T>> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  late List<T> _items;

  @override
  void initState() {
    super.initState();
    _items = List<T>.from(widget.items);
    widget.controller?._attach(this);
  }

  @override
  void didUpdateWidget(OiAnimatedList<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?._detach();
      widget.controller?._attach(this);
    }
  }

  @override
  void dispose() {
    widget.controller?._detach();
    super.dispose();
  }

  void _insert(int index, T item) {
    _items.insert(index, item);
    final reducedMotion =
        context.animations.reducedMotion ||
        MediaQuery.disableAnimationsOf(context);
    _listKey.currentState?.insertItem(
      index,
      duration: reducedMotion
          ? Duration.zero
          : const Duration(milliseconds: 300),
    );
  }

  void _remove(int index) {
    final removedItem = _items.removeAt(index);
    final reducedMotion =
        context.animations.reducedMotion ||
        MediaQuery.disableAnimationsOf(context);
    _listKey.currentState?.removeItem(
      index,
      (context, animation) =>
          _buildRemoveWidget(context, removedItem, animation),
      duration: reducedMotion
          ? Duration.zero
          : const Duration(milliseconds: 300),
    );
  }

  Widget _buildRemoveWidget(
    BuildContext context,
    T item,
    Animation<double> animation,
  ) {
    if (widget.removeBuilder != null) {
      return widget.removeBuilder!(context, item, animation);
    }
    return FadeTransition(
      opacity: animation,
      child: widget.itemBuilder(context, item, animation, 0),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reducedMotion =
        context.animations.reducedMotion ||
        MediaQuery.disableAnimationsOf(context);
    return AnimatedList(
      key: _listKey,
      initialItemCount: _items.length,
      scrollDirection: widget.scrollDirection,
      shrinkWrap: widget.shrinkWrap,
      padding: widget.padding,
      itemBuilder: (context, index, animation) {
        final child = widget.itemBuilder(
          context,
          _items[index],
          animation,
          index,
        );
        if (reducedMotion) return child;
        return SizeTransition(sizeFactor: animation, child: child);
      },
    );
  }
}
