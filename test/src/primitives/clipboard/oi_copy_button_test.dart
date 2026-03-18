// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs
// REQ-0014: OiCopyButton required-prop enforcement tests.

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/primitives/clipboard/oi_copy_button.dart';

import '../../../helpers/pump_app.dart';

void main() {
  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (
          MethodCall call,
        ) async {
          if (call.method == 'Clipboard.setData') return null;
          if (call.method == 'Clipboard.getData') {
            return {'text': 'mock'};
          }
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  // ── REQ-0014: Required props enforce correctness ──────────────────────────

  group('OiCopyButton accessibility (REQ-0014)', () {
    testWidgets('semanticLabel is exposed in the accessibility tree', (
      tester,
    ) async {
      await tester.pumpObers(
        const OiCopyButton(value: 'text', semanticLabel: 'Copy to clipboard'),
      );
      final semanticsWidgets = tester.widgetList<Semantics>(
        find.byType(Semantics),
      );
      final matching = semanticsWidgets
          .where((s) => s.properties.label == 'Copy to clipboard')
          .toList();
      expect(matching, isNotEmpty);
    });

    testWidgets('semanticLabel is marked as button in accessibility tree', (
      tester,
    ) async {
      await tester.pumpObers(
        const OiCopyButton(value: 'text', semanticLabel: 'Copy'),
      );
      final semanticsWidgets = tester.widgetList<Semantics>(
        find.byType(Semantics),
      );
      final matching = semanticsWidgets
          .where(
            (s) =>
                s.properties.label == 'Copy' &&
                (s.properties.button ?? false),
          )
          .toList();
      expect(matching, isNotEmpty);
    });
  });

  // ── 1. Shows default copy icon initially ──────────────────────────────────

  testWidgets('shows default copy icon initially', (tester) async {
    await tester.pumpObers(
      const OiCopyButton(value: 'text', semanticLabel: 'Copy'),
    );
    // Default icon is "⎘".
    expect(find.text('⎘'), findsOneWidget);
    expect(find.text('✓'), findsNothing);
  });

  // ── 2. Shows copied widget after tap ──────────────────────────────────────

  testWidgets('shows copied widget after tap', (tester) async {
    await tester.pumpObers(
      const OiCopyButton(value: 'text', semanticLabel: 'Copy'),
    );

    await tester.tap(find.byType(OiCopyButton));
    await tester.pump();

    expect(find.text('✓'), findsOneWidget);
    expect(find.text('⎘'), findsNothing);
  });

  // ── 3. Reverts to icon after feedbackDuration ──────────────────────────────

  testWidgets('reverts to icon after feedbackDuration elapses', (tester) async {
    await tester.pumpObers(
      const OiCopyButton(
        value: 'text',
        semanticLabel: 'Copy',
        feedbackDuration: Duration(milliseconds: 200),
      ),
    );

    await tester.tap(find.byType(OiCopyButton));
    await tester.pump();
    expect(find.text('✓'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 250));
    expect(find.text('⎘'), findsOneWidget);
    expect(find.text('✓'), findsNothing);
  });

  // ── 4. Copies value to clipboard on tap ───────────────────────────────────

  testWidgets('copies value to clipboard on tap', (tester) async {
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
      const OiCopyButton(value: 'my value', semanticLabel: 'Copy'),
    );

    await tester.tap(find.byType(OiCopyButton));
    await tester.pump();

    expect(written, 'my value');
  });

  // ── 5. Custom icon and copiedWidget are shown ─────────────────────────────

  testWidgets('custom icon is shown by default', (tester) async {
    await tester.pumpObers(
      const OiCopyButton(
        value: 'x',
        semanticLabel: 'Copy',
        icon: Text('COPY'),
      ),
    );
    expect(find.text('COPY'), findsOneWidget);
  });

  testWidgets('custom copiedWidget shown after tap', (tester) async {
    await tester.pumpObers(
      const OiCopyButton(
        value: 'x',
        semanticLabel: 'Copy',
        copiedWidget: Text('DONE'),
      ),
    );

    await tester.tap(find.byType(OiCopyButton));
    await tester.pump();

    expect(find.text('DONE'), findsOneWidget);
  });
}
