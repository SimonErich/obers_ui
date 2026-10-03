// Tests do not require documentation comments.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/navigation/oi_tabs.dart';

import '../../../helpers/pump_app.dart';

const _tabs = [
  OiTabItem(label: 'Alpha'),
  OiTabItem(label: 'Beta'),
  OiTabItem(label: 'Gamma'),
];

void main() {
  testWidgets('text-only tabs expose visible counts without requiring icons', (
    tester,
  ) async {
    await tester.pumpObers(
      Center(
        child: OiTabs(
          tabs: const [
            OiTabItem(label: 'Items', badge: 4),
            OiTabItem(label: 'Empty', badge: 0),
          ],
          selectedIndex: 0,
          onSelected: (_) {},
        ),
      ),
    );
    expect(find.text('4'), findsOneWidget);
    expect(find.text('0'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  for (final style in [
    OiTabIndicatorStyle.underline,
    OiTabIndicatorStyle.filled,
  ]) {
    testWidgets('$style divider owns space below its tab controls', (
      tester,
    ) async {
      await tester.pumpObers(
        Center(
          child: OiTabs(
            tabs: const [OiTabItem(label: 'Tab', semanticLabel: 'First tab')],
            selectedIndex: 0,
            onSelected: (_) {},
            indicatorStyle: style,
          ),
        ),
      );
      final tab = find.byWidgetPredicate(
        (widget) =>
            widget is Semantics && widget.properties.label == 'First tab',
      );
      expect(
        tester.getSize(find.byType(OiTabs)).height - tester.getSize(tab).height,
        style == OiTabIndicatorStyle.underline ? 1 : 0,
      );
      expect(tester.takeException(), isNull);
    });
  }

  // ── Rendering ──────────────────────────────────────────────────────────────

  testWidgets('renders all tab labels', (tester) async {
    await tester.pumpObers(
      OiTabs(tabs: _tabs, selectedIndex: 0, onSelected: (_) {}),
    );
    expect(find.text('Alpha'), findsOneWidget);
    expect(find.text('Beta'), findsOneWidget);
    expect(find.text('Gamma'), findsOneWidget);
  });

  testWidgets('renders tab with icon and badge', (tester) async {
    const icon = IconData(0xe318, fontFamily: 'MaterialIcons');
    await tester.pumpObers(
      OiTabs(
        tabs: const [OiTabItem(label: 'Home', icon: icon, badge: 3)],
        selectedIndex: 0,
        onSelected: (_) {},
      ),
    );
    expect(find.text('Home'), findsOneWidget);
    expect(find.byIcon(icon), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
  });

  // ── Selection ──────────────────────────────────────────────────────────────

  testWidgets('onSelected fires with correct index on tap', (tester) async {
    int? selected;
    await tester.pumpObers(
      OiTabs(tabs: _tabs, selectedIndex: 0, onSelected: (i) => selected = i),
    );
    await tester.tap(find.text('Beta'));
    await tester.pump();
    expect(selected, 1);
  });

  testWidgets('tapping third tab calls onSelected(2)', (tester) async {
    int? selected;
    await tester.pumpObers(
      OiTabs(tabs: _tabs, selectedIndex: 0, onSelected: (i) => selected = i),
    );
    await tester.tap(find.text('Gamma'));
    await tester.pump();
    expect(selected, 2);
  });

  // ── Indicator styles ───────────────────────────────────────────────────────

  testWidgets('underline indicator style renders without error', (
    tester,
  ) async {
    await tester.pumpObers(
      OiTabs(tabs: _tabs, selectedIndex: 0, onSelected: (_) {}),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('filled indicator style renders without error', (tester) async {
    await tester.pumpObers(
      OiTabs(
        tabs: _tabs,
        selectedIndex: 1,
        onSelected: (_) {},
        indicatorStyle: OiTabIndicatorStyle.filled,
      ),
    );
    expect(tester.takeException(), isNull);
    expect(find.text('Beta'), findsOneWidget);
  });

  testWidgets('pill indicator style renders without error', (tester) async {
    await tester.pumpObers(
      OiTabs(
        tabs: _tabs,
        selectedIndex: 0,
        onSelected: (_) {},
        indicatorStyle: OiTabIndicatorStyle.pill,
      ),
    );
    expect(tester.takeException(), isNull);
    expect(find.text('Alpha'), findsOneWidget);
  });

  // ── Scrollable ─────────────────────────────────────────────────────────────

  testWidgets('scrollable=true wraps row in SingleChildScrollView', (
    tester,
  ) async {
    await tester.pumpObers(
      OiTabs(
        tabs: _tabs,
        selectedIndex: 0,
        onSelected: (_) {},
        scrollable: true,
      ),
    );
    expect(find.byType(SingleChildScrollView), findsOneWidget);
  });

  testWidgets(
    'scrollable underline spans the label and follows controlled selection',
    (tester) async {
      var selected = 0;
      await tester.pumpObers(
        StatefulBuilder(
          builder: (context, setState) => OiTabs(
            tabs: _tabs,
            selectedIndex: selected,
            scrollable: true,
            onSelected: (index) => setState(() => selected = index),
          ),
        ),
      );
      Finder activeIndicator() => find.byWidgetPredicate(
        (widget) =>
            widget is AnimatedContainer &&
            widget.constraints?.maxHeight == 2 &&
            (widget.decoration as BoxDecoration?)?.color?.a == 1,
      );
      expect(activeIndicator(), findsOneWidget);
      expect(
        tester.getSize(activeIndicator()).width,
        greaterThan(tester.getSize(find.text('Alpha')).width),
      );
      expect(
        tester.getTopLeft(activeIndicator()).dx,
        lessThan(tester.getTopLeft(find.text('Alpha')).dx),
      );
      await tester.tap(find.text('Beta'));
      await tester.pumpAndSettle();
      expect(activeIndicator(), findsOneWidget);
      expect(
        tester.getCenter(activeIndicator()).dx,
        closeTo(tester.getCenter(find.text('Beta')).dx, .1),
      );
      expect(tester.takeException(), isNull);
    },
  );

  // ── Content ────────────────────────────────────────────────────────────────

  testWidgets('content widget is rendered below tab bar', (tester) async {
    await tester.pumpObers(
      OiTabs(
        tabs: _tabs,
        selectedIndex: 0,
        onSelected: (_) {},
        content: const Text('page content'),
      ),
    );
    expect(find.text('page content'), findsOneWidget);
  });

  // ── Keyboard navigation ────────────────────────────────────────────────────

  testWidgets('selected text uses different weight from unselected', (
    tester,
  ) async {
    await tester.pumpObers(
      OiTabs(tabs: _tabs, selectedIndex: 0, onSelected: (_) {}),
    );
    final selectedText = tester.widget<Text>(find.text('Alpha'));
    final unselectedText = tester.widget<Text>(find.text('Beta'));
    expect(
      selectedText.style?.fontWeight,
      isNot(equals(unselectedText.style?.fontWeight)),
    );
  });
}
