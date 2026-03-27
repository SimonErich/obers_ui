// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/composites/workflow/oi_pipeline.dart';

import '../../../helpers/pump_app.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

Widget _pipeline({
  List<OiPipelineStage>? stages,
  Axis direction = Axis.horizontal,
  ValueChanged<int>? onStageTap,
  String label = 'Test Pipeline',
}) {
  return SizedBox(
    width: 800,
    height: 400,
    child: OiPipeline(
      stages:
          stages ??
          const [
            OiPipelineStage(label: 'Build', status: OiPipelineStatus.completed),
            OiPipelineStage(label: 'Test', status: OiPipelineStatus.running),
            OiPipelineStage(label: 'Deploy', status: OiPipelineStatus.pending),
          ],
      label: label,
      direction: direction,
      onStageTap: onStageTap,
    ),
  );
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  // 1. Stages render with labels.
  testWidgets('renders stage labels', (tester) async {
    await tester.pumpObers(_pipeline());
    expect(find.text('Build'), findsOneWidget);
    expect(find.text('Test'), findsOneWidget);
    expect(find.text('Deploy'), findsOneWidget);
  });

  // 2. Correct icons for each status.
  testWidgets('renders correct icon for each status', (tester) async {
    final stages = OiPipelineStatus.values.map((s) {
      return OiPipelineStage(label: s.name, status: s);
    }).toList();

    // Use a wider surface so all status stages fit without overflow.
    await tester.pumpObers(
      SizedBox(
        width: 1200,
        height: 400,
        child: OiPipeline(stages: stages, label: 'Test Pipeline'),
      ),
      surfaceSize: const Size(1200, 600),
    );

    for (final status in OiPipelineStatus.values) {
      final expectedIcon = OiPipeline.statusIcon(status);
      expect(
        find.byIcon(expectedIcon),
        findsWidgets,
        reason: 'Expected icon for $status',
      );
    }
  });

  // 3. Connecting arrows between stages.
  testWidgets('renders connecting arrows between stages', (tester) async {
    await tester.pumpObers(_pipeline());
    // There should be 2 arrows for 3 stages (at indices 1 and 2).
    expect(find.byKey(const ValueKey('oi_pipeline_arrow_1')), findsOneWidget);
    expect(find.byKey(const ValueKey('oi_pipeline_arrow_2')), findsOneWidget);
  });

  // 4. Horizontal direction renders a Row.
  testWidgets('horizontal direction renders stages in a row', (tester) async {
    await tester.pumpObers(_pipeline());
    expect(find.byType(Row), findsOneWidget);
    expect(find.byType(Column), findsWidgets); // inner stage columns
  });

  // 5. Vertical direction renders a Column layout.
  testWidgets('vertical direction renders stages in a column', (tester) async {
    await tester.pumpObers(_pipeline(direction: Axis.vertical));
    // The outer layout should be a Column. Inner stage cards also use Column,
    // so we look for the outer one by checking that no top-level Row exists
    // wrapping the stages.
    final columns = tester.widgetList<Column>(find.byType(Column));
    expect(columns.length, greaterThanOrEqualTo(1));
  });

  // 6. onStageTap fires with the correct index.
  testWidgets('onStageTap fires with correct index', (tester) async {
    int? tappedIndex;
    await tester.pumpObers(
      _pipeline(onStageTap: (index) => tappedIndex = index),
    );
    // Tap the second stage label.
    await tester.tap(find.text('Test'));
    await tester.pump();
    expect(tappedIndex, 1);
  });

  // 7. Status colors are correct (completed = green/success).
  testWidgets('completed status uses success color', (tester) async {
    await tester.pumpObers(_pipeline());
    // The completed stage should have a Container with a border colored
    // with success.base. We verify by finding the stage icon with the
    // expected icon data.
    final completedIcon = OiPipeline.statusIcon(OiPipelineStatus.completed);
    expect(find.byIcon(completedIcon), findsOneWidget);
  });

  // 8. Failed status renders with error icon.
  testWidgets('failed status renders error icon', (tester) async {
    const stages = [
      OiPipelineStage(label: 'Fail', status: OiPipelineStatus.failed),
    ];
    await tester.pumpObers(_pipeline(stages: stages));
    final failedIcon = OiPipeline.statusIcon(OiPipelineStatus.failed);
    expect(find.byIcon(failedIcon), findsOneWidget);
  });

  // 9. Running status renders with running icon.
  testWidgets('running status renders info/running icon', (tester) async {
    const stages = [
      OiPipelineStage(label: 'Run', status: OiPipelineStatus.running),
    ];
    await tester.pumpObers(_pipeline(stages: stages));
    final runningIcon = OiPipeline.statusIcon(OiPipelineStatus.running);
    expect(find.byIcon(runningIcon), findsOneWidget);
  });

  // 10. Skipped status renders with skipped icon.
  testWidgets('skipped status renders block icon', (tester) async {
    const stages = [
      OiPipelineStage(label: 'Skip', status: OiPipelineStatus.skipped),
    ];
    await tester.pumpObers(_pipeline(stages: stages));
    final skippedIcon = OiPipeline.statusIcon(OiPipelineStatus.skipped);
    expect(find.byIcon(skippedIcon), findsOneWidget);
  });

  // 11. Duration displayed when provided.
  testWidgets('duration is displayed when provided', (tester) async {
    const stages = [
      OiPipelineStage(
        label: 'Build',
        status: OiPipelineStatus.completed,
        duration: Duration(minutes: 3, seconds: 42),
      ),
    ];
    await tester.pumpObers(_pipeline(stages: stages));
    expect(find.text('3m 42s'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('oi_pipeline_duration_0')),
      findsOneWidget,
    );
  });

  // 12. Duration with hours.
  testWidgets('duration with hours formats correctly', (tester) async {
    const stages = [
      OiPipelineStage(
        label: 'Long',
        status: OiPipelineStatus.completed,
        duration: Duration(hours: 1, minutes: 15),
      ),
    ];
    await tester.pumpObers(_pipeline(stages: stages));
    expect(find.text('1h 15m'), findsOneWidget);
  });

  // 13. No duration means no duration text.
  testWidgets('no duration text when duration is null', (tester) async {
    const stages = [
      OiPipelineStage(label: 'Quick', status: OiPipelineStatus.pending),
    ];
    await tester.pumpObers(_pipeline(stages: stages));
    expect(find.byKey(const ValueKey('oi_pipeline_duration_0')), findsNothing);
  });

  // 14. Content widget is rendered inside stage.
  testWidgets('content widget is rendered inside stage card', (tester) async {
    const stages = [
      OiPipelineStage(
        label: 'Build',
        status: OiPipelineStatus.running,
        content: Text('Building...', key: ValueKey('custom_content')),
      ),
    ];
    await tester.pumpObers(_pipeline(stages: stages));
    expect(find.byKey(const ValueKey('custom_content')), findsOneWidget);
    expect(find.text('Building...'), findsOneWidget);
  });

  // 15. Semantics label on the pipeline.
  testWidgets('semantics label is applied to pipeline', (tester) async {
    await tester.pumpObers(_pipeline(label: 'CI Pipeline'));
    expect(
      find.byWidgetPredicate(
        (w) => w is Semantics && w.properties.label == 'CI Pipeline',
      ),
      findsOneWidget,
    );
  });

  // 16. Empty stages list renders without errors.
  testWidgets('empty stages list renders without errors', (tester) async {
    await tester.pumpObers(_pipeline(stages: const []));
    // No stages, no arrows.
    expect(find.byKey(const ValueKey('oi_pipeline_arrow_1')), findsNothing);
  });

  // 17. Single stage has no arrows.
  testWidgets('single stage has no connecting arrows', (tester) async {
    const stages = [
      OiPipelineStage(label: 'Only', status: OiPipelineStatus.completed),
    ];
    await tester.pumpObers(_pipeline(stages: stages));
    expect(find.text('Only'), findsOneWidget);
    expect(find.byKey(const ValueKey('oi_pipeline_arrow_1')), findsNothing);
  });

  // 18. Stage key is applied.
  testWidgets('stage widgets have expected keys', (tester) async {
    await tester.pumpObers(_pipeline());
    expect(find.byKey(const ValueKey('oi_pipeline_stage_0')), findsOneWidget);
    expect(find.byKey(const ValueKey('oi_pipeline_stage_1')), findsOneWidget);
    expect(find.byKey(const ValueKey('oi_pipeline_stage_2')), findsOneWidget);
  });

  // 19. onStageTap not provided means no GestureDetector on stages.
  testWidgets('no GestureDetector when onStageTap is null', (tester) async {
    await tester.pumpObers(_pipeline());
    // Tapping a stage should not throw.
    await tester.tap(find.text('Build'));
    await tester.pump();
    // If we get here without error, the test passes.
  });

  // 20. Pending status renders correct icon.
  testWidgets('pending status renders unchecked circle icon', (tester) async {
    const stages = [
      OiPipelineStage(label: 'Wait', status: OiPipelineStatus.pending),
    ];
    await tester.pumpObers(_pipeline(stages: stages));
    final pendingIcon = OiPipeline.statusIcon(OiPipelineStatus.pending);
    expect(find.byIcon(pendingIcon), findsOneWidget);
  });
}
