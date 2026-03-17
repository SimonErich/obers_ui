// Tests are internal; doc comments on local helpers are not required.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/foundation/oi_accessibility.dart';

/// Wraps [child] in a default [MediaQuery] and [Directionality].
Widget buildDefault(Widget child) {
  return MediaQuery(
    data: const MediaQueryData(),
    child: Directionality(textDirection: TextDirection.ltr, child: child),
  );
}

void main() {
  group('OiA11y', () {
    testWidgets('reducedMotion returns false by default', (tester) async {
      late bool result;
      await tester.pumpWidget(
        buildDefault(
          Builder(
            builder: (ctx) {
              result = OiA11y.reducedMotion(ctx);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(result, isFalse);
    });

    testWidgets('highContrast returns false by default', (tester) async {
      late bool result;
      await tester.pumpWidget(
        buildDefault(
          Builder(
            builder: (ctx) {
              result = OiA11y.highContrast(ctx);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(result, isFalse);
    });

    testWidgets('textScale returns 1.0 by default', (tester) async {
      late double result;
      await tester.pumpWidget(
        buildDefault(
          Builder(
            builder: (ctx) {
              result = OiA11y.textScale(ctx);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(result, 1.0);
    });

    testWidgets('boldText returns false by default', (tester) async {
      late bool result;
      await tester.pumpWidget(
        buildDefault(
          Builder(
            builder: (ctx) {
              result = OiA11y.boldText(ctx);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(result, isFalse);
    });
  });
}
