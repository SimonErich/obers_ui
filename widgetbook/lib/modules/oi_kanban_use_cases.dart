import 'package:flutter/material.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_widgetbook/helpers/knob_helpers.dart';
import 'package:widgetbook/widgetbook.dart';

final _sampleColumns = [
  const OiKanbanColumn<String>(
    key: 'backlog',
    title: 'Backlog',
    color: Colors.grey,
    items: ['Set up CI pipeline', 'Write API docs'],
  ),
  const OiKanbanColumn<String>(
    key: 'todo',
    title: 'To Do',
    color: Colors.blue,
    items: ['Design login screen', 'Implement auth flow'],
  ),
  const OiKanbanColumn<String>(
    key: 'in-progress',
    title: 'In Progress',
    color: Colors.orange,
    items: ['Build dashboard module'],
  ),
  const OiKanbanColumn<String>(
    key: 'done',
    title: 'Done',
    color: Colors.green,
    items: ['Project setup', 'Database schema', 'Theme configuration'],
  ),
];

final oiKanbanComponent = WidgetbookComponent(
  name: 'OiKanban',
  useCases: [
    WidgetbookUseCase(
      name: 'Playground',
      builder: (context) {
        final collapsibleColumns = context.knobs.boolean(
          label: 'Collapsible Columns',
          initialValue: true,
        );
        final quickEdit = context.knobs.boolean(
          label: 'Quick Edit',
          initialValue: true,
        );
        final addColumn = context.knobs.boolean(label: 'Show Add Column');
        final reorderColumns = context.knobs.boolean(
          label: 'Reorder Columns',
          initialValue: true,
        );
        final useWipLimits = context.knobs.boolean(label: 'Use WIP Limits');

        return useCaseWrapper(
          SizedBox(
            height: 600,
            width: 900,
            child: OiKanban<String>(
              columns: _sampleColumns,
              label: 'Kanban board',
              collapsibleColumns: collapsibleColumns,
              quickEdit: quickEdit,
              addColumn: addColumn,
              reorderColumns: reorderColumns,
              wipLimits: useWipLimits
                  ? const {
                      'backlog': 5,
                      'todo': 3,
                      'in-progress': 2,
                      'done': 10,
                    }
                  : null,
              onAddColumn: addColumn ? () {} : null,
              onCardMove: (_, __, ___, ____) {},
              onColumnReorder: (_, __) {},
            ),
          ),
        );
      },
    ),
  ],
);
