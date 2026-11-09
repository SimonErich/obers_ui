import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/obers_ui.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets(
    'outline space does not shift items from the surrounding gutter',
    (tester) async {
      await tester.pumpObers(
        const Center(
          child: SizedBox(
            width: 240,
            child: OiMediaStrip(
              itemExtent: 56,
              gap: 8,
              outlinePadding: 4,
              children: [
                SizedBox(key: ValueKey('first')),
                SizedBox(key: ValueKey('second')),
              ],
            ),
          ),
        ),
      );
      final strip = tester.getRect(find.byType(OiMediaStrip));
      final first = tester.getRect(find.byKey(const ValueKey('first')));
      expect(first.left, strip.left);
      expect(first.top, strip.top + 4);
      expect(strip.height, 64);
      expect(
        tester.getTopLeft(find.byKey(const ValueKey('second'))).dx,
        first.left + 64,
      );
      expect(tester.takeException(), isNull);
    },
  );
  for (final direction in TextDirection.values) {
    testWidgets('portrait carousel gutters and scroll edges in $direction', (
      tester,
    ) async {
      final controller = ScrollController();
      addTearDown(controller.dispose);
      await tester.pumpObers(
        Directionality(
          textDirection: direction,
          child: Center(
            child: SizedBox(
              width: 240,
              child: OiMediaStrip(
                controller: controller,
                itemExtent: 200,
                itemAspectRatio: 4 / 5,
                gap: 12,
                horizontalBleed: 24,
                contentPadding: const EdgeInsetsDirectional.only(
                  start: 24,
                  end: 24,
                  bottom: 4,
                ),
                children: [
                  for (var i = 0; i < 6; i++) SizedBox(key: ValueKey(i)),
                ],
              ),
            ),
          ),
        ),
      );
      final strip = tester.getRect(find.byType(OiMediaStrip));
      final first = tester.getRect(find.byKey(const ValueKey(0)));
      expect(first.size, const Size(200, 250));
      expect(strip.height, 254);
      expect(first.top, strip.top);
      expect(
        direction == TextDirection.ltr ? first.left : first.right,
        direction == TextDirection.ltr ? strip.left : strip.right,
      );
      final viewport = tester.getRect(find.byType(SingleChildScrollView));
      expect(viewport.left, strip.left - 24);
      expect(viewport.right, strip.right + 24);
      controller.jumpTo(controller.position.maxScrollExtent);
      await tester.pump();
      final last = tester.getRect(find.byKey(const ValueKey(5)));
      expect(
        direction == TextDirection.ltr ? last.right : last.left,
        direction == TextDirection.ltr ? strip.right : strip.left,
      );
      expect(tester.takeException(), isNull);
    });
  }
}
