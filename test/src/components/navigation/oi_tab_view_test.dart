// Tests do not require documentation comments.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/obers_ui.dart';

import '../../../helpers/pump_app.dart';

final _tabs = [
  OiTabViewItem(label: 'Overview', builder: (_) => const Text('Overview Content')),
  OiTabViewItem(label: 'Details', builder: (_) => const Text('Details Content')),
  OiTabViewItem(label: 'Activity', builder: (_) => const Text('Activity Content')),
];

void main() {
  testWidgets('renders tab labels', (tester) async {
    await tester.pumpObers(
      SizedBox.expand(
        child: OiTabView(tabs: _tabs),
      ),
      surfaceSize: const Size(800, 600),
    );

    expect(find.text('Overview'), findsOneWidget);
    expect(find.text('Details'), findsOneWidget);
    expect(find.text('Activity'), findsOneWidget);
  });

  testWidgets('initial content matches initialIndex', (tester) async {
    await tester.pumpObers(
      SizedBox.expand(
        child: OiTabView(tabs: _tabs, initialIndex: 1),
      ),
      surfaceSize: const Size(800, 600),
    );
    await tester.pumpAndSettle();

    expect(find.text('Details Content'), findsOneWidget);
  });

  testWidgets('tapping tab switches content', (tester) async {
    await tester.pumpObers(
      SizedBox.expand(
        child: OiTabView(tabs: _tabs),
      ),
      surfaceSize: const Size(800, 600),
    );
    await tester.pumpAndSettle();

    // Initially shows first tab content.
    expect(find.text('Overview Content'), findsOneWidget);

    // Tap the "Details" tab.
    await tester.tap(find.text('Details'));
    await tester.pumpAndSettle();

    expect(find.text('Details Content'), findsOneWidget);
  });

  testWidgets('onTabChanged callback fires', (tester) async {
    int? changedIndex;
    await tester.pumpObers(
      SizedBox.expand(
        child: OiTabView(
          tabs: _tabs,
          onTabChanged: (index) => changedIndex = index,
        ),
      ),
      surfaceSize: const Size(800, 600),
    );

    await tester.tap(find.text('Activity'));
    await tester.pumpAndSettle();

    expect(changedIndex, 2);
  });
}
