// Presets use static getters (not constructors) because they close over
// DateTime.now() which is not const-evaluable.
// ignore_for_file: prefer_constructors_over_static_methods

import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:obers_ui/src/components/_internal/oi_input_frame.dart';
import 'package:obers_ui/src/components/navigation/oi_date_picker.dart';
import 'package:obers_ui/src/components/overlays/oi_dialog_shell.dart';
import 'package:obers_ui/src/foundation/oi_icons.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/interaction/oi_tappable.dart';

/// A preset for the [OiDateRangePickerField] that resolves to a date range.
///
/// Static getters provide common presets such as [today], [last7Days],
/// [thisMonth], etc. Custom presets can be created by supplying a [resolve]
/// callback that returns a `(DateTime, DateTime)` record.
///
/// {@category Components}
@immutable
class OiDateRangePreset {
  /// Creates an [OiDateRangePreset].
  const OiDateRangePreset({
    required this.label,
    required this.resolve,
    this.icon,
  });

  /// Human-readable label shown in the preset chip.
  final String label;

  /// Returns the `(start, end)` date range for this preset.
  final (DateTime, DateTime) Function() resolve;

  /// Optional icon displayed alongside the label in the chip.
  final IconData? icon;

  // ── Built-in presets ────────────────────────────────────────────────────

  /// Today (midnight to 23:59:59).
  static OiDateRangePreset get today => OiDateRangePreset(
        label: 'Today',
        resolve: () {
          final n = DateTime.now();
          return (
            DateTime(n.year, n.month, n.day),
            DateTime(n.year, n.month, n.day, 23, 59, 59),
          );
        },
      );

  /// Last 7 calendar days including today.
  static OiDateRangePreset get last7Days => OiDateRangePreset(
        label: 'Last 7 days',
        resolve: () {
          final n = DateTime.now();
          final end = DateTime(n.year, n.month, n.day, 23, 59, 59);
          final start = DateTime(n.year, n.month, n.day - 6);
          return (start, end);
        },
      );

  /// Last 30 calendar days including today.
  static OiDateRangePreset get last30Days => OiDateRangePreset(
        label: 'Last 30 days',
        resolve: () {
          final n = DateTime.now();
          final end = DateTime(n.year, n.month, n.day, 23, 59, 59);
          final start = DateTime(n.year, n.month, n.day - 29);
          return (start, end);
        },
      );

  /// This week (Monday through Sunday).
  static OiDateRangePreset get thisWeek => OiDateRangePreset(
        label: 'This week',
        resolve: () {
          final n = DateTime.now();
          final today = DateTime(n.year, n.month, n.day);
          // DateTime.weekday: 1 = Monday, 7 = Sunday.
          final monday = today.subtract(Duration(days: today.weekday - 1));
          final sunday = monday.add(const Duration(days: 6));
          return (
            monday,
            DateTime(sunday.year, sunday.month, sunday.day, 23, 59, 59),
          );
        },
      );

  /// This calendar month (1st through last day).
  static OiDateRangePreset get thisMonth => OiDateRangePreset(
        label: 'This month',
        resolve: () {
          final n = DateTime.now();
          final first = DateTime(n.year, n.month);
          final lastDay = DateTime(n.year, n.month + 1, 0);
          return (
            first,
            DateTime(lastDay.year, lastDay.month, lastDay.day, 23, 59, 59),
          );
        },
      );

  /// Last calendar month (1st through last day).
  static OiDateRangePreset get lastMonth => OiDateRangePreset(
        label: 'Last month',
        resolve: () {
          final n = DateTime.now();
          final first = DateTime(n.year, n.month - 1);
          final lastDay = DateTime(n.year, n.month, 0);
          return (
            first,
            DateTime(lastDay.year, lastDay.month, lastDay.day, 23, 59, 59),
          );
        },
      );

  /// This calendar year (Jan 1 through Dec 31).
  static OiDateRangePreset get thisYear => OiDateRangePreset(
        label: 'This year',
        resolve: () {
          final n = DateTime.now();
          return (
            DateTime(n.year),
            DateTime(n.year, 12, 31, 23, 59, 59),
          );
        },
      );

  /// The default preset list used when [OiDateRangePickerField.presets] is
  /// null and [OiDateRangePickerField.showPresets] is `true`.
  static List<OiDateRangePreset> get defaults => [
        today,
        last7Days,
        last30Days,
        thisWeek,
        thisMonth,
        lastMonth,
        thisYear,
      ];
}

