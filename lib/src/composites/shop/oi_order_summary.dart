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

/// The texts of an [OiOrderSummary], in English by default; pass
/// translations to localize the summary.
///
/// {@category Composites}
class OiOrderSummaryLabels {
  /// Creates an [OiOrderSummaryLabels].
  const OiOrderSummaryLabels({
    this.title = 'Order Summary',
    this.items = englishItems,
    this.totals = const OiOrderTotalsLabels(),
    this.itemRow = const OiCartItemRowLabels(),
  });

  /// "Items (3)": the default [items].
  static String englishItems(int count) => 'Items ($count)';

  /// Heading of the summary.
  final String title;

  /// Title of the collapsible item list, by the number of items.
  final String Function(int count) items;

  /// The labels of the totals rows.
  final OiOrderTotalsLabels totals;

  /// The texts of each item row.
  final OiCartItemRowLabels itemRow;
}

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
    this.labels = const OiOrderSummaryLabels(),
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

  /// The summary's texts; pass translations to localize it.
  final OiOrderSummaryLabels labels;

  Widget _buildItemList(BuildContext context) {
    final breakpoint = context.breakpoint;
    final sp = context.spacing;

    return OiAccordion(
      allowMultiple: true,
      sections: [
        OiAccordionSection(
          title: labels.items(items!.length),
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
                  labels: labels.itemRow,
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryLines(BuildContext context) {
    final breakpoint = context.breakpoint;
    final sp = context.spacing;

    return OiColumn(
      breakpoint: breakpoint,
      gap: OiResponsive(sp.sm),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OiOrderSummaryLine(
          label: labels.totals.subtotal,
          amount: summary.subtotal,
          currencyCode: currencyCode,
        ),
        if (summary.discount != null)
          OiOrderSummaryLine(
            label: summary.discountLabel ?? labels.totals.discount,
            amount: summary.discount!,
            currencyCode: currencyCode,
            negative: true,
          ),
        if (summary.shipping != null)
          OiOrderSummaryLine(
            label: summary.shippingLabel ?? labels.totals.shipping,
            amount: summary.shipping!,
            currencyCode: currencyCode,
          ),
        if (summary.tax != null)
          OiOrderSummaryLine(
            label: summary.taxLabel ?? labels.totals.tax,
            amount: summary.tax!,
            currencyCode: currencyCode,
          ),
        const OiDivider(),
        OiOrderSummaryLine(
          label: labels.totals.total,
          amount: summary.total,
          currencyCode: currencyCode,
          bold: true,
        ),
      ],
    );
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
            OiLabel.bodyStrong(labels.title),
            if (hasItems) ...[_buildItemList(context), const OiDivider()],
            _buildSummaryLines(context),
          ],
        ),
      ),
    );
  }
}
