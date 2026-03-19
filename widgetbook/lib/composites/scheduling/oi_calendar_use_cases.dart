import 'package:flutter/material.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_widgetbook/helpers/knob_helpers.dart';
import 'package:widgetbook/widgetbook.dart';

final _now = DateTime.now();

final _sampleEvents = [
  OiCalendarEvent(
    key: 'e1',
    title: 'Team Standup',
    start: DateTime(_now.year, _now.month, _now.day, 9),
    end: DateTime(_now.year, _now.month, _now.day, 10),
  ),
  OiCalendarEvent(
    key: 'e2',
    title: 'Lunch Break',
    start: DateTime(_now.year, _now.month, _now.day, 12),
    end: DateTime(_now.year, _now.month, _now.day, 13),
  ),
  OiCalendarEvent(
    key: 'e3',
    title: 'Company Holiday',
    start: DateTime(_now.year, _now.month, _now.day + 2),
    end: DateTime(_now.year, _now.month, _now.day + 2),
    allDay: true,
    color: const Color(0xFF16A34A),
  ),
];

final oiCalendarComponent = WidgetbookComponent(
  name: 'OiCalendar',
  useCases: [
    WidgetbookUseCase(
      name: 'Playground',
      builder: (context) {
        final mode = context.knobs.enumKnob<OiCalendarMode>(
          label: 'Mode',
          values: OiCalendarMode.values,
        );

        return SizedBox(
          height: 500,
          child: OiCalendar(
            label: 'Event calendar',
            events: _sampleEvents,
            mode: mode,
          ),
        );
      },
    ),
  ],
);
