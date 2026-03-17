// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/foundation/theme/oi_text_theme.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme_data.dart';
import 'package:obers_ui/src/primitives/display/oi_label.dart';

import '../../../helpers/pump_app.dart';

void main() {
  // ── Variant rendering ──────────────────────────────────────────────────────

  group('OiLabel variant rendering', () {
    for (final variant in OiLabelVariant.values) {
      testWidgets('renders $variant variant', (tester) async {
        await tester.pumpObers(OiLabel('Hello', variant: variant));
        expect(find.text('Hello'), findsOneWidget);
      });
    }
  });

  // ── maxLines / overflow ────────────────────────────────────────────────────

  testWidgets('applies maxLines and overflow', (tester) async {
    await tester.pumpObers(
      const OiLabel(
        'long text',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
    final textWidget = tester.widget<Text>(find.byType(Text));
    expect(textWidget.maxLines, 1);
    expect(textWidget.overflow, TextOverflow.ellipsis);
  });

  // ── textAlign ─────────────────────────────────────────────────────────────

  testWidgets('applies textAlign', (tester) async {
    await tester.pumpObers(
      const OiLabel('aligned', textAlign: TextAlign.center),
    );
    final textWidget = tester.widget<Text>(find.byType(Text));
    expect(textWidget.textAlign, TextAlign.center);
  });

  // ── semanticsLabel ────────────────────────────────────────────────────────

  testWidgets('semanticsLabel wraps in Semantics node with correct label',
      (tester) async {
    await tester.pumpObers(
      const OiLabel('visible text', semanticsLabel: 'accessible label'),
    );
    // Filter Semantics widgets to find the one OiLabel inserts.
    final semanticsWidgets =
        tester.widgetList<Semantics>(find.byType(Semantics));
    final matching = semanticsWidgets
        .where((s) => s.properties.label == 'accessible label')
        .toList();
    expect(matching, hasLength(1));
  });

  // ── selectable ────────────────────────────────────────────────────────────

  testWidgets('selectable wraps in SelectableRegion', (tester) async {
    await tester.pumpObers(
      const OiLabel('select me', selectable: true),
    );
    expect(find.byType(SelectableRegion), findsOneWidget);
  });

  testWidgets('non-selectable does not wrap in SelectableRegion',
      (tester) async {
    await tester.pumpObers(const OiLabel('normal text'));
    expect(find.byType(SelectableRegion), findsNothing);
  });

  // ── copyable ──────────────────────────────────────────────────────────────

  testWidgets('copyable copies text to clipboard on tap', (tester) async {
    String? copiedText;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          copiedText = (call.arguments as Map)['text'] as String;
        }
        return null;
      },
    );

    await tester.pumpObers(
      const OiLabel('copy me', copyable: true),
    );
    await tester.tap(find.text('copy me'));
    await tester.pump();

    expect(copiedText, 'copy me');

    tester.binding.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  testWidgets('non-copyable does not copy on tap', (tester) async {
    String? copiedText;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          copiedText = (call.arguments as Map)['text'] as String;
        }
        return null;
      },
    );

    await tester.pumpObers(const OiLabel('no copy'));
    await tester.tap(find.text('no copy'));
    await tester.pump();
    expect(copiedText, isNull);

    tester.binding.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  // ── Responsive font scaling ───────────────────────────────────────────────
  //
  // We pump with an explicit MediaQuery so we control the reported width
  // independently of the WidgetsApp view sizing.

  group('responsive font scaling', () {
    Future<double> resolvedFontSize(
      WidgetTester tester,
      OiLabelVariant variant,
      double width,
    ) async {
      final theme = OiThemeData.light();
      await tester.pumpWidget(
        MediaQuery(
          data: MediaQueryData(size: Size(width, 800)),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: OiTheme(
              data: theme,
              child: OiLabel('scale test', variant: variant),
            ),
          ),
        ),
      );
      final textWidget = tester.widget<Text>(find.text('scale test'));
      return textWidget.style?.fontSize ??
          theme.textTheme.styleFor(variant).fontSize!;
    }

    for (final variant in [
      OiLabelVariant.display,
      OiLabelVariant.h1,
      OiLabelVariant.h2,
    ]) {
      final theme = OiThemeData.light();
      final baseSize = theme.textTheme.styleFor(variant).fontSize!;

      testWidgets('$variant compact (400dp) → ×1.0', (tester) async {
        final size = await resolvedFontSize(tester, variant, 400);
        expect(size, closeTo(baseSize * 1.0, 0.01));
      });

      testWidgets('$variant medium (700dp) → ×1.1', (tester) async {
        final size = await resolvedFontSize(tester, variant, 700);
        expect(size, closeTo(baseSize * 1.1, 0.01));
      });

      testWidgets('$variant expanded (900dp) → ×1.2', (tester) async {
        final size = await resolvedFontSize(tester, variant, 900);
        expect(size, closeTo(baseSize * 1.2, 0.01));
      });
    }

    testWidgets('body variant does not scale at expanded (900dp)',
        (tester) async {
      final theme = OiThemeData.light();
      final baseSize =
          theme.textTheme.styleFor(OiLabelVariant.body).fontSize!;
      final size = await resolvedFontSize(tester, OiLabelVariant.body, 900);
      expect(size, closeTo(baseSize, 0.01));
    });
  });
}
