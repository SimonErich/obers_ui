import 'package:flutter/material.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:widgetbook/widgetbook.dart';

final _sampleEvents = [
  OiTimelineEvent(
    timestamp: DateTime(2024, 1, 15, 9, 30),
    title: 'Project Created',
    description: 'Initial project setup and repository created.',
    icon: Icons.create_new_folder,
  ),
  OiTimelineEvent(
    timestamp: DateTime(2024, 2, 1, 14),
    title: 'First Release',
    description: 'Version 1.0 released to production.',
    icon: Icons.rocket_launch,
    color: const Color(0xFF16A34A),
  ),
  OiTimelineEvent(
    timestamp: DateTime(2024, 3, 10, 11, 15),
    title: 'Bug Fix',
    description: 'Critical issue resolved in the authentication module.',
    icon: Icons.bug_report,
    color: const Color(0xFFDC2626),
  ),
];

final oiTimelineComponent = WidgetbookComponent(
  name: 'OiTimeline',
  useCases: [
    WidgetbookUseCase(
      name: 'Playground',
      builder: (context) {
        return SizedBox(
          height: 500,
          child: OiTimeline(label: 'Project timeline', events: _sampleEvents),
        );
      },
    ),
  ],
);
