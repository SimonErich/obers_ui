// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/foundation/oi_responsive.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme_data.dart';
import 'package:obers_ui/src/primitives/layout/oi_container.dart';

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
  // ── Rendering ──────────────────────────────────────────────────────────────

  testWidgets('renders child', (tester) async {
    await tester.pumpObers(
      const OiContainer(
        breakpoint: OiBreakpoint.compact,
        child: Text('hello'),
      ),
    );
    expect(find.text('hello'), findsOneWidget);
  });

  testWidgets('renders without child', (tester) async {
    await tester.pumpObers(
      const OiContainer(breakpoint: OiBreakpoint.compact),
    );
    expect(find.byType(OiContainer), findsOneWidget);
  });

  // ── maxWidth constraint ────────────────────────────────────────────────────

  testWidgets('applies maxWidth via ConstrainedBox', (tester) async {
    await tester.pumpObers(
      const OiContainer(
        breakpoint: OiBreakpoint.compact,
        maxWidth: OiResponsive<double>(300),
        child: Text('x'),
      ),
    );
    final boxes = tester
        .widgetList<ConstrainedBox>(find.byType(ConstrainedBox))
        .where((b) => b.constraints.maxWidth == 300)
        .toList();
    expect(boxes, hasLength(1));
  });

  testWidgets('maxWidth defaults to infinity when not set', (tester) async {
    await tester.pumpObers(
      const OiContainer(
        breakpoint: OiBreakpoint.compact,
        child: Text('x'),
      ),
    );
    final boxes = tester
        .widgetList<ConstrainedBox>(find.byType(ConstrainedBox))
        .where((b) => b.constraints.maxWidth == double.infinity)
        .toList();
    expect(boxes, isNotEmpty);
  });

  // ── Padding ────────────────────────────────────────────────────────────────

  testWidgets('applies padding when provided', (tester) async {
    await tester.pumpObers(
      const OiContainer(
        breakpoint: OiBreakpoint.compact,
        padding: OiResponsive<EdgeInsetsGeometry>(EdgeInsets.all(16)),
        child: Text('padded'),
      ),
    );
    final padding = tester.widget<Padding>(find.byType(Padding));
    expect(padding.padding, const EdgeInsets.all(16));
  });

  testWidgets('no Padding widget when padding is null', (tester) async {
    await tester.pumpObers(
      const OiContainer(
        breakpoint: OiBreakpoint.compact,
        child: Text('no pad'),
      ),
    );
    expect(find.byType(Padding), findsNothing);
  });

  // ── Centering ─────────────────────────────────────────────────────────────

  testWidgets('centered=true wraps in Center', (tester) async {
    await tester.pumpObers(
      const OiContainer(
        breakpoint: OiBreakpoint.compact,
        child: Text('centered'),
      ),
    );
    expect(find.byType(Center), findsOneWidget);
  });

  testWidgets('centered=false does not wrap in Center', (tester) async {
    await tester.pumpObers(
      const OiContainer(
        breakpoint: OiBreakpoint.compact,
        centered: false,
        child: Text('not centered'),
      ),
    );
    expect(find.byType(Center), findsNothing);
  });

  // ── Responsive layout props ───────────────────────────────────────────────

  group('responsive layout props', () {
    testWidgets('responsive maxWidth varies with breakpoint', (tester) async {
      final responsiveMaxWidth = OiResponsive<double>.breakpoints({
        OiBreakpoint.compact: double.infinity,
        OiBreakpoint.expanded: 960,
        OiBreakpoint.large: 1200,
      });

      // Compact → maxWidth infinity.
      await pumpAtWidth(
        tester,
        OiContainer(
          breakpoint: OiBreakpoint.compact,
          maxWidth: responsiveMaxWidth,
          child: const Text('x'),
        ),
        400,
      );
      var boxes = tester
          .widgetList<ConstrainedBox>(find.byType(ConstrainedBox))
          .toList();
      expect(boxes.any((b) => b.constraints.maxWidth == double.infinity), isTrue);

      // Expanded → maxWidth 960.
      await pumpAtWidth(
        tester,
        OiContainer(
          breakpoint: OiBreakpoint.expanded,
          maxWidth: responsiveMaxWidth,
          child: const Text('x'),
        ),
        900,
      );
      boxes = tester
          .widgetList<ConstrainedBox>(find.byType(ConstrainedBox))
          .toList();
      expect(boxes.any((b) => b.constraints.maxWidth == 960), isTrue);

      // Large → maxWidth 1200.
      await pumpAtWidth(
        tester,
        OiContainer(
          breakpoint: OiBreakpoint.large,
          maxWidth: responsiveMaxWidth,
          child: const Text('x'),
        ),
        1300,
      );
      boxes = tester
          .widgetList<ConstrainedBox>(find.byType(ConstrainedBox))
          .toList();
      expect(boxes.any((b) => b.constraints.maxWidth == 1200), isTrue);
    });

    testWidgets('responsive padding varies with breakpoint', (tester) async {
      final responsivePadding =
          OiResponsive<EdgeInsetsGeometry>.breakpoints({
        OiBreakpoint.compact: const EdgeInsets.all(8),
        OiBreakpoint.expanded: const EdgeInsets.all(24),
      });

      // Compact → padding 8.
      await pumpAtWidth(
        tester,
        OiContainer(
          breakpoint: OiBreakpoint.compact,
          padding: responsivePadding,
          child: const Text('padded'),
        ),
        400,
      );
      var padding = tester.widget<Padding>(find.byType(Padding));
      expect(padding.padding, const EdgeInsets.all(8));

      // Expanded → padding 24.
      await pumpAtWidth(
        tester,
        OiContainer(
          breakpoint: OiBreakpoint.expanded,
          padding: responsivePadding,
          child: const Text('padded'),
        ),
        900,
      );
      padding = tester.widget<Padding>(find.byType(Padding));
      expect(padding.padding, const EdgeInsets.all(24));
    });
  });

  // ── Explicit breakpoint parameter ─────────────────────────────────────────

  group('explicit breakpoint parameter', () {
    testWidgets('breakpoint param overrides context breakpoint for maxWidth', (
      tester,
    ) async {
      final responsiveMaxWidth = OiResponsive<double>.breakpoints({
        OiBreakpoint.compact: double.infinity,
        OiBreakpoint.large: 1200,
      });

      // Screen is compact-width (400), but breakpoint is explicitly large.
      await pumpAtWidth(
        tester,
        OiContainer(
          maxWidth: responsiveMaxWidth,
          breakpoint: OiBreakpoint.large,
          child: const Text('x'),
        ),
        400,
      );
      final boxes = tester
          .widgetList<ConstrainedBox>(find.byType(ConstrainedBox))
          .toList();
      expect(boxes.any((b) => b.constraints.maxWidth == 1200), isTrue);
    });

    testWidgets('breakpoint param resolves padding correctly', (
      tester,
    ) async {
      final responsivePadding =
          OiResponsive<EdgeInsetsGeometry>.breakpoints({
        OiBreakpoint.compact: const EdgeInsets.all(8),
        OiBreakpoint.expanded: const EdgeInsets.all(32),
      });

      // Screen is compact-width (400), but breakpoint is explicitly expanded.
      await pumpAtWidth(
        tester,
        OiContainer(
          padding: responsivePadding,
          breakpoint: OiBreakpoint.expanded,
          child: const Text('padded'),
        ),
        400,
      );
      final padding = tester.widget<Padding>(find.byType(Padding));
      expect(padding.padding, const EdgeInsets.all(32));
    });
  });
}
