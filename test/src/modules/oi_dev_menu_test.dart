// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/buttons/oi_button.dart';
import 'package:obers_ui/src/components/inputs/oi_switch_tile.dart';
import 'package:obers_ui/src/modules/oi_dev_menu.dart';
import 'package:obers_ui/src/primitives/display/oi_label.dart';

import '../../helpers/pump_app.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

const _envs = [
  OiDevEnvironment(key: 'dev', label: 'Development', url: 'https://dev.api'),
  OiDevEnvironment(
    key: 'staging',
    label: 'Staging',
    url: 'https://staging.api',
  ),
  OiDevEnvironment(key: 'prod', label: 'Production', url: 'https://prod.api'),
];

const _flags = [
  OiFeatureFlag(
    key: 'dark_mode',
    label: 'Dark Mode',
    description: 'Enable dark theme',
  ),
  OiFeatureFlag(
    key: 'new_ui',
    label: 'New UI',
    description: 'Experimental layout',
  ),
];

final _now = DateTime(2026, 3, 28, 14, 30, 45);

final _logs = [
  OiLogEntry(
    message: 'App started',
    level: OiLogLevel.info,
    timestamp: _now,
    source: 'Main',
  ),
  OiLogEntry(
    message: 'Token expired',
    level: OiLogLevel.warning,
    timestamp: _now,
  ),
  OiLogEntry(
    message: 'Network error',
    level: OiLogLevel.error,
    timestamp: _now,
    source: 'Http',
  ),
  OiLogEntry(message: 'Cache hit', level: OiLogLevel.debug, timestamp: _now),
];

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('OiDevMenu standalone', () {
    testWidgets('renders environment list', (tester) async {
      await tester.pumpObers(
        const SizedBox(
          width: 500,
          height: 600,
          child: OiDevMenu(
            label: 'Dev Menu',
            environments: _envs,
            currentEnvironment: 'dev',
          ),
        ),
      );

      expect(find.text('Development'), findsOneWidget);
      expect(find.text('Staging'), findsOneWidget);
      expect(find.text('Production'), findsOneWidget);
    });

    testWidgets('environment selection calls onEnvironmentChange', (
      tester,
    ) async {
      String? selected;

      await tester.pumpObers(
        SizedBox(
          width: 500,
          height: 600,
          child: OiDevMenu(
            label: 'Dev Menu',
            environments: _envs,
            currentEnvironment: 'dev',
            onEnvironmentChange: (key) => selected = key,
          ),
        ),
      );

      await tester.tap(find.text('Staging'));
      await tester.pumpAndSettle();

      expect(selected, 'staging');
    });

    testWidgets('feature flag toggles call onFeatureFlagChange', (
      tester,
    ) async {
      String? changedKey;
      bool? changedValue;

      await tester.pumpObers(
        SizedBox(
          width: 500,
          height: 600,
          child: OiDevMenu(
            label: 'Dev Menu',
            featureFlags: _flags,
            featureFlagValues: const {'dark_mode': false, 'new_ui': true},
            onFeatureFlagChange: (key, {required bool value}) {
              changedKey = key;
              changedValue = value;
            },
          ),
        ),
      );

      // Tap "Flags" tab.
      await tester.tap(find.text('Flags'));
      await tester.pumpAndSettle();

      // Tap the first switch tile to toggle Dark Mode on.
      await tester.tap(find.byType(OiSwitchTile).first);
      await tester.pumpAndSettle();

      expect(changedKey, 'dark_mode');
      expect(changedValue, true);
    });

    testWidgets('action buttons render and call onTap', (tester) async {
      var tapped = false;

      await tester.pumpObers(
        SizedBox(
          width: 500,
          height: 600,
          child: OiDevMenu(
            label: 'Dev Menu',
            actions: [
              OiDevAction(label: 'Clear Cache', onTap: () => tapped = true),
              OiDevAction(label: 'Reset App', onTap: () {}, destructive: true),
            ],
          ),
        ),
      );

      // Tap "Actions" tab.
      await tester.tap(find.text('Actions'));
      await tester.pumpAndSettle();

      expect(find.text('Clear Cache'), findsOneWidget);
      expect(find.text('Reset App'), findsOneWidget);

      await tester.tap(find.text('Clear Cache'));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets('log entries render', (tester) async {
      await tester.pumpObers(
        SizedBox(
          width: 500,
          height: 600,
          child: OiDevMenu(label: 'Dev Menu', logs: _logs),
        ),
      );

      // Tap "Logs" tab.
      await tester.tap(find.text('Logs'));
      await tester.pumpAndSettle();

      expect(find.text('App started'), findsOneWidget);
      expect(find.text('Token expired'), findsOneWidget);
      expect(find.text('Network error'), findsOneWidget);
      expect(find.text('Cache hit'), findsOneWidget);
    });

    testWidgets('log filter chips filter by level', (tester) async {
      await tester.pumpObers(
        SizedBox(
          width: 500,
          height: 600,
          child: OiDevMenu(label: 'Dev Menu', logs: _logs),
        ),
      );

      // Tap "Logs" tab.
      await tester.tap(find.text('Logs'));
      await tester.pumpAndSettle();

      // All logs visible initially.
      expect(find.text('App started'), findsOneWidget);
      expect(find.text('Cache hit'), findsOneWidget);

      // Tap "Error" filter.
      await tester.tap(find.text('Error'));
      await tester.pumpAndSettle();

      // Only error log visible.
      expect(find.text('Network error'), findsOneWidget);
      expect(find.text('App started'), findsNothing);
      expect(find.text('Cache hit'), findsNothing);
    });

    testWidgets('destructive actions render with destructive style', (
      tester,
    ) async {
      await tester.pumpObers(
        SizedBox(
          width: 500,
          height: 600,
          child: OiDevMenu(
            label: 'Dev Menu',
            actions: [
              OiDevAction(label: 'Delete All', onTap: () {}, destructive: true),
            ],
          ),
        ),
      );

      // Tap "Actions" tab.
      await tester.tap(find.text('Actions'));
      await tester.pumpAndSettle();

      // Find the OiButton and verify it is destructive variant.
      final button = tester.widget<OiButton>(find.byType(OiButton));
      expect(button.variant, OiButtonVariant.destructive);
    });

    testWidgets('semantics label is applied', (tester) async {
      await tester.pumpObers(
        const SizedBox(
          width: 500,
          height: 600,
          child: OiDevMenu(
            label: 'Test Dev Menu',
            environments: _envs,
            currentEnvironment: 'dev',
          ),
        ),
      );

      expect(
        find.byWidgetPredicate(
          (w) => w is Semantics && w.properties.label == 'Test Dev Menu',
        ),
        findsOneWidget,
      );
    });
  });

  group('OiDevMenu trigger', () {
    testWidgets('child renders initially, menu is hidden', (tester) async {
      await tester.pumpObers(
        const OiDevMenu.trigger(
          label: 'Dev Menu',
          environments: _envs,
          currentEnvironment: 'dev',
          child: OiLabel.body('My App Content'),
        ),
        surfaceSize: const Size(500, 600),
      );

      expect(find.text('My App Content'), findsOneWidget);
      // Menu header should not be visible.
      expect(find.text('Developer Menu'), findsNothing);
    });

    testWidgets('triple-tap opens menu', (tester) async {
      await tester.pumpObers(
        const OiDevMenu.trigger(
          label: 'Dev Menu',
          environments: _envs,
          currentEnvironment: 'dev',
          child: Center(child: OiLabel.body('My App Content')),
        ),
        surfaceSize: const Size(800, 600),
      );

      // Triple tap on the child to open the menu.
      final childFinder = find.text('My App Content');
      await tester.tap(childFinder);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(childFinder);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(childFinder);
      await tester.pumpAndSettle();

      expect(find.text('Developer Menu'), findsOneWidget);
    });

    testWidgets('close button closes menu', (tester) async {
      await tester.pumpObers(
        const OiDevMenu.trigger(
          label: 'Dev Menu',
          environments: _envs,
          currentEnvironment: 'dev',
          child: Center(child: OiLabel.body('My App Content')),
        ),
        surfaceSize: const Size(800, 600),
      );

      // Open menu via triple tap.
      final childFinder = find.text('My App Content');
      await tester.tap(childFinder);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(childFinder);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(childFinder);
      await tester.pumpAndSettle();

      expect(find.text('Developer Menu'), findsOneWidget);

      // Tap the close button via widget predicate.
      final closeButton = find.byWidgetPredicate(
        (w) => w is Semantics && w.properties.label == 'Close developer menu',
      );
      await tester.tap(closeButton);
      await tester.pumpAndSettle();

      expect(find.text('Developer Menu'), findsNothing);
    });
  });
}
