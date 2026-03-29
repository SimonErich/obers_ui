// Tests do not require documentation comments.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/buttons/oi_button.dart';
import 'package:obers_ui/src/modules/oi_maintenance_page.dart';

import '../../helpers/pump_app.dart';

void main() {
  group('OiMaintenancePage', () {
    testWidgets('default constructor renders title', (tester) async {
      await tester.pumpObers(
        const OiMaintenancePage(
          title: 'Under Construction',
          label: 'Maintenance page',
        ),
        surfaceSize: const Size(800, 600),
      );

      expect(find.text('Under Construction'), findsOneWidget);
    });

    testWidgets('.maintenance() factory shows default title and description', (
      tester,
    ) async {
      await tester.pumpObers(
        OiMaintenancePage.maintenance(),
        surfaceSize: const Size(800, 600),
      );

      expect(find.text("We'll be back soon"), findsOneWidget);
      expect(
        find.text("We're performing scheduled maintenance."),
        findsOneWidget,
      );
    });

    testWidgets('.notFound() factory shows "Page not found"', (tester) async {
      await tester.pumpObers(
        OiMaintenancePage.notFound(),
        surfaceSize: const Size(800, 600),
      );

      expect(find.text('Page not found'), findsOneWidget);
      expect(
        find.text('The page you are looking for does not exist.'),
        findsOneWidget,
      );
    });

    testWidgets('.serverError() factory shows "Something went wrong"', (
      tester,
    ) async {
      await tester.pumpObers(
        OiMaintenancePage.serverError(),
        surfaceSize: const Size(800, 600),
      );

      expect(find.text('Something went wrong'), findsOneWidget);
      expect(find.text('An unexpected error occurred.'), findsOneWidget);
    });

    testWidgets('.offline() factory shows "You\'re offline"', (tester) async {
      await tester.pumpObers(
        OiMaintenancePage.offline(),
        surfaceSize: const Size(800, 600),
      );

      expect(find.text("You're offline"), findsOneWidget);
      expect(
        find.text('Check your internet connection and try again.'),
        findsOneWidget,
      );
    });

    testWidgets('retry button renders when onRetry provided', (tester) async {
      var tapped = false;
      await tester.pumpObers(
        OiMaintenancePage.maintenance(onRetry: () => tapped = true),
        surfaceSize: const Size(800, 600),
      );

      expect(find.byType(OiButton), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);

      await tester.tap(find.text('Try Again'));
      expect(tapped, isTrue);
    });

    testWidgets('no retry button when onRetry is null', (tester) async {
      await tester.pumpObers(
        OiMaintenancePage.maintenance(),
        surfaceSize: const Size(800, 600),
      );

      expect(find.byType(OiButton), findsNothing);
    });

    testWidgets('description renders when provided', (tester) async {
      await tester.pumpObers(
        const OiMaintenancePage(
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
        const OiMaintenancePage(
          title: 'Maintenance',
          label: 'System maintenance',
        ),
        surfaceSize: const Size(800, 600),
      );

      expect(
        find.byWidgetPredicate(
          (w) => w is Semantics && w.properties.label == 'System maintenance',
        ),
        findsOneWidget,
      );
    });

    testWidgets('custom illustration renders when provided', (tester) async {
      await tester.pumpObers(
        const OiMaintenancePage(
          title: 'Maintenance',
          label: 'Maintenance page',
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

    testWidgets('countdown renders when estimatedReturn is in the future', (
      tester,
    ) async {
      await tester.pumpObers(
        OiMaintenancePage.maintenance(
          estimatedReturn: DateTime.now().add(const Duration(hours: 2)),
        ),
        surfaceSize: const Size(800, 600),
      );

      expect(find.textContaining('Returning in'), findsOneWidget);
    });

    testWidgets('social links render when provided', (tester) async {
      var linkTapped = false;
      await tester.pumpObers(
        OiMaintenancePage.maintenance(
          socialLinks: [
            OiSocialLink(label: 'Twitter', onTap: () => linkTapped = true),
            const OiSocialLink(label: 'GitHub', onTap: _noOp),
          ],
        ),
        surfaceSize: const Size(800, 600),
      );

      expect(find.text('Twitter'), findsOneWidget);
      expect(find.text('GitHub'), findsOneWidget);

      await tester.tap(find.text('Twitter'));
      expect(linkTapped, isTrue);
    });
  });
}

void _noOp() {}
