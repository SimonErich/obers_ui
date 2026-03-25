import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/inputs/oi_select.dart';
import 'package:obers_ui/src/foundation/oi_icons.dart';
import 'package:obers_ui/src/foundation/persistence/oi_settings_driver.dart';
import 'package:obers_ui/src/foundation/persistence/oi_settings_mixin.dart';
import 'package:obers_ui/src/foundation/persistence/oi_settings_provider.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/models/settings/oi_filter_bar_settings.dart';


// ── Filter types ─────────────────────────────────────────────────────────────

/// The type of filter input.
///
/// {@category Composites}
enum OiFilterType {
  /// A free-text filter.
  text,

  /// A select / dropdown filter with predefined [OiSelectOption]s.
  select,

  /// A single date filter.
  date,

  /// A date range filter.
  dateRange,

  /// A single number filter.
  number,

  /// A number range filter.
  numberRange,

  /// A custom filter rendered by [OiFilterDefinition.customBuilder].
  custom,
}

// ── Filter operator ──────────────────────────────────────────────────────────

/// The comparison operator for a column filter.
///
/// {@category Composites}
enum OiFilterOperator {
  /// Exact equality.
  equals,

  /// Substring match.
  contains,

  /// Greater than comparison.
  greaterThan,

  /// Less than comparison.
  lessThan,

  /// Range (between two values).
  between,
}

// ── Column filter ────────────────────────────────────────────────────────────

/// A single active column filter value.
///
/// Holds the filter [value] and the [operator] used for comparison.
///
/// {@category Composites}
@immutable
class OiColumnFilter {
  /// Creates an [OiColumnFilter].
  const OiColumnFilter({
    required this.value,
    this.operator = OiFilterOperator.equals,
  });

  /// The filter value. The runtime type varies by [OiFilterType].
  final dynamic value;

  /// The comparison operator applied to [value].
  final OiFilterOperator operator;
}

// ── Filter definition ────────────────────────────────────────────────────────

/// A filter definition describing how a single filter chip behaves.
///
/// The [key] identifies the filter and is used as the map key in the
/// active-filters map. The [label] is shown on the chip. The [type]
/// determines the input control shown in the filter popover.
///
/// {@category Composites}
@immutable
class OiFilterDefinition {
  /// Creates an [OiFilterDefinition].
  const OiFilterDefinition({
    required this.key,
    required this.label,
    required this.type,
    this.options,
    this.customBuilder,
  });

  /// Unique identifier for this filter.
  final String key;

  /// The human-readable label shown on the chip.
  final String label;

  /// The type of input control for this filter.
  final OiFilterType type;

  /// Options for [OiFilterType.select] filters.
  ///
  /// Ignored for other filter types.
  final List<OiSelectOption<String>>? options;

  /// A custom widget builder for [OiFilterType.custom] filters.
  ///
  /// Receives the current value and a callback to update it.
  /// Ignored for other filter types.
  final Widget Function(dynamic value, ValueChanged<dynamic>)? customBuilder;
}

// ── OiFilterBar ──────────────────────────────────────────────────────────────

/// A horizontal bar of filter chips that can be activated to filter data.
///
/// Each filter is a clickable chip that opens a filter popover. Active
/// filters show as filled chips with an X to remove.
///
/// Provide [filters] to define the available filter dimensions and
/// [activeFilters] to control which filters are currently applied.
/// [onFilterChange] is called with the updated map whenever the user
/// activates, modifies, or removes a filter.
///
/// An optional [trailing] widget (e.g. a "Clear all" button) is rendered
/// after the last chip.
///
/// {@category Composites}
class OiFilterBar extends StatefulWidget {
  /// Creates an [OiFilterBar].
  const OiFilterBar({
    required this.filters,
    required this.activeFilters,
    required this.onFilterChange,
    this.trailing,
    this.settingsDriver,
    this.settingsKey,
    this.settingsNamespace = 'oi_filter_bar',
    this.settingsSaveDebounce = const Duration(milliseconds: 500),
    super.key,
  });

