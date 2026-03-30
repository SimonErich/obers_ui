import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/_internal/oi_input_frame.dart';
import 'package:obers_ui/src/foundation/oi_icons.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/interaction/oi_tappable.dart';
import 'package:obers_ui/src/primitives/overlay/oi_floating.dart'
    show OiFloating;

/// A time of day independent of Flutter's Material TimeOfDay.
///
/// Zero-dependency. [Comparable]. Immutable.
///
/// [hour] must be in the range 0–23; [minute] in 0–59; [second] in 0–59.
///
/// {@category Components}
@immutable
class OiTimeOfDay implements Comparable<OiTimeOfDay> {
  /// Creates an [OiTimeOfDay].
  const OiTimeOfDay({
    required this.hour,
    required this.minute,
    this.second = 0,
  });

  /// Creates an [OiTimeOfDay] from the current local time.
  factory OiTimeOfDay.now() {
    final now = DateTime.now();
    return OiTimeOfDay(hour: now.hour, minute: now.minute, second: now.second);
  }

  /// The hour component, in the range 0–23.
  final int hour;

  /// The minute component, in the range 0–59.
  final int minute;

  /// The second component, in the range 0–59.
  final int second;

  /// Formats as 24-hour `HH:MM` (or `HH:MM:SS` when [second] is non-zero).
  String format24() {
    final hh = hour.toString().padLeft(2, '0');
    final mm = minute.toString().padLeft(2, '0');
    if (second != 0) {
      final ss = second.toString().padLeft(2, '0');
      return '$hh:$mm:$ss';
    }
    return '$hh:$mm';
  }

  /// Formats as 12-hour `h:MM AM/PM`.
  String format12() {
    final period = hour < 12 ? 'AM' : 'PM';
    final h = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    final mm = minute.toString().padLeft(2, '0');
    return '$h:$mm $period';
  }

  @override
  int compareTo(OiTimeOfDay other) {
    if (hour != other.hour) return hour.compareTo(other.hour);
    if (minute != other.minute) return minute.compareTo(other.minute);
    return second.compareTo(other.second);
  }

  @override
  bool operator ==(Object other) =>
      other is OiTimeOfDay &&
      other.hour == hour &&
      other.minute == minute &&
      other.second == second;

  @override
  int get hashCode => Object.hash(hour, minute, second);

  @override
  String toString() => format24();
}

/// A time-picker input component.
///
/// Shows the current [value] as `HH:MM` text and opens an overlay with hour
/// and minute [ListWheelScrollView] pickers when tapped. Supports both 24-hour
/// and 12-hour (AM/PM) display via [use24Hour].
///
/// {@category Components}
class OiTimeInput extends StatefulWidget {
  /// Creates an [OiTimeInput].
  const OiTimeInput({
    this.value,
    this.onChanged,
    this.label,
    this.hint,
    this.error,
    this.enabled = true,
    this.use24Hour = true,
    super.key,
  });

  /// The currently selected time.
  final OiTimeOfDay? value;

  /// Called when the user selects a time.
  final ValueChanged<OiTimeOfDay?>? onChanged;

  /// Optional label rendered above the frame.
  final String? label;

  /// Optional hint rendered below the frame.
  final String? hint;

  /// Validation error message.
  final String? error;

  /// Whether the field accepts interaction.
  final bool enabled;

  /// When true the picker uses 24-hour format; otherwise 12-hour with AM/PM.
  final bool use24Hour;

  @override
  State<OiTimeInput> createState() => _OiTimeInputState();
}

class _OiTimeInputState extends State<OiTimeInput> {
  bool _open = false;
  late int _pickerHour;
  late int _pickerMinute;
  late ScrollController _hourCtrl;
  late ScrollController _minuteCtrl;

  static const double _itemHeight = 36;
  static const int _visibleItems = 5;
  static const double _centerOffset = (_visibleItems ~/ 2) * _itemHeight;

  int get _hourCount => widget.use24Hour ? 24 : 12;

  @override
  void initState() {
    super.initState();
    final ref = widget.value ?? const OiTimeOfDay(hour: 0, minute: 0);
    _pickerHour = ref.hour;
    _pickerMinute = ref.minute;
    _initControllers();
  }

  void _initControllers() {
    final hourItem = widget.use24Hour ? _pickerHour : (_pickerHour % 12);
    _hourCtrl = ScrollController(
      initialScrollOffset: (hourItem * _itemHeight - _centerOffset).clamp(
        0.0,
        double.infinity,
      ),
    );
    _minuteCtrl = ScrollController(
      initialScrollOffset: (_pickerMinute * _itemHeight - _centerOffset).clamp(
        0.0,
        double.infinity,
      ),
    );
  }

