import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/interaction/oi_tappable.dart';

/// A custom-painted checkbox with checked, unchecked, and indeterminate states.
///
/// The [value] is `bool?`: `false` = unchecked, `true` = checked,
/// `null` = indeterminate (shows a dash).
///
/// Tapping cycles: unchecked → checked, indeterminate → checked,
/// checked → unchecked. The [onChanged] callback receives `true` when the
/// new state is checked and `false` otherwise.
///
/// Colors and size are resolved from the nearest [OiTheme].
///
/// {@category Components}
class OiCheckbox extends StatelessWidget {
  /// Creates an [OiCheckbox].
  const OiCheckbox({
    required this.value,
    this.onChanged,
    this.label,
    this.enabled = true,
    super.key,
  });

  /// The current checkbox state.
  ///
  /// `true` = checked, `false` = unchecked, `null` = indeterminate.
  final bool? value;

  /// Called when the user taps the checkbox.
  ///
  /// Receives `true` when the new state is checked, `false` otherwise.
  final ValueChanged<bool>? onChanged;

  /// Optional label rendered to the right of the checkbox.
  final String? label;

  /// Whether the checkbox responds to taps.
  final bool enabled;

  void _handleTap() {
    if (onChanged == null) return;
    if (value == true) {
      onChanged!(false);
    } else {
      onChanged!(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final themeData = context.theme;
    final size = themeData.components.checkbox?.size ?? 18.0;
    final borderRadius =
        themeData.components.checkbox?.borderRadius ?? BorderRadius.circular(4);

    final isChecked = value == true;
    final isIndeterminate = value == null;

    final fillColor = (isChecked || isIndeterminate)
        ? colors.primary.base
        : colors.surface;
    final borderColor = (isChecked || isIndeterminate)
        ? colors.primary.base
        : colors.border;

    Widget box = CustomPaint(
      size: Size(size, size),
      painter: _OiCheckboxPainter(
        state: value,
        fillColor: fillColor,
        borderColor: borderColor,
        checkColor: colors.textOnPrimary,
        borderRadius: borderRadius,
      ),
    );

    if (label != null) {
      box = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          box,
          const SizedBox(width: 8),
          Text(label!, style: TextStyle(fontSize: 14, color: colors.text)),
        ],
      );
    }

    return OiTappable(
      onTap: enabled ? _handleTap : null,
      enabled: enabled,
      child: box,
    );
  }
}

// ---------------------------------------------------------------------------
// Painter
// ---------------------------------------------------------------------------

class _OiCheckboxPainter extends CustomPainter {
  const _OiCheckboxPainter({
    required this.state,
    required this.fillColor,
    required this.borderColor,
    required this.checkColor,
    required this.borderRadius,
  });

  final bool? state;
  final Color fillColor;
  final Color borderColor;
  final Color checkColor;
  final BorderRadius borderRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = borderRadius.toRRect(Offset.zero & size);

    canvas
      // Fill.
      ..drawRRect(rrect, Paint()..color = fillColor)
      // Border.
      ..drawRRect(
        rrect,
        Paint()
          ..color = borderColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );

    final paint = Paint()
      ..color = checkColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    if (state == true) {
      // Draw checkmark.
      final path = Path()
        ..moveTo(size.width * 0.2, size.height * 0.5)
        ..lineTo(size.width * 0.43, size.height * 0.72)
        ..lineTo(size.width * 0.8, size.height * 0.28);
      canvas.drawPath(path, paint);
    } else if (state == null) {
      // Draw dash (indeterminate).
      canvas.drawLine(
        Offset(size.width * 0.25, size.height * 0.5),
        Offset(size.width * 0.75, size.height * 0.5),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_OiCheckboxPainter old) =>
      old.state != state ||
      old.fillColor != fillColor ||
      old.borderColor != borderColor ||
      old.checkColor != checkColor ||
      old.borderRadius != borderRadius;
}
