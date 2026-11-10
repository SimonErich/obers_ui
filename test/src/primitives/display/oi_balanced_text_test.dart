import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/obers_ui.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('balancing does not split a word that fits the original width', (
    tester,
  ) async {
    const text = 'short longestword x y z';
    await tester.pumpObers(
      const Center(
        child: SizedBox(
          width: 280,
          child: OiBalancedText(
            text,
            variant: OiLabelVariant.body,
            style: TextStyle(fontSize: 20, height: 1),
          ),
        ),
      ),
    );
    final paragraph = tester.renderObject<RenderParagraph>(find.text(text));
    final start = text.indexOf('longestword');
    final boxes = paragraph.getBoxesForSelection(
      TextSelection(
        baseOffset: start,
        extentOffset: start + 'longestword'.length,
      ),
    );
    expect(boxes, hasLength(1));
  });

  testWidgets('balances short lines without changing the accessible text', (
    tester,
  ) async {
    const text = 'one two three four';
    await tester.pumpObers(
      const Center(
        child: SizedBox(
          width: 280,
          child: OiBalancedText(
            text,
            variant: OiLabelVariant.body,
            style: TextStyle(fontSize: 20, height: 1),
          ),
        ),
      ),
    );
    final paragraph = tester.renderObject<RenderParagraph>(find.text(text));
    expect(paragraph.size.width, lessThan(240));
    expect(paragraph.size.height, 40);
    expect(paragraph.text.toPlainText(), text);
  });

  testWidgets(
    'measures with the system text scaler and preserves RTL direction',
    (tester) async {
      await tester.pumpObers(
        const MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(2)),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Center(
              child: SizedBox(
                width: 280,
                child: OiBalancedText(
                  'one two three four',
                  variant: OiLabelVariant.body,
                  style: TextStyle(fontSize: 20, height: 1),
                ),
              ),
            ),
          ),
        ),
      );
      final paragraph = tester.renderObject<RenderParagraph>(
        find.text('one two three four'),
      );
      expect(paragraph.textScaler.scale(20), 40);
      expect(paragraph.textDirection, TextDirection.rtl);
      expect(paragraph.size.height, 120);
      expect(tester.takeException(), isNull);
    },
  );
}
