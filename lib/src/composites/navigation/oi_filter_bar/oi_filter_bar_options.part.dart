part of '../oi_filter_bar.dart';

// ── Filter option widgets ────────────────────────────────────────────────────

/// A single option row in a select filter dropdown with hover effect.
class _FilterOption extends StatefulWidget {
  const _FilterOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_FilterOption> createState() => _FilterOptionState();
}

class _FilterOptionState extends State<_FilterOption> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: widget.selected
                ? colors.primary.base.withValues(alpha: 0.1)
                : _hovered
                ? colors.surfaceSubtle
                : null,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            widget.label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: widget.selected ? FontWeight.w600 : FontWeight.w400,
              color: widget.selected ? colors.primary.base : colors.text,
            ),
          ),
        ),
      ),
    );
  }
}

/// A checkbox option row for multi-select filter popovers.
class _FilterCheckboxOption extends StatefulWidget {
  const _FilterCheckboxOption({
    required this.label,
    required this.checked,
    required this.onChanged,
  });

  final String label;
  final bool checked;
  final ValueChanged<bool> onChanged;

  @override
  State<_FilterCheckboxOption> createState() => _FilterCheckboxOptionState();
}

class _FilterCheckboxOptionState extends State<_FilterCheckboxOption> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => widget.onChanged(!widget.checked),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: _hovered ? colors.surfaceSubtle : null,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            children: [
              OiCheckbox(
                value: widget.checked,
                onChanged: widget.onChanged,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: 14,
                    color: colors.text,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
