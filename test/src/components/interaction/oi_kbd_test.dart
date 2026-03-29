// Tests do not require documentation comments.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/interaction/oi_kbd.dart';

import '../../../helpers/pump_app.dart';

void main() {
  group('OiKbd', () {
    testWidgets('renders single key', (tester) async {
      await tester.pumpObers(const OiKbd(keys: ['K']));

      expect(find.text('K'), findsOneWidget);
    });

    testWidgets('renders multiple keys', (tester) async {
      await tester.pumpObers(const OiKbd(keys: ['ctrl', 'shift', 'P']));

      // On non-Apple platforms, ctrl → 'Ctrl'
      expect(find.text('P'), findsOneWidget);
    });

    testWidgets('maps enter to return symbol', (tester) async {
      await tester.pumpObers(const OiKbd(keys: ['enter']));

      expect(find.text('\u21B5'), findsOneWidget);
    });

    testWidgets('maps esc to Esc', (tester) async {
      await tester.pumpObers(const OiKbd(keys: ['esc']));

      expect(find.text('Esc'), findsOneWidget);
    });

    testWidgets('wraps in Semantics with key label', (tester) async {
      await tester.pumpObers(const OiKbd(keys: ['ctrl', 'C']));

      final semantics = find.byWidgetPredicate(
        (w) => w is Semantics && w.properties.label == 'ctrl + C',
      );
      expect(semantics, findsOneWidget);
    });
  });
}
