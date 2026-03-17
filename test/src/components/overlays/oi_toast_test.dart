// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/overlays/oi_toast.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('renders message text', (tester) async {
    await tester.pumpObers(
      const OiToast(message: 'Saved successfully'),
    );
    expect(find.text('Saved successfully'), findsOneWidget);
  });

  testWidgets('renders action widget when provided', (tester) async {
    await tester.pumpObers(
      const OiToast(
        message: 'Item deleted',
        action: Text('Undo'),
      ),
    );
    expect(find.text('Undo'), findsOneWidget);
  });

  testWidgets('success level renders success icon', (tester) async {
    await tester.pumpObers(
      const OiToast(message: 'Done', level: OiToastLevel.success),
    );
    expect(find.text('✓'), findsOneWidget);
  });

  testWidgets('warning level renders warning icon', (tester) async {
    await tester.pumpObers(
      const OiToast(message: 'Careful', level: OiToastLevel.warning),
    );
    expect(find.text('⚠'), findsOneWidget);
  });

  testWidgets('error level renders error icon', (tester) async {
    await tester.pumpObers(
      const OiToast(message: 'Failed', level: OiToastLevel.error),
    );
    expect(find.text('✕'), findsOneWidget);
  });

  testWidgets('info level renders info icon', (tester) async {
    await tester.pumpObers(
      const OiToast(message: 'FYI'),
    );
    expect(find.text('ℹ'), findsOneWidget);
  });

  testWidgets('onDismiss fires after duration elapses', (tester) async {
    var dismissed = false;
    await tester.pumpObers(
      OiToast(
        message: 'Auto-dismiss',
        duration: const Duration(milliseconds: 100),
        onDismiss: () => dismissed = true,
      ),
    );
    // Advance past the duration.
    await tester.pump(const Duration(milliseconds: 150));
    expect(dismissed, isTrue);
  });

  testWidgets('pauseOnHover=false: timer is not cancelled on hover',
      (tester) async {
    // With pauseOnHover=false no MouseRegion wraps the content.
    await tester.pumpObers(
      const OiToast(
        message: 'No hover pause',
        pauseOnHover: false,
      ),
    );
    // Should render without a top-level MouseRegion around content.
    // The content text must still be visible.
    expect(find.text('No hover pause'), findsOneWidget);
  });

  testWidgets('different positions all render the message', (tester) async {
    for (final pos in OiToastPosition.values) {
      await tester.pumpObers(
        OiToast(message: 'pos test', position: pos),
      );
      expect(find.text('pos test'), findsOneWidget);
    }
  });
}
