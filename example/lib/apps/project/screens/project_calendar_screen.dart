import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';

import 'package:obers_ui_example/data/mock_calendar.dart';

/// Calendar screen for the Project mini-app.
///
/// Supports creating events via date tap, viewing event details via event tap,
/// and moving events to new dates.
class ProjectCalendarScreen extends StatefulWidget {
  const ProjectCalendarScreen({super.key});

  @override
  State<ProjectCalendarScreen> createState() => _ProjectCalendarScreenState();
}

class _ProjectCalendarScreenState extends State<ProjectCalendarScreen> {
  late List<OiCalendarEvent> _events;
  int _nextEventId = 100;

  @override
  void initState() {
    super.initState();
    _events = buildCalendarEvents();
  }

  void _onDateTap(DateTime date) {
    final controller = TextEditingController();
    OiOverlayHandle? handle;

    handle = OiDialog.show(
      context,
      label: 'Create event dialog',
      dialog: OiDialog.form(
        label: 'Create event',
        title: 'New Event',
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: OiLabel.caption(
                'Date: ${date.day}/${date.month}/${date.year}',
              ),
            ),
            OiTextInput(
              controller: controller,
              label: 'Event title',
              placeholder: 'Enter event title...',
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
                  _nextEventId++;
                  _events = [
                    ..._events,
                    OiCalendarEvent(
                      key: 'user-cal-$_nextEventId',
                      title: title,
                      start: DateTime(date.year, date.month, date.day, 9),
                      end: DateTime(date.year, date.month, date.day, 10),
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

  void _onEventTap(OiCalendarEvent event) {
    OiToast.show(context, message: event.title);
  }

  void _onEventMove(OiCalendarEvent event, DateTime newStart, DateTime newEnd) {
    setState(() {
      _events = _events.map((e) {
        if (e.key == event.key) {
          return OiCalendarEvent(
            key: e.key,
            title: e.title,
            start: newStart,
            end: newEnd,
            allDay: e.allDay,
            color: e.color,
          );
        }
        return e;
      }).toList();
    });

    OiToast.show(
      context,
      message: 'Moved "${event.title}" to ${newStart.day}/${newStart.month}',
      level: OiToastLevel.success,
    );
  }

  @override
  Widget build(BuildContext context) {
    return OiCalendar(
      events: _events,
      label: 'Project Calendar',
      onDateTap: _onDateTap,
      onEventTap: _onEventTap,
      onEventMove: _onEventMove,
    );
  }
}
