part of '../oi_filter_bar.dart';

// ── Filter chip ──────────────────────────────────────────────────────────────

/// A single filter chip that shows the filter label and active state.
class _FilterChip extends StatefulWidget {
  const _FilterChip({
    required this.definition,
    required this.active,
    required this.onActivate,
    required this.onRemove,
    this.activeFilter,
  });

  final OiFilterDefinition definition;
  final bool active;
  final OiColumnFilter? activeFilter;
  final ValueChanged<BuildContext> onActivate;
  final VoidCallback onRemove;

  @override
  State<_FilterChip> createState() => _FilterChipState();
}

class _FilterChipState extends State<_FilterChip> {
  bool _chipHovered = false;
  bool _closeHovered = false;

  String _formatValue(OiColumnFilter? filter) {
    if (filter == null) return '';
    final v = filter.value;
    if (v is List<String>) {
      if (v.isEmpty) return '';
      // For multiselect, resolve labels from options if available.
      final options = widget.definition.options;
      if (options != null) {
        return v.map((val) {
          final match = options.where((o) => o.value == val);
          return match.isNotEmpty ? match.first.label : val;
        }).join(', ');
      }
      return v.join(', ');
    }
    if (v is DateTime) {
      return '${v.year}-${v.month.toString().padLeft(2, '0')}-${v.day.toString().padLeft(2, '0')}';
    }
    if (v is String) return v;
    return v.toString();
  }

  int _activeCount() {
    final v = widget.activeFilter?.value;
    if (v is List<String>) return v.length;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final isActive = widget.active;
    final isMultiSelect = widget.definition.type == OiFilterType.multiSelect;
    final multiCount = isMultiSelect ? _activeCount() : 0;
    final baseColor = isActive
        ? colors.primary.base.withValues(alpha: 0.1)
        : colors.surfaceSubtle;
    final hoveredColor = isActive
        ? colors.primary.base.withValues(alpha: 0.18)
        : colors.border.withValues(alpha: 0.3);
    final textColor = isActive ? colors.primary.base : colors.text;
    final borderColor = isActive ? colors.primary.base : colors.border;

    return MouseRegion(
      onEnter: (_) => setState(() => _chipHovered = true),
      onExit: (_) => setState(() => _chipHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => widget.onActivate(context),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: _chipHovered && !_closeHovered ? hoveredColor : baseColor,
            borderRadius: BorderRadius.circular(100),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Label (and value for non-multiselect active chips).
              Padding(
                padding: EdgeInsets.only(
                  left: 12,
                  top: 6,
                  bottom: 6,
                  right: isActive && !isMultiSelect ? 4 : 0,
                ),
                child: Text(
                  isActive && !isMultiSelect
                      ? '${widget.definition.label}: '
                            '${_formatValue(widget.activeFilter)}'
                      : widget.definition.label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                    color: textColor,
                  ),
                ),
              ),

              // Multi-select: show count badge.
              if (isActive && isMultiSelect && multiCount > 0) ...[
                const SizedBox(width: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: colors.primary.base,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    '$multiCount',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: colors.textOnPrimary,
                    ),
                  ),
                ),
              ],

              // Active: show X to remove; Inactive: show chevron.
              if (isActive)
                MouseRegion(
                  onEnter: (_) => setState(() => _closeHovered = true),
                  onExit: (_) => setState(() => _closeHovered = false),
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: widget.onRemove,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 4,
                        right: 8,
                        top: 6,
                        bottom: 6,
                      ),
                      child: AnimatedScale(
                        scale: _closeHovered ? 1.3 : 1.0,
                        duration: const Duration(milliseconds: 150),
                        child: Icon(
                          OiIcons.x,
                          size: 14,
                          weight: _closeHovered ? 700 : 400,
                          color: textColor,
                        ),
                      ),
                    ),
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.only(left: 4, right: 8),
                  child: Icon(
                    OiIcons.chevronDown,
                    size: 14,
                    color: colors.textMuted,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
