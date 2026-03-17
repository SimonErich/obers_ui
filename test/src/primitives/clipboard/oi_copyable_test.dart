// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/primitives/clipboard/oi_copyable.dart';

import '../../../helpers/pump_app.dart';

void main() {
  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (
          MethodCall call,
        ) async {
          if (call.method == 'Clipboard.setData') return null;
          if (call.method == 'Clipboard.getData') {
            return {'text': 'mock clipboard'};
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
      const OiCopyable(value: 'hello', child: Text('copy me')),
    );
    expect(find.text('copy me'), findsOneWidget);
  });

  // ── 2. Tap copies to clipboard ────────────────────────────────────────────

  testWidgets('tap copies value to clipboard', (tester) async {
    String? written;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (
          MethodCall call,
        ) async {
          if (call.method == 'Clipboard.setData') {
            written = (call.arguments as Map)['text'] as String?;
            return null;
          }
          return null;
        });

    await tester.pumpObers(
      const OiCopyable(value: 'copied text', child: Text('tap me')),
    );

    await tester.tap(find.text('tap me'));
    await tester.pump();

    expect(written, 'copied text');
  });

  // ── 3. onCopied callback fires after tap ──────────────────────────────────

  testWidgets('onCopied callback fires after tap', (tester) async {
    var copiedCalled = false;
    await tester.pumpObers(
      OiCopyable(
        value: 'val',
        onCopied: () => copiedCalled = true,
        child: const Text('tap'),
      ),
    );

    await tester.tap(find.text('tap'));
    await tester.pump();

    expect(copiedCalled, isTrue);
  });

  // ── 4. enabled=false: tap does not copy ───────────────────────────────────

  testWidgets('enabled=false: tap does not copy', (tester) async {
    String? written;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (
          MethodCall call,
        ) async {
          if (call.method == 'Clipboard.setData') {
            written = (call.arguments as Map)['text'] as String?;
            return null;
          }
          return null;
        });

    await tester.pumpObers(
      const OiCopyable(value: 'secret', enabled: false, child: Text('tap me')),
    );

    await tester.tap(find.text('tap me'));
    await tester.pump();

    expect(written, isNull);
  });

  // ── 5. enabled=false: onCopied is not called ──────────────────────────────

  testWidgets('enabled=false: onCopied is not called', (tester) async {
    var copiedCalled = false;
    await tester.pumpObers(
      OiCopyable(
        value: 'val',
        enabled: false,
        onCopied: () => copiedCalled = true,
        child: const Text('tap'),
      ),
    );

    await tester.tap(find.text('tap'));
    await tester.pump();

    expect(copiedCalled, isFalse);
  });

  // ── 6. Ctrl+C keyboard shortcut copies value ──────────────────────────────

  testWidgets('Ctrl+C copies value to clipboard', (tester) async {
    String? written;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (
          MethodCall call,
        ) async {
          if (call.method == 'Clipboard.setData') {
            written = (call.arguments as Map)['text'] as String?;
            return null;
          }
          return null;
        });

    await tester.pumpObers(
      const OiCopyable(value: 'keyboard copy', child: Text('focus me')),
    );

    // Focus the widget so key events are delivered.
    await tester.tap(find.byType(OiCopyable));
    await tester.pump();

    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.keyC);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.keyC);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await tester.pump();

    expect(written, 'keyboard copy');
  });
}
