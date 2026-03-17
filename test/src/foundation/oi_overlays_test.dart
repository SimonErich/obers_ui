// Tests are internal; doc comments on local helpers are not required.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/foundation/oi_overlays.dart';

/// Wraps [child] in the overlay host so overlay insertion works.
Widget buildHost({
  required OiOverlaysService service,
  required Widget child,
}) {
  return Directionality(
    textDirection: TextDirection.ltr,
    child: buildOiOverlaysHost(service: service, child: child),
  );
}

void main() {
  group('OiOverlayZOrder', () {
    test('has expected values in order', () {
      expect(OiOverlayZOrder.values, [
        OiOverlayZOrder.base,
        OiOverlayZOrder.dropdown,
        OiOverlayZOrder.tooltip,
        OiOverlayZOrder.panel,
        OiOverlayZOrder.dialog,
        OiOverlayZOrder.toast,
        OiOverlayZOrder.critical,
      ]);
    });

    test('higher enum index renders above lower', () {
      expect(
        OiOverlayZOrder.dialog.index,
        greaterThan(OiOverlayZOrder.base.index),
      );
      expect(
        OiOverlayZOrder.toast.index,
        greaterThan(OiOverlayZOrder.dialog.index),
      );
      expect(
        OiOverlayZOrder.critical.index,
        greaterThan(OiOverlayZOrder.toast.index),
      );
    });
  });

  group('createOiOverlaysService', () {
    test('returns an OiOverlaysService instance', () {
      final service = createOiOverlaysService();
      expect(service, isA<OiOverlaysService>());
    });

    test('returns a new instance each call', () {
      final a = createOiOverlaysService();
      final b = createOiOverlaysService();
      expect(a, isNot(same(b)));
    });
  });

  group('OiOverlayHandle', () {
    testWidgets('isDismissed is false after show', (tester) async {
      final service = createOiOverlaysService();

      await tester.pumpWidget(
        buildHost(
          service: service,
          child: const SizedBox.shrink(),
        ),
      );
      await tester.pump(); // let post-frame callback attach overlay state

      final handle = service.show(builder: (_) => const SizedBox.shrink());
      expect(handle.isDismissed, isFalse);
    });

    testWidgets('isDismissed is true after dismiss', (tester) async {
      final service = createOiOverlaysService();

      await tester.pumpWidget(
        buildHost(
          service: service,
          child: const SizedBox.shrink(),
        ),
      );
      await tester.pump();

      final handle = service.show(builder: (_) => const SizedBox.shrink())
        ..dismiss();
      expect(handle.isDismissed, isTrue);
    });

    testWidgets('dismiss is idempotent', (tester) async {
      final service = createOiOverlaysService();

      await tester.pumpWidget(
        buildHost(
          service: service,
          child: const SizedBox.shrink(),
        ),
      );
      await tester.pump();

      final handle = service.show(builder: (_) => const SizedBox.shrink())
        ..dismiss();
      // Second dismiss must not throw
      expect(handle.dismiss, returnsNormally);
      expect(handle.isDismissed, isTrue);
    });

    testWidgets('update does not throw when not dismissed', (tester) async {
      final service = createOiOverlaysService();

      await tester.pumpWidget(
        buildHost(
          service: service,
          child: const SizedBox.shrink(),
        ),
      );
      await tester.pump();

      final handle = service.show(builder: (_) => const SizedBox.shrink());
      expect(handle.update, returnsNormally);
    });

    testWidgets('update is a no-op after dismiss', (tester) async {
      final service = createOiOverlaysService();

      await tester.pumpWidget(
        buildHost(
          service: service,
          child: const SizedBox.shrink(),
        ),
      );
      await tester.pump();

      final handle = service.show(builder: (_) => const SizedBox.shrink())
        ..dismiss();
      expect(handle.update, returnsNormally);
    });
  });

  group('OiOverlaysService', () {
    testWidgets('show renders the provided widget', (tester) async {
      final service = createOiOverlaysService();

      await tester.pumpWidget(
        buildHost(
          service: service,
          child: const SizedBox.shrink(),
        ),
      );
      await tester.pump();

      service.show(
        builder: (_) => const Text('overlay content'),
      );
      await tester.pump();

      expect(find.text('overlay content'), findsOneWidget);
    });

    testWidgets('show with dismissible adds a barrier', (tester) async {
      final service = createOiOverlaysService();
      var dismissed = false;

      await tester.pumpWidget(
        buildHost(
          service: service,
          child: const SizedBox.shrink(),
        ),
      );
      await tester.pump();

      service.show(
        builder: (_) => const Text('overlay'),
        onDismiss: () => dismissed = true,
      );
      await tester.pump();

      // Tap the dismiss barrier GestureDetector directly
      await tester.tap(find.byType(GestureDetector).first);
      await tester.pump();

      expect(dismissed, isTrue);
    });

    testWidgets('show with dismissible=false has no tap barrier', (tester) async {
      final service = createOiOverlaysService();
      var dismissCalled = false;

      await tester.pumpWidget(
        buildHost(
          service: service,
          child: const SizedBox.shrink(),
        ),
      );
      await tester.pump();

      final handle = service.show(
        builder: (_) => const Text('overlay'),
        dismissible: false,
        onDismiss: () => dismissCalled = true,
      );
      await tester.pump();

      await tester.tapAt(Offset.zero);
      await tester.pump();

      // Without a dismissible barrier the overlay should still be present
      expect(handle.isDismissed, isFalse);
      expect(dismissCalled, isFalse);

      handle.dismiss();
    });

    testWidgets('dismissAll dismisses every active overlay', (tester) async {
      final service = createOiOverlaysService();

      await tester.pumpWidget(
        buildHost(
          service: service,
          child: const SizedBox.shrink(),
        ),
      );
      await tester.pump();

      final h1 = service.show(builder: (_) => const SizedBox.shrink());
      final h2 = service.show(builder: (_) => const SizedBox.shrink());
      final h3 = service.show(builder: (_) => const SizedBox.shrink());

      service.dismissAll();

      expect(h1.isDismissed, isTrue);
      expect(h2.isDismissed, isTrue);
      expect(h3.isDismissed, isTrue);
    });

    testWidgets('dismissAll is safe when no overlays are active',
        (tester) async {
      final service = createOiOverlaysService();

      await tester.pumpWidget(
        buildHost(
          service: service,
          child: const SizedBox.shrink(),
        ),
      );
      await tester.pump();

      expect(service.dismissAll, returnsNormally);
    });

    testWidgets('dismissed handle removed, remaining stays visible',
        (tester) async {
      final service = createOiOverlaysService();

      await tester.pumpWidget(
        buildHost(
          service: service,
          child: const SizedBox.shrink(),
        ),
      );
      await tester.pump();

      service.show(builder: (_) => const Text('first'));
      final h2 = service.show(builder: (_) => const Text('second'));
      await tester.pump();

      h2.dismiss();
      await tester.pump();

      expect(find.text('first'), findsOneWidget);
      expect(find.text('second'), findsNothing);
    });
  });

  group('OiOverlays', () {
    testWidgets('of(context) returns the service', (tester) async {
      final service = createOiOverlaysService();
      late OiOverlaysService captured;

      await tester.pumpWidget(
        buildHost(
          service: service,
          child: Builder(
            builder: (context) {
              captured = OiOverlays.of(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(captured, same(service));
    });

    testWidgets('maybeOf returns null when no OiOverlays in tree',
        (tester) async {
      late OiOverlaysService? captured;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Builder(
            builder: (context) {
              captured = OiOverlays.maybeOf(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(captured, isNull);
    });

    testWidgets('of(context) throws when no OiOverlays in tree',
        (tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Builder(
            builder: (context) {
              expect(
                () => OiOverlays.of(context),
                throwsAssertionError,
              );
              return const SizedBox.shrink();
            },
          ),
        ),
      );
    });

    test('updateShouldNotify returns false for same service instance', () {
      final service = createOiOverlaysService();
      const child = SizedBox.shrink();

      final oldWidget = OiOverlays(service: service, child: child);
      final newWidget = OiOverlays(service: service, child: child);

      expect(newWidget.updateShouldNotify(oldWidget), isFalse);
    });

    test('updateShouldNotify returns true for different service instances', () {
      final serviceA = createOiOverlaysService();
      final serviceB = createOiOverlaysService();
      const child = SizedBox.shrink();

      final oldWidget = OiOverlays(service: serviceA, child: child);
      final newWidget = OiOverlays(service: serviceB, child: child);

      expect(newWidget.updateShouldNotify(oldWidget), isTrue);
    });
  });

  group('buildOiOverlaysHost', () {
    testWidgets('returns a widget that mounts correctly', (tester) async {
      final service = createOiOverlaysService();

      await tester.pumpWidget(
        buildHost(
          service: service,
          child: const Text('child widget'),
        ),
      );

      expect(find.text('child widget'), findsOneWidget);
    });

    testWidgets('attaches overlay state after first frame', (tester) async {
      final service = createOiOverlaysService();

      await tester.pumpWidget(
        buildHost(
          service: service,
          child: const SizedBox.shrink(),
        ),
      );
      await tester.pump(); // process post-frame callback

      // After attachment, show() must not assert
      expect(
        () => service.show(builder: (_) => const SizedBox.shrink()),
        returnsNormally,
      );
    });
  });
}
