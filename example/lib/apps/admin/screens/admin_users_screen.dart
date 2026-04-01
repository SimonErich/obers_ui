import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';

import 'package:obers_ui_example/data/mock_dashboard.dart';

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

/// Employee directory table showcasing advanced [OiTable] features:
/// grouping, column manager, striped rows, built-in pagination,
/// context menu, and a detail sheet with [OiTabs] and [OiMetadataEditor].
class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  late final List<Map<String, Object>> _employees =
      List.of(kEmployeeTableData);
  Set<String> _selectedKeys = {};
  String? _groupByField;

  // ── Employee mutations ─────────────────────────────────────────────────

  int _indexByEmail(Map<String, Object> row) =>
      _employees.indexWhere((e) => e['email'] == row['email']);

  void _setStatus(Map<String, Object> row, String status) {
    final idx = _indexByEmail(row);
    if (idx < 0) return;
    setState(() {
      _employees[idx] = {..._employees[idx], 'status': status};
    });
  }

  void _removeEmployee(Map<String, Object> row) {
    setState(() {
      _employees.removeWhere((e) => e['email'] == row['email']);
    });
  }

  Future<bool> _confirmDelete(String name) async {
    final confirmed = await showOiDialog<bool>(
      context,
      builder: (context, close) => OiDialog.confirm(
        label: 'Confirm deletion',
        title: 'Delete user',
        content: Text(
          'Are you sure you want to delete $name? '
          'This action cannot be undone.',
        ),
        actions: [
          OiButton.ghost(label: 'Cancel', onTap: () => close(false)),
          OiButton.destructive(label: 'Delete', onTap: () => close(true)),
        ],
      ),
    );
    return confirmed == true;
  }

  // ── Context menu ──────────────────────────────────────────────────────

  List<OiMenuItem> _rowMenuItems(Map<String, Object> row) {
    final isActive = row['status'] == 'active';

    return [
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
        label: isActive ? 'Deactivate' : 'Activate',
        icon: isActive ? OiIcons.ban : OiIcons.check,
        onTap: () {
          final newStatus = isActive ? 'inactive' : 'active';
          _setStatus(row, newStatus);
          OiToast.show(
            context,
            message: '${row['name']} ${isActive ? 'deactivated' : 'activated'}',
            level: isActive ? OiToastLevel.warning : OiToastLevel.success,
          );
        },
      ),
      OiMenuItem(
        label: 'Delete',
        icon: OiIcons.trash2,
        onTap: () async {
          if (!await _confirmDelete(row['name']! as String)) return;
          _removeEmployee(row);
          OiToast.show(
            context,
            message: '${row['name']} removed',
            level: OiToastLevel.error,
          );
        },
      ),
    ];
  }

  // ── Detail sheet ──────────────────────────────────────────────────────

  void _showUserDetail(Map<String, Object> row) {
    OiSheet.show(
      context,
      label: 'User details: ${row['name']}',
      side: OiPanelSide.right,
      size: 440,
      child: _UserDetailSheet(row: row),
    );
  }

  // ── Columns ───────────────────────────────────────────────────────────

  List<OiTableColumn<Map<String, Object>>> get _columns => [
    OiTableColumn(
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
    OiTableColumn(
      id: 'name',
      header: 'Name',
      width: 180,
      valueGetter: (row) => row['name']! as String,
    ),
    OiTableColumn(
      id: 'role',
      header: 'Role',
      width: 160,
      valueGetter: (row) => row['role']! as String,
    ),
    OiTableColumn(
      id: 'department',
      header: 'Department',
      width: 140,
      valueGetter: (row) => row['department']! as String,
    ),
    OiTableColumn(
      id: 'status',
      header: 'Status',
      width: 100,
      valueGetter: (row) => row['status']! as String,
      cellBuilder: (_, row, __) {
        final status = row['status']! as String;
        return OiBadge.soft(
          label: status[0].toUpperCase() + status.substring(1),
          color: _statusColor(status),
        );
      },
    ),
    OiTableColumn(
      id: 'email',
      header: 'Email',
      width: 200,
      valueGetter: (row) => row['email']! as String,
    ),
    OiTableColumn(
      id: 'location',
      header: 'Location',
      width: 120,
      valueGetter: (row) => row['location']! as String,
    ),
    OiTableColumn(
      id: 'joined',
      header: 'Joined',
      width: 120,
      valueGetter: (row) => row['joined']! as String,
    ),
    OiTableColumn(
      id: 'ordersProcessed',
      header: 'Orders',
      width: 70,
      valueGetter: (row) => '${row['ordersProcessed']}',
    ),
    OiTableColumn(
      id: 'actions',
      header: '',
      sortable: false,
      filterable: false,
      resizable: false,
      cellBuilder: (_, row, __) => OiContextMenu(
        label: 'Actions for ${row['name']}',
        items: _rowMenuItems(row),
        child: const Padding(
          padding: EdgeInsets.all(8.0),
          child: Icon(OiIcons.ellipsisVertical, size: 18),
        ),
      ),
    ),
  ];

  // ── Bulk actions ──────────────────────────────────────────────────────

  List<OiBulkAction> get _bulkActions => [
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
      onTap: () async {
        final count = _selectedKeys.length;
        final confirmed = await _confirmDelete('$count users');
        if (!confirmed) return;
        setState(() {
          _employees.removeWhere(
            (e) => _selectedKeys.contains(e['email']! as String),
          );
          _selectedKeys = {};
        });
        OiToast.show(
          context,
          message: '$count users removed',
          level: OiToastLevel.error,
        );
      },
      variant: OiBulkActionVariant.destructive,
    ),
  ];

  // ── Build ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;

    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(spacing.md, spacing.md, spacing.md, 0),
              child: Row(
                children: [
                  const OiLabel.bodyStrong('Group by: '),
                  SizedBox(width: spacing.sm),
                  for (final field in [null, 'department', 'status'])
                    Padding(
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
                ],
              ),
            ),
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
                  onSelectionChanged: (keys) =>
                      setState(() => _selectedKeys = keys),
                  columns: _columns,
                ),
              ),
            ),
          ],
        ),
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
              actions: _bulkActions,
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
    const OiMetadataField(key: 'Contract Type', value: 'Full-time'),
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(spacing.md, spacing.md, spacing.md, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              OiTabs(
                tabs: const [
                  OiTabItem(label: 'Profile'),
                  OiTabItem(label: 'Metadata'),
                ],
                selectedIndex: _tabIndex,
                onSelected: (i) => setState(() => _tabIndex = i),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(spacing.md),
            child: _tabIndex == 0
                ? OiDetailView(
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
                          OiDetailField(
                            label: 'Location',
                            value: row['location'],
                          ),
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
                  )
                : OiMetadataEditor(
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
          ),
        ),
      ],
    );
  }
}
