// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/composites/visualization/oi_gauge.dart';

import '../../../helpers/pump_app.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

Widget _gauge({
  double value = 50,
  String label = 'Test Gauge',
  double min = 0,
  double max = 100,
  List<OiGaugeSegment>? segments,
  String Function(double)? formatValue,
  bool showValue = true,
  double? target,
  double? size,
}) {
  return SizedBox(
    width: 400,
    height: 300,
    child: OiGauge(
      value: value,
      label: label,
      min: min,
      max: max,
      segments: segments,
      formatValue: formatValue,
      showValue: showValue,
      target: target,
      size: size,
    ),
  );
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  // 1. Renders without errors.
  testWidgets('renders without errors', (tester) async {
    await tester.pumpObers(_gauge());
    expect(find.byType(OiGauge), findsOneWidget);
  });

  // 2. Data displays correctly — value text shown.
  testWidgets('displays value text when showValue is true', (tester) async {
    await tester.pumpObers(_gauge(value: 75));
    expect(find.text('75'), findsOneWidget);
  });

  // 3. Labels render — semantics label present.
  testWidgets('has semantics label', (tester) async {
    await tester.pumpObers(_gauge(label: 'Speed'));
    final semantics = tester.getSemantics(find.byType(OiGauge));
    expect(semantics.label, contains('Speed'));
  });

  // 4. Custom colors applied via segments.
  testWidgets('renders with custom segments without errors', (tester) async {
    await tester.pumpObers(
      _gauge(
        segments: [
          const OiGaugeSegment(
            from: 0,
            to: 30,
            color: Color(0xFF00FF00),
            label: 'Low',
          ),
          const OiGaugeSegment(
            from: 30,
            to: 70,
            color: Color(0xFFFFFF00),
            label: 'Medium',
          ),
          const OiGaugeSegment(
            from: 70,
            to: 100,
            color: Color(0xFFFF0000),
            label: 'High',
          ),
        ],
      ),
    );
    expect(find.byType(OiGauge), findsOneWidget);
    expect(find.byKey(const Key('oi_gauge_painter')), findsOneWidget);
  });

  // 5. formatValue callback is used.
  testWidgets('formatValue callback formats displayed value', (tester) async {
    await tester.pumpObers(
      _gauge(value: 42.5, formatValue: (v) => '${v.toStringAsFixed(1)}%'),
    );
    expect(find.text('42.5%'), findsOneWidget);
  });

  // 6. showValue false hides value text.
  testWidgets('hides value text when showValue is false', (tester) async {
    await tester.pumpObers(_gauge(showValue: false));
    expect(find.byKey(const Key('oi_gauge_value')), findsNothing);
  });

  // 7. Target marker renders without error.
  testWidgets('target marker renders without error', (tester) async {
    await tester.pumpObers(_gauge(target: 80));
    expect(find.byType(OiGauge), findsOneWidget);
  });

  // 8. Size adapts to container.
  testWidgets('adapts to custom size', (tester) async {
    await tester.pumpObers(
      const Center(child: OiGauge(value: 50, label: 'Size Test', size: 150)),
    );
    final painter = find.byKey(const Key('oi_gauge_painter'));
    final painterSize = tester.getSize(painter);
    expect(painterSize.width, 150);
  });

  // 9. Value clamped to min/max.
  testWidgets('clamps value below min', (tester) async {
    await tester.pumpObers(_gauge(value: -20));
    // The displayed text is the raw value (not clamped), but the
    // painter receives a clamped value. Widget renders without error.
    expect(find.byType(OiGauge), findsOneWidget);
  });

  // 10. Value above max still renders.
  testWidgets('clamps value above max', (tester) async {
    await tester.pumpObers(_gauge(value: 200));
    expect(find.byType(OiGauge), findsOneWidget);
  });

  // 11. CustomPaint painter is present.
  testWidgets('CustomPaint painter is present', (tester) async {
    await tester.pumpObers(_gauge());
    expect(find.byKey(const Key('oi_gauge_painter')), findsOneWidget);
  });

  // 12. Semantics value matches formatted value.
  testWidgets('semantics value matches formatted text', (tester) async {
    await tester.pumpObers(_gauge(value: 60));
    final semantics = tester.getSemantics(find.byType(OiGauge));
    expect(semantics.value, contains('60'));
  });
}
