import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_charts/src/composites/oi_bar_chart/oi_bar_chart.dart';
import 'package:obers_ui_charts/src/composites/oi_bar_chart/oi_bar_chart_data.dart';
import 'package:obers_ui_charts/src/composites/oi_heatmap.dart';
import 'package:obers_ui_charts/src/composites/oi_histogram/oi_histogram.dart';
import 'package:obers_ui_charts/src/composites/oi_histogram/oi_histogram_data.dart';
import 'package:obers_ui_charts/src/composites/oi_line_chart/oi_line_chart.dart';
import 'package:obers_ui_charts/src/composites/oi_line_chart/oi_line_chart_data.dart';
import 'package:obers_ui_charts/src/composites/oi_pie_chart.dart';
import 'package:obers_ui_charts/src/composites/oi_scatter_plot.dart';
import 'package:obers_ui_charts/src/modules/oi_explorer_chart_type.dart';
import 'package:obers_ui_charts/src/modules/oi_explorer_column.dart';
import 'package:obers_ui_charts/src/modules/oi_explorer_controller.dart';

/// An interactive data exploration widget that lets users pivot, group, and
/// visualize a dataset by assigning columns to axes and switching chart types.
///
/// [OiChartExplorer] renders in two panes:
/// - **Column picker** (left) — lists all [columns] and shows which are
///   assigned to x-axis, y-axis, and group-by. Tapping a column chip cycles
///   through assigning it to x → y → groupBy → unassigned.
/// - **Chart area** (right/below) — renders the chart described by the current
///   [controller] state using the mapped [data].
///
/// Axis assignments and the active chart type are managed by an
/// [OiExplorerController]. When no external [controller] is provided, an
/// internal one is created automatically from [initialChart], [xColumn],
/// [yColumn], and [groupBy].
///
/// The widget rebuilds automatically via [ListenableBuilder] on every
/// controller state change.
///
/// ```dart
/// OiChartExplorer<SalesRecord>(
///   label: 'Data Explorer',
///   data: records,
///   columns: [
///     OiExplorerColumn<SalesRecord>(
///       id: 'date', label: 'Date',
///       accessor: (r) => r.date, type: OiColumnType.date,
///     ),
///     OiExplorerColumn<SalesRecord>(
///       id: 'revenue', label: 'Revenue',
///       accessor: (r) => r.revenue, type: OiColumnType.numeric,
///     ),
///     OiExplorerColumn<SalesRecord>(
///       id: 'category', label: 'Category',
///       accessor: (r) => r.category, type: OiColumnType.categorical,
///     ),
///   ],
///   initialChart: OiExplorerChartType.line,
///   xColumn: 'date',
///   yColumn: 'revenue',
///   groupBy: 'category',
/// )
/// ```
///
/// {@category Modules}
class OiChartExplorer<T> extends StatefulWidget {
  /// Creates an [OiChartExplorer].
  const OiChartExplorer({
    required this.label,
    required this.data,
    required this.columns,
    super.key,
    this.initialChart = OiExplorerChartType.line,
    this.xColumn,
    this.yColumn,
    this.groupBy,
    this.controller,
    this.semanticLabel,
  });

  /// The accessibility label for the explorer.
  final String label;

  /// The domain objects to explore.
  final List<T> data;

  /// The column descriptors that define how to extract dimensions from [data].
  final List<OiExplorerColumn<T>> columns;

  /// The chart type shown when the widget first renders (no external
  /// controller). Ignored when [controller] is provided.
  final OiExplorerChartType initialChart;

  /// The initial x-axis column id. Ignored when [controller] is provided.
  final String? xColumn;

  /// The initial y-axis column id. Ignored when [controller] is provided.
  final String? yColumn;

  /// The initial group-by column id. Ignored when [controller] is provided.
  final String? groupBy;

