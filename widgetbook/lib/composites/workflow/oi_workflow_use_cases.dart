import 'package:flutter/material.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:widgetbook/widgetbook.dart';

import '../../helpers/knob_helpers.dart';

final oiWorkflowComponent = WidgetbookComponent(
  name: 'Workflow',
  useCases: [
    WidgetbookUseCase(
      name: 'OiFlowGraph',
      builder: (context) {
        return SizedBox(
          width: 600,
          height: 400,
          child: OiFlowGraph(
            label: 'Flow graph',
            nodes: const [
              OiFlowNode(
                key: 'start',
                position: Offset(50, 100),
                label: 'Start',
                outputs: ['out'],
              ),
              OiFlowNode(
                key: 'process',
                position: Offset(250, 100),
                label: 'Process',
                inputs: ['in'],
                outputs: ['out'],
              ),
              OiFlowNode(
                key: 'end',
                position: Offset(450, 100),
                label: 'End',
                inputs: ['in'],
              ),
            ],
            edges: const [
              OiFlowEdge(
                sourceNode: 'start',
                sourcePort: 'out',
                targetNode: 'process',
                targetPort: 'in',
              ),
              OiFlowEdge(
                sourceNode: 'process',
                sourcePort: 'out',
                targetNode: 'end',
                targetPort: 'in',
              ),
            ],
          ),
        );
      },
    ),
    WidgetbookUseCase(
      name: 'OiPipeline',
      builder: (context) {
        return useCaseWrapper(
          OiPipeline(
            label: 'CI/CD Pipeline',
            stages: const [
              OiPipelineStage(
                label: 'Build',
                status: OiPipelineStatus.completed,
                duration: Duration(minutes: 2),
              ),
              OiPipelineStage(
                label: 'Test',
                status: OiPipelineStatus.running,
                duration: Duration(minutes: 5),
              ),
              OiPipelineStage(
                label: 'Deploy',
                status: OiPipelineStatus.pending,
              ),
            ],
          ),
        );
      },
    ),
    WidgetbookUseCase(
      name: 'OiStateDiagram',
      builder: (context) {
        return SizedBox(
          width: 500,
          height: 300,
          child: OiStateDiagram(
            label: 'State machine',
            currentState: 'active',
            states: const [
              OiStateNode(
                key: 'idle',
                label: 'Idle',
                position: Offset(50, 100),
                initial: true,
              ),
              OiStateNode(
                key: 'active',
                label: 'Active',
                position: Offset(250, 100),
              ),
              OiStateNode(
                key: 'done',
                label: 'Done',
                position: Offset(450, 100),
                terminal: true,
              ),
            ],
            transitions: const [
              OiStateTransition(from: 'idle', to: 'active', label: 'start'),
              OiStateTransition(from: 'active', to: 'done', label: 'finish'),
              OiStateTransition(from: 'active', to: 'idle', label: 'reset'),
            ],
          ),
        );
      },
    ),
  ],
);
