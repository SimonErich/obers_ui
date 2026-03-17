// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/display/oi_popover.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('open=true shows content', (tester) async {
    await tester.pumpObers(
      const OiPopover(
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
