// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/foundation/theme/oi_decoration_theme.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme_data.dart';
import 'package:obers_ui/src/primitives/display/oi_divider.dart';

import '../../../helpers/pump_app.dart';

// ── helpers ──────────────────────────────────────────────────────────────────

/// Returns the first [Container] that is a direct product of OiDivider's solid
/// line — identifiable by having a non-null [color] and being very thin.
Container? _solidLineContainer(WidgetTester tester) {
  final containers = tester.widgetList<Container>(find.byType(Container));
  for (final c in containers) {
    final d = c.decoration;
    // OiDivider's solid line Container has a `color:` argument, not decoration.
    if (c.color != null) return c;
    if (d is BoxDecoration && d.color != null) return c;
  }
  return null;
}

void main() {
  // ── Horizontal solid divider ───────────────────────────────────────────────

  testWidgets('horizontal solid divider renders a thin Container', (tester) async {
    await tester.pumpObers(const OiDivider());
    final c = _solidLineContainer(tester);
    expect(c, isNotNull);
  });

  testWidgets('horizontal solid divider height equals thickness', (tester) async {
    await tester.pumpObers(
      const OiDivider(key: ValueKey('div'), thickness: 2),
    );
    // The line Container declares its height via BoxConstraints.
    final containerFinder = find.descendant(
      of: find.byKey(const ValueKey('div')),
      matching: find.byWidgetPredicate((w) => w is Container && w.color != null),
    );
    expect(containerFinder, findsOneWidget);
    final c = tester.widget<Container>(containerFinder);
    expect(c.constraints?.minHeight, 2.0);
    expect(c.constraints?.maxHeight, 2.0);
  });

  testWidgets('uses provided color', (tester) async {
    await tester.pumpObers(
      const OiDivider(color: Color(0xFFFF0000)),
    );
    final c = _solidLineContainer(tester)!;
    expect(c.color, const Color(0xFFFF0000));
  });

  testWidgets('defaults to theme border color when color is null', (tester) async {
    final theme = OiThemeData.light();
    await tester.pumpObers(const OiDivider());
    final c = _solidLineContainer(tester)!;
    expect(c.color, theme.colors.border);
  });

  // ── Vertical solid divider ────────────────────────────────────────────────

  testWidgets('vertical solid divider declares width equal to thickness', (tester) async {
    await tester.pumpObers(
      const SizedBox(
        height: 100,
        child: OiDivider(key: ValueKey('div'), axis: Axis.vertical),
      ),
    );
    // The vertical line Container declares its width via BoxConstraints.
    final containerFinder = find.descendant(
      of: find.byKey(const ValueKey('div')),
      matching: find.byWidgetPredicate((w) => w is Container && w.color != null),
    );
    expect(containerFinder, findsOneWidget);
    final c = tester.widget<Container>(containerFinder);
    expect(c.constraints?.minWidth, 1.0);
    expect(c.constraints?.maxWidth, 1.0);
  });

  // ── Dashed / dotted border — CustomPaint ──────────────────────────────────

  testWidgets('dashed style uses CustomPaint', (tester) async {
    await tester.pumpObers(
      const OiDivider(
        key: ValueKey('div'),
        style: OiBorderLineStyle.dashed,
      ),
    );
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('div')),
        matching: find.byType(CustomPaint),
      ),
      findsOneWidget,
    );
  });

  testWidgets('dashed style produces no solid Container line', (tester) async {
    await tester.pumpObers(
      const OiDivider(style: OiBorderLineStyle.dashed),
    );
    // No Container with a direct color (the solid-line path) should exist.
    expect(_solidLineContainer(tester), isNull);
  });

  testWidgets('dotted style uses CustomPaint', (tester) async {
    await tester.pumpObers(
      const OiDivider(
        key: ValueKey('div'),
        style: OiBorderLineStyle.dotted,
      ),
    );
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('div')),
        matching: find.byType(CustomPaint),
      ),
      findsOneWidget,
    );
  });

  // ── withLabel ─────────────────────────────────────────────────────────────

  testWidgets('withLabel renders the label text', (tester) async {
    await tester.pumpObers(
      const OiDivider.withLabel('Section'),
    );
    expect(find.text('Section'), findsOneWidget);
  });

  testWidgets('withLabel uses a Row for horizontal axis', (tester) async {
    await tester.pumpObers(
      const OiDivider.withLabel('OR'),
    );
    expect(find.byType(Row), findsOneWidget);
  });

  testWidgets('withLabel flanks text with two line widgets', (tester) async {
    await tester.pumpObers(
      const OiDivider.withLabel('OR'),
    );
    // Two Expanded children inside the Row each hold a solid line Container.
    final expanded = tester.widgetList<Expanded>(find.byType(Expanded));
    expect(expanded.length, greaterThanOrEqualTo(2));
  });

  testWidgets('withLabel on vertical axis uses a Column', (tester) async {
    await tester.pumpObers(
      const SizedBox(
        width: 40,
        height: 200,
        child: OiDivider.withLabel('▼', axis: Axis.vertical),
      ),
    );
    expect(find.byType(Column), findsOneWidget);
  });

  // ── withContent ───────────────────────────────────────────────────────────

  testWidgets('withContent renders the provided child widget', (tester) async {
    await tester.pumpObers(
      const OiDivider.withContent(Icon(IconData(0xe000))),
    );
    expect(find.byType(Icon), findsOneWidget);
  });

  testWidgets('withContent uses a Row for horizontal axis', (tester) async {
    await tester.pumpObers(
      const OiDivider.withContent(SizedBox(width: 20, height: 20)),
    );
    expect(find.byType(Row), findsOneWidget);
  });

  // ── spacing ───────────────────────────────────────────────────────────────

  testWidgets('spacing > 0 wraps divider in Padding', (tester) async {
    await tester.pumpObers(
      const OiDivider(spacing: 16),
    );
    expect(find.byType(Padding), findsAtLeastNWidgets(1));
  });

  testWidgets('spacing == 0 does not add extra Padding', (tester) async {
    await tester.pumpObers(
      const OiDivider(),
    );
    expect(find.byType(Padding), findsNothing);
  });

  // ── context extension color resolution ───────────────────────────────────

  testWidgets('color resolution uses context.colors.border', (tester) async {
    final theme = OiThemeData.light();
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(size: Size(400, 800)),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: OiTheme(
            data: theme,
            child: const OiDivider(),
          ),
        ),
      ),
    );
    final c = _solidLineContainer(tester)!;
    expect(c.color, theme.colors.border);
  });
}
