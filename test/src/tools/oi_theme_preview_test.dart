// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/buttons/oi_button.dart';
import 'package:obers_ui/src/components/display/oi_badge.dart';
import 'package:obers_ui/src/components/display/oi_card.dart';
import 'package:obers_ui/src/components/display/oi_progress.dart';
import 'package:obers_ui/src/components/inputs/oi_number_input.dart';
import 'package:obers_ui/src/components/inputs/oi_text_input.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme_data.dart';
import 'package:obers_ui/src/tools/oi_theme_preview.dart';

import '../../helpers/pump_app.dart';

void main() {
  group('OiThemePreview', () {
    testWidgets('renders without errors', (tester) async {
      await tester.pumpObers(
        OiThemePreview(theme: OiThemeData.light()),
        surfaceSize: const Size(1200, 3000),
      );

      expect(find.byType(OiThemePreview), findsOneWidget);
    });

    testWidgets('wraps content in OiTheme with provided theme', (tester) async {
      final theme = OiThemeData.dark();

      await tester.pumpObers(
        OiThemePreview(theme: theme),
        surfaceSize: const Size(1200, 3000),
      );

      // The OiThemePreview wraps its content in an OiTheme.
      final oiTheme = tester.widget<OiTheme>(
        find.descendant(
          of: find.byType(OiThemePreview),
          matching: find.byType(OiTheme),
        ),
      );
      expect(oiTheme.data, equals(theme));
    });

    testWidgets('color section shows color swatches', (tester) async {
      await tester.pumpObers(
        OiThemePreview(theme: OiThemeData.light()),
        surfaceSize: const Size(1200, 3000),
      );

      // The "Colors" heading should be visible.
      expect(find.text('Colors'), findsOneWidget);

      // Swatch labels should appear.
      expect(find.text('Primary'), findsOneWidget);
      expect(find.text('Accent'), findsOneWidget);
      expect(find.text('Success'), findsOneWidget);
      expect(find.text('Warning'), findsOneWidget);
      expect(find.text('Error'), findsOneWidget);
      expect(find.text('Info'), findsOneWidget);
    });

    testWidgets('typography section shows text variants', (tester) async {
      await tester.pumpObers(
        OiThemePreview(theme: OiThemeData.light()),
        surfaceSize: const Size(1200, 3000),
      );

      expect(find.text('Typography'), findsOneWidget);
      expect(find.text('display: The quick brown fox'), findsOneWidget);
      expect(find.text('body: The quick brown fox'), findsOneWidget);
      expect(find.text('h1: The quick brown fox'), findsOneWidget);
    });

    testWidgets('spacing section shows spacing blocks', (tester) async {
      await tester.pumpObers(
        OiThemePreview(theme: OiThemeData.light()),
        surfaceSize: const Size(1200, 3000),
      );

      expect(find.text('Spacing'), findsOneWidget);
      expect(find.text('xs (4)'), findsOneWidget);
      expect(find.text('md (16)'), findsOneWidget);
      expect(find.text('xxl (48)'), findsOneWidget);
    });

    testWidgets('buttons section shows button variants', (tester) async {
      await tester.pumpObers(
        OiThemePreview(theme: OiThemeData.light()),
        surfaceSize: const Size(1200, 3000),
      );

      expect(find.text('Buttons'), findsOneWidget);
      expect(find.byType(OiButton), findsWidgets);
    });

    testWidgets('inputs section shows inputs', (tester) async {
      await tester.pumpObers(
        OiThemePreview(theme: OiThemeData.light()),
        surfaceSize: const Size(1200, 3000),
      );

      expect(find.text('Inputs'), findsOneWidget);
      expect(find.byType(OiTextInput), findsWidgets);
      expect(find.byType(OiNumberInput), findsOneWidget);
    });

    testWidgets('cards section shows card variants', (tester) async {
      await tester.pumpObers(
        OiThemePreview(theme: OiThemeData.light()),
        surfaceSize: const Size(1200, 3000),
      );

      expect(find.text('Cards'), findsOneWidget);
      expect(find.byType(OiCard), findsWidgets);
    });

    testWidgets('badges section shows badge variants', (tester) async {
      await tester.pumpObers(
        OiThemePreview(theme: OiThemeData.light()),
        surfaceSize: const Size(1200, 3000),
      );

      expect(find.text('Badges'), findsOneWidget);
      expect(find.byType(OiBadge), findsWidgets);
    });

    testWidgets('progress section shows progress indicators', (tester) async {
      await tester.pumpObers(
        OiThemePreview(theme: OiThemeData.light()),
        surfaceSize: const Size(1200, 3000),
      );

      expect(find.text('Progress'), findsOneWidget);
      expect(find.byType(OiProgress), findsWidgets);
    });

    group('show* flags', () {
      testWidgets('showColors=false hides color section', (tester) async {
        await tester.pumpObers(
          OiThemePreview(theme: OiThemeData.light(), showColors: false),
          surfaceSize: const Size(1200, 3000),
        );

        expect(find.text('Colors'), findsNothing);
      });

      testWidgets('showTypography=false hides typography section', (
        tester,
      ) async {
        await tester.pumpObers(
          OiThemePreview(theme: OiThemeData.light(), showTypography: false),
          surfaceSize: const Size(1200, 3000),
        );

        expect(find.text('Typography'), findsNothing);
      });

      testWidgets('showSpacing=false hides spacing section', (tester) async {
        await tester.pumpObers(
          OiThemePreview(theme: OiThemeData.light(), showSpacing: false),
          surfaceSize: const Size(1200, 3000),
        );

        expect(find.text('Spacing'), findsNothing);
      });

      testWidgets('showButtons=false hides buttons section', (tester) async {
        await tester.pumpObers(
          OiThemePreview(theme: OiThemeData.light(), showButtons: false),
          surfaceSize: const Size(1200, 3000),
        );

        expect(find.text('Buttons'), findsNothing);
      });

      testWidgets('showInputs=false hides inputs section', (tester) async {
        await tester.pumpObers(
          OiThemePreview(theme: OiThemeData.light(), showInputs: false),
          surfaceSize: const Size(1200, 3000),
        );

        expect(find.text('Inputs'), findsNothing);
      });

      testWidgets('showCards=false hides cards section', (tester) async {
        await tester.pumpObers(
          OiThemePreview(theme: OiThemeData.light(), showCards: false),
          surfaceSize: const Size(1200, 3000),
        );

        expect(find.text('Cards'), findsNothing);
      });

      testWidgets('showBadges=false hides badges section', (tester) async {
        await tester.pumpObers(
          OiThemePreview(theme: OiThemeData.light(), showBadges: false),
          surfaceSize: const Size(1200, 3000),
        );

        expect(find.text('Badges'), findsNothing);
      });

      testWidgets('showProgress=false hides progress section', (tester) async {
        await tester.pumpObers(
          OiThemePreview(theme: OiThemeData.light(), showProgress: false),
          surfaceSize: const Size(1200, 3000),
        );

        expect(find.text('Progress'), findsNothing);
      });
    });
  });
}
