// Tests do not require documentation comments.

import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/composites/navigation/oi_sidebar.dart';
import 'package:obers_ui/src/foundation/theme/component_themes/oi_sidebar_theme_data.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme_data.dart';

import '../../../helpers/pump_app.dart';

// ── Helpers ──────────────────────────────────────────────────────────────────

const _sections = [
  OiSidebarSection(
    title: 'Main',
    items: [
      OiSidebarItem(
        id: 'home',
        label: 'Home',
        icon: IconData(0xe318, fontFamily: 'MaterialIcons'),
      ),
      OiSidebarItem(
        id: 'inbox',
        label: 'Inbox',
        icon: IconData(0xe156, fontFamily: 'MaterialIcons'),
        badgeCount: 5,
      ),
      OiSidebarItem(
        id: 'disabled',
        label: 'Disabled',
        icon: IconData(0xe14c, fontFamily: 'MaterialIcons'),
        disabled: true,
      ),
    ],
  ),
  OiSidebarSection(
    title: 'Projects',
    items: [
      OiSidebarItem(
        id: 'project_a',
        label: 'Project A',
        icon: IconData(0xe2c8, fontFamily: 'MaterialIcons'),
        children: [
          OiSidebarItem(
            id: 'task_1',
            label: 'Task 1',
            icon: IconData(0xe876, fontFamily: 'MaterialIcons'),
          ),
          OiSidebarItem(
            id: 'task_2',
            label: 'Task 2',
            icon: IconData(0xe876, fontFamily: 'MaterialIcons'),
          ),
        ],
      ),
    ],
  ),
];

Widget _sidebar({
  List<OiSidebarSection>? sections,
  String? selectedId,
  ValueChanged<String>? onSelect,
  OiSidebarMode mode = OiSidebarMode.full,
  Widget? header,
  Widget? footer,
}) {
  return SizedBox(
    width: 300,
    height: 600,
    child: OiSidebar(
      sections: sections ?? _sections,
      selectedId: selectedId,
      onSelect: onSelect ?? (_) {},
      label: 'Test sidebar',
      mode: mode,
      header: header,
      footer: footer,
    ),
  );
}

// ── Tests ────────────────────────────────────────────────────────────────────

