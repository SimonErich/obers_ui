import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';

import 'package:obers_ui_example/data/mock_dashboard.dart';

/// Dashboard overview with metric cards, a funnel chart, and a gauge.
class AdminOverviewScreen extends StatelessWidget {
  const AdminOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return OiDashboard(
      label: 'Admin dashboard',
      cards: [
        // 4 metric cards
        for (var i = 0; i < kDashboardMetrics.length; i++)
          OiDashboardCard(
            key: 'metric-$i',
            title: kDashboardMetrics[i].label,
            child: OiMetric(
              label: kDashboardMetrics[i].label,
              value: kDashboardMetrics[i].value,
              subValue: kDashboardMetrics[i].subValue,
              trend: kDashboardMetrics[i].trend,
              trendPercent: kDashboardMetrics[i].trendPercent,
            ),
          ),

        // Funnel chart
        OiDashboardCard(
          key: 'funnel',
          title: 'Conversion Funnel',
          columnSpan: 2,
          rowSpan: 2,
          child: OiFunnelChart(
            label: 'Sales conversion funnel',
            stages: [
              for (final stage in kFunnelStages)
                OiFunnelStage(
                  label: stage.label,
                  value: stage.value.toDouble(),
                ),
            ],
          ),
        ),

        // Gauge
        OiDashboardCard(
          key: 'gauge',
          title: 'Customer Satisfaction',
          columnSpan: 2,
          rowSpan: 2,
          child: OiGauge(
            label: 'Customer satisfaction score',
            value: 4.7,
            max: 5,
            formatValue: (v) => v.toStringAsFixed(1),
          ),
        ),
      ],
    );
  }
}
