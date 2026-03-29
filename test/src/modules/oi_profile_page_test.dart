// Tests do not require documentation comments.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/obers_ui.dart';

import '../../helpers/pump_app.dart';

const _profile = OiProfileData(
  name: 'Jane Doe',
  email: 'jane@example.com',
  role: 'Admin',
  phone: '+1 555 1234',
  bio: 'Hello world',
);

const _minimalProfile = OiProfileData(name: 'John', email: 'john@example.com');

const _accounts = [
  OiLinkedAccount(
    provider: 'google',
    label: 'Google',
    icon: OiIcons.mail,
    connected: true,
    username: 'jane@gmail.com',
  ),
  OiLinkedAccount(provider: 'github', label: 'GitHub', icon: OiIcons.link),
  OiLinkedAccount(
    provider: 'slack',
    label: 'Slack',
    icon: OiIcons.link,
    connected: true,
    username: 'jane-doe',
  ),
];

void main() {
  group('OiProfilePage', () {
    testWidgets('renders profile name and email', (tester) async {
      await tester.pumpObers(
        const OiProfilePage(profile: _profile, label: 'Profile'),
        surfaceSize: const Size(800, 600),
      );

      expect(find.text('Jane Doe'), findsWidgets);
      expect(find.text('jane@example.com'), findsOneWidget);
    });

    testWidgets('renders avatar with correct name', (tester) async {
      await tester.pumpObers(
        const OiProfilePage(profile: _profile, label: 'Profile'),
        surfaceSize: const Size(800, 600),
      );

      // OiAvatar should be rendered (it uses initials "JD").
      expect(find.byType(OiAvatar), findsOneWidget);
    });

    testWidgets('role renders when provided', (tester) async {
      await tester.pumpObers(
        const OiProfilePage(profile: _profile, label: 'Profile'),
        surfaceSize: const Size(800, 600),
      );

      expect(find.text('Admin'), findsOneWidget);
    });

    testWidgets('role does not render when absent', (tester) async {
      await tester.pumpObers(
        const OiProfilePage(profile: _minimalProfile, label: 'Profile'),
        surfaceSize: const Size(800, 600),
      );

      expect(find.text('Admin'), findsNothing);
    });

    testWidgets('personal info fields render', (tester) async {
      await tester.pumpObers(
        const OiProfilePage(profile: _profile, label: 'Profile'),
        surfaceSize: const Size(800, 600),
      );

      expect(find.text('Personal Information'), findsOneWidget);
      expect(find.text('Name'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Phone'), findsOneWidget);
      expect(find.text('Bio'), findsOneWidget);
    });

    testWidgets('linked accounts render with labels', (tester) async {
      await tester.pumpObers(
        const OiProfilePage(
          profile: _profile,
          label: 'Profile',
          linkedAccounts: _accounts,
        ),
        surfaceSize: const Size(800, 900),
      );

      expect(find.text('Linked Accounts'), findsOneWidget);
      expect(find.text('Google'), findsOneWidget);
      expect(find.text('GitHub'), findsOneWidget);
      expect(find.text('Slack'), findsOneWidget);
    });

    testWidgets('connected accounts show Connected badge', (tester) async {
      await tester.pumpObers(
        const OiProfilePage(
          profile: _profile,
          label: 'Profile',
          linkedAccounts: _accounts,
        ),
        surfaceSize: const Size(800, 900),
      );

      // Google and Slack are connected, so expect 2 "Connected" badges.
      expect(find.text('Connected'), findsNWidgets(2));
    });

    testWidgets('disconnect button calls onAccountUnlink', (tester) async {
      OiLinkedAccount? unlinkedAccount;

      await tester.pumpObers(
        OiProfilePage(
          profile: _profile,
          label: 'Profile',
          linkedAccounts: _accounts,
          onAccountUnlink: (account) => unlinkedAccount = account,
        ),
        surfaceSize: const Size(800, 900),
      );

      // Tap the first "Disconnect" button (Google).
      await tester.tap(find.text('Disconnect').first);
      await tester.pumpAndSettle();

      expect(unlinkedAccount, isNotNull);
      expect(unlinkedAccount!.provider, 'google');
    });

    testWidgets('danger zone renders when showDangerZone is true', (
      tester,
    ) async {
      await tester.pumpObers(
        const OiProfilePage(profile: _profile, label: 'Profile'),
        surfaceSize: const Size(800, 800),
      );

      expect(find.text('Danger Zone'), findsOneWidget);
      expect(find.text('Delete Account'), findsOneWidget);
    });

    testWidgets('danger zone hidden when showDangerZone is false', (
      tester,
    ) async {
      await tester.pumpObers(
        const OiProfilePage(
          profile: _profile,
          label: 'Profile',
          showDangerZone: false,
        ),
        surfaceSize: const Size(800, 800),
      );

      expect(find.text('Danger Zone'), findsNothing);
      expect(find.text('Delete Account'), findsNothing);
    });

    testWidgets('delete button calls onDeleteAccount after confirmation', (
      tester,
    ) async {
      var deleteCalled = false;

      await tester.pumpObers(
        OiProfilePage(
          profile: _profile,
          label: 'Profile',
          onDeleteAccount: () async {
            deleteCalled = true;
            return true;
          },
        ),
        surfaceSize: const Size(800, 800),
      );

      // First tap: confirmation state.
      await tester.tap(find.text('Delete Account'));
      await tester.pumpAndSettle();

      expect(find.text('Are you sure? Tap again to confirm'), findsOneWidget);
      expect(deleteCalled, isFalse);

      // Second tap: actually delete.
      await tester.tap(find.text('Are you sure? Tap again to confirm'));
      await tester.pumpAndSettle();

      expect(deleteCalled, isTrue);
    });

    testWidgets('semantics label is applied', (tester) async {
      await tester.pumpObers(
        const OiProfilePage(profile: _profile, label: 'User Profile Page'),
        surfaceSize: const Size(800, 600),
      );

      expect(find.bySemanticsLabel('User Profile Page'), findsOneWidget);
    });

    testWidgets('custom sections render', (tester) async {
      await tester.pumpObers(
        const OiProfilePage(
          profile: _profile,
          label: 'Profile',
          sections: [
            OiProfileSection(
              title: 'Preferences',
              icon: OiIcons.settings,
              child: OiLabel.body('Dark mode toggle here'),
            ),
          ],
        ),
        surfaceSize: const Size(800, 800),
      );

      expect(find.text('Preferences'), findsOneWidget);
      expect(find.text('Dark mode toggle here'), findsOneWidget);
    });
  });
}
