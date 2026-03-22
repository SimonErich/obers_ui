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

  bool _hasChanges = false;

  void _save() {
    setState(() => _hasChanges = false);
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
                    const OiLabel.caption(
                      'Manage what each role can access across the system.',
                    ),
                  ],
                ),
              ),
              OiButton.primary(
                label: 'Save Changes',
                icon: OiIcons.check,
                onTap: _hasChanges ? _save : null,
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
            matrix: _matrix,
            onChange: (updated) {
              setState(() {
                _matrix = updated;
                _hasChanges = true;
              });
            },
          ),
        ],
      ),
    );
  }
}
