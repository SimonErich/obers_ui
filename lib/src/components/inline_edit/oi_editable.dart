import 'package:flutter/widgets.dart';

/// A generic wrapper that toggles between a display (read-only) widget
/// and an edit widget.
///
/// When [enabled] is `true` and [editOnTap] is `true`, tapping the display
/// widget enters edit mode. The edit widget receives a `commit` callback to
/// finalise the new value and a `cancel` callback to revert without saving.
/// Committing calls [onChanged] with the new value.
///
/// {@category Components}
class OiEditable<T> extends StatefulWidget {
  /// Creates an [OiEditable].
  const OiEditable({
    required this.value,
    required this.displayBuilder,
    required this.editBuilder,
    this.onChanged,
    this.enabled = true,
    this.editOnTap = true,
    super.key,
  });

  /// The current value shown in display mode and passed to the edit widget.
  final T value;

  /// Builds the display (read-only) widget.
  ///
  /// Receives the current [BuildContext], the [value], and a startEdit
  /// callback that transitions to edit mode when called.
  final Widget Function(BuildContext context, T value, VoidCallback startEdit)
  displayBuilder;

  /// Builds the edit widget.
  ///
  /// Receives the current [BuildContext], the [value], a commit callback
  /// to save the new value, and a cancel callback to discard changes.
  final Widget Function(
    BuildContext context,
    T value,
    void Function(T newValue) commit,
    VoidCallback cancel,
  )
  editBuilder;

  /// Called when the user commits a new value.
  final ValueChanged<T>? onChanged;

  /// Whether editing is enabled.
  ///
  /// When `false`, tapping the display widget does not enter edit mode.
  final bool enabled;

  /// Whether tapping the display widget automatically triggers edit mode.
  ///
  /// Defaults to `true`.
  final bool editOnTap;

  @override
  State<OiEditable<T>> createState() => _OiEditableState<T>();
}

class _OiEditableState<T> extends State<OiEditable<T>> {
  bool _editing = false;

  void _startEdit() {
    if (!widget.enabled || _editing) return;
    setState(() => _editing = true);
  }

  void _commit(T newValue) {
    widget.onChanged?.call(newValue);
    setState(() => _editing = false);
  }

  void _cancel() {
    setState(() => _editing = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_editing) {
      return widget.editBuilder(context, widget.value, _commit, _cancel);
    }

    final display = widget.displayBuilder(context, widget.value, _startEdit);

    if (!widget.editOnTap || !widget.enabled) {
      return display;
    }

    return GestureDetector(
      onTap: _startEdit,
      behavior: HitTestBehavior.opaque,
      child: display,
    );
  }
}
