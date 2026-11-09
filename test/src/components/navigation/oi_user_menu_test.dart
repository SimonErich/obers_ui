// Tests for OiUserMenu — REQ-0015.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/display/oi_avatar.dart';
import 'package:obers_ui/src/components/navigation/oi_user_menu.dart';
import 'package:obers_ui/src/components/overlays/oi_context_menu.dart';
import 'package:obers_ui/src/foundation/oi_icons.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('default and custom avatars share one named menu trigger', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    for (final avatar in [
      null,
      const OiAvatar(semanticLabel: 'Marie Novak', initials: 'MN'),
    ]) {
      await tester.pumpObers(
        OiUserMenu(
          label: 'Marie Novak account menu',
          userName: 'Marie Novak',
          avatar: avatar,
          avatarInitials: 'MN',
          items: const [],
        ),
      );
      expect(find.bySemanticsLabel('Marie Novak account menu'), findsOneWidget);
      expect(
        find.bySemanticsLabel(RegExp('Marie Novak.*Marie Novak', dotAll: true)),
        findsNothing,
      );
    }
    semantics.dispose();
  });

  // ── Rendering ────────────────────────────────────────────────────────────

  testWidgets('renders avatar with initials when no imageUrl', (tester) async {
    await tester.pumpObers(
      const OiUserMenu(
        label: 'User menu',
        userName: 'John Doe',
        avatarInitials: 'JD',
        items: [],
      ),
    );
    expect(find.byType(OiAvatar), findsOneWidget);
    expect(find.text('JD'), findsOneWidget);
  });

  testWidgets('renders avatar with imageUrl', (tester) async {
    await tester.pumpObers(
      const OiUserMenu(
        label: 'User menu',
        userName: 'John Doe',
        avatarUrl: 'https://example.com/avatar.png',
        items: [],
      ),
    );
    expect(find.byType(OiAvatar), findsOneWidget);
  });

  // ── Popover interaction ──────────────────────────────────────────────────

  testWidgets('custom avatar keeps menu trigger and actions', (tester) async {
    var opened = false;
    await tester.pumpObers(
      Center(
        child: OiUserMenu(
          label: 'User menu',
          userName: 'Marie Novak',
          avatar: const OiAvatar(
            semanticLabel: 'Marie Novak',
            initials: 'MN',
            size: OiAvatarSize.sm,
            backgroundColor: Color(0xFFE5F5FA),
          ),
          items: [OiMenuItem(label: 'Profile', onTap: () => opened = true)],
        ),
      ),
    );
    expect(tester.getSize(find.byType(OiAvatar)), const Size(32, 32));
    await tester.tap(find.byType(OiAvatar));
    await tester.pumpAndSettle();
    expect(find.text('Marie Novak'), findsOneWidget);
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    expect(opened, isTrue);
  });

  testWidgets('tapping avatar opens popover', (tester) async {
    await tester.pumpObers(
      const OiUserMenu(
        label: 'User menu',
        userName: 'Jane Smith',
        userEmail: 'jane@example.com',
        avatarInitials: 'JS',
        items: [OiMenuItem(label: 'Profile')],
      ),
    );

    await tester.tap(find.byType(OiAvatar));
    await tester.pumpAndSettle();

    expect(find.text('Jane Smith'), findsOneWidget);
    expect(find.text('jane@example.com'), findsOneWidget);
  });

  testWidgets('popover header shows userName and userEmail', (tester) async {
    await tester.pumpObers(
      const OiUserMenu(
        label: 'User menu',
        userName: 'Alice',
        userEmail: 'alice@test.org',
        avatarInitials: 'A',
        items: [],
      ),
    );

    await tester.tap(find.byType(OiAvatar));
    await tester.pumpAndSettle();

    expect(find.text('Alice'), findsOneWidget);
    expect(find.text('alice@test.org'), findsOneWidget);
  });

  testWidgets('menu items are rendered with correct labels', (tester) async {
    await tester.pumpObers(
      OiUserMenu(
        label: 'User menu',
        userName: 'Bob',
        avatarInitials: 'B',
        items: [
          OiMenuItem(label: 'Profile', icon: OiIcons.user, onTap: () {}),
          OiMenuItem(label: 'Settings', icon: OiIcons.settings, onTap: () {}),
          OiMenuItem(label: 'Logout', icon: OiIcons.logOut, onTap: () {}),
        ],
      ),
    );

    await tester.tap(find.byType(OiAvatar));
    await tester.pumpAndSettle();

    expect(find.text('Profile'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Logout'), findsOneWidget);
  });

  testWidgets('menu items have correct icons', (tester) async {
    await tester.pumpObers(
      OiUserMenu(
        label: 'User menu',
        userName: 'Bob',
        avatarInitials: 'B',
        items: [
          OiMenuItem(label: 'Profile', icon: OiIcons.user, onTap: () {}),
        ],
      ),
    );

    await tester.tap(find.byType(OiAvatar));
    await tester.pumpAndSettle();

    expect(find.byIcon(OiIcons.user), findsOneWidget);
  });

  // ── Custom header ────────────────────────────────────────────────────────

  testWidgets('custom header replaces default header', (tester) async {
    await tester.pumpObers(
      const OiUserMenu(
        label: 'User menu',
        userName: 'Bob',
        avatarInitials: 'B',
        header: Text('Custom Header'),
        items: [],
      ),
    );

    await tester.tap(find.byType(OiAvatar));
    await tester.pumpAndSettle();

    expect(find.text('Custom Header'), findsOneWidget);
  });

  // ── Edge cases ───────────────────────────────────────────────────────────

  testWidgets('empty items list renders header only', (tester) async {
    await tester.pumpObers(
      const OiUserMenu(
        label: 'User menu',
        userName: 'Alice',
        avatarInitials: 'A',
        items: [],
      ),
    );

    await tester.tap(find.byType(OiAvatar));
    await tester.pumpAndSettle();

    expect(find.text('Alice'), findsOneWidget);
  });

  // ── Accessibility ────────────────────────────────────────────────────────

  testWidgets('semantic label is present', (tester) async {
    await tester.pumpObers(
      const OiUserMenu(
        label: 'Account menu',
        userName: 'Test User',
        avatarInitials: 'TU',
        items: [],
      ),
    );

    final semanticsWidgets = tester.widgetList<Semantics>(
      find.byType(Semantics),
    );
    final matching = semanticsWidgets
        .where((s) => s.properties.label == 'Account menu')
        .toList();
    expect(matching, isNotEmpty);
  });
}
