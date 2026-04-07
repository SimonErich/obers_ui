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
    OiCalendarEventDialog.showCreate(
      context,
      date: date,
      onCreated: (result) {
        setState(() {
          _nextEventId++;
          _events = [
            ..._events,
            OiCalendarEvent(
              key: 'user-cal-$_nextEventId',
              title: result.title,
              start: result.start,
              end: result.end,
              color: const Color(0xFF26A69A),
            ),
          ];
        });
      },
    );
  }

  void _onEventTap(OiCalendarEvent event) {
    OiCalendarEventDialog.show(
      context,
      event: event,
      onSaved: (result) {
        setState(() {
          _events = _events.map((e) {
            if (e.key == event.key) {
              return OiCalendarEvent(
                key: e.key,
                title: result.title,
                start: result.start,
                end: result.end,
                allDay: e.allDay,
                color: e.color,
              );
            }
            return e;
          }).toList();
        });
      },
      onDeleted: () {
        setState(() {
          _events = _events.where((e) => e.key != event.key).toList();
        });
      },
    );
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
