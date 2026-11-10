# Workflow & Diagrams

These widgets draw workflows, pipelines, and state machines. Use them to show
how work moves through stages, how nodes connect, or where a process stands
right now. They render nodes, edges, pills, and status colors from the theme,
so the picture stays readable in light and dark mode.

| Widget | What it does |
| --- | --- |
| `OiFlowGraph` | A node-and-edge canvas with drag, ports, pan, and zoom. |
| `OiPipeline` | A linear row (or column) of stages with status icons and arrows. |
| `OiStateDiagram` | A state machine drawn as boxes and labeled arrows. |
| `OiWorkflowStepper` | A two-row stepper: phases on top, steps of the current phase below. |
| `OiWorkflowTree` | Expandable groups of items with aggregate status and progress counts. |

## OiPipeline

A linear view of sequential stages, like a CI/CD run. Each stage shows a status
icon and color, and arrows connect them. Reach for this when the steps run one
after another and you want to show where the run is.

```dart
OiPipeline(
  label: 'Build pipeline',
  stages: [
    OiPipelineStage(label: 'Checkout', status: OiPipelineStatus.completed),
    OiPipelineStage(label: 'Build', status: OiPipelineStatus.running),
    OiPipelineStage(label: 'Deploy', status: OiPipelineStatus.pending),
  ],
)
```

Add a `duration` to any stage to show timing, and pass `content` for a custom
widget inside the stage card. Set `direction` to `Axis.vertical` to stack the
stages.

