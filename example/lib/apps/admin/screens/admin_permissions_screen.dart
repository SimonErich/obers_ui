import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';

import 'package:obers_ui_example/data/mock_dashboard.dart';

/// Showcases [OiPermissions] — a role-based permission matrix editor.
class AdminPermissionsScreen extends StatefulWidget {
  const AdminPermissionsScreen({super.key});

  @override
  State<AdminPermissionsScreen> createState() => _AdminPermissionsScreenState();
}

class _AdminPermissionsScreenState extends State<AdminPermissionsScreen> {
  late Map<String, Set<String>> _matrix = {
    for (final entry in kMockPermissionMatrix.entries)
      entry.key: Set<String>.of(entry.value),
  };

  late Map<String, Set<String>> _savedMatrix = {
    for (final entry in _matrix.entries)
      entry.key: Set<String>.of(entry.value),
  };

  bool _editing = false;

  void _startEditing() {
    setState(() {
      _savedMatrix = {
        for (final entry in _matrix.entries)
          entry.key: Set<String>.of(entry.value),
      };
      _editing = true;
    });
  }

  void _cancel() {
    setState(() {
      _matrix = {
        for (final entry in _savedMatrix.entries)
          entry.key: Set<String>.of(entry.value),
      };
      _editing = false;
    });
  }

  void _save() {
    setState(() => _editing = false);
    OiToast.show(
      context,
      message: 'Permissions saved successfully',
      level: OiToastLevel.success,
    );
  }

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;

    return SingleChildScrollView(
      padding: EdgeInsets.all(spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const OiLabel.h3('Roles & Permissions'),
                    SizedBox(height: spacing.xs),
                    const OiLabel.small(
                      'Manage what each role can access across the system.',
                    ),
                  ],
                ),
              ),
              if (_editing) ...[
                OiButton.ghost(
                  label: 'Cancel',
                  onTap: _cancel,
                ),
                SizedBox(width: spacing.sm),
                OiButton.primary(
                  label: 'Save',
                  icon: OiIcons.check,
                  onTap: _save,
                ),
              ] else
                OiButton.primary(
                  label: 'Edit',
                  icon: OiIcons.pencil,
                  onTap: _startEditing,
                ),
            ],
          ),
          SizedBox(height: spacing.lg),
          OiPermissions(
            label: 'Permission matrix',
            permissions: [
              for (final p in kMockPermissions)
                OiPermissionItem(
                  key: p.key,
                  label: p.label,
                  description: p.description,
                ),
            ],
            roles: [
              for (final r in kMockRoles)
                OiRole(
                  key: r.key,
                  label: r.label,
                  description: r.description,
                  color: Color(r.color),
                ),
            ],
            enabled: _editing,
            matrix: _matrix,
            onChange: (updated) {
              setState(() {
                _matrix = updated;
              });
            },
          ),
        ],
      ),
    );
  }
}
