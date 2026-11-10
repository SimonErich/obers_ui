import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/obers_ui.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('all six concurrent toast requests keep their own anchors', (
    tester,
  ) async {
    final anchor = GlobalKey();
    final handles = <OiOverlayHandle>[];
    var callbacks = 0;
    await tester.pumpObers(
      SizedBox.expand(key: anchor),
      surfaceSize: const Size(1200, 800),
    );
    try {
      for (final position in OiToastPosition.values) {
        handles.add(
          OiToast.show(
            anchor.currentContext!,
            message: position.name,
            position: position,
            duration: null,
            onDismiss: () => callbacks++,
          ),
        );
      }
      await tester.pumpAndSettle();
      expect(handles, hasLength(6));
      expect(find.byType(OiToast), findsNWidgets(6));
      expect(handles.every((handle) => !handle.isDismissed), isTrue);
      expect(tester.takeException(), isNull);
      final measured = <String, Rect>{};
      for (final position in OiToastPosition.values) {
        final toast = find.byWidgetPredicate(
          (widget) => widget is OiToast && widget.message == position.name,
        );
        expect(toast, findsOneWidget);
        measured[position.name] = tester.getRect(toast);
      }
      debugPrint(
        jsonEncode({
          'mixedPositions': {
            for (final entry in measured.entries)
              entry.key: [
                entry.value.left,
                entry.value.top,
                entry.value.width,
                entry.value.height,
              ],
          },
          'viewport': [1200, 800],
          'liveHandles': handles.where((handle) => !handle.isDismissed).length,
        }),
      );
      for (final position in OiToastPosition.values) {
        final expected = switch (position) {
          OiToastPosition.topLeft => const Rect.fromLTWH(16, 16, 400, 62),
          OiToastPosition.topCenter => const Rect.fromLTWH(400, 16, 400, 62),
          OiToastPosition.topRight => const Rect.fromLTWH(784, 16, 400, 62),
          OiToastPosition.bottomLeft => const Rect.fromLTWH(16, 714, 400, 62),
          OiToastPosition.bottomCenter => const Rect.fromLTWH(
            400,
            714,
            400,
            62,
          ),
          OiToastPosition.bottomRight => const Rect.fromLTWH(784, 714, 400, 62),
        };
        expect(
          measured[position.name],
          expected,
          reason: 'Each requested position must retain its own viewport anchor',
        );
      }
      expect(callbacks, 0);
    } finally {
      for (final handle in handles) {
        handle
          ..dismiss()
          ..dismiss();
      }
      await tester.pumpAndSettle();
      expect(handles.every((handle) => handle.isDismissed), isTrue);
      expect(find.byType(OiToast), findsNothing);
      expect(callbacks, 0);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets(
    'removing the first group leaves other anchors and order intact',
    (
      tester,
    ) async {
      final anchor = GlobalKey();
      final handles = <String, OiOverlayHandle>{};
      var callbacks = 0;
      await tester.pumpObers(
        SizedBox.expand(key: anchor),
        surfaceSize: const Size(1200, 800),
      );
      try {
        for (final position in OiToastPosition.values) {
          handles[position.name] = OiToast.show(
            anchor.currentContext!,
            message: position.name,
            position: position,
            duration: null,
            onDismiss: () => callbacks++,
          );
        }
        await tester.pumpAndSettle();
        final before = {
          for (final position in OiToastPosition.values)
            position.name: tester.getRect(_toast(position.name)),
        };
        handles['topLeft']!.dismiss();
        await tester.pump();
        expect(_toast('topLeft'), findsNothing);
        for (final position in OiToastPosition.values.skip(1)) {
          expect(tester.getRect(_toast(position.name)), before[position.name]);
          expect(handles[position.name]!.isDismissed, isFalse);
        }
        handles['nextRight'] = OiToast.show(
          anchor.currentContext!,
          message: 'nextRight',
          position: OiToastPosition.topRight,
          duration: null,
        );
        handles['replacement'] = OiToast.show(
          anchor.currentContext!,
          message: 'replacement',
          position: OiToastPosition.topLeft,
          duration: null,
        );
        await tester.pumpAndSettle();
        expect(tester.getRect(_toast('replacement')), before['topLeft']);
        expect(tester.getRect(_toast('topRight')), before['topRight']);
        expect(tester.getRect(_toast('nextRight')).top, 86);
        for (final position in [
          OiToastPosition.topCenter,
          OiToastPosition.bottomLeft,
          OiToastPosition.bottomCenter,
          OiToastPosition.bottomRight,
        ]) {
          expect(tester.getRect(_toast(position.name)), before[position.name]);
        }
        expect(callbacks, 0);
        expect(tester.takeException(), isNull);
      } finally {
        for (final handle in handles.values) {
          handle.dismiss();
        }
        await tester.pump();
      }
      expect(handles.values.every((handle) => handle.isDismissed), isTrue);
      expect(find.byType(OiToast), findsNothing);
      expect(callbacks, 0);
    },
  );

  testWidgets('another group cannot restart a partially elapsed expiry', (
    tester,
  ) async {
    final anchor = GlobalKey();
    final handles = <OiOverlayHandle>[];
    var expiryCalls = 0;
    var manualCalls = 0;
    final started = tester.binding.clock.now();
    await tester.pumpObers(
      SizedBox.expand(key: anchor),
      surfaceSize: const Size(1200, 800),
    );
    try {
      handles.add(
        OiToast.show(
          anchor.currentContext!,
          message: 'Elapsed',
          position: OiToastPosition.topRight,
          duration: const Duration(seconds: 1),
          onDismiss: () => expiryCalls++,
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));
      handles.add(
        OiToast.show(
          anchor.currentContext!,
          message: 'Other group',
          position: OiToastPosition.topLeft,
          duration: null,
          onDismiss: () => manualCalls++,
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      handles.last.dismiss();
      await tester.pump();
      handles.add(
        OiToast.show(
          anchor.currentContext!,
          message: 'Survivor',
          position: OiToastPosition.bottomLeft,
          duration: null,
          onDismiss: () => manualCalls++,
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 460));
      expect(handles.first.isDismissed, isFalse);
      expect(expiryCalls, 0);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 220));
      final opacity = tester
          .widget<FadeTransition>(
            find
                .descendant(
                  of: _toast('Elapsed'),
                  matching: find.byType(FadeTransition),
                )
                .first,
          )
          .opacity
          .value;
      expect(opacity, 0);
      expect(
        tester.binding.clock.now().difference(started),
        const Duration(milliseconds: 1230),
      );
      debugPrint(
        jsonEncode({
          'timerBoundary': {
            'elapsedMs': tester.binding.clock
                .now()
                .difference(started)
                .inMilliseconds,
            'opacity': opacity,
            'calls': expiryCalls,
          },
        }),
      );
      await tester.pumpAndSettle();
      expect(
        tester.binding.clock.now().difference(started),
        const Duration(milliseconds: 1330),
      );
      debugPrint(
        jsonEncode({
          'timerSettled': {
            'elapsedMs': tester.binding.clock
                .now()
                .difference(started)
                .inMilliseconds,
            'calls': expiryCalls,
          },
        }),
      );
      expect(expiryCalls, 1);
      expect(handles.first.isDismissed, isTrue);
      expect(_toast('Elapsed'), findsNothing);
      expect(handles.last.isDismissed, isFalse);
      expect(_toast('Survivor'), findsOneWidget);
      expect(manualCalls, 0);
      expect(tester.takeException(), isNull);
    } finally {
      for (final handle in handles) {
        handle.dismiss();
      }
      await tester.pump();
    }
  });

  testWidgets('cross-group hover survives updates and pauses only its card', (
    tester,
  ) async {
    final anchor = GlobalKey();
    final handles = <OiOverlayHandle>[];
    final dismissed = <String>[];
    final pointer = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await tester.pumpObers(
      SizedBox.expand(key: anchor),
      surfaceSize: const Size(1200, 800),
    );
    try {
      for (final position in [
        OiToastPosition.topLeft,
        OiToastPosition.topRight,
      ]) {
        handles.add(
          OiToast.show(
            anchor.currentContext!,
            message: position.name,
            position: position,
            duration: const Duration(milliseconds: 700),
            onDismiss: () => dismissed.add(position.name),
          ),
        );
      }
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));
      await pointer.addPointer(location: Offset.zero);
      await pointer.moveTo(tester.getCenter(_toast('topRight')));
      await tester.pump();
      handles.add(
        OiToast.show(
          anchor.currentContext!,
          message: 'Temporary group',
          position: OiToastPosition.bottomLeft,
          duration: null,
        ),
      );
      await tester.pump();
      handles.last.dismiss();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 800));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 220));
      await tester.pumpAndSettle();
      expect(dismissed, ['topLeft']);
      expect(handles.first.isDismissed, isTrue);
      expect(handles[1].isDismissed, isFalse);
      expect(_toast('topRight'), findsOneWidget);
      await pointer.moveTo(Offset.zero);
      await tester.pump();
      // Preserve the inherited full-duration-on-resume policy, not remaining time.
      await tester.pump(const Duration(milliseconds: 699));
      expect(handles[1].isDismissed, isFalse);
      expect(dismissed, ['topLeft']);
      await tester.pump(const Duration(milliseconds: 1));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 220));
      await tester.pumpAndSettle();
      expect(dismissed, ['topLeft', 'topRight']);
      expect(handles[1].isDismissed, isTrue);
      expect(tester.takeException(), isNull);
    } finally {
      await pointer.removePointer();
      for (final handle in handles) {
        handle.dismiss();
      }
      await tester.pump();
    }
  });

  testWidgets('mixed actions and localized close target only their own entry', (
    tester,
  ) async {
    final anchor = GlobalKey();
    final handles = <OiOverlayHandle>[];
    final actions = <int>[];
    final dismissed = <int>[];
    final semantics = tester.ensureSemantics();
    await tester.pumpObers(
      SizedBox.expand(key: anchor),
      surfaceSize: const Size(1200, 800),
    );
    try {
      for (var index = 0; index < OiToastPosition.values.length; index++) {
        handles.add(
          OiToast.show(
            anchor.currentContext!,
            message: 'Item $index',
            position: OiToastPosition.values[index],
            duration: null,
            dismissLabel: 'Schließen $index',
            onDismiss: () => dismissed.add(index),
            action: OiButton.ghost(
              label: 'Undo $index',
              size: OiButtonSize.small,
              onTap: () => actions.add(index),
            ),
          ),
        );
      }
      await tester.pumpAndSettle();
      for (var index = 0; index < handles.length; index++) {
        final close = _close('Item $index');
        expect(
          tester.widget<OiIconButton>(close).semanticLabel,
          'Schließen $index',
        );
        final closeSemantics = find.descendant(
          of: close,
          matching: find.byWidgetPredicate(
            (widget) =>
                widget is Semantics &&
                widget.properties.label == 'Schließen $index',
          ),
        );
        expect(closeSemantics, findsOneWidget);
        expect(tester.getSemantics(closeSemantics).label, 'Schließen $index');
        expect(
          find.descendant(
            of: _toast('Item $index'),
            matching: find.byWidgetPredicate(
              (widget) =>
                  widget is Semantics && widget.properties.liveRegion == true,
            ),
          ),
          findsOneWidget,
        );
        await tester.tap(find.text('Undo $index'));
        await tester.pump();
        expect(actions, List.generate(index + 1, (value) => value));
        expect(dismissed, List.generate(index, (value) => value));
        expect(handles[index].isDismissed, isFalse);
        await tester.tap(close);
        await tester.pumpAndSettle();
        expect(dismissed, List.generate(index + 1, (value) => value));
        expect(handles[index].isDismissed, isTrue);
        expect(_toast('Item $index'), findsNothing);
        for (final handle in handles.skip(index + 1)) {
          expect(handle.isDismissed, isFalse);
        }
      }
      expect(tester.takeException(), isNull);
    } finally {
      for (final handle in handles) {
        handle.dismiss();
      }
      await tester.pump();
      semantics.dispose();
    }
    expect(find.byType(OiToast), findsNothing);
  });

  testWidgets(
    'separated overflowing groups scroll and retain state independently',
    (
      tester,
    ) async {
      final anchor = GlobalKey();
      final handles = <OiOverlayHandle>[];
      final actions = <String>[];
      final dismissed = <String>[];
      await tester.pumpObers(
        SizedBox.expand(key: anchor),
        surfaceSize: const Size(1200, 800),
      );
      try {
        for (var index = 0; index < 12; index++) {
          for (final position in [
            OiToastPosition.topLeft,
            OiToastPosition.bottomRight,
          ]) {
            final name =
                '${position == OiToastPosition.topLeft ? 'L' : 'R'} $index';
            handles.add(
              OiToast.show(
                anchor.currentContext!,
                message: name,
                position: position,
                duration: null,
                dismissLabel: 'Schließen $name',
                onDismiss: () => dismissed.add(name),
                action: OiButton.ghost(
                  label: 'Undo $name',
                  size: OiButtonSize.small,
                  onTap: () => actions.add(name),
                ),
              ),
            );
          }
        }
        await tester.pumpAndSettle();
        expect(find.text('L 0').hitTestable(), findsOneWidget);
        expect(find.text('L 11').hitTestable(), findsNothing);
        expect(find.text('R 11').hitTestable(), findsOneWidget);
        expect(find.text('R 0').hitTestable(), findsNothing);
        final rightBefore = tester.getRect(_toast('R 11'));
        await tester.drag(find.text('L 0'), const Offset(0, -500));
        await tester.pumpAndSettle();
        expect(find.text('L 11').hitTestable(), findsOneWidget);
        expect(find.text('L 0').hitTestable(), findsNothing);
        expect(tester.getRect(_toast('R 11')), rightBefore);
        final leftScrolled = tester.getRect(_toast('L 11'));
        await tester.drag(find.text('R 11'), const Offset(0, 500));
        await tester.pumpAndSettle();
        expect(find.text('R 0').hitTestable(), findsOneWidget);
        expect(find.text('R 11').hitTestable(), findsNothing);
        expect(tester.getRect(_toast('L 11')), leftScrolled);
        final rightScrolled = tester.getRect(_toast('R 0'));
        handles.add(
          OiToast.show(
            anchor.currentContext!,
            message: 'Temporary center',
            position: OiToastPosition.topCenter,
            duration: null,
          ),
        );
        await tester.pumpAndSettle();
        handles.last.dismiss();
        await tester.pump();
        expect(tester.getRect(_toast('L 11')), leftScrolled);
        expect(tester.getRect(_toast('R 0')), rightScrolled);
        await tester.tap(find.text('Undo L 11'));
        await tester.tap(find.text('Undo R 0'));
        await tester.pump();
        expect(actions, ['L 11', 'R 0']);
        await tester.tap(_close('L 11'));
        await tester.pumpAndSettle();
        await tester.tap(_close('R 0'));
        await tester.pumpAndSettle();
        expect(dismissed, ['L 11', 'R 0']);
        expect(handles[22].isDismissed, isTrue);
        expect(handles[1].isDismissed, isTrue);
        expect(tester.takeException(), isNull);
      } finally {
        for (final handle in handles) {
          handle.dismiss();
        }
        await tester.pump();
      }
      expect(handles.every((handle) => handle.isDismissed), isTrue);
      expect(find.byType(OiToast), findsNothing);
    },
  );
}

Finder _toast(String message) => find.byWidgetPredicate(
  (widget) => widget is OiToast && widget.message == message,
);

Finder _close(String message) =>
    find.descendant(of: _toast(message), matching: find.byType(OiIconButton));
