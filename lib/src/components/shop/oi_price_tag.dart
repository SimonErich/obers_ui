import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/oi_responsive.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/display/oi_label.dart';
import 'package:obers_ui/src/primitives/layout/oi_row.dart';

/// The size of an [OiPriceTag].
///
/// {@category Components}
enum OiPriceTagSize {
  /// Compact price display.
  small,

  /// Standard price display.
  medium,

  /// Prominent price display.
  large,
}

/// Currency placement relative to the amount.
enum _CurrencyPosition { before, after }

/// Known currency symbols and their placement conventions.
///
/// Coverage: REQ-0027
const Map<String, ({String symbol, _CurrencyPosition position})> _currencyMap =
    {
      'USD': (symbol: r'$', position: _CurrencyPosition.before),
      'CAD': (symbol: r'CA$', position: _CurrencyPosition.before),
      'GBP': (symbol: '£', position: _CurrencyPosition.before),
      'EUR': (symbol: '€', position: _CurrencyPosition.after),
      'JPY': (symbol: '¥', position: _CurrencyPosition.before),
      'CNY': (symbol: '¥', position: _CurrencyPosition.before),
      'KRW': (symbol: '₩', position: _CurrencyPosition.before),
      'INR': (symbol: '₹', position: _CurrencyPosition.before),
      'CHF': (symbol: 'CHF', position: _CurrencyPosition.before),
      'AUD': (symbol: r'A$', position: _CurrencyPosition.before),
      'BRL': (symbol: r'R$', position: _CurrencyPosition.before),
      'SEK': (symbol: 'kr', position: _CurrencyPosition.after),
      'NOK': (symbol: 'kr', position: _CurrencyPosition.after),
      'DKK': (symbol: 'kr', position: _CurrencyPosition.after),
      'PLN': (symbol: 'zł', position: _CurrencyPosition.after),
      'CZK': (symbol: 'Kč', position: _CurrencyPosition.after),
      'TRY': (symbol: '₺', position: _CurrencyPosition.before),
      'MXN': (symbol: r'MX$', position: _CurrencyPosition.before),
    };

/// A formatted price display with optional compare-at (strikethrough) price
/// and currency symbol.
///
/// Coverage: REQ-0027
///
/// When [compareAtPrice] is provided and greater than [price], shows the
/// compare-at price with strikethrough in a muted color and the current
/// price in bold primary. Zero price shows "Free". Negative prices are
/// shown in the success color. Currency symbol placement follows locale
/// conventions (€ after in DE, $ before in US).
///
/// Composes [OiRow] for layout and [OiLabel] for colour-coded price display.
///
/// {@category Components}
class OiPriceTag extends StatelessWidget {
  /// Creates an [OiPriceTag].
  const OiPriceTag({
    required this.price,
    required this.label,
    this.compareAtPrice,
    this.currencyCode,
    this.currencySymbol,
    this.decimalPlaces = 2,
    this.size = OiPriceTagSize.medium,
    super.key,
  });

  /// The current price to display.
  final double price;

  /// Accessibility label announced by screen readers.
  final String label;

  /// Original price before discount. Shown with strikethrough when > [price].
  final double? compareAtPrice;

  /// ISO 4217 currency code (e.g. 'USD', 'EUR'). Defaults to 'USD'.
  final String? currencyCode;

  /// Explicit currency symbol override. Takes priority over [currencyCode].
  final String? currencySymbol;

  /// Number of decimal places to show. Defaults to 2.
  final int decimalPlaces;

  /// The size variant.
  final OiPriceTagSize size;

  /// Whether the price is zero.
  bool get _isFree => price == 0;

  /// Whether a valid compare-at price is present.
  bool get _isOnSale => compareAtPrice != null && compareAtPrice! > price;

  String _formatPrice(double value, int decimals) {
    return value.toStringAsFixed(decimals);
  }

  ({String symbol, _CurrencyPosition position}) _resolveCurrency() {
    if (currencySymbol != null) {
      final code = currencyCode ?? 'USD';
      final known = _currencyMap[code.toUpperCase()];
      return (
        symbol: currencySymbol!,
        position: known?.position ?? _CurrencyPosition.before,
      );
    }
    final code = currencyCode ?? 'USD';
    final known = _currencyMap[code.toUpperCase()];
    if (known != null) return known;
    return (symbol: code, position: _CurrencyPosition.after);
  }

  String _buildPriceText(double value) {
    final currency = _resolveCurrency();
    final isNegative = value < 0;
    final formatted = _formatPrice(isNegative ? -value : value, decimalPlaces);
    final prefix = isNegative ? '-' : '';
    return currency.position == _CurrencyPosition.before
        ? '$prefix${currency.symbol}$formatted'
        : '$prefix$formatted ${currency.symbol}';
  }

  Color _resolvePriceColor(BuildContext context) {
    final colors = context.colors;
    if (price < 0) return colors.success.base;
    if (_isOnSale) return colors.primary.base;
    return colors.text;
  }

  Widget _buildFormattedPrice(BuildContext context) {
    if (_isFree) {
      final freeColor = context.colors.success.base;
      switch (size) {
        case OiPriceTagSize.small:
          return OiLabel.tiny('Free', color: freeColor);
        case OiPriceTagSize.medium:
          return OiLabel.smallStrong('Free', color: freeColor);
        case OiPriceTagSize.large:
          return OiLabel.h4('Free', color: freeColor);
      }
    }

    final priceColor = _resolvePriceColor(context);
    final text = _buildPriceText(price);

    switch (size) {
      case OiPriceTagSize.small:
        return OiLabel.tiny(text, color: priceColor);
      case OiPriceTagSize.medium:
        return _isOnSale
            ? OiLabel.smallStrong(text, color: priceColor)
            : OiLabel.small(text, color: priceColor);
      case OiPriceTagSize.large:
        return OiLabel.h4(text, color: priceColor);
    }
  }

  Widget _buildCompareAtPrice(BuildContext context) {
    final colors = context.colors;
    final text = _buildPriceText(compareAtPrice!);

    switch (size) {
      case OiPriceTagSize.small:
      case OiPriceTagSize.medium:
        return OiLabel.tiny(
          text,
          color: colors.textMuted,
          decoration: TextDecoration.lineThrough,
          decorationColor: colors.textMuted,
        );
      case OiPriceTagSize.large:
        return OiLabel.small(
          text,
          color: colors.textMuted,
          decoration: TextDecoration.lineThrough,
          decorationColor: colors.textMuted,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final breakpoint = context.breakpoint;

    Widget content;
    if (_isOnSale) {
      content = OiRow(
        breakpoint: breakpoint,
        gap: OiResponsive(context.spacing.xs),
        children: [
          _buildCompareAtPrice(context),
          _buildFormattedPrice(context),
        ],
      );
    } else {
      content = _buildFormattedPrice(context);
    }

    return Semantics(
      label: label,
      child: ExcludeSemantics(child: content),
    );
  }
}
