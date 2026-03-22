import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';

import 'package:obers_ui_example/data/mock_calendar.dart';

/// Timeline screen for the Project mini-app.
class ProjectTimelineScreen extends StatelessWidget {
  const ProjectTimelineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final events = buildTimelineEvents();

    return Padding(
      padding: EdgeInsets.all(spacing.lg),
      child: OiTimeline(
        events: events,
        label: 'Project Milestones',
      ),
    );
  }
}
