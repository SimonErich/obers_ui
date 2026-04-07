import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_charts/obers_ui_charts.dart';

import 'package:obers_ui_example/data/mock_dashboard.dart';

/// Dashboard overview with metric cards, funnel, gauge, heatmap, radar,
/// sankey, and treemap.
class AdminOverviewScreen extends StatelessWidget {
  const AdminOverviewScreen({super.key});

  static const _metricTooltips = [
    'Total revenue earned this month compared to the previous month.',
    'Total number of orders placed this month.',
    'Count of unique users who were active this month.',
    'Average customer satisfaction rating out of 5 stars.',
  ];

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final bp = context.breakpoint;

    return SingleChildScrollView(
      padding: EdgeInsets.all(spacing.lg),
      child: OiGrid(
        breakpoint: bp,
        columns: OiResponsive.breakpoints({
          OiBreakpoint.compact: 1,
          OiBreakpoint.expanded: 2,
          OiBreakpoint.large: 4,
        }),
        gap: OiResponsive.breakpoints({
          OiBreakpoint.compact: 12.0,
          OiBreakpoint.expanded: 14.0,
          OiBreakpoint.large: 16.0,
        }),
        stretchRows: true,
        children: [
          // ── Row 1 — 4 metric cards (1 col each) ──────────────────────
          for (var i = 0; i < kDashboardMetrics.length; i++)
            _DashboardTile(
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

          // ── Row 2 — Funnel + Gauge (2 cols each on desktop, full on mobile) ─
          _DashboardTile(
            title: 'Conversion Funnel',
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
          ).span(columnSpan: OiResponsive.breakpoints({
            OiBreakpoint.compact: 1,
            OiBreakpoint.large: 2,
          })),
          _DashboardTile(
            title: 'Customer Satisfaction',
            child: OiGauge(
              label: 'Customer satisfaction score',
              value: 4.7,
              max: 5,
              formatValue: (v) => v.toStringAsFixed(1),
            ),
          ).span(columnSpan: OiResponsive.breakpoints({
            OiBreakpoint.compact: 1,
            OiBreakpoint.large: 2,
          })),

          // ── Row 3 — Radar + Treemap (2 cols each) ─────────────────────
          _DashboardTile(
            title: 'Category Performance',
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
          ).span(columnSpan: OiResponsive.breakpoints({
            OiBreakpoint.compact: 1,
            OiBreakpoint.large: 2,
          })),
          _DashboardTile(
            title: 'Revenue by Category',
            child: OiTreemap(
              label: 'Revenue by product category',
              nodes: [
                for (final n in kTreemapNodes)
                  OiTreemapNode(
                    key: n.key,
                    label: n.label,
                    value: n.value,
                  ),
              ],
              showValues: true,
            ),
          ).span(columnSpan: OiResponsive.breakpoints({
            OiBreakpoint.compact: 1,
            OiBreakpoint.large: 2,
          })),

          // ── Row 4 — Customer Journey (full width) ─────────────────────
          _DashboardTile(
            title: 'Customer Journey',
            child: LayoutBuilder(
              builder: (context, constraints) {
                const minWidth = 600.0;
                final needsScroll = constraints.maxWidth < minWidth;
                final chart = OiSankey(
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
                );
                if (!needsScroll) return chart;
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(width: minWidth, child: chart),
                );
              },
            ),
          ).span(columnSpan: const OiResponsive(fullSpanSentinel)),

          // ── Row 5 — Activity Heatmap (full width) ─────────────────────
          _DashboardTile(
            title: 'Activity Heatmap',
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
                'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun',
              ],
              columnLabels: List.generate(24, (i) => '${i}h'),
              showValues: false,
            ),
          ).span(columnSpan: const OiResponsive(fullSpanSentinel)),
        ],
      ),
    );
  }
}

// ─── Helper widgets ──────────────────────────────────────────────────────────

/// A single dashboard card with a title header and content area.
class _DashboardTile extends StatelessWidget {
  const _DashboardTile({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: colors.borderSubtle),
              ),
            ),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: colors.text,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: child,
          ),
        ],
      ),
    );
  }
}
