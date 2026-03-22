import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';

import 'package:obers_ui_example/data/mock_calendar.dart';

/// Calendar screen for the Project mini-app.
class ProjectCalendarScreen extends StatelessWidget {
  const ProjectCalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final events = buildCalendarEvents();

    return OiCalendar(
      events: events,
      label: 'Project Calendar',
    );
  }
}
