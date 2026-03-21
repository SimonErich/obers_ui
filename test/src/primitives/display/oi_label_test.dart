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
    testWidgets('renders display variant', (tester) async {
      await tester.pumpObers(const OiLabel.display('Hello'));
      expect(find.text('Hello'), findsOneWidget);
    });

    testWidgets('renders h1 variant', (tester) async {
      await tester.pumpObers(const OiLabel.h1('Hello'));
      expect(find.text('Hello'), findsOneWidget);
    });

    testWidgets('renders h2 variant', (tester) async {
      await tester.pumpObers(const OiLabel.h2('Hello'));
      expect(find.text('Hello'), findsOneWidget);
    });

    testWidgets('renders h3 variant', (tester) async {
      await tester.pumpObers(const OiLabel.h3('Hello'));
      expect(find.text('Hello'), findsOneWidget);
    });

    testWidgets('renders h4 variant', (tester) async {
      await tester.pumpObers(const OiLabel.h4('Hello'));
      expect(find.text('Hello'), findsOneWidget);
    });

    testWidgets('renders body variant', (tester) async {
      await tester.pumpObers(const OiLabel.body('Hello'));
      expect(find.text('Hello'), findsOneWidget);
    });

    testWidgets('renders bodyStrong variant', (tester) async {
      await tester.pumpObers(const OiLabel.bodyStrong('Hello'));
      expect(find.text('Hello'), findsOneWidget);
    });

    testWidgets('renders small variant', (tester) async {
      await tester.pumpObers(const OiLabel.small('Hello'));
      expect(find.text('Hello'), findsOneWidget);
    });

    testWidgets('renders smallStrong variant', (tester) async {
      await tester.pumpObers(const OiLabel.smallStrong('Hello'));
      expect(find.text('Hello'), findsOneWidget);
    });

    testWidgets('renders tiny variant', (tester) async {
      await tester.pumpObers(const OiLabel.tiny('Hello'));
      expect(find.text('Hello'), findsOneWidget);
    });

    testWidgets('renders caption variant', (tester) async {
      await tester.pumpObers(const OiLabel.caption('Hello'));
      expect(find.text('Hello'), findsOneWidget);
    });

    testWidgets('renders code variant', (tester) async {
      await tester.pumpObers(const OiLabel.code('Hello'));
      expect(find.text('Hello'), findsOneWidget);
    });

    testWidgets('renders overline variant', (tester) async {
      await tester.pumpObers(const OiLabel.overline('Hello'));
      expect(find.text('Hello'), findsOneWidget);
    });

    testWidgets('renders link variant', (tester) async {
      await tester.pumpObers(const OiLabel.link('Hello'));
      expect(find.text('Hello'), findsOneWidget);
    });
  });

  // ── maxLines / overflow ────────────────────────────────────────────────────

  testWidgets('applies maxLines and overflow', (tester) async {
    await tester.pumpObers(
      const OiLabel.body(
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
      const OiLabel.body('aligned', textAlign: TextAlign.center),
    );
    final textWidget = tester.widget<Text>(find.byType(Text));
    expect(textWidget.textAlign, TextAlign.center);
  });

  // ── semanticsLabel ────────────────────────────────────────────────────────

  testWidgets('semanticsLabel wraps in Semantics node with correct label', (
    tester,
  ) async {
    await tester.pumpObers(
      const OiLabel.body('visible text', semanticsLabel: 'accessible label'),
    );
    // Filter Semantics widgets to find the one OiLabel inserts.
    final semanticsWidgets = tester.widgetList<Semantics>(
      find.byType(Semantics),
    );
    final matching = semanticsWidgets
        .where((s) => s.properties.label == 'accessible label')
        .toList();
    expect(matching, hasLength(1));
  });

  // ── selectable ────────────────────────────────────────────────────────────

  testWidgets('selectable wraps in SelectableRegion', (tester) async {
    await tester.pumpObers(const OiLabel.body('select me', selectable: true));
    expect(find.byType(SelectableRegion), findsOneWidget);
  });

  testWidgets('non-selectable does not wrap in SelectableRegion', (
    tester,
  ) async {
    await tester.pumpObers(const OiLabel.body('normal text'));
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

    await tester.pumpObers(const OiLabel.body('copy me', copyable: true));
    await tester.tap(find.text('copy me'));
    await tester.pump();

    expect(copiedText, 'copy me');

    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      null,
    );
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

    await tester.pumpObers(const OiLabel.body('no copy'));
    await tester.tap(find.text('no copy'));
    await tester.pump();
    expect(copiedText, isNull);

    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      null,
    );
  });

  // ── Responsive font scaling ───────────────────────────────────────────────
  //
  // We pump with an explicit MediaQuery so we control the reported width
  // independently of the WidgetsApp view sizing.

  group('responsive font scaling', () {
    Future<double> resolvedFontSize(
      WidgetTester tester,
      OiLabelVariant variant,
      Widget label,
      double width,
    ) async {
      final theme = OiThemeData.light();
      await tester.pumpWidget(
        MediaQuery(
          data: MediaQueryData(size: Size(width, 800)),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: OiTheme(data: theme, child: label),
          ),
        ),
      );
      final textWidget = tester.widget<Text>(find.text('scale test'));
      return textWidget.style?.fontSize ??
          theme.textTheme.styleFor(variant).fontSize!;
    }

    for (final entry in <OiLabelVariant, Widget>{
      OiLabelVariant.display: const OiLabel.display('scale test'),
      OiLabelVariant.h1: const OiLabel.h1('scale test'),
      OiLabelVariant.h2: const OiLabel.h2('scale test'),
    }.entries) {
      final variant = entry.key;
      final label = entry.value;
      final theme = OiThemeData.light();
      final baseSize = theme.textTheme.styleFor(variant).fontSize!;

      testWidgets('$variant compact (400dp) → ×1.0', (tester) async {
        final size = await resolvedFontSize(tester, variant, label, 400);
        expect(size, closeTo(baseSize * 1.0, 0.01));
      });

      testWidgets('$variant medium (700dp) → ×1.1', (tester) async {
        final size = await resolvedFontSize(tester, variant, label, 700);
        expect(size, closeTo(baseSize * 1.1, 0.01));
      });

      testWidgets('$variant expanded (900dp) → ×1.2', (tester) async {
        final size = await resolvedFontSize(tester, variant, label, 900);
        expect(size, closeTo(baseSize * 1.2, 0.01));
      });
    }

    testWidgets('body variant does not scale at expanded (900dp)', (
      tester,
    ) async {
      final theme = OiThemeData.light();
      final baseSize = theme.textTheme.styleFor(OiLabelVariant.body).fontSize!;
      final size = await resolvedFontSize(
        tester,
        OiLabelVariant.body,
        const OiLabel.body('scale test'),
        900,
      );
      expect(size, closeTo(baseSize, 0.01));
    });
  });
}
