part of 'oi_table.dart';

// ── _ColumnManagerPanel ────────────────────────────────────────────────────────

/// Overlay panel that lets the user toggle column visibility.
class _ColumnManagerPanel<T> extends StatelessWidget {
  const _ColumnManagerPanel({
    required this.columns,
    required this.visibility,
    required this.onToggle,
  });

  final List<OiTableColumn<T>> columns;
  final Map<String, bool> visibility;
  final void Function(String columnId, bool visible) onToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('oi_table_column_manager'),
      constraints: const BoxConstraints(maxWidth: 240),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        border: Border.all(color: const Color(0xFFD1D5DB)),
        borderRadius: BorderRadius.circular(4),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: Text(
              'Columns',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
          for (final col in columns)
            GestureDetector(
              key: Key('col_manager_${col.id}'),
              behavior: HitTestBehavior.opaque,
              onTap: () {
                final currentlyVisible = visibility[col.id] ?? true;
                onToggle(col.id, !currentlyVisible);
              },
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Row(
                  children: [
                    Text((visibility[col.id] ?? true) ? '☑' : '☐'),
                    const SizedBox(width: 8),
                    Expanded(child: Text(col.header)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
