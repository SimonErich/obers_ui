import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';

/// A permission in the matrix.
///
/// Represents a single permission that can be granted to roles.
class OiPermissionItem {
  /// Creates an [OiPermissionItem].
  const OiPermissionItem({
    required this.key,
    required this.label,
    this.description,
  });

  /// Unique identifier for this permission.
  final String key;

  /// Human-readable label for the permission.
  final String label;

  /// Optional description providing more detail.
  final String? description;
}

/// A role in the permission matrix.
///
/// Represents a role that can be granted permissions.
class OiRole {
  /// Creates an [OiRole].
  const OiRole({
    required this.key,
    required this.label,
    this.description,
    this.color,
  });

  /// Unique identifier for this role.
  final String key;

  /// Human-readable label for the role.
  final String label;

  /// Optional description providing more detail.
  final String? description;

  /// Optional color used for visual distinction.
  final Color? color;
}

/// A role-based permission matrix editor.
///
/// Renders permissions as rows and roles as columns with checkboxes at
/// intersections. Toggling a checkbox adds or removes the permission from
/// the role and fires [onChange] with the updated matrix.
///
/// {@category Modules}
class OiPermissions extends StatelessWidget {
  /// Creates an [OiPermissions].
  const OiPermissions({
    required this.permissions, required this.roles, required this.matrix, required this.onChange, required this.label, super.key,
    this.enabled = true,
  });

  /// The list of permissions (rows).
  final List<OiPermissionItem> permissions;

  /// The list of roles (columns).
  final List<OiRole> roles;

  /// The permission matrix: role key to set of granted permission keys.
  final Map<String, Set<String>> matrix;

  /// Called when a permission is toggled with the full updated matrix.
  final ValueChanged<Map<String, Set<String>>> onChange;

  /// Accessibility label for the permission matrix.
  final String label;

  /// Whether the matrix is editable.
  final bool enabled;

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  bool _isGranted(String roleKey, String permissionKey) {
    return matrix[roleKey]?.contains(permissionKey) ?? false;
  }

  void _toggle(String roleKey, String permissionKey) {
    if (!enabled) return;
    final updated = <String, Set<String>>{};
    for (final entry in matrix.entries) {
      updated[entry.key] = Set<String>.of(entry.value);
    }
    final rolePerms = updated.putIfAbsent(roleKey, () => <String>{});
    if (rolePerms.contains(permissionKey)) {
      rolePerms.remove(permissionKey);
    } else {
      rolePerms.add(permissionKey);
    }
    onChange(updated);
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;

    if (permissions.isEmpty || roles.isEmpty) {
      return Semantics(
        label: label,
        child: Center(
          child: Text(
            'No permissions configured',
            style: TextStyle(color: colors.textMuted),
          ),
        ),
      );
    }

    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: label,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with role names
              Row(
                children: [
                  // Empty top-left corner
                  SizedBox(
                    width: 200,
                    child: Padding(
                      padding: EdgeInsets.all(spacing.sm),
                      child: Text(
                        'Permission',
                        style: TextStyle(
                          color: colors.textMuted,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  for (final role in roles)
                    SizedBox(
                      width: 120,
                      child: Padding(
                        padding: EdgeInsets.all(spacing.sm),
                        child: Text(
                          role.label,
                          style: TextStyle(
                            color: role.color ?? colors.text,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),

              // Divider
              Container(
                height: 1,
                color: colors.borderSubtle,
                width: 200.0 + roles.length * 120.0,
              ),

              // Permission rows
              for (final permission in permissions)
                _buildPermissionRow(context, permission),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionRow(
    BuildContext context,
    OiPermissionItem permission,
  ) {
    final colors = context.colors;
    final spacing = context.spacing;

    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: colors.borderSubtle)),
      ),
      child: Row(
        children: [
          // Permission label
          SizedBox(
            width: 200,
            child: Padding(
              padding: EdgeInsets.all(spacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    permission.label,
                    style: TextStyle(color: colors.text, fontSize: 13),
                  ),
                  if (permission.description != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        permission.description!,
                        style: TextStyle(color: colors.textMuted, fontSize: 11),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Checkbox for each role
          for (final role in roles)
            SizedBox(
              width: 120,
              child: Center(
                child: GestureDetector(
                  onTap: enabled
                      ? () => _toggle(role.key, permission.key)
                      : null,
                  child: Semantics(
                    container: true,
                    explicitChildNodes: true,
                    label: '${permission.label} for ${role.label}',
                    toggled: _isGranted(role.key, permission.key),
                    child: _OiCheckbox(
                      checked: _isGranted(role.key, permission.key),
                      enabled: enabled,
                      color: role.color,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// A simple checkbox used within the permissions matrix.
class _OiCheckbox extends StatelessWidget {
  const _OiCheckbox({required this.checked, required this.enabled, this.color});

  /// Whether the checkbox is checked.
  final bool checked;

  /// Whether the checkbox is interactive.
  final bool enabled;

  /// Optional accent color.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final effectiveColor = color ?? colors.primary.base;

    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: checked ? effectiveColor : null,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: checked
              ? effectiveColor
              : enabled
              ? colors.border
              : colors.borderSubtle,
          width: 2,
        ),
      ),
      child: checked
          ? Center(
              child: Icon(
                const IconData(0xe876, fontFamily: 'MaterialIcons'),
                size: 14,
                color: colors.textOnPrimary,
              ),
            )
          : null,
    );
  }
}
