import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';

import 'package:obers_ui_example/data/mock_users.dart';

// ── Task model ──────────────────────────────────────────────────────────────

/// A task card used in the Kanban board.
class MockTask {
  const MockTask({
    required this.id,
    required this.title,
    this.assignee,
    this.priority = 'medium',
    this.labels = const [],
    this.dueDate,
  });

  final String id;
  final String title;
  final MockUser? assignee;

  /// One of `low`, `medium`, `high`, or `critical`.
  final String priority;
  final List<String> labels;
  final DateTime? dueDate;

  @override
  String toString() => title;
}

// ── Kanban columns ──────────────────────────────────────────────────────────

/// Builds a Kanban board with five columns of Austrian-themed product tasks.
List<OiKanbanColumn<MockTask>> buildKanbanColumns() {
  final now = DateTime.now();

  return [
    // ── Backlog ──────────────────────────────────────────────────────────
    OiKanbanColumn<MockTask>(
      key: 'backlog',
      title: 'Backlog',
      color: const Color(0xFF9E9E9E), // grey
      items: [
        const MockTask(
          id: 'task-01',
          title: 'Source new Bergkäse supplier from Vorarlberg',
          assignee: kWolfgang,
          priority: 'low',
          labels: ['sourcing', 'dairy'],
        ),
        const MockTask(
          id: 'task-02',
          title: 'Design gift wrapping for Mozartkugeln box set',
          assignee: kMaria,
          labels: ['design', 'packaging'],
        ),
        const MockTask(
          id: 'task-03',
          title: 'Implement Kaffeepause reminder feature',
          priority: 'low',
          labels: ['sustainability'],
        ),
        MockTask(
          id: 'task-04',
          title: 'Plan Almabtrieb seasonal promotion',
          assignee: kFranz,
          labels: ['marketing', 'seasonal'],
          dueDate: DateTime(now.year, 9),
        ),
      ],
    ),

    // ── To Do ────────────────────────────────────────────────────────────
    OiKanbanColumn<MockTask>(
      key: 'todo',
      title: 'To Do',
      color: const Color(0xFF42A5F5), // blue
      items: [
        MockTask(
          id: 'task-05',
          title: 'Update product photos for Dirndl collection',
          assignee: kMaria,
          priority: 'high',
          labels: ['photography', 'clothing'],
          dueDate: now.add(const Duration(days: 7)),
        ),
        MockTask(
          id: 'task-06',
          title: 'Add Steirisches Kürbiskernöl to online shop',
          assignee: kLiesl,
          labels: ['development', 'food'],
          dueDate: now.add(const Duration(days: 5)),
        ),
        MockTask(
          id: 'task-07',
          title: 'Translate product descriptions to English',
          assignee: kAnna,
          priority: 'high',
          labels: ['content', 'i18n'],
          dueDate: now.add(const Duration(days: 10)),
        ),
      ],
    ),

    // ── In Progress ──────────────────────────────────────────────────────
    OiKanbanColumn<MockTask>(
      key: 'in-progress',
      title: 'In Progress',
      color: const Color(0xFFFFA726), // amber
      items: [
        MockTask(
          id: 'task-08',
          title: 'Build checkout flow for Sachertorte subscriptions',
          assignee: kStefan,
          priority: 'critical',
          labels: ['development', 'subscriptions'],
          dueDate: now.add(const Duration(days: 3)),
        ),
        MockTask(
          id: 'task-09',
          title: 'Prepare Easter Geschenkkorb bundle pricing',
          assignee: kFranz,
          priority: 'high',
          labels: ['pricing', 'seasonal'],
          dueDate: now.add(const Duration(days: 2)),
        ),
        MockTask(
          id: 'task-14',
          title: 'Integrate payment gateway for Wiener Melange orders',
          assignee: kLiesl,
          priority: 'high',
          labels: ['development', 'payments'],
          dueDate: now.add(const Duration(days: 4)),
        ),
        MockTask(
          id: 'task-15',
          title: 'Fix Sachertorte image not loading on mobile',
          assignee: kElisabeth,
          labels: ['performance', 'infrastructure'],
          dueDate: now.add(const Duration(days: 6)),
        ),
      ],
    ),

    // ── Review ───────────────────────────────────────────────────────────
    OiKanbanColumn<MockTask>(
      key: 'review',
      title: 'Review',
      color: const Color(0xFFAB47BC), // purple
      items: [
        MockTask(
          id: 'task-10',
          title: 'QA: Lederhosen size guide integration',
          assignee: kMaximilian,
          priority: 'high',
          labels: ['qa', 'clothing'],
          dueDate: now.add(const Duration(days: 1)),
        ),
      ],
    ),

    // ── Done ─────────────────────────────────────────────────────────────
    const OiKanbanColumn<MockTask>(
      key: 'done',
      title: 'Done',
      color: Color(0xFF66BB6A), // green
      items: [
        MockTask(
          id: 'task-11',
          title: 'Launch Kaffeehauskultur landing page',
          assignee: kLiesl,
          priority: 'high',
          labels: ['development', 'coffee'],
        ),
        MockTask(
          id: 'task-12',
          title: 'Ship Tiroler Speck sample packs to influencers',
          assignee: kHans,
          labels: ['logistics', 'marketing'],
        ),
        MockTask(
          id: 'task-13',
          title: 'Fix Almdudler inventory sync issue',
          assignee: kStefan,
          priority: 'critical',
          labels: ['bugfix', 'inventory'],
        ),
      ],
    ),
  ];
}
