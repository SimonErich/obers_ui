// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/inputs/oi_switch_tile.dart';
import 'package:obers_ui/src/modules/oi_consent_banner.dart';

import '../../helpers/pump_app.dart';

const _categories = [
  OiConsentCategory(
    key: 'essential',
    name: 'Essential',
    description: 'Required for the site to function.',
    required: true,
    defaultValue: true,
  ),
  OiConsentCategory(
    key: 'analytics',
    name: 'Analytics',
    description: 'Help us understand usage patterns.',
  ),
  OiConsentCategory(
    key: 'marketing',
    name: 'Marketing',
    description: 'Used for targeted advertising.',
  ),
  OiConsentCategory(
    key: 'preferences',
    name: 'Preferences',
    description: 'Remember your settings.',
    defaultValue: true,
  ),
];

void main() {
  group('OiConsentBanner', () {
    testWidgets('renders title and description', (tester) async {
      await tester.pumpObers(
        const SizedBox(
          width: 800,
          height: 600,
          child: OiConsentBanner(
            categories: _categories,
            label: 'Cookie consent',
            title: 'Cookie Notice',
            description: 'We use cookies to improve your experience.',
          ),
        ),
      );

      expect(find.text('Cookie Notice'), findsOneWidget);
      expect(
        find.text('We use cookies to improve your experience.'),
        findsOneWidget,
      );
    });

    testWidgets('Accept All button calls onAcceptAll', (tester) async {
      var acceptAllCalled = false;

      await tester.pumpObers(
        SizedBox(
          width: 800,
          height: 600,
          child: OiConsentBanner(
            categories: _categories,
            label: 'Cookie consent',
            onAcceptAll: () => acceptAllCalled = true,
          ),
        ),
      );

      await tester.tap(find.text('Accept All'));
      await tester.pumpAndSettle();

      expect(acceptAllCalled, isTrue);
    });

    testWidgets('Reject All button calls onRejectAll', (tester) async {
      var rejectAllCalled = false;

      await tester.pumpObers(
        SizedBox(
          width: 800,
          height: 600,
          child: OiConsentBanner(
            categories: _categories,
            label: 'Cookie consent',
            onRejectAll: () => rejectAllCalled = true,
          ),
        ),
      );

      await tester.tap(find.text('Reject All'));
      await tester.pumpAndSettle();

      expect(rejectAllCalled, isTrue);
    });

    testWidgets('Manage Preferences button opens dialog', (tester) async {
      await tester.pumpObers(
        SizedBox(
          width: 800,
          height: 600,
          child: OiConsentBanner(
            categories: _categories,
            label: 'Cookie consent',
            onSavePreferences: (_) {},
          ),
        ),
      );

      // Dialog should not be visible yet.
      expect(find.text('Cookie Preferences'), findsNothing);

      await tester.tap(find.text('Manage Preferences'));
      await tester.pumpAndSettle();

      // Dialog should now be visible with category names.
      expect(find.text('Cookie Preferences'), findsOneWidget);
      expect(find.text('Analytics'), findsOneWidget);
      expect(find.text('Marketing'), findsOneWidget);
    });

    testWidgets('required categories cannot be toggled off', (tester) async {
      await tester.pumpObers(
        SizedBox(
          width: 800,
          height: 600,
          child: OiConsentBanner(
            categories: _categories,
            label: 'Cookie consent',
            onSavePreferences: (_) {},
          ),
        ),
      );

      await tester.tap(find.text('Manage Preferences'));
      await tester.pumpAndSettle();

      // The Essential category switch tile should be disabled.
      final essentialTile = tester
          .widgetList<OiSwitchTile>(find.byType(OiSwitchTile))
          .firstWhere((t) => t.title == 'Essential');

      expect(essentialTile.enabled, isFalse);
      expect(essentialTile.value, isTrue);
    });

    testWidgets('.minimal() factory has no manage button', (tester) async {
      await tester.pumpObers(
        const SizedBox(
          width: 800,
          height: 600,
          child: OiConsentBanner.minimal(
            categories: _categories,
            label: 'Cookie consent',
          ),
        ),
      );

      expect(find.text('Accept All'), findsOneWidget);
      expect(find.text('Reject All'), findsOneWidget);
      expect(find.text('Manage Preferences'), findsNothing);
    });

    testWidgets('banner is hidden when visible is false', (tester) async {
      await tester.pumpObers(
        const SizedBox(
          width: 800,
          height: 600,
          child: OiConsentBanner(
            categories: _categories,
            label: 'Cookie consent',
            visible: false,
          ),
        ),
      );

      // The banner should render SizedBox.shrink when not visible.
      expect(find.text('We use cookies'), findsNothing);
    });

    testWidgets('semantics label is applied', (tester) async {
      await tester.pumpObers(
        const SizedBox(
          width: 800,
          height: 600,
          child: OiConsentBanner(
            categories: _categories,
            label: 'GDPR consent banner',
          ),
        ),
      );

      final semantics = tester.widget<Semantics>(
        find.byWidgetPredicate(
          (w) => w is Semantics && w.properties.label == 'GDPR consent banner',
        ),
      );
      expect(semantics, isNotNull);
    });

    testWidgets(
      'privacy policy link renders when onPrivacyPolicyTap provided',
      (tester) async {
        var privacyTapped = false;

        await tester.pumpObers(
          SizedBox(
            width: 800,
            height: 600,
            child: OiConsentBanner(
              categories: _categories,
              label: 'Cookie consent',
              onPrivacyPolicyTap: () => privacyTapped = true,
            ),
          ),
        );

        expect(find.text('Privacy Policy'), findsOneWidget);

        await tester.tap(find.text('Privacy Policy'));
        await tester.pumpAndSettle();

        expect(privacyTapped, isTrue);
      },
    );
  });
}
