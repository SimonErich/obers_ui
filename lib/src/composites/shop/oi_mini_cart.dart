import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/buttons/oi_button.dart';
import 'package:obers_ui/src/components/buttons/oi_icon_button.dart';
import 'package:obers_ui/src/components/display/oi_badge.dart';
import 'package:obers_ui/src/components/display/oi_popover.dart';
import 'package:obers_ui/src/components/overlays/oi_sheet.dart';
import 'package:obers_ui/src/components/shop/oi_cart_item_row.dart';
import 'package:obers_ui/src/components/shop/oi_price_tag.dart';
import 'package:obers_ui/src/foundation/oi_icons.dart';
import 'package:obers_ui/src/foundation/oi_responsive.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/models/oi_cart_item.dart';
import 'package:obers_ui/src/models/oi_cart_summary.dart';
import 'package:obers_ui/src/primitives/display/oi_divider.dart';
import 'package:obers_ui/src/primitives/display/oi_label.dart';
import 'package:obers_ui/src/primitives/layout/oi_column.dart';
import 'package:obers_ui/src/primitives/layout/oi_row.dart';

// Material Icons codepoints.
const IconData _kCartIcon = OiIcons.shoppingCart;

/// How the [OiMiniCart] displays its content overlay.
///
/// {@category Composites}
enum OiMiniCartDisplay {
  /// Shows content in a popover anchored to the cart icon.
  popover,

  /// Shows content in a bottom sheet.
  sheet,
}

/// A compact cart widget: an icon button with badge count that opens a popover
/// or sheet showing a condensed cart preview.
///
/// Coverage: REQ-0061
///
/// Shows limited items with an overflow indicator, total price, and
/// 'View Cart' and 'Checkout' buttons. Badge is hidden when the cart is empty.
/// Empty state shows 'Cart is empty'.
///
/// Composes [OiIconButton], [OiBadge], [OiPopover]/[OiSheet], [OiColumn],
/// [OiCartItemRow] (compact), [OiPriceTag], [OiButton], [OiLabel].
///
/// {@category Composites}
class OiMiniCart extends StatefulWidget {
  /// Creates an [OiMiniCart].
  const OiMiniCart({
    required this.items,
    required this.summary,
    required this.label,
    this.onViewCart,
    this.onCheckout,
    this.onRemove,
    this.onQuantityChange,
    this.maxVisibleItems = 3,
    this.display = OiMiniCartDisplay.popover,
    this.currencyCode = 'EUR',
    super.key,
  });

  /// The list of cart items.
  final List<OiCartItem> items;

  /// The cart summary for total price display.
  final OiCartSummary summary;

  /// Accessibility label announced by screen readers.
  final String label;

  /// Called when the user taps the 'View Cart' button.
  final VoidCallback? onViewCart;

  /// Called when the user taps the 'Checkout' button.
  final VoidCallback? onCheckout;

  /// Called when the user removes an item, with the item's `productKey`.
  final ValueChanged<Object>? onRemove;

  /// Called when the user changes the quantity of an item.
  final void Function(({Object productKey, int quantity}))? onQuantityChange;

  /// Maximum number of items shown in the preview. Defaults to `3`.
  final int maxVisibleItems;

  /// Whether to show a popover or sheet. Defaults to [OiMiniCartDisplay.popover].
  final OiMiniCartDisplay display;

  /// ISO 4217 currency code. Defaults to `'EUR'`.
  final String currencyCode;

  @override
  State<OiMiniCart> createState() => _OiMiniCartState();
}

class _OiMiniCartState extends State<OiMiniCart> {
  bool _isOpen = false;

  void _toggle() => setState(() => _isOpen = !_isOpen);

  void _close() => setState(() => _isOpen = false);

  Widget _buildAnchor(BuildContext context) {
    final iconButton = OiIconButton(
      icon: _kCartIcon,
      semanticLabel: widget.label,
      onTap: _toggle,
    );

    if (widget.items.isEmpty) return iconButton;

    final totalCount = widget.items.fold<int>(
      0,
      (sum, item) => sum + item.quantity,
    );

    return Stack(
      clipBehavior: Clip.none,
      children: [
        iconButton,
        Positioned(
          top: -4,
          right: -4,
          child: OiBadge.filled(label: '$totalCount', size: OiBadgeSize.small),
        ),
      ],
    );
  }

  Widget _buildEmptyContent(BuildContext context) {
    final sp = context.spacing;

    return Padding(
      padding: EdgeInsets.all(sp.lg),
      child: const Center(child: OiLabel.body('Cart is empty')),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (widget.items.isEmpty) return _buildEmptyContent(context);

    final breakpoint = context.breakpoint;
    final sp = context.spacing;

    final visibleItems = widget.items.take(widget.maxVisibleItems).toList();
    final overflowCount = widget.items.length - visibleItems.length;

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(sp.md),
        child: OiColumn(
          breakpoint: breakpoint,
          gap: OiResponsive(sp.sm),
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const OiLabel.bodyStrong('Cart'),
            for (final item in visibleItems)
              OiCartItemRow(
                item: item,
                label: '${item.name} × ${item.quantity}',
                compact: true,
                currencyCode: widget.currencyCode,
                onQuantityChange: widget.onQuantityChange != null
                    ? (qty) => widget.onQuantityChange!(
                          (productKey: item.productKey, quantity: qty),
                        )
                    : null,
                onRemove: widget.onRemove != null
                    ? () => widget.onRemove!(item.productKey)
                    : null,
              ),
            if (overflowCount > 0)
              Padding(
                padding: EdgeInsets.only(left: sp.sm),
                child: OiLabel.small(
                  '$overflowCount more item${overflowCount == 1 ? '' : 's'}',
                ),
              ),
            const OiDivider(),
            OiRow(
              breakpoint: breakpoint,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const OiLabel.bodyStrong('Total'),
                OiPriceTag(
                  price: widget.summary.total,
                  label: 'Cart total',
                  currencyCode: widget.currencyCode,
                ),
              ],
            ),
            OiRow(
              breakpoint: breakpoint,
              gap: OiResponsive(sp.sm),
              children: [
                Expanded(
                  child: OiButton.ghost(
                    label: 'View Cart',
                    onTap: widget.onViewCart,
                    fullWidth: true,
                    semanticLabel: 'View Cart',
                  ),
                ),
                Expanded(
                  child: OiButton.primary(
                    label: 'Checkout',
                    onTap: widget.onCheckout,
                    fullWidth: true,
                    semanticLabel: 'Checkout',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final content = _buildContent(context);

    if (widget.display == OiMiniCartDisplay.sheet) {
      return Semantics(
        label: widget.label,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildAnchor(context),
            OiSheet(
              label: widget.label,
              open: _isOpen,
              onClose: _close,
              child: content,
            ),
          ],
        ),
      );
    }

    return Semantics(
      label: widget.label,
      child: OiPopover(
        label: widget.label,
        open: _isOpen,
        onClose: _close,
        anchor: _buildAnchor(context),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: content,
        ),
      ),
    );
  }
}
