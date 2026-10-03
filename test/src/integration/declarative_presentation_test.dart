import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/obers_ui.dart';

import '../../helpers/pump_app.dart';

void main() {
  testWidgets(
    'explicit heading scale and component typography preserve font axes',
    (tester) async {
      final base = OiThemeData.light(fontFamily: 'Mona Sans');
      const style = TextStyle(
        fontFamily: 'Mona Sans',
        fontSize: 34,
        height: 40 / 34,
        fontVariations: [
          FontVariation('wght', 560),
          FontVariation('wdth', 106),
        ],
      );
      final theme = base.copyWith(
        textTheme: base.textTheme.copyWith(
          h1: style,
          headingScale: const OiResponsive<double>(1),
        ),
        components: base.components.copyWith(
          button: const OiButtonThemeData(textStyle: style, smallHeight: 32),
        ),
      );
      await tester.pumpObers(
        Column(
          children: [
            const OiLabel.h1('Heading'),
            OiButton.primary(
              label: 'Action',
              size: OiButtonSize.small,
              onTap: () {},
            ),
            const Text('Inherited'),
          ],
        ),
        theme: theme,
        surfaceSize: const Size(1440, 800),
      );
      expect(tester.widget<Text>(find.text('Heading')).style?.fontSize, 34);
      expect(
        tester.widget<Text>(find.text('Action')).style?.fontVariations,
        style.fontVariations,
      );
      expect(
        DefaultTextStyle.of(
          tester.element(find.text('Inherited')),
        ).style.fontFamily,
        'Mona Sans',
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('shared icon source reaches shell and buttons with font fallback', (
    tester,
  ) async {
    const svg =
        '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path d="M4 12h16" stroke="currentColor" stroke-width="1.5"/></svg>';
    final theme = OiThemeData.light().copyWith(
      components: OiComponentThemes(
        icon: OiIconThemeData(
          sources: {OiIcons.house: const OiIconSource.svg(svg)},
        ),
      ),
    );
    await tester.pumpObers(
      OiAppShell(
        label: 'Test',
        navigation: const [],
        primaryNavigation: const [
          OiNavItem(label: 'Home', icon: OiIcons.house, route: '/'),
        ],
        currentPrimaryRoute: '/',
        child: Column(
          children: [
            OiButton.primary(label: 'House', icon: OiIcons.house, onTap: () {}),
            const OiIcon.decorative(icon: OiIcons.plus),
          ],
        ),
      ),
      theme: theme,
      surfaceSize: const Size(1440, 800),
    );
    await tester.pumpAndSettle();
    expect(find.byType(SvgPicture), findsNWidgets(2));
    expect(find.byIcon(OiIcons.plus), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('shell renders two navigation levels with themed geometry', (
    tester,
  ) async {
    String? primary;
    String? secondary;
    final theme = OiThemeData.light().copyWith(
      components: const OiComponentThemes(
        appShell: OiAppShellThemeData(
          topBarHeight: 64,
          primaryNavigationWidth: 64,
        ),
        sidebar: OiSidebarThemeData(width: 264),
      ),
    );
    await tester.pumpObers(
      OiAppShell(
        label: 'Test',
        primaryNavigation: const [
          OiNavItem(label: 'Shop', icon: OiIcons.store, route: '/shop'),
        ],
        currentPrimaryRoute: '/shop',
        onPrimaryNavigate: (route) => primary = route,
        navigation: const [
          OiNavItem(label: 'Orders', icon: OiIcons.package, route: '/orders'),
        ],
        onNavigate: (route) => secondary = route,
        navigationHeader: const Text('Order navigation'),
        navigationFooter: const Text('Settings footer'),
        search: const Text('Global search'),
        child: const Text('Records'),
      ),
      theme: theme,
      surfaceSize: const Size(1440, 800),
    );
    expect(tester.getSize(find.byType(OiNavigationRail)).width, 64);
    expect(tester.getSize(find.byType(OiSidebar)).width, 264);
    await tester.tap(find.byIcon(OiIcons.store));
    await tester.tap(find.text('Orders'));
    expect(primary, '/shop');
    expect(secondary, '/orders');
    expect(find.text('Global search'), findsOneWidget);
    expect(find.text('Settings footer'), findsOneWidget);
  });

  testWidgets('wizard navigation remains controlled and gates future steps', (
    tester,
  ) async {
    int? requested;
    await tester.pumpObers(
      OiWizardLayout(
        steps: const [
          OiWizardStepPresentation(title: 'Customer', summary: Text('Lena')),
          OiWizardStepPresentation(title: 'Delivery'),
          OiWizardStepPresentation(title: 'Review'),
        ],
        currentStep: 1,
        completedSteps: const {0},
        onStepTap: (value) => requested = value,
        header: const Text('New order'),
        footer: const Text('Continue'),
        aside: const Text('Live summary'),
        child: const Text('Form body'),
      ),
      surfaceSize: const Size(1440, 800),
    );
    await tester.tap(find.text('Review'));
    expect(requested, isNull);
    await tester.tap(find.text('Customer'));
    expect(requested, 0);
    expect(find.text('Live summary'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
    final summaryCard = find
        .ancestor(
          of: find.text('Live summary'),
          matching: find.byType(OiSurface),
        )
        .first;
    final bodyCard = find
        .ancestor(of: find.text('Form body'), matching: find.byType(OiSurface))
        .first;
    expect(tester.getSize(summaryCard).height, tester.getSize(bodyCard).height);
    expect(tester.getTopLeft(summaryCard).dy, tester.getTopLeft(bodyCard).dy);
    final futureStep = find
        .ancestor(of: find.text('Review'), matching: find.byType(OiTappable))
        .first;
    expect(tester.widget<OiTappable>(futureStep).disabledOpacity, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('page and wizard offer supporting content on narrow screens', (
    tester,
  ) async {
    await tester.pumpObers(
      OiPageLayout(
        header: OiPageHeader(
          title: 'An order title that wraps safely',
          subtitle: 'Supporting context',
          actions: [OiButton.primary(label: 'Create order', onTap: () {})],
        ),
        aside: const Text('Supporting record'),
        child: const Text('Main record'),
      ),
      surfaceSize: const Size(375, 800),
    );
    await tester.tap(find.text('Summary'));
    await tester.pumpAndSettle();
    expect(find.text('Supporting record'), findsOneWidget);
    await tester.tap(
      find.byWidgetPredicate(
        (widget) =>
            widget is OiButton && widget.semanticLabel == 'Close Summary',
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Supporting record'), findsNothing);
    await tester.tap(find.text('Summary'));
    await tester.pumpAndSettle();
    expect(find.text('Supporting record'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.text('Supporting record'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('compact wizard summary keeps its close action pinned', (
    tester,
  ) async {
    await tester.pumpObers(
      OiWizardLayout(
        steps: const [OiWizardStepPresentation(title: 'Review')],
        currentStep: 0,
        aside: const SizedBox(height: 1200, child: Text('Supporting record')),
        asideFooter: const Text('Pinned total'),
        child: const Text('Main record'),
      ),
      surfaceSize: const Size(390, 844),
    );
    await tester.tap(find.text('Summary'));
    await tester.pumpAndSettle();
    final close = find.byWidgetPredicate(
      (widget) => widget is OiButton && widget.semanticLabel == 'Close Summary',
    );
    final top = tester.getTopLeft(close).dy;
    expect(top, lessThan(100));
    await tester.dragFrom(const Offset(180, 260), const Offset(0, -500));
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(close).dy, top);
    expect(find.text('Pinned total'), findsOneWidget);
    await tester.tap(close);
    await tester.pumpAndSettle();
    expect(find.text('Supporting record'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('record expansion follows stable keys across reordering', (
    tester,
  ) async {
    var rows = ['first', 'second'];
    var expanded = <String>{};
    late StateSetter update;
    await tester.pumpObers(
      StatefulBuilder(
        builder: (context, setState) {
          update = setState;
          return OiTable<String>(
            label: 'Orders',
            rows: rows,
            rowKey: (row) => row,
            columns: [
              OiTableColumn(
                id: 'name',
                header: 'Name',
                valueGetter: (row) => row,
              ),
            ],
            expandedRowKeys: expanded,
            onExpandedRowsChanged: (next) => setState(() => expanded = next),
            expandedRowBuilder: (context, row) => Text('Details for $row'),
          );
        },
      ),
      surfaceSize: const Size(800, 600),
    );
    await tester.tap(find.bySemanticsLabel('Expand row').first);
    await tester.pump();
    expect(expanded, {'first'});
    update(() => rows = ['second', 'first']);
    await tester.pump();
    expect(find.text('Details for first'), findsOneWidget);
    expect(find.text('Details for second'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('radio cards expose rich content and disable selection', (
    tester,
  ) async {
    String? value;
    final semantics = tester.ensureSemantics();
    await tester.pumpObers(
      Column(
        children: [
          OiRadioTile<String>.card(
            title: 'Company profile',
            value: 'company',
            groupValue: value,
            onChanged: (next) => value = next,
            details: const Text('Budget remaining'),
            badge: const Text('Default'),
          ),
          OiRadioTile<String>.card(
            title: 'Unavailable',
            value: 'disabled',
            groupValue: value,
            enabled: false,
            onChanged: (next) => value = next,
          ),
        ],
      ),
    );
    final cardSemantics = tester.getSemantics(
      find.byType(OiRadioTile<String>).first,
    );
    final label = cardSemantics.getSemanticsData().label;
    expect(label, contains('Company profile'));
    expect(label, contains('Budget remaining'));
    expect(label, contains('Default'));
    var children = 0;
    cardSemantics.visitChildren((_) {
      children++;
      return true;
    });
    expect(
      children,
      0,
      reason:
          'The whole card is one named control, with no blank nested radio.',
    );
    await tester.tap(find.text('Budget remaining'));
    expect(value, 'company');
    await tester.tap(find.text('Unavailable'));
    expect(value, 'company');
    semantics.dispose();
  });

  testWidgets(
    'compact choice checks preserve selection and accessible radio semantics',
    (tester) async {
      var selected = 'first';
      await tester.pumpObers(
        StatefulBuilder(
          builder: (context, setState) => Column(
            children: [
              for (final option in ['first', 'second'])
                OiRadioTile<String>.card(
                  title: option,
                  value: option,
                  groupValue: selected,
                  onChanged: (value) => setState(() => selected = value),
                  dense: true,
                  bordered: false,
                  indicator: OiRadioTileIndicator.check,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
            ],
          ),
        ),
      );
      expect(find.byType(OiRadio<String>), findsNothing);
      expect(find.byIcon(OiIcons.check), findsOneWidget);
      expect(
        tester.getSize(find.byType(OiRadioTile<String>).first).height,
        lessThanOrEqualTo(52),
      );
      await tester.tap(find.text('second'));
      await tester.pumpAndSettle();
      expect(selected, 'second');
      expect(find.byIcon(OiIcons.check), findsOneWidget);
      final semantics = tester.widgetList<Semantics>(
        find.descendant(
          of: find.byType(OiRadioTile<String>).last,
          matching: find.byType(Semantics),
        ),
      );
      expect(
        semantics.any(
          (widget) =>
              widget.properties.selected == true &&
              widget.properties.inMutuallyExclusiveGroup == true,
        ),
        isTrue,
      );
    },
  );

  testWidgets(
    'filter panel keeps typed draft values and does not apply implicitly',
    (tester) async {
      var values = <String, OiColumnFilter>{};
      var applied = 0;
      await tester.pumpObers(
        StatefulBuilder(
          builder: (context, setState) => OiFilterPanel(
            sections: const [
              OiFilterSection(
                title: 'Totals',
                filters: [
                  OiFilterDefinition(
                    key: 'amount',
                    label: 'Amount',
                    type: OiFilterType.number,
                  ),
                  OiFilterDefinition(
                    key: 'range',
                    label: 'Dates',
                    type: OiFilterType.dateRange,
                  ),
                ],
              ),
            ],
            activeFilters: values,
            onFilterChange: (next) => setState(() => values = next),
            onApply: () => applied++,
          ),
        ),
      );
      tester.widget<OiNumberInput>(find.byType(OiNumberInput)).onChanged!(12.5);
      await tester.pump();
      expect(values['amount']?.value, 12.5);
      expect(applied, 0);
      final start = DateTime(2026, 9, 28);
      tester
          .widget<OiDateRangePickerField>(find.byType(OiDateRangePickerField))
          .onChanged!(start, start.add(const Duration(days: 1)));
      await tester.pump();
      expect(values['range']?.value, isA<(DateTime, DateTime)>());
      await tester.tap(find.text('Apply filters'));
      expect(applied, 1);
    },
  );
}
