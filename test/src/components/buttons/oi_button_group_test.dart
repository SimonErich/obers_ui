// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/buttons/oi_button_group.dart';
import 'package:obers_ui/src/primitives/display/oi_surface.dart';

import '../../../helpers/pump_app.dart';

const _kItemDay = OiButtonGroupItem(label: 'Day');
const _kItemWeek = OiButtonGroupItem(label: 'Week');
const _kItemMonth = OiButtonGroupItem(label: 'Month');

void main() {
  // ── Basic rendering ────────────────────────────────────────────────────────

  testWidgets('renders all item labels', (tester) async {
    await tester.pumpObers(
      const OiButtonGroup(
        items: [_kItemDay, _kItemWeek, _kItemMonth],
      ),
    );
    expect(find.text('Day'), findsOneWidget);
    expect(find.text('Week'), findsOneWidget);
    expect(find.text('Month'), findsOneWidget);
  });

  testWidgets('horizontal direction uses Row layout', (tester) async {
    await tester.pumpObers(
      const OiButtonGroup(
        items: [OiButtonGroupItem(label: 'A'), OiButtonGroupItem(label: 'B')],
      ),
    );
    expect(find.byType(Row), findsWidgets);
    final aCy = tester.getCenter(find.text('A')).dy;
    final bCy = tester.getCenter(find.text('B')).dy;
    expect((aCy - bCy).abs(), lessThan(4));
  });

  testWidgets('vertical direction uses Column layout', (tester) async {
    await tester.pumpObers(
      const OiButtonGroup(
        direction: Axis.vertical,
        items: [OiButtonGroupItem(label: 'A'), OiButtonGroupItem(label: 'B')],
      ),
    );
    expect(find.byType(Column), findsWidgets);
    final aCx = tester.getCenter(find.text('A')).dx;
    final bCx = tester.getCenter(find.text('B')).dx;
    expect((aCx - bCx).abs(), lessThan(4));
  });

  // ── Connected border radii ─────────────────────────────────────────────────

  testWidgets(
      'connected: middle button has zero border radius in horizontal group',
      (tester) async {
    await tester.pumpObers(
      const OiButtonGroup(
        items: [
          OiButtonGroupItem(label: 'A'),
          OiButtonGroupItem(label: 'B'),
          OiButtonGroupItem(label: 'C'),
        ],
      ),
    );
    final containers = tester.widgetList<Container>(find.byType(Container));
    final decorations = containers
        .map((c) => c.decoration)
        .whereType<BoxDecoration>()
        .toList();
    // In connected mode the Container has borderRadius: null (the OiSurface
    // provides the outer radius and ClipRRect clips the children).
    final nullOrZeroRadius = decorations.any(
      (d) => d.borderRadius == null || d.borderRadius == BorderRadius.zero,
    );
    expect(nullOrZeroRadius, isTrue);
  });

  testWidgets('connected: group is wrapped in OiSurface', (tester) async {
    await tester.pumpObers(
      const OiButtonGroup(
        items: [OiButtonGroupItem(label: 'A'), OiButtonGroupItem(label: 'B')],
      ),
    );
    // There must be exactly one OiSurface that is a descendant of OiButtonGroup.
    expect(
      find.descendant(
        of: find.byType(OiButtonGroup),
        matching: find.byType(OiSurface),
      ),
      findsOneWidget,
    );
  });

  // ── Gapped layout ──────────────────────────────────────────────────────────

  testWidgets('gapped: items are separated and have individual border radii',
      (tester) async {
    await tester.pumpObers(
      const OiButtonGroup(
        items: [OiButtonGroupItem(label: 'A'), OiButtonGroupItem(label: 'B')],
        spacing: 8,
      ),
    );
    // In gapped mode, no shared OiSurface inside OiButtonGroup.
    expect(
      find.descendant(
        of: find.byType(OiButtonGroup),
        matching: find.byType(OiSurface),
      ),
      findsNothing,
    );
    expect(find.text('A'), findsOneWidget);
    expect(find.text('B'), findsOneWidget);
  });

  // ── Exclusive mode ─────────────────────────────────────────────────────────

  testWidgets('exclusive: tapping item calls onSelect with correct index',
      (tester) async {
    int? selected;
    await tester.pumpObers(
      OiButtonGroup(
        exclusive: true,
        selectedIndex: 0,
        onSelect: (i) => selected = i,
        items: const [
          OiButtonGroupItem(label: 'A'),
          OiButtonGroupItem(label: 'B'),
          OiButtonGroupItem(label: 'C'),
        ],
      ),
    );
    await tester.tap(find.text('B'));
    await tester.pump();
    expect(selected, 1);
  });

  testWidgets('exclusive: selected item has non-zero background alpha (soft)',
      (tester) async {
    await tester.pumpObers(
      const OiButtonGroup(
        exclusive: true,
        selectedIndex: 1,
        items: [
          OiButtonGroupItem(label: 'A'),
          OiButtonGroupItem(label: 'B'),
          OiButtonGroupItem(label: 'C'),
        ],
      ),
    );
    // The container for the selected item (soft variant) should have
    // a non-zero background alpha.
    final containers = tester.widgetList<Container>(find.byType(Container));
    final filled = containers.where((c) {
      final d = c.decoration;
      if (d is BoxDecoration) return (d.color?.a ?? 0) > 0;
      return false;
    });
    expect(filled, isNotEmpty);
  });

  testWidgets('exclusive: arrow key moves selection', (tester) async {
    int? selected;
    await tester.pumpObers(
      OiButtonGroup(
        exclusive: true,
        selectedIndex: 0,
        onSelect: (i) => selected = i,
        items: const [
          OiButtonGroupItem(label: 'A'),
          OiButtonGroupItem(label: 'B'),
          OiButtonGroupItem(label: 'C'),
        ],
      ),
    );
    // Focus the group then press arrow right.
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();
    expect(selected, 1);
  });

  // ── Icon items ─────────────────────────────────────────────────────────────

  testWidgets('item with icon renders Icon widget', (tester) async {
    const icon = IconData(0xe318, fontFamily: 'MaterialIcons');
    await tester.pumpObers(
      const OiButtonGroup(
        items: [OiButtonGroupItem(label: 'Home', icon: icon)],
      ),
    );
    expect(find.byIcon(icon), findsOneWidget);
  });

  // ── Disabled items ─────────────────────────────────────────────────────────

  testWidgets('disabled item does not call onSelect', (tester) async {
    int? selected;
    await tester.pumpObers(
      OiButtonGroup(
        exclusive: true,
        selectedIndex: 0,
        onSelect: (i) => selected = i,
        items: const [
          OiButtonGroupItem(label: 'A'),
          OiButtonGroupItem(label: 'B', enabled: false),
        ],
      ),
    );
    await tester.tap(find.text('B'));
    await tester.pump();
    expect(selected, isNull);
  });

  // ── Empty list ─────────────────────────────────────────────────────────────

  testWidgets('empty items list renders nothing crashlessly', (tester) async {
    await tester.pumpObers(const OiButtonGroup(items: []));
    expect(tester.takeException(), isNull);
  });
}
