// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/composites/visualization/oi_funnel_chart.dart';

import '../../../helpers/pump_app.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

const _stages = [
  OiFunnelStage(label: 'Visitors', value: 1000),
  OiFunnelStage(label: 'Leads', value: 600),
  OiFunnelStage(label: 'Customers', value: 200),
];

Widget _funnelChart({
  List<OiFunnelStage> stages = _stages,
  String label = 'Test Funnel',
  bool showValues = true,
  bool showPercentages = true,
  String Function(double)? formatValue,
  ValueChanged<int>? onStageTap,
}) {
  return SizedBox(
    width: 400,
    height: 300,
    child: OiFunnelChart(
      stages: stages,
      label: label,
      showValues: showValues,
      showPercentages: showPercentages,
      formatValue: formatValue,
      onStageTap: onStageTap,
    ),
  );
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  // 1. Renders without errors.
  testWidgets('renders without errors', (tester) async {
    await tester.pumpObers(_funnelChart());
    expect(find.byType(OiFunnelChart), findsOneWidget);
  });

  // 2. Data displays correctly — stage labels shown.
  testWidgets('displays stage labels', (tester) async {
    await tester.pumpObers(_funnelChart());
    expect(find.text('Visitors'), findsOneWidget);
    expect(find.text('Leads'), findsOneWidget);
    expect(find.text('Customers'), findsOneWidget);
  });

  // 3. Labels render with values and percentages.
  testWidgets('shows values and percentages', (tester) async {
    await tester.pumpObers(_funnelChart());
    expect(find.text('1000 - 100%'), findsOneWidget);
    expect(find.text('600 - 60%'), findsOneWidget);
    expect(find.text('200 - 20%'), findsOneWidget);
  });

  // 4. Custom colors applied.
  testWidgets('renders with custom stage colors', (tester) async {
    await tester.pumpObers(_funnelChart(
      stages: const [
        OiFunnelStage(
          label: 'Custom',
          value: 100,
          color: Color(0xFF9C27B0),
        ),
      ],
    ));
    expect(find.text('Custom'), findsOneWidget);
  });

  // 5. onStageTap fires.
  testWidgets('onStageTap fires with correct index', (tester) async {
    int? tappedIndex;
    await tester.pumpObers(_funnelChart(
      onStageTap: (index) => tappedIndex = index,
    ));
    await tester.tap(find.text('Leads'));
    await tester.pump();
    expect(tappedIndex, 1);
  });

  // 6. Empty data handles gracefully.
  testWidgets('handles empty stages gracefully', (tester) async {
    await tester.pumpObers(_funnelChart(stages: const []));
    expect(find.byType(OiFunnelChart), findsOneWidget);
    expect(find.byKey(const Key('oi_funnel_chart_empty')), findsOneWidget);
  });

  // 7. Semantics label present.
  testWidgets('has semantics label', (tester) async {
    await tester.pumpObers(_funnelChart(label: 'Sales Funnel'));
    final semantics = tester.getSemantics(find.byType(OiFunnelChart));
    expect(semantics.label, contains('Sales Funnel'));
  });

  // 8. Size adapts to container — stage keys present.
  testWidgets('stage widgets have expected keys', (tester) async {
    await tester.pumpObers(_funnelChart());
    expect(find.byKey(const Key('oi_funnel_stage_0')), findsOneWidget);
    expect(find.byKey(const Key('oi_funnel_stage_1')), findsOneWidget);
    expect(find.byKey(const Key('oi_funnel_stage_2')), findsOneWidget);
  });

  // 9. formatValue callback is used.
  testWidgets('formatValue callback formats displayed value', (tester) async {
    await tester.pumpObers(_funnelChart(
      formatValue: (v) => '${v.toInt()}k',
    ));
    expect(find.text('1000k - 100%'), findsOneWidget);
  });

  // 10. showValues false hides values.
  testWidgets('hides values when showValues is false', (tester) async {
    await tester.pumpObers(_funnelChart(showValues: false, showPercentages: false));
    expect(find.text('1000 - 100%'), findsNothing);
  });

  // 11. Only percentages shown.
  testWidgets('shows only percentages when showValues is false', (tester) async {
    await tester.pumpObers(_funnelChart(showValues: false));
    expect(find.text('100%'), findsOneWidget);
    expect(find.text('60%'), findsOneWidget);
  });

  // 12. Chart key present with data.
  testWidgets('chart has expected key', (tester) async {
    await tester.pumpObers(_funnelChart());
    expect(find.byKey(const Key('oi_funnel_chart')), findsOneWidget);
  });
}
