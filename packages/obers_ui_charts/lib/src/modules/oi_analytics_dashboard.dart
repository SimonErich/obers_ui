import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_charts/src/foundation/oi_chart_settings_driver_binding.dart';
import 'package:obers_ui_charts/src/foundation/oi_chart_sync_group.dart';
import 'package:obers_ui_charts/src/modules/oi_dashboard_filter.dart';
import 'package:obers_ui_charts/src/modules/oi_dashboard_panel.dart';
import 'package:obers_ui_charts/src/modules/oi_grid_position.dart';

/// A responsive, multi-chart analytics dashboard with synchronized filtering
/// and optional shared hover/selection state across all panels.
///
/// [OiAnalyticsDashboard] arranges [panels] in a CSS-grid-style layout where
/// each panel declares its own [OiGridPosition]. The number of logical grid
/// columns is controlled by [columns] (default 3), and each row's height is
/// fixed by [rowHeight] (default 250 px). On narrow screens the layout adapts:
/// when available width is less than `columns × 160 px`, the effective column
/// count is reduced automatically.
///
/// Panels are rendered as titled surfaces. The panel [OiDashboardPanel.chart]
/// widget fills the body of each surface, with the panel title rendered in a
/// thin header bar above it.
///
/// When [syncGroup] is provided every child panel is wrapped in an
/// [OiChartSyncProvider] so that hover and crosshair interactions propagate
/// across all charts on the dashboard.
///
/// An optional [filters] list renders a filter bar above the grid. Filter
/// change callbacks are forwarded through [onFilterChange].
///
/// The [label] is required for accessibility and is announced by screen
/// readers as the semantic label for the dashboard container.
///
/// ```dart
/// OiAnalyticsDashboard(
///   label: 'Sales Analytics',
///   panels: [
///     OiDashboardPanel(
///       id: 'revenue',
///       title: 'Revenue Over Time',
///       gridPosition: OiGridPosition(row: 0, col: 0, colSpan: 2),
///       chart: OiLineChart(...),
///     ),
///     OiDashboardPanel(
///       id: 'breakdown',
///       title: 'Revenue by Category',
///       gridPosition: OiGridPosition(row: 0, col: 2),
///       chart: OiPieChart(...),
///     ),
///   ],
///   syncGroup: 'sales-dashboard',
///   columns: 3,
///   rowHeight: 250,
///   spacing: 16,
/// )
/// ```
///
/// {@category Modules}
class OiAnalyticsDashboard extends StatelessWidget {
  /// Creates an [OiAnalyticsDashboard].
  const OiAnalyticsDashboard({
    required this.label,
    required this.panels,
    super.key,
    this.syncGroup,
    this.columns = 3,
    this.rowHeight = 250.0,
    this.spacing = 16.0,
    this.filters = const [],
    this.onFilterChange,
    this.settings,
    this.semanticLabel,
  });

  /// The accessibility label for the dashboard.
  ///
  /// Announced by screen readers as the label for the dashboard container.
  final String label;

  /// The panels to display in the dashboard grid.
  ///
  /// An empty list renders an empty-state message.
  final List<OiDashboardPanel> panels;

  /// Optional sync group identifier.
  ///
  /// When set, all chart panels are wrapped in an [OiChartSyncProvider] so
  /// that hover, crosshair, and selection interactions are synchronized
  /// across charts.
  final String? syncGroup;

  /// The number of logical grid columns. Defaults to 3.
  ///
  /// The actual column count may be reduced when the available width is
  /// insufficient to render [columns] columns at a minimum of 160 px each.
  final int columns;

  /// The fixed height of each row in logical pixels. Defaults to 250.
  final double rowHeight;

  /// The gap between panels in logical pixels. Defaults to 16.
  final double spacing;

  /// Optional list of dashboard-level filters.
  ///
  /// Rendered in a filter bar above the panel grid. Use [onFilterChange] to
  /// react to user interaction.
  final List<OiDashboardFilter> filters;

  /// Called when the user interacts with any dashboard filter.
  final ValueChanged<List<OiDashboardFilter>>? onFilterChange;

  /// Optional settings persistence binding.
  final OiChartSettingsDriverBinding? settings;

  /// An optional override for the semantic label.
  ///
  /// When null, [label] is used.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final effectiveSemanticLabel = semanticLabel ?? label;

    if (panels.isEmpty) {
      return Semantics(
        label: effectiveSemanticLabel,
        child: _EmptyState(colors: colors),
      );
    }

    Widget grid = LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;

        // Compute effective column count from available width.
        const minColWidth = 160.0;
        final maxCols = columns.clamp(1, panels.length);
        var effectiveCols = maxCols;
        while (effectiveCols > 1) {
          final colWidth =
              (availableWidth - spacing * (effectiveCols - 1)) / effectiveCols;
          if (colWidth >= minColWidth) break;
          effectiveCols--;
        }

        final colWidth =
            (availableWidth - spacing * (effectiveCols - 1)) / effectiveCols;

        // Determine how many rows are needed.
        var maxRow = 0;
        for (final panel in panels) {
          final lastRow =
              panel.gridPosition.row + panel.gridPosition.rowSpan - 1;
          if (lastRow > maxRow) maxRow = lastRow;
        }
        final rowCount = maxRow + 1;