  /// The available filter definitions.
  final List<OiFilterDefinition> filters;

  /// The currently active filters keyed by [OiFilterDefinition.key].
  final Map<String, OiColumnFilter> activeFilters;

  /// Called when the active filter set changes.
  final ValueChanged<Map<String, OiColumnFilter>> onFilterChange;

  /// An optional widget rendered after the filter chips (e.g. "Clear all").
  final Widget? trailing;

  // ── Settings persistence ──────────────────────────────────────────────────

  /// Driver used to persist settings. When `null` settings are not persisted.
  final OiSettingsDriver? settingsDriver;

  /// Sub-key scoping this filter bar's settings within [settingsNamespace].
  final String? settingsKey;

  /// Top-level namespace for settings storage.
  final String settingsNamespace;

  /// Debounce duration for auto-saving settings after changes.
  final Duration settingsSaveDebounce;

  @override
  State<OiFilterBar> createState() => _OiFilterBarState();
}

class _OiFilterBarState extends State<OiFilterBar>
    with OiSettingsMixin<OiFilterBar, OiFilterBarSettings> {
  /// Resolved driver: explicit widget prop → OiSettingsProvider → null.
  OiSettingsDriver? _resolvedDriver;

  // ── OiSettingsMixin contract ───────────────────────────────────────────────

  @override
  String get settingsNamespace => widget.settingsNamespace;

  @override
  String? get settingsKey => widget.settingsKey;

  @override
  OiSettingsDriver? get settingsDriver => _resolvedDriver;

  @override
  OiFilterBarSettings get defaultSettings => const OiFilterBarSettings();

  @override
  OiFilterBarSettings deserializeSettings(Map<String, dynamic> json) =>
      OiFilterBarSettings.fromJson(json);

  @override
  OiFilterBarSettings mergeSettings(
    OiFilterBarSettings saved,
    OiFilterBarSettings defaults,
  ) => saved.mergeWith(defaults);

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void initState() {
    _resolvedDriver = widget.settingsDriver;
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newDriver = widget.settingsDriver ?? OiSettingsProvider.of(context);
    if (newDriver != _resolvedDriver) {
      _resolvedDriver = newDriver;
      if (settingsLoaded) {
        reloadSettings();
      }
    }
  }

  OiFilterBarSettings _toSettings() {
    return OiFilterBarSettings(
      activeFilters: widget.activeFilters.map(
        (key, filter) => MapEntry(key, filter.value),
      ),
      filterOrder: widget.activeFilters.keys.toList(),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final filter in widget.filters)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _FilterChip(
                definition: filter,
                active: widget.activeFilters.containsKey(filter.key),
                activeFilter: widget.activeFilters[filter.key],
                onActivate: (chipContext) => _openFilter(chipContext, filter),
                onRemove: () => _removeFilter(filter.key),
              ),
            ),
          if (widget.trailing != null) widget.trailing!,
        ],
      ),
    );
  }

  void _openFilter(BuildContext chipContext, OiFilterDefinition filter) {
    final overlay = Overlay.of(chipContext);
    final box = chipContext.findRenderObject()! as RenderBox;
    final position = box.localToGlobal(Offset.zero);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (ctx) => _FilterPopover(
        definition: filter,
        currentFilter: widget.activeFilters[filter.key],
        anchor: Offset(position.dx, position.dy + box.size.height + 4),
        onApply: (value) {
          final updated = Map<String, OiColumnFilter>.from(widget.activeFilters)
            ..[filter.key] = value;
          widget.onFilterChange(updated);
          updateSettings(_toSettings(), debounce: widget.settingsSaveDebounce);
          entry
            ..remove()
            ..dispose();
        },
        onClose: () {
          entry
            ..remove()
            ..dispose();
        },
      ),
    );
    overlay.insert(entry);
  }

  void _removeFilter(String key) {
    final updated = Map<String, OiColumnFilter>.from(widget.activeFilters)
      ..remove(key);
    widget.onFilterChange(updated);
    updateSettings(_toSettings(), debounce: widget.settingsSaveDebounce);
  }
}

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
    if (v is String) return v;
    return v.toString();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final isActive = widget.active;
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
        child: Container(
          decoration: BoxDecoration(
            color: _chipHovered && !_closeHovered ? hoveredColor : baseColor,
            borderRadius: BorderRadius.circular(100),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.only(
                  left: 12,
                  top: 6,
                  bottom: 6,
                  right: isActive ? 4 : 12,
                ),
                child: Text(
                  isActive
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
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Filter popover ───────────────────────────────────────────────────────────

/// An overlay popover that collects a filter value from the user.
///
/// Positioned as a dropdown below the [anchor] point. For select filters the
/// options are shown directly and tapping one applies immediately. For text
/// filters a text input with an apply button is shown.
class _FilterPopover extends StatefulWidget {
  const _FilterPopover({
    required this.definition,
    required this.onApply,
    required this.onClose,
    required this.anchor,
    this.currentFilter,
  });

  final OiFilterDefinition definition;
  final OiColumnFilter? currentFilter;
  final ValueChanged<OiColumnFilter> onApply;
  final VoidCallback onClose;
  final Offset anchor;

  @override
  State<_FilterPopover> createState() => _FilterPopoverState();
}

class _FilterPopoverState extends State<_FilterPopover> {
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    final initial = widget.currentFilter?.value?.toString() ?? '';
    _textController = TextEditingController(text: initial);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _apply() {
    final value = _textController.text;
    if (value.isNotEmpty) {
      widget.onApply(OiColumnFilter(value: value));
    }
  }

  bool get _isSelect =>
      widget.definition.type == OiFilterType.select &&
      widget.definition.options != null &&
      widget.definition.options!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Stack(
      children: [
        // Barrier.
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.onClose,
            child: const SizedBox.expand(),
          ),
        ),
        // Dropdown positioned below the chip.
        Positioned(
          left: widget.anchor.dx,
          top: widget.anchor.dy,
          child: Container(
            key: const Key('oi_filter_popover'),
            width: 220,
            padding: _isSelect
                ? const EdgeInsets.symmetric(vertical: 4)
                : const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: colors.borderSubtle),
              boxShadow: [
                BoxShadow(
                  color: colors.overlay.withValues(alpha: 0.12),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: _isSelect
                ? _buildSelectOptions(context)
                : _buildTextInput(context),
          ),
        ),
      ],
    );
  }

  Widget _buildSelectOptions(BuildContext context) {
    final currentValue = widget.currentFilter?.value;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final option in widget.definition.options!)
          _FilterOption(
            label: option.label,
            selected: currentValue == option.value,
            onTap: () => widget.onApply(OiColumnFilter(value: option.value)),
          ),
      ],
    );
  }

  Widget _buildTextInput(BuildContext context) {
    final colors = context.colors;

    if (widget.definition.type == OiFilterType.custom &&
        widget.definition.customBuilder != null) {
      return widget.definition.customBuilder!(
        widget.currentFilter?.value,
        (v) => _textController.text = v.toString(),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: colors.border),
            borderRadius: BorderRadius.circular(6),
          ),
          child: EditableText(
            controller: _textController,
            focusNode: FocusNode(),
            style: TextStyle(fontSize: 14, color: colors.text),
            cursorColor: colors.primary.base,
            backgroundCursorColor: colors.border,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          key: const Key('oi_filter_apply'),
          onTap: _apply,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: colors.primary.base,
              borderRadius: BorderRadius.circular(6),
            ),
            alignment: Alignment.center,
            child: Text(
              'Apply',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: colors.textOnPrimary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

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
