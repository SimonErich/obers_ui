import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/oi_responsive.dart';
import 'package:obers_ui/src/foundation/theme/oi_decoration_theme.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/models/oi_payment_method.dart';
import 'package:obers_ui/src/primitives/display/oi_label.dart';
import 'package:obers_ui/src/primitives/display/oi_surface.dart';
import 'package:obers_ui/src/primitives/interaction/oi_tappable.dart';
import 'package:obers_ui/src/primitives/layout/oi_column.dart';
import 'package:obers_ui/src/primitives/layout/oi_row.dart';

// Material Icons codepoints.
const IconData _kPaymentIcon = IconData(0xe8a1, fontFamily: 'MaterialIcons');

/// A selectable row that represents a single payment method.
///
/// Coverage: REQ-0071
///
/// Displays the payment method label, optional description and icon, and a
/// radio-style selection indicator. A border highlight distinguishes the
/// [selected] state. Tapping fires [onSelect].
///
/// {@category Components}
class OiPaymentOption extends StatelessWidget {
  /// Creates an [OiPaymentOption].
  const OiPaymentOption({
    required this.method,
    required this.label,
    this.selected = false,
    this.onSelect,
    super.key,
  });

  /// The payment method data to display.
  final OiPaymentMethod method;

  /// Accessibility label announced by screen readers.
  final String label;

  /// Whether this option is currently selected.
  final bool selected;

  /// Called when the user taps this option.
  final ValueChanged<OiPaymentMethod>? onSelect;

  IconData _resolveIcon() {
    return method.icon ?? _kPaymentIcon;
  }

  Widget _buildRadioIndicator(BuildContext context) {
    final colors = context.colors;
    const outerSize = 18.0;
    const innerSize = 8.0;

    return SizedBox(
      width: outerSize,
      height: outerSize,
      child: CustomPaint(
        painter: _RadioPainter(
          selected: selected,
          outerColor: selected ? colors.primary.base : colors.border,
          innerColor: colors.primary.base,
          outerSize: outerSize,
          innerSize: innerSize,
        ),
      ),
    );
  }

  Widget _buildIcon(BuildContext context) {
    final colors = context.colors;
    final icon = _resolveIcon();
    return Icon(icon, size: 20, color: colors.textMuted);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final sp = context.spacing;
    final breakpoint = context.breakpoint;

    final borderColor = selected ? colors.primary.base : colors.borderSubtle;

    Widget content = OiRow(
      breakpoint: breakpoint,
      gap: OiResponsive(sp.sm),
      children: [
        _buildRadioIndicator(context),
        _buildIcon(context),
        Expanded(
          child: OiColumn(
            breakpoint: breakpoint,
            gap: const OiResponsive(2),
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              OiLabel.bodyStrong(method.label),
              if (method.description != null)
                OiLabel.small(method.description!, color: colors.textMuted),
            ],
          ),
        ),
        if (method.isDefault)
          OiLabel.tiny('Default', color: colors.primary.base),
      ],
    );

    content = OiSurface(
      borderRadius: context.radius.sm,
      border: OiBorderStyle.solid(borderColor, selected ? 2 : 1),
      color: selected ? colors.primary.base.withValues(alpha: 0.05) : null,
      padding: EdgeInsets.all(sp.md),
      child: content,
    );

    if (onSelect != null) {
      content = OiTappable(onTap: () => onSelect!(method), child: content);
    }

    return Semantics(
      label: label,
      selected: selected,
      child: ExcludeSemantics(child: content),
    );
  }
}

class _RadioPainter extends CustomPainter {
  _RadioPainter({
    required this.selected,
    required this.outerColor,
    required this.innerColor,
    required this.outerSize,
    required this.innerSize,
  });

  final bool selected;
  final Color outerColor;
  final Color innerColor;
  final double outerSize;
  final double innerSize;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = outerSize / 2;
    final innerRadius = innerSize / 2;

    canvas.drawCircle(
      center,
      outerRadius,
      Paint()
        ..color = outerColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    if (selected) {
      canvas.drawCircle(
        center,
        innerRadius,
        Paint()
          ..color = innerColor
          ..style = PaintingStyle.fill,
      );
    }
  }

  @override
  bool shouldRepaint(_RadioPainter oldDelegate) =>
      selected != oldDelegate.selected ||
      outerColor != oldDelegate.outerColor ||
      innerColor != oldDelegate.innerColor;
}
