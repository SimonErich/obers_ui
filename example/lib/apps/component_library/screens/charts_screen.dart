import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_example/apps/component_library/shared/component_showcase_section.dart';

/// Showcase screen for all chart and data visualization widgets.
class ChartsScreen extends StatefulWidget {
  const ChartsScreen({super.key});

  @override
  State<ChartsScreen> createState() => _ChartsScreenState();
}

class _ChartsScreenState extends State<ChartsScreen> {
  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;

    return SingleChildScrollView(
      padding: EdgeInsets.all(spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── OiBarChart ──────────────────────────────────────────────────
          const ComponentShowcaseSection(
            title: 'Bar Chart',
            widgetName: 'OiBarChart',
            description:
                'A bar chart for categorical comparisons. Supports grouped, '
                'stacked, horizontal-grouped, and horizontal-stacked layouts.',
            examples: [
              ComponentExample(
                title: 'Monthly Revenue',
                child: SizedBox(
                  height: 300,
                  child: OiBarChart(
                    label: 'Monthly revenue',
                    categories: [
                      OiBarCategory(label: 'Jan', values: [12]),
                      OiBarCategory(label: 'Feb', values: [19]),
                      OiBarCategory(label: 'Mar', values: [8]),
                      OiBarCategory(label: 'Apr', values: [15]),
                      OiBarCategory(label: 'May', values: [22]),
                      OiBarCategory(label: 'Jun', values: [17]),
                    ],
                    series: [OiBarSeries(label: 'Revenue')],
                  ),
                ),
              ),
            ],
          ),

          // ── OiLineChart ─────────────────────────────────────────────────
          const ComponentShowcaseSection(
            title: 'Line Chart',
            widgetName: 'OiLineChart',
            description:
                'A line chart for visualising time series and metric data. '
                'Supports straight, stepped, and smooth interpolation modes.',
            examples: [
              ComponentExample(
                title: 'Visitor Trend',
                child: SizedBox(
                  height: 300,
                  child: OiLineChart(
                    label: 'Visitor trend',
                    series: [
                      OiLineSeries(
                        label: 'Visitors',
                        points: [
                          OiLinePoint(x: 0, y: 120, label: 'Mon'),
                          OiLinePoint(x: 1, y: 150, label: 'Tue'),
                          OiLinePoint(x: 2, y: 180, label: 'Wed'),
                          OiLinePoint(x: 3, y: 90, label: 'Thu'),
                          OiLinePoint(x: 4, y: 210, label: 'Fri'),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ── OiPieChart ──────────────────────────────────────────────────
          const ComponentShowcaseSection(
            title: 'Pie Chart',
            widgetName: 'OiPieChart',
            description:
                'A pie or donut chart for visualising proportional data. '
                'Supports segment labels, percentages, and a donut variant.',
            examples: [
              ComponentExample(
                title: 'Market Share',
                child: SizedBox(
                  height: 300,
                  child: OiPieChart(
                    label: 'Market share',
                    segments: [
                      OiPieSegment(label: 'Chrome', value: 65),
                      OiPieSegment(label: 'Safari', value: 19),
                      OiPieSegment(label: 'Firefox', value: 10),
                      OiPieSegment(label: 'Other', value: 6),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ── OiSparkline ─────────────────────────────────────────────────
          const ComponentShowcaseSection(
            title: 'Sparkline',
            widgetName: 'OiSparkline',
            description:
                'A compact inline sparkline chart for embedding in metrics, '
                'table cells, or list tiles.',
            examples: [
              ComponentExample(
                title: 'Inline Trend',
                child: SizedBox(
                  height: 40,
                  width: 120,
                  child: OiSparkline(
                    values: [3, 7, 5, 12, 8, 15, 10],
                    label: 'Trend',
                  ),
                ),
              ),
            ],
          ),

          // ── OiGauge ─────────────────────────────────────────────────────
          const ComponentShowcaseSection(
            title: 'Gauge',
            widgetName: 'OiGauge',
            description:
                'A gauge / speedometer visualization showing a value within '
                'a range. Supports colored segments and a target marker.',
            examples: [
              ComponentExample(
                title: 'CPU Usage',
                child: SizedBox(
                  height: 200,
                  child: OiGauge(value: 72, label: 'CPU Usage'),
                ),
              ),
            ],
          ),

          // ── OiFunnelChart ───────────────────────────────────────────────
          const ComponentShowcaseSection(
            title: 'Funnel Chart',
            widgetName: 'OiFunnelChart',
            description:
                'A funnel chart showing conversion through stages. Stages '
                'are rendered as progressively narrowing trapezoids.',
            examples: [
              ComponentExample(
                title: 'Sales Funnel',
                child: SizedBox(
                  height: 300,
                  child: OiFunnelChart(
                    label: 'Sales funnel',
                    stages: [
                      OiFunnelStage(label: 'Leads', value: 1000),
                      OiFunnelStage(label: 'Qualified', value: 500),
                      OiFunnelStage(label: 'Proposal', value: 200),
                      OiFunnelStage(label: 'Won', value: 80),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ── OiHeatmap ───────────────────────────────────────────────────
          const ComponentShowcaseSection(
            title: 'Heatmap',
            widgetName: 'OiHeatmap',
            description:
                'A heatmap visualization showing values as colored cells in '
                'a grid. Cells are colored on a gradient based on their value.',
            examples: [
              ComponentExample(
                title: 'Weekly Activity',
                child: SizedBox(
                  height: 250,
                  child: OiHeatmap(
                    label: 'Activity',
                    rowLabels: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'],
                    columnLabels: ['9am', '10am', '11am', '12pm', '1pm'],
                    cells: [
                      OiHeatmapCell(row: 0, column: 0, value: 3),
                      OiHeatmapCell(row: 0, column: 1, value: 7),
                      OiHeatmapCell(row: 0, column: 2, value: 5),
                      OiHeatmapCell(row: 0, column: 3, value: 2),
                      OiHeatmapCell(row: 0, column: 4, value: 8),
                      OiHeatmapCell(row: 1, column: 0, value: 4),
                      OiHeatmapCell(row: 1, column: 1, value: 6),
                      OiHeatmapCell(row: 1, column: 2, value: 9),
                      OiHeatmapCell(row: 1, column: 3, value: 1),
                      OiHeatmapCell(row: 1, column: 4, value: 5),
                      OiHeatmapCell(row: 2, column: 0, value: 8),
                      OiHeatmapCell(row: 2, column: 1, value: 3),
                      OiHeatmapCell(row: 2, column: 2, value: 6),
                      OiHeatmapCell(row: 2, column: 3, value: 7),
                      OiHeatmapCell(row: 2, column: 4, value: 4),
                      OiHeatmapCell(row: 3, column: 0, value: 2),
                      OiHeatmapCell(row: 3, column: 1, value: 9),
                      OiHeatmapCell(row: 3, column: 2, value: 4),
                      OiHeatmapCell(row: 3, column: 3, value: 8),
                      OiHeatmapCell(row: 3, column: 4, value: 6),
                      OiHeatmapCell(row: 4, column: 0, value: 5),
                      OiHeatmapCell(row: 4, column: 1, value: 2),
                      OiHeatmapCell(row: 4, column: 2, value: 7),
                      OiHeatmapCell(row: 4, column: 3, value: 3),
                      OiHeatmapCell(row: 4, column: 4, value: 9),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ── OiRadarChart ────────────────────────────────────────────────
          const ComponentShowcaseSection(
            title: 'Radar Chart',
            widgetName: 'OiRadarChart',
            description:
                'A radar / spider chart for comparing multiple dimensions. '
                'Renders data as polygons on radial axes.',
            examples: [
              ComponentExample(
                title: 'Player Skills',
                child: SizedBox(
                  height: 300,
                  child: OiRadarChart(
                    label: 'Skills',
                    axes: [
                      'Speed',
                      'Power',
                      'Accuracy',
                      'Stamina',
                      'Technique',
                    ],
                    series: [
                      OiRadarSeries(label: 'Player', values: [8, 6, 9, 7, 5]),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ── OiScatterPlot ───────────────────────────────────────────────
          const ComponentShowcaseSection(
            title: 'Scatter Plot',
            widgetName: 'OiScatterPlot',
            description:
                'A scatter plot for visualising correlation between two '
                'variables. Supports multiple series with configurable point '
                'shapes (circle, square, diamond, triangle) and sizes.',
            examples: [
              ComponentExample(
                title: 'Key Parameters',
                child: OiLabel.body(
                  'OiScatterPlot renders data points on a Cartesian grid. '
                  'Required: label (String), series (List<OiScatterSeries>). '
                  'Each OiScatterSeries has label, points '
                  '(List<OiScatterPoint> with x, y), optional color, '
                  'pointRadius, and shape (OiScatterShape). '
                  'Optional: xAxis, yAxis (OiChartAxis), showGrid, '
                  'showLegend, onPointTap.',
                ),
              ),
            ],
          ),

          // ── OiBubbleChart ───────────────────────────────────────────────
          const ComponentShowcaseSection(
            title: 'Bubble Chart',
            widgetName: 'OiBubbleChart',
            description:
                'A bubble chart visualization plotting data by x, y, and '
                'size dimensions. Extends scatter plot concepts with a third '
                'data dimension encoded as bubble radius.',
            examples: [
              ComponentExample(
                title: 'Key Parameters',
                child: OiLabel.body(
                  'OiBubbleChart takes an OiBubbleChartData object containing '
                  'series definitions, size configuration, and axis settings. '
                  'Required: data (OiBubbleChartData). Optional: '
                  'semanticLabel, theme (OiBubbleChartTheme), '
                  'interactionMode, compact.',
                ),
              ),
            ],
          ),

          // ── OiSankey ────────────────────────────────────────────────────
          const ComponentShowcaseSection(
            title: 'Sankey Diagram',
            widgetName: 'OiSankey',
            description:
                'A flow diagram showing how values move between categories. '
                'Nodes are laid out in columns and links are rendered as '
                'curved bands proportional to their value.',
            examples: [
              ComponentExample(
                title: 'Key Parameters',
                child: OiLabel.body(
                  'OiSankey takes nodes (List<OiSankeyNode> with key, label) '
                  'and links (List<OiSankeyLink> with source, target, value). '
                  'Required: nodes, links, label. Optional: showLabels, '
                  'showValues, onNodeTap, onLinkTap.',
                ),
              ),
            ],
          ),

          // ── OiTreemap ───────────────────────────────────────────────────
          const ComponentShowcaseSection(
            title: 'Treemap',
            widgetName: 'OiTreemap',
            description:
                'A treemap visualization showing hierarchical data as nested '
                'rectangles. Each node area is proportional to its value.',
            examples: [
              ComponentExample(
                title: 'Key Parameters',
                child: OiLabel.body(
                  'OiTreemap takes nodes (List<OiTreemapNode> with key, '
                  'label, value, optional children for nesting). '
                  'Required: nodes, label. Optional: showLabels, showValues, '
                  'onNodeTap.',
                ),
              ),
            ],
          ),

          // ── OiChartSurface ──────────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Chart Surface',
            widgetName: 'OiChartSurface',
            description:
                'A themed visual container for charts. Provides consistent '
                'surface styling with variants: default (card), atom, compact, '
                'frosted, and soft.',
            examples: [
              ComponentExample(
                title: 'Wrapped Sparkline',
                child: OiChartSurface(
                  semanticLabel: 'Chart container',
                  child: Padding(
                    padding: EdgeInsets.all(spacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const OiLabel.caption('Revenue trend'),
                        SizedBox(height: spacing.sm),
                        const SizedBox(
                          height: 40,
                          width: 200,
                          child: OiSparkline(
                            values: [5, 12, 8, 20, 14, 25, 18],
                            label: 'Revenue trend',
                            fill: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
