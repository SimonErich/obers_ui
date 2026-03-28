import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';

import 'package:obers_ui_example/data/mock_tasks.dart';

/// Kanban board screen for the Project mini-app.
class ProjectKanbanScreen extends StatefulWidget {
  const ProjectKanbanScreen({super.key});

  @override
  State<ProjectKanbanScreen> createState() => _ProjectKanbanScreenState();
}

class _ProjectKanbanScreenState extends State<ProjectKanbanScreen> {
  late List<OiKanbanColumn<MockTask>> _columns;

  @override
  void initState() {
    super.initState();
    _columns = buildKanbanColumns();
  }

  void _onCardMove(
    MockTask item,
    Object fromColumn,
    Object toColumn,
    int newIndex,
  ) {
    setState(() {
      // Remove from source column.
      _columns = _columns.map((col) {
        if (col.key == fromColumn) {
          final updated = List<MockTask>.from(col.items)..remove(item);
          return OiKanbanColumn<MockTask>(
            key: col.key,
            title: col.title,
            color: col.color,
            items: updated,
          );
        }
        return col;
      }).toList();

      // Insert into target column.
      _columns = _columns.map((col) {
        if (col.key == toColumn) {
          final updated = List<MockTask>.from(col.items)
            ..insert(newIndex.clamp(0, col.items.length), item);
          return OiKanbanColumn<MockTask>(
            key: col.key,
            title: col.title,
            color: col.color,
            items: updated,
          );
        }
        return col;
      }).toList();
    });
  }

  void _moveTaskToColumn(MockTask task, String targetColumnKey) {
    // Find which column the task is currently in.
    String? sourceKey;
    for (final col in _columns) {
      if (col.items.contains(task)) {
        sourceKey = col.key as String;
        break;
      }
    }
    if (sourceKey == null || sourceKey == targetColumnKey) return;

    _onCardMove(task, sourceKey, targetColumnKey, 0);
  }

  void _deleteTask(MockTask task) {
    setState(() {
      _columns = _columns.map((col) {
        if (col.items.contains(task)) {
          final updated = List<MockTask>.from(col.items)..remove(task);
          return OiKanbanColumn<MockTask>(
            key: col.key,
            title: col.title,
            color: col.color,
            items: updated,
          );
        }
        return col;
      }).toList();
    });
  }

  static const _priorityColors = {
    'low': OiBadgeColor.info,
    'medium': OiBadgeColor.warning,
    'high': OiBadgeColor.error,
    'critical': OiBadgeColor.error,
  };

  List<OiMenuItem> _buildContextMenuItems(MockTask task) {
    return [
      OiMenuItem(
        label: 'Edit',
        icon: OiIcons.squarePen,
        onTap: () {
          OiToast.show(
            context,
            message: 'Editing: ${task.title}',
          );
        },
      ),
      const OiMenuDivider(),
      OiMenuItem(
        label: 'Move to Backlog',
        icon: OiIcons.undo2,
        onTap: () => _moveTaskToColumn(task, 'backlog'),
      ),
      OiMenuItem(
        label: 'Move to To Do',
        icon: OiIcons.arrowRight,
        onTap: () => _moveTaskToColumn(task, 'todo'),
      ),
      OiMenuItem(
        label: 'Move to In Progress',
        icon: OiIcons.arrowRight,
        onTap: () => _moveTaskToColumn(task, 'in-progress'),
      ),
      OiMenuItem(
        label: 'Move to Review',
        icon: OiIcons.arrowRight,
        onTap: () => _moveTaskToColumn(task, 'review'),
      ),
      OiMenuItem(
        label: 'Move to Done',
        icon: OiIcons.circleCheck,
        onTap: () => _moveTaskToColumn(task, 'done'),
      ),
      const OiMenuDivider(),
      OiMenuItem(
        label: 'Delete',
        icon: OiIcons.trash2,
        onTap: () => _deleteTask(task),
      ),
    ];
  }

  Widget _buildCard(MockTask task) {
    return Builder(
      builder: (context) {
        final colors = context.colors;
        final spacing = context.spacing;

        return OiContextMenu(
          label: 'Task actions for ${task.title}',
          items: _buildContextMenuItems(task),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(spacing.sm),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: colors.borderSubtle),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Task title
                OiLabel.body(
                  task.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: spacing.xs),
                // Bottom row: assignee avatar + priority badge
                Row(
                  children: [
                    if (task.assignee != null) ...[
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: colors.primary.muted,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            task.assignee!.initials,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: colors.primary.base,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: spacing.xs),
                    ],
                    const Spacer(),
                    OiBadge.soft(
                      label: task.priority,
                      color:
                          _priorityColors[task.priority] ??
                          OiBadgeColor.neutral,
                      size: OiBadgeSize.small,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return OiKanban<MockTask>(
      columns: _columns,
      label: 'Project Kanban Board',
      cardBuilder: _buildCard,
      onCardMove: _onCardMove,
      wipLimits: const {'in-progress': 3},
      cardKey: (task) => task.id,
    );
  }
}
