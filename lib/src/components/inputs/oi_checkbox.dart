import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';

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
class OiCheckbox extends StatefulWidget {
  /// Creates an [OiCheckbox].
  const OiCheckbox({
    required this.value,
    this.onChanged,
    this.label,
    this.labelWidget,
    this.semanticLabel,
    this.labelStyle,
    this.enabled = true,
    super.key,
  }) : assert(
         labelWidget == null || semanticLabel != null,
         'Rich checkbox labels require semanticLabel for an accessible name.',
       );

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

  /// Rich noninteractive label content. Provide [semanticLabel] for its text.
  final Widget? labelWidget;

  /// Accessible name when the checkbox has no visible label, such as a table.
  final String? semanticLabel;

  /// Optional style override for the label text.
  final TextStyle? labelStyle;

  /// Whether the checkbox responds to taps.
  final bool enabled;

  @override
  State<OiCheckbox> createState() => _OiCheckboxState();
}

class _OiCheckboxState extends State<OiCheckbox> {
  bool _hovered = false;
  bool _focused = false;
  bool _showFocus = false;
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (!widget.enabled || widget.onChanged == null) return;
    _focusNode.requestFocus();
    if (widget.value ?? false) {
      widget.onChanged!(false);
    } else {
      widget.onChanged!(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final themeData = context.theme;
    final size = themeData.components.checkbox?.size ?? 18.0;
    final borderRadius =
        themeData.components.checkbox?.borderRadius ?? BorderRadius.circular(4);

    final isChecked = widget.value ?? false;
    final isIndeterminate = widget.value == null;
    final cht = themeData.components.checkbox;
    final isActive = widget.enabled && widget.onChanged != null;

    final checkedColor = !isActive && cht?.disabledColor != null
        ? cht!.disabledColor!
        : cht?.checkedColor ?? colors.primary.base;
    final Color fillColor;
    final Color borderColor;

    if (isChecked || isIndeterminate) {
      fillColor = checkedColor;
      borderColor = checkedColor;
    } else if (_hovered && isActive) {
      fillColor = colors.primary.base.withValues(alpha: 0.1);
      borderColor = colors.primary.base;
    } else {
      fillColor = colors.surface;
      borderColor = cht?.uncheckedBorderColor ?? colors.border;
    }

    Widget box = CustomPaint(
      size: Size(size, size),
      painter: _OiCheckboxPainter(
        state: widget.value,
        fillColor: fillColor,
        borderColor: borderColor,
        checkColor: cht?.checkmarkColor ?? colors.textOnPrimary,
        borderRadius: borderRadius,
        borderWidth: cht?.borderWidth ?? 1.5,
      ),
    );

    if (_showFocus && isActive) {
      box = DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          boxShadow: [BoxShadow(color: colors.borderFocus, spreadRadius: 2)],
        ),
        child: box,
      );
    }

    if (widget.label != null || widget.labelWidget != null) {
      box = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          box,
          const SizedBox(width: 8),
          Flexible(
            child:
                widget.labelWidget ??
                Text(
                  widget.label!,
                  style:
                      widget.labelStyle ??
                      TextStyle(fontSize: 14, color: colors.text),
                ),
          ),
        ],
      );
    }

    return Semantics(
      label: widget.semanticLabel ?? widget.label,
      checked: widget.value == true,
      mixed: widget.value == null,
      enabled: isActive,
      focusable: isActive,
      focused: _focused,
      onTap: isActive ? _handleTap : null,
      onFocus: isActive ? _focusNode.requestFocus : null,
      child: FocusableActionDetector(
        enabled: isActive,
        focusNode: _focusNode,
        includeFocusSemantics: false,
        onFocusChange: (value) => setState(() => _focused = value),
        onShowFocusHighlight: (value) => setState(() => _showFocus = value),
        shortcuts: const {
          SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
          SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
        },
        actions: {
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              _handleTap();
              return null;
            },
          ),
        },
        child: MouseRegion(
          cursor: isActive
              ? SystemMouseCursors.click
              : SystemMouseCursors.basic,
          onEnter: (_) => setState(() => _hovered = true),
          onExit: (_) => setState(() => _hovered = false),
          child: GestureDetector(
            onTap: isActive ? _handleTap : null,
            excludeFromSemantics: true,
            behavior: HitTestBehavior.opaque,
            child: ExcludeSemantics(child: box),
          ),
        ),
      ),
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
    required this.borderWidth,
  });

  final bool? state;
  final Color fillColor;
  final Color borderColor;
  final Color checkColor;
  final BorderRadius borderRadius;
  final double borderWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = borderRadius.toRRect(Offset.zero & size);

    canvas
      // Fill.
      ..drawRRect(rrect, Paint()..color = fillColor)
      // Border.
      ..drawRRect(
        rrect.deflate(borderWidth / 2),
        Paint()
          ..color = borderColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = borderWidth,
      );

    final paint = Paint()
      ..color = checkColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    if (state ?? false) {
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
      old.borderRadius != borderRadius ||
      old.borderWidth != borderWidth;
}
