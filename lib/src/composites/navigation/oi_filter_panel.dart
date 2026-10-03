import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/buttons/oi_button.dart';
import 'package:obers_ui/src/components/inputs/oi_checkbox.dart';
import 'package:obers_ui/src/components/inputs/oi_date_picker_field.dart';
import 'package:obers_ui/src/components/inputs/oi_date_range_picker_field.dart';
import 'package:obers_ui/src/components/inputs/oi_number_input.dart';
import 'package:obers_ui/src/components/inputs/oi_select.dart';
import 'package:obers_ui/src/components/inputs/oi_text_input.dart';
import 'package:obers_ui/src/composites/navigation/oi_filter_bar.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/display/oi_label.dart';

/// A titled group of reusable filter definitions.
@immutable
class OiFilterSection {
  /// Creates a section.
  const OiFilterSection({required this.filters, this.title});

  /// Optional heading.
  final String? title;

  /// Filters in display order.
  final List<OiFilterDefinition> filters;
}

/// Controlled filter content for a sheet, sidebar or custom resource screen.
///
/// The host owns draft values and applies them on [onApply]. Use the same
/// definitions in [OiFilterBar] to keep compact and expanded filters consistent.
class OiFilterPanel extends StatelessWidget {
  /// Creates filter content with optional apply/clear actions.
  const OiFilterPanel({
    required this.sections,
    required this.activeFilters,
    required this.onFilterChange,
    this.onApply,
    this.onClear,
    this.applyLabel = 'Apply filters',
    this.clearLabel = 'Clear all',
    super.key,
  });

  /// Filter sections.
  final List<OiFilterSection> sections;

  /// Controlled values, which may be staged until applying.
  final Map<String, OiColumnFilter> activeFilters;

  /// Reports each draft edit without mutating the supplied map.
  final ValueChanged<Map<String, OiColumnFilter>> onFilterChange;

  /// Applies the host's draft.
  final VoidCallback? onApply;

  /// Clears the host's draft.
  final VoidCallback? onClear;

  /// Apply action label, optionally including a preview count.
  final String applyLabel;

  /// Clear action label.
  final String clearLabel;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    mainAxisSize: MainAxisSize.min,
    children: [
      for (final section in sections)
        Padding(
          padding: EdgeInsets.only(bottom: context.spacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (section.title != null)
                Padding(
                  padding: EdgeInsets.only(bottom: context.spacing.md),
                  child: OiLabel.bodyStrong(section.title!),
                ),
              for (final filter in section.filters)
                Padding(
                  padding: EdgeInsets.only(bottom: context.spacing.md),
                  child: OiFilterInput(
                    key: ValueKey(filter.key),
                    definition: filter,
                    value: activeFilters[filter.key],
                    onChanged: (value) {
                      final next = Map<String, OiColumnFilter>.of(
                        activeFilters,
                      );
                      if (value == null) {
                        next.remove(filter.key);
                      } else {
                        next[filter.key] = value;
                      }
                      onFilterChange(next);
                    },
                  ),
                ),
            ],
          ),
        ),
      if (onApply != null || onClear != null)
        Wrap(
          alignment: WrapAlignment.end,
          spacing: context.spacing.sm,
          runSpacing: context.spacing.sm,
          children: [
            if (onClear != null)
              OiButton.ghost(label: clearLabel, onTap: onClear),
            if (onApply != null)
              OiButton.primary(label: applyLabel, onTap: onApply),
          ],
        ),
    ],
  );
}

/// Shared typed filter editor used by expanded panels and filter popovers.
class OiFilterInput extends StatefulWidget {
  /// Creates an editor for one filter definition.
  const OiFilterInput({
    required this.definition,
    required this.value,
    required this.onChanged,
    super.key,
  });

  /// Filter configuration.
  final OiFilterDefinition definition;

  /// Controlled current value.
  final OiColumnFilter? value;

  /// Null removes the filter.
  final ValueChanged<OiColumnFilter?> onChanged;
  @override
  State<OiFilterInput> createState() => _OiFilterInputState();
}

class _OiFilterInputState extends State<OiFilterInput> {
  late final TextEditingController _text;
  @override
  void initState() {
    super.initState();
    _text = TextEditingController(text: widget.value?.value?.toString() ?? '');
  }

  @override
  void didUpdateWidget(OiFilterInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value?.value != widget.value?.value) {
      final next = widget.value?.value?.toString() ?? '';
      if (_text.text != next) {
        _text.value = TextEditingValue(
          text: next,
          selection: TextSelection.collapsed(offset: next.length),
        );
      }
    }
  }

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  void _set(
    dynamic value, [
    OiFilterOperator operator = OiFilterOperator.equals,
  ]) => widget.onChanged(
    value == null || value == '' || value is List && value.isEmpty
        ? null
        : OiColumnFilter(value: value, operator: operator),
  );
  @override
  Widget build(BuildContext context) {
    final definition = widget.definition;
    final value = widget.value?.value;
    switch (definition.type) {
      case OiFilterType.text:
        return OiTextInput(
          label: definition.label,
          controller: _text,
          onChanged: (value) => _set(value, OiFilterOperator.contains),
        );
      case OiFilterType.select:
        return OiSelect<String>(
          label: definition.label,
          options: definition.options ?? const [],
          value: value is String ? value : null,
          onChanged: _set,
        );
      case OiFilterType.multiSelect:
        final selected = value is Iterable
            ? value.cast<String>().toSet()
            : <String>{};
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            OiLabel.smallStrong(definition.label),
            for (final option
                in definition.options ?? <OiSelectOption<String>>[])
              OiCheckbox(
                label: option.label,
                value: selected.contains(option.value),
                enabled: option.enabled,
                onChanged: (checked) {
                  final next = Set<String>.of(selected);
                  if (checked) {
                    next.add(option.value);
                  } else {
                    next.remove(option.value);
                  }
                  _set(next.toList());
                },
              ),
          ],
        );
      case OiFilterType.date:
        return OiDatePickerField(
          label: definition.label,
          value: value is DateTime ? value : null,
          clearable: true,
          onChanged: _set,
        );
      case OiFilterType.dateRange:
        final range = value is (DateTime, DateTime) ? value : null;
        return OiDateRangePickerField(
          label: definition.label,
          startDate: range?.$1,
          endDate: range?.$2,
          onChanged: (start, end) =>
              _set((start, end), OiFilterOperator.between),
        );
      case OiFilterType.number:
        return OiNumberInput(
          label: definition.label,
          value: value is num ? value.toDouble() : null,
          onChanged: _set,
        );
      case OiFilterType.numberRange:
        final range = value is (num?, num?) ? value : (null, null);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            OiLabel.smallStrong(definition.label),
            Row(
              children: [
                Expanded(
                  child: OiNumberInput(
                    label: 'Minimum',
                    value: range.$1?.toDouble(),
                    onChanged: (v) =>
                        _set((v, range.$2), OiFilterOperator.between),
                  ),
                ),
                SizedBox(width: context.spacing.sm),
                Expanded(
                  child: OiNumberInput(
                    label: 'Maximum',
                    value: range.$2?.toDouble(),
                    onChanged: (v) =>
                        _set((range.$1, v), OiFilterOperator.between),
                  ),
                ),
              ],
            ),
          ],
        );
      case OiFilterType.custom:
        return definition.customBuilder?.call(value, _set) ??
            const SizedBox.shrink();
    }
  }
}