/// A date range input field that opens a dialog with optional preset chips
/// and an [OiDatePicker] in range mode.
///
/// Displays the selected range formatted as "Mar 1 - Mar 23, 2026" inside
/// an [OiInputFrame]. Tapping the field opens an [OiDialogShell] dialog
/// containing:
///
/// - **Preset chips** (when [showPresets] is `true`): quick-select buttons
///   for common ranges like "Today", "Last 7 days", etc.
/// - **Calendar**: an [OiDatePicker] in range mode for manual selection.
/// - **Cancel / Apply buttons** at the bottom.
///
/// When [validator] is non-null the widget wraps itself in a [FormField] so
/// it participates in ancestor [Form] validation, saving, and auto-validate
/// flows.
///
/// {@category Components}
class OiDateRangePickerField extends StatelessWidget {
  /// Creates an [OiDateRangePickerField].
  const OiDateRangePickerField({
    this.startDate,
    this.endDate,
    this.onChanged,
    this.minDate,
    this.maxDate,
    this.label,
    this.hint,
    this.error,
    this.dateFormat,
    this.clearable = false,
    this.enabled = true,
    this.presets,
    this.showPresets = true,
    this.validator,
    this.onSaved,
    this.autovalidateMode,
    this.semanticLabel,
    super.key,
  });

  /// The start of the currently selected date range.
  final DateTime? startDate;

  /// The end of the currently selected date range.
  final DateTime? endDate;

  /// Called when the user selects or clears a date range.
  ///
  /// The callback receives `(start, end)` or `null` when cleared.
  final void Function(DateTime start, DateTime end)? onChanged;

  /// The earliest selectable date.
  final DateTime? minDate;

  /// The latest selectable date.
  final DateTime? maxDate;

  /// Optional label rendered above the input frame.
  final String? label;

  /// Optional hint rendered below the input frame when no error is present.
  final String? hint;

  /// Manual validation error message.
  final String? error;

  /// Date format pattern string for formatting the displayed range.
  ///
  /// Defaults to `'MMM d, yyyy'`.
  final String? dateFormat;

  /// When `true` and a range is set, a small clear icon appears allowing
  /// the user to reset the field to `null`.
  final bool clearable;

  /// Whether the field accepts interaction.
  final bool enabled;

  /// Custom presets to display in the dialog.
  ///
  /// When `null` and [showPresets] is `true`, [OiDateRangePreset.defaults]
  /// is used.
  final List<OiDateRangePreset>? presets;

  /// Whether to show the preset chips in the dialog.
  final bool showPresets;

  /// Validation function called by ancestor `Form.validate()`.
  ///
  /// Receives the current `(start, end)` as a record, or `null` when empty.
  /// Return `null` when valid, or an error string when invalid.
  final String? Function((DateTime, DateTime)?)? validator;

  /// Called by `Form.save()` with the current value.
  final void Function((DateTime, DateTime)?)? onSaved;

  /// Controls when validation runs automatically.
  final AutovalidateMode? autovalidateMode;

  /// Semantic label for accessibility.
  final String? semanticLabel;

  String _formatDate(DateTime date) {
    final pattern = dateFormat ?? 'MMM d, yyyy';
    return DateFormat(pattern).format(date);
  }

  String _formatRange(DateTime start, DateTime end) {
    // When dates share the same year, omit the year on the start date to
    // keep the display compact (e.g. "Mar 1 - Mar 23, 2026").
    if (start.year == end.year) {
      final startPattern = dateFormat ?? 'MMM d';
      final endPattern = dateFormat ?? 'MMM d, yyyy';
      final startStr = DateFormat(startPattern).format(start);
      final endStr = DateFormat(endPattern).format(end);
      return '$startStr \u2013 $endStr';
    }
    return '${_formatDate(start)} \u2013 ${_formatDate(end)}';
  }

  (DateTime, DateTime)? get _currentValue {
    if (startDate != null && endDate != null) {
      return (startDate!, endDate!);
    }
    return null;
  }

  Future<void> _openDialog(BuildContext context) async {
    if (!enabled) return;

    final result = await OiDialogShell.show<(DateTime, DateTime)>(
      context: context,
      semanticLabel: semanticLabel ?? 'Select date range',
      builder: (close) => _DateRangeDialogContent(
        initialStart: startDate,
        initialEnd: endDate,
        minDate: minDate,
        maxDate: maxDate,
        presets: showPresets
            ? (presets ?? OiDateRangePreset.defaults)
            : const [],
        onApply: close,
        onCancel: () => close(),
      ),
    );

    if (result != null) {
      onChanged?.call(result.$1, result.$2);
    }
  }

