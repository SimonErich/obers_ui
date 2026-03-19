part of 'oi_table.dart';

// ── _CellFrame ────────────────────────────────────────────────────────────────

/// Internal widget that wraps a table cell and handles the transition between
/// display mode and edit mode.
class _CellFrame<T> extends StatefulWidget {
  const _CellFrame({
    required this.row,
    required this.rowIndex,
    required this.columnId,
    required this.child,
    required this.onChanged,
    super.key,
  });

  final T row;
  final int rowIndex;
  final String columnId;
  final Widget child;
  final void Function(dynamic value) onChanged;

  @override
  State<_CellFrame<T>> createState() => _CellFrameState<T>();
}

class _CellFrameState<T> extends State<_CellFrame<T>> {
  bool _editing = false;
  final TextEditingController _textCtrl = TextEditingController();

  @override
  void dispose() {
    _textCtrl.dispose();
    super.dispose();
  }

  void _startEdit() {
    setState(() => _editing = true);
  }

  void _commit() {
    widget.onChanged(_textCtrl.text);
    setState(() => _editing = false);
  }

  void _cancel() {
    setState(() => _editing = false);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    if (_editing) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: EditableText(
              controller: _textCtrl,
              focusNode: FocusNode()..requestFocus(),
              style: const TextStyle(fontSize: 14),
              cursorColor: colors.primary.base,
              backgroundCursorColor: colors.borderSubtle,
            ),
          ),
          GestureDetector(onTap: _commit, child: const Text('✓')),
          GestureDetector(onTap: _cancel, child: const Text('✗')),
        ],
      );
    }
    return GestureDetector(
      key: const Key('cell_display'),
      onDoubleTap: _startEdit,
      child: widget.child,
    );
  }
}

// ── _FilterField ──────────────────────────────────────────────────────────────

class _FilterField extends StatefulWidget {
  const _FilterField({
    required this.initialValue,
    required this.onChanged,
    super.key,
  });

  final String initialValue;
  final ValueChanged<String> onChanged;

  @override
  State<_FilterField> createState() => _FilterFieldState();
}

class _FilterFieldState extends State<_FilterField> {
  late final TextEditingController _ctrl;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialValue);
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return EditableText(
      controller: _ctrl,
      focusNode: _focusNode,
      style: const TextStyle(fontSize: 12),
      cursorColor: colors.primary.base,
      backgroundCursorColor: colors.borderSubtle,
      onChanged: widget.onChanged,
    );
  }
}
