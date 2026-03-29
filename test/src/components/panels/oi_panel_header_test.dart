// Tests do not require documentation comments.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/panels/oi_panel_header.dart';

import '../../../helpers/pump_app.dart';

void main() {
  group('OiPanelHeader', () {
    testWidgets('renders label', (tester) async {
      await tester.pumpObers(
        const OiPanelHeader(label: 'Settings'),
      );

      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('renders subtitle when provided', (tester) async {
      await tester.pumpObers(
        const OiPanelHeader(
          label: 'Settings',
          subtitle: 'App preferences',
        ),
      );

      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('App preferences'), findsOneWidget);
    });

    testWidgets('taps when onTap is provided', (tester) async {
      var tapped = false;
      await tester.pumpObers(
        OiPanelHeader(
          label: 'Tap me',
          onTap: () => tapped = true,
        ),
      );

      await tester.tap(find.text('Tap me'));
      expect(tapped, isTrue);
    });

    testWidgets('renders leading and trailing widgets', (tester) async {
      await tester.pumpObers(
        const OiPanelHeader(
          label: 'Header',
          leading: Icon(IconData(0xe001), size: 16),
          trailing: Icon(IconData(0xe002), size: 16),
        ),
      );

      expect(find.byType(Icon), findsNWidgets(2));
    });

    testWidgets('wraps in Semantics with header: true', (tester) async {
      await tester.pumpObers(
        const OiPanelHeader(label: 'Test Header'),
      );

      final semantics = find.byWidgetPredicate(
        (w) => w is Semantics && w.properties.header == true,
      );
      expect(semantics, findsOneWidget);
    });
  });
}
