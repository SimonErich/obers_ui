import 'package:flutter/material.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:widgetbook/widgetbook.dart';

import '../helpers/knob_helpers.dart';

const _samplePermissions = [
  OiPermissionItem(
    key: 'read',
    label: 'Read',
    description: 'View resources and data',
  ),
  OiPermissionItem(
    key: 'write',
    label: 'Write',
    description: 'Create and edit resources',
  ),
  OiPermissionItem(
    key: 'delete',
    label: 'Delete',
    description: 'Remove resources permanently',
  ),
  OiPermissionItem(
    key: 'admin',
    label: 'Admin',
    description: 'Manage users and settings',
  ),
  OiPermissionItem(
    key: 'audit',
    label: 'Audit Log',
    description: 'View activity and audit trails',
  ),
];

const _sampleRoles = [
  OiRole(key: 'viewer', label: 'Viewer', color: Colors.blue),
  OiRole(key: 'editor', label: 'Editor', color: Colors.orange),
  OiRole(key: 'admin', label: 'Admin', color: Colors.red),
];

const _sampleMatrix = <String, Set<String>>{
  'viewer': {'read'},
  'editor': {'read', 'write'},
  'admin': {'read', 'write', 'delete', 'admin', 'audit'},
};

final oiPermissionsComponent = WidgetbookComponent(
  name: 'OiPermissions',
  useCases: [
    WidgetbookUseCase(
      name: 'Playground',
      builder: (context) {
        final enabled = context.knobs.boolean(
          label: 'Enabled',
          initialValue: true,
        );

        return useCaseWrapper(
          SizedBox(
            height: 500,
            width: 600,
            child: OiPermissions(
              permissions: _samplePermissions,
              roles: _sampleRoles,
              matrix: _sampleMatrix,
              onChange: (_) {},
              label: 'Permission matrix',
              enabled: enabled,
            ),
          ),
        );
      },
    ),
    WidgetbookUseCase(
      name: 'Read Only',
      builder: (context) {
        return useCaseWrapper(
          SizedBox(
            height: 500,
            width: 600,
            child: OiPermissions(
              permissions: _samplePermissions,
              roles: _sampleRoles,
              matrix: _sampleMatrix,
              onChange: (_) {},
              label: 'Read-only permission matrix',
              enabled: false,
            ),
          ),
        );
      },
    ),
  ],
);
