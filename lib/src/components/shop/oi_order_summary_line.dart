import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/shop/oi_price_tag.dart';
import 'package:obers_ui/src/foundation/oi_responsive.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/animation/oi_shimmer.dart';
import 'package:obers_ui/src/primitives/display/oi_label.dart';
import 'package:obers_ui/src/primitives/layout/oi_column.dart';
import 'package:obers_ui/src/primitives/layout/oi_row.dart';

/// A single summary row showing a label on the left and an amount on the right.
///
/// Coverage: REQ-0031
///
/// Used for subtotal, discount, shipping, tax, and total lines in checkout UIs.
/// Supports bold styling for total rows, green negative styling for discounts,
/// shimmer loading state for shipping calculation, and optional subtitles.
///
/// Composes [OiRow], [OiLabel], [OiPriceTag], [OiShimmer].
///
/// {@category Components}
class OiOrderSummaryLine extends StatelessWidget {
  /// Creates an [OiOrderSummaryLine].
  const OiOrderSummaryLine({
    required this.label,
    required this.amount,
    this.currencyCode = 'EUR',
    this.bold = false,
    this.negative = false,
    this.loading = false,
    this.subtitle,
    super.key,
  });

  /// The label for this line (e.g. 'Subtotal', 'Shipping', 'Total').
  final String label;

  /// The monetary amount.
  final double amount;

  /// ISO 4217 currency code. Defaults to `'EUR'`.
  final String currencyCode;

  /// Whether to display in bold (typically for the total row).
  ///
  /// Defaults to `false`.
  final bool bold;

  /// Whether the amount is a discount (shown in green with minus prefix).
  ///
  /// Defaults to `false`.
  final bool negative;

  /// Whether to show a shimmer placeholder instead of the amount.
  ///
  /// Defaults to `false`.
  final bool loading;

  /// Optional subtitle below the label (e.g. coupon code 'SUMMER20').
  final String? subtitle;

  Widget _buildLabel(BuildContext context) {
    final breakpoint = context.breakpoint;
    final sp = context.spacing;
    final colors = context.colors;

    final Widget labelWidget;
    if (bold) {
      labelWidget = OiLabel.h4(label);
    } else if (negative) {
      labelWidget = OiLabel.small(label);
    } else {
      labelWidget = OiLabel.body(label);
    }

    if (subtitle == null) return labelWidget;

    return OiColumn(
      breakpoint: breakpoint,
      gap: OiResponsive(sp.xs / 2),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        labelWidget,
        Text(
          subtitle!,
          style: TextStyle(
            fontSize: 12,
            color: colors.primary.base,
          ),
        ),
      ],
    );
  }

  Widget _buildAmount(BuildContext context) {
    if (loading) {
      return OiShimmer(
        child: Container(
          width: 60,
          height: 16,
          color: context.colors.surfaceSubtle,
        ),
      );
    }

    final displayAmount = negative ? -amount.abs() : amount;

    return OiPriceTag(
      price: displayAmount,
      label: '$label amount',
      currencyCode: currencyCode,
      size: bold ? OiPriceTagSize.large : OiPriceTagSize.medium,
    );
  }

  @override
  Widget build(BuildContext context) {
    final breakpoint = context.breakpoint;

    return Semantics(
      label: '$label: ${loading ? 'loading' : amount.toStringAsFixed(2)}',
      child: ExcludeSemantics(
        child: OiRow(
          breakpoint: breakpoint,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(child: _buildLabel(context)),
            _buildAmount(context),
          ],
        ),
      ),
    );
  }
}
