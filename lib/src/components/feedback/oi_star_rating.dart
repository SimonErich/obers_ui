import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';

/// A painter that draws a single star shape with a left-to-right fill
/// fraction for partial (half-star) display.
class _StarPainter extends CustomPainter {
  const _StarPainter({
    required this.fillFraction,
    required this.activeColor,
    required this.inactiveColor,
  });

  /// Fill fraction: 0.0 = empty, 0.5 = half, 1.0 = full.
  final double fillFraction;

  /// Color for the filled portion.
  final Color activeColor;

  /// Color for the unfilled portion.
  final Color inactiveColor;

  @override
  void paint(Canvas canvas, Size size) {
    final path = _starPath(size);

    // REQ-0025: inactive stars are drawn as outlines (stroke only) so that
    // the shape difference — not just color — distinguishes rated from
    // unrated stars.
    canvas.drawPath(
      path,
      Paint()
        ..color = inactiveColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    if (fillFraction > 0) {
      // Clip horizontally to reveal the active colour as a solid fill.
      canvas
        ..save()
        ..clipRect(Rect.fromLTWH(0, 0, size.width * fillFraction, size.height))
        ..drawPath(path, Paint()..color = activeColor)
        ..restore();
    }
  }

  Path _starPath(Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final outerR = size.width / 2;
    final innerR = outerR * 0.4;
    const points = 5;
    final path = Path();

    for (var i = 0; i < points * 2; i++) {
      final r = i.isEven ? outerR : innerR;
      final angle = (i * math.pi / points) - math.pi / 2;
      final x = cx + r * math.cos(angle);
      final y = cy + r * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(_StarPainter oldDelegate) =>
      fillFraction != oldDelegate.fillFraction ||
      activeColor != oldDelegate.activeColor ||
      inactiveColor != oldDelegate.inactiveColor;
}

/// A star-based rating widget that supports half-star values and hover preview.
///
/// Displays [maxStars] stars with the first [value] stars filled. When
/// [allowHalf] is `true`, half-star values (e.g. 3.5) are supported: tapping
/// the left half of a star selects a 0.5 increment; the right half selects a
/// whole-star value. On pointer devices, hovering previews the value before
/// committing. When [readOnly] is `true`, all gesture and hover detection is
/// disabled.
///
/// Arrow keys (← / →) adjust the rating by one step when focused.
///
/// {@category Components}
class OiStarRating extends StatefulWidget {
  /// Creates an [OiStarRating].
  const OiStarRating({
    this.label,
    this.value = 0.0,
    this.maxStars = 5,
    this.allowHalf = false,
    this.readOnly = false,
    this.onChanged,
    this.size = 32.0,
    this.activeColor,
    this.inactiveColor,
    super.key,
  });

  /// Accessible label announced by screen readers.
  final String? label;

  /// The current rating value, from 0.0 to [maxStars].
  final double value;

  /// The total number of stars displayed. Defaults to 5.
  final int maxStars;

  /// Whether half-star values (e.g. 2.5) are allowed.
  final bool allowHalf;

  /// Whether all interaction is disabled.
  final bool readOnly;

  /// Called when the user selects a new rating.
  final ValueChanged<double>? onChanged;

  /// Size of each individual star in logical pixels. Defaults to 32.
  final double size;

  /// Color of filled stars. Defaults to the theme warning swatch base color.
  final Color? activeColor;

  /// Color of empty stars. Defaults to the theme border color.
  final Color? inactiveColor;

  @override
  State<OiStarRating> createState() => _OiStarRatingState();
}

class _OiStarRatingState extends State<OiStarRating> {
  double? _hoverValue;

  double get _step => widget.allowHalf ? 0.5 : 1.0;

  double _candidateValue(int starIndex, double localX) {
    if (widget.allowHalf && localX < widget.size / 2) {
      return starIndex + 0.5;
    }
    return (starIndex + 1).toDouble();
  }

  double _fillFraction(int starIndex, double displayValue) {
    final diff = displayValue - starIndex;
    if (diff <= 0) return 0;
    if (diff >= 1) return 1;
    return diff;
  }

  KeyEventResult _onKeyEvent(FocusNode node, KeyEvent event) {
    if (widget.readOnly || widget.onChanged == null) {
      return KeyEventResult.ignored;
    }
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }

    if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      final next = (widget.value + _step).clamp(
        0.0,
        widget.maxStars.toDouble(),
      );
      widget.onChanged?.call(next);
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      final next = (widget.value - _step).clamp(
        0.0,
        widget.maxStars.toDouble(),
      );
      widget.onChanged?.call(next);
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final activeColor = widget.activeColor ?? colors.warning.base;
    final inactiveColor = widget.inactiveColor ?? colors.border;
    final display = _hoverValue ?? widget.value;

    Widget buildStar(int i) {
      Widget star = SizedBox(
        width: widget.size,
        height: widget.size,
        child: CustomPaint(
          painter: _StarPainter(
            fillFraction: _fillFraction(i, display),
            activeColor: activeColor,
            inactiveColor: inactiveColor,
          ),
        ),
      );

      if (!widget.readOnly) {
        star = MouseRegion(
          cursor: SystemMouseCursors.click,
          onHover: (e) => setState(
            () => _hoverValue = _candidateValue(i, e.localPosition.dx),
          ),
          onExit: (_) => setState(() => _hoverValue = null),
          child: GestureDetector(
            onTapDown: (d) =>
                widget.onChanged?.call(_candidateValue(i, d.localPosition.dx)),
            child: star,
          ),
        );
      }
      return star;
    }

    final baseLabel = widget.label != null ? '${widget.label}, ' : '';
    final semanticLabel =
        '${baseLabel}Rating ${widget.value} out of ${widget.maxStars}';

    final stars = Row(
      mainAxisSize: MainAxisSize.min,
      children: List<Widget>.generate(widget.maxStars, buildStar),
    );

    return Semantics(
      label: semanticLabel,
      slider: true,
      value: '${widget.value}',
      increasedValue: widget.readOnly
          ? null
          : '${(widget.value + _step).clamp(0.0, widget.maxStars.toDouble())}',
      decreasedValue: widget.readOnly
          ? null
          : '${(widget.value - _step).clamp(0.0, widget.maxStars.toDouble())}',
      child: widget.readOnly
          ? stars
          : Focus(onKeyEvent: _onKeyEvent, child: stars),
    );
  }
}
