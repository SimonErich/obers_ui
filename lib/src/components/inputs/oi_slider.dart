import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/_internal/oi_input_frame.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';

/// A draggable slider for selecting a value in a continuous or discrete range.
///
/// Supports single-thumb and dual-thumb (range) modes. Use [secondaryValue]
/// for the upper bound of a range selection; [onRangeChanged] fires instead
/// of [onChanged] in that case. [divisions] snaps the thumb to evenly-spaced
/// tick marks. [showLabels] displays the current value(s) above each thumb;
/// [showTicks] renders tick marks on the track.
///
/// {@category Components}
class OiSlider extends StatefulWidget {
  /// Creates an [OiSlider].
  const OiSlider({
    required this.value,
    required this.min,
    required this.max,
    this.secondaryValue,
    this.divisions,
    this.onChanged,
    this.onRangeChanged,
    this.label,
    this.showLabels = false,
    this.showTicks = false,
    this.enabled = true,
    this.semanticLabel,
    this.secondarySemanticLabel,
    this.surfaceBuilder,
    this.height,
    super.key,
  });

  /// Accessible name without a visible form label.
  final String? semanticLabel;

  /// Accessible name of the upper thumb of a range.
  final String? secondarySemanticLabel;

  /// Optional complete visual surface. Fractions are normalized to 0–1;
  /// OiSlider retains pointer, keyboard, focus and semantic interactions.
  final Widget Function(BuildContext, double, double?)? surfaceBuilder;

  /// Height of a custom surface (ordinary sliders retain their standard size).
  final double? height;

  /// The current primary (or lower-range) thumb value.
  final double value;

  /// When non-null, a second thumb is shown for range selection.
  final double? secondaryValue;

  /// The minimum selectable value.
  final double min;

  /// The maximum selectable value.
  final double max;

  /// Number of discrete divisions. When null the slider is continuous.
  final int? divisions;

  /// Called when the primary thumb value changes.
  final ValueChanged<double>? onChanged;

  /// Called when either range thumb changes. Fires instead of [onChanged]
  /// when [secondaryValue] is non-null.
  final void Function(double start, double end)? onRangeChanged;

  /// Optional label rendered above the slider via [OiInputFrame].
  final String? label;

  /// Whether to show value labels above each thumb.
  final bool showLabels;

  /// Whether to render tick marks at division positions.
  final bool showTicks;

  /// Whether the slider responds to drag gestures.
  final bool enabled;

  @override
  State<OiSlider> createState() => _OiSliderState();
}

