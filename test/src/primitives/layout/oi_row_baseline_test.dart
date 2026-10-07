import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/obers_ui.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('different type sizes share a baseline across responsive gaps', (
    tester,
  ) async {
    await tester.pumpObers(
      const Center(
        child: OiRow(
          breakpoint: OiBreakpoint.compact,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          gap: OiResponsive(8),
          children: [
            OiLabel.body('Large', style: TextStyle(fontSize: 32)),
            OiLabel.body('Small', style: TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
    double baseline(String text) {
      final finder = find.text(text);
      final label = tester.widget<Text>(finder);
      final painter = TextPainter(
        text: TextSpan(text: text, style: label.style),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: tester.getSize(finder).width);
      final value =
          tester.getTopLeft(finder).dy +
          painter.computeLineMetrics().first.baseline;
      painter.dispose();
      return value;
    }

    expect(baseline('Large'), closeTo(baseline('Small'), .01));
    expect(tester.takeException(), isNull);
  });
}
