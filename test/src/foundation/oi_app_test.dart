// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/foundation/oi_app.dart';
import 'package:obers_ui/src/foundation/oi_platform.dart';
import 'package:obers_ui/src/foundation/oi_undo_stack.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme_data.dart';

void main() {
  group('OiApp', () {
    testWidgets('provides OiTheme to descendants', (tester) async {
      late OiThemeData? capturedTheme;
      await tester.pumpWidget(
        OiApp(
          home: Builder(builder: (ctx) {
            capturedTheme = OiTheme.maybeOf(ctx);
            return const SizedBox();
          }),
        ),
      );
      expect(capturedTheme, isNotNull);
    });

    testWidgets('provides OiUndoStack to descendants', (tester) async {
      late OiUndoStack? captured;
      await tester.pumpWidget(
        OiApp(
          home: Builder(builder: (ctx) {
            captured = OiUndoStack.maybeOf(ctx);
            return const SizedBox();
          }),
        ),
      );
      expect(captured, isNotNull);
    });

    testWidgets('provides OiPlatform to descendants', (tester) async {
      late OiPlatformData? captured;
      await tester.pumpWidget(
        OiApp(
          home: Builder(builder: (ctx) {
            captured = OiPlatform.maybeOf(ctx);
            return const SizedBox();
          }),
        ),
      );
      expect(captured, isNotNull);
    });

    testWidgets('light themeMode uses light theme', (tester) async {
      final lightTheme = OiThemeData.light();
      late OiThemeData? captured;
      await tester.pumpWidget(
        OiApp(
          theme: lightTheme,
          themeMode: ThemeMode.light,
          home: Builder(builder: (ctx) {
            captured = OiTheme.maybeOf(ctx);
            return const SizedBox();
          }),
        ),
      );
      expect(captured?.isLight, isTrue);
    });

    testWidgets('dark themeMode uses dark theme', (tester) async {
      final darkTheme = OiThemeData.dark();
      late OiThemeData? captured;
      await tester.pumpWidget(
        OiApp(
          darkTheme: darkTheme,
          themeMode: ThemeMode.dark,
          home: Builder(builder: (ctx) {
            captured = OiTheme.maybeOf(ctx);
            return const SizedBox();
          }),
        ),
      );
      expect(captured?.isDark, isTrue);
    });

    testWidgets('OiDensityScope is provided', (tester) async {
      late OiDensity? captured;
      await tester.pumpWidget(
        OiApp(
          density: OiDensity.dense,
          home: Builder(builder: (ctx) {
            captured = OiDensityScope.of(ctx);
            return const SizedBox();
          }),
        ),
      );
      expect(captured, equals(OiDensity.dense));
    });
  });
}
