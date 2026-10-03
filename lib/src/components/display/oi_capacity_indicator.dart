import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/theme/oi_text_theme.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/display/oi_icon.dart';
import 'package:obers_ui/src/primitives/display/oi_label.dart';

/// A labeled capacity ratio with optional warning and striped remaining space.
///
/// Values above capacity stay visible in the label while the fill is clamped.
/// The component owns no data or timers and can be reused for stock, seats,
/// delivery capacity, storage and other bounded quantities.
class OiCapacityIndicator extends StatelessWidget {
  /// Creates a controlled capacity display.
  const OiCapacityIndicator({
    required this.value,
    required this.max,
    required this.label,
    this.subtitle,
    this.warningThreshold = .9,
    this.warningText,
    this.color,
    this.warningColor,
    this.showValue = true,
    this.showLabel = true,
    this.caption,
    this.valueLabel,
    this.stripedRemainder = true,
    this.height = 4,
    this.gap,
    this.labelStyle,
    this.valueStyle,
    this.horizontal = false,
    this.trackWidth = 110,
    super.key,
  }) : assert(
         value >= 0 && value < double.infinity,
         'value must be finite and nonnegative.',
       ),
       assert(
         max >= 0 && max < double.infinity,
         'max must be finite and nonnegative.',
       ),
       assert(
         warningThreshold >= 0 && warningThreshold <= 1,
         'warningThreshold must be between zero and one.',
       ),
       assert(height > 0, 'height must be positive.');

  /// Used capacity; values over [max] represent overbooking.
  final num value;

  /// Total capacity; zero renders an empty track.
  final num max;

  /// Short accessible description of the measured resource.
  final String label;

  /// Supporting context below the label.
  final String? subtitle;

  /// Utilization ratio at which warning colors and text appear.
  final double warningThreshold;

  /// Optional explicit warning, displayed only at or above the threshold.
  final String? warningText;

  /// Normal fill color, defaulting to the theme's primary color.
  final Color? color;

  /// Warning fill and caption color, defaulting to the theme's warning color.
  final Color? warningColor;

  /// Whether to display the textual ratio.
  final bool showValue;

  /// Whether to display the heading. The accessible label remains available.
  final bool showLabel;

  /// Optional supporting explanation below the capacity track.
  final String? caption;

  /// Optional localized ratio replacing the default "value / max" text.
  final String? valueLabel;

  /// Hatches the unused part of the track.
  final bool stripedRemainder;

  /// Track height in logical pixels.
  final double height;

  /// Optional spacing around the bar; omitted follows the active theme.
  final double? gap;

  /// Optional supporting-label typography for dense summaries.
  final TextStyle? labelStyle;

  /// Optional ratio typography independent of the supporting label.
  final TextStyle? valueStyle;

  /// Places the track and ratio beside the label instead of below it.
  final bool horizontal;

  /// Track width in the horizontal presentation.
  final double trackWidth;