class _OiSliderState extends State<OiSlider>
    with SingleTickerProviderStateMixin {
  // Which thumb is being dragged: 0 = primary, 1 = secondary.
  int? _draggingThumb;
  int? _focusedThumb;

  late AnimationController _animController;
  late double _startValue;
  late double _startSecondary;
  late double _targetValue;
  late double _targetSecondary;

  // Display values are derived from the animation progress at paint time
  // rather than stored via setState on every tick — see the AnimatedBuilder
  // in build(). This keeps the per-frame work to a repaint of the painter
  // instead of a full subtree rebuild.
  double get _displayValue =>
      _startValue + (_targetValue - _startValue) * _animController.value;
  double get _displaySecondary =>
      _startSecondary +
      (_targetSecondary - _startSecondary) * _animController.value;

  @override
  void initState() {
    super.initState();
    final initialSecondary = widget.secondaryValue ?? widget.value;
    _targetValue = widget.value;
    _targetSecondary = initialSecondary;
    _startValue = widget.value;
    _startSecondary = initialSecondary;
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
      value: 1, // start settled; display == value at t=1 (start==target)
    );
  }

  @override
  void didUpdateWidget(OiSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newSecondary = widget.secondaryValue ?? widget.value;
    if (widget.value != _targetValue || newSecondary != _targetSecondary) {
      _startValue = _displayValue;
      _startSecondary = _displaySecondary;
      _targetValue = widget.value;
      _targetSecondary = newSecondary;
      if (_draggingThumb != null) {
        // While dragging, snap immediately — no animation lag. At t=1 the
        // display getters evaluate to the target, so this shows the new value.
        _animController.value = 1.0;
      } else {
        _animController.value = 0.0;
        _animController.animateTo(1, curve: Curves.easeOutCubic);
      }
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  double _snap(double v) {
    if (widget.divisions == null || widget.divisions! <= 0) return v;
    final step = (widget.max - widget.min) / widget.divisions!;
    return widget.min + ((v - widget.min) / step).round() * step;
  }

  double _clamp(double v) => v.clamp(widget.min, widget.max);

  double _valueFromPosition(double dx, double width) {
    final inset = widget.surfaceBuilder == null ? 10.0 : 0.0;
    final ratio = ((dx - inset) / (width - 2 * inset)).clamp(0.0, 1.0);
    return _clamp(_snap(widget.min + ratio * (widget.max - widget.min)));
  }

  void _handleDragStart(DragStartDetails details, double width) {
    if (!widget.enabled) return;
    final v = _valueFromPosition(details.localPosition.dx, width);
    if (widget.secondaryValue != null) {
      final dPrimary = (v - widget.value).abs();
      final dSecondary = (v - widget.secondaryValue!).abs();
      _draggingThumb = dPrimary <= dSecondary ? 0 : 1;
    } else {
      _draggingThumb = 0;
    }
    _applyDrag(details.localPosition.dx, width);
  }

  void _handleDragUpdate(DragUpdateDetails details, double width) {
    if (!widget.enabled || _draggingThumb == null) return;
    _applyDrag(details.localPosition.dx, width);
  }

  void _handleDragEnd(DragEndDetails _) => _draggingThumb = null;

  void _applyDrag(double dx, double width) {
    final v = _valueFromPosition(dx, width);
    if (widget.secondaryValue != null) {
      if (_draggingThumb == 0) {
        final start = v.clamp(widget.min, widget.secondaryValue!);
        widget.onRangeChanged?.call(start, widget.secondaryValue!);
      } else {
        final end = v.clamp(widget.value, widget.max);
        widget.onRangeChanged?.call(widget.value, end);
      }
    } else {
      widget.onChanged?.call(v);
    }
  }

  void _handleTapDown(TapDownDetails details, double width) {
    if (!widget.enabled) return;
    final v = _valueFromPosition(details.localPosition.dx, width);
    if (widget.secondaryValue != null) {
      final dPrimary = (v - widget.value).abs();
      final dSecondary = (v - widget.secondaryValue!).abs();
      if (dPrimary <= dSecondary) {
        final start = v.clamp(widget.min, widget.secondaryValue!);
        widget.onRangeChanged?.call(start, widget.secondaryValue!);
      } else {
        final end = v.clamp(widget.value, widget.max);
        widget.onRangeChanged?.call(widget.value, end);
      }
    } else {
      widget.onChanged?.call(v);
    }
  }

  double _fraction(double value) =>
      ((value - widget.min) / (widget.max - widget.min)).clamp(0.0, 1.0);

  void _adjust(int thumb, int direction) {
    if (!widget.enabled) return;
    final step = (widget.max - widget.min) / (widget.divisions ?? 100);
    if (widget.secondaryValue == null) {
      widget.onChanged?.call(_clamp(widget.value + direction * step));
    } else if (thumb == 0) {
      widget.onRangeChanged?.call(
        (widget.value + direction * step).clamp(
          widget.min,
          widget.secondaryValue!,
        ),
        widget.secondaryValue!,
      );
    } else {
      widget.onRangeChanged?.call(
        widget.value,
        (widget.secondaryValue! + direction * step).clamp(
          widget.value,
          widget.max,
        ),
      );
    }
  }

  Widget _semanticThumb(
    BuildContext context,
    int thumb,
    double width,
    double height,
  ) {
    final value = thumb == 0 ? widget.value : widget.secondaryValue!;
    final step = (widget.max - widget.min) / (widget.divisions ?? 100);
    final lower = thumb == 0 ? widget.min : widget.value;
    final upper = thumb == 0 ? widget.secondaryValue ?? widget.max : widget.max;
    final inset = widget.surfaceBuilder == null ? 10.0 : 0.0;
    final x = inset + _fraction(value) * (width - 2 * inset);
    return Positioned(
      left: (x - 22).clamp(0.0, (width - 44).clamp(0.0, double.infinity)),
      top: 0,
      width: 44,
      height: height,
      child: Focus(
        canRequestFocus: widget.enabled,
        onFocusChange: (focused) => setState(() {
          _focusedThumb = focused
              ? thumb
              : _focusedThumb == thumb
              ? null
              : _focusedThumb;
        }),
        onKeyEvent: (_, event) {
          if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
            return KeyEventResult.ignored;
          }
          final key = event.logicalKey;
          if (key == LogicalKeyboardKey.arrowRight ||
              key == LogicalKeyboardKey.arrowUp) {
            _adjust(thumb, 1);
            return KeyEventResult.handled;
          }
          if (key == LogicalKeyboardKey.arrowLeft ||
              key == LogicalKeyboardKey.arrowDown) {
            _adjust(thumb, -1);
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        },
        child: Semantics(
          container: true,
          slider: true,
          enabled: widget.enabled,
          label: thumb == 0
              ? widget.semanticLabel ?? widget.label
              : widget.secondarySemanticLabel ??
                    widget.semanticLabel ??
                    widget.label,
          value: value.toStringAsFixed(1),
          increasedValue: (value + step).clamp(lower, upper).toStringAsFixed(1),
          decreasedValue: (value - step).clamp(lower, upper).toStringAsFixed(1),
          onIncrease: widget.enabled ? () => _adjust(thumb, 1) : null,
          onDecrease: widget.enabled ? () => _adjust(thumb, -1) : null,
          child: DecoratedBox(
            decoration: BoxDecoration(
              border:
                  _focusedThumb == thumb &&
                      FocusManager.instance.highlightMode ==
                          FocusHighlightMode.traditional
                  ? Border.all(
                      color: context.effects.focusRing.enforced.color,
                      width: context.effects.focusRing.enforced.width,
                    )
                  : null,
              borderRadius: context.effects.focusRing.enforced.borderRadius,
            ),
            child: const SizedBox.expand(),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final reduceMotion =
        context.animations.reducedMotion ||
        MediaQuery.disableAnimationsOf(context);
    if (reduceMotion) {
      _animController.duration = Duration.zero;
    } else {
      _animController.duration = const Duration(milliseconds: 250);
    }
    const trackHeight = 4.0;
    const thumbRadius = 10.0;
    final totalHeight = widget.height ?? 28.0;

    Widget slider = LayoutBuilder(
      builder: (ctx, constraints) {
        final width = constraints.maxWidth;
        return GestureDetector(
          onTapDown: (d) => _handleTapDown(d, width),
          onHorizontalDragStart: (d) => _handleDragStart(d, width),
          onHorizontalDragUpdate: (d) => _handleDragUpdate(d, width),
          onHorizontalDragEnd: _handleDragEnd,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: EdgeInsets.only(top: widget.showLabels ? 16.0 : 0.0),
            child: SizedBox(
              height: totalHeight + (widget.showLabels ? 20.0 : 0.0),
              width: double.infinity,
              // Only the painter rebuilds per animation frame; the gesture/
              // layout tree above stays put, and the RepaintBoundary keeps the
              // per-frame repaint off neighbouring widgets.
              child: RepaintBoundary(
                child: AnimatedBuilder(
                  animation: _animController,
                  builder: (context, _) => Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned.fill(
                        child:
                            widget.surfaceBuilder?.call(
                              context,
                              _fraction(_displayValue),
                              widget.secondaryValue == null
                                  ? null
                                  : _fraction(_displaySecondary),
                            ) ??
                            CustomPaint(
                              painter: _OiSliderPainter(
                                value: _displayValue,
                                secondaryValue: widget.secondaryValue != null
                                    ? _displaySecondary
                                    : null,
                                labelValue: widget.value,
                                labelSecondaryValue: widget.secondaryValue,
                                min: widget.min,
                                max: widget.max,
                                divisions: widget.divisions,
                                trackColor: colors.border,
                                activeColor: colors.primary.base,
                                thumbColor: colors.primary.base,
                                thumbInnerColor: colors.surface,
                                labelColor: colors.text,
                                trackHeight: trackHeight,
                                thumbRadius: thumbRadius,
                                totalHeight: totalHeight,
                                showLabels: widget.showLabels,
                                showTicks: widget.showTicks,
                                enabled: widget.enabled,
                              ),
                            ),
                      ),
                      for (
                        var thumb = 0;
                        thumb < (widget.secondaryValue == null ? 1 : 2);
                        thumb++
                      )
                        _semanticThumb(context, thumb, width, totalHeight),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    if (widget.label != null) {
      slider = OiInputFrame(label: widget.label, child: slider);
    }

    return slider;
  }
}

// ---------------------------------------------------------------------------
// Painter
// ---------------------------------------------------------------------------

class _OiSliderPainter extends CustomPainter {
  const _OiSliderPainter({
    required this.value,
    required this.min,
    required this.max,
    required this.trackColor,
    required this.activeColor,
    required this.thumbColor,
    required this.thumbInnerColor,
    required this.labelColor,
    required this.trackHeight,
    required this.thumbRadius,
    required this.totalHeight,
    required this.showLabels,
    required this.showTicks,
    required this.enabled,
    required this.labelValue,
    this.secondaryValue,
    this.labelSecondaryValue,
    this.divisions,
  });

  final double value;
  final double? secondaryValue;
  final double labelValue;
  final double? labelSecondaryValue;
  final double min;
  final double max;
  final int? divisions;
  final Color trackColor;
  final Color activeColor;
  final Color thumbColor;
  final Color thumbInnerColor;
  final Color labelColor;
  final double trackHeight;
  final double thumbRadius;
  final double totalHeight;
  final bool showLabels;
  final bool showTicks;
  final bool enabled;

  double _ratio(double v) => (v - min) / (max - min);

  @override
  void paint(Canvas canvas, Size size) {
    final trackY = totalHeight / 2;
    final trackStart = thumbRadius;
    final trackEnd = size.width - thumbRadius;
    final trackWidth = trackEnd - trackStart;

    final primaryX = trackStart + _ratio(value) * trackWidth;
    final secondaryX = secondaryValue != null
        ? trackStart + _ratio(secondaryValue!) * trackWidth
        : null;

    final trackPaint = Paint()
      ..color = enabled ? trackColor : trackColor.withValues(alpha: 0.4)
      ..strokeWidth = trackHeight
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final activePaint = Paint()
      ..color = enabled ? activeColor : activeColor.withValues(alpha: 0.4)
      ..strokeWidth = trackHeight
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Full track.
    canvas.drawLine(
      Offset(trackStart, trackY),
      Offset(trackEnd, trackY),
      trackPaint,
    );

    // Active portion.
    final activeStart = secondaryX != null ? primaryX : trackStart;
    final activeEnd = secondaryX ?? primaryX;
    if (activeEnd > activeStart) {
      canvas.drawLine(
        Offset(activeStart, trackY),
        Offset(activeEnd, trackY),
        activePaint,
      );
    }

    // Tick marks.
    if (showTicks && divisions != null && divisions! > 0) {
      final tickPaint = Paint()
        ..color = trackColor
        ..strokeWidth = 1.5;
      for (var i = 0; i <= divisions!; i++) {
        final x = trackStart + (i / divisions!) * trackWidth;
        canvas.drawLine(
          Offset(x, trackY - 5),
          Offset(x, trackY + 5),
          tickPaint,
        );
      }
    }

    // Thumb(s).
    _drawThumb(canvas, primaryX, trackY, labelValue);
    if (secondaryX != null) {
      _drawThumb(canvas, secondaryX, trackY, labelSecondaryValue!);
    }
  }

  void _drawThumb(Canvas canvas, double x, double y, double v) {
    canvas
      ..drawCircle(
        Offset(x, y),
        thumbRadius,
        Paint()
          ..color = enabled ? thumbColor : thumbColor.withValues(alpha: 0.4),
      )
      ..drawCircle(
        Offset(x, y),
        thumbRadius - 2,
        Paint()..color = thumbInnerColor,
      );

    if (showLabels) {
      final label = v == v.truncateToDouble()
          ? v.toStringAsFixed(0)
          : v.toStringAsFixed(1);
      final tp = TextPainter(
        text: TextSpan(
          text: label,
          style: TextStyle(fontSize: 10, color: labelColor),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(
        canvas,
        Offset(x - tp.width / 2, y - thumbRadius - tp.height - 2),
      );
    }
  }

  @override
  bool shouldRepaint(_OiSliderPainter old) =>
      old.value != value ||
      old.secondaryValue != secondaryValue ||
      old.min != min ||
      old.max != max ||
      old.divisions != divisions ||
      old.activeColor != activeColor ||
      old.enabled != enabled;
}
