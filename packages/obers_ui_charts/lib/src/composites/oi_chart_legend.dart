import 'package:flutter/services.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Legend Position
// ─────────────────────────────────────────────────────────────────────────────

/// Position of the chart legend relative to the chart.
///
/// {@category Composites}
enum OiChartLegendPosition {
  /// Above the chart.
  top,

  /// Below the chart.
  bottom,

  /// To the left of the chart.
  left,

  /// To the right of the chart.
  right,

  /// Floating overlay on top of the chart.
  floating,
}

// ─────────────────────────────────────────────────────────────────────────────
// Marker Shape
// ─────────────────────────────────────────────────────────────────────────────

/// Shape of the color indicator in a legend item.
///
/// {@category Composites}
enum OiLegendMarkerShape {
  /// A small square with rounded corners.
  square,

  /// A circle.
  circle,

  /// A horizontal line (suitable for line charts).
  line,

  /// A diamond / rotated square.
  diamond,

  /// A triangle pointing up.
  triangle,
}

// ─────────────────────────────────────────────────────────────────────────────
// Legend Item Data
// ─────────────────────────────────────────────────────────────────────────────

/// Data for a single legend item.
///
/// {@category Composites}
@immutable
class OiChartLegendItem {
  /// Creates an [OiChartLegendItem].
  const OiChartLegendItem({
    required this.id,
    required this.label,
    required this.color,
    this.visible = true,
    this.emphasized = false,
    this.markerShape,
  });

  /// Unique identifier for this series.
  final String id;

  /// Display label for the series.
  final String label;

  /// Color of the series marker.
  final Color color;

  /// Whether the series is currently visible.
  final bool visible;

  /// Whether the series is currently emphasized (exclusive focus).
  final bool emphasized;

  /// Optional marker shape override for this item.
  final OiLegendMarkerShape? markerShape;

  /// Returns a copy with the specified fields replaced.
  OiChartLegendItem copyWith({
    String? id,
    String? label,
    Color? color,
    bool? visible,
    bool? emphasized,
    OiLegendMarkerShape? markerShape,
  }) {
    return OiChartLegendItem(
      id: id ?? this.id,
      label: label ?? this.label,
      color: color ?? this.color,
      visible: visible ?? this.visible,
      emphasized: emphasized ?? this.emphasized,
      markerShape: markerShape ?? this.markerShape,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OiChartLegendItem &&
        other.id == id &&
        other.label == label &&
        other.color == color &&
        other.visible == visible &&
        other.emphasized == emphasized &&
        other.markerShape == markerShape;
  }

  @override
  int get hashCode =>
      Object.hash(id, label, color, visible, emphasized, markerShape);
}

// ─────────────────────────────────────────────────────────────────────────────
// Legend Item Builder
// ─────────────────────────────────────────────────────────────────────────────

/// Callback for building a custom legend item widget.
///
/// {@category Composites}
typedef OiLegendItemBuilder =
    Widget Function(
      BuildContext context,
      OiChartLegendItem item,
      int index,
      VoidCallback? onTap,
      VoidCallback? onDoubleTap,
    );

// ─────────────────────────────────────────────────────────────────────────────
// OiChartLegend
// ─────────────────────────────────────────────────────────────────────────────

/// A chart legend that displays series identification with interactive
/// toggle, exclusive focus, and keyboard support.
///
/// Features:
/// - Show/hide toggle per series on tap
/// - Exclusive focus (isolate a single series) on double-tap
/// - Keyboard operable (Enter/Space to toggle, Shift+Enter for exclusive)
/// - Configurable marker shapes
/// - Custom item builder
/// - Responsive: on compact breakpoints, auto-moves below chart
/// - Wrap behaviour for many series
///
/// ```dart
/// OiChartLegend(
///   items: [
///     OiChartLegendItem(id: 'a', label: 'Revenue', color: Colors.blue),
///     OiChartLegendItem(id: 'b', label: 'Cost', color: Colors.red),
///   ],
///   onToggle: (id) { /* toggle series visibility */ },
///   onExclusiveFocus: (id) { /* show only this series */ },
/// )
/// ```
///
/// {@category Composites}
class OiChartLegend extends StatelessWidget {
  /// Creates an [OiChartLegend].
  const OiChartLegend({
    required this.items,
    super.key,
    this.position = OiChartLegendPosition.bottom,
    this.markerShape = OiLegendMarkerShape.square,
    this.onToggle,
    this.onExclusiveFocus,
    this.itemBuilder,
    this.legendTheme,
    this.semanticLabel,
  });

  /// The legend items to display.
  final List<OiChartLegendItem> items;

  /// Position of the legend relative to the chart.
  ///
  /// On compact breakpoints, the legend automatically moves to `bottom`
  /// regardless of this setting.
  final OiChartLegendPosition position;

  /// Default marker shape for all items (overridden by per-item shapes).
  final OiLegendMarkerShape markerShape;

  /// Callback when a legend item is tapped to toggle series visibility.
  final ValueChanged<String>? onToggle;

  /// Callback when a legend item is double-tapped for exclusive focus.
  ///
  /// The chart should show only the identified series and hide all others.
  final ValueChanged<String>? onExclusiveFocus;

  /// Optional custom builder for individual legend items.
  final OiLegendItemBuilder? itemBuilder;