```dart
OiPipeline(
  label: 'Nightly job',
  direction: Axis.vertical,
  onStageTap: (index) => openStageLog(index),
  stages: [
    OiPipelineStage(
      label: 'Test',
      status: OiPipelineStatus.completed,
      duration: Duration(minutes: 2, seconds: 14),
    ),
    OiPipelineStage(label: 'Package', status: OiPipelineStatus.failed),
  ],
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `stages` | `List<OiPipelineStage>` | **required** | The stages in order. |
| `label` | `String` | **required** | Accessibility label for the pipeline. |
| `direction` | `Axis` | `horizontal` | Lay stages out in a row or a column. |
| `onStageTap` | `ValueChanged<int>?` | `null` | Called with the tapped stage index. |

Each `OiPipelineStage` takes a `label`, a `status`, an optional `duration`, and
an optional `content` widget shown inside the card.

The `OiPipelineStatus` enum has five values: `pending`, `running`, `completed`,
`failed`, and `skipped`. The pipeline picks the icon and color for each one.

## OiWorkflowStepper

A two-row stepper for multi-phase workflows. The top row shows phase pills. The
bottom row shows the steps of the current phase. Completed phases and steps turn
green, the current one is filled, and future ones stay muted. Use it for wizards
where steps are grouped into phases.

```dart
OiWorkflowStepper(
  label: 'Onboarding',
  currentPhaseId: 'profile',
  currentStepId: 'avatar',
  completedStepIds: {'name', 'email'},
  enabledStepIds: {'bio'},
  onStepTap: (phaseId, stepId) => goToStep(phaseId, stepId),
  phases: [
    OiWorkflowPhase(
      id: 'account',
      label: 'Account',
      steps: [
        OiWorkflowStep(id: 'name', label: 'Name'),
        OiWorkflowStep(id: 'email', label: 'Email'),
      ],
    ),
    OiWorkflowPhase(
      id: 'profile',
      label: 'Profile',
      steps: [
        OiWorkflowStep(id: 'avatar', label: 'Avatar', estimatedTime: '~1 min'),
        OiWorkflowStep(id: 'bio', label: 'Bio'),
      ],
    ),
  ],
)
```

A step is tappable only when it is completed or listed in `enabledStepIds`, and
never the current step. This gives you prerequisite gating for free: future
steps stay locked until you enable them. Steps whose IDs appear in
`skippedStepIds` are hidden from the step row.

Set `orientation` to `OiWorkflowStepperOrientation.vertical` for a stacked
layout that fits a sidebar.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `phases` | `List<OiWorkflowPhase>` | **required** | The phases, each with its steps. |
| `currentPhaseId` | `String` | **required** | ID of the active phase. |
| `currentStepId` | `String` | **required** | ID of the active step. |
| `label` | `String` | **required** | Accessibility label for the stepper. |
| `onStepTap` | `void Function(String phaseId, String stepId)?` | `null` | Called when a tappable step is tapped. |
| `completedStepIds` | `Set<String>` | `{}` | Steps shown as done. |
| `enabledStepIds` | `Set<String>` | `{}` | Future steps that are tappable. |
| `skippedStepIds` | `Set<String>` | `{}` | Steps hidden from the step row. |
| `orientation` | `OiWorkflowStepperOrientation` | `horizontal` | `horizontal` or `vertical`. |

`OiWorkflowPhase` has `id`, `label`, `steps`, an optional `icon`, and an
optional `badge` widget pinned to the pill corner. `OiWorkflowStep` has `id`,
`label`, an optional `icon`, and an optional `estimatedTime` hint.

!!! note
    A phase counts as completed once every one of its non-skipped steps is in
    `completedStepIds`. You do not mark phases done directly.

## OiWorkflowTree

An expandable tree of groups and items with a status dot and progress count on
each group. It sits between `OiPipeline` (a flat list) and `OiTree` (a generic
hierarchy). Use it when work is grouped, and each group has its own set of items
with their own status.

```dart
OiWorkflowTree<void>(
  label: 'Release checklist',
  onItemTap: (item) => showDetails(item.id),
  groups: [
    OiWorkflowGroup(
      id: 'build',
      label: 'Build',
      items: [
        OiWorkflowItem(id: 'lint', label: 'Lint', status: OiPipelineStatus.completed),
        OiWorkflowItem(id: 'test', label: 'Test', status: OiPipelineStatus.running),
        OiWorkflowItem(id: 'deploy', label: 'Deploy', status: OiPipelineStatus.pending),
      ],
    ),
  ],
)
```

The group header shows an aggregated status: running if any item is running,
then failed, then completed only when all items are done. Groups with a running
item expand on first build when `autoExpandActive` is on. Items reuse the
`OiPipelineStatus` enum, so a tree and a pipeline read the same status the same
way.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `label` | `String` | **required** | Accessibility label for the tree. |
| `groups` | `List<OiWorkflowGroup<T>>` | **required** | The groups shown in the tree. |
| `controller` | `OiWorkflowTreeController?` | `null` | External expand/collapse control. One is created when null. |
| `showProgress` | `bool` | `true` | Show inline counts like "3 / 7" in headers. |
| `autoExpandActive` | `bool` | `true` | Expand groups with a running item on first build. |
| `onItemTap` | `void Function(OiWorkflowItem<T>)?` | `null` | Called when an item row is tapped. |
| `onGroupTap` | `void Function(OiWorkflowGroup<T>)?` | `null` | Called when a group header is tapped. |

`OiWorkflowGroup<T>` has `id`, `label`, `items`, and an optional `icon`.
`OiWorkflowItem<T>` has `id`, `label`, `status`, plus optional `data`, `role`
(shown as a soft badge), `duration`, `trailingWidget`, and `highlighted`.

To drive expansion yourself, pass an `OiWorkflowTreeController`. It exposes
`expanded(id)`, `expandGroup(id)`, `collapseGroup(id)`, `toggleGroup(id)`,
`expandAll(ids)`, and `collapseAll()`.

```dart
final controller = OiWorkflowTreeController();
// later
controller.expandAll(['build', 'release']);
```

## OiFlowGraph

A node-and-edge canvas for visual workflows. You place nodes at positions,
connect their ports with edges, and let users drag, pan, and zoom. Reach for it
to build workflow editors, integration flows, or data flow diagrams.

```dart
OiFlowGraph(
  label: 'Integration flow',
  nodes: [
    OiFlowNode(
      key: 'source',
      label: 'Source',
      position: Offset(40, 60),
      outputs: ['out'],
    ),
    OiFlowNode(
      key: 'sink',
      label: 'Sink',
      position: Offset(320, 60),
      inputs: ['in'],
    ),
  ],
  edges: [
    OiFlowEdge(
      sourceNode: 'source',
      sourcePort: 'out',
      targetNode: 'sink',
      targetPort: 'in',
    ),
  ],
  onNodeTap: (node) => inspect(node.key),
)
```

Nodes carry a unique `key`, a `label`, a `position`, and named `inputs` and
`outputs` for the ports edges attach to. To move a node, handle `onNodeMove` and
store the new `Offset` in your own state, then rebuild with the updated node.
The graph does not keep positions for you.

```dart
OiFlowNode _node = OiFlowNode(key: 'a', label: 'A', position: Offset.zero);

