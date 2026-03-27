// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/foundation/oi_icons.dart';
import 'package:obers_ui/src/modules/oi_permissions.dart';

import '../../helpers/pump_app.dart';

void main() {
  final permissions = [
    const OiPermissionItem(key: 'read', label: 'Read'),
    const OiPermissionItem(
      key: 'write',
      label: 'Write',
      description: 'Create and edit',
    ),
    const OiPermissionItem(key: 'delete', label: 'Delete'),
  ];

  final roles = [
    const OiRole(key: 'admin', label: 'Admin'),
    const OiRole(key: 'editor', label: 'Editor'),
    const OiRole(key: 'viewer', label: 'Viewer'),
  ];

  testWidgets('permissions render as rows', (tester) async {
    await tester.pumpObers(
      SizedBox(
        width: 800,
        height: 600,
        child: OiPermissions(
          permissions: permissions,
          roles: roles,
          matrix: const {
            'admin': {'read', 'write', 'delete'},
          },
          onChange: (_) {},
          label: 'Permissions',
        ),
      ),
    );
    expect(find.text('Read'), findsOneWidget);
    expect(find.text('Write'), findsOneWidget);
    expect(find.text('Delete'), findsOneWidget);
  });

  testWidgets('roles render as columns', (tester) async {
    await tester.pumpObers(
      SizedBox(
        width: 800,
        height: 600,
        child: OiPermissions(
          permissions: permissions,
          roles: roles,
          matrix: const {},
          onChange: (_) {},
          label: 'Permissions',
        ),
      ),
    );
    expect(find.text('Admin'), findsOneWidget);
    expect(find.text('Editor'), findsOneWidget);
    expect(find.text('Viewer'), findsOneWidget);
  });

  testWidgets('checkboxes render at intersections', (tester) async {
    await tester.pumpObers(
      SizedBox(
        width: 800,
        height: 600,
        child: OiPermissions(
          permissions: permissions,
          roles: roles,
          matrix: const {},
          onChange: (_) {},
          label: 'Permissions',
        ),
      ),
    );
    // 3 permissions x 3 roles = 9 checkboxes (each is a 20x20 Container)
    // Check that the check icon (0xe876) does not appear for unchecked
    expect(find.byIcon(OiIcons.check), findsNothing);
  });

  testWidgets('checked permissions show check icon', (tester) async {
    await tester.pumpObers(
      SizedBox(
        width: 800,
        height: 600,
        child: OiPermissions(
          permissions: permissions,
          roles: roles,
          matrix: const {
            'admin': {'read', 'write', 'delete'},
          },
          onChange: (_) {},
          label: 'Permissions',
        ),
      ),
    );
    // Admin has 3 permissions checked
    expect(find.byIcon(OiIcons.check), findsNWidgets(3));
  });

  testWidgets('toggling fires onChange with updated matrix', (tester) async {
    Map<String, Set<String>>? result;

    await tester.pumpObers(
      SizedBox(
        width: 800,
        height: 600,
        child: OiPermissions(
          permissions: const [OiPermissionItem(key: 'read', label: 'Read')],
          roles: const [OiRole(key: 'admin', label: 'Admin')],
          matrix: const {},
          onChange: (m) => result = m,
          label: 'Permissions',
        ),
      ),
    );

    // Find and tap the checkbox area (the GestureDetector wrapping the checkbox)
    await tester.tap(find.bySemanticsLabel('Read for Admin'));
    await tester.pump();

    expect(result, isNotNull);
    expect(result!['admin'], contains('read'));
  });

  testWidgets('disabled blocks toggling', (tester) async {
    Map<String, Set<String>>? result;

    await tester.pumpObers(
      SizedBox(
        width: 800,
        height: 600,
        child: OiPermissions(
          permissions: const [OiPermissionItem(key: 'read', label: 'Read')],
          roles: const [OiRole(key: 'admin', label: 'Admin')],
          matrix: const {},
          onChange: (m) => result = m,
          label: 'Permissions',
          enabled: false,
        ),
      ),
    );

    await tester.tap(find.bySemanticsLabel('Read for Admin'));
    await tester.pump();

    // onChange should not have been called
    expect(result, isNull);
  });

  testWidgets('empty permissions shows placeholder', (tester) async {
    await tester.pumpObers(
      SizedBox(
        width: 800,
        height: 600,
        child: OiPermissions(
          permissions: const [],
          roles: roles,
          matrix: const {},
          onChange: (_) {},
          label: 'Permissions',
        ),
      ),
    );
    expect(find.text('No permissions configured'), findsOneWidget);
  });

  testWidgets('empty roles shows placeholder', (tester) async {
    await tester.pumpObers(
      SizedBox(
        width: 800,
        height: 600,
        child: OiPermissions(
          permissions: permissions,
          roles: const [],
          matrix: const {},
          onChange: (_) {},
          label: 'Permissions',
        ),
      ),
    );
    expect(find.text('No permissions configured'), findsOneWidget);
  });

  testWidgets('has semantics label', (tester) async {
    await tester.pumpObers(
      SizedBox(
        width: 800,
        height: 600,
        child: OiPermissions(
          permissions: const [],
          roles: const [],
          matrix: const {},
          onChange: (_) {},
          label: 'Role Matrix',
        ),
      ),
    );
    final semanticsWidgets = tester.widgetList<Semantics>(
      find.byType(Semantics),
    );
    final matching = semanticsWidgets
        .where(
          (s) =>
              s.properties.label != null &&
              s.properties.label!.contains('Role Matrix'),
        )
        .toList();
    expect(matching, isNotEmpty);
  });

  testWidgets('permission description renders when provided', (tester) async {
    await tester.pumpObers(
      SizedBox(
        width: 800,
        height: 600,
        child: OiPermissions(
          permissions: const [
            OiPermissionItem(
              key: 'write',
              label: 'Write',
              description: 'Create and edit',
            ),
          ],
          roles: const [OiRole(key: 'admin', label: 'Admin')],
          matrix: const {},
          onChange: (_) {},
          label: 'Permissions',
        ),
      ),
    );
    expect(find.text('Create and edit'), findsOneWidget);
  });
}
