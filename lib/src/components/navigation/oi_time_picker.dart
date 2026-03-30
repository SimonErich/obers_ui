import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/inputs/oi_time_input.dart'
    show OiTimeOfDay;
import 'package:obers_ui/src/components/overlays/oi_dialog_shell.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/interaction/oi_tappable.dart';

/// A standalone time picker with scrollable hour and minute wheels.
///
/// Displays two [ListWheelScrollView] columns — one for hours, one for
/// minutes — that snap to discrete values. When [use24Hour] is `false` an
/// AM / PM toggle row is shown below the wheels.
///
/// Changes are reported continuously via [onChanged] as the user scrolls.
///
/// {@category Components}
class OiTimePicker extends StatefulWidget {
  /// Creates an [OiTimePicker].
  const OiTimePicker({
    this.value,
    this.onChanged,
    this.use24Hour = true,
    super.key,
  });

  /// The initially selected time.
  final OiTimeOfDay? value;

  /// Called whenever the selected time changes.
  final ValueChanged<OiTimeOfDay>? onChanged;

  /// When `true` the hour wheel shows 0–23; otherwise 1–12 with AM/PM.
  final bool use24Hour;

  /// Shows a time picker in a dialog and returns the selected time.
  ///
  /// Returns `null` if the dialog is dismissed without selecting a time.
  static Future<OiTimeOfDay?> show(
    BuildContext context, {
    OiTimeOfDay? initialTime,
    bool use24Hour = true,
    String semanticLabel = 'Select time',
  }) {
    return OiDialogShell.show<OiTimeOfDay>(
      context: context,
      semanticLabel: semanticLabel,
      builder: (close) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            OiTimePicker(
              value: initialTime,
              use24Hour: use24Hour,
              onChanged: close,
            ),
          ],
        ),
      ),
    );
  }

  @override
  State<OiTimePicker> createState() => _OiTimePickerState();
}

class _OiTimePickerState extends State<OiTimePicker> {
  late int _hour;
  late int _minute;
  late bool _isPm;

  late FixedExtentScrollController _hourCtrl;
  late FixedExtentScrollController _minuteCtrl;

  int get _hourCount => widget.use24Hour ? 24 : 12;

  @override
  void initState() {
    super.initState();
    final ref = widget.value ?? const OiTimeOfDay(hour: 0, minute: 0);
    _hour = ref.hour;
    _minute = ref.minute;
    _isPm = ref.hour >= 12;

    final hourItem = widget.use24Hour
        ? _hour
        : (_hour % 12 == 0 ? 0 : _hour % 12);
    _hourCtrl = FixedExtentScrollController(initialItem: hourItem);
    _minuteCtrl = FixedExtentScrollController(initialItem: _minute);
  }

  @override
  void dispose() {
    _hourCtrl.dispose();
    _minuteCtrl.dispose();
    super.dispose();
  }

  void _onHourChanged(int index) {
    setState(() {
      if (widget.use24Hour) {
        _hour = index;
      } else {
        final h12 = index == 0 ? 12 : index;
        _hour = _isPm ? (h12 == 12 ? 12 : h12 + 12) : (h12 == 12 ? 0 : h12);
      }
    });
    widget.onChanged?.call(OiTimeOfDay(hour: _hour, minute: _minute));
  }

  void _onMinuteChanged(int index) {
    setState(() => _minute = index);
    widget.onChanged?.call(OiTimeOfDay(hour: _hour, minute: _minute));
  }

  void _toggleAmPm() {
    setState(() {
      _isPm = !_isPm;
      if (_isPm && _hour < 12) _hour += 12;
      if (!_isPm && _hour >= 12) _hour -= 12;
    });
    widget.onChanged?.call(OiTimeOfDay(hour: _hour, minute: _minute));
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    const itemExtent = 44.0;
    const visibleItems = 5;
    const pickerHeight = itemExtent * visibleItems;

    final selectedHour = widget.use24Hour
        ? _hour
        : (_hour % 12 == 0 ? 0 : _hour % 12);

    Widget wheel({
      required int itemCount,
      required String Function(int) label,
      required FixedExtentScrollController controller,
      required ValueChanged<int> onChanged,
      required int selectedIndex,
    }) {
      return SizedBox(
        width: 72,
        height: pickerHeight,
        child: ListWheelScrollView.useDelegate(
          controller: controller,
          itemExtent: itemExtent,
          physics: const FixedExtentScrollPhysics(),
          onSelectedItemChanged: onChanged,
          childDelegate: ListWheelChildBuilderDelegate(
            childCount: itemCount,
            builder: (ctx, index) => _WheelItem(
              label: label(index),
              selected: index == selectedIndex,
              onTap: () => controller.animateToItem(
                index,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
              ),
            ),
          ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            wheel(
              itemCount: _hourCount,
              label: (i) {
                if (widget.use24Hour) return i.toString().padLeft(2, '0');
                return (i == 0 ? 12 : i).toString().padLeft(2, '0');
              },
              controller: _hourCtrl,
              onChanged: _onHourChanged,
              selectedIndex: selectedHour,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                ':',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: colors.text,
                ),
              ),
            ),
            wheel(
              itemCount: 60,
              label: (i) => i.toString().padLeft(2, '0'),
              controller: _minuteCtrl,
              onChanged: _onMinuteChanged,
              selectedIndex: _minute,
            ),
          ],
        ),
        if (!widget.use24Hour) ...[
          const SizedBox(height: 12),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _AmPmButton(
                label: 'AM',
                selected: !_isPm,
                onTap: _isPm ? _toggleAmPm : null,
              ),
              const SizedBox(width: 8),
              _AmPmButton(
                label: 'PM',
                selected: _isPm,
                onTap: !_isPm ? _toggleAmPm : null,
              ),
            ],
          ),
        ],
      ],
    );
  }
}

// ── Wheel item with selected highlight and hover ────────────────────────────

class _WheelItem extends StatefulWidget {
  const _WheelItem({required this.label, required this.selected, this.onTap});

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  State<_WheelItem> createState() => _WheelItemState();
}

class _WheelItemState extends State<_WheelItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final selected = widget.selected;

    Color bg;
    Color textColor;
    if (selected) {
      bg = colors.primary.base;
      textColor = colors.textOnPrimary;
    } else if (_hovered) {
      bg = colors.surfaceHover;
      textColor = colors.text;
    } else {
      bg = const Color(0x00000000);
      textColor = colors.text;
    }

    return GestureDetector(
      onTap: widget.onTap,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              widget.label,
              style: TextStyle(
                fontSize: 22,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                color: textColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── AM/PM toggle button ────────────────────────────────────────────────────

class _AmPmButton extends StatelessWidget {
  const _AmPmButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return OiTappable(
      onTap: onTap,
      child: AnimatedContainer(
        duration:
            context.animations.reducedMotion ||
                MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? colors.primary.base : colors.surfaceSubtle,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? colors.primary.base : colors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: selected ? colors.textOnPrimary : colors.textMuted,
          ),
        ),
      ),
    );
  }
}
