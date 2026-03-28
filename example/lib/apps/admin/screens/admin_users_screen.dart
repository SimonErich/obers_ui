import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';

import 'package:obers_ui_example/data/mock_dashboard.dart';

/// Employee directory table showcasing advanced [OiTable] features:
/// grouping, column manager, striped rows, built-in pagination,
/// context menu, and a detail sheet with [OiTabs] and [OiMetadataEditor].
class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  late final List<Map<String, Object>> _employees = List.of(kEmployeeTableData);
  Set<String> _selectedKeys = {};
  String? _groupByField;

  String _initialsFrom(String name) {
    final parts = name.split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}';
    return parts[0][0];
  }

  OiBadgeColor _statusColor(String status) => switch (status) {
    'active' => OiBadgeColor.success,
    'on-leave' => OiBadgeColor.warning,
    'inactive' => OiBadgeColor.error,
    _ => OiBadgeColor.neutral,
  };

  // ── Context menu ────────────────────────────────────────────────────────

  List<OiMenuItem> _rowMenuItems(Map<String, Object> row) => [
        OiMenuItem(
          label: 'View Details',
          icon: OiIcons.eye,
          onTap: () => _showUserDetail(row),
        ),
        OiMenuItem(
          label: 'Send Email',
          icon: OiIcons.mail,
          onTap: () => OiToast.show(
            context,
            message: 'Email sent to ${row['name']}',
          ),
        ),
        const OiMenuDivider(),
        OiMenuItem(
          label: 'Deactivate',
          icon: OiIcons.ban,
          onTap: () {
            setState(() {
              final idx = _employees.indexWhere(
                (e) => e['email'] == row['email'],
              );
              if (idx >= 0) {
                _employees[idx] = {..._employees[idx], 'status': 'inactive'};
              }
            });
            OiToast.show(
              context,
              message: '${row['name']} deactivated',
              level: OiToastLevel.warning,
            );
          },
        ),
        OiMenuItem(
          label: 'Delete',
          icon: OiIcons.trash2,
          onTap: () {
            setState(() {
              _employees.removeWhere((e) => e['email'] == row['email']);
            });
            OiToast.show(
              context,
              message: '${row['name']} removed',
              level: OiToastLevel.error,
            );
          },
        ),
      ];

  // ── Detail sheet ────────────────────────────────────────────────────────

  void _showUserDetail(Map<String, Object> row) {
    OiSheet.show(
      context,
      label: 'User details: ${row['name']}',
      side: OiPanelSide.right,
      size: 440,
      child: _UserDetailSheet(row: row),
    );
  }

  // ── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;

    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Group-by toggle
            Padding(
              padding: EdgeInsets.fromLTRB(
                spacing.md,
                spacing.md,
                spacing.md,
                0,
              ),
              child: Row(
                children: [
                  const OiLabel.bodyStrong('Group by: '),
                  SizedBox(width: spacing.sm),
                  ...[null, 'department', 'status'].map(
                    (field) => Padding(
                      padding: EdgeInsets.only(right: spacing.xs),
                      child: _groupByField == field
                          ? OiButton.primary(
                              label: field ?? 'None',
                              onTap: () =>
                                  setState(() => _groupByField = field),
                              size: OiButtonSize.small,
                            )
                          : OiButton.ghost(
                              label: field ?? 'None',
                              onTap: () =>
                                  setState(() => _groupByField = field),
                              size: OiButtonSize.small,
                            ),
                    ),
                  ),
                ],
              ),
            ),

            // Table
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(spacing.md),
                child: OiTable<Map<String, Object>>(
                  label: 'Employee directory',
                  rows: _employees,
                  selectable: true,
                  multiSelect: true,
                  striped: true,
                  showColumnManager: true,
                  paginationMode: OiTablePaginationMode.pages,
                  pageSizeOptions: const [5, 10, 25],
                  rowKey: (row) => row['email']! as String,
                  groupBy: _groupByField,
                  onSelectionChanged: (keys) {
                    setState(() => _selectedKeys = keys);
                  },
                  onRowTap: (row, index) => _showUserDetail(row),
                  columns: [
                    OiTableColumn<Map<String, Object>>(
                      id: 'avatar',
                      header: '',
                      width: 48,
                      sortable: false,
                      filterable: false,
                      resizable: false,
                      cellBuilder: (context, row, _) => OiAvatar(
                        semanticLabel: row['name']! as String,
                        initials: _initialsFrom(row['name']! as String),
                        size: OiAvatarSize.sm,
                      ),
                    ),
                    OiTableColumn<Map<String, Object>>(
                      id: 'name',
                      header: 'Name',
                      valueGetter: (row) => row['name']! as String,
                    ),
                    OiTableColumn<Map<String, Object>>(
                      id: 'role',
                      header: 'Role',
                      valueGetter: (row) => row['role']! as String,
                    ),
                    OiTableColumn<Map<String, Object>>(
                      id: 'department',
                      header: 'Department',
                      valueGetter: (row) => row['department']! as String,
                    ),
                    OiTableColumn<Map<String, Object>>(
                      id: 'status',
                      header: 'Status',
                      valueGetter: (row) => row['status']! as String,
                      cellBuilder: (ctx, row, _) {
                        final status = row['status']! as String;
                        return OiBadge.soft(
                          label: status[0].toUpperCase() + status.substring(1),
                          color: _statusColor(status),
                        );
                      },
                    ),
                    OiTableColumn<Map<String, Object>>(
                      id: 'email',
                      header: 'Email',
                      valueGetter: (row) => row['email']! as String,
                    ),
                    OiTableColumn<Map<String, Object>>(
                      id: 'location',
                      header: 'Location',
                      valueGetter: (row) => row['location']! as String,
                    ),
                    OiTableColumn<Map<String, Object>>(
                      id: 'joined',
                      header: 'Joined',
                      valueGetter: (row) => row['joined']! as String,
                    ),
                    OiTableColumn<Map<String, Object>>(
                      id: 'ordersProcessed',
                      header: 'Orders',
                      valueGetter: (row) => '${row['ordersProcessed']}',
                    ),
                    // Actions column with context menu.
                    OiTableColumn<Map<String, Object>>(
                      id: 'actions',
                      header: '',
                      sortable: false,
                      filterable: false,
                      resizable: false,
                      cellBuilder: (ctx, row, _) => OiContextMenu(
                        label: 'Actions for ${row['name']}',
                        items: _rowMenuItems(row),
                        child: const Icon(OiIcons.ellipsisVertical, size: 18),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        // Bulk action bar.
        if (_selectedKeys.isNotEmpty)
          Positioned(
            bottom: spacing.lg + 48,
            left: spacing.lg,
            right: spacing.lg,
            child: OiBulkBar(
              selectedCount: _selectedKeys.length,
              totalCount: _employees.length,
              label: 'users',
              onSelectAll: () {
                setState(() {
                  _selectedKeys =
                      _employees.map((r) => r['email']! as String).toSet();
                });
              },
              onDeselectAll: () => setState(() => _selectedKeys = {}),
              actions: [
                OiBulkAction(
                  label: 'Export',
                  icon: OiIcons.download,
                  onTap: () {
                    OiToast.show(
                      context,
                      message: 'Exported ${_selectedKeys.length} users',
                      level: OiToastLevel.success,
                    );
                    setState(() => _selectedKeys = {});
                  },
                ),
                OiBulkAction(
                  label: 'Delete',
                  icon: OiIcons.trash2,
                  onTap: () {
                    setState(() {
                      _employees.removeWhere(
                        (e) => _selectedKeys.contains(e['email']! as String),
                      );
                      _selectedKeys = {};
                    });
                  },
                  variant: OiBulkActionVariant.destructive,
                ),
              ],
            ),
          ),
      ],
    );
  }
}