  @override
  void didUpdateWidget(OiTimeInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value && !_open) {
      final ref = widget.value ?? const OiTimeOfDay(hour: 0, minute: 0);
      _pickerHour = ref.hour;
      _pickerMinute = ref.minute;
    }
  }

  @override
  void dispose() {
    _hourCtrl.dispose();
    _minuteCtrl.dispose();
    super.dispose();
  }

  void _togglePicker() {
    if (_open) {
      setState(() => _open = false);
      return;
    }
    _hourCtrl.dispose();
    _minuteCtrl.dispose();
    final ref = widget.value ?? const OiTimeOfDay(hour: 0, minute: 0);
    _pickerHour = ref.hour;
    _pickerMinute = ref.minute;
    _initControllers();
    setState(() => _open = true);
  }

  String _formatTime(OiTimeOfDay t) {
    if (widget.use24Hour) {
      return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
    }
    final h = t.hour % 12 == 0 ? 12 : t.hour % 12;
    final ampm = t.hour < 12 ? 'AM' : 'PM';
    return '${h.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')} $ampm';
  }

  void _confirmPicker() {
    widget.onChanged?.call(
      OiTimeOfDay(hour: _pickerHour, minute: _pickerMinute),
    );
    setState(() => _open = false);
  }

  void _cancelPicker() => setState(() => _open = false);

  Widget _buildPickerColumn({
    required BuildContext context,
    required int itemCount,
    required String Function(int) label,
    required int selectedIndex,
    required void Function(int) onSelected,
    required ScrollController scrollCtrl,
    double width = 60,
  }) {
    final colors = context.colors;
    const columnHeight = _itemHeight * _visibleItems;

    return SizedBox(
      width: width,
      height: columnHeight,
      child: ListView.builder(
        controller: scrollCtrl,
        itemCount: itemCount,
        itemExtent: _itemHeight,
        itemBuilder: (context, index) {
          final isSelected = index == selectedIndex;
          return OiTappable(
            onTap: () => onSelected(index),
            clipBorderRadius: BorderRadius.circular(6),
            child: Container(
              height: _itemHeight,
              alignment: Alignment.center,
              decoration: isSelected
                  ? BoxDecoration(
                      color: colors.primary.base.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    )
                  : null,
              child: Text(
                label(index),
                style: TextStyle(
                  fontSize: 15,
                  color: isSelected ? colors.primary.base : colors.text,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPicker(BuildContext context) {
    final colors = context.colors;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: colors.overlay,
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildPickerColumn(
                context: context,
                itemCount: _hourCount,
                label: (i) {
                  if (widget.use24Hour) return i.toString().padLeft(2, '0');
                  return (i == 0 ? 12 : i).toString().padLeft(2, '0');
                },
                selectedIndex: widget.use24Hour
                    ? _pickerHour
                    : (_pickerHour % 12),
                onSelected: (i) {
                  setState(() {
                    _pickerHour = widget.use24Hour
                        ? i
                        : (widget.value != null && widget.value!.hour >= 12
                              ? (i == 0 ? 12 : i)
                              : (i == 0 ? 0 : i));
                  });
                },
                scrollCtrl: _hourCtrl,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  ':',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: colors.text,
                  ),
                ),
              ),
              _buildPickerColumn(
                context: context,
                itemCount: 60,
                label: (i) => i.toString().padLeft(2, '0'),
                selectedIndex: _pickerMinute,
                onSelected: (i) => setState(() => _pickerMinute = i),
                scrollCtrl: _minuteCtrl,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              OiTappable(
                onTap: _cancelPicker,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: colors.textMuted),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              OiTappable(
                onTap: _confirmPicker,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Text(
                    'OK',
                    style: TextStyle(
                      color: colors.primary.base,
                      fontWeight: FontWeight.w600,
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

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final displayText = widget.value != null ? _formatTime(widget.value!) : '';

    final clockIcon = Icon(OiIcons.clock, size: 18, color: colors.textMuted);

    final anchor = GestureDetector(
      onTap: widget.enabled ? _togglePicker : null,
      behavior: HitTestBehavior.opaque,
      child: OiInputFrame(
        label: widget.label,
        hint: widget.hint,
        error: widget.error,
        focused: _open,
        enabled: widget.enabled,
        trailing: clockIcon,
        child: Text(
          displayText,
          style: TextStyle(
            fontSize: 14,
            color: displayText.isEmpty ? colors.textMuted : colors.text,
          ),
        ),
      ),
    );

    return OiFloating(
      visible: _open,
      onDismiss: _cancelPicker,
      anchor: anchor,
      child: UnconstrainedBox(
        alignment: Alignment.topLeft,
        child: _buildPicker(context),
      ),
    );
  }
}
