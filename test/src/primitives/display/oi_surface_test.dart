// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/foundation/theme/oi_decoration_theme.dart';
import 'package:obers_ui/src/foundation/theme/oi_effects_theme.dart';
import 'package:obers_ui/src/primitives/display/oi_surface.dart';

import '../../../helpers/pump_app.dart';

void main() {
  // ── Renders child ─────────────────────────────────────────────────────────

  testWidgets('renders child widget', (tester) async {
    await tester.pumpObers(const OiSurface(child: Text('hello')));
    expect(find.text('hello'), findsOneWidget);
  });

  // ── Color ─────────────────────────────────────────────────────────────────

  testWidgets('applies background color via Container decoration', (
    tester,
  ) async {
    await tester.pumpObers(const OiSurface(color: Color(0xFFABCDEF)));
    final container = tester.widget<Container>(find.byType(Container));
    final decoration = container.decoration! as BoxDecoration;
    expect(decoration.color, const Color(0xFFABCDEF));
  });

  // ── Solid border ──────────────────────────────────────────────────────────

  testWidgets('solid border appears in BoxDecoration.border', (tester) async {
    await tester.pumpObers(
      OiSurface(
        border: OiBorderStyle.solid(const Color(0xFF0000FF), 2),
        child: const SizedBox(width: 100, height: 100),
      ),
    );
    final container = tester.widget<Container>(find.byType(Container));
    final decoration = container.decoration! as BoxDecoration;
    expect(decoration.border, isNotNull);
  });

  testWidgets('solid border does NOT use CustomPaint', (tester) async {
    await tester.pumpObers(
      OiSurface(
        key: const ValueKey('surface'),
        border: OiBorderStyle.solid(const Color(0xFF0000FF), 2),
        child: const SizedBox(width: 100, height: 100),
      ),
    );
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('surface')),
        matching: find.byType(CustomPaint),
      ),
      findsNothing,
    );
  });

  // ── Dashed border ─────────────────────────────────────────────────────────

  testWidgets('dashed border uses CustomPaint', (tester) async {
    await tester.pumpObers(
      OiSurface(
        key: const ValueKey('surface'),
        border: OiBorderStyle.dashed(const Color(0xFF00FF00), 1),
        child: const SizedBox(width: 100, height: 100),
      ),
    );
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('surface')),
        matching: find.byType(CustomPaint),
      ),
      findsOneWidget,
    );
  });

  testWidgets('dashed border does not add a BoxDecoration border', (
    tester,
  ) async {
    await tester.pumpObers(
      OiSurface(
        border: OiBorderStyle.dashed(const Color(0xFF00FF00), 1),
        child: const SizedBox(width: 100, height: 100),
      ),
    );
    final container = tester.widget<Container>(find.byType(Container));
    final decoration = container.decoration! as BoxDecoration;
    expect(decoration.border, isNull);
  });

  // ── Dotted border ─────────────────────────────────────────────────────────

  testWidgets('dotted border uses CustomPaint', (tester) async {
    await tester.pumpObers(
      OiSurface(
        key: const ValueKey('surface'),
        border: OiBorderStyle.dotted(const Color(0xFFFF0000), 1),
        child: const SizedBox(width: 100, height: 100),
      ),
    );
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('surface')),
        matching: find.byType(CustomPaint),
      ),
      findsOneWidget,
    );
  });

  // ── Shadow ────────────────────────────────────────────────────────────────

  testWidgets('shadow appears in BoxDecoration.boxShadow', (tester) async {
    const shadow = BoxShadow(
      color: Color(0x55000000),
      blurRadius: 8,
      offset: Offset(0, 4),
    );
    await tester.pumpObers(
      const OiSurface(
        shadow: [shadow],
        child: SizedBox(width: 100, height: 100),
      ),
    );
    final container = tester.widget<Container>(find.byType(Container));
    final decoration = container.decoration! as BoxDecoration;
    expect(decoration.boxShadow, contains(shadow));
  });

  // ── Halo ──────────────────────────────────────────────────────────────────

  testWidgets('halo is merged into boxShadow list', (tester) async {
    final halo = OiHaloStyle.from(const Color(0xFF2563EB));
    await tester.pumpObers(
      OiSurface(halo: halo, child: const SizedBox(width: 100, height: 100)),
    );
    final container = tester.widget<Container>(find.byType(Container));
    final decoration = container.decoration! as BoxDecoration;
    expect(decoration.boxShadow, contains(halo.toBoxShadow()));
  });

  // ── Gradient ──────────────────────────────────────────────────────────────

  testWidgets('gradient applied via BoxDecoration.gradient', (tester) async {
    const gradientStyle = OiGradientStyle(
      linear: true,
      colors: [Color(0xFF000000), Color(0xFFFFFFFF)],
    );
    await tester.pumpObers(
      const OiSurface(
        gradient: gradientStyle,
        child: SizedBox(width: 100, height: 100),
      ),
    );
    final container = tester.widget<Container>(find.byType(Container));
    final decoration = container.decoration! as BoxDecoration;
    expect(decoration.gradient, isNotNull);
    // color should be null when gradient is applied
    expect(decoration.color, isNull);
  });

  // ── Glass effect ──────────────────────────────────────────────────────────

  testWidgets('glass:true adds BackdropFilter', (tester) async {
    await tester.pumpObers(
      const OiSurface(glass: true, child: SizedBox(width: 100, height: 100)),
    );
    expect(find.byType(BackdropFilter), findsOneWidget);
  });

  testWidgets('glass:false does not add BackdropFilter', (tester) async {
    await tester.pumpObers(
      const OiSurface(child: SizedBox(width: 100, height: 100)),
    );
    expect(find.byType(BackdropFilter), findsNothing);
  });

  // ── Padding ───────────────────────────────────────────────────────────────

  testWidgets('padding is forwarded to Container', (tester) async {
    const insets = EdgeInsets.all(16);
    await tester.pumpObers(const OiSurface(padding: insets, child: SizedBox()));
    final container = tester.widget<Container>(find.byType(Container));
    expect(container.padding, insets);
  });

  // ── Border radius ─────────────────────────────────────────────────────────

  testWidgets('borderRadius applied to BoxDecoration', (tester) async {
    final radius = BorderRadius.circular(12);
    await tester.pumpObers(
      OiSurface(
        borderRadius: radius,
        child: const SizedBox(width: 100, height: 100),
      ),
    );
    final container = tester.widget<Container>(find.byType(Container));
    final decoration = container.decoration! as BoxDecoration;
    expect(decoration.borderRadius, radius);
  });
}
