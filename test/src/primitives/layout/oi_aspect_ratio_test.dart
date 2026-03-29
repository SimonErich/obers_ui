// Tests do not require documentation comments.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/foundation/oi_responsive.dart';
import 'package:obers_ui/src/primitives/layout/oi_aspect_ratio.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('renders child', (tester) async {
    await tester.pumpObers(
      const OiAspectRatio(
        breakpoint: OiBreakpoint.compact,
        ratio: OiResponsive<double>(16 / 9),
        child: ColoredBox(color: Color(0xFF000000)),
      ),
    );
    expect(find.byType(AspectRatio), findsOneWidget);
    expect(find.byType(ColoredBox), findsAtLeastNWidgets(1));
  });

  testWidgets('passes ratio to AspectRatio', (tester) async {
    await tester.pumpObers(
      const OiAspectRatio(
        breakpoint: OiBreakpoint.compact,
        ratio: OiResponsive<double>(4 / 3),
        child: ColoredBox(color: Color(0xFF000000)),
      ),
    );
    final ar = tester.widget<AspectRatio>(find.byType(AspectRatio));
    expect(ar.aspectRatio, closeTo(4 / 3, 0.001));
  });

  testWidgets('1:1 ratio passes through correctly', (tester) async {
    await tester.pumpObers(
      const OiAspectRatio(
        breakpoint: OiBreakpoint.compact,
        ratio: OiResponsive<double>(1),
        child: ColoredBox(color: Color(0xFF000000)),
      ),
    );
    final ar = tester.widget<AspectRatio>(find.byType(AspectRatio));
    expect(ar.aspectRatio, 1.0);
  });

  // ── Responsive ratio ───────────────────────────────────────────────────────

  testWidgets('responsive ratio resolves per breakpoint', (tester) async {
    final responsiveRatio = OiResponsive<double>.breakpoints({
      OiBreakpoint.compact: 4 / 3,
      OiBreakpoint.expanded: 16 / 9,
    });

    // At compact breakpoint → 4:3
    await tester.pumpObers(
      OiAspectRatio(
        breakpoint: OiBreakpoint.compact,
        ratio: responsiveRatio,
        child: const ColoredBox(color: Color(0xFF000000)),
      ),
    );
    var ar = tester.widget<AspectRatio>(find.byType(AspectRatio));
    expect(ar.aspectRatio, closeTo(4 / 3, 0.001));

    // At expanded breakpoint → 16:9
    await tester.pumpObers(
      OiAspectRatio(
        breakpoint: OiBreakpoint.expanded,
        ratio: responsiveRatio,
        child: const ColoredBox(color: Color(0xFF000000)),
      ),
    );
    ar = tester.widget<AspectRatio>(find.byType(AspectRatio));
    expect(ar.aspectRatio, closeTo(16 / 9, 0.001));
  });

  testWidgets('responsive ratio cascades to nearest smaller breakpoint', (
    tester,
  ) async {
    final responsiveRatio = OiResponsive<double>.breakpoints({
      OiBreakpoint.compact: 1,
      OiBreakpoint.large: 16 / 9,
    });

    // medium has no explicit value → cascades to compact → 1:1
    await tester.pumpObers(
      OiAspectRatio(
        breakpoint: OiBreakpoint.medium,
        ratio: responsiveRatio,
        child: const ColoredBox(color: Color(0xFF000000)),
      ),
    );
    final ar = tester.widget<AspectRatio>(find.byType(AspectRatio));
    expect(ar.aspectRatio, 1.0);
  });
}
