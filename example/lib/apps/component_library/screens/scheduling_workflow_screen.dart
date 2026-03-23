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
                child: OiDatePicker(
                  value: _selectedDate,
                  onChanged: (date) => setState(() => _selectedDate = date),
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
                  height: 200,
                  child: OiTimePicker(
                    value: const OiTimeOfDay(hour: 14, minute: 30),
                    onChanged: (_) {},
                  ),
                ),
              ),
            ],
          ),

          // ── OiGantt ───────────────────────────────────────────────────
          const ComponentShowcaseSection(
            title: 'Gantt Chart',
            widgetName: 'OiGantt',
            description:
                'A Gantt chart for project timeline visualization. Displays '
                'tasks as horizontal bars across a time axis, showing '
                'duration, dependencies, and progress.',
            examples: [
              ComponentExample(
                title: 'Key Parameters',
                child: OiLabel.body(
                  'OiGantt takes a list of OiGanttTask objects, each with '
                  'a key, title, start and end DateTime, optional progress '
                  '(0.0-1.0), color, and dependencies (list of task keys). '
                  'Required: tasks, label. Optional: onTaskTap, '
                  'onTaskMove, onTaskResize, settingsDriver.',
                ),
              ),
            ],
          ),

          // ── OiScheduler ───────────────────────────────────────────────
          const ComponentShowcaseSection(
            title: 'Scheduler',
            widgetName: 'OiScheduler',
            description:
                'A scheduling and appointment manager widget. Provides a '
                'resource-based view for managing time slots and bookings '
                'across multiple resources.',
            examples: [
              ComponentExample(
                title: 'Key Parameters',
                child: OiLabel.body(
                  'OiScheduler displays a time-resource grid for managing '
                  'appointments. It takes resources, events, a time range, '
                  'and callbacks for event creation and interaction. '
                  'Supports drag-to-create and drag-to-reschedule.',
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
          const ComponentShowcaseSection(
            title: 'Flow Graph',
            widgetName: 'OiFlowGraph',
            description:
                'A flowchart and graph visualization widget. Renders nodes '
                'and directed edges for workflow diagrams, decision trees, '
                'and process flows.',
            examples: [
              ComponentExample(
                title: 'Key Parameters',
                child: OiLabel.body(
                  'OiFlowGraph takes a list of OiFlowNode objects (each with '
                  'key, label, position, and optional content widget) and '
                  'OiFlowEdge objects (source, target, optional label). '
                  'Required: nodes, edges, label. Supports interactive '
                  'panning, zooming, and node drag-and-drop.',
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
          const ComponentShowcaseSection(
            title: 'State Diagram',
            widgetName: 'OiStateDiagram',
            description:
                'A state machine diagram widget for visualising states and '
                'transitions. Renders nodes as states and directed edges as '
                'transitions between them.',
            examples: [
              ComponentExample(
                title: 'Key Parameters',
                child: OiLabel.body(
                  'OiStateDiagram takes a list of OiState objects (each with '
                  'key, label, and an isInitial/isFinal flag) and '
                  'OiTransition objects (source, target, label/event). '
                  'Required: states, transitions, label. Renders states as '
                  'rounded rectangles with transition arrows between them.',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