OiFlowGraph(
  label: 'Editor',
  onNodeMove: (node, offset) => setState(() {
    _node = OiFlowNode(key: node.key, label: node.label, position: offset);
  }),
  nodes: [_node],
  edges: const [],
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `nodes` | `List<OiFlowNode>` | **required** | The nodes to render. |
| `edges` | `List<OiFlowEdge>` | **required** | The edges connecting node ports. |
| `label` | `String` | **required** | Accessibility label for the graph. |
| `nodeBuilder` | `Widget Function(OiFlowNode)?` | `null` | Custom node rendering. A default card is used when null. |
| `onNodeTap` | `ValueChanged<OiFlowNode>?` | `null` | Called when a node is tapped. |
| `onNodeMove` | `void Function(OiFlowNode, Offset)?` | `null` | Called when a node is dragged. |
| `onEdgeCreate` | `void Function(String sourcePort, String targetPort)?` | `null` | Called when a new edge is drawn. |
| `onEdgeDelete` | `ValueChanged<OiFlowEdge>?` | `null` | Called when an edge is removed. |
| `editable` | `bool` | `true` | Allow interactive moves. |
| `zoomable` | `bool` | `true` | Allow zooming. |
| `pannable` | `bool` | `true` | Allow panning. |
| `snapToGrid` | `bool` | `true` | Snap moved nodes to the grid and draw the dot grid. |
| `gridSize` | `double` | `20` | Grid cell size in logical pixels. |
| `width` | `double?` | `null` | Canvas width. Defaults to 600 when null. |
| `height` | `double?` | `null` | Canvas height. Defaults to 400 when null. |

`OiFlowNode` also takes an `icon`, a `color` override, and an arbitrary `data`
map. `OiFlowEdge` takes an optional `label` and an `animated` flag.

## OiStateDiagram

A state machine drawn as labeled boxes with arrows between them. Mark the entry
point with `initial` and accepting states with `terminal`, and highlight where
you are with `currentState`. Use it to document a status field or a small state
machine.

```dart
OiStateDiagram(
  label: 'Order status',
  currentState: 'shipped',
  states: [
    OiStateNode(key: 'new', label: 'New', position: Offset(20, 40), initial: true),
    OiStateNode(key: 'shipped', label: 'Shipped', position: Offset(180, 40)),
    OiStateNode(key: 'done', label: 'Delivered', position: Offset(340, 40), terminal: true),
  ],
  transitions: [
    OiStateTransition(from: 'new', to: 'shipped', label: 'ship'),
    OiStateTransition(from: 'shipped', to: 'done', label: 'deliver'),
  ],
  onStateSelect: (key) => selectState(key),
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `states` | `List<OiStateNode>` | **required** | The state nodes. |
| `transitions` | `List<OiStateTransition>` | **required** | The arrows between states. |
| `label` | `String` | **required** | Accessibility label for the diagram. |
| `currentState` | `Object?` | `null` | Key of the active state, highlighted with a thicker border. |
| `editable` | `bool` | `false` | Allow interactive editing. |
| `onStateSelect` | `ValueChanged<Object>?` | `null` | Called with the tapped state key. |
| `width` | `double?` | `null` | Canvas width. Defaults to 400 when null. |
| `height` | `double?` | `null` | Canvas height. Defaults to 300 when null. |

`OiStateNode` takes `key`, `label`, `position`, an optional `color`, and the
`initial` and `terminal` flags. `OiStateTransition` takes `from`, `to`, an
optional `label`, and an optional `color`.

!!! tip "Which one do I reach for?"
    Use `OiPipeline` for a straight run of stages. Use `OiWorkflowStepper` for a
    wizard grouped into phases. Use `OiWorkflowTree` when items nest under
    groups. Use `OiFlowGraph` or `OiStateDiagram` only when you need free-form
    nodes and connections, since you own the node positions.

## Related

- [Feedback & Status](feedback.md) for progress bars, steppers, and status dots.
- [Data & Tables](data-tables.md) for `OiTree` and other hierarchy views.
