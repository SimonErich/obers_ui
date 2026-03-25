import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_charts/obers_ui_charts.dart';

import 'package:obers_ui_example/data/mock_dashboard.dart';

/// Dashboard overview with metric cards, funnel, gauge, heatmap, radar,
/// sankey, and treemap.
class AdminOverviewScreen extends StatefulWidget {
  const AdminOverviewScreen({super.key});

  @override
  State<AdminOverviewScreen> createState() => _AdminOverviewScreenState();
}

class _AdminOverviewScreenState extends State<AdminOverviewScreen> {
  bool _isEditing = false;

  static const _metricTooltips = [
    'Total revenue earned this month compared to the previous month.',
    'Total number of orders placed this month.',
    'Count of unique users who were active this month.',
    'Average customer satisfaction rating out of 5 stars.',
  ];

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;

    return Column(
      children: [
        // Edit mode toolbar
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: spacing.lg,
            vertical: spacing.sm,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OiSwitch(
                label: 'Edit mode',
                value: _isEditing,
                onChanged: (v) {
                  setState(() => _isEditing = v);
                  if (v) {
                    OiToast.show(
                      context,
                      message: 'Edit mode is not yet available. '
                          'Drag-and-drop reordering coming soon.',
                      level: OiToastLevel.info,
                    );
                  }
                },
              ),
            ],
          ),
        ),

        // Dashboard grid
        // TODO: Implement drag-and-drop reordering in OiDashboard edit mode.
        Expanded(
          child: OiDashboard(
            label: 'Admin dashboard',
            editable: _isEditing,
            cards: [
              // 4 metric cards wrapped in OiTooltip
              for (var i = 0; i < kDashboardMetrics.length; i++)
                OiDashboardCard(
                  key: 'metric-$i',
                  title: kDashboardMetrics[i].label,
                  child: OiTooltip(
                    label: '${kDashboardMetrics[i].label} tooltip',
                    message: _metricTooltips[i],
                    child: OiMetric(
                      label: kDashboardMetrics[i].label,
                      value: kDashboardMetrics[i].value,
                      subValue: kDashboardMetrics[i].subValue,
                      trend: kDashboardMetrics[i].trend,
                      trendPercent: kDashboardMetrics[i].trendPercent,
                    ),
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

              // Heatmap
              OiDashboardCard(
                key: 'heatmap',
                title: 'Activity Heatmap',
                columnSpan: 4,
                rowSpan: 2,
                child: OiHeatmap(
                  label: 'Activity by day and hour',
                  cells: [
                    for (var r = 0; r < kHeatmapData.length; r++)
                      for (var c = 0; c < kHeatmapData[r].length; c++)
                        OiHeatmapCell(
                          row: r,
                          column: c,
                          value: kHeatmapData[r][c].toDouble(),
                        ),
                  ],
                  rowLabels: const [
                    'Mon',
                    'Tue',
                    'Wed',
                    'Thu',
                    'Fri',
                    'Sat',
                    'Sun',
                  ],
                  columnLabels: List.generate(24, (i) => '${i}h'),
                  showValues: false,
                ),
              ),

              // Radar chart
              OiDashboardCard(
                key: 'radar',
                title: 'Category Performance',
                columnSpan: 2,
                rowSpan: 2,
                child: OiRadarChart(
                  label: 'Product category performance comparison',
                  axes: kRadarCategories,
                  series: [
                    OiRadarSeries(
                      label: 'This Quarter',
                      values: kRadarValues[0],
                    ),
                    OiRadarSeries(
                      label: 'Last Quarter',
                      values: kRadarValues[1],
                    ),
                  ],
                  maxValue: 100,
                ),
              ),

              // Sankey chart — customer journey
              OiDashboardCard(
                key: 'sankey',
                title: 'Customer Journey',
                columnSpan: 4,
                rowSpan: 2,
                child: OiSankey(
                  label: 'Customer journey flow',
                  nodes: [
                    for (final n in kSankeyNodes)
                      OiSankeyNode(key: n.key, label: n.label),
                  ],
                  links: [
                    for (final l in kSankeyLinks)
                      OiSankeyLink(
                        source: l.source,
                        target: l.target,
                        value: l.value,
                      ),
                  ],
                  showValues: true,
                ),
              ),

              // Treemap — revenue by category
              OiDashboardCard(
                key: 'treemap',
                title: 'Revenue by Category',
                columnSpan: 2,
                rowSpan: 2,
                child: OiTreemap(
                  label: 'Revenue by product category',
                  nodes: [
                    for (final n in kTreemapNodes)
                      OiTreemapNode(key: n.key, label: n.label, value: n.value),
                  ],
                  showValues: true,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
