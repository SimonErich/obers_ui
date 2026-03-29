// Tests do not require documentation comments.

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/buttons/oi_button.dart';
import 'package:obers_ui/src/components/buttons/oi_button_group.dart';
import 'package:obers_ui/src/foundation/oi_app.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme_data.dart';
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
        label: 'Test group',
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
        label: 'Test group',
        items: [
          OiButtonGroupItem(label: 'A'),
          OiButtonGroupItem(label: 'B'),
        ],
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
        label: 'Test group',
        direction: Axis.vertical,
        items: [
          OiButtonGroupItem(label: 'A'),
          OiButtonGroupItem(label: 'B'),
        ],
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
          label: 'Test group',
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
    },
  );

  testWidgets('connected: group is wrapped in OiSurface', (tester) async {
    await tester.pumpObers(
      const OiButtonGroup(
        label: 'Test group',
        items: [
          OiButtonGroupItem(label: 'A'),
          OiButtonGroupItem(label: 'B'),
        ],
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

  testWidgets('connected: horizontal group has dividers between items', (
    tester,
  ) async {
    await tester.pumpObers(
      const OiButtonGroup(
        label: 'Test group',
        items: [
          OiButtonGroupItem(label: 'A'),
          OiButtonGroupItem(label: 'B'),
          OiButtonGroupItem(label: 'C'),
        ],
      ),
    );
    // Dividers are 1px-wide Containers between items; there should be
    // count-1 = 2 of them, identifiable by width == 1.
    final dividers = tester
        .widgetList<Container>(find.byType(Container))
        .where((c) => c.constraints?.maxWidth == 1.0)
        .toList();
    expect(
      dividers.length,
      greaterThanOrEqualTo(2),
      reason: 'expect 2 dividers for 3 items',
    );
  });

  testWidgets('connected: vertical group has dividers between items', (
    tester,
  ) async {
    await tester.pumpObers(
      const OiButtonGroup(
        label: 'Test group',
        direction: Axis.vertical,
        items: [
          OiButtonGroupItem(label: 'A'),
          OiButtonGroupItem(label: 'B'),
        ],
      ),
    );
    // Dividers are 1px-tall Containers between items.
    final dividers = tester
        .widgetList<Container>(find.byType(Container))
        .where((c) => c.constraints?.maxHeight == 1.0)
        .toList();
    expect(
      dividers.length,
      greaterThanOrEqualTo(1),
      reason: 'expect 1 divider for 2 items',
    );
  });

  // ── Gapped layout ──────────────────────────────────────────────────────────

  testWidgets('gapped: items are separated and have individual border radii', (
    tester,
  ) async {
    await tester.pumpObers(
      const OiButtonGroup(
        label: 'Test group',
        items: [
          OiButtonGroupItem(label: 'A'),
          OiButtonGroupItem(label: 'B'),
        ],
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

  // ── Exclusive mode (exclusive: true) ──────────────────────────────────────

  testWidgets('exclusive: tapping item calls onSelect with correct index', (
    tester,
  ) async {
    int? selected;
    await tester.pumpObers(
      OiButtonGroup(
        label: 'Test group',
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

  testWidgets('exclusive: selected item has non-zero background alpha (soft)', (
    tester,
  ) async {
    await tester.pumpObers(
      const OiButtonGroup(
        label: 'Test group',
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
        label: 'Test group',
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

  testWidgets('exclusive: vertical group responds to arrow down/up', (
    tester,
  ) async {
    int? selected;
    await tester.pumpObers(
      OiButtonGroup(
        label: 'Test group',
        exclusive: true,
        direction: Axis.vertical,
        selectedIndex: 0,
        onSelect: (i) => selected = i,
        items: const [
          OiButtonGroupItem(label: 'A'),
          OiButtonGroupItem(label: 'B'),
        ],
      ),
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    expect(selected, 1);
  });

  testWidgets(
    'exclusive: only one item selected — deselects previous on new tap',
    (tester) async {
      int? lastSelected;
      var selectedIndex = 0;
      await tester.pumpWidget(
        OiApp(
          theme: OiThemeData.light(),
          home: _TestControlled(
            builder: (setState) => OiButtonGroup(
              label: 'Test group',
              exclusive: true,
              selectedIndex: selectedIndex,
              onSelect: (i) {
                setState(() {
                  lastSelected = i;
                  selectedIndex = i;
                });
              },
              items: const [
                OiButtonGroupItem(label: 'A'),
                OiButtonGroupItem(label: 'B'),
              ],
            ),
          ),
        ),
      );
      await tester.tap(find.text('B'));
      await tester.pump();
      expect(lastSelected, 1);
      await tester.tap(find.text('A'));
      await tester.pump();
      expect(lastSelected, 0);
    },
  );

  // ── Non-exclusive mode (exclusive: false / default) ────────────────────────

  testWidgets('non-exclusive: item onTap fires independently', (tester) async {
    var tappedA = false;
    var tappedB = false;
    await tester.pumpObers(
      OiButtonGroup(
        label: 'Test group',
        items: [
          OiButtonGroupItem(label: 'A', onTap: () => tappedA = true),
          OiButtonGroupItem(label: 'B', onTap: () => tappedB = true),
        ],
      ),
    );
    await tester.tap(find.text('A'));
    await tester.pump();
    expect(tappedA, isTrue);
    expect(tappedB, isFalse);

    await tester.tap(find.text('B'));
    await tester.pump();
    expect(tappedB, isTrue);
  });

  testWidgets('non-exclusive: arrow keys have no effect', (tester) async {
    int? selected;
    await tester.pumpObers(
      OiButtonGroup(
        label: 'Test group',
        onSelect: (i) => selected = i,
        items: const [
          OiButtonGroupItem(label: 'A'),
          OiButtonGroupItem(label: 'B'),
        ],
      ),
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();
    expect(selected, isNull);
  });

  // ── Icon items ─────────────────────────────────────────────────────────────

  testWidgets('item with icon renders Icon widget', (tester) async {
    const icon = IconData(0xe318, fontFamily: 'MaterialIcons');
    await tester.pumpObers(
      const OiButtonGroup(
        label: 'Test group',
        items: [OiButtonGroupItem(label: 'Home', icon: icon)],
      ),
    );
    expect(find.byIcon(icon), findsOneWidget);
  });

  // ── Disabled items ─────────────────────────────────────────────────────────

  testWidgets('disabled item does not call onSelect in exclusive mode', (
    tester,
  ) async {
    int? selected;
    await tester.pumpObers(
      OiButtonGroup(
        label: 'Test group',
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

  testWidgets('disabled item does not call onTap in non-exclusive mode', (
    tester,
  ) async {
    var tapped = false;
    await tester.pumpObers(
      OiButtonGroup(
        label: 'Test group',
        items: [
          OiButtonGroupItem(
            label: 'A',
            onTap: () => tapped = true,
            enabled: false,
          ),
        ],
      ),
    );
    await tester.tap(find.text('A'));
    await tester.pump();
    expect(tapped, isFalse);
  });

  // ── Empty list ─────────────────────────────────────────────────────────────

  testWidgets('empty items list renders nothing crashlessly', (tester) async {
    await tester.pumpObers(const OiButtonGroup(label: 'Test group', items: []));
    expect(tester.takeException(), isNull);
  });

  // ── Compact wrap behaviour ─────────────────────────────────────────────────

  testWidgets(
    'wrap=true: horizontal group becomes vertical on compact breakpoint',
    (tester) async {
      await tester.pumpObers(
        const MediaQuery(
          data: MediaQueryData(size: Size(375, 812)),
          child: OiButtonGroup(
            label: 'Test group',
            items: [
              OiButtonGroupItem(label: 'A'),
              OiButtonGroupItem(label: 'B'),
            ],
          ),
        ),
      );
      // On compact + wrap=true the effective direction is Axis.vertical:
      // items share the same x-coordinate and have different y-coordinates.
      final aCx = tester.getCenter(find.text('A')).dx;
      final bCx = tester.getCenter(find.text('B')).dx;
      final aY = tester.getCenter(find.text('A')).dy;
      final bY = tester.getCenter(find.text('B')).dy;
      expect(
        (aCx - bCx).abs(),
        lessThan(4),
        reason: 'items should share x (vertical layout)',
      );
      expect(
        (aY - bY).abs(),
        greaterThan(4),
        reason: 'items should be stacked vertically',
      );
    },
  );

  testWidgets(
    'wrap: connected group — each button stretches to full available width on compact',
    (tester) async {
      const groupWidth = 375.0;
      await tester.pumpObers(
        const MediaQuery(
          data: MediaQueryData(size: Size(groupWidth, 812)),
          child: Center(
            child: SizedBox(
              width: groupWidth,
              child: OiButtonGroup(
                label: 'Test group',
                items: [
                  OiButtonGroupItem(label: 'A'),
                  OiButtonGroupItem(label: 'B'),
                ],
              ),
            ),
          ),
        ),
      );
      // Find all OiButton widgets inside the group.
      final buttonFinder = find.descendant(
        of: find.byType(OiButtonGroup),
        matching: find.byType(OiButton),
      );
      expect(buttonFinder, findsNWidgets(2));

      // The group is wrapped in OiSurface with a 1px border on each side,
      // so the available width for buttons is groupWidth - 2.
      final groupBox = tester.renderObject<RenderBox>(
        find.byType(OiButtonGroup),
      );
      final groupRenderedWidth = groupBox.size.width;

      for (final element in tester.elementList(buttonFinder)) {
        final box = element.renderObject! as RenderBox;
        expect(
          box.size.width,
          closeTo(groupRenderedWidth - 2, 1),
          reason: 'Each button should stretch to full width minus border',
        );
      }
    },
  );

  testWidgets(
    'wrap: gapped group — each button stretches to full available width on compact',
    (tester) async {
      const groupWidth = 375.0;
      await tester.pumpObers(
        const MediaQuery(
          data: MediaQueryData(size: Size(groupWidth, 812)),
          child: Center(
            child: SizedBox(
              width: groupWidth,
              child: OiButtonGroup(
                label: 'Test group',
                spacing: 8,
                items: [
                  OiButtonGroupItem(label: 'A'),
                  OiButtonGroupItem(label: 'B'),
                ],
              ),
            ),
          ),
        ),
      );
      final buttonFinder = find.descendant(
        of: find.byType(OiButtonGroup),
        matching: find.byType(OiButton),
      );
      expect(buttonFinder, findsNWidgets(2));

      final groupBox = tester.renderObject<RenderBox>(
        find.byType(OiButtonGroup),
      );
      final groupRenderedWidth = groupBox.size.width;

      for (final element in tester.elementList(buttonFinder)) {
        final box = element.renderObject! as RenderBox;
        expect(
          box.size.width,
          closeTo(groupRenderedWidth, 1),
          reason: 'Each gapped button should stretch to full available width',
        );
      }
    },
  );

  testWidgets('wrap=false: horizontal group stays Row on compact breakpoint', (
    tester,
  ) async {
    await tester.pumpObers(
      const MediaQuery(
        data: MediaQueryData(size: Size(375, 812)),
        child: OiButtonGroup(
          label: 'Test group',
          wrap: false,
          items: [
            OiButtonGroupItem(label: 'A'),
            OiButtonGroupItem(label: 'B'),
          ],
        ),
      ),
    );
    // wrap=false keeps horizontal layout even on compact.
    final aY = tester.getCenter(find.text('A')).dy;
    final bY = tester.getCenter(find.text('B')).dy;
    expect(
      (aY - bY).abs(),
      lessThan(4),
      reason: 'items should share y (horizontal layout)',
    );
  });
}

// ── Test helper ───────────────────────────────────────────────────────────────

/// A minimal StatefulWidget wrapper so tests can simulate controlled behaviour
/// without requiring a full pumpObers context (which doesn't expose setState).
class _TestControlled extends StatefulWidget {
  const _TestControlled({required this.builder});

  final Widget Function(void Function(void Function()) setState) builder;

  @override
  State<_TestControlled> createState() => _TestControlledState();
}

class _TestControlledState extends State<_TestControlled> {
  @override
  Widget build(BuildContext context) {
    return widget.builder(setState);
  }
}
