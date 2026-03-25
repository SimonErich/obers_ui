// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui_charts/src/components/oi_chart_surface.dart';
import 'package:obers_ui/src/foundation/theme/oi_decoration_theme.dart';
import 'package:obers_ui/src/foundation/theme/oi_effects_theme.dart';
import 'package:obers_ui/src/primitives/display/oi_surface.dart';

import '../../helpers/pump_chart_app.dart';

void main() {
  // ---------------------------------------------------------------------------
  // REQ-0108 — Card-like presentation
  // ---------------------------------------------------------------------------

  group('REQ-0108 — card-like presentation', () {
    testWidgets('renders child inside OiSurface', (tester) async {
      await tester.pumpChartApp(
        const OiChartSurface(child: Text('chart content')),
      );
      expect(find.text('chart content'), findsOneWidget);
      expect(find.byType(OiSurface), findsOneWidget);
    });

    testWidgets('card variant applies elevation shadows', (tester) async {
      await tester.pumpChartApp(
        const OiChartSurface(child: Text('chart')),
      );
      final surface = tester.widget<OiSurface>(find.byType(OiSurface));
      expect(surface.shadow, isNotNull);
      expect(surface.shadow!.length, equals(2));
      expect(surface.shadow![0].blurRadius, equals(8));
      expect(surface.shadow![1].blurRadius, equals(2));
    });

    testWidgets('card variant uses borderRadius of 8', (tester) async {
      await tester.pumpChartApp(
        const OiChartSurface(child: Text('chart')),
      );
      final surface = tester.widget<OiSurface>(find.byType(OiSurface));
      expect(surface.borderRadius, equals(BorderRadius.circular(8)));
    });

    testWidgets('card variant has default padding of 16', (tester) async {
      await tester.pumpChartApp(
        const OiChartSurface(child: Text('chart')),
      );
      final surface = tester.widget<OiSurface>(find.byType(OiSurface));
      expect(surface.padding, equals(const EdgeInsets.all(16)));
    });

    testWidgets('card variant does not set frosted', (tester) async {
      await tester.pumpChartApp(
        const OiChartSurface(child: Text('chart')),
      );
      final surface = tester.widget<OiSurface>(find.byType(OiSurface));
      expect(surface.frosted, isFalse);
    });
  });

  // ---------------------------------------------------------------------------
  // REQ-0108 — Compact embedded presentation
  // ---------------------------------------------------------------------------

  group('REQ-0108 — compact presentation', () {
    testWidgets('compact variant has default padding of 8', (tester) async {
      await tester.pumpChartApp(
        OiChartSurface.compact(child: const Text('chart')),
      );
      final surface = tester.widget<OiSurface>(find.byType(OiSurface));
      expect(surface.padding, equals(const EdgeInsets.all(8)));
    });

    testWidgets('compact variant has no shadow', (tester) async {
      await tester.pumpChartApp(
        OiChartSurface.compact(child: const Text('chart')),
      );
      final surface = tester.widget<OiSurface>(find.byType(OiSurface));
      expect(surface.shadow, isNull);
    });

    testWidgets('compact variant uses default border', (tester) async {
      await tester.pumpChartApp(
        OiChartSurface.compact(child: const Text('chart')),
      );
      final surface = tester.widget<OiSurface>(find.byType(OiSurface));
      expect(surface.border, isNotNull);
    });
  });

  // ---------------------------------------------------------------------------
  // REQ-0108 — Frosted variant
  // ---------------------------------------------------------------------------

  group('REQ-0108 — frosted variant', () {
    testWidgets('frosted variant sets frosted=true on OiSurface', (
      tester,
    ) async {
      await tester.pumpChartApp(
        OiChartSurface.frosted(child: const Text('chart')),
      );
      final surface = tester.widget<OiSurface>(find.byType(OiSurface));
      expect(surface.frosted, isTrue);
    });

    testWidgets('frosted variant uses glassBackground color', (tester) async {
      await tester.pumpChartApp(
        OiChartSurface.frosted(child: const Text('chart')),
      );
      final surface = tester.widget<OiSurface>(find.byType(OiSurface));
      // glassBackground in light mode is Color(0x99FFFFFF)
      expect(surface.color, equals(const Color(0x99FFFFFF)));
    });

    testWidgets('frosted variant uses glassBorder by default', (tester) async {
      await tester.pumpChartApp(
        OiChartSurface.frosted(child: const Text('chart')),
      );
      final surface = tester.widget<OiSurface>(find.byType(OiSurface));
      expect(surface.border, isNotNull);
      expect(surface.border!.color, equals(const Color(0x33FFFFFF)));
    });

    testWidgets('frosted variant applies BackdropFilter', (tester) async {
      await tester.pumpChartApp(
        OiChartSurface.frosted(child: const Text('chart')),
      );
      expect(find.byType(BackdropFilter), findsOneWidget);
    });

    testWidgets('frosted variant has default padding of 16', (tester) async {
      await tester.pumpChartApp(
        OiChartSurface.frosted(child: const Text('chart')),
      );
      final surface = tester.widget<OiSurface>(find.byType(OiSurface));
      expect(surface.padding, equals(const EdgeInsets.all(16)));
    });
  });

  // ---------------------------------------------------------------------------
  // REQ-0108 — Soft variant
  // ---------------------------------------------------------------------------

  group('REQ-0108 — soft variant', () {
    testWidgets('soft variant uses surfaceSubtle color', (tester) async {
      await tester.pumpChartApp(
        OiChartSurface.soft(child: const Text('chart')),
      );
      final surface = tester.widget<OiSurface>(find.byType(OiSurface));
      // surfaceSubtle in light mode is Color(0xFFF9FAFB)
      expect(surface.color, equals(const Color(0xFFF9FAFB)));
    });

    testWidgets('soft variant has no shadow', (tester) async {
      await tester.pumpChartApp(
        OiChartSurface.soft(child: const Text('chart')),
      );
      final surface = tester.widget<OiSurface>(find.byType(OiSurface));
      expect(surface.shadow, isNull);
    });

    testWidgets('soft variant uses default border', (tester) async {
      await tester.pumpChartApp(
        OiChartSurface.soft(child: const Text('chart')),
      );
      final surface = tester.widget<OiSurface>(find.byType(OiSurface));
      expect(surface.border, isNotNull);
    });

    testWidgets('soft variant does not set frosted', (tester) async {
      await tester.pumpChartApp(
        OiChartSurface.soft(child: const Text('chart')),
      );
      final surface = tester.widget<OiSurface>(find.byType(OiSurface));
      expect(surface.frosted, isFalse);
    });
  });

  // ---------------------------------------------------------------------------
  // REQ-0108 — Theme token inheritance (border, shadow, halo, gradient)
  // ---------------------------------------------------------------------------

  group('REQ-0108 — theme token inheritance', () {
    testWidgets('custom padding is forwarded to OiSurface', (tester) async {
      const customPadding = EdgeInsets.all(24);
      await tester.pumpChartApp(
        const OiChartSurface(padding: customPadding, child: Text('chart')),
      );
      final surface = tester.widget<OiSurface>(find.byType(OiSurface));
      expect(surface.padding, equals(customPadding));
    });

    testWidgets('custom border is forwarded to OiSurface', (tester) async {
      final customBorder = OiBorderStyle.solid(const Color(0xFFFF0000), 2);
      await tester.pumpChartApp(
        OiChartSurface(border: customBorder, child: const Text('chart')),
      );
      final surface = tester.widget<OiSurface>(find.byType(OiSurface));
      expect(surface.border, equals(customBorder));
    });

    testWidgets('gradient is forwarded to OiSurface', (tester) async {
      final gradient = OiGradientStyle.linear(const [
        Color(0xFF000000),
        Color(0xFFFFFFFF),
      ]);
      await tester.pumpChartApp(
        OiChartSurface(gradient: gradient, child: const Text('chart')),
      );
      final surface = tester.widget<OiSurface>(find.byType(OiSurface));
      expect(surface.gradient, equals(gradient));
    });

    testWidgets('halo is forwarded to OiSurface', (tester) async {
      const halo = OiHaloStyle(color: Color(0x330000FF), blur: 12, spread: 4);
      await tester.pumpChartApp(
        const OiChartSurface(halo: halo, child: Text('chart')),
      );
      final surface = tester.widget<OiSurface>(find.byType(OiSurface));
      expect(surface.halo, equals(halo));
    });

    testWidgets('custom border overrides frosted default border', (
      tester,
    ) async {
      final customBorder = OiBorderStyle.dashed(const Color(0xFFFF0000), 3);
      await tester.pumpChartApp(
        OiChartSurface.frosted(
          border: customBorder,
          child: const Text('chart'),
        ),
      );
      final surface = tester.widget<OiSurface>(find.byType(OiSurface));
      expect(surface.border, equals(customBorder));
    });

    testWidgets('custom border overrides soft default border', (tester) async {
      final customBorder = OiBorderStyle.dotted(const Color(0xFF00FF00), 1);
      await tester.pumpChartApp(
        OiChartSurface.soft(
          border: customBorder,
          child: const Text('chart'),
        ),
      );
      final surface = tester.widget<OiSurface>(find.byType(OiSurface));
      expect(surface.border, equals(customBorder));
    });

    testWidgets('custom border overrides compact default border', (
      tester,
    ) async {
      final customBorder = OiBorderStyle.solid(const Color(0xFF0000FF), 2);
      await tester.pumpChartApp(
        OiChartSurface.compact(
          border: customBorder,
          child: const Text('chart'),
        ),
      );
      final surface = tester.widget<OiSurface>(find.byType(OiSurface));
      expect(surface.border, equals(customBorder));
    });
  });

  // ---------------------------------------------------------------------------
  // REQ-0108 — Accessibility
  // ---------------------------------------------------------------------------

  group('REQ-0108 — accessibility', () {
    testWidgets('semanticLabel wraps surface in Semantics widget', (
      tester,
    ) async {
      await tester.pumpChartApp(
        const OiChartSurface(
          semanticLabel: 'Sales chart',
          child: Text('chart'),
        ),
      );
      // Find the Semantics widget that OiChartSurface adds.
      final semanticsFinder = find.byWidgetPredicate(
        (widget) =>
            widget is Semantics &&
            widget.properties.label == 'Sales chart',
      );
      expect(semanticsFinder, findsOneWidget);
    });

    testWidgets('no Semantics widget when semanticLabel is null', (
      tester,
    ) async {
      await tester.pumpChartApp(
        const OiChartSurface(child: Text('chart')),
      );
      // There may be Semantics from OiApp; verify none wrapping OiSurface
      // directly from OiChartSurface by checking the build output shape.
      final surface = find.byType(OiSurface);
      expect(surface, findsOneWidget);
      // The parent of OiSurface should not be a Semantics widget.
      final surfaceElement = tester.element(surface);
      var foundSemantics = false;
      surfaceElement.visitAncestorElements((element) {
        if (element.widget is Semantics) {
          final s = element.widget as Semantics;
          if (s.properties.label == 'Sales chart') {
            foundSemantics = true;
          }
          return false;
        }
        if (element.widget is OiChartSurface) {
          return false;
        }
        return true;
      });
      expect(foundSemantics, isFalse);
    });
  });
}
