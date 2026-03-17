// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/composites/onboarding/oi_whats_new.dart';

import '../../../helpers/pump_app.dart';

void main() {
  group('OiWhatsNew', () {
    testWidgets('renders items with title and description', (tester) async {
      await tester.pumpObers(
        const OiWhatsNew(
          items: [
            OiWhatsNewItem(
              title: 'Dark Mode',
              description: 'The app now supports dark mode.',
            ),
            OiWhatsNewItem(
              title: 'Export PDF',
              description: 'Export your reports as PDF.',
            ),
          ],
        ),
      );

      expect(find.text('Dark Mode'), findsOneWidget);
      expect(find.text('The app now supports dark mode.'), findsOneWidget);
      expect(find.text('Export PDF'), findsOneWidget);
      expect(find.text('Export your reports as PDF.'), findsOneWidget);
    });

    testWidgets('renders dialog title', (tester) async {
      await tester.pumpObers(
        const OiWhatsNew(
          title: 'Release Notes',
          items: [OiWhatsNewItem(title: 'Feature', description: 'A feature.')],
        ),
      );

      expect(find.text('Release Notes'), findsOneWidget);
    });

    testWidgets('icons are displayed when provided', (tester) async {
      await tester.pumpObers(
        const OiWhatsNew(
          items: [
            OiWhatsNewItem(
              title: 'Search',
              description: 'Improved search.',
              icon: IconData(0xe8b6, fontFamily: 'MaterialIcons'),
            ),
          ],
        ),
      );

      expect(find.byType(Icon), findsOneWidget);
    });

    testWidgets('version badge is displayed when provided', (tester) async {
      await tester.pumpObers(
        const OiWhatsNew(
          items: [
            OiWhatsNewItem(
              title: 'Feature',
              description: 'A new feature.',
              version: 'v2.1.0',
            ),
          ],
        ),
      );

      expect(find.text('v2.1.0'), findsOneWidget);
      expect(find.byKey(const Key('oi_whats_new_version')), findsOneWidget);
    });

    testWidgets('onDismiss fires when dismiss button is tapped', (
      tester,
    ) async {
      var dismissed = false;
      await tester.pumpObers(
        OiWhatsNew(
          items: const [
            OiWhatsNewItem(title: 'Feature', description: 'A feature.'),
          ],
          onDismiss: () => dismissed = true,
        ),
      );

      await tester.tap(find.byKey(const Key('oi_whats_new_dismiss')));
      await tester.pump();

      expect(dismissed, isTrue);
    });

    testWidgets('empty items handles gracefully', (tester) async {
      await tester.pumpObers(const OiWhatsNew(items: []));

      expect(find.byKey(const Key('oi_whats_new_empty')), findsOneWidget);
      expect(find.text('No updates at this time.'), findsOneWidget);
    });

    testWidgets("default title is What's New", (tester) async {
      await tester.pumpObers(
        const OiWhatsNew(
          items: [OiWhatsNewItem(title: 'Feature', description: 'A feature.')],
        ),
      );

      expect(find.text("What's New"), findsOneWidget);
    });

    testWidgets('Got it button is always shown', (tester) async {
      await tester.pumpObers(
        const OiWhatsNew(
          items: [OiWhatsNewItem(title: 'Feature', description: 'A feature.')],
        ),
      );

      expect(find.text('Got it'), findsOneWidget);
    });

    testWidgets('multiple items all render', (tester) async {
      final items = List.generate(
        5,
        (i) =>
            OiWhatsNewItem(title: 'Feature $i', description: 'Description $i'),
      );

      await tester.pumpObers(OiWhatsNew(items: items));

      for (var i = 0; i < 5; i++) {
        expect(find.text('Feature $i'), findsOneWidget);
        expect(find.text('Description $i'), findsOneWidget);
      }
    });
  });
}