  /// Optional external controller.
  ///
  /// When provided, the widget is fully controlled by the caller — the
  /// [initialChart], [xColumn], [yColumn], and [groupBy] parameters are
  /// ignored.
  final OiExplorerController? controller;

  /// An optional override for the semantic label.
  ///
  /// When null, [label] is used.
  final String? semanticLabel;

  @override
  State<OiChartExplorer<T>> createState() => _OiChartExplorerState<T>();
}

class _OiChartExplorerState<T> extends State<OiChartExplorer<T>> {
  late OiExplorerController _controller;
  bool _ownsController = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _controller = widget.controller!;
    } else {
      _controller = OiExplorerController(
        chartType: widget.initialChart,
        xColumnId: widget.xColumn,
        yColumnId: widget.yColumn,
        groupByColumnId: widget.groupBy,
      );
      _ownsController = true;
    }
  }

  @override
  void didUpdateWidget(OiChartExplorer<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != null &&
        widget.controller != oldWidget.controller) {
      if (_ownsController) {
        _controller.dispose();
        _ownsController = false;
      }
      _controller = widget.controller!;
    }
  }

  @override
  void dispose() {
    if (_ownsController) {
      _controller.dispose();
    }
    super.dispose();
  }

  /// Cycles the column assignment: unassigned → x → y → groupBy → unassigned.
  ///
  /// Tapping an unassigned column sets it as x. Tapping the x column moves it
  /// to y. Tapping the y column moves it to groupBy. Tapping the groupBy
  /// column clears the assignment.
  void _tapColumn(String columnId) {
    if (_controller.xColumnId == columnId) {
      _controller.setXColumn('');
      _controller.setYColumn(columnId);
    } else if (_controller.yColumnId == columnId) {
      _controller.setYColumn('');
      _controller.setGroupBy(columnId);
    } else if (_controller.groupByColumnId == columnId) {
      _controller.setGroupBy(null);
    } else {
      _controller.setXColumn(columnId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveSemanticLabel = widget.semanticLabel ?? widget.label;

    return Semantics(
      label: effectiveSemanticLabel,
      child: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) => _ExplorerLayout<T>(
          data: widget.data,
          columns: widget.columns,
          controller: _controller,
          onColumnTap: _tapColumn,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _ExplorerLayout — column picker + chart area
// ─────────────────────────────────────────────────────────────────────────────

class _ExplorerLayout<T> extends StatelessWidget {
  const _ExplorerLayout({
    required this.data,
    required this.columns,
    required this.controller,
    required this.onColumnTap,
  });

  final List<T> data;
  final List<OiExplorerColumn<T>> columns;
  final OiExplorerController controller;
  final ValueChanged<String> onColumnTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 600;

        final columnPicker = _ColumnPicker<T>(
          columns: columns,
          controller: controller,
          onColumnTap: onColumnTap,
          colors: colors,
        );

        final chartTypeSwitcher = _ChartTypeSwitcher(
          controller: controller,
          colors: colors,
        );

        final chartArea = _ChartArea<T>(
          data: data,
          columns: columns,
          controller: controller,
          colors: colors,
        );

        if (isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left pane: column picker + type switcher
              SizedBox(
                width: 180,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    chartTypeSwitcher,
                    const SizedBox(height: 12),
                    columnPicker,
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Right pane: chart
              Expanded(child: chartArea),
            ],
          );
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            chartTypeSwitcher,
            const SizedBox(height: 8),
            columnPicker,
            const SizedBox(height: 12),
            chartArea,
          ],
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _ChartTypeSwitcher — row of chart type buttons
// ─────────────────────────────────────────────────────────────────────────────

class _ChartTypeSwitcher extends StatelessWidget {
  const _ChartTypeSwitcher({required this.controller, required this.colors});

  final OiExplorerController controller;
  final OiColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      key: const Key('oi_chart_explorer_type_switcher'),
      spacing: 6,
      runSpacing: 4,
      children: [
        for (final type in OiExplorerChartType.values)
          _TypeChip(
            chartType: type,
            isSelected: controller.chartType == type,
            colors: colors,
            onTap: () => controller.setChartType(type),
          ),
      ],
    );
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({
    required this.chartType,
    required this.isSelected,
    required this.colors,
    required this.onTap,
  });

  final OiExplorerChartType chartType;
  final bool isSelected;
  final OiColorScheme colors;
  final VoidCallback onTap;

  String get _label => switch (chartType) {
    OiExplorerChartType.line => 'Line',
    OiExplorerChartType.bar => 'Bar',
    OiExplorerChartType.scatter => 'Scatter',
    OiExplorerChartType.pie => 'Pie',
    OiExplorerChartType.heatmap => 'Heatmap',
    OiExplorerChartType.histogram => 'Histogram',
  };

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Semantics(
        label: _label,
        selected: isSelected,
        button: true,
        child: OiSurface(
          color: isSelected ? colors.primary.base : colors.surfaceSubtle,
          border: OiBorderStyle.solid(
            isSelected ? colors.primary.base : colors.borderSubtle,
            1,
          ),
          borderRadius: BorderRadius.circular(4),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          child: OiLabel.caption(
            _label,
            color: isSelected ? colors.primary.foreground : colors.text,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _ColumnPicker — list of columns with axis assignment badges
// ─────────────────────────────────────────────────────────────────────────────

class _ColumnPicker<T> extends StatelessWidget {
  const _ColumnPicker({
    required this.columns,
    required this.controller,
    required this.onColumnTap,
    required this.colors,
  });

  final List<OiExplorerColumn<T>> columns;
  final OiExplorerController controller;
  final ValueChanged<String> onColumnTap;
  final OiColorScheme colors;

  String? _assignment(String id) {
    if (controller.xColumnId == id) return 'X';
    if (controller.yColumnId == id) return 'Y';
    if (controller.groupByColumnId == id) return 'G';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const Key('oi_chart_explorer_column_picker'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OiLabel.caption(
          'Columns',
          color: colors.textMuted,
          key: const Key('oi_chart_explorer_column_picker_label'),
        ),
        const SizedBox(height: 6),
        for (final column in columns) ...[
          _ColumnTile(
            column: column,
            assignment: _assignment(column.id),
            colors: colors,
            onTap: () => onColumnTap(column.id),
          ),
          const SizedBox(height: 4),
        ],
      ],
    );
  }
}

class _ColumnTile<T> extends StatelessWidget {
  const _ColumnTile({
    required this.column,
    required this.colors,
    required this.onTap,
    this.assignment,
  });

  final OiExplorerColumn<T> column;
  final String? assignment;
  final OiColorScheme colors;
  final VoidCallback onTap;

  String get _typeLabel => switch (column.type) {
    OiColumnType.numeric => '#',
    OiColumnType.categorical => 'A',
    OiColumnType.date => 'D',
  };

  @override
  Widget build(BuildContext context) {
    final isAssigned = assignment != null;

    return GestureDetector(
      onTap: onTap,
      child: Semantics(
        label: '${column.label}, ${assignment ?? "unassigned"}',
        button: true,
        child: OiSurface(
          key: Key('oi_chart_explorer_col_${column.id}'),
          color: isAssigned
              ? colors.primary.base.withValues(alpha: 0.08)
              : colors.surfaceSubtle,
          border: OiBorderStyle.solid(
            isAssigned ? colors.primary.base : colors.borderSubtle,
            1,
          ),
          borderRadius: BorderRadius.circular(4),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            children: [
              OiLabel.caption(_typeLabel, color: colors.textMuted),
              const SizedBox(width: 6),
              Expanded(
                child: OiLabel.small(
                  column.label,
                  color: colors.text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (assignment != null) ...[
                const SizedBox(width: 4),
                OiSurface(
                  color: colors.primary.base,
                  borderRadius: BorderRadius.circular(3),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 1,
                  ),
                  child: OiLabel.caption(
                    assignment!,
                    color: colors.primary.foreground,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _ChartArea — renders the active chart type with mapped data
// ─────────────────────────────────────────────────────────────────────────────

class _ChartArea<T> extends StatelessWidget {
  const _ChartArea({
    required this.data,
    required this.columns,
    required this.controller,
    required this.colors,
  });

  final List<T> data;
  final List<OiExplorerColumn<T>> columns;
  final OiExplorerController controller;
  final OiColorScheme colors;

  OiExplorerColumn<T>? _columnById(String? id) {
    if (id == null) return null;
    for (final col in columns) {
      if (col.id == id) return col;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return _NoData(colors: colors);
    }

    final xCol = _columnById(controller.xColumnId);
    final yCol = _columnById(controller.yColumnId);

    if (xCol == null && yCol == null) {
      return _NoPicker(colors: colors);
    }

    return _buildChart(context, xCol, yCol);
  }

  Widget _buildChart(
    BuildContext context,
    OiExplorerColumn<T>? xCol,
    OiExplorerColumn<T>? yCol,
  ) {
    final chartColors = colors.chart;

    switch (controller.chartType) {
      case OiExplorerChartType.line:
        return _buildLineChart(xCol, yCol, chartColors);
      case OiExplorerChartType.bar:
        return _buildBarChart(xCol, yCol, chartColors);
      case OiExplorerChartType.scatter:
        return _buildScatterChart(xCol, yCol, chartColors);
      case OiExplorerChartType.pie:
        return _buildPieChart(xCol, yCol, chartColors);
      case OiExplorerChartType.heatmap:
        return _buildHeatmap(xCol, yCol);
      case OiExplorerChartType.histogram:
        return _buildHistogram(yCol ?? xCol, chartColors);
    }
  }

  Widget _buildLineChart(
    OiExplorerColumn<T>? xCol,
    OiExplorerColumn<T>? yCol,
    List<Color> chartColors,
  ) {
    final effectiveY = yCol ?? xCol;
    if (effectiveY == null) return _NoPicker(colors: colors);

    final points = <OiLinePoint>[];
    for (var i = 0; i < data.length; i++) {
      final xVal = xCol != null
          ? _toDouble(xCol.accessor(data[i]), i.toDouble())
          : i.toDouble();
      final yVal = _toDouble(effectiveY.accessor(data[i]), 0);
      points.add(OiLinePoint(x: xVal, y: yVal));
    }

    return OiLineChart(
      key: const Key('oi_chart_explorer_line'),
      label: controller.yColumnId ?? controller.xColumnId ?? 'Chart',
      series: [OiLineSeries(label: effectiveY.label, points: points)],
    );
  }

  Widget _buildBarChart(
    OiExplorerColumn<T>? xCol,
    OiExplorerColumn<T>? yCol,
    List<Color> chartColors,
  ) {
    final effectiveY = yCol ?? xCol;
    if (effectiveY == null) return _NoPicker(colors: colors);

    final categories = <OiBarCategory>[];
    for (var i = 0; i < data.length; i++) {
      final catLabel = xCol != null
          ? xCol.accessor(data[i]).toString()
          : i.toString();
      final value = _toDouble(effectiveY.accessor(data[i]), 0);
      categories.add(OiBarCategory(label: catLabel, values: [value]));
    }

    return OiBarChart(
      key: const Key('oi_chart_explorer_bar'),
      label: effectiveY.label,
      categories: categories,
    );
  }

  Widget _buildScatterChart(
    OiExplorerColumn<T>? xCol,
    OiExplorerColumn<T>? yCol,
    List<Color> chartColors,
  ) {
    if (xCol == null || yCol == null) {
      return _NoPicker(
        colors: colors,
        message: 'Assign both X and Y for scatter plot',
      );
    }

    final points = <OiScatterPoint>[];
    for (final item in data) {
      points.add(
        OiScatterPoint(
          x: _toDouble(xCol.accessor(item), 0),
          y: _toDouble(yCol.accessor(item), 0),
        ),
      );
    }

    return OiScatterPlot(
      key: const Key('oi_chart_explorer_scatter'),
      label: '${xCol.label} vs ${yCol.label}',
      series: [
        OiScatterSeries(
          label: '${xCol.label} vs ${yCol.label}',
          points: points,
        ),
      ],
    );
  }

  Widget _buildPieChart(
    OiExplorerColumn<T>? xCol,
    OiExplorerColumn<T>? yCol,
    List<Color> chartColors,
  ) {
    final effectiveValue = yCol ?? xCol;
    if (effectiveValue == null) return _NoPicker(colors: colors);

    final segments = <OiPieSegment>[];
    for (var i = 0; i < data.length; i++) {
      final segLabel = xCol != null && xCol != effectiveValue
          ? xCol.accessor(data[i]).toString()
          : i.toString();
      final value = _toDouble(effectiveValue.accessor(data[i]), 0);
      if (value > 0) {
        segments.add(
          OiPieSegment(
            label: segLabel,
            value: value,
            color: chartColors[i % chartColors.length],
          ),
        );
      }
    }

    if (segments.isEmpty) return _NoData(colors: colors);

    return OiPieChart(
      key: const Key('oi_chart_explorer_pie'),
      label: effectiveValue.label,
      segments: segments,
    );
  }

  Widget _buildHeatmap(OiExplorerColumn<T>? xCol, OiExplorerColumn<T>? yCol) {
    // Build a simple flat heatmap from numeric data in a grid layout.
    // We lay out data row by row where x→column and index→row.
    if (xCol == null) return _NoPicker(colors: colors);

    final numCols = 10.clamp(1, data.length);
    final cells = <OiHeatmapCell>[];
    for (var i = 0; i < data.length; i++) {
      cells.add(
        OiHeatmapCell(
          row: i ~/ numCols,
          column: i % numCols,
          value: _toDouble(xCol.accessor(data[i]), 0),
        ),
      );
    }

    return OiHeatmap(
      key: const Key('oi_chart_explorer_heatmap'),
      label: xCol.label,
      cells: cells,
    );
  }

  Widget _buildHistogram(OiExplorerColumn<T>? col, List<Color> chartColors) {
    if (col == null) return _NoPicker(colors: colors);

    return OiHistogram<T>(
      key: const Key('oi_chart_explorer_histogram'),
      label: col.label,
      series: [
        OiHistogramSeries<T>(
          id: col.id,
          label: col.label,
          data: data,
          valueMapper: (item) => _toDouble(col.accessor(item), 0),
        ),
      ],
    );
  }

  /// Converts a dynamic value to a double for plotting.
  ///
  /// - num → toDouble()
  /// - DateTime → millisecondsSinceEpoch.toDouble()
  /// - Other → [fallback]
  static double _toDouble(dynamic value, double fallback) {
    if (value is num) return value.toDouble();
    if (value is DateTime) return value.millisecondsSinceEpoch.toDouble();
    return fallback;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _NoPicker — shown when no column is assigned yet
// ─────────────────────────────────────────────────────────────────────────────

class _NoPicker extends StatelessWidget {
  const _NoPicker({required this.colors, this.message});

  final OiColorScheme colors;
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: OiLabel.small(
          message ?? 'Select columns to visualize data',
          color: colors.textMuted,
          key: const Key('oi_chart_explorer_no_picker'),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _NoData — shown when data list is empty
// ─────────────────────────────────────────────────────────────────────────────

class _NoData extends StatelessWidget {
  const _NoData({required this.colors});

  final OiColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: OiLabel.small(
          'No data to explore',
          color: colors.textMuted,
          key: const Key('oi_chart_explorer_no_data'),
        ),
      ),
    );
  }
}
