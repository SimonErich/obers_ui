import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';

import 'package:obers_ui_example/data/mock_calendar.dart';

/// Scheduler screen for the Project mini-app.
///
/// Shows a day/week team schedule using [OiScheduler] with interactive
/// slot tapping and empty time-cell tapping.
class ProjectSchedulerScreen extends StatefulWidget {
  const ProjectSchedulerScreen({super.key});

  @override
  State<ProjectSchedulerScreen> createState() => _ProjectSchedulerScreenState();
}

class _ProjectSchedulerScreenState extends State<ProjectSchedulerScreen> {
  late List<OiScheduleSlot> _slots;
  int _nextSlotId = 200;

  @override
  void initState() {
    super.initState();
    _slots = buildScheduleSlots();
  }

  void _onSlotTap(OiScheduleSlot slot) {
    final startHour = slot.start.hour.toString().padLeft(2, '0');
    final endHour = slot.end.hour.toString().padLeft(2, '0');

    OiToast.show(
      context,
      message: '${slot.title} ($startHour:00 - $endHour:00)',
      level: OiToastLevel.info,
    );
  }

  void _onTimeSlotTap(DateTime time) {
    final controller = TextEditingController();
    OiOverlayHandle? handle;

    handle = OiDialog.show(
      context,
      label: 'Create schedule slot dialog',
      dialog: OiDialog.form(
        label: 'Create schedule slot',
        title: 'New Schedule Slot',
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: OiLabel.caption(
                '${time.day}/${time.month}/${time.year} '
                'at ${time.hour.toString().padLeft(2, '0')}:00',
              ),
            ),
            OiTextInput(
              controller: controller,
              label: 'Slot title',
              placeholder: 'Enter slot title...',
              autofocus: true,
            ),
          ],
        ),
        actions: [
          OiButton.ghost(label: 'Cancel', onTap: () => handle?.dismiss()),
          OiButton.primary(
            label: 'Create',
            onTap: () {
              final title = controller.text.trim();
              if (title.isNotEmpty) {
                setState(() {
                  _nextSlotId++;
                  _slots = [
                    ..._slots,
                    OiScheduleSlot(
                      key: 'user-sched-$_nextSlotId',
                      title: title,
                      start: time,
                      end: time.add(const Duration(hours: 1)),
                      color: const Color(0xFF26A69A),
                    ),
                  ];
                });
              }
              handle?.dismiss();
            },
          ),
        ],
        onClose: () => handle?.dismiss(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return OiScheduler(
      slots: _slots,
      label: 'Team Schedule',
      mode: OiSchedulerMode.day,
      startHour: 8,
      endHour: 18,
      onSlotTap: _onSlotTap,
      onTimeSlotTap: _onTimeSlotTap,
    );
  }
}