  @override
  Widget build(BuildContext context) {
    final theme = context.components.capacity;
    final valueStyle =
        this.valueStyle ??
        labelStyle ??
        theme?.valueStyle ??
        context.textTheme.caption;
    final ratioWidth = horizontal ? theme?.valueWidth : null;
    final ratio = max <= 0 ? 0.0 : (value / max).clamp(0.0, 1.0);
    final warning = max > 0 && value / max >= warningThreshold;
    final activeColor = warning
        ? warningColor ?? context.colors.warning.base
        : color ?? context.colors.primary.base;
    final text = valueLabel ?? '${_number(value)} / ${_number(max)}';
    final track = SizedBox(
      width: horizontal ? trackWidth : null,
      height: height,
      child: CustomPaint(
        painter: _CapacityPainter(
          ratio: ratio,
          color: activeColor,
          trackColor: context.colors.surfaceSubtle,
          stripeColor: theme?.stripeColor ?? context.colors.border,
          radius: theme?.trackRadius,
          striped: stripedRemainder,
          direction: Directionality.of(context),
        ),
      ),
    );
    final heading = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OiLabel.variant(
          label,
          variant: OiLabelVariant.bodyStrong,
          style: labelStyle ?? theme?.labelStyle,
        ),
        if (subtitle != null) OiLabel.caption(subtitle!),
      ],
    );
    return Semantics(
      label: label,
      value: text,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (showLabel || showValue || horizontal)
            Row(
              children: [
                Expanded(child: showLabel ? heading : const SizedBox.shrink()),
                if (horizontal) ...[
                  SizedBox(width: theme?.columnGap ?? context.spacing.md),
                  track,
                ],
                if (showValue) ...[
                  SizedBox(width: theme?.columnGap ?? context.spacing.sm),
                  SizedBox(
                    width: ratioWidth,
                    child: valueLabel != null
                        ? Text(
                            valueLabel!,
                            style: valueStyle,
                            textAlign: TextAlign.end,
                          )
                        : Text.rich(
                            TextSpan(
                              style: valueStyle.copyWith(
                                color: context.colors.textMuted,
                              ),
                              children: [
                                TextSpan(
                                  text: _number(value),
                                  style: valueStyle.copyWith(
                                    color: context.colors.text,
                                    fontWeight: FontWeight.w500,
                                    fontVariations: const [],
                                  ),
                                ),
                                TextSpan(text: ' / ${_number(max)}'),
                              ],
                            ),
                            textAlign: TextAlign.end,
                          ),
                  ),
                ],
              ],
            ),
          if (!horizontal) ...[
            if (showLabel || showValue)
              SizedBox(height: gap ?? context.spacing.sm),
            track,
          ],
          if (caption != null)
            Padding(
              padding: EdgeInsets.only(top: gap ?? context.spacing.xs),
              child: OiLabel.caption(caption!),
            ),
          if (warning && warningText != null)
            Padding(
              padding: EdgeInsets.only(
                top: gap ?? theme?.warningGap ?? context.spacing.xs,
              ),
              child: Row(
                children: [
                  if (horizontal && theme?.alignWarningWithTrack == true)
                    const Spacer(),
                  SizedBox(
                    width: horizontal && theme?.alignWarningWithTrack == true
                        ? trackWidth +
                              (theme?.columnGap ?? context.spacing.sm) +
                              (ratioWidth ?? 48)
                        : null,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (theme?.warningIcon case final icon?) ...[
                          OiIcon.raw(
                            icon,
                            size: 16,
                            color: context.colors.warning.base,
                          ),
                          const SizedBox(width: 6),
                        ],
                        Flexible(
                          child: OiLabel.caption(
                            warningText!,
                            color: context.colors.warning.base,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  static String _number(num number) => number == number.roundToDouble()
      ? number.toInt().toString()
      : number.toString();
}

class _CapacityPainter extends CustomPainter {
  const _CapacityPainter({
    required this.ratio,
    required this.color,
    required this.trackColor,
    required this.stripeColor,
    required this.striped,
    required this.direction,
    this.radius,
  });
  final double? radius;
  final double ratio;
  final Color color;
  final Color trackColor;
  final Color stripeColor;
  final bool striped;
  final TextDirection direction;

  @override
  void paint(Canvas canvas, Size size) {
    final bounds = Offset.zero & size;
    final shape = RRect.fromRectAndRadius(
      bounds,
      Radius.circular(radius ?? size.height / 2),
    );
    canvas
      ..save()
      ..clipRRect(shape)
      ..drawRect(bounds, Paint()..color = trackColor);
    if (striped) {
      final paint = Paint()
        ..color = stripeColor
        ..strokeWidth = 1;
      final spacing = math.max(4, size.height);
      for (var x = -size.height; x < size.width + size.height; x += spacing) {
        canvas.drawLine(
          Offset(x, size.height),
          Offset(x + size.height, 0),
          paint,
        );
      }
    }
    final filled = size.width * ratio;
    canvas
      ..drawRect(
        Rect.fromLTWH(
          direction == TextDirection.rtl ? size.width - filled : 0,
          0,
          filled,
          size.height,
        ),
        Paint()..color = color,
      )
      ..restore();
  }

  @override
  bool shouldRepaint(_CapacityPainter oldDelegate) =>
      radius != oldDelegate.radius ||
      ratio != oldDelegate.ratio ||
      color != oldDelegate.color ||
      trackColor != oldDelegate.trackColor ||
      stripeColor != oldDelegate.stripeColor ||
      striped != oldDelegate.striped ||
      direction != oldDelegate.direction;
}
