// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/composites/scheduling/oi_gantt.dart';

import '../../../helpers/pump_app.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

final _tasks = [
  OiGanttTask(
    key: 't1',
    label: 'Design',
    start: DateTime(2025, 6, 1),
    end: DateTime(2025, 6, 10),
    progress: 0.8,
  ),
  OiGanttTask(
    key: 't2',
    label: 'Development',
    start: DateTime(2025, 6, 8),
    end: DateTime(2025, 6, 25),
    progress: 0.4,
    dependsOn: const ['t1'],
  ),
  OiGanttTask(
    key: 't3',
    label: 'Testing',
    start: DateTime(2025, 6, 20),
    end: DateTime(2025, 6, 30),
    dependsOn: const ['t2'],
  ),
];

Widget _gantt({
  List<OiGanttTask>? tasks,
  String label = 'Test Gantt',
  DateTime? viewStart,
  DateTime? viewEnd,
  OiGanttZoom zoom = OiGanttZoom.week,
  ValueChanged<OiGanttTask>? onTaskTap,
  bool showDependencies = true,
  bool showToday = true,
  bool showWeekends = true,
  Object Function(OiGanttTask)? groupBy,
  Widget Function(Object key)? groupHeader,
}) {
  return SizedBox(
    width: 1000,
    height: 600,
    child: OiGantt(
      tasks: tasks ?? _tasks,
      label: label,
      viewStart: viewStart,
      viewEnd: viewEnd,
      zoom: zoom,
      onTaskTap: onTaskTap,
      showDependencies: showDependencies,
      showToday: showToday,
      showWeekends: showWeekends,
      groupBy: groupBy,
      groupHeader: groupHeader,
    ),
  );
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  // 1. Tasks render as bars.
  testWidgets('tasks render as bars with labels', (tester) async {
    await tester.pumpObers(_gantt());
    expect(find.text('Design'), findsWidgets);
    expect(find.text('Development'), findsWidgets);
    expect(find.text('Testing'), findsWidgets);
  });

  // 2. Task bars have correct keys (verifies positioning by key).
  testWidgets('task bars are positioned with correct keys', (tester) async {
    await tester.pumpObers(_gantt());
    expect(find.byKey(const ValueKey('gantt_task_t1')), findsOneWidget);
    expect(find.byKey(const ValueKey('gantt_task_t2')), findsOneWidget);
    expect(find.byKey(const ValueKey('gantt_task_t3')), findsOneWidget);
  });

  // 3. Today line renders when showToday is true.
  testWidgets('today line renders when showToday is true', (tester) async {
    // Use a view range that includes today.
    final today = DateTime.now();
    final tasks = [
      OiGanttTask(
        key: 'now',
        label: 'Current',
        start: today.subtract(const Duration(days: 5)),
        end: today.add(const Duration(days: 5)),
      ),
    ];
    await tester.pumpObers(
      _gantt(
        tasks: tasks,
        viewStart: today.subtract(const Duration(days: 10)),
        viewEnd: today.add(const Duration(days: 10)),
      ),
    );
    expect(find.byKey(const ValueKey('gantt_today_line')), findsOneWidget);
  });

  // 4. Today line hidden when showToday is false.
  testWidgets('today line is hidden when showToday is false', (tester) async {
    final today = DateTime.now();
    final tasks = [
      OiGanttTask(
        key: 'now',
        label: 'Current',
        start: today.subtract(const Duration(days: 5)),
        end: today.add(const Duration(days: 5)),
      ),
    ];
    await tester.pumpObers(
      _gantt(
        tasks: tasks,
        viewStart: today.subtract(const Duration(days: 10)),
        viewEnd: today.add(const Duration(days: 10)),
        showToday: false,
      ),
    );
    expect(find.byKey(const ValueKey('gantt_today_line')), findsNothing);
  });

  // 5. Weekend shading renders via CustomPaint when showWeekends is true.
  testWidgets('weekend shading is present when showWeekends is true', (
    tester,
  ) async {
    await tester.pumpObers(_gantt());
    // The weekend painter is rendered via CustomPaint. Verify it exists.
    expect(find.byType(CustomPaint), findsWidgets);
  });

  // 6. Zoom changes scale — day zoom has wider columns.
  testWidgets('day zoom renders without error', (tester) async {
    await tester.pumpObers(_gantt(zoom: OiGanttZoom.day));
    expect(find.text('Design'), findsWidgets);
  });

  // 7. Month zoom.
  testWidgets('month zoom renders without error', (tester) async {
    await tester.pumpObers(_gantt(zoom: OiGanttZoom.month));
    expect(find.text('Design'), findsWidgets);
  });

  // 8. Quarter zoom.
  testWidgets('quarter zoom renders without error', (tester) async {
    await tester.pumpObers(_gantt(zoom: OiGanttZoom.quarter));
    expect(find.text('Design'), findsWidgets);
  });

  // 9. onTaskTap fires when a task bar is tapped.
  testWidgets('onTaskTap fires when task bar is tapped', (tester) async {
    OiGanttTask? tapped;
    await tester.pumpObers(
      _gantt(onTaskTap: (task) => tapped = task, showDependencies: false),
    );
    await tester.tap(find.byKey(const ValueKey('gantt_task_t1')));
    await tester.pump();
    expect(tapped?.label, 'Design');
  });

  // 10. Task labels render in the label column.
  testWidgets('task labels appear in the label column', (tester) async {
    await tester.pumpObers(_gantt());
    // Labels should be present (at least once for label column).
    expect(find.text('Design'), findsWidgets);
    expect(find.text('Development'), findsWidgets);
  });

  // 11. Progress fill is visible.
  testWidgets('progress fill widget is rendered for tasks', (tester) async {
    await tester.pumpObers(_gantt());
    // Progress fill keys.
    expect(find.byKey(const ValueKey('gantt_progress_t1')), findsOneWidget);
    expect(find.byKey(const ValueKey('gantt_progress_t2')), findsOneWidget);
  });

  // 12. Dependencies drawn as arrows (via CustomPaint).
  testWidgets('dependencies are drawn when showDependencies is true', (
    tester,
  ) async {
    await tester.pumpObers(_gantt());
    // The dependency painter is rendered via CustomPaint.
    expect(find.byType(CustomPaint), findsWidgets);
  });

  // 13. No dependencies when showDependencies is false.
  testWidgets('dependencies are not drawn when showDependencies is false', (
    tester,
  ) async {
    // Count CustomPaint widgets with and without dependencies.
    await tester.pumpObers(_gantt());
    final withDeps = tester.widgetList(find.byType(CustomPaint)).length;

    await tester.pumpObers(_gantt(showDependencies: false));
    final withoutDeps = tester.widgetList(find.byType(CustomPaint)).length;

    // There should be fewer CustomPaint widgets without dependency painting.
    expect(withoutDeps, lessThan(withDeps));
  });

  // 14. Grouping renders group headers.
  testWidgets('groupBy renders group headers', (tester) async {
    final groupedTasks = [
      OiGanttTask(
        key: 'g1',
        label: 'Task 1',
        start: DateTime(2025, 6, 1),
        end: DateTime(2025, 6, 5),
        group: 'Phase 1',
      ),
      OiGanttTask(
        key: 'g2',
        label: 'Task 2',
        start: DateTime(2025, 6, 5),
        end: DateTime(2025, 6, 10),
        group: 'Phase 1',
      ),
      OiGanttTask(
        key: 'g3',
        label: 'Task 3',
        start: DateTime(2025, 6, 10),
        end: DateTime(2025, 6, 15),
        group: 'Phase 2',
      ),
    ];
    await tester.pumpObers(
      _gantt(tasks: groupedTasks, groupBy: (task) => task.group!),
    );
    // Group headers should be rendered.
    expect(find.text('Phase 1'), findsWidgets);
    expect(find.text('Phase 2'), findsWidgets);
  });

  // 15. Custom group header builder.
  testWidgets('custom groupHeader builder is used', (tester) async {
    final groupedTasks = [
      OiGanttTask(
        key: 'g1',
        label: 'Task 1',
        start: DateTime(2025, 6, 1),
        end: DateTime(2025, 6, 5),
        group: 'Alpha',
      ),
    ];
    await tester.pumpObers(
      _gantt(
        tasks: groupedTasks,
        groupBy: (task) => task.group!,
        groupHeader: (key) =>
            Text('Group: $key', key: ValueKey('custom_header_$key')),
      ),
    );
    expect(find.byKey(const ValueKey('custom_header_Alpha')), findsOneWidget);
  });

  // 16. Semantics label is applied.
  testWidgets('semantics label is applied', (tester) async {
    await tester.pumpObers(_gantt(label: 'Project Plan'));
    final semantics = find.byWidgetPredicate(
      (widget) =>
          widget is Semantics && widget.properties.label == 'Project Plan',
    );
    expect(semantics, findsOneWidget);
  });

  // 17. Empty tasks list handles gracefully.
  testWidgets('empty tasks list renders without error', (tester) async {
    await tester.pumpObers(_gantt(tasks: const []));
    // Should render header at minimum.
    expect(find.text('Task'), findsOneWidget);
  });

  // 18. Task with custom color.
  testWidgets('task with custom color renders without error', (tester) async {
    final coloredTasks = [
      OiGanttTask(
        key: 'c1',
        label: 'Red Task',
        start: DateTime(2025, 6, 1),
        end: DateTime(2025, 6, 10),
        color: const Color(0xFFFF0000),
      ),
    ];
    await tester.pumpObers(_gantt(tasks: coloredTasks));
    expect(find.text('Red Task'), findsWidgets);
  });

  // 19. Verify task bar appears after earlier task bar in vertical order.
  testWidgets('tasks appear in list order vertically', (tester) async {
    await tester.pumpObers(_gantt());
    // In the label column, Design should appear above Development.
    final designPos = tester.getTopLeft(find.text('Design').first);
    final devPos = tester.getTopLeft(find.text('Development').first);
    expect(designPos.dy, lessThan(devPos.dy));
  });
}
