// Tests do not require documentation comments.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/display/oi_scroll_to_top.dart';

import '../../../helpers/pump_app.dart';

Widget _buildScrollable({
  required ScrollController controller,
  double threshold = 200,
  int itemCount = 100,
}) {
  return OiScrollToTop(
    controller: controller,
    threshold: threshold,
    child: ListView.builder(
      controller: controller,
      itemCount: itemCount,
      itemBuilder: (_, i) => SizedBox(height: 50, child: Text('Item $i')),
    ),
  );
}

void main() {
  group('OiScrollToTop', () {
    // ── Initial state ────────────────────────────────────────────────────────

    testWidgets('button is hidden initially', (tester) async {
      final controller = ScrollController();
      addTearDown(controller.dispose);
      await tester.pumpObers(
        _buildScrollable(controller: controller),
        surfaceSize: const Size(400, 600),
      );
      final fadeTransition = tester.widget<FadeTransition>(
        find.descendant(
          of: find.byType(OiScrollToTop),
          matching: find.byType(FadeTransition),
        ).first,
      );
      expect(fadeTransition.opacity.value, 0.0);
    });

    // ── Appears after threshold ──────────────────────────────────────────────

    testWidgets('button appears after scrolling past threshold', (
      tester,
    ) async {
      final controller = ScrollController();
      addTearDown(controller.dispose);
      await tester.pumpObers(
        _buildScrollable(controller: controller, threshold: 100),
        surfaceSize: const Size(400, 600),
      );
      controller.jumpTo(150);
      await tester.pumpAndSettle();
      final fadeTransition = tester.widget<FadeTransition>(
        find.descendant(
          of: find.byType(OiScrollToTop),
          matching: find.byType(FadeTransition),
        ).first,
      );
      expect(fadeTransition.opacity.value, 1.0);
    });

    // ── Stays hidden below threshold ─────────────────────────────────────────

    testWidgets('button stays hidden when scroll is below threshold', (
      tester,
    ) async {
      final controller = ScrollController();
      addTearDown(controller.dispose);
      await tester.pumpObers(
        _buildScrollable(controller: controller),
        surfaceSize: const Size(400, 600),
      );
      controller.jumpTo(100);
      await tester.pumpAndSettle();
      final fadeTransition = tester.widget<FadeTransition>(
        find.descendant(
          of: find.byType(OiScrollToTop),
          matching: find.byType(FadeTransition),
        ).first,
      );
      expect(fadeTransition.opacity.value, 0.0);
    });

    // ── Hides when scrolled back ─────────────────────────────────────────────

    testWidgets('button hides when scrolled back above threshold', (
      tester,
    ) async {
      final controller = ScrollController();
      addTearDown(controller.dispose);
      await tester.pumpObers(
        _buildScrollable(controller: controller, threshold: 100),
        surfaceSize: const Size(400, 600),
      );

      // Scroll past threshold.
      controller.jumpTo(150);
      await tester.pumpAndSettle();

      // Scroll back above threshold.
      controller.jumpTo(50);
      await tester.pumpAndSettle();

      final fadeTransition = tester.widget<FadeTransition>(
        find.descendant(
          of: find.byType(OiScrollToTop),
          matching: find.byType(FadeTransition),
        ).first,
      );
      expect(fadeTransition.opacity.value, 0.0);
    });

    // ── Semantics ────────────────────────────────────────────────────────────

    testWidgets('default semantic label is "Scroll to top"', (tester) async {
      final controller = ScrollController();
      addTearDown(controller.dispose);
      await tester.pumpObers(
        _buildScrollable(controller: controller),
        surfaceSize: const Size(400, 600),
      );
      final widget = tester.widget<OiScrollToTop>(
        find.byType(OiScrollToTop),
      );
      expect(widget.semanticLabel, 'Scroll to top');
    });

    testWidgets('custom semantic label is applied', (tester) async {
      final controller = ScrollController();
      addTearDown(controller.dispose);
      await tester.pumpObers(
        OiScrollToTop(
          controller: controller,
          semanticLabel: 'Back to top',
          child: ListView.builder(
            controller: controller,
            itemCount: 50,
            itemBuilder: (_, i) => SizedBox(height: 50, child: Text('Item $i')),
          ),
        ),
        surfaceSize: const Size(400, 600),
      );
      final widget = tester.widget<OiScrollToTop>(
        find.byType(OiScrollToTop),
      );
      expect(widget.semanticLabel, 'Back to top');
    });

    // ── Child is rendered ────────────────────────────────────────────────────

    testWidgets('child content is rendered', (tester) async {
      final controller = ScrollController();
      addTearDown(controller.dispose);
      await tester.pumpObers(
        _buildScrollable(controller: controller),
        surfaceSize: const Size(400, 600),
      );
      expect(find.text('Item 0'), findsOneWidget);
    });
  });
}
