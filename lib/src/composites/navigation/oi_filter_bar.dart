import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/inputs/oi_checkbox.dart';
import 'package:obers_ui/src/components/inputs/oi_select.dart';
import 'package:obers_ui/src/components/inputs/oi_text_input.dart';
import 'package:obers_ui/src/components/navigation/oi_date_picker.dart';
import 'package:obers_ui/src/foundation/oi_icons.dart';
import 'package:obers_ui/src/foundation/oi_overlays.dart';
import 'package:obers_ui/src/foundation/persistence/oi_settings_driver.dart';
import 'package:obers_ui/src/foundation/persistence/oi_settings_mixin.dart';
import 'package:obers_ui/src/foundation/persistence/oi_settings_provider.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/models/settings/oi_filter_bar_settings.dart';

part 'oi_filter_bar/oi_filter_bar_chip.part.dart';
part 'oi_filter_bar/oi_filter_bar_options.part.dart';
part 'oi_filter_bar/oi_filter_bar_popover.part.dart';

// ── Filter types ─────────────────────────────────────────────────────────────

/// The type of filter input.
///
/// {@category Composites}
enum OiFilterType {
  /// A free-text filter.
  text,

  /// A select / dropdown filter with predefined [OiSelectOption]s.
  select,

  /// A multi-select filter with checkboxes for each option.
  multiSelect,

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
    this.suggestions,
    this.customBuilder,
  });

  /// Unique identifier for this filter.
  final String key;

  /// The human-readable label shown on the chip.
  final String label;

  /// The type of input control for this filter.
  final OiFilterType type;

  /// Options for [OiFilterType.select] and [OiFilterType.multiSelect] filters.
  ///
  /// Ignored for other filter types.
  final List<OiSelectOption<String>>? options;

  /// Static suggestions for [OiFilterType.text] filters.
  ///
  /// When provided, the text filter popover shows a search input with a
  /// filterable list of suggestions below it.
  final List<String>? suggestions;

  /// A custom widget builder for [OiFilterType.custom] filters.
  ///
  /// Receives the current value and a callback to update it.
  /// Ignored for other filter types.
  final Widget Function(dynamic value, ValueChanged<dynamic>)? customBuilder;
}

// ── OiFilterBar ────────────────────────────────────────────────────────────

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
  void dispose() {
    _closeFilter();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newDriver = widget.settingsDriver ?? OiSettingsProvider.of(context);
    if (newDriver != _resolvedDriver) {
      _resolvedDriver = newDriver;
      if (settingsLoaded) {
        unawaited(reloadSettings());
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

  OiOverlayHandle? _filterHandle;

  void _closeFilter() {
    _filterHandle?.dismiss();
    _filterHandle = null;
  }

  void _openFilter(BuildContext chipContext, OiFilterDefinition filter) {
    // For date filters, open the date picker dialog directly.
    if (filter.type == OiFilterType.date) {
      unawaited(_openDatePicker(chipContext, filter));
      return;
    }

    _closeFilter();

    final box = chipContext.findRenderObject()! as RenderBox;
    final position = box.localToGlobal(Offset.zero);

    Widget popoverBuilder(BuildContext ctx) {
      return _FilterPopover(
        definition: filter,
        currentFilter: widget.activeFilters[filter.key],
        anchor: Offset(position.dx, position.dy + box.size.height + 4),
        onApply: (value) {
          final updated = Map<String, OiColumnFilter>.from(widget.activeFilters)
            ..[filter.key] = value;
          widget.onFilterChange(updated);
          updateSettings(_toSettings(), debounce: widget.settingsSaveDebounce);
          _closeFilter();
        },
        onClose: _closeFilter,
      );
    }

    final service = OiOverlays.maybeOf(chipContext);
    if (service != null) {
      _filterHandle = service.show(
        label: '${filter.label} filter',
        builder: popoverBuilder,
        zOrder: OiOverlayZOrder.dropdown,
        dismissOnScroll: true,
        onDismiss: _closeFilter,
      );
    } else {
      // Fallback: insert directly into the nearest Flutter Overlay.
      final overlay = Overlay.of(chipContext);
      final entry = OverlayEntry(builder: popoverBuilder);
      overlay.insert(entry);
      _filterHandle = createOiOverlayHandle(entry);
    }
  }

  Future<void> _openDatePicker(
    BuildContext chipContext,
    OiFilterDefinition filter,
  ) async {
    final currentValue = widget.activeFilters[filter.key]?.value;
    final initialDate = currentValue is DateTime ? currentValue : null;

    final result = await OiDatePicker.show(
      chipContext,
      initialDate: initialDate,
    );
    if (result != null && mounted) {
      final updated = Map<String, OiColumnFilter>.from(widget.activeFilters)
        ..[filter.key] = OiColumnFilter(value: result);
      widget.onFilterChange(updated);
      updateSettings(_toSettings(), debounce: widget.settingsSaveDebounce);
    }
  }

  void _removeFilter(String key) {
    final updated = Map<String, OiColumnFilter>.from(widget.activeFilters)
      ..remove(key);
    widget.onFilterChange(updated);
    updateSettings(_toSettings(), debounce: widget.settingsSaveDebounce);
  }
}