// ── Detail sheet with tabs ──────────────────────────────────────────────────

class _UserDetailSheet extends StatefulWidget {
  const _UserDetailSheet({required this.row});
  final Map<String, Object> row;

  @override
  State<_UserDetailSheet> createState() => _UserDetailSheetState();
}

class _UserDetailSheetState extends State<_UserDetailSheet> {
  int _tabIndex = 0;
  late List<OiMetadataField> _metadata = [
    const OiMetadataField(key: 'Employee ID', value: 'EMP-2026-042'),
    const OiMetadataField(
      key: 'Contract Type',
      value: 'Full-time',
    ),
    const OiMetadataField(
      key: 'Remote Eligible',
      value: true,
      type: OiMetadataType.boolean,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final row = widget.row;

    return SingleChildScrollView(
      padding: EdgeInsets.all(spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with avatar.
          Row(
            children: [
              OiAvatar(
                semanticLabel: row['name']! as String,
                initials: _initialsFrom(row['name']! as String),
                size: OiAvatarSize.lg,
              ),
              SizedBox(width: spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    OiLabel.h4(row['name']! as String),
                    SizedBox(height: spacing.xs),
                    OiLabel.caption(row['role']! as String),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: spacing.lg),

          // Tabs.
          OiTabs(
            tabs: const [
              OiTabItem(label: 'Profile'),
              OiTabItem(label: 'Metadata'),
            ],
            selectedIndex: _tabIndex,
            onSelected: (i) => setState(() => _tabIndex = i),
          ),
          SizedBox(height: spacing.md),

          if (_tabIndex == 0) ...[
            OiDetailView(
              label: 'Profile details',
              sections: [
                OiDetailSection(
                  title: 'Contact',
                  fields: [
                    OiDetailField(label: 'Name', value: row['name']),
                    OiDetailField(
                      label: 'Email',
                      value: row['email'],
                      type: OiFieldType.email,
                    ),
                    OiDetailField(label: 'Phone', value: row['phone']),
                    OiDetailField(label: 'Location', value: row['location']),
                  ],
                ),
                OiDetailSection(
                  title: 'Work',
                  fields: [
                    OiDetailField(label: 'Role', value: row['role']),
                    OiDetailField(
                      label: 'Department',
                      value: row['department'],
                    ),
                    OiDetailField(label: 'Status', value: row['status']),
                    OiDetailField(label: 'Joined', value: row['joined']),
                    OiDetailField(
                      label: 'Orders Processed',
                      value: '${row['ordersProcessed']}',
                    ),
                  ],
                ),
              ],
            ),
          ] else ...[
            OiMetadataEditor(
              label: 'Employee metadata',
              fields: _metadata,
              availableKeys: const [
                'Employee ID',
                'Contract Type',
                'Remote Eligible',
                'Team Lead',
                'Start Date',
                'Notes',
              ],
              onChange: (fields) => setState(() => _metadata = fields),
            ),
          ],
        ],
      ),
    );
  }

  String _initialsFrom(String name) {
    final parts = name.split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}';
    return parts[0][0];
  }
}
