import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_charts/src/primitives/markers/chart_marker.dart';

/// A single item in a chart legend.
class OiChartLegendItem {
  const OiChartLegendItem({
    required this.label,
    required this.color,
    this.dashed = false,
    this.shape = OiMarkerShape.circle,
  });

  final String label;
  final Color color;
  final bool dashed;
  final OiMarkerShape shape;
}

/// A chart legend widget that displays series labels with color indicators.
///
/// Uses [OiLabel] for text rendering per REQ-0007.
class OiChartLegend extends StatelessWidget {
  const OiChartLegend({
    required this.items,
    super.key,
    this.direction = Axis.horizontal,
    this.onItemTap,
  });

  final List<OiChartLegendItem> items;
  final Axis direction;
  final ValueChanged<int>? onItemTap;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[
      for (var i = 0; i < items.length; i++) _buildItem(context, i),
    ];

    return Semantics(
      label: 'Chart legend',
      child: direction == Axis.horizontal
          ? Wrap(spacing: 16, runSpacing: 8, children: children)
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: children,
            ),
    );
  }

  Widget _buildItem(BuildContext context, int index) {
    final item = items[index];

    final child = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _LegendSwatch(color: item.color, shape: item.shape, dashed: item.dashed),
        const SizedBox(width: 6),
        OiLabel.small(item.label),
      ],
    );

    if (onItemTap != null) {
      return GestureDetector(onTap: () => onItemTap!(index), child: child);
    }

    return child;
  }
}

class _LegendSwatch extends StatelessWidget {
  const _LegendSwatch({
    required this.color,
    required this.shape,
    required this.dashed,
  });

  final Color color;
  final OiMarkerShape shape;
  final bool dashed;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(12, 12),
      painter: _SwatchPainter(color: color, shape: shape, dashed: dashed),
    );
  }
}

class _SwatchPainter extends CustomPainter {
  const _SwatchPainter({
    required this.color,
    required this.shape,
    required this.dashed,
  });

  final Color color;
  final OiMarkerShape shape;
  final bool dashed;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    if (shape == OiMarkerShape.none) {
      // Draw a line swatch.
      final paint = Paint()
        ..color = color
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;
      canvas.drawLine(
        Offset(0, size.height / 2),
        Offset(size.width, size.height / 2),
        paint,
      );
      return;
    }

    OiChartMarkerPainter.paint(
      canvas,
      center,
      shape: shape,
      color: color,
      size: size.width,
    );
  }

  @override
  bool shouldRepaint(covariant _SwatchPainter oldDelegate) =>
      color != oldDelegate.color ||
      shape != oldDelegate.shape ||
      dashed != oldDelegate.dashed;
}
