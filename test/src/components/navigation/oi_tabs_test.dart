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
