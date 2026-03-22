import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';

import 'package:obers_ui_example/data/mock_calendar.dart';

/// Gantt chart screen for the Project mini-app.
class ProjectGanttScreen extends StatelessWidget {
  const ProjectGanttScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tasks = buildGanttTasks();

    return OiGantt(
      tasks: tasks,
      label: 'Q1 Relaunch Gantt Chart',
      groupBy: (task) => task.group ?? 'Ungrouped',
    );
  }
}
