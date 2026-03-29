// Tests do not require documentation comments.

import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/foundation/oi_page_route.dart';
import 'package:obers_ui/src/foundation/theme/oi_animation_config.dart';

import '../../helpers/pump_app.dart';

void main() {
  group('OiPageRoute', () {
    testWidgets('fade transition shows new page', (tester) async {
      await tester.pumpObers(
        Builder(
          builder: (context) {
            return GestureDetector(
              onTap: () {
                unawaited(
                  Navigator.of(context).push<void>(
                    OiPageRoute<void>(
                      builder: (_) => const Text('Page 2'),
                    ),
                  ),
                );
              },
              child: const Text('Page 1'),
            );
          },
        ),
      );

      await tester.tap(find.text('Page 1'));
      await tester.pumpAndSettle();

      expect(find.text('Page 2'), findsOneWidget);
    });

    testWidgets('slide horizontal transition shows new page', (tester) async {
      await tester.pumpObers(
        Builder(
          builder: (context) {
            return GestureDetector(
              onTap: () {
                unawaited(
                  Navigator.of(context).push<void>(
                    OiPageRoute<void>(
                      builder: (_) => const Text('Slid Page'),
                      transition: OiPageTransitionType.slideHorizontal,
                    ),
                  ),
                );
              },
              child: const Text('Start'),
            );
          },
        ),
      );

      await tester.tap(find.text('Start'));
      await tester.pumpAndSettle();

      expect(find.text('Slid Page'), findsOneWidget);
    });

    testWidgets('none transition shows immediately', (tester) async {
      await tester.pumpObers(
        Builder(
          builder: (context) {
            return GestureDetector(
              onTap: () {
                unawaited(
                  Navigator.of(context).push<void>(
                    OiPageRoute<void>(
                      builder: (_) => const Text('Instant Page'),
                      transition: OiPageTransitionType.none,
                    ),
                  ),
                );
              },
              child: const Text('Go'),
            );
          },
        ),
      );

      await tester.tap(find.text('Go'));
      // Only one pump needed — no animation to settle.
      await tester.pump();
      await tester.pump();

      expect(find.text('Instant Page'), findsOneWidget);
    });

    testWidgets('pop returns value', (tester) async {
      String? result;

      await tester.pumpObers(
        Builder(
          builder: (context) {
            return GestureDetector(
              onTap: () async {
                final value = await Navigator.of(context).push<String>(
                  OiPageRoute<String>(
                    builder: (ctx) {
                      return GestureDetector(
                        onTap: () => Navigator.of(ctx).pop('hello'),
                        child: const Text('Page 2'),
                      );
                    },
                  ),
                );
                result = value;
              },
              child: const Text('Page 1'),
            );
          },
        ),
      );

      // Navigate to Page 2.
      await tester.tap(find.text('Page 1'));
      await tester.pumpAndSettle();

      // Pop Page 2 with a result.
      await tester.tap(find.text('Page 2'));
      await tester.pumpAndSettle();

      expect(result, 'hello');
    });

    testWidgets('maintains state by default', (tester) async {
      final route = OiPageRoute<void>(
        builder: (_) => const SizedBox.shrink(),
      );
      expect(route.maintainState, isTrue);
    });

    testWidgets('default transition is fade', (tester) async {
      final route = OiPageRoute<void>(
        builder: (_) => const SizedBox.shrink(),
      );
      expect(route.transition, OiPageTransitionType.fade);
    });
  });

  group('OiTransitionPage', () {
    testWidgets('createRoute returns OiPageRoute', (tester) async {
      const page = OiTransitionPage<void>(
        child: Text('Page Content'),
      );

      late BuildContext capturedContext;
      await tester.pumpObers(
        Builder(
          builder: (context) {
            capturedContext = context;
            return const SizedBox.shrink();
          },
        ),
      );

      final route = page.createRoute(capturedContext);
      expect(route, isA<OiPageRoute<void>>());
    });

    testWidgets('forwards transition type to OiPageRoute', (tester) async {
      const page = OiTransitionPage<void>(
        child: Text('content'),
        transition: OiPageTransitionType.slideVertical,
      );

      late BuildContext capturedContext;
      await tester.pumpObers(
        Builder(
          builder: (context) {
            capturedContext = context;
            return const SizedBox.shrink();
          },
        ),
      );

      final route = page.createRoute(capturedContext) as OiPageRoute<void>;
      expect(route.transition, OiPageTransitionType.slideVertical);
    });

    testWidgets('forwards custom durations to OiPageRoute', (tester) async {
      const page = OiTransitionPage<void>(
        child: Text('content'),
        transitionDuration: Duration(milliseconds: 500),
        reverseTransitionDuration: Duration(milliseconds: 300),
      );

      late BuildContext capturedContext;
      await tester.pumpObers(
        Builder(
          builder: (context) {
            capturedContext = context;
            return const SizedBox.shrink();
          },
        ),
      );

      final route = page.createRoute(capturedContext) as OiPageRoute<void>;
      expect(route.transitionDuration, const Duration(milliseconds: 500));
      expect(
        route.reverseTransitionDuration,
        const Duration(milliseconds: 300),
      );
    });
  });
}
