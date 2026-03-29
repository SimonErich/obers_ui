// Tests do not require documentation comments.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/buttons/oi_button.dart';
import 'package:obers_ui/src/composites/navigation/oi_error_page.dart';
import 'package:obers_ui/src/foundation/theme/oi_text_theme.dart';
import 'package:obers_ui/src/primitives/display/oi_label.dart';

import '../../../helpers/pump_app.dart';

void main() {
  group('OiErrorPage', () {
    testWidgets('default constructor renders title and error code', (
      tester,
    ) async {
      await tester.pumpObers(
        const OiErrorPage(
          title: 'Custom Error',
          label: 'Custom error page',
          errorCode: '418',
        ),
        surfaceSize: const Size(800, 600),
      );

      expect(find.text('Custom Error'), findsOneWidget);
      expect(find.text('418'), findsOneWidget);
    });

    testWidgets('.notFound() factory shows 404 and default title', (
      tester,
    ) async {
      await tester.pumpObers(
        OiErrorPage.notFound(),
        surfaceSize: const Size(800, 600),
      );

      expect(find.text('404'), findsOneWidget);
      expect(find.text('Page not found'), findsOneWidget);
      expect(
        find.text('The page you are looking for does not exist.'),
        findsOneWidget,
      );
    });

    testWidgets('.forbidden() factory shows 403 and default title', (
      tester,
    ) async {
      await tester.pumpObers(
        OiErrorPage.forbidden(),
        surfaceSize: const Size(800, 600),
      );

      expect(find.text('403'), findsOneWidget);
      expect(find.text('Access denied'), findsOneWidget);
      expect(
        find.text('You do not have permission to view this page.'),
        findsOneWidget,
      );
    });

    testWidgets('.serverError() factory shows 500 and default title', (
      tester,
    ) async {
      await tester.pumpObers(
        OiErrorPage.serverError(),
        surfaceSize: const Size(800, 600),
      );

      expect(find.text('500'), findsOneWidget);
      expect(find.text('Something went wrong'), findsOneWidget);
      expect(
        find.text('An unexpected error occurred on the server.'),
        findsOneWidget,
      );
    });

    testWidgets('custom illustration is rendered when provided', (
      tester,
    ) async {
      await tester.pumpObers(
        const OiErrorPage(
          title: 'Error',
          label: 'Error page',
          illustration: SizedBox(
            key: Key('custom-illustration'),
            width: 100,
            height: 100,
          ),
        ),
        surfaceSize: const Size(800, 600),
      );

      expect(find.byKey(const Key('custom-illustration')), findsOneWidget);
    });

    testWidgets(
      'action button renders when actionLabel and onAction provided',
      (tester) async {
        var tapped = false;
        await tester.pumpObers(
          OiErrorPage.notFound(
            actionLabel: 'Go Home',
            onAction: () => tapped = true,
          ),
          surfaceSize: const Size(800, 600),
        );

        expect(find.byType(OiButton), findsOneWidget);
        expect(find.text('Go Home'), findsOneWidget);

        await tester.tap(find.text('Go Home'));
        expect(tapped, isTrue);
      },
    );

    testWidgets('no action button when actionLabel is null', (tester) async {
      await tester.pumpObers(
        OiErrorPage.notFound(),
        surfaceSize: const Size(800, 600),
      );

      expect(find.byType(OiButton), findsNothing);
    });

    testWidgets('description renders when provided', (tester) async {
      await tester.pumpObers(
        const OiErrorPage(
          title: 'Error',
          label: 'Error page',
          description: 'Something went terribly wrong.',
        ),
        surfaceSize: const Size(800, 600),
      );

      expect(find.text('Something went terribly wrong.'), findsOneWidget);
    });

    testWidgets('semantics label is applied', (tester) async {
      await tester.pumpObers(
        const OiErrorPage(
          title: 'Error',
          label: 'Error boundary',
          errorCode: '500',
        ),
        surfaceSize: const Size(800, 600),
      );

      expect(
        find.byWidgetPredicate(
          (w) => w is Semantics && w.properties.label == 'Error boundary',
        ),
        findsOneWidget,
      );
    });

    testWidgets('no error code shown when errorCode is null', (tester) async {
      await tester.pumpObers(
        const OiErrorPage(title: 'Unknown Error', label: 'Error page'),
        surfaceSize: const Size(800, 600),
      );

      expect(find.text('Unknown Error'), findsOneWidget);
      // The title renders as OiLabel.h4 but no OiLabel.display (error code)
      // should be present.
      final labels = tester.widgetList<OiLabel>(find.byType(OiLabel));
      expect(labels.where((l) => l.variant == OiLabelVariant.display), isEmpty);
    });
  });
}
