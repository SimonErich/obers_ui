// Tests are internal; doc comments on local helpers are not required.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme_data.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme_scope.dart';

Widget buildWithTheme(Widget child, {OiThemeData? theme}) {
  return OiTheme(
    data: theme ?? OiThemeData.light(),
    child: Directionality(textDirection: TextDirection.ltr, child: child),
  );
}

void main() {
  group('OiTheme', () {
    testWidgets('of(context) returns the injected theme', (tester) async {
      late OiThemeData captured;
      final injected = OiThemeData.light();

      await tester.pumpWidget(
        buildWithTheme(
          Builder(
            builder: (context) {
              captured = OiTheme.of(context);
              return const SizedBox.shrink();
            },
          ),
          theme: injected,
        ),
      );

      expect(captured, equals(injected));
    });

    testWidgets('maybeOf(context) returns null when no OiTheme in tree', (
      tester,
    ) async {
      late OiThemeData? captured;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Builder(
            builder: (context) {
              captured = OiTheme.maybeOf(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(captured, isNull);
    });

    testWidgets('of(context) throws assertion error when no OiTheme in tree', (
      tester,
    ) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Builder(
            builder: (context) {
              expect(() => OiTheme.of(context), throwsAssertionError);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
    });

    testWidgets('context.theme returns the OiThemeData', (tester) async {
      late OiThemeData captured;
      final injected = OiThemeData.light();

      await tester.pumpWidget(
        buildWithTheme(
          Builder(
            builder: (context) {
              captured = context.theme;
              return const SizedBox.shrink();
            },
          ),
          theme: injected,
        ),
      );

      expect(captured, equals(injected));
    });

    testWidgets('context.colors returns the OiColorScheme', (tester) async {
      final injected = OiThemeData.light();

      await tester.pumpWidget(
        buildWithTheme(
          Builder(
            builder: (context) {
              expect(context.colors, equals(injected.colors));
              return const SizedBox.shrink();
            },
          ),
          theme: injected,
        ),
      );
    });

    testWidgets('context.textTheme returns the OiTextTheme', (tester) async {
      final injected = OiThemeData.light();

      await tester.pumpWidget(
        buildWithTheme(
          Builder(
            builder: (context) {
              expect(context.textTheme, equals(injected.textTheme));
              return const SizedBox.shrink();
            },
          ),
          theme: injected,
        ),
      );
    });

    testWidgets('context.spacing returns the OiSpacingScale', (tester) async {
      final injected = OiThemeData.light();

      await tester.pumpWidget(
        buildWithTheme(
          Builder(
            builder: (context) {
              expect(context.spacing, equals(injected.spacing));
              return const SizedBox.shrink();
            },
          ),
          theme: injected,
        ),
      );
    });

    testWidgets('context.effects returns the OiEffectsTheme', (tester) async {
      final injected = OiThemeData.light();

      await tester.pumpWidget(
        buildWithTheme(
          Builder(
            builder: (context) {
              expect(context.effects, equals(injected.effects));
              return const SizedBox.shrink();
            },
          ),
          theme: injected,
        ),
      );
    });

    testWidgets('OiThemeScope overrides the theme for its subtree', (
      tester,
    ) async {
      final outer = OiThemeData.light();
      final inner = OiThemeData.dark();
      late OiThemeData outerCaptured;
      late OiThemeData innerCaptured;

      await tester.pumpWidget(
        buildWithTheme(
          Column(
            children: [
              Builder(
                builder: (context) {
                  outerCaptured = OiTheme.of(context);
                  return const SizedBox.shrink();
                },
              ),
              OiThemeScope(
                data: inner,
                child: Builder(
                  builder: (context) {
                    innerCaptured = OiTheme.of(context);
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
          theme: outer,
        ),
      );

      expect(outerCaptured, equals(outer));
      expect(innerCaptured, equals(inner));
    });

    testWidgets('Changing OiTheme data triggers updateShouldNotify', (
      tester,
    ) async {
      var buildCount = 0;

      await tester.pumpWidget(
        buildWithTheme(
          Builder(
            builder: (context) {
              OiTheme.of(context); // subscribe
              buildCount++;
              return const SizedBox.shrink();
            },
          ),
          theme: OiThemeData.light(),
        ),
      );

      expect(buildCount, 1);

      await tester.pumpWidget(
        buildWithTheme(
          Builder(
            builder: (context) {
              OiTheme.of(context);
              buildCount++;
              return const SizedBox.shrink();
            },
          ),
          theme: OiThemeData.dark(),
        ),
      );

      expect(buildCount, 2);
    });

    test('updateShouldNotify returns false when data is equal', () {
      const child = SizedBox.shrink();
      final themeA = OiThemeData.light();
      final themeB = OiThemeData.light(); // equal value, different instance

      final widgetOld = OiTheme(data: themeA, child: child);
      final widgetNew = OiTheme(data: themeB, child: child);

      // updateShouldNotify should return false when the data is equal
      expect(widgetNew.updateShouldNotify(widgetOld), isFalse);
    });

    test('updateShouldNotify returns true when data differs', () {
      const child = SizedBox.shrink();
      final widgetOld = OiTheme(data: OiThemeData.light(), child: child);
      final widgetNew = OiTheme(data: OiThemeData.dark(), child: child);

      expect(widgetNew.updateShouldNotify(widgetOld), isTrue);
    });
  });
}
