import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';

import 'package:obers_ui_example/apps/component_library/shared/component_showcase_section.dart';

/// Showcase screen for table, tree, and detail view widgets.
class TablesTreesScreen extends StatefulWidget {
  const TablesTreesScreen({super.key});

  @override
  State<TablesTreesScreen> createState() => _TablesTreesScreenState();
}

class _TablesTreesScreenState extends State<TablesTreesScreen> {
  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;

    return SingleChildScrollView(
      padding: EdgeInsets.all(spacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const OiLabel.h2('Tables & Trees'),
          SizedBox(height: spacing.lg),

          // ── OiTable ────────────────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Table',
            widgetName: 'OiTable',
            description:
                'A full-featured data table with sorting, filtering, column management, and pagination.',
            examples: [
              ComponentExample(
                title: 'Simple table',
                child: SizedBox(
                  height: 400,
                  child: OiTable<Map<String, String>>(
                    label: 'Users table',
                    columns: [
                      OiTableColumn<Map<String, String>>(
                        id: 'name',
                        header: 'Name',
                        valueGetter: (row) => row['name'] ?? '',
                      ),
                      OiTableColumn<Map<String, String>>(
                        id: 'email',
                        header: 'Email',
                        valueGetter: (row) => row['email'] ?? '',
                      ),
                      OiTableColumn<Map<String, String>>(
                        id: 'role',
                        header: 'Role',
                        valueGetter: (row) => row['role'] ?? '',
                        cellBuilder: (context, row, _) =>
                            OiBadge.soft(label: row['role'] ?? ''),
                      ),
                    ],
                    rows: const [
                      {
                        'name': 'Alice Johnson',
                        'email': 'alice@example.com',
                        'role': 'Admin',
                      },
                      {
                        'name': 'Bob Smith',
                        'email': 'bob@example.com',
                        'role': 'Editor',
                      },
                      {
                        'name': 'Carol Lee',
                        'email': 'carol@example.com',
                        'role': 'Viewer',
                      },
                      {
                        'name': 'Dan Wilson',
                        'email': 'dan@example.com',
                        'role': 'Editor',
                      },
                      {
                        'name': 'Eve Chen',
                        'email': 'eve@example.com',
                        'role': 'Admin',
                      },
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ── OiTree ─────────────────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Tree',
            widgetName: 'OiTree',
            description:
                'A hierarchical tree view with expand/collapse, selection, and custom node builders.',
            examples: [
              ComponentExample(
                title: 'File tree',
                child: SizedBox(
                  height: 300,
                  child: OiTree<String>(
                    label: 'File tree',
                    nodes: const [
                      OiTreeNode(
                        id: 'src',
                        label: 'src',
                        children: [
                          OiTreeNode(
                            id: 'components',
                            label: 'components',
                            children: [
                              OiTreeNode(id: 'button', label: 'button.dart'),
                              OiTreeNode(id: 'card', label: 'card.dart'),
                              OiTreeNode(id: 'input', label: 'input.dart'),
                            ],
                          ),
                          OiTreeNode(
                            id: 'utils',
                            label: 'utils',
                            children: [
                              OiTreeNode(id: 'helpers', label: 'helpers.dart'),
                            ],
                          ),
                        ],
                      ),
                      OiTreeNode(
                        id: 'test',
                        label: 'test',
                        children: [
                          OiTreeNode(
                            id: 'widget_test',
                            label: 'widget_test.dart',
                          ),
                        ],
                      ),
                      OiTreeNode(id: 'pubspec', label: 'pubspec.yaml'),
                    ],
                    selectable: true,
                    showLines: true,
                    onNodeTap: (_) {},
                  ),
                ),
              ),
            ],
          ),

          // ── OiDetailView ───────────────────────────────────────────────
          const ComponentShowcaseSection(
            title: 'Detail View',
            widgetName: 'OiDetailView',
            description:
                'A read-only record detail layout with label/value pairs grouped into sections.',
            examples: [
              ComponentExample(
                title: 'User details',
                child: OiDetailView(
                  label: 'User details',
                  columns: 2,
                  sections: [
                    OiDetailSection(
                      title: 'Personal Information',
                      fields: [
                        OiDetailField(label: 'Name', value: 'John Doe'),
                        OiDetailField(
                          label: 'Email',
                          value: 'john@example.com',
                        ),
                        OiDetailField(label: 'Phone', value: '+1 555-0123'),
                        OiDetailField(
                          label: 'Location',
                          value: 'San Francisco, CA',
                        ),
                      ],
                    ),
                    OiDetailSection(
                      title: 'Account',
                      fields: [
                        OiDetailField(label: 'Role', value: 'Administrator'),
                        OiDetailField(label: 'Status', value: 'Active'),
                        OiDetailField(label: 'Joined', value: '2024-01-15'),
                        OiDetailField(label: 'Last login', value: '2026-03-22'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