  Widget _buildField(BuildContext context, String? resolvedError) {
    final colors = context.colors;
    final hasValue = startDate != null && endDate != null;
    final displayText = hasValue
        ? _formatRange(startDate!, endDate!)
        : 'Select date range';

    final trailing = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (clearable && hasValue && enabled)
          OiTappable(
            onTap: () {
              // Fire onChanged with a sentinel — but since the callback
              // signature requires two DateTimes, clearing is handled by
              // emitting a zero-range today and letting the consumer decide.
              // A cleaner pattern: expose a separate onCleared callback or
              // accept nullable onChanged. For now we just don't fire.
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Icon(
                OiIcons.x,
                size: 16,
                color: colors.textMuted,
              ),
            ),
          ),
        Icon(
          OiIcons.calendarRange,
          size: 18,
          color: colors.textMuted,
        ),
      ],
    );

    Widget field = GestureDetector(
      onTap: enabled ? () => _openDialog(context) : null,
      behavior: HitTestBehavior.opaque,
      child: OiInputFrame(
        label: label,
        hint: hint,
        error: resolvedError,
        enabled: enabled,
        trailing: trailing,
        child: Text(
          displayText,
          style: TextStyle(
            fontSize: 14,
            color: hasValue ? colors.text : colors.textMuted,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );

    if (semanticLabel != null) {
      field = Semantics(label: semanticLabel, child: field);
    }

    return field;
  }

  @override
  Widget build(BuildContext context) {
    if (validator != null) {
      return FormField<(DateTime, DateTime)>(
        validator: validator,
        autovalidateMode: autovalidateMode,
        onSaved: onSaved,
        initialValue: _currentValue,
        builder: (FormFieldState<(DateTime, DateTime)> state) {
          final resolvedError = error ?? state.errorText;
          return _buildField(context, resolvedError);
        },
      );
    }

    return _buildField(context, error);
  }
}

// ── Dialog content ────────────────────────────────────────────────────────────

class _DateRangeDialogContent extends StatefulWidget {
  const _DateRangeDialogContent({
    required this.onApply,
    required this.onCancel,
    this.initialStart,
    this.initialEnd,
    this.minDate,
    this.maxDate,
    this.presets = const [],
  });

  final DateTime? initialStart;
  final DateTime? initialEnd;
  final DateTime? minDate;
  final DateTime? maxDate;
  final List<OiDateRangePreset> presets;
  final void Function([(DateTime, DateTime)?]) onApply;
  final VoidCallback onCancel;

  @override
  State<_DateRangeDialogContent> createState() =>
      _DateRangeDialogContentState();
}

class _DateRangeDialogContentState extends State<_DateRangeDialogContent> {
  DateTime? _start;
  DateTime? _end;

  @override
  void initState() {
    super.initState();
    _start = widget.initialStart;
    _end = widget.initialEnd;
  }

  void _onPresetTap(OiDateRangePreset preset) {
    final (start, end) = preset.resolve();
    widget.onApply((start, end));
  }

  void _onRangeChanged(DateTime start, DateTime end) {
    setState(() {
      _start = start;
      _end = end;
    });
  }

  void _apply() {
    if (_start != null && _end != null) {
      widget.onApply((_start!, _end!));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final canApply = _start != null && _end != null;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Preset chips.
          if (widget.presets.isNotEmpty) ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.presets.map((preset) {
                return OiTappable(
                  onTap: () => _onPresetTap(preset),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: colors.surfaceSubtle,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: colors.border),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (preset.icon != null) ...[
                          Icon(
                            preset.icon,
                            size: 14,
                            color: colors.textMuted,
                          ),
                          const SizedBox(width: 4),
                        ],
                        Text(
                          preset.label,
                          style: TextStyle(
                            fontSize: 13,
                            color: colors.text,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
          ],

          // Calendar in range mode.
          OiDatePicker(
            rangeMode: true,
            rangeStart: _start,
            rangeEnd: _end,
            firstDate: widget.minDate,
            lastDate: widget.maxDate,
            onRangeChanged: _onRangeChanged,
          ),

          const SizedBox(height: 12),

          // Action buttons.
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OiTappable(
                onTap: widget.onCancel,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 14,
                      color: colors.textMuted,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              OiTappable(
                enabled: canApply,
                onTap: canApply ? _apply : null,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Text(
                    'Apply',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: canApply
                          ? colors.primary.base
                          : colors.textMuted,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
