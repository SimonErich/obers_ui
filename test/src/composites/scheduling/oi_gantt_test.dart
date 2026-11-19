// Tests do not require documentation comments.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/composites/scheduling/oi_gantt.dart';
import 'package:obers_ui/src/foundation/persistence/drivers/oi_in_memory_driver.dart';
import 'package:obers_ui/src/foundation/persistence/oi_settings_provider.dart';
import 'package:obers_ui/src/models/settings/oi_gantt_settings.dart';

import '../../../helpers/pump_app.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

final _tasks = [
  OiGanttTask(
    key: 't1',
    label: 'Design',
    start: DateTime(2025, 6),
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

/// A task that counts how often the Gantt reads its dates.
class _CountingTask extends OiGanttTask {
  const _CountingTask({
    required super.key,
    required super.label,
    required super.start,
    required super.end,
    required this.onRead,
  });

  final VoidCallback onRead;

  @override
  DateTime get start {
    onRead();
    return super.start;
  }

  @override
  DateTime get end {
    onRead();
    return super.end;
  }
}

/// The horizontal scroll offsets of the header and the body, in tree order.
List<double> _horizontalOffsets(WidgetTester tester) => [
  for (final view in tester.widgetList<SingleChildScrollView>(
    find.byType(SingleChildScrollView),
  ))
    if (view.scrollDirection == Axis.horizontal) view.controller!.offset,
];

/// The width of the scrollable timeline.
double _timelineWidth(WidgetTester tester) {
  final view = tester
      .widgetList<SingleChildScrollView>(find.byType(SingleChildScrollView))
      .firstWhere((view) => view.scrollDirection == Axis.horizontal);
  return (view.child! as SizedBox).width!;
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
        start: DateTime(2025, 6),
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
        start: DateTime(2025, 6),
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
        start: DateTime(2025, 6),
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

  // ── Horizontal scrolling ──────────────────────────────────────────────────

  testWidgets('dragging the timeline scrolls header and body together', (
    tester,
  ) async {
    await tester.pumpObers(_gantt(zoom: OiGanttZoom.day));

    await tester.drag(
      find.byKey(const ValueKey('gantt_task_t1')),
      const Offset(-200, 0),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    final offsets = _horizontalOffsets(tester);
    expect(offsets, hasLength(2));
    expect(offsets.last, greaterThan(100));
    expect(offsets.first, offsets.last);
  });

  testWidgets('dragging the header scrolls the body with it', (tester) async {
    await tester.pumpObers(_gantt(zoom: OiGanttZoom.day));

    // The header is the 28px strip above the rows; drag inside its timeline.
    final headerTimeline =
        tester.getTopLeft(find.byType(OiGantt)) + const Offset(500, 14);
    await tester.dragFrom(headerTimeline, const Offset(-150, 0));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    final offsets = _horizontalOffsets(tester);
    expect(offsets.first, greaterThan(100));
    expect(offsets.last, offsets.first);
  });

  testWidgets('a saved scroll position is restored', (tester) async {
    final driver = OiInMemorySettingsDriver();
    await driver.save<OiGanttSettings>(
      namespace: 'oi_gantt',
      data: const OiGanttSettings(scrollPosition: 500),
      serialize: (settings) => settings.toJson(),
    );

    // 29 days at 40px is wider than the viewport, so 500 is in range.
    await tester.pumpObers(
      SizedBox(
        width: 1000,
        height: 600,
        child: OiGantt(
          tasks: _tasks,
          label: 'Gantt',
          zoom: OiGanttZoom.day,
          settingsDriver: driver,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(_horizontalOffsets(tester), [500, 500]);

    // Let the debounced save triggered by the restore finish.
    await tester.pump(const Duration(milliseconds: 600));
  });

  testWidgets(
    'a saved scroll position from an OiSettingsProvider is restored',
    (
      tester,
    ) async {
      final driver = OiInMemorySettingsDriver();
      await driver.save<OiGanttSettings>(
        namespace: 'oi_gantt',
        data: const OiGanttSettings(scrollPosition: 300),
        serialize: (settings) => settings.toJson(),
      );

      await tester.pumpObers(
        OiSettingsProvider(
          driver: driver,
          child: OiGantt(tasks: _tasks, label: 'Gantt', zoom: OiGanttZoom.day),
        ),
      );
      await tester.pumpAndSettle();

      expect(_horizontalOffsets(tester), [300, 300]);
      await tester.pump(const Duration(milliseconds: 600));
    },
  );

  testWidgets('a saved scroll position beyond the timeline is clamped', (
    tester,
  ) async {
    final driver = OiInMemorySettingsDriver();
    await driver.save<OiGanttSettings>(
      namespace: 'oi_gantt',
      data: const OiGanttSettings(scrollPosition: 50000),
      serialize: (settings) => settings.toJson(),
    );

    await tester.pumpObers(
      SizedBox(
        width: 1000,
        height: 600,
        child: OiGantt(
          tasks: _tasks,
          label: 'Gantt',
          zoom: OiGanttZoom.day,
          settingsDriver: driver,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 29 days at 40px = 1160 wide; the 800 wide test surface leaves 640 next
    // to the 160 wide label column.
    expect(_horizontalOffsets(tester), [520, 520]);
    await tester.pump(const Duration(milliseconds: 600));
  });

  // ── Bar geometry ──────────────────────────────────────────────────────────

  group('bar geometry', () {
    Rect bar(WidgetTester tester, String key) =>
        tester.getRect(find.byKey(ValueKey('gantt_task_$key')));

    testWidgets('a task within one day is as wide as its hours', (
      tester,
    ) async {
      await tester.pumpObers(
        _gantt(
          zoom: OiGanttZoom.day,
          showToday: false,
          tasks: [
            OiGanttTask(
              key: 'origin',
              label: 'Origin',
              start: DateTime(2025, 6),
              end: DateTime(2025, 6, 4),
            ),
            OiGanttTask(
              key: 'shift',
              label: 'Shift',
              start: DateTime(2025, 6, 2, 9),
              end: DateTime(2025, 6, 2, 17),
            ),
          ],
        ),
      );

      final origin = bar(tester, 'origin');
      final shift = bar(tester, 'shift');
      // Day zoom is 40px per day: 09:00 is 1 + 9/24 days in, 8h is a third.
      expect(shift.left - origin.left, closeTo((1 + 9 / 24) * 40, 0.01));
      expect(shift.width, closeTo(8 / 24 * 40, 0.01));
    });

    testWidgets('end is exclusive: 5 Jan to 6 Jan is one day wide', (
      tester,
    ) async {
      await tester.pumpObers(
        _gantt(
          zoom: OiGanttZoom.day,
          showToday: false,
          tasks: [
            OiGanttTask(
              key: 'one',
              label: 'One',
              start: DateTime(2026, 1, 5),
              end: DateTime(2026, 1, 6),
            ),
            OiGanttTask(
              key: 'ten',
              label: 'Ten',
              start: DateTime(2026, 1, 5),
              end: DateTime(2026, 1, 15),
            ),
          ],
        ),
      );

      expect(bar(tester, 'one').width, 40);
      expect(bar(tester, 'ten').width, 400);
      // The timeline ends where the last task ends, without a spare day.
      expect(_timelineWidth(tester), 400);
    });

    testWidgets('the timeline covers the whole day a task ends in', (
      tester,
    ) async {
      await tester.pumpObers(
        _gantt(
          zoom: OiGanttZoom.day,
          showToday: false,
          tasks: [
            OiGanttTask(
              key: 'a',
              label: 'A',
              start: DateTime(2026, 1, 5, 9),
              end: DateTime(2026, 1, 9, 17),
            ),
          ],
        ),
      );

      // 5 Jan 00:00 up to 10 Jan 00:00.
      expect(_timelineWidth(tester), 5 * 40);
      expect(bar(tester, 'a').width, closeTo((4 + 8 / 24) * 40, 0.01));
    });

    testWidgets('a task without a duration keeps a visible sliver', (
      tester,
    ) async {
      await tester.pumpObers(
        _gantt(
          zoom: OiGanttZoom.day,
          showToday: false,
          tasks: [
            OiGanttTask(
              key: 'milestone',
              label: 'Milestone',
              start: DateTime(2026, 1, 5),
              end: DateTime(2026, 1, 5),
            ),
          ],
        ),
      );

      expect(bar(tester, 'milestone').width, 4);
    });
  });

  testWidgets('task dates are read a fixed number of times per task', (
    tester,
  ) async {
    var reads = 0;
    const count = 60;
    await tester.pumpObers(
      _gantt(
        tasks: [
          for (var i = 0; i < count; i++)
            _CountingTask(
              key: 'task$i',
              label: 'Task $i',
              start: DateTime(2025, 6, 1 + i),
              end: DateTime(2025, 6, 3 + i),
              onRead: () => reads++,
            ),
        ],
      ),
    );

    // Finding the view range per bar read every task once per task
    // (thousands of reads for 60 tasks).
    expect(reads, lessThan(count * 12));
  });
}
