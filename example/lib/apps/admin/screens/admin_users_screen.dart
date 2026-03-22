import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';

import 'package:obers_ui_example/data/mock_dashboard.dart';

/// Employee directory table with sortable columns.
class AdminUsersScreen extends StatelessWidget {
  const AdminUsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;

    return Padding(
      padding: EdgeInsets.all(spacing.md),
      child: OiTable<Map<String, Object>>(
        label: 'Employee directory',
        rows: kEmployeeTableData,
        columns: [
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
            id: 'email',
            header: 'Email',
            valueGetter: (row) => row['email']! as String,
          ),
          OiTableColumn<Map<String, Object>>(
            id: 'joined',
            header: 'Joined',
            valueGetter: (row) => row['joined']! as String,
          ),
        ],
        onRowTap: (row, index) {
          debugPrint('Tapped user: ${row['name']} at index $index');
        },
      ),
    );
  }
}
