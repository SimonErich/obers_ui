import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/obers_ui.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('immediate duplicate close activation notifies only once', (
    tester,
  ) async {
    final anchor = GlobalKey();
    await tester.pumpObers(SizedBox.expand(key: anchor));
    var calls = 0;
    final handle = OiToast.show(
      anchor.currentContext!,
      message: 'Lifecycle',
      duration: null,
      onDismiss: () => calls++,
    );
    try {
      await tester.pump();
      await tester.tap(find.byType(OiIconButton));
      await tester.tap(find.byType(OiIconButton));
      await tester.pumpAndSettle();
      expect(calls, 1);
      expect(find.byType(OiToast), findsNothing);
      expect(tester.takeException(), isNull);
    } finally {
      handle.dismiss();
      await tester.pump();
    }
  });

  testWidgets('close dismissal updates the returned handle', (tester) async {
    final anchor = GlobalKey();
    await tester.pumpObers(SizedBox.expand(key: anchor));
    var calls = 0;
    final handle = OiToast.show(
      anchor.currentContext!,
      message: 'Lifecycle',
      duration: null,
      onDismiss: () => calls++,
    );
    try {
      await tester.pumpAndSettle();
      await tester.tap(find.byType(OiIconButton));
      await tester.pumpAndSettle();
      expect(calls, 1);
      expect(find.byType(OiToast), findsNothing);
      expect(handle.isDismissed, isTrue);
      handle.dismiss();
      expect(calls, 1);
    } finally {
      handle.dismiss();
      await tester.pump();
    }
  });

  testWidgets('expiry updates the handle and notifies once', (tester) async {
    final anchor = GlobalKey();
    await tester.pumpObers(SizedBox.expand(key: anchor));
    var calls = 0;
    final handle = OiToast.show(
      anchor.currentContext!,
      message: 'Expiry',
      duration: const Duration(milliseconds: 100),
      onDismiss: () => calls++,
    );
    try {
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));
      await tester.pumpAndSettle();
      expect(calls, 1);
      expect(handle.isDismissed, isTrue);
      expect(find.byType(OiToast), findsNothing);
      handle.dismiss();
      expect(calls, 1);
      expect(tester.takeException(), isNull);
    } finally {
      handle.dismiss();
      await tester.pump();
    }
  });

  testWidgets('manual dismissal remains immediate and bypasses the callback', (
    tester,
  ) async {
    final anchor = GlobalKey();
    await tester.pumpObers(SizedBox.expand(key: anchor));
    var calls = 0;
    final handle = OiToast.show(
      anchor.currentContext!,
      message: 'Manual',
      onDismiss: () => calls++,
    );
    try {
      await tester.pumpAndSettle();
      handle.dismiss();
      expect(handle.isDismissed, isTrue);
      handle.dismiss();
      await tester.pump();
      await tester.pump(const Duration(seconds: 5));
      expect(calls, 0);
      expect(find.byType(OiToast), findsNothing);
      expect(tester.takeException(), isNull);
    } finally {
      handle.dismiss();
      await tester.pump();
    }
  });

  testWidgets('dismiss callback may reenter its handle and add a new toast', (
    tester,
  ) async {
    final anchor = GlobalKey();
    await tester.pumpObers(SizedBox.expand(key: anchor));
    var calls = 0;
    var successorCalls = 0;
    late OiOverlayHandle handle;
    OiOverlayHandle? successor;
    handle = OiToast.show(
      anchor.currentContext!,
      message: 'Original',
      duration: null,
      onDismiss: () {
        calls++;
        handle
          ..dismiss()
          ..dismiss();
        successor = OiToast.show(
          anchor.currentContext!,
          message: 'Successor',
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
      expect(handle.isDismissed, isTrue);
      expect(successor?.isDismissed, isFalse);
      expect(find.text('Original'), findsNothing);
      expect(find.text('Successor'), findsOneWidget);
      successor!.dismiss();
      successor!.dismiss();
      await tester.pump();
      expect(successorCalls, 0);
      expect(find.byType(OiToast), findsNothing);
      expect(tester.takeException(), isNull);
    } finally {
      handle.dismiss();
      successor?.dismiss();
      await tester.pump();
    }
  });

  for (final timerRace in [false, true]) {
    testWidgets('in-flight close is idempotent, timer race: $timerRace', (
      tester,
    ) async {
      final anchor = GlobalKey();
      await tester.pumpObers(SizedBox.expand(key: anchor));
      var calls = 0;
      final handle = OiToast.show(
        anchor.currentContext!,
        message: 'In flight',
        duration: timerRace ? const Duration(milliseconds: 400) : null,
        onDismiss: () => calls++,
      );
      try {
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 250));
        await tester.tap(find.byType(OiIconButton));
        if (timerRace) {
          await tester.pump(const Duration(milliseconds: 150));
        } else {
          await tester.tap(find.byType(OiIconButton));
        }
        await tester.pumpAndSettle();
        expect(calls, 1);
        expect(handle.isDismissed, isTrue);
        expect(find.byType(OiToast), findsNothing);
        expect(tester.takeException(), isNull);
      } finally {
        handle.dismiss();
        await tester.pump();
      }
    });
  }

  testWidgets('null expiry keeps owner pause and resume callbacks intact', (
    tester,
  ) async {
    var pauses = 0;
    var resumes = 0;
    var dismissals = 0;
    await tester.pumpObers(
      Center(
        child: OiToast(
          label: 'Owner expiry',
          message: 'Owner expiry',
          duration: null,
          onPauseRequested: () => pauses++,
          onResumeRequested: () => resumes++,
          onDismiss: () => dismissals++,
        ),
      ),
    );
    await tester.pumpAndSettle();
    final pointer = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await pointer.addPointer(location: Offset.zero);
    await pointer.moveTo(tester.getCenter(find.byType(OiToast)));
    await tester.pump();
    expect(pauses, 1);
    await tester.pump(const Duration(seconds: 10));
    expect(dismissals, 0);
    await pointer.moveTo(Offset.zero);
    await tester.pump();
    expect(resumes, 1);
    await pointer.removePointer();
    await tester.longPress(find.text('Owner expiry'));
    await tester.pump();
    expect(pauses, 2);
    expect(resumes, 2);
    await tester.pump(const Duration(seconds: 10));
    expect(dismissals, 0);
    expect(find.byType(OiToast), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'throwing caller still cleans its entry and preserves successor',
    (
      tester,
    ) async {
      final anchor = GlobalKey();
      await tester.pumpObers(SizedBox.expand(key: anchor));
      final errors = <Object>[];
      final exception = StateError('Caller exception');
      var calls = 0;
      var successorCalls = 0;
      OiOverlayHandle? successor;
      final handle = OiToast.show(
        anchor.currentContext!,
        message: 'Throwing caller',
        duration: null,
        onDismiss: () {
          calls++;
          successor = OiToast.show(
            anchor.currentContext!,
            message: 'Successor',
            duration: null,
            onDismiss: () => successorCalls++,
          );
          throw exception;
        },
      );
      try {
        await tester.pumpAndSettle();
        await runZonedGuarded(() async {
          await tester.tap(find.byType(OiIconButton));
          await tester.pumpAndSettle();
        }, (error, stack) => errors.add(error));
        expect(calls, 1);
        expect(errors, [same(exception)]);
        expect(handle.isDismissed, isTrue);
        expect(find.text('Throwing caller'), findsNothing);
        expect(find.text('Successor'), findsOneWidget);
        expect(successor?.isDismissed, isFalse);
        handle.dismiss();
        successor!.dismiss();
        await tester.pump();
        expect(successor!.isDismissed, isTrue);
        expect(successorCalls, 0);
        expect(find.byType(OiToast), findsNothing);
        expect(tester.takeException(), isNull);
      } finally {
        handle.dismiss();
        successor?.dismiss();
        await tester.pump();
      }
    },
  );
}