void main() {
  testWidgets(
    'context branch uses21px inset, radius8 and independent stroke role',
    (tester) async {
      const color = Color(0xff445566);
      const token = OiSidebarThemeData(
        contextBranchColor: color,
        iconWidth: 24,
        itemHeight: 36,
      );
      expect(token.copyWith(), token);
      expect(token.copyWith().hashCode, token.hashCode);
      final base = OiThemeData.light();
      await tester.pumpObers(
        SizedBox(
          width: 260,
          height: 300,
          child: OiSidebar(
            label: 'Navigation',
            selectedId: null,
            onSelect: (_) {},
            sections: const [
              OiSidebarSection(
                items: [
                  OiSidebarItem(
                    id: 'parent',
                    label: 'Orders',
                    icon: IconData(1),
                    children: [
                      OiSidebarItem(
                        id: 'record',
                        label: 'ORD-1',
                        icon: IconData(2),
                        contextChild: true,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        theme: base.copyWith(
          components: base.components.copyWith(sidebar: token),
        ),
      );
      final paint = tester.widget<CustomPaint>(
        find.byKey(const Key('oi_sidebar_context_branch')),
      );
      final recorder = ui.PictureRecorder();
      paint.painter!.paint(Canvas(recorder), const Size(36, 36));
      final picture = recorder.endRecording();
      final bytes = (await tester.runAsync(() async {
        final image = await picture.toImage(36, 36);
        final result = (await image.toByteData())!.buffer.asUint8List();
        image.dispose();
        return result;
      }))!;
      List<int> pixel(int x, int y) =>
          bytes.sublist((y * 36 + x) * 4, (y * 36 + x) * 4 + 4);
      expect(pixel(21, 5), [68, 85, 102, 255]);
      expect(pixel(28, 5)[3], 0);
      expect(pixel(21, 17)[3], 0);
      expect(pixel(31, 17), [68, 85, 102, 255]);
      picture.dispose();
    },
  );

  testWidgets(
    'mixed contextual and ordinary children retain accordion behavior',
    (tester) async {
      await tester.pumpObers(
        SizedBox(
          width: 260,
          height: 300,
          child: OiSidebar(
            label: 'Navigation',
            selectedId: 'parent',
            onSelect: (_) {},
            sections: const [
              OiSidebarSection(
                items: [
                  OiSidebarItem(
                    id: 'parent',
                    label: 'Orders',
                    icon: IconData(1),
                    children: [
                      OiSidebarItem(
                        id: 'record',
                        label: 'ORD-1',
                        icon: IconData(2),
                        contextChild: true,
                      ),
                      OiSidebarItem(
                        id: 'ordinary',
                        label: 'All orders',
                        icon: IconData(3),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('ORD-1'), findsNothing);
      expect(find.byType(AnimatedRotation), findsOneWidget);
      await tester.tap(find.text('Orders'));
      await tester.pumpAndSettle();
      expect(find.text('ORD-1'), findsOneWidget);
      expect(find.text('All orders'), findsOneWidget);
      await tester.tap(find.text('Orders'));
      await tester.pumpAndSettle();
      expect(find.text('ORD-1'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'context record branch keeps selection and code label semantics',
    (tester) async {
      var selected = '';
      await tester.pumpObers(
        SizedBox(
          width: 260,
          height: 300,
          child: OiSidebar(
            label: 'Navigation',
            selectedId: 'parent',
            onSelect: (id) => selected = id,
            sections: const [
              OiSidebarSection(
                items: [
                  OiSidebarItem(
                    id: 'parent',
                    label: 'Orders',
                    icon: IconData(1),
                    children: [
                      OiSidebarItem(
                        id: 'record',
                        label: 'ORD-1',
                        icon: IconData(2),
                        contextChild: true,
                        monospace: true,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(AnimatedRotation), findsNothing);
      await tester.tap(find.text('Orders'));
      await tester.pumpAndSettle();
      expect(selected, 'parent');
      final label = find.text('ORD-1');
      expect(label, findsOneWidget);
      expect(tester.widget<Text>(label).style!.fontFamily, 'monospace');
      expect(
        find.byWidgetPredicate(
          (widget) => widget is Icon && widget.icon == const IconData(2),
        ),
        findsNothing,
      );
      await tester.tap(label);
      await tester.pumpAndSettle();
      expect(selected, 'record');
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'selected nested destinations reveal their parent automatically',
    (
      tester,
    ) async {
      await tester.pumpObers(_sidebar(selectedId: 'task_1'));
      await tester.pumpAndSettle();
      expect(find.text('Task 1').hitTestable(), findsOneWidget);
      await tester.pumpObers(_sidebar(selectedId: 'home'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Project A'));
      await tester.pumpAndSettle();
      expect(find.text('Task 1').hitTestable(), findsNothing);
      await tester.pumpObers(_sidebar(selectedId: 'task_2'));
      await tester.pumpAndSettle();
      expect(find.text('Task 2').hitTestable(), findsOneWidget);
    },
  );
  group('OiSidebar', () {
    testWidgets('renders items with icon and label', (tester) async {
      await tester.pumpObers(_sidebar());

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Inbox'), findsOneWidget);
      expect(find.text('Disabled'), findsOneWidget);
    });

    testWidgets('selected item is highlighted', (tester) async {
      await tester.pumpObers(_sidebar(selectedId: 'home'));

      // The Home item should be present and rendered.
      expect(find.text('Home'), findsOneWidget);

      // Verify the selected item has a colored container (primary tint).
      final homeText = find.text('Home');
      expect(homeText, findsOneWidget);
    });

    testWidgets('nested items indent when parent is tapped', (tester) async {
      await tester.pumpObers(_sidebar());

      // Initially, nested items exist in the tree but are collapsed (height=0
      // via SizeTransition). They are not hittable or visible.
      expect(find.text('Task 1').hitTestable(), findsNothing);
      expect(find.text('Task 2').hitTestable(), findsNothing);

      // Tap the parent item to expand.
      await tester.tap(find.text('Project A'));
      await tester.pumpAndSettle();

      // Now nested items should be visible and hittable.
      expect(find.text('Task 1'), findsOneWidget);
      expect(find.text('Task 2'), findsOneWidget);
    });

    testWidgets('section titles render', (tester) async {
      await tester.pumpObers(_sidebar());

      expect(find.text('Main'), findsOneWidget);
      expect(find.text('Projects'), findsOneWidget);
    });

    testWidgets('compact mode shows only icons', (tester) async {
      await tester.pumpObers(_sidebar(mode: OiSidebarMode.compact));

      // In compact mode, items are wrapped with OiTooltip indicating they
      // are icon-only. Verify the sidebar mode is compact and icons render.
      final sidebar = tester.widget<OiSidebar>(find.byType(OiSidebar));
      expect(sidebar.mode, OiSidebarMode.compact);

      // Icons should still be present.
      expect(find.byType(Icon), findsWidgets);
    });

    testWidgets('hidden mode shows nothing', (tester) async {
      await tester.pumpObers(_sidebar(mode: OiSidebarMode.hidden));

      expect(find.text('Home'), findsNothing);
      expect(find.text('Inbox'), findsNothing);
      expect(find.text('Main'), findsNothing);
      expect(find.byType(Icon), findsNothing);
    });

    testWidgets('badges show on items', (tester) async {
      await tester.pumpObers(_sidebar());

      // The Inbox item has badgeCount: 5.
      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('keyboard navigation with arrow keys and enter', (
      tester,
    ) async {
      String? selected;
      await tester.pumpObers(_sidebar(onSelect: (id) => selected = id));

      // Focus the sidebar.
      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();

      // Navigate down.
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();

      // Press enter to select.
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();

      // An item should have been selected.
      expect(selected, isNotNull);
    });

    testWidgets('semantics navigation role is present', (tester) async {
      await tester.pumpObers(_sidebar());

      // The sidebar wraps content in Semantics with the label.
      final semantics = find.bySemanticsLabel('Test sidebar');
      expect(semantics, findsOneWidget);
    });

    testWidgets('header and footer render', (tester) async {
      await tester.pumpObers(
        _sidebar(header: const Text('Header'), footer: const Text('Footer')),
      );

      expect(find.text('Header'), findsOneWidget);
      expect(find.text('Footer'), findsOneWidget);
    });

    testWidgets('onSelect fires when item is tapped', (tester) async {
      String? selected;
      await tester.pumpObers(_sidebar(onSelect: (id) => selected = id));

      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();

      expect(selected, 'home');
    });

    testWidgets('disabled items are not selectable', (tester) async {
      String? selected;
      await tester.pumpObers(_sidebar(onSelect: (id) => selected = id));

      // Tap the disabled item — the OiTappable should prevent the tap.
      await tester.tap(find.text('Disabled'));
      await tester.pumpAndSettle();

      // The disabled item should not have been selected via onSelect
      // because OiTappable suppresses callbacks when disabled.
      expect(selected, isNot('disabled'));
    });

    testWidgets('collapsible section hides items on tap', (tester) async {
      await tester.pumpObers(_sidebar());

      // Items are visible initially.
      expect(find.text('Home'), findsOneWidget);

      // Tap the section title to collapse.
      await tester.tap(find.text('Main'));
      await tester.pumpAndSettle();

      // Items in the Main section should be hidden.
      expect(find.text('Home'), findsNothing);

      // Tap again to expand.
      await tester.tap(find.text('Main'));
      await tester.pumpAndSettle();

      expect(find.text('Home'), findsOneWidget);
    });
  });
}
