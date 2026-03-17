// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/primitives/clipboard/oi_paste_zone.dart';

import '../../../helpers/pump_app.dart';

void main() {
  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (
          MethodCall call,
        ) async {
          if (call.method == 'Clipboard.setData') return null;
          if (call.method == 'Clipboard.getData') {
            return {'text': 'pasted text'};
          }
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  // ── 1. Renders child ───────────────────────────────────────────────────────

  testWidgets('renders child widget', (tester) async {
    await tester.pumpObers(
      OiPasteZone(onPaste: (_) {}, child: const Text('paste here')),
    );
    expect(find.text('paste here'), findsOneWidget);
  });

  // ── 2. Ctrl+V calls onPaste with clipboard text ───────────────────────────

  testWidgets('Ctrl+V calls onPaste with clipboard text', (tester) async {
    String? pasted;
    await tester.pumpObers(
      OiPasteZone(
        // autofocus ensures the Focus node receives key events in tests.
        autofocus: true,
        onPaste: (text) => pasted = text,
        child: const Text('target'),
      ),
    );
    await tester.pumpAndSettle();

    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.keyV);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.keyV);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);

    // One pump to process the key event, a second to flush the
    // async Clipboard.getData future and its then() callback.
    await tester.pump();
    await tester.pump();

    expect(pasted, 'pasted text');
  });

  // ── 3. enabled=false: Ctrl+V does not call onPaste ────────────────────────

  testWidgets('enabled=false: Ctrl+V does not call onPaste', (tester) async {
    var called = false;
    await tester.pumpObers(
      OiPasteZone(
        autofocus: true,
        onPaste: (_) => called = true,
        enabled: false,
        child: const Text('target'),
      ),
    );
    await tester.pumpAndSettle();

    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.keyV);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.keyV);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pump();
    await tester.pump();

    expect(called, isFalse);
  });

  // ── 4. Non-paste key combination does not trigger onPaste ─────────────────

  testWidgets('unrelated key does not trigger onPaste', (tester) async {
    var called = false;
    await tester.pumpObers(
      OiPasteZone(
        autofocus: true,
        onPaste: (_) => called = true,
        child: const Text('target'),
      ),
    );
    await tester.pumpAndSettle();

    // Press Ctrl+X (not V).
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.keyX);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.keyX);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pump();
    await tester.pump();

    expect(called, isFalse);
  });
}
