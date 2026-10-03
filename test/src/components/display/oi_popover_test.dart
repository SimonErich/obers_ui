// Tests do not require documentation comments.

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/display/oi_popover.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('popover labels its content independently from its trigger', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    for (final open in [false, true]) {
      await tester.pumpObers(
        OiPopover(
          label: 'Account options',
          open: open,
          anchor: const Text('Account trigger'),
          content: const Text('Profile details'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.bySemanticsLabel('Account trigger'), findsOneWidget);
      expect(
        find.bySemanticsLabel('Account options'),
        open ? findsOneWidget : findsNothing,
      );
      if (open) {
        expect(find.bySemanticsLabel('Profile details'), findsOneWidget);
      }
    }
    semantics.dispose();
  });

  testWidgets('open=true shows content', (tester) async {
    await tester.pumpObers(
      const OiPopover(
        label: 'Test popover',
        open: true,
        anchor: Text('anchor'),
        content: Text('popover body'),
      ),
    );
    expect(find.text('popover body'), findsOneWidget);
  });

  testWidgets('open=false hides content', (tester) async {
    await tester.pumpObers(
      const OiPopover(
        label: 'Test popover',
        anchor: Text('anchor'),
        content: Text('popover body'),
      ),
    );
    expect(find.text('popover body'), findsNothing);
  });

  testWidgets('escape key calls onClose', (tester) async {
    var closed = false;
    await tester.pumpObers(
      OiPopover(
        label: 'Test popover',
        open: true,
        onClose: () => closed = true,
        anchor: const Text('anchor'),
        content: const Text('content'),
      ),
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pump();
    expect(closed, isTrue);
  });
}
