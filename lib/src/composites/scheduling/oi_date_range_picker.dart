import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/buttons/oi_button.dart';
import 'package:obers_ui/src/components/inputs/oi_date_range_picker_field.dart';
import 'package:obers_ui/src/components/inputs/oi_time_input.dart';
import 'package:obers_ui/src/components/navigation/oi_date_picker.dart';
import 'package:obers_ui/src/foundation/oi_responsive.dart';
import 'package:obers_ui/src/foundation/theme/oi_spacing_scale.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/display/oi_label.dart';
import 'package:obers_ui/src/primitives/layout/oi_column.dart';
import 'package:obers_ui/src/primitives/layout/oi_row.dart';

/// Dual-calendar date range selector with quick-select presets.
///
/// Use inside an `OiPopover`, `OiDialog`, or inline in a page.
/// For a form field that opens this picker, use [OiDateRangePickerField].
///
/// ```dart
/// OiDateRangePicker(
///   label: 'Select period',
///   onApply: (start, end) => print('$start – $end'),
/// )
/// ```
///
/// {@category Composites}
class OiDateRangePicker extends StatefulWidget {
  /// Creates an [OiDateRangePicker].
  const OiDateRangePicker({
    required this.label,
    this.startDate,
    this.endDate,
    this.onApply,
    this.onCancel,
    this.presets,
    this.firstDate,
    this.lastDate,
    this.singleCalendar = false,
    this.showPresets = true,
    this.applyLabel,
    this.cancelLabel,
    this.semanticLabel,
    this.disabledDates,
    this.disabledDaysOfWeek,
    this.locale,
    this.firstDayOfWeek,
    this.showTimePicker = false,
    super.key,
  });

  /// Accessibility label for the picker region.
  final String label;

  /// Currently selected start date (inclusive).
  final DateTime? startDate;

  /// Currently selected end date (inclusive).
  final DateTime? endDate;

  /// Called when the user taps Apply with the selected range.
  final void Function(DateTime start, DateTime end)? onApply;

  /// Called when the user taps Cancel.
  final VoidCallback? onCancel;

  /// Quick-select presets shown alongside the calendars.
  /// Defaults to [OiDateRangePreset.defaults] if null.
  final List<OiDateRangePreset>? presets;

  /// Earliest selectable date.
  final DateTime? firstDate;

  /// Latest selectable date.
  final DateTime? lastDate;

  /// Show only one calendar instead of two side-by-side.
  /// Automatically true on compact breakpoints.
  final bool singleCalendar;

  /// Whether to show the presets panel.
  final bool showPresets;

  /// Override label for the Apply button.
  final String? applyLabel;

  /// Override label for the Cancel button.
  final String? cancelLabel;

  /// Accessibility label.
  final String? semanticLabel;

  /// Specific dates that cannot be selected.
  final Set<DateTime>? disabledDates;

  /// Days of the week that cannot be selected (1=Monday, 7=Sunday).
  final Set<int>? disabledDaysOfWeek;

  /// Locale for month/day names. Defaults to app locale.
  final Locale? locale;

  /// First day of the week (1=Monday, 7=Sunday). Defaults to locale default.
  final int? firstDayOfWeek;

  /// Whether to show time pickers below each calendar.
  final bool showTimePicker;

  @override
  State<OiDateRangePicker> createState() => _OiDateRangePickerState();
}

class _OiDateRangePickerState extends State<OiDateRangePicker> {
  DateTime? _start;
  DateTime? _end;
  OiTimeOfDay? _startTime;
  OiTimeOfDay? _endTime;
  late DateTime _leftMonth;
  late DateTime _rightMonth;

  @override
  void initState() {
    super.initState();
    _start = widget.startDate;
    _end = widget.endDate;
    // Initialise time fields from incoming dates when time picker is enabled.
    if (widget.showTimePicker && _start != null) {
      _startTime = OiTimeOfDay(hour: _start!.hour, minute: _start!.minute);
    }
    if (widget.showTimePicker && _end != null) {
      _endTime = OiTimeOfDay(hour: _end!.hour, minute: _end!.minute);
    }
    final ref = _start ?? DateTime.now();
    _leftMonth = DateTime(ref.year, ref.month);
    _rightMonth = DateTime(ref.year, ref.month + 1);
  }

