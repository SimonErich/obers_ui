// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/foundation/oi_responsive.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme_data.dart';
import 'package:obers_ui/src/primitives/layout/oi_wrap_layout.dart';

import '../../../helpers/pump_app.dart';

Future<void> pumpAtWidth(
  WidgetTester tester,
  Widget widget,
  double width,
) async {
  await tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(size: Size(width, 800)),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: OiTheme(data: OiThemeData.light(), child: widget),
      ),
    ),
  );
}

void main() {
  testWidgets('renders children inside a Wrap', (tester) async {
    await tester.pumpObers(
      const OiWrapLayout(
        breakpoint: OiBreakpoint.compact,
        children: [Text('A'), Text('B'), Text('C')],
      ),
    );
    expect(find.byType(Wrap), findsOneWidget);
    expect(find.text('A'), findsOneWidget);
    expect(find.text('B'), findsOneWidget);
    expect(find.text('C'), findsOneWidget);
  });

  testWidgets('passes spacing and runSpacing to Wrap', (tester) async {
    await tester.pumpObers(
      const OiWrapLayout(
        breakpoint: OiBreakpoint.compact,
        spacing: OiResponsive<double>(8),
        runSpacing: OiResponsive<double>(16),
        children: [Text('X')],
      ),
    );
    final wrap = tester.widget<Wrap>(find.byType(Wrap));
    expect(wrap.spacing, 8);
    expect(wrap.runSpacing, 16);
  });

  testWidgets('passes alignment to Wrap', (tester) async {
    await tester.pumpObers(
      const OiWrapLayout(
        breakpoint: OiBreakpoint.compact,
        alignment: WrapAlignment.center,
        children: [Text('X')],
      ),
    );
    final wrap = tester.widget<Wrap>(find.byType(Wrap));
    expect(wrap.alignment, WrapAlignment.center);
  });

  testWidgets('passes direction to Wrap', (tester) async {
    await tester.pumpObers(
      const OiWrapLayout(
        breakpoint: OiBreakpoint.compact,
        direction: Axis.vertical,
        children: [Text('X')],
      ),
    );
    final wrap = tester.widget<Wrap>(find.byType(Wrap));
    expect(wrap.direction, Axis.vertical);
  });

  // ── Responsive spacing ──────────────────────────────────────────────────

  group('responsive spacing', () {
    testWidgets('spacing varies with breakpoint', (tester) async {
      final responsiveSpacing = OiResponsive<double>.breakpoints({
        OiBreakpoint.compact: 4,
        OiBreakpoint.expanded: 16,
      });

      // Compact → spacing 4.
      await pumpAtWidth(
        tester,
        OiWrapLayout(
          breakpoint: OiBreakpoint.compact,
          spacing: responsiveSpacing,
          children: const [Text('A'), Text('B')],
        ),
        400,
      );
      var wrap = tester.widget<Wrap>(find.byType(Wrap));
      expect(wrap.spacing, 4);

      // Expanded → spacing 16.
      await pumpAtWidth(
        tester,
        OiWrapLayout(
          breakpoint: OiBreakpoint.expanded,
          spacing: responsiveSpacing,
          children: const [Text('A'), Text('B')],
        ),
        900,
      );
      wrap = tester.widget<Wrap>(find.byType(Wrap));
      expect(wrap.spacing, 16);
    });

    testWidgets('runSpacing varies with breakpoint', (tester) async {
      final responsiveRunSpacing = OiResponsive<double>.breakpoints({
        OiBreakpoint.compact: 8,
        OiBreakpoint.large: 24,
      });

      // Compact → runSpacing 8.
      await pumpAtWidth(
        tester,
        OiWrapLayout(
          breakpoint: OiBreakpoint.compact,
          runSpacing: responsiveRunSpacing,
          children: const [Text('A')],
        ),
        400,
      );
      var wrap = tester.widget<Wrap>(find.byType(Wrap));
      expect(wrap.runSpacing, 8);

      // Large → runSpacing 24.
      await pumpAtWidth(
        tester,
        OiWrapLayout(
          breakpoint: OiBreakpoint.large,
          runSpacing: responsiveRunSpacing,
          children: const [Text('A')],
        ),
        1300,
      );
      wrap = tester.widget<Wrap>(find.byType(Wrap));
      expect(wrap.runSpacing, 24);
    });
  });

  // ── Explicit breakpoint parameter ─────────────────────────────────────────

  group('explicit breakpoint parameter', () {
    testWidgets('breakpoint param overrides context for spacing', (
      tester,
    ) async {
      final responsiveSpacing = OiResponsive<double>.breakpoints({
        OiBreakpoint.compact: 4,
        OiBreakpoint.expanded: 16,
      });

      // Screen is compact-width (400), but breakpoint is explicitly expanded.
      await pumpAtWidth(
        tester,
        OiWrapLayout(
          spacing: responsiveSpacing,
          breakpoint: OiBreakpoint.expanded,
          children: const [Text('A'), Text('B')],
        ),
        400,
      );
      final wrap = tester.widget<Wrap>(find.byType(Wrap));
      expect(wrap.spacing, 16);
    });

    testWidgets('breakpoint param overrides context for runSpacing', (
      tester,
    ) async {
      final responsiveRunSpacing = OiResponsive<double>.breakpoints({
        OiBreakpoint.compact: 8,
        OiBreakpoint.large: 24,
      });

      // Screen is compact-width (400), but breakpoint is explicitly large.
      await pumpAtWidth(
        tester,
        OiWrapLayout(
          runSpacing: responsiveRunSpacing,
          breakpoint: OiBreakpoint.large,
          children: const [Text('A')],
        ),
        400,
      );
      final wrap = tester.widget<Wrap>(find.byType(Wrap));
      expect(wrap.runSpacing, 24);
    });
  });
}
