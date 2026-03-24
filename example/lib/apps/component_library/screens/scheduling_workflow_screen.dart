import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_example/apps/component_library/shared/component_showcase_section.dart';

/// Showcase screen for scheduling, timeline, and workflow widgets.
class SchedulingWorkflowScreen extends StatefulWidget {
  const SchedulingWorkflowScreen({super.key});

  @override
  State<SchedulingWorkflowScreen> createState() =>
      _SchedulingWorkflowScreenState();
}

class _SchedulingWorkflowScreenState extends State<SchedulingWorkflowScreen> {
  DateTime? _selectedDate;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;

    return SingleChildScrollView(
      padding: EdgeInsets.all(spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── OiCalendar ────────────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Calendar',
            widgetName: 'OiCalendar',
            description:
                'A calendar view (day/week/month) for displaying and managing '
                'events. Supports navigation between time periods, event '
                'display, and interaction.',
            examples: [
              ComponentExample(
                title: 'Month View with Events',
                child: SizedBox(
                  height: 500,
                  child: OiCalendar(
                    label: 'Calendar',
                    events: [
                      OiCalendarEvent(
                        key: 'evt-1',
                        title: 'Team standup',
                        start: DateTime(2026, 3, 23, 9),
                        end: DateTime(2026, 3, 23, 9, 30),
                      ),
                      OiCalendarEvent(
                        key: 'evt-2',
                        title: 'Sprint review',
                        start: DateTime(2026, 3, 25, 14),
                        end: DateTime(2026, 3, 25, 15),
                      ),
                      OiCalendarEvent(
                        key: 'evt-3',
                        title: 'Design workshop',
                        start: DateTime(2026, 3, 27, 10),
                        end: DateTime(2026, 3, 27, 12),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ── OiDatePicker ──────────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Date Picker',
            widgetName: 'OiDatePicker',
            description:
                'A calendar date picker with optional date-range selection. '
                'Displays a month-view calendar grid with day navigation.',
            examples: [
              ComponentExample(
                title: 'Single Date Selection',
                child: SizedBox(
                  width: 400,
                  child: OiDatePicker(
                    value: _selectedDate,
                    onChanged: (date) => setState(() => _selectedDate = date),
                  ),
                ),
              ),
              ComponentExample(
                title: 'Date Range Selection',
                child: SizedBox(
                  width: 400,
                  child: OiDatePicker(
                    rangeMode: true,
                    rangeStart: _rangeStart,
                    rangeEnd: _rangeEnd,
                    onRangeChanged: (start, end) => setState(() {
                      _rangeStart = start;
                      _rangeEnd = end;
                    }),
                  ),
                ),
              ),
            ],
          ),

          // ── OiTimePicker ──────────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Time Picker',
            widgetName: 'OiTimePicker',
            description:
                'A standalone time picker with scrollable hour and minute '
                'wheels. Supports 12-hour and 24-hour formats.',
            examples: [
              ComponentExample(
                title: '24-Hour Format',
                child: SizedBox(
                  height: 240,
                  child: OiTimePicker(
                    value: const OiTimeOfDay(hour: 14, minute: 30),
                    onChanged: (_) {},
                  ),
                ),
              ),
            ],
          ),

          // ── OiGantt ───────────────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Gantt Chart',
            widgetName: 'OiGantt',
            description:
                'A Gantt chart for project timeline visualization. Displays '
                'tasks as horizontal bars across a time axis, showing '
                'duration, dependencies, and progress. \n\n'
                'OiGantt takes a list of OiGanttTask objects, each with '
                  'a key, title, start and end DateTime, optional progress '
                  '(0.0-1.0), color, and dependencies (list of task keys). '
                  'Required: tasks, label. Optional: onTaskTap, '
                  'onTaskMove, onTaskResize, settingsDriver.',
            examples: [
              ComponentExample(
                title: 'Project Tasks',
                child: SizedBox(
                  height: 300,
                  child: OiGantt(
                    label: 'Project Gantt',
                    tasks: [
                      OiGanttTask(
                        key: 'design',
                        label: 'Design',
                        start: DateTime(2026, 3, 1),
                        end: DateTime(2026, 3, 10),
                        progress: 1.0,
                      ),
                      OiGanttTask(
                        key: 'develop',
                        label: 'Development',
                        start: DateTime(2026, 3, 8),
                        end: DateTime(2026, 3, 25),
                        progress: 0.6,
                        dependsOn: ['design'],
                      ),
                      OiGanttTask(
                        key: 'testing',
                        label: 'Testing',
                        start: DateTime(2026, 3, 20),
                        end: DateTime(2026, 4, 1),
                        progress: 0.1,
                        dependsOn: ['develop'],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ── OiScheduler ───────────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Scheduler',
            widgetName: 'OiScheduler',
            description:
                'A scheduling and appointment manager widget. Provides a '
                'resource-based view for managing time slots and bookings '
                'across multiple resources. \n\n'
                'OiScheduler displays a time-resource grid for managing '
                  'appointments. It takes resources, events, a time range, '
                  'and callbacks for event creation and interaction. '
                  'Supports drag-to-create and drag-to-reschedule.',
            examples: [
              ComponentExample(
                title: 'Day View',
                child: SizedBox(
                  height: 400,
                  child: OiScheduler(
                    label: 'Daily Schedule',
                    date: DateTime(2026, 3, 23),
                    startHour: 9,
                    endHour: 17,
                    slots: [
                      OiScheduleSlot(
                        key: 'slot-1',
                        title: 'Team standup',
                        start: DateTime(2026, 3, 23, 9),
                        end: DateTime(2026, 3, 23, 9, 30),
                      ),
                      OiScheduleSlot(
                        key: 'slot-2',
                        title: 'Sprint planning',
                        start: DateTime(2026, 3, 23, 11),
                        end: DateTime(2026, 3, 23, 12),
                      ),
                      OiScheduleSlot(
                        key: 'slot-3',
                        title: 'Code review',
                        start: DateTime(2026, 3, 23, 14),
                        end: DateTime(2026, 3, 23, 15, 30),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ── OiTimeline ────────────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Timeline',
            widgetName: 'OiTimeline',
            description:
                'A vertical timeline showing events in chronological order. '
                'Used for activity history, changelogs, and project milestones.',
            examples: [
              ComponentExample(
                title: 'Project Timeline',
                child: OiTimeline(
                  label: 'Project timeline',
                  events: [
                    OiTimelineEvent(
                      title: 'Project kickoff',
                      description: 'Initial planning and team setup',
                      timestamp: DateTime(2026, 1, 15),
                    ),
                    OiTimelineEvent(
                      title: 'Design phase completed',
                      description: 'UI/UX designs approved by stakeholders',
                      timestamp: DateTime(2026, 2),
                    ),
                    OiTimelineEvent(
                      title: 'Development sprint 1',
                      description: 'Core features implemented and tested',
                      timestamp: DateTime(2026, 2, 20),
                    ),
                    OiTimelineEvent(
                      title: 'Beta release',
                      description: 'Deployed to staging for user testing',
                      timestamp: DateTime(2026, 3, 10),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ── OiFlowGraph ───────────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Flow Graph',
            widgetName: 'OiFlowGraph',
            description:
                'A flowchart and graph visualization widget. Renders nodes '
                'and directed edges for workflow diagrams, decision trees, '
                'and process flows. \n\n'
                'OiFlowGraph takes a list of OiFlowNode objects (each with '
                  'key, label, position, and optional content widget) and '
                  'OiFlowEdge objects (source, target, optional label). '
                  'Required: nodes, edges, label. Supports interactive '
                  'panning, zooming, and node drag-and-drop.',
            examples: [
              ComponentExample(
                title: 'Workflow Diagram',
                child: SizedBox(
                  height: 350,
                  child: OiFlowGraph(
                    label: 'Approval workflow',
                    nodes: const [
                      OiFlowNode(
                        key: 'start',
                        label: 'Start',
                        position: Offset(20, 120),
                        outputs: ['out'],
                      ),
                      OiFlowNode(
                        key: 'review',
                        label: 'Review',
                        position: Offset(200, 120),
                        inputs: ['in'],
                        outputs: ['approve', 'reject'],
                      ),
                      OiFlowNode(
                        key: 'approved',
                        label: 'Approved',
                        position: Offset(420, 40),
                        inputs: ['in'],
                      ),
                      OiFlowNode(
                        key: 'rejected',
                        label: 'Rejected',
                        position: Offset(420, 200),
                        inputs: ['in'],
                      ),
                    ],
                    edges: const [
                      OiFlowEdge(
                        sourceNode: 'start',
                        sourcePort: 'out',
                        targetNode: 'review',
                        targetPort: 'in',
                      ),
                      OiFlowEdge(
                        sourceNode: 'review',
                        sourcePort: 'approve',
                        targetNode: 'approved',
                        targetPort: 'in',
                        label: 'Approve',
                      ),
                      OiFlowEdge(
                        sourceNode: 'review',
                        sourcePort: 'reject',
                        targetNode: 'rejected',
                        targetPort: 'in',
                        label: 'Reject',
                      ),
                    ],
                    editable: false,
                  ),
                ),
              ),
            ],
          ),

          // ── OiPipeline ────────────────────────────────────────────────
          const ComponentShowcaseSection(
            title: 'Pipeline',
            widgetName: 'OiPipeline',
            description:
                'A linear pipeline / workflow view showing sequential stages '
                'with status indicators. Like CI/CD pipeline visualization.',
            examples: [
              ComponentExample(
                title: 'CI/CD Pipeline',
                child: OiPipeline(
                  label: 'CI/CD Pipeline',
                  stages: [
                    OiPipelineStage(
                      label: 'Build',
                      status: OiPipelineStatus.completed,
                      duration: Duration(minutes: 3, seconds: 24),
                    ),
                    OiPipelineStage(
                      label: 'Test',
                      status: OiPipelineStatus.completed,
                      duration: Duration(minutes: 8, seconds: 12),
                    ),
                    OiPipelineStage(
                      label: 'Lint',
                      status: OiPipelineStatus.running,
                    ),
                    OiPipelineStage(
                      label: 'Deploy',
                      status: OiPipelineStatus.pending,
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ── OiStateDiagram ────────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'State Diagram',
            widgetName: 'OiStateDiagram',
            description:
                'A state machine diagram widget for visualising states and '
                'transitions. Renders nodes as states and directed edges as '
                'transitions between them. \n\n'
                'OiStateDiagram takes a list of OiState objects (each with '
                  'key, label, and an isInitial/isFinal flag) and '
                  'OiTransition objects (source, target, label/event). '
                  'Required: states, transitions, label. Renders states as '
                  'rounded rectangles with transition arrows between them.',
            examples: [
              ComponentExample(
                title: 'Order State Machine',
                child: SizedBox(
                  height: 300,
                  child: OiStateDiagram(
                    label: 'Order state machine',
                    currentState: 'processing',
                    states: const [
                      OiStateNode(
                        key: 'new',
                        label: 'New',
                        position: Offset(20, 120),
                        initial: true,
                      ),
                      OiStateNode(
                        key: 'processing',
                        label: 'Processing',
                        position: Offset(200, 120),
                      ),
                      OiStateNode(
                        key: 'shipped',
                        label: 'Shipped',
                        position: Offset(400, 60),
                      ),
                      OiStateNode(
                        key: 'delivered',
                        label: 'Delivered',
                        position: Offset(580, 60),
                        terminal: true,
                      ),
                      OiStateNode(
                        key: 'cancelled',
                        label: 'Cancelled',
                        position: Offset(400, 200),
                        terminal: true,
                      ),
                    ],
                    transitions: const [
                      OiStateTransition(
                        from: 'new',
                        to: 'processing',
                        label: 'confirm',
                      ),
                      OiStateTransition(
                        from: 'processing',
                        to: 'shipped',
                        label: 'ship',
                      ),
                      OiStateTransition(
                        from: 'shipped',
                        to: 'delivered',
                        label: 'deliver',
                      ),
                      OiStateTransition(
                        from: 'processing',
                        to: 'cancelled',
                        label: 'cancel',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
