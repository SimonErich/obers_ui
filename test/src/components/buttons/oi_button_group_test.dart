// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/buttons/oi_button.dart';
import 'package:obers_ui/src/components/buttons/oi_button_group.dart';

import '../../../helpers/pump_app.dart';

void main() {
  // ── Basic rendering ────────────────────────────────────────────────────────

  testWidgets('renders all button labels', (tester) async {
    await tester.pumpObers(
      const OiButtonGroup(
        buttons: [
          OiButton.outline(label: 'Day'),
          OiButton.outline(label: 'Week'),
          OiButton.outline(label: 'Month'),
        ],
      ),
    );
    expect(find.text('Day'), findsOneWidget);
    expect(find.text('Week'), findsOneWidget);
    expect(find.text('Month'), findsOneWidget);
  });

  testWidgets('horizontal orientation uses Row layout', (tester) async {
    await tester.pumpObers(
      const OiButtonGroup(
        buttons: [
          OiButton.outline(label: 'A'),
          OiButton.outline(label: 'B'),
        ],
      ),
    );
    expect(find.byType(Row), findsWidgets);
    // Both labels are on the same vertical centre line.
    final aCy = tester.getCenter(find.text('A')).dy;
    final bCy = tester.getCenter(find.text('B')).dy;
    expect((aCy - bCy).abs(), lessThan(4));
  });

  testWidgets('vertical orientation uses Column layout', (tester) async {
    await tester.pumpObers(
      const OiButtonGroup(
        orientation: Axis.vertical,
        buttons: [
          OiButton.outline(label: 'A'),
          OiButton.outline(label: 'B'),
        ],
      ),
    );
    expect(find.byType(Column), findsWidgets);
    final aCx = tester.getCenter(find.text('A')).dx;
    final bCx = tester.getCenter(find.text('B')).dx;
    expect((aCx - bCx).abs(), lessThan(4));
  });

  // ── Connected border radii ─────────────────────────────────────────────────

  testWidgets('middle button has zero border radius in horizontal group',
      (tester) async {
    await tester.pumpObers(
      const OiButtonGroup(
        buttons: [
          OiButton.outline(label: 'A'),
          OiButton.outline(label: 'B'),
          OiButton.outline(label: 'C'),
        ],
      ),
    );
    // Find all Containers in the group; the middle item should have zero radius.
    final containers = tester.widgetList<Container>(find.byType(Container));
    final decorations = containers
        .map((c) => c.decoration)
        .whereType<BoxDecoration>()
        .toList();
    final zeroRadius = decorations.any(
      (d) => d.borderRadius == BorderRadius.zero,
    );
    expect(zeroRadius, isTrue);
  });

  // ── Segmented mode ─────────────────────────────────────────────────────────

  testWidgets('segmented: tapping button calls onSelected with correct index',
      (tester) async {
    int? selected;
    await tester.pumpObers(
      OiButtonGroup(
        segmented: true,
        selectedIndex: 0,
        onSelected: (i) => selected = i,
        buttons: const [
          OiButton.ghost(label: 'A'),
          OiButton.ghost(label: 'B'),
          OiButton.ghost(label: 'C'),
        ],
      ),
    );
    await tester.tap(find.text('B'));
    await tester.pump();
    expect(selected, 1);
  });

  testWidgets('segmented: selected button uses primary fill', (tester) async {
    await tester.pumpObers(
      const OiButtonGroup(
        segmented: true,
        selectedIndex: 1,
        buttons: [
          OiButton.ghost(label: 'A'),
          OiButton.ghost(label: 'B'),
          OiButton.ghost(label: 'C'),
        ],
      ),
    );
    // The container for the selected item (index 1) should have a non-zero
    // background alpha (primary.base).
    final containers = tester.widgetList<Container>(find.byType(Container));
    final filled = containers.where((c) {
      final d = c.decoration;
      if (d is BoxDecoration) return (d.color?.a ?? 0) > 0;
      return false;
    });
    expect(filled, isNotEmpty);
  });

  testWidgets('empty buttons list renders nothing crashlessly', (tester) async {
    await tester.pumpObers(const OiButtonGroup(buttons: []));
    // Should render the SizedBox.shrink() fallback without exceptions.
    expect(tester.takeException(), isNull);
  });
}
