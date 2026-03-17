import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/_internal/oi_input_frame.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/interaction/oi_tappable.dart';
import 'package:obers_ui/src/primitives/overlay/oi_floating.dart'
    show OiFloating;

/// A time value with hour and minute components.
///
/// [hour] must be in the range 0–23; [minute] in 0–59.
///
/// {@category Components}
@immutable
class OiTimeOfDay {
  /// Creates an [OiTimeOfDay].
  const OiTimeOfDay({required this.hour, required this.minute});

  /// The hour component, in the range 0–23.
  final int hour;

  /// The minute component, in the range 0–59.
  final int minute;

  @override
  bool operator ==(Object other) =>
      other is OiTimeOfDay && other.hour == hour && other.minute == minute;

  @override
  int get hashCode => Object.hash(hour, minute);

  @override
  String toString() =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
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
  late FixedExtentScrollController _hourCtrl;
  late FixedExtentScrollController _minuteCtrl;

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
    _hourCtrl = FixedExtentScrollController(initialItem: hourItem);
    _minuteCtrl = FixedExtentScrollController(initialItem: _pickerMinute);
  }

  @override
  void dispose() {
    _hourCtrl.dispose();
    _minuteCtrl.dispose();
    super.dispose();
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

  Widget _buildPicker(BuildContext context) {
    final colors = context.colors;
    const itemExtent = 40.0;
    const visibleItems = 5;
    const pickerHeight = itemExtent * visibleItems;

    Widget column(
      int itemCount,
      String Function(int) label,
      FixedExtentScrollController ctrl,
      void Function(int) onChanged,
    ) {
      return SizedBox(
        width: 60,
        height: pickerHeight,
        child: ListWheelScrollView.useDelegate(
          controller: ctrl,
          itemExtent: itemExtent,
          physics: const FixedExtentScrollPhysics(),
          onSelectedItemChanged: onChanged,
          childDelegate: ListWheelChildBuilderDelegate(
            childCount: itemCount,
            builder: (ctx, index) => Center(
              child: Text(
                label(index),
                style: TextStyle(fontSize: 16, color: colors.text),
              ),
            ),
          ),
        ),
      );
    }

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
              column(
                _hourCount,
                (i) {
                  if (widget.use24Hour) return i.toString().padLeft(2, '0');
                  return (i == 0 ? 12 : i).toString().padLeft(2, '0');
                },
                _hourCtrl,
                (i) {
                  setState(() {
                    _pickerHour = widget.use24Hour
                        ? i
                        : (widget.value != null && widget.value!.hour >= 12
                            ? (i == 0 ? 12 : i)
                            : (i == 0 ? 0 : i));
                  });
                },
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
              column(
                60,
                (i) => i.toString().padLeft(2, '0'),
                _minuteCtrl,
                (i) => setState(() => _pickerMinute = i),
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
    final displayText =
        widget.value != null ? _formatTime(widget.value!) : '';

    final clockIcon = Icon(
      const IconData(0xe41e, fontFamily: 'MaterialIcons'),
      size: 18,
      color: colors.textMuted,
    );

    final anchor = GestureDetector(
      onTap: widget.enabled ? () => setState(() => _open = !_open) : null,
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
      anchor: anchor,
      child: UnconstrainedBox(
        alignment: Alignment.topLeft,
        child: _buildPicker(context),
      ),
    );
  }
}