  /// Optional legend theme override.
  final OiChartLegendTheme? legendTheme;

  /// Accessibility label for the legend container.
  final String? semanticLabel;

  /// Resolves the effective position, taking the compact breakpoint into
  /// account.
  OiChartLegendPosition resolvePosition(BuildContext context) {
    if (context.isCompact) return OiChartLegendPosition.bottom;
    return position;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final theme = legendTheme ?? context.components.chart?.legend;
    final iconSize = theme?.iconSize ?? 12.0;
    final spacing = theme?.spacing ?? 16.0;
    final padding = theme?.padding ?? EdgeInsets.zero;
    final labelStyle = (theme?.labelStyle ?? const TextStyle(fontSize: 12))
        .copyWith(color: theme?.labelColor ?? colors.textMuted);

    return Semantics(
      label: semanticLabel ?? 'Chart legend',
      container: true,
      child: Padding(
        padding: padding,
        child: Wrap(
          key: const Key('oi_chart_legend'),
          spacing: spacing,
          runSpacing: 4,
          children: [
            for (var i = 0; i < items.length; i++)
              _buildItem(context, items[i], i, iconSize, labelStyle),
          ],
        ),
      ),
    );
  }

  Widget _buildItem(
    BuildContext context,
    OiChartLegendItem item,
    int index,
    double iconSize,
    TextStyle labelStyle,
  ) {
    final onTap = onToggle != null ? () => onToggle!(item.id) : null;
    final onDoubleTap = onExclusiveFocus != null
        ? () => onExclusiveFocus!(item.id)
        : null;

    if (itemBuilder != null) {
      return itemBuilder!(context, item, index, onTap, onDoubleTap);
    }

    final shape = item.markerShape ?? markerShape;
    final dimmed = !item.visible;

    return Focus(
      key: Key('oi_chart_legend_item_${item.id}'),
      onKeyEvent: (node, event) {
        if (event is! KeyDownEvent) return KeyEventResult.ignored;
        if (event.logicalKey == LogicalKeyboardKey.enter ||
            event.logicalKey == LogicalKeyboardKey.space) {
          // Shift+key → exclusive focus; plain key → toggle.
          if (HardwareKeyboard.instance.isShiftPressed) {
            onDoubleTap?.call();
          } else {
            onTap?.call();
          }
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: Semantics(
        label: '${item.label}, ${item.visible ? "visible" : "hidden"}',
        toggled: item.visible,
        button: true,
        child: GestureDetector(
          onTap: onTap,
          onDoubleTap: onDoubleTap,
          child: Opacity(
            opacity: dimmed ? 0.4 : 1.0,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _LegendMarker(
                  color: item.color,
                  shape: shape,
                  size: iconSize,
                  emphasized: item.emphasized,
                ),
                SizedBox(width: iconSize / 3),
                OiLabel.caption(item.label, color: labelStyle.color),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Legend Marker
// ─────────────────────────────────────────────────────────────────────────────

class _LegendMarker extends StatelessWidget {
  const _LegendMarker({
    required this.color,
    required this.shape,
    required this.size,
    this.emphasized = false,
  });

  final Color color;
  final OiLegendMarkerShape shape;
  final double size;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(shape == OiLegendMarkerShape.line ? size * 1.5 : size, size),
      painter: _MarkerPainter(
        color: color,
        shape: shape,
        emphasized: emphasized,
      ),
    );
  }
}

class _MarkerPainter extends CustomPainter {
  _MarkerPainter({
    required this.color,
    required this.shape,
    this.emphasized = false,
  });

  final Color color;
  final OiLegendMarkerShape shape;
  final bool emphasized;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final strokePaint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    switch (shape) {
      case OiLegendMarkerShape.square:
        final rect = RRect.fromRectAndRadius(
          Offset.zero & size,
          Radius.circular(size.width * 0.15),
        );
        canvas.drawRRect(rect, paint);
        if (emphasized) canvas.drawRRect(rect, strokePaint);

      case OiLegendMarkerShape.circle:
        final r = size.shortestSide / 2;
        canvas.drawCircle(size.center(Offset.zero), r, paint);
        if (emphasized) {
          canvas.drawCircle(size.center(Offset.zero), r, strokePaint);
        }

      case OiLegendMarkerShape.line:
        final linePaint = Paint()
          ..color = color
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round;
        final y = size.height / 2;
        canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
        if (emphasized) {
          canvas.drawCircle(Offset(size.width / 2, y), size.height / 4, paint);
        }

      case OiLegendMarkerShape.diamond:
        final path = Path()
          ..moveTo(size.width / 2, 0)
          ..lineTo(size.width, size.height / 2)
          ..lineTo(size.width / 2, size.height)
          ..lineTo(0, size.height / 2)
          ..close();
        canvas.drawPath(path, paint);
        if (emphasized) canvas.drawPath(path, strokePaint);

      case OiLegendMarkerShape.triangle:
        final path = Path()
          ..moveTo(size.width / 2, 0)
          ..lineTo(size.width, size.height)
          ..lineTo(0, size.height)
          ..close();
        canvas.drawPath(path, paint);
        if (emphasized) canvas.drawPath(path, strokePaint);
    }
  }

  @override
  bool shouldRepaint(_MarkerPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.shape != shape ||
      oldDelegate.emphasized != emphasized;
}
