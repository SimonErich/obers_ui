import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/inputs/oi_select.dart';
import 'package:obers_ui/src/foundation/oi_icons.dart';
import 'package:obers_ui/src/foundation/persistence/oi_settings_driver.dart';
import 'package:obers_ui/src/foundation/persistence/oi_settings_mixin.dart';
import 'package:obers_ui/src/foundation/persistence/oi_settings_provider.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/models/settings/oi_filter_bar_settings.dart';
import 'package:obers_ui/src/primitives/interaction/oi_tappable.dart';

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
                onActivate: () => _openFilter(context, filter),
                onRemove: () => _removeFilter(filter.key),
              ),
            ),
          if (widget.trailing != null) widget.trailing!,
        ],
      ),
    );
  }

  void _openFilter(BuildContext context, OiFilterDefinition filter) {
    // Show the filter popover as an overlay.
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (ctx) => _FilterPopover(
        definition: filter,
        currentFilter: widget.activeFilters[filter.key],
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
class _FilterChip extends StatelessWidget {
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
  final VoidCallback onActivate;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final bgColor = active
        ? colors.primary.base.withValues(alpha: 0.1)
        : colors.surfaceSubtle;
    final textColor = active ? colors.primary.base : colors.text;
    final borderColor = active ? colors.primary.base : colors.border;

    return OiTappable(
      onTap: onActivate,
      semanticLabel: definition.label,
      clipBorderRadius: BorderRadius.circular(100),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              active
                  ? '${definition.label}: ${_formatValue(activeFilter)}'
                  : definition.label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                color: textColor,
              ),
            ),
            if (active) ...[
              const SizedBox(width: 6),
              GestureDetector(
                onTap: onRemove,
                behavior: HitTestBehavior.opaque,
                child: Icon(
                  OiIcons.x,
                  size: 14,
                  color: textColor,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatValue(OiColumnFilter? filter) {
    if (filter == null) return '';
    final v = filter.value;
    if (v is String) return v;
    return v.toString();
  }
}

// ── Filter popover ───────────────────────────────────────────────────────────

/// An overlay popover that collects a filter value from the user.
class _FilterPopover extends StatefulWidget {
  const _FilterPopover({
    required this.definition,
    required this.onApply,
    required this.onClose,
    this.currentFilter,
  });

  final OiFilterDefinition definition;
  final OiColumnFilter? currentFilter;
  final ValueChanged<OiColumnFilter> onApply;
  final VoidCallback onClose;

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
        // Popover content.
        Center(
          child: Container(
            key: const Key('oi_filter_popover'),
            width: 280,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: colors.border),
              boxShadow: [
                BoxShadow(
                  color: colors.overlay.withValues(alpha: 0.15),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  widget.definition.label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colors.text,
                  ),
                ),
                const SizedBox(height: 12),
                _buildInput(context),
                const SizedBox(height: 12),
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
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInput(BuildContext context) {
    final colors = context.colors;

    if (widget.definition.type == OiFilterType.custom &&
        widget.definition.customBuilder != null) {
      return widget.definition.customBuilder!(
        widget.currentFilter?.value,
        (v) => _textController.text = v.toString(),
      );
    }

    // Default: text input for all other types.
    return Container(
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
    );
  }
}
