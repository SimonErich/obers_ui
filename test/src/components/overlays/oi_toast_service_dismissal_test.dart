import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/obers_ui.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('service dismissal cannot revive old toasts or their handles', (
    tester,
  ) async {
    final anchor = GlobalKey();
    await tester.pumpObers(SizedBox.expand(key: anchor));
    final context = anchor.currentContext!;
    final service = OiOverlays.of(context);
    var oldCallbacks = 0;
    var successorCallbacks = 0;
    final oldHandles = <OiOverlayHandle>[];
    OiOverlayHandle? successor;
    try {
      for (var i = 0; i < 3; i++) {
        oldHandles.add(
          OiToast.show(
            context,
            message: 'Old $i',
            duration: null,
            onDismiss: () => oldCallbacks++,
          ),
        );
      }
      await tester.pumpAndSettle();
      expect(oldHandles.every((handle) => !handle.isDismissed), isTrue);
      service
        ..dismissAll()
        ..dismissAll();
      final dismissedImmediately = oldHandles
          .map((handle) => handle.isDismissed)
          .toList();
      successor = OiToast.show(
        context,
        message: 'Successor',
        duration: null,
        onDismiss: () => successorCallbacks++,
      );
      await tester.pumpAndSettle();
      expect(dismissedImmediately, [true, true, true]);
      for (var i = 0; i < 3; i++) {
        expect(find.text('Old $i'), findsNothing);
      }
      expect(find.text('Successor'), findsOneWidget);
      for (final handle in oldHandles) {
        handle
          ..update()
          ..dismiss()
          ..dismiss();
      }
      await tester.pump();
      expect(find.text('Successor'), findsOneWidget);
      expect(successor.isDismissed, isFalse);
      expect(oldCallbacks, 0);
      expect(successorCallbacks, 0);
      service
        ..dismissAll()
        ..dismissAll();
      expect(successor.isDismissed, isTrue);
      await tester.pump();
      expect(find.byType(OiToast), findsNothing);
      expect(oldCallbacks, 0);
      expect(successorCallbacks, 0);
      expect(tester.takeException(), isNull);
    } finally {
      for (final handle in oldHandles) {
        handle.dismiss();
      }
      successor?.dismiss();
      // Public cleanup also purges a dismissed generation awaiting next show.
      OiToast.show(
        context,
        message: 'Cleanup',
        duration: null,
      ).dismiss();
      await tester.pump();
    }
  });

  testWidgets(
    'explicitly dismissed service has no stale fresh-host successor',
    (
      tester,
    ) async {
      final oldAnchor = GlobalKey();
      await tester.pumpWidget(
        OiApp(
          key: const ValueKey('old service host'),
          theme: OiThemeData.light(),
          home: SizedBox.expand(key: oldAnchor),
        ),
      );
      var context = oldAnchor.currentContext!;
      final oldService = OiOverlays.of(context);
      var callbacks = 0;
      final old = OiToast.show(
        context,
        message: 'Old host toast',
        duration: null,
        onDismiss: () => callbacks++,
      );
      OiOverlayHandle? successor;
      try {
        await tester.pumpAndSettle();
        oldService.dismissAll();
        expect(old.isDismissed, isTrue);
        await tester.pump();
        final newAnchor = GlobalKey();
        await tester.pumpWidget(
          OiApp(
            key: const ValueKey('new service host'),
            theme: OiThemeData.light(),
            home: SizedBox.expand(key: newAnchor),
          ),
        );
        context = newAnchor.currentContext!;
        expect(identical(OiOverlays.of(context), oldService), isFalse);
        successor = OiToast.show(
          context,
          message: 'Fresh host successor',
          duration: null,
          onDismiss: () => callbacks++,
        );
        await tester.pumpAndSettle();
        old
          ..update()
          ..dismiss()
          ..dismiss();
        oldService
          ..dismissAll()
          ..dismissAll();
        await tester.pump();
        expect(find.text('Old host toast'), findsNothing);
        expect(find.text('Fresh host successor'), findsOneWidget);
        expect(successor.isDismissed, isFalse);
        expect(callbacks, 0);
        expect(tester.takeException(), isNull);
      } finally {
        old.dismiss();
        successor?.dismiss();
        if (context.mounted) {
          OiToast.show(
            context,
            message: 'Cleanup',
            duration: null,
          ).dismiss();
        }
        await tester.pump();
      }
    },
  );

  for (final timerExpiry in [false, true]) {
    for (final withSuccessor in [false, true]) {
      testWidgets(
        'service dismissal cancels pending close, timer: $timerExpiry, '
        'successor: $withSuccessor',
        (
          tester,
        ) async {
          final anchor = GlobalKey();
          await tester.pumpObers(SizedBox.expand(key: anchor));
          final context = anchor.currentContext!;
          var oldCallbacks = 0;
          var successorCallbacks = 0;
          final old = OiToast.show(
            context,
            message: 'Pending old toast',
            duration: timerExpiry
                ? const Duration(milliseconds: 400)
                : const Duration(seconds: 5),
            onDismiss: () => oldCallbacks++,
          );
          OiOverlayHandle? successor;
          try {
            await tester.pump();
            await tester.pump(const Duration(milliseconds: 250));
            if (timerExpiry) {
              await tester.pump(const Duration(milliseconds: 151));
            } else {
              await tester.tap(find.byType(OiIconButton));
              await tester.pump();
              await tester.pump(const Duration(milliseconds: 50));
            }
            expect(oldCallbacks, 0);
            OiOverlays.of(context).dismissAll();
            expect(old.isDismissed, isTrue);
            expect(oldCallbacks, 0);
            if (withSuccessor) {
              successor = OiToast.show(
                context,
                message: 'Pending successor',
                duration: null,
                onDismiss: () => successorCallbacks++,
              );
            }
            old
              ..update()
              ..dismiss();
            await tester.pump(const Duration(seconds: 1));
            await tester.pumpAndSettle();
            await tester.pump(const Duration(seconds: 6));
            expect(find.text('Pending old toast'), findsNothing);
            expect(
              find.text('Pending successor'),
              withSuccessor ? findsOneWidget : findsNothing,
            );
            expect(oldCallbacks, 0);
            expect(successorCallbacks, 0);
            successor ??= OiToast.show(
              context,
              message: 'Pending successor',
              duration: null,
              onDismiss: () => successorCallbacks++,
            );
            await tester.pumpAndSettle();
            old
              ..update()
              ..dismiss();
            await tester.pump();
            expect(find.text('Pending successor'), findsOneWidget);
            expect(successor.isDismissed, isFalse);
            await tester.tap(find.byType(OiIconButton));
            await tester.pumpAndSettle();
            expect(successorCallbacks, 1);
            expect(successor.isDismissed, isTrue);
            expect(tester.takeException(), isNull);
          } finally {
            old.dismiss();
            successor?.dismiss();
            OiToast.show(
              context,
              message: 'Cleanup',
              duration: null,
            ).dismiss();
            await tester.pump();
          }
        },
      );
    }
  }

  testWidgets('caller may dismiss the service and create a live successor', (
    tester,
  ) async {
    final anchor = GlobalKey();
    await tester.pumpObers(SizedBox.expand(key: anchor));
    final context = anchor.currentContext!;
    var calls = 0;
    var successorCalls = 0;
    late OiOverlayHandle old;
    OiOverlayHandle? successor;
    old = OiToast.show(
      context,
      message: 'Reentrant old toast',
      duration: null,
      onDismiss: () {
        calls++;
        OiOverlays.of(context).dismissAll();
        old
          ..update()
          ..dismiss();
        successor = OiToast.show(
          context,
          message: 'Reentrant successor',
          duration: null,
          onDismiss: () => successorCalls++,
        );
      },
    );
    try {
      await tester.pumpAndSettle();
      await tester.tap(find.byType(OiIconButton));
      await tester.pumpAndSettle();
      expect(calls, 1);
      expect(old.isDismissed, isTrue);
      expect(find.text('Reentrant old toast'), findsNothing);
      expect(find.text('Reentrant successor'), findsOneWidget);
      expect(successor!.isDismissed, isFalse);
      old
        ..update()
        ..dismiss()
        ..dismiss();
      await tester.pump();
      expect(find.text('Reentrant successor'), findsOneWidget);
      await tester.tap(find.byType(OiIconButton));
      await tester.pumpAndSettle();
      expect(successorCalls, 1);
      expect(successor!.isDismissed, isTrue);
      expect(calls, 1);
      expect(tester.takeException(), isNull);
    } finally {
      old.dismiss();
      successor?.dismiss();
      await tester.pump();
    }
  });
}