        final totalHeight = rowCount * rowHeight + (rowCount - 1) * spacing;

        return SizedBox(
          height: totalHeight,
          child: Stack(
            key: const Key('oi_analytics_dashboard_grid'),
            children: [
              for (final panel in panels)
                _PanelPositioned(
                  panel: panel,
                  effectiveCols: effectiveCols,
                  colWidth: colWidth,
                  rowHeight: rowHeight,
                  spacing: spacing,
                  colors: colors,
                ),
            ],
          ),
        );
      },
    );

    // Wrap with sync provider when a syncGroup is specified.
    if (syncGroup != null) {
      grid = OiChartSyncProvider(syncGroup: syncGroup!, child: grid);
    }

    return Semantics(
      label: effectiveSemanticLabel,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (filters.isNotEmpty) ...[
            _FilterBar(
              filters: filters,
              onFilterChange: onFilterChange,
              colors: colors,
            ),
            SizedBox(height: spacing),
          ],
          grid,
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _PanelPositioned — positions a single panel in the Stack grid
// ─────────────────────────────────────────────────────────────────────────────

class _PanelPositioned extends StatelessWidget {
  const _PanelPositioned({
    required this.panel,
    required this.effectiveCols,
    required this.colWidth,
    required this.rowHeight,
    required this.spacing,
    required this.colors,
  });

  final OiDashboardPanel panel;
  final int effectiveCols;
  final double colWidth;
  final double rowHeight;
  final double spacing;
  final OiColorScheme colors;

  @override
  Widget build(BuildContext context) {
    final pos = panel.gridPosition;

    // Clamp col/colSpan to the effective column count.
    final col = pos.col.clamp(0, effectiveCols - 1);
    final colSpan = pos.colSpan.clamp(1, effectiveCols - col);

    final left = col * (colWidth + spacing);
    final top = pos.row * (rowHeight + spacing);
    final width = colSpan * colWidth + (colSpan - 1) * spacing;
    final height = pos.rowSpan * rowHeight + (pos.rowSpan - 1) * spacing;

    return Positioned(
      left: left,
      top: top,
      width: width,
      height: height,
      child: _PanelSurface(panel: panel, colors: colors),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _PanelSurface — titled card containing the chart
// ─────────────────────────────────────────────────────────────────────────────

class _PanelSurface extends StatelessWidget {
  const _PanelSurface({required this.panel, required this.colors});

  final OiDashboardPanel panel;
  final OiColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: panel.title,
      child: OiSurface(
        key: Key('oi_dashboard_panel_${panel.id}'),
        color: colors.surface,
        border: OiBorderStyle.solid(colors.borderSubtle, 1),
        borderRadius: BorderRadius.circular(8),
        padding: const EdgeInsets.all(0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Panel header ───────────────────────────────────────────
            Container(
              key: Key('oi_dashboard_panel_header_${panel.id}'),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: colors.borderSubtle, width: 1),
                ),
              ),
              child: OiLabel.small(
                panel.title,
                color: colors.textSubtle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // ── Chart body ─────────────────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: panel.chart,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _FilterBar — renders dashboard-level filters
// ─────────────────────────────────────────────────────────────────────────────

class _FilterBar extends StatelessWidget {
  const _FilterBar({
    required this.filters,
    required this.colors,
    this.onFilterChange,
  });

  final List<OiDashboardFilter> filters;
  final ValueChanged<List<OiDashboardFilter>>? onFilterChange;
  final OiColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      key: const Key('oi_analytics_dashboard_filter_bar'),
      spacing: 12,
      runSpacing: 8,
      children: [
        for (final filter in filters)
          _FilterChip(filter: filter, colors: colors),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.filter, required this.colors});

  final OiDashboardFilter filter;
  final OiColorScheme colors;

  @override
  Widget build(BuildContext context) {
    final description = switch (filter) {
      OiDateRangeFilter(:final start, :final end) => () {
        if (start == null && end == null) return filter.label;
        final s = start == null
            ? '…'
            : '${start.year}-${start.month.toString().padLeft(2, '0')}-${start.day.toString().padLeft(2, '0')}';
        final e = end == null
            ? '…'
            : '${end.year}-${end.month.toString().padLeft(2, '0')}-${end.day.toString().padLeft(2, '0')}';
        return '${filter.label}: $s – $e';
      }(),
      OiDropdownFilter(:final selected) =>
        selected == null ? filter.label : '${filter.label}: $selected',
      _ => filter.label,
    };

    return OiSurface(
      key: Key('oi_dashboard_filter_${filter.id}'),
      color: colors.surfaceSubtle,
      border: OiBorderStyle.solid(colors.borderSubtle, 1),
      borderRadius: BorderRadius.circular(4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: OiLabel.caption(description, color: colors.textSubtle),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _EmptyState
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.colors});

  final OiColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: OiLabel.small(
          'No panels to display',
          color: colors.textMuted,
          key: const Key('oi_analytics_dashboard_empty'),
        ),
      ),
    );
  }
}
