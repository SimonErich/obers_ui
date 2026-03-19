import 'package:flutter/material.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:widgetbook/widgetbook.dart';

import '../../helpers/knob_helpers.dart';

final _now = DateTime.now();

final _sampleSlots = [
  OiScheduleSlot(
    key: 's1',
    title: 'Morning Meeting',
    start: DateTime(_now.year, _now.month, _now.day, 9),
    end: DateTime(_now.year, _now.month, _now.day, 10),
  ),
  OiScheduleSlot(
    key: 's2',
    title: 'Code Review',
    start: DateTime(_now.year, _now.month, _now.day, 14),
    end: DateTime(_now.year, _now.month, _now.day, 15),
    color: const Color(0xFF7C3AED),
  ),
];

final oiSchedulerComponent = WidgetbookComponent(
  name: 'OiScheduler',
  useCases: [
    WidgetbookUseCase(
      name: 'Playground',
      builder: (context) {
        final mode = context.knobs.enumKnob<OiSchedulerMode>(
          label: 'Mode',
          values: OiSchedulerMode.values,
        );

        return SizedBox(
          height: 500,
          child: OiScheduler(
            label: 'Day scheduler',
            slots: _sampleSlots,
            mode: mode,
          ),
        );
      },
    ),
  ],
);
