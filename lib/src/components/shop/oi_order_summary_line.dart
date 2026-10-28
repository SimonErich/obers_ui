import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/shop/oi_price_tag.dart';
import 'package:obers_ui/src/foundation/oi_responsive.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/animation/oi_shimmer.dart';
import 'package:obers_ui/src/primitives/display/oi_label.dart';
import 'package:obers_ui/src/primitives/layout/oi_column.dart';
import 'package:obers_ui/src/primitives/layout/oi_row.dart';

/// The labels of the totals rows ([OiOrderSummaryLine]s) that the cart and
/// order summaries show, in English by default.
///
/// The discount, shipping and tax rows prefer the labels of the
/// `OiCartSummary` they show, when it has them.
///
/// {@category Components}
class OiOrderTotalsLabels {
  /// Creates an [OiOrderTotalsLabels].
  const OiOrderTotalsLabels({
    this.subtotal = 'Subtotal',
    this.discount = 'Discount',
    this.shipping = 'Shipping',
    this.tax = 'Tax',
    this.total = 'Total',
    this.loading = 'loading',
  });

  /// Label of the subtotal row.
  final String subtotal;

  /// Label of the discount row.
  final String discount;

  /// Label of the shipping row.
  final String shipping;

  /// Label of the tax row.
  final String tax;

  /// Label of the total row.
  final String total;

  /// Read by screen readers in place of an amount that is loading.
  final String loading;
}

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
    this.loadingLabel = 'loading',
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

  /// Read by screen readers in place of the amount while [loading].
  final String loadingLabel;

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
      label: '$label: ${loading ? loadingLabel : amount.toStringAsFixed(2)}',
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
