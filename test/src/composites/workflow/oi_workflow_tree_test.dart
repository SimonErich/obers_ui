// Tests do not require documentation comments.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/composites/workflow/oi_pipeline.dart';
import 'package:obers_ui/src/composites/workflow/oi_workflow_tree.dart';

import '../../../helpers/pump_app.dart';

List<OiWorkflowGroup<void>> _sampleGroups() => [
  OiWorkflowGroup<void>(
    id: 'build',
    label: 'Build',
    items: [
      const OiWorkflowItem(
        id: 'lint',
        label: 'Lint',
        status: OiPipelineStatus.completed,
      ),
      const OiWorkflowItem(
        id: 'compile',
        label: 'Compile',
        status: OiPipelineStatus.running,
      ),
      const OiWorkflowItem(
        id: 'test',
        label: 'Test',
        status: OiPipelineStatus.pending,
      ),
    ],
  ),
  const OiWorkflowGroup<void>(
    id: 'deploy',
    label: 'Deploy',
    items: [
      OiWorkflowItem(
        id: 'push',
        label: 'Push',
        status: OiPipelineStatus.pending,
      ),
    ],
  ),
];

void main() {
  group('OiWorkflowTree', () {
    testWidgets('renders group labels', (tester) async {
      await tester.pumpObers(
        OiWorkflowTree<void>(
          label: 'Pipeline',
          groups: _sampleGroups(),
        ),
        surfaceSize: const Size(400, 600),
      );

      expect(find.text('Build'), findsOneWidget);
      expect(find.text('Deploy'), findsOneWidget);
    });

    testWidgets('auto-expands group with running items', (tester) async {
      await tester.pumpObers(
        OiWorkflowTree<void>(
          label: 'Pipeline',
          groups: _sampleGroups(),
        ),
        surfaceSize: const Size(400, 600),
      );
      await tester.pump(const Duration(milliseconds: 300));

      // Build group has a running item → should be expanded.
      expect(find.text('Lint'), findsOneWidget);
      expect(find.text('Compile'), findsOneWidget);
    });

    testWidgets('shows progress count', (tester) async {
      await tester.pumpObers(
        OiWorkflowTree<void>(
          label: 'Pipeline',
          groups: _sampleGroups(),
        ),
        surfaceSize: const Size(400, 600),
      );
      await tester.pump(const Duration(milliseconds: 300));

      // Build: 1 completed out of 3.
      expect(find.text('1 / 3'), findsOneWidget);
    });

    testWidgets('controller expand/collapse changes state', (tester) async {
      final controller = OiWorkflowTreeController();
      await tester.pumpObers(
        OiWorkflowTree<void>(
          label: 'Pipeline',
          groups: _sampleGroups(),
          controller: controller,
          autoExpandActive: false,
        ),
        surfaceSize: const Size(400, 600),
      );
      await tester.pump(const Duration(milliseconds: 300));

      // Initially collapsed.
      expect(controller.isExpanded('build'), isFalse);

      controller.expandGroup('build');
      await tester.pump(const Duration(milliseconds: 300));

      expect(controller.isExpanded('build'), isTrue);

      controller.collapseAll();
      await tester.pump(const Duration(milliseconds: 300));

      expect(controller.isExpanded('build'), isFalse);
    });

    testWidgets('onItemTap fires with correct item', (tester) async {
      OiWorkflowItem<void>? tappedItem;
      final controller = OiWorkflowTreeController();
      controller.expandGroup('build');

      await tester.pumpObers(
        OiWorkflowTree<void>(
          label: 'Pipeline',
          groups: _sampleGroups(),
          controller: controller,
          autoExpandActive: false,
          onItemTap: (item) => tappedItem = item,
        ),
        surfaceSize: const Size(400, 600),
      );
      await tester.pump(const Duration(milliseconds: 300));

      await tester.tap(find.text('Lint'));
      expect(tappedItem?.id, 'lint');
    });
  });
}
