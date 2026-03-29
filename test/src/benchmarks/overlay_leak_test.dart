// Test helpers do not need public API docs.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/obers_ui.dart';

import '../../helpers/pump_app.dart';

void main() {
  group('OiOverlays lifecycle benchmark (REQ-0176)', () {
    testWidgets('show and dismiss toast 100 times without leaks', (
      tester,
    ) async {
      await tester.pumpObers(
        Builder(builder: (context) => const SizedBox.expand()),
      );

      // Grab a BuildContext that has OiOverlays in scope.
      final context = tester.element(find.byType(SizedBox).last);

      for (var i = 0; i < 100; i++) {
        final handle = OiToast.show(
          context,
          message: 'Toast #$i',
          duration: const Duration(
            seconds: 30,
          ), // long enough not to auto-dismiss
        );
        await tester.pump();

        expect(handle.isDismissed, isFalse);
        handle.dismiss();
        await tester.pump();
      }

      // No exceptions means no leaks or disposed-controller errors.
      expect(tester.takeException(), isNull);
    });

    testWidgets('rapid show/dismiss cycle does not throw', (tester) async {
      await tester.pumpObers(
        Builder(builder: (context) => const SizedBox.expand()),
        surfaceSize: const Size(1200, 6500),
      );

      final context = tester.element(find.byType(SizedBox).last);
      final handles = <OiOverlayHandle>[];

      // Show 100 toasts without dismissing.
      for (var i = 0; i < 100; i++) {
        handles.add(
          OiToast.show(
            context,
            message: 'Rapid toast #$i',
            level: OiToastLevel.values[i % OiToastLevel.values.length],
            duration: const Duration(seconds: 60),
          ),
        );
      }
      await tester.pump();

      // Dismiss all at once.
      for (final handle in handles) {
        handle.dismiss();
      }
      await tester.pump();

      expect(tester.takeException(), isNull);
    });
  });
}
