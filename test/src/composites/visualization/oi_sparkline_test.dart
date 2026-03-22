// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/composites/visualization/oi_sparkline.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme_data.dart';

import '../../../helpers/pump_app.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

Widget _sparkline({
  List<double> values = const [10, 20, 15, 30, 25],
  String label = 'Test sparkline',
  Color? color,
  bool fill = false,
  double fillOpacity = 0.15,
  double strokeWidth = 1.5,
  bool showLastPoint = false,
  bool showMinMax = false,
  double height = 32,
  double? width,
}) {
  return SizedBox(
    width: width ?? 200,
    height: height,
    child: OiSparkline(
      label: label,
      values: values,
      color: color,
      fill: fill,
      fillOpacity: fillOpacity,
      strokeWidth: strokeWidth,
      showLastPoint: showLastPoint,
      showMinMax: showMinMax,
      height: height,
      width: width,
    ),
  );
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  testWidgets('renders without errors', (tester) async {
    await tester.pumpObers(_sparkline());
    expect(find.byType(OiSparkline), findsOneWidget);
  });

  testWidgets('CustomPaint painter is present', (tester) async {
    await tester.pumpObers(_sparkline());
    expect(find.byKey(const Key('oi_sparkline_painter')), findsOneWidget);
  });

  testWidgets('fill mode renders without error', (tester) async {
    await tester.pumpObers(_sparkline(fill: true));
    expect(find.byType(OiSparkline), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('custom color applied', (tester) async {
    await tester.pumpObers(
      _sparkline(color: const Color(0xFFFF5722)),
    );
    expect(find.byType(OiSparkline), findsOneWidget);
  });

  testWidgets('empty data returns SizedBox.shrink', (tester) async {
    await tester.pumpObers(_sparkline(values: const []));
    expect(find.byKey(const Key('oi_sparkline_empty')), findsOneWidget);
  });

  testWidgets('single value renders without error', (tester) async {
    await tester.pumpObers(_sparkline(values: const [42]));
    expect(find.byType(OiSparkline), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('has semantics label', (tester) async {
    await tester.pumpObers(_sparkline(label: 'Revenue trend'));
    final semantics = tester.getSemantics(find.byType(OiSparkline));
    expect(semantics.label, contains('Revenue trend'));
  });

  testWidgets('showLastPoint renders without error', (tester) async {
    await tester.pumpObers(_sparkline(showLastPoint: true));
    expect(find.byType(OiSparkline), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('showMinMax renders without error', (tester) async {
    await tester.pumpObers(_sparkline(showMinMax: true));
    expect(find.byType(OiSparkline), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('custom dimensions applied', (tester) async {
    await tester.pumpObers(_sparkline(width: 100, height: 48));
    final sizedBox = tester.widget<SizedBox>(
      find.descendant(
        of: find.byType(OiSparkline),
        matching: find.byType(SizedBox),
      ),
    );
    expect(sizedBox.height, 48);
  });

  testWidgets('light theme renders correctly', (tester) async {
    await tester.pumpObers(
      _sparkline(),
      theme: OiThemeData.light(),
    );
    expect(find.byType(OiSparkline), findsOneWidget);
  });

  testWidgets('dark theme renders correctly', (tester) async {
    await tester.pumpObers(
      _sparkline(),
      theme: OiThemeData.dark(),
    );
    expect(find.byType(OiSparkline), findsOneWidget);
  });
}
