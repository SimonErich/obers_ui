import 'package:flutter/material.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:widgetbook/widgetbook.dart';

import '../../helpers/knob_helpers.dart';

final _now = DateTime.now();

final _sampleTasks = [
  OiGanttTask(
    key: 't1',
    label: 'Design',
    start: _now,
    end: _now.add(const Duration(days: 5)),
    progress: 1.0,
  ),
  OiGanttTask(
    key: 't2',
    label: 'Development',
    start: _now.add(const Duration(days: 5)),
    end: _now.add(const Duration(days: 15)),
    progress: 0.4,
    dependsOn: const ['t1'],
  ),
  OiGanttTask(
    key: 't3',
    label: 'Testing',
    start: _now.add(const Duration(days: 15)),
    end: _now.add(const Duration(days: 20)),
    progress: 0.0,
    dependsOn: const ['t2'],
  ),
];

final oiGanttComponent = WidgetbookComponent(
  name: 'OiGantt',
  useCases: [
    WidgetbookUseCase(
      name: 'Playground',
      builder: (context) {
        final zoom = context.knobs.enumKnob<OiGanttZoom>(
          label: 'Zoom',
          values: OiGanttZoom.values,
          initialValue: OiGanttZoom.week,
        );

        return SizedBox(
          height: 300,
          child: OiGantt(
            label: 'Project gantt',
            tasks: _sampleTasks,
            zoom: zoom,
          ),
        );
      },
    ),
  ],
);
