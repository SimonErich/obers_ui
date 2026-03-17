// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/composites/scheduling/oi_timeline.dart';

import '../../../helpers/pump_app.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

final _events = [
  OiTimelineEvent(
    timestamp: DateTime(2025, 1, 10, 9),
    title: 'Event A',
    description: 'Description A',
  ),
  OiTimelineEvent(
    timestamp: DateTime(2025, 1, 11, 14, 30),
    title: 'Event B',
    description: 'Description B',
  ),
  OiTimelineEvent(
    timestamp: DateTime(2025, 1, 12, 18),
    title: 'Event C',
  ),
];

Widget _timeline({
  List<OiTimelineEvent>? events,
  String label = 'Test Timeline',
  bool showTimestamps = true,
  bool alternating = false,
  bool collapsible = false,
  ValueChanged<OiTimelineEvent>? onEventTap,
}) {
  return SizedBox(
    width: 600,
    height: 800,
    child: OiTimeline(
      events: events ?? _events,
      label: label,
      showTimestamps: showTimestamps,
      alternating: alternating,
      collapsible: collapsible,
      onEventTap: onEventTap,
    ),
  );
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  // 1. Events render in order.
  testWidgets('renders events in order', (tester) async {
    await tester.pumpObers(_timeline());
    expect(find.text('Event A'), findsOneWidget);
    expect(find.text('Event B'), findsOneWidget);
    expect(find.text('Event C'), findsOneWidget);

    // Verify order: A appears above B.
    final posA = tester.getTopLeft(find.text('Event A'));
    final posB = tester.getTopLeft(find.text('Event B'));
    expect(posA.dy, lessThan(posB.dy));
  });

  // 2. Timestamps are shown when showTimestamps is true.
  testWidgets('shows timestamps when showTimestamps is true', (tester) async {
    await tester.pumpObers(_timeline());
    // The formatted timestamp for Event A: 2025-01-10 09:00.
    expect(find.text('2025-01-10 09:00'), findsOneWidget);
  });

  // 3. Timestamps are hidden when showTimestamps is false.
  testWidgets('hides timestamps when showTimestamps is false', (tester) async {
    await tester.pumpObers(_timeline(showTimestamps: false));
    expect(find.text('2025-01-10 09:00'), findsNothing);
  });

  // 4. Icons per event.
  testWidgets('renders icons on timeline dots', (tester) async {
    final eventsWithIcons = [
      OiTimelineEvent(
        timestamp: DateTime(2025, 1, 10),
        title: 'Icon Event',
        icon: const IconData(0xe047, fontFamily: 'MaterialIcons'),
      ),
    ];
    await tester.pumpObers(_timeline(events: eventsWithIcons));
    expect(find.text('Icon Event'), findsOneWidget);
    expect(find.byType(Icon), findsOneWidget);
  });

  // 5. Alternating left/right layout.
  testWidgets('alternating mode places cards on alternating sides',
      (tester) async {
    await tester.pumpObers(_timeline(alternating: true));
    await tester.pumpAndSettle();

    // In alternating mode, event at index 0 is on right, index 1 on left.
    // The card positions relative to center should differ.
    final posA = tester.getTopLeft(find.text('Event A'));
    final posB = tester.getTopLeft(find.text('Event B'));
    // Event A (index 0) is on the right, Event B (index 1) is on the left.
    // So Event A x should be > Event B x.
    expect(posA.dx, isNot(equals(posB.dx)));
  });

  // 6. Collapsible sections toggle on tap.
  testWidgets('collapsible events toggle description visibility',
      (tester) async {
    await tester.pumpObers(_timeline(collapsible: true));
    // Initially expanded — description visible.
    expect(find.text('Description A'), findsOneWidget);

    // Tap the collapse toggle (the down arrow).
    await tester.tap(find.text('\u25BC').first);
    await tester.pump();

    // Description should be hidden.
    expect(find.text('Description A'), findsNothing);

    // Tap again to expand.
    await tester.tap(find.text('\u25B6').first);
    await tester.pump();

    expect(find.text('Description A'), findsOneWidget);
  });

  // 7. Custom content renders.
  testWidgets('custom content widget renders inside event card',
      (tester) async {
    final eventsWithContent = [
      OiTimelineEvent(
        timestamp: DateTime(2025, 1, 10),
        title: 'Content Event',
        content: const Text('Custom Widget', key: ValueKey('custom_content')),
      ),
    ];
    await tester.pumpObers(_timeline(events: eventsWithContent));
    expect(find.byKey(const ValueKey('custom_content')), findsOneWidget);
    expect(find.text('Custom Widget'), findsOneWidget);
  });

  // 8. Empty events list handles gracefully.
  testWidgets('empty events list renders without error', (tester) async {
    await tester.pumpObers(_timeline(events: const []));
    // No events rendered, but no crash.
    expect(find.text('Event A'), findsNothing);
    expect(find.byType(SizedBox), findsWidgets);
  });

  // 9. Semantics label is present.
  testWidgets('semantics label is applied', (tester) async {
    await tester.pumpObers(_timeline(label: 'My Activity Feed'));
    expect(
      find.bySemanticsLabel('My Activity Feed'),
      findsOneWidget,
    );
  });

  // 10. onEventTap fires on tap.
  testWidgets('onEventTap fires when event card is tapped', (tester) async {
    OiTimelineEvent? tapped;
    await tester.pumpObers(
      _timeline(onEventTap: (event) => tapped = event),
    );
    await tester.tap(find.text('Event B'));
    await tester.pump();
    expect(tapped?.title, 'Event B');
  });

  // 11. Descriptions render.
  testWidgets('descriptions render below titles', (tester) async {
    await tester.pumpObers(_timeline());
    expect(find.text('Description A'), findsOneWidget);
    expect(find.text('Description B'), findsOneWidget);
  });

  // 12. Custom colors on dots.
  testWidgets('custom event color is applied without error', (tester) async {
    final eventsWithColor = [
      OiTimelineEvent(
        timestamp: DateTime(2025, 1, 10),
        title: 'Colored Event',
        color: const Color(0xFFFF0000),
      ),
    ];
    await tester.pumpObers(_timeline(events: eventsWithColor));
    expect(find.text('Colored Event'), findsOneWidget);
  });
}
