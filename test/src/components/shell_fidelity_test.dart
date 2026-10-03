import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/obers_ui.dart';

import '../../helpers/pump_app.dart';

void main() {
  testWidgets('filter chip separates edit and clear with keyboard semantics', (
    tester,
  ) async {
    var edited = 0;
    var cleared = 0;
    await tester.pumpObers(
      Center(
        child: OiFilterChip(
          label: 'Status',
          value: 'Ready',
          selected: true,
          onTap: () => edited++,
          onRemove: () => cleared++,
        ),
      ),
    );
    final semantics = tester.ensureSemantics();
    await tester.tap(find.bySemanticsLabel('Remove Status'));
    expect(cleared, 1);
    expect(edited, 0);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    expect(edited, 1);
    expect(cleared, 1);
    semantics.dispose();
  });

  testWidgets('long filter values fit a narrow container', (tester) async {
    await tester.pumpObers(
      Center(
        child: SizedBox(
          width: 180,
          child: OiFilterChip(
            label: 'Organization',
            value: 'A long organization name',
            selected: true,
            onTap: () {},
            onRemove: () {},
          ),
        ),
      ),
      surfaceSize: const Size(390, 600),
    );
    expect(tester.takeException(), isNull);
    expect(tester.getSize(find.byType(OiFilterChip)).width, 180);
  });

  testWidgets(
    'sidebar can show plain themed counts without status badge styling',
    (tester) async {
      final base = OiThemeData.light();
      await tester.pumpObers(
        SizedBox(
          width: 264,
          child: OiSidebar(
            label: 'Navigation',
            selectedId: 'orders',
            onSelect: (_) {},
            sections: const [
              OiSidebarSection(
                items: [
                  OiSidebarItem(
                    id: 'orders',
                    label: 'Orders',
                    icon: OiIcons.shoppingBag,
                    badgeCount: 412,
                  ),
                ],
              ),
            ],
          ),
        ),
        theme: base.copyWith(
          components: base.components.copyWith(
            sidebar: const OiSidebarThemeData(
              plainBadges: true,
              itemPadding: EdgeInsets.symmetric(horizontal: 12),
              badgeTextStyle: TextStyle(fontSize: 12, color: Color(0xff445566)),
            ),
          ),
        ),
      );
      expect(find.byType(OiBadge), findsNothing);
      expect(
        tester.widget<Text>(find.text('412')).style?.color,
        const Color(0xff445566),
      );
      final row = find
          .ancestor(of: find.text('412'), matching: find.byType(Row))
          .first;
      expect(
        tester.getTopRight(find.text('412')).dx,
        tester.getTopRight(row).dx,
      );
    },
  );

  testWidgets(
    'distributed pagination keeps controls apart and activates by keyboard',
    (tester) async {
      int? page;
      final base = OiThemeData.light();
      await tester.pumpObers(
        Align(
          alignment: Alignment.topCenter,
          child: OiPagination(
            totalItems: 412,
            currentPage: 0,
            perPage: 15,
            perPageOptions: const [15, 25],
            label: 'orders',
            onPageChange: (value) => page = value,
          ),
        ),
        theme: base.copyWith(
          components: base.components.copyWith(
            pagination: const OiPaginationThemeData(
              distributed: true,
              showFirstLast: false,
              siblingCount: 2,
              buttonSize: 32,
              activeBackground: Color(0xffeeeeff),
              activeForeground: Color(0xff555599),
            ),
          ),
        ),
        surfaceSize: const Size(1100, 600),
      );
      final total = tester.getCenter(
        find.byKey(const Key('oi_pagination_total')),
      );
      final current = tester.getCenter(
        find.byKey(const Key('oi_pagination_page_0')),
      );
      final size = tester.getCenter(
        find.byKey(const Key('oi_pagination_per_page')),
      );
      expect(total.dx, lessThan(current.dx));
      expect(size.dx, greaterThan(current.dx));
      expect(find.byKey(const Key('oi_pagination_first')), findsNothing);
      expect(find.text('3'), findsOneWidget);
      final focus = find
          .descendant(
            of: find.byKey(const Key('oi_pagination_page_1')),
            matching: find.byType(Focus),
          )
          .first;
      tester.widget<Focus>(focus).focusNode?.requestFocus();
      // OiTappable owns an implicit focus node; request it through the element.
      Focus.of(tester.element(find.text('2'))).requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.space);
      expect(page, 1);
    },
  );

  testWidgets('pagination wraps labels in constrained panel columns', (
    tester,
  ) async {
    await tester.pumpObers(
      const Align(
        alignment: Alignment.topCenter,
        child: SizedBox(
          width: 640,
          child: OiPagination(
            totalItems: 30,
            currentPage: 0,
            perPage: 15,
            label: 'rows',
            labels: OiPaginationLabels(perPage: 'Rows per page'),
          ),
        ),
      ),
      surfaceSize: const Size(800, 600),
    );
    expect(tester.takeException(), isNull);
    expect(find.text('Rows per page'), findsOneWidget);
    expect(find.byKey(const Key('oi_pagination_total')), findsOneWidget);
  });

  testWidgets('inset segments retain total height and keyboard selection', (
    tester,
  ) async {
    final base = OiThemeData.light();
    var selected = 0;
    await tester.pumpObers(
      Center(
        child: OiSegmentedControl<int>(
          segments: const [
            OiSegment(value: 0, label: 'Today'),
            OiSegment(value: 1, label: 'Tomorrow'),
          ],
          selected: selected,
          onChanged: (value) => selected = value,
        ),
      ),
      theme: base.copyWith(
        components: base.components.copyWith(
          segmentedControl: const OiSegmentedControlThemeData(
            height: 32,
            inset: 2,
            innerRadius: BorderRadius.all(Radius.circular(6)),
          ),
        ),
      ),
    );
    expect(tester.getSize(find.byType(OiSegmentedControl<int>)).height, 32);
    await tester.tap(find.text('Today'));
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    expect(selected, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('many page controls wrap within a narrow viewport', (
    tester,
  ) async {
    await tester.pumpObers(
      const Center(
        child: SizedBox(
          width: 288,
          child: OiPagination(
            totalItems: 48213,
            currentPage: 20,
            perPage: 15,
            label: 'orders',
          ),
        ),
      ),
      surfaceSize: const Size(320, 800),
    );
    expect(tester.takeException(), isNull);
    expect(
      find.byKey(const Key('oi_pagination_next')).hitTestable(),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('oi_pagination_page_20')).hitTestable(),
      findsOneWidget,
    );
  });

  testWidgets('switch honors track dimensions and leading label', (
    tester,
  ) async {
    final base = OiThemeData.light();
    await tester.pumpObers(
      Center(
        child: OiSwitch(
          value: true,
          label: 'Charts',
          labelLeading: true,
          onChanged: (_) {},
        ),
      ),
      theme: base.copyWith(
        components: base.components.copyWith(
          switchTheme: const OiSwitchThemeData(width: 36, height: 20),
        ),
      ),
    );
    final track = find
        .descendant(
          of: find.byType(OiSwitch),
          matching: find.byType(AnimatedContainer),
        )
        .first;
    expect(tester.getSize(track), const Size(36, 20));
    expect(
      tester.getCenter(find.text('Charts')).dx,
      lessThan(tester.getCenter(track).dx),
    );
  });

  testWidgets('compact date input remains named and keyboard accessible', (
    tester,
  ) async {
    await tester.pumpObers(
      Center(
        child: SizedBox(
          width: 200,
          child: OiDateInput(
            value: DateTime(2026, 9, 28),
            semanticLabel: 'Delivery date start',
            leadingIcon: true,
          ),
        ),
      ),
    );
    final semantics = tester.ensureSemantics();
    expect(
      find.bySemanticsLabel(RegExp('Delivery date start')),
      findsOneWidget,
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(tester.widget<OiFloating>(find.byType(OiFloating)).visible, isTrue);
    semantics.dispose();
  });
}