  void _onLeftMonthChanged(DateTime month) {
    setState(() {
      _leftMonth = DateTime(month.year, month.month);
      // Ensure right is always >= left + 1 month.
      final minRight = DateTime(_leftMonth.year, _leftMonth.month + 1);
      if (_rightMonth.isBefore(minRight) ||
          _rightMonth.isAtSameMomentAs(minRight)) {
        // Only advance right if it would overlap with left.
        if (_rightMonth.year == _leftMonth.year &&
            _rightMonth.month == _leftMonth.month) {
          _rightMonth = minRight;
        }
      }
    });
  }

  void _onRightMonthChanged(DateTime month) {
    setState(() {
      _rightMonth = DateTime(month.year, month.month);
      // Ensure right >= left + 1 month.
      if (_rightMonth.year == _leftMonth.year &&
          _rightMonth.month <= _leftMonth.month) {
        _rightMonth = DateTime(_leftMonth.year, _leftMonth.month + 1);
      }
    });
  }

  void _onRangeSelected(DateTime start, DateTime end) {
    setState(() {
      // Auto-swap if end < start.
      if (end.isBefore(start)) {
        _start = end;
        _end = start;
      } else {
        _start = start;
        _end = end;
      }
    });
  }

  void _onPresetTap(OiDateRangePreset preset) {
    final (start, end) = preset.resolve();
    setState(() {
      _start = start;
      _end = end;
      _leftMonth = DateTime(start.year, start.month);
      final nextMonth = DateTime(start.year, start.month + 1);
      _rightMonth = end.month == start.month && end.year == start.year
          ? nextMonth
          : DateTime(end.year, end.month);
    });
  }

