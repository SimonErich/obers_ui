import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';

import 'package:obers_ui_example/apps/project/screens/project_calendar_screen.dart';
import 'package:obers_ui_example/apps/project/screens/project_gantt_screen.dart';
import 'package:obers_ui_example/apps/project/screens/project_kanban_screen.dart';
import 'package:obers_ui_example/apps/project/screens/project_timeline_screen.dart';
import 'package:obers_ui_example/shell/showcase_shell.dart';
import 'package:obers_ui_example/theme/theme_state.dart';

/// Project management mini-app showcasing Kanban, Gantt, Calendar, and
/// Timeline widgets.
class ProjectApp extends StatefulWidget {
  const ProjectApp({required this.themeState, super.key});

  final ThemeState themeState;

  @override
  State<ProjectApp> createState() => _ProjectAppState();
}

class _ProjectAppState extends State<ProjectApp> {
  int _selectedTab = 0;

  static const _tabs = [
    OiTabItem(
      label: 'Kanban',
      icon: IconData(0xf04b, fontFamily: 'MaterialIcons'),
    ),
    OiTabItem(
      label: 'Gantt',
      icon: IconData(0xe6e1, fontFamily: 'MaterialIcons'),
    ),
    OiTabItem(
      label: 'Calendar',
      icon: IconData(0xe614, fontFamily: 'MaterialIcons'),
    ),
    OiTabItem(
      label: 'Timeline',
      icon: IconData(0xe922, fontFamily: 'MaterialIcons'),
    ),
  ];

  Widget _buildSelectedScreen() {
    switch (_selectedTab) {
      case 0:
        return const ProjectKanbanScreen();
      case 1:
        return const ProjectGanttScreen();
      case 2:
        return const ProjectCalendarScreen();
      case 3:
        return const ProjectTimelineScreen();
      default:
        return const ProjectKanbanScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ShowcaseShell(
      title: 'Projects',
      themeState: widget.themeState,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OiTabs(
            tabs: _tabs,
            selectedIndex: _selectedTab,
            onSelected: (index) => setState(() => _selectedTab = index),
          ),
          Expanded(child: _buildSelectedScreen()),
        ],
      ),
    );
  }
}
