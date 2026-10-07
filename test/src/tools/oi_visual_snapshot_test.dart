import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/obers_ui.dart';

void main() {
  testWidgets(
    'captures painted text without requiring semantics and excludes offstage',
    (tester) async {
      await tester.pumpWidget(
        const OiApp(
          home: SizedBox(
            width: 200,
            child: Stack(
              children: [
                ExcludeSemantics(child: OiLabel.body('Painted label')),
                Offstage(child: OiLabel.body('Hidden label')),
                Positioned(
                  top: 700,
                  child: OiLabel.body('Below viewport'),
                ),
              ],
            ),
          ),
        ),
      );
      final snapshot = OiVisualSnapshot.capture(
        tester.binding.renderViews.first,
        viewport: const Rect.fromLTWH(0, 0, 800, 600),
      );
      expect(snapshot.texts.map((t) => t['label']), contains('Painted label'));
      expect(
        snapshot.texts.map((t) => t['label']),
        isNot(contains('Hidden label')),
      );
      expect(
        snapshot.texts.map((t) => t['label']),
        isNot(contains('Below viewport')),
      );
      final text = snapshot.texts.singleWhere(
        (t) => t['label'] == 'Painted label',
      );
      expect(text['lines'], isNotEmpty);
      expect(
        (text['style']! as Map<String, Object?>)['fontSize'],
        greaterThan(0),
      );
    },
  );

  testWidgets('records clipping without reporting hidden scroll children', (
    tester,
  ) async {
    await tester.pumpWidget(
      const OiApp(
        home: Center(
          child: SizedBox(
            width: 200,
            height: 40,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  OiLabel.body('Visible'),
                  SizedBox(height: 100),
                  OiLabel.body('Hidden'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    final snapshot = OiVisualSnapshot.capture(
      tester.binding.renderViews.first,
      viewport: const Rect.fromLTWH(0, 0, 800, 600),
    );
    expect(snapshot.texts.map((t) => t['label']), contains('Visible'));
    expect(snapshot.texts.map((t) => t['label']), isNot(contains('Hidden')));
  });
}
