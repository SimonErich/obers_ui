import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';

// ── Calendar events ─────────────────────────────────────────────────────────

/// Builds ~10 calendar events relative to today.
List<OiCalendarEvent> buildCalendarEvents() {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  return [
    // Daily standup — today
    OiCalendarEvent(
      key: 'cal-1',
      title: 'Daily Standup',
      start: today.add(const Duration(hours: 9)),
      end: today.add(const Duration(hours: 9, minutes: 15)),
      color: const Color(0xFF42A5F5),
    ),
    // Kaffeepause — today
    OiCalendarEvent(
      key: 'cal-2',
      title: 'Kaffeepause',
      start: today.add(const Duration(hours: 10, minutes: 30)),
      end: today.add(const Duration(hours: 10, minutes: 45)),
      color: const Color(0xFF8D6E63),
    ),
    // Sprint Review — tomorrow
    OiCalendarEvent(
      key: 'cal-3',
      title: 'Sprint Review',
      start: today.add(const Duration(days: 1, hours: 14)),
      end: today.add(const Duration(days: 1, hours: 15, minutes: 30)),
      color: const Color(0xFF7E57C2),
    ),
    // Team Schnitzel Dinner — day after tomorrow
    OiCalendarEvent(
      key: 'cal-4',
      title: 'Team Schnitzel Dinner',
      start: today.add(const Duration(days: 2, hours: 18, minutes: 30)),
      end: today.add(const Duration(days: 2, hours: 21)),
      color: const Color(0xFFEF5350),
    ),
    // Product photoshoot — in 3 days
    OiCalendarEvent(
      key: 'cal-5',
      title: 'Dirndl Photoshoot',
      start: today.add(const Duration(days: 3, hours: 10)),
      end: today.add(const Duration(days: 3, hours: 16)),
      color: const Color(0xFFEC407A),
    ),
    // Company outing — in 5 days, all day
    OiCalendarEvent(
      key: 'cal-6',
      title: 'Betriebsausflug Wachau',
      start: today.add(const Duration(days: 5)),
      end: today.add(const Duration(days: 5, hours: 23, minutes: 59)),
      allDay: true,
      color: const Color(0xFF66BB6A),
    ),
    // Supplier meeting — in 4 days
    OiCalendarEvent(
      key: 'cal-7',
      title: 'Tiroler Speck Supplier Meeting',
      start: today.add(const Duration(days: 4, hours: 11)),
      end: today.add(const Duration(days: 4, hours: 12)),
      color: const Color(0xFFFFA726),
    ),
    // Public holiday — in 7 days, all day
    OiCalendarEvent(
      key: 'cal-8',
      title: 'Nationalfeiertag',
      start: today.add(const Duration(days: 7)),
      end: today.add(const Duration(days: 7, hours: 23, minutes: 59)),
      allDay: true,
      color: const Color(0xFFEF5350),
    ),
    // Deadline — in 6 days
    OiCalendarEvent(
      key: 'cal-9',
      title: 'Easter Campaign Deadline',
      start: today.add(const Duration(days: 6, hours: 17)),
      end: today.add(const Duration(days: 6, hours: 18)),
      color: const Color(0xFFFF7043),
    ),
    // Retrospective — yesterday
    OiCalendarEvent(
      key: 'cal-10',
      title: 'Sprint Retrospective',
      start: today.subtract(const Duration(hours: 10)),
      end: today.subtract(const Duration(hours: 9)),
      color: const Color(0xFF26A69A),
    ),
  ];
}

// ── Gantt tasks ─────────────────────────────────────────────────────────────

