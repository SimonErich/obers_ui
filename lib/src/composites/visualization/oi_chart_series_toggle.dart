import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:obers_ui/src/composites/visualization/oi_chart_legend.dart';
import 'package:obers_ui/src/foundation/theme/component_themes/oi_chart_theme_data.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Series Info
// ─────────────────────────────────────────────────────────────────────────────

/// Information about a single chart series for toggle purposes.
///
/// {@category Composites}
@immutable
class OiSeriesInfo {
  /// Creates an [OiSeriesInfo].
  const OiSeriesInfo({
    required this.id,
    required this.label,
    required this.color,
  });

  /// Unique identifier for this series.
  final String id;

  /// Display label for the series.
  final String label;

  /// Color of the series.
  final Color color;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OiSeriesInfo &&
        other.id == id &&
        other.label == label &&
        other.color == color;
  }

  @override
  int get hashCode => Object.hash(id, label, color);
}

// ─────────────────────────────────────────────────────────────────────────────
// OiChartSeriesToggle
// ─────────────────────────────────────────────────────────────────────────────

/// A stateful controller widget for toggling chart series visibility.
///
/// Provides UI controls for:
/// - Toggling individual series visibility
/// - Isolating a single series (exclusive focus)
/// - Bulk show/hide all operations
///
/// Integrates with [OiChartLegend] by managing series visibility state and
/// forwarding toggle/focus events to the parent via [onVisibilityChanged].
///
/// ```dart
/// OiChartSeriesToggle(
///   series: [
///     OiSeriesInfo(id: 'a', label: 'Revenue', color: Colors.blue),
///     OiSeriesInfo(id: 'b', label: 'Cost', color: Colors.red),
///   ],
///   hiddenSeriesIds: {'b'},
///   onVisibilityChanged: (hiddenIds) {
///     setState(() => _hidden = hiddenIds);
///   },
/// )
/// ```
///
/// {@category Composites}
class OiChartSeriesToggle extends StatefulWidget {
  /// Creates an [OiChartSeriesToggle].
  const OiChartSeriesToggle({
    required this.series,
    required this.onVisibilityChanged,
    super.key,
    this.hiddenSeriesIds = const {},
    this.legendPosition = OiChartLegendPosition.bottom,
    this.markerShape = OiLegendMarkerShape.square,
    this.itemBuilder,
    this.legendTheme,
    this.showBulkControls = true,
    this.semanticLabel,
  });

  /// All available series.
  final List<OiSeriesInfo> series;

  /// Callback when the set of hidden series changes.
  ///
  /// Receives the updated set of hidden series IDs.
  final ValueChanged<Set<String>> onVisibilityChanged;

  /// The set of currently hidden series IDs.
  final Set<String> hiddenSeriesIds;

  /// Position of the integrated legend.
  final OiChartLegendPosition legendPosition;

  /// Marker shape for legend items.
  final OiLegendMarkerShape markerShape;

  /// Optional custom builder for legend items.
  final OiLegendItemBuilder? itemBuilder;

  /// Optional legend theme override.
  final OiChartLegendTheme? legendTheme;

  /// Whether to show bulk "Show All" / "Hide All" controls.
  final bool showBulkControls;

  /// Accessibility label for the toggle control area.
  final String? semanticLabel;

  @override
  State<OiChartSeriesToggle> createState() => _OiChartSeriesToggleState();
}

class _OiChartSeriesToggleState extends State<OiChartSeriesToggle> {
  /// The ID of the exclusively focused series, if any.
  String? _exclusiveFocusId;

  Set<String> get _effectiveHidden {
    if (_exclusiveFocusId != null) {
      // In exclusive mode, hide everything except the focused series.
      return widget.series
          .where((s) => s.id != _exclusiveFocusId)
          .map((s) => s.id)
          .toSet();
    }
    return widget.hiddenSeriesIds;
  }

  void _toggleSeries(String id) {
    // If in exclusive mode, exit it first.
    if (_exclusiveFocusId != null) {
      setState(() => _exclusiveFocusId = null);
      // Restore original visibility (no series hidden).
      widget.onVisibilityChanged(const {});
      return;
    }

    final hidden = Set<String>.from(widget.hiddenSeriesIds);
    if (hidden.contains(id)) {
      hidden.remove(id);
    } else {
      hidden.add(id);
    }
    widget.onVisibilityChanged(hidden);
  }

  void _exclusiveFocus(String id) {
    if (_exclusiveFocusId == id) {
      // Double-tap again on the same series → exit exclusive mode.
      setState(() => _exclusiveFocusId = null);
      widget.onVisibilityChanged(const {});
      return;
    }

    setState(() => _exclusiveFocusId = id);

    // Hide all series except the focused one.
    final hidden = widget.series
        .where((s) => s.id != id)
        .map((s) => s.id)
        .toSet();
    widget.onVisibilityChanged(hidden);
  }

  void _showAll() {
    setState(() => _exclusiveFocusId = null);
    widget.onVisibilityChanged(const {});
  }

  void _hideAll() {
    setState(() => _exclusiveFocusId = null);
    final allIds = widget.series.map((s) => s.id).toSet();
    widget.onVisibilityChanged(allIds);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final hidden = _effectiveHidden;

    final legendItems = widget.series.map((s) {
      return OiChartLegendItem(
        id: s.id,
        label: s.label,
        color: s.color,
        visible: !hidden.contains(s.id),
        emphasized: _exclusiveFocusId == s.id,
        // markerShape not set – falls back to legend default.
      );
    }).toList();

    final legend = OiChartLegend(
      items: legendItems,
      position: widget.legendPosition,
      markerShape: widget.markerShape,
      onToggle: _toggleSeries,
      onExclusiveFocus: _exclusiveFocus,
      itemBuilder: widget.itemBuilder,
      legendTheme: widget.legendTheme,
      semanticLabel: widget.semanticLabel ?? 'Series toggle',
    );

    if (!widget.showBulkControls) return legend;

    final labelStyle = TextStyle(
      fontSize: 11,
      color: colors.textMuted,
    );

    return Semantics(
      label: widget.semanticLabel ?? 'Chart series toggle',
      container: true,
      child: Column(
        key: const Key('oi_chart_series_toggle'),
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          legend,
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _BulkButton(
                label: 'Show All',
                style: labelStyle,
                onTap: _showAll,
              ),
              const SizedBox(width: 12),
              _BulkButton(
                label: 'Hide All',
                style: labelStyle,
                onTap: _hideAll,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bulk Button
// ─────────────────────────────────────────────────────────────────────────────

class _BulkButton extends StatelessWidget {
  const _BulkButton({
    required this.label,
    required this.style,
    required this.onTap,
  });

  final String label;
  final TextStyle style;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Focus(
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent &&
            (event.logicalKey == LogicalKeyboardKey.enter ||
                event.logicalKey == LogicalKeyboardKey.space)) {
          onTap();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: Semantics(
        label: label,
        button: true,
        child: GestureDetector(
          onTap: onTap,
          child: Text(label, style: style),
        ),
      ),
    );
  }
}
