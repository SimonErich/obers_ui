// Tests do not require documentation comments.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/composites/navigation/oi_three_column_layout.dart';

import '../../../helpers/pump_app.dart';

// ── Helpers ──────────────────────────────────────────────────────────────────

const _surfaceSize = Size(1280, 800);

Widget _layout({
  Widget? leftColumn,
  Widget? middleColumn,
  Widget? rightColumn,
  String label = 'Test layout',
  double leftColumnWidth = 260,
  double leftColumnMinWidth = 200,
  double leftColumnMaxWidth = 400,
  double rightColumnWidth = 320,
  double rightColumnMinWidth = 250,
  double rightColumnMaxWidth = 500,
  bool showRightColumn = true,
  bool resizable = true,
}) {
  return OiThreeColumnLayout(
    label: label,
    leftColumn:
        leftColumn ??
        const SizedBox.expand(key: Key('left'), child: Placeholder()),
    middleColumn:
        middleColumn ??
        const SizedBox.expand(key: Key('middle'), child: Placeholder()),
    rightColumn: rightColumn,
    leftColumnWidth: leftColumnWidth,
    leftColumnMinWidth: leftColumnMinWidth,
    leftColumnMaxWidth: leftColumnMaxWidth,
    rightColumnWidth: rightColumnWidth,
    rightColumnMinWidth: rightColumnMinWidth,
    rightColumnMaxWidth: rightColumnMaxWidth,
    showRightColumn: showRightColumn,
    resizable: resizable,
  );
}

// ── Tests ───────────────────────────────────────────────────────────────────

void main() {
  group('OiThreeColumnLayout', () {
    testWidgets('renders left and middle columns', (tester) async {
      await tester.pumpObers(_layout(), surfaceSize: _surfaceSize);

      expect(find.byKey(const Key('left')), findsOneWidget);
      expect(find.byKey(const Key('middle')), findsOneWidget);
    });

    testWidgets('renders right column when showRightColumn is true', (
      tester,
    ) async {
      await tester.pumpObers(
        _layout(
          rightColumn: const SizedBox.expand(
            key: Key('right'),
            child: Placeholder(),
          ),
        ),
        surfaceSize: _surfaceSize,
      );

      expect(find.byKey(const Key('right')), findsOneWidget);
    });

    testWidgets('hides right column when showRightColumn is false', (
      tester,
    ) async {
      await tester.pumpObers(
        _layout(
          rightColumn: const SizedBox.expand(
            key: Key('right'),
            child: Placeholder(),
          ),
          showRightColumn: false,
        ),
        surfaceSize: _surfaceSize,
      );

      expect(find.byKey(const Key('right')), findsNothing);
    });

    testWidgets('left column respects initial width', (tester) async {
      const initialWidth = 300.0;
      await tester.pumpObers(
        _layout(leftColumnWidth: initialWidth),
        surfaceSize: _surfaceSize,
      );

      // Find the SizedBox wrapping the left column by looking for the
      // one whose width matches the initial value.
      final leftWidget = tester.widget<SizedBox>(
        find.ancestor(
          of: find.byKey(const Key('left')),
          matching: find.byType(SizedBox),
        ),
      );
      expect(leftWidget.width, initialWidth);
    });

    testWidgets('has semantics label', (tester) async {
      await tester.pumpObers(
        _layout(label: 'IDE layout'),
        surfaceSize: _surfaceSize,
      );

      expect(find.bySemanticsLabel('IDE layout'), findsOneWidget);
    });

    testWidgets('renders without error with minimal config (no right column)', (
      tester,
    ) async {
      await tester.pumpObers(
        const OiThreeColumnLayout(
          label: 'Minimal layout',
          leftColumn: SizedBox.expand(child: Placeholder()),
          middleColumn: SizedBox.expand(child: Placeholder()),
        ),
        surfaceSize: _surfaceSize,
      );

      // Should render without errors — left, divider, middle only.
      expect(find.byType(OiThreeColumnLayout), findsOneWidget);
    });

    testWidgets('middle column takes remaining space', (tester) async {
      const leftWidth = 260.0;
      const rightWidth = 320.0;
      const dividerWidth = 2.0;

      await tester.pumpObers(
        _layout(
          rightColumn: const SizedBox.expand(
            key: Key('right'),
            child: Placeholder(),
          ),
        ),
        surfaceSize: _surfaceSize,
      );
      await tester.pumpAndSettle();

      // The middle Expanded widget should take
      // totalWidth - leftWidth - rightWidth - 2 dividers.
      final middleFinder = find.byKey(const Key('middle'));
      expect(middleFinder, findsOneWidget);

      final middleBox = tester.renderObject<RenderBox>(middleFinder);
      final expectedWidth =
          _surfaceSize.width - leftWidth - rightWidth - (dividerWidth * 2);
      expect(middleBox.size.width, closeTo(expectedWidth, 1.0));
    });
  });
}
