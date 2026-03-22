import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/oi_responsive.dart';
import 'package:obers_ui/src/foundation/theme/oi_decoration_theme.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/models/oi_shipping_method.dart';
import 'package:obers_ui/src/primitives/display/oi_label.dart';
import 'package:obers_ui/src/primitives/display/oi_surface.dart';
import 'package:obers_ui/src/primitives/interaction/oi_tappable.dart';
import 'package:obers_ui/src/primitives/layout/oi_column.dart';
import 'package:obers_ui/src/primitives/layout/oi_row.dart';

/// Currency placement relative to the amount.
enum _CurrencyPosition { before, after }

/// Known currency symbols and their placement conventions.
const Map<String, ({String symbol, _CurrencyPosition position})> _currencyMap =
    {
      'USD': (symbol: r'$', position: _CurrencyPosition.before),
      'EUR': (symbol: '€', position: _CurrencyPosition.after),
      'GBP': (symbol: '£', position: _CurrencyPosition.before),
      'CHF': (symbol: 'CHF', position: _CurrencyPosition.before),
    };

/// A selectable row that represents a single shipping method.
///
/// Coverage: REQ-0071
///
/// Displays the shipping method label, optional description, estimated
/// delivery, and formatted price. A border highlight and filled radio
/// indicator distinguish the [selected] state. Tapping fires [onSelect].
///
/// Zero price is displayed as "Free".
///
/// {@category Components}
class OiShippingOption extends StatelessWidget {
  /// Creates an [OiShippingOption].
  const OiShippingOption({
    required this.method,
    required this.label,
    this.selected = false,
    this.onSelect,
    this.currencyCode = 'EUR',
    super.key,
  });

  /// The shipping method data to display.
  final OiShippingMethod method;

  /// Accessibility label announced by screen readers.
  final String label;

  /// Whether this option is currently selected.
  final bool selected;

  /// Called when the user taps this option.
  final ValueChanged<OiShippingMethod>? onSelect;

  /// ISO 4217 currency code for price formatting. Defaults to `'EUR'`.
  final String currencyCode;

  String _formatPrice(double price) {
    if (price == 0) return 'Free';
    final currency = _currencyMap[currencyCode.toUpperCase()];
    final formatted = price.toStringAsFixed(2);
    if (currency != null) {
      return currency.position == _CurrencyPosition.before
          ? '${currency.symbol}$formatted'
          : '$formatted ${currency.symbol}';
    }
    return '$formatted $currencyCode';
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

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final sp = context.spacing;
    final breakpoint = context.breakpoint;

    final borderColor = selected ? colors.primary.base : colors.borderSubtle;

    Widget content = OiRow(
      breakpoint: breakpoint,
      gap: OiResponsive(sp.sm),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRadioIndicator(context),
        Expanded(
          child: OiColumn(
            breakpoint: breakpoint,
            gap: const OiResponsive(2),
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              OiRow(
                breakpoint: breakpoint,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(child: OiLabel.bodyStrong(method.label)),
                  OiLabel.bodyStrong(_formatPrice(method.price)),
                ],
              ),
              if (method.description != null)
                OiLabel.small(method.description!, color: colors.textMuted),
              if (method.estimatedDelivery != null)
                OiLabel.tiny(
                  method.estimatedDelivery!,
                  color: colors.textMuted,
                ),
            ],
          ),
        ),
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

    // Outer circle.
    canvas.drawCircle(
      center,
      outerRadius,
      Paint()
        ..color = outerColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Inner filled circle when selected.
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