  DateTime _combineDateAndTime(DateTime date, OiTimeOfDay? time) {
    if (time == null) return date;
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  void _apply() {
    if (_start != null && _end != null) {
      final start = widget.showTimePicker
          ? _combineDateAndTime(_start!, _startTime)
          : _start!;
      final end = widget.showTimePicker
          ? _combineDateAndTime(_end!, _endTime)
          : _end!;
      widget.onApply?.call(start, end);
    }
  }

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final breakpoint = context.breakpoint;
    final isCompact =
        widget.singleCalendar ||
        breakpoint.compareTo(OiBreakpoint.compact) <= 0;
    final effectivePresets = widget.presets ?? OiDateRangePreset.defaults;

    return Semantics(
      label: widget.semanticLabel ?? widget.label,
      child: OiColumn(
        breakpoint: breakpoint,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Presets + calendars.
          if (isCompact)
            _buildCompactLayout(context, effectivePresets, spacing, breakpoint)
          else
            _buildExpandedLayout(
              context,
              effectivePresets,
              spacing,
              breakpoint,
            ),

          // Footer: Cancel + Apply.
          Padding(
            padding: EdgeInsets.only(top: spacing.md),
            child: OiRow(
              breakpoint: breakpoint,
              gap: OiResponsive<double>(spacing.sm),
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OiButton.ghost(
                  label: widget.cancelLabel ?? 'Cancel',
                  onTap: widget.onCancel,
                ),
                OiButton.primary(
                  label: widget.applyLabel ?? 'Apply',
                  onTap: _start != null && _end != null ? _apply : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedLayout(
    BuildContext context,
    List<OiDateRangePreset> presets,
    OiSpacingScale spacing,
    OiBreakpoint breakpoint,
  ) {
    return OiRow(
      breakpoint: breakpoint,
      gap: OiResponsive<double>(spacing.md),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.showPresets)
          SizedBox(
            width: 160,
            child: _buildPresetsList(context, presets, spacing, breakpoint),
          ),
        Expanded(
          child: OiColumn(
            breakpoint: breakpoint,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              OiDatePicker(
                rangeMode: true,
                rangeStart: _start,
                rangeEnd: _end,
                onRangeChanged: _onRangeSelected,
                firstDate: widget.firstDate,
                lastDate: widget.lastDate,
                disabledDates: widget.disabledDates,
                disabledDaysOfWeek: widget.disabledDaysOfWeek,
                firstDayOfWeek: widget.firstDayOfWeek,
                displayMonth: _leftMonth,
                onDisplayMonthChanged: _onLeftMonthChanged,
              ),
              if (widget.showTimePicker)
                Padding(
                  padding: EdgeInsets.only(top: spacing.sm),
                  child: OiTimeInput(
                    label: 'Start time',
                    value: _startTime,
                    onChanged: (time) => setState(() => _startTime = time),
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: OiColumn(
            breakpoint: breakpoint,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              OiDatePicker(
                rangeMode: true,
                rangeStart: _start,
                rangeEnd: _end,
                onRangeChanged: _onRangeSelected,
                firstDate: widget.firstDate,
                lastDate: widget.lastDate,
                disabledDates: widget.disabledDates,
                disabledDaysOfWeek: widget.disabledDaysOfWeek,
                firstDayOfWeek: widget.firstDayOfWeek,
                displayMonth: _rightMonth,
                onDisplayMonthChanged: _onRightMonthChanged,
              ),
              if (widget.showTimePicker)
                Padding(
                  padding: EdgeInsets.only(top: spacing.sm),
                  child: OiTimeInput(
                    label: 'End time',
                    value: _endTime,
                    onChanged: (time) => setState(() => _endTime = time),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCompactLayout(
    BuildContext context,
    List<OiDateRangePreset> presets,
    OiSpacingScale spacing,
    OiBreakpoint breakpoint,
  ) {
    return OiColumn(
      breakpoint: breakpoint,
      gap: OiResponsive<double>(spacing.sm),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.showPresets)
          _buildPresetsChips(context, presets, spacing, breakpoint),
        OiDatePicker(
          rangeMode: true,
          rangeStart: _start,
          rangeEnd: _end,
          onRangeChanged: _onRangeSelected,
          firstDate: widget.firstDate,
          lastDate: widget.lastDate,
          disabledDates: widget.disabledDates,
          disabledDaysOfWeek: widget.disabledDaysOfWeek,
          firstDayOfWeek: widget.firstDayOfWeek,
          displayMonth: _leftMonth,
          onDisplayMonthChanged: _onLeftMonthChanged,
        ),
        if (widget.showTimePicker)
          OiTimeInput(
            label: 'Start time',
            value: _startTime,
            onChanged: (time) => setState(() => _startTime = time),
          ),
        if (widget.showTimePicker)
          OiTimeInput(
            label: 'End time',
            value: _endTime,
            onChanged: (time) => setState(() => _endTime = time),
          ),
      ],
    );
  }

  Widget _buildPresetsList(
    BuildContext context,
    List<OiDateRangePreset> presets,
    OiSpacingScale spacing,
    OiBreakpoint breakpoint,
  ) {
    return OiColumn(
      breakpoint: breakpoint,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final preset in presets)
          Padding(
            padding: EdgeInsets.only(bottom: spacing.xs / 2),
            child: OiButton.ghost(
              label: preset.label,
              onTap: () => _onPresetTap(preset),
              size: OiButtonSize.small,
            ),
          ),
      ],
    );
  }

  Widget _buildPresetsChips(
    BuildContext context,
    List<OiDateRangePreset> presets,
    OiSpacingScale spacing,
    OiBreakpoint breakpoint,
  ) {
    return Wrap(
      spacing: spacing.xs,
      runSpacing: spacing.xs,
      children: [
        for (final preset in presets)
          OiButton.outline(
            label: preset.label,
            onTap: () => _onPresetTap(preset),
            size: OiButtonSize.small,
          ),
      ],
    );
  }
}