/// Builds 7 Gantt tasks for the "Q1 Relaunch" project with dependencies.
List<OiGanttTask> buildGanttTasks() {
  // Project runs from Jan 6 to Mar 31, 2026.
  return [
    OiGanttTask(
      key: 'gantt-1',
      label: 'Research & Requirements',
      start: DateTime(2026, 1, 6),
      end: DateTime(2026, 1, 23),
      progress: 1.0,
      color: Color(0xFF42A5F5),
      group: 'Planning',
    ),
    OiGanttTask(
      key: 'gantt-2',
      label: 'UI/UX Design',
      start: DateTime(2026, 1, 20),
      end: DateTime(2026, 2, 13),
      progress: 1.0,
      color: Color(0xFFAB47BC),
      group: 'Planning',
      dependsOn: ['gantt-1'],
    ),
    OiGanttTask(
      key: 'gantt-3',
      label: 'Backend API Development',
      start: DateTime(2026, 2, 2),
      end: DateTime(2026, 3, 6),
      progress: 0.85,
      color: Color(0xFFFFA726),
      group: 'Development',
      dependsOn: ['gantt-1'],
    ),
    OiGanttTask(
      key: 'gantt-4',
      label: 'Frontend Implementation',
      start: DateTime(2026, 2, 16),
      end: DateTime(2026, 3, 13),
      progress: 0.65,
      color: Color(0xFF66BB6A),
      group: 'Development',
      dependsOn: ['gantt-2'],
    ),
    OiGanttTask(
      key: 'gantt-5',
      label: 'Content & Product Data Migration',
      start: DateTime(2026, 2, 23),
      end: DateTime(2026, 3, 13),
      progress: 0.50,
      color: Color(0xFF8D6E63),
      group: 'Development',
      dependsOn: ['gantt-3'],
    ),
    OiGanttTask(
      key: 'gantt-6',
      label: 'QA & Testing',
      start: DateTime(2026, 3, 9),
      end: DateTime(2026, 3, 25),
      progress: 0.20,
      color: Color(0xFFEF5350),
      group: 'Launch',
      dependsOn: ['gantt-4', 'gantt-5'],
    ),
    OiGanttTask(
      key: 'gantt-7',
      label: 'Go-Live & Monitoring',
      start: DateTime(2026, 3, 26),
      end: DateTime(2026, 3, 31),
      progress: 0.0,
      color: Color(0xFF26A69A),
      group: 'Launch',
      dependsOn: ['gantt-6'],
    ),
  ];
}

// ── Timeline events ─────────────────────────────────────────────────────────

/// Builds 5 project milestones from January to today (March 22, 2026).
List<OiTimelineEvent> buildTimelineEvents() {
  return [
    OiTimelineEvent(
      timestamp: DateTime(2026, 1, 6),
      title: 'Project Kickoff',
      description:
          'Q1 Relaunch project started. Team assembled, goals defined, '
          'and initial roadmap approved by Leopold.',
      icon: IconData(0xe037, fontFamily: 'MaterialIcons'), // flag
      color: Color(0xFF42A5F5),
    ),
    OiTimelineEvent(
      timestamp: DateTime(2026, 1, 23),
      title: 'Requirements Signed Off',
      description:
          'All product requirements finalized. 42 user stories created '
          'covering the full Alpenglueck shop relaunch scope.',
      icon: IconData(0xe876, fontFamily: 'MaterialIcons'), // check_circle
      color: Color(0xFF66BB6A),
    ),
    OiTimelineEvent(
      timestamp: DateTime(2026, 2, 13),
      title: 'Design Review Complete',
      description:
          'Maria presented the new Alpine-inspired design system. '
          'Stakeholder feedback incorporated, all screens approved.',
      icon: IconData(0xe40a, fontFamily: 'MaterialIcons'), // palette
      color: Color(0xFFAB47BC),
    ),
    OiTimelineEvent(
      timestamp: DateTime(2026, 3, 6),
      title: 'Backend API v1 Deployed',
      description:
          'Core API endpoints live on staging. Product catalog, orders, '
          'and user authentication fully functional.',
      icon: IconData(0xe871, fontFamily: 'MaterialIcons'), // cloud_done
      color: Color(0xFFFFA726),
    ),
    OiTimelineEvent(
      timestamp: DateTime(2026, 3, 22),
      title: 'Frontend Beta Ready',
      description:
          'First beta build deployed for internal testing. '
          'Schnitzel-themed onboarding flow getting great feedback from the team.',
      icon: IconData(0xe8e5, fontFamily: 'MaterialIcons'), // trending_up
      color: Color(0xFF26A69A),
    ),
  ];
}
