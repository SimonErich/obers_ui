import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/display/oi_card.dart';
import 'package:obers_ui/src/components/navigation/oi_accordion.dart';
import 'package:obers_ui/src/components/shop/oi_cart_item_row.dart';
import 'package:obers_ui/src/components/shop/oi_order_summary_line.dart';
import 'package:obers_ui/src/foundation/oi_responsive.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/models/oi_cart_item.dart';
import 'package:obers_ui/src/models/oi_cart_summary.dart';
import 'package:obers_ui/src/primitives/display/oi_divider.dart';
import 'package:obers_ui/src/primitives/display/oi_label.dart';
import 'package:obers_ui/src/primitives/layout/oi_column.dart';

/// A complete order summary card showing all line items (subtotal, discount,
/// shipping, tax, total) with an optional expandable item list.
///
/// Coverage: REQ-0039
///
/// The item list is rendered inside an [OiAccordion] for expand/collapse.
/// Individual items are shown as read-only [OiCartItemRow] widgets.
///
/// Composes [OiCard], [OiColumn], [OiOrderSummaryLine], [OiDivider],
/// [OiAccordion], [OiCartItemRow], [OiLabel].
///
/// {@category Composites}
class OiOrderSummary extends StatelessWidget {
  /// Creates an [OiOrderSummary].
  const OiOrderSummary({
    required this.summary,
    required this.label,
    this.items,
    this.showItems = true,
    this.expandedByDefault = false,
    this.currencyCode = 'EUR',
    super.key,
  });

  /// The cart summary with subtotal, discount, shipping, tax, and total.
  final OiCartSummary summary;

  /// Accessibility label announced by screen readers.
  final String label;

  /// Optional list of cart items to show in an expandable accordion.
  final List<OiCartItem>? items;

  /// Whether to show the expandable item list when [items] is provided.
  ///
  /// Defaults to `true`.
  final bool showItems;

  /// Whether the item list accordion starts expanded.
  ///
  /// Defaults to `false`.
  final bool expandedByDefault;

  /// ISO 4217 currency code. Defaults to `'EUR'`.
  final String currencyCode;

  Widget _buildItemList(BuildContext context) {
    final breakpoint = context.breakpoint;
    final sp = context.spacing;

    return OiAccordion(
      allowMultiple: true,
      sections: [
        OiAccordionSection(
          title: 'Items (${items!.length})',
          initiallyExpanded: expandedByDefault,
          content: OiColumn(
            breakpoint: breakpoint,
            gap: OiResponsive(sp.xs),
            children: [
              for (final item in items!)
                OiCartItemRow(
                  item: item,
                  label: '${item.name} × ${item.quantity}',
                  editable: false,
                  currencyCode: currencyCode,
                ),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildSummaryLines(BuildContext context) {
    final sp = context.spacing;

    return [
      OiOrderSummaryLine(
        label: 'Subtotal',
        amount: summary.subtotal,
        currencyCode: currencyCode,
      ),
      if (summary.discount != null)
        OiOrderSummaryLine(
          label: summary.discountLabel ?? 'Discount',
          amount: summary.discount!,
          currencyCode: currencyCode,
          negative: true,
        ),
      if (summary.shipping != null)
        OiOrderSummaryLine(
          label: summary.shippingLabel ?? 'Shipping',
          amount: summary.shipping!,
          currencyCode: currencyCode,
        ),
      if (summary.tax != null)
        OiOrderSummaryLine(
          label: summary.taxLabel ?? 'Tax',
          amount: summary.tax!,
          currencyCode: currencyCode,
        ),
      Padding(
        padding: EdgeInsets.symmetric(vertical: sp.xs),
        child: const OiDivider(),
      ),
      OiOrderSummaryLine(
        label: 'Total',
        amount: summary.total,
        currencyCode: currencyCode,
        bold: true,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final breakpoint = context.breakpoint;
    final sp = context.spacing;
    final hasItems = showItems && items != null && items!.isNotEmpty;

    return Semantics(
      label: label,
      child: OiCard(
        child: OiColumn(
          breakpoint: breakpoint,
          gap: OiResponsive(sp.sm),
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const OiLabel.bodyStrong('Order Summary'),
            if (hasItems) ...[_buildItemList(context), const OiDivider()],
            ..._buildSummaryLines(context),
          ],
        ),
      ),
    );
  }
}
