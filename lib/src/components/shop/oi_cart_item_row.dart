import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/buttons/oi_button.dart';
import 'package:obers_ui/src/components/display/oi_image.dart';
import 'package:obers_ui/src/components/shop/oi_price_tag.dart';
import 'package:obers_ui/src/components/shop/oi_quantity_selector.dart';
import 'package:obers_ui/src/foundation/oi_responsive.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/models/oi_cart_item.dart';
import 'package:obers_ui/src/primitives/display/oi_label.dart';
import 'package:obers_ui/src/primitives/gesture/oi_swipeable.dart';
import 'package:obers_ui/src/primitives/interaction/oi_tappable.dart';
import 'package:obers_ui/src/primitives/layout/oi_column.dart';
import 'package:obers_ui/src/primitives/layout/oi_row.dart';

// Material Icons codepoints.
const IconData _kDeleteIcon = IconData(0xe872, fontFamily: 'MaterialIcons');
const IconData _kImageIcon = IconData(0xe3f4, fontFamily: 'MaterialIcons');

/// A single line item row for the shopping cart.
///
/// Coverage: REQ-0030
///
/// Shows thumbnail, name, variant info, quantity selector, line total, and
/// remove button. Supports swipe-to-remove on mobile via [OiSwipeable].
/// Non-editable mode hides quantity selector and remove button.
///
/// Composes [OiRow], [OiImage], [OiLabel], [OiQuantitySelector],
/// [OiPriceTag], [OiButton.ghost], [OiSwipeable].
///
/// {@category Components}
class OiCartItemRow extends StatelessWidget {
  /// Creates an [OiCartItemRow].
  const OiCartItemRow({
    required this.item,
    required this.label,
    this.onQuantityChange,
    this.onRemove,
    this.onTap,
    this.editable = true,
    this.compact = false,
    this.currencyCode = 'EUR',
    super.key,
  });

  /// The cart item data to display.
  final OiCartItem item;

  /// Accessibility label announced by screen readers.
  final String label;

  /// Called when the user changes the quantity.
  final ValueChanged<int>? onQuantityChange;

  /// Called when the user removes this item.
  final VoidCallback? onRemove;

  /// Called when the row is tapped.
  final VoidCallback? onTap;

  /// Whether interactive controls (quantity selector, remove button) are shown.
  ///
  /// Set to `false` for order confirmation views. Defaults to `true`.
  final bool editable;

  /// When `true`, renders a smaller row suitable for mini-cart overlays.
  ///
  /// Defaults to `false`.
  final bool compact;

  /// ISO 4217 currency code for price display. Defaults to `'EUR'`.
  final String currencyCode;

  Widget _buildThumbnail(BuildContext context) {
    final size = compact ? 48.0 : 72.0;

    if (item.imageUrl != null) {
      return ClipRRect(
        borderRadius: context.radius.sm,
        child: OiImage(
          src: item.imageUrl!,
          alt: item.name,
          width: size,
          height: size,
          fit: BoxFit.cover,
        ),
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: context.colors.surfaceSubtle,
        borderRadius: context.radius.sm,
      ),
      child: Center(
        child: Icon(
          _kImageIcon,
          size: compact ? 20 : 28,
          color: context.colors.textMuted,
        ),
      ),
    );
  }

  Widget _buildInfo(BuildContext context) {
    final breakpoint = context.breakpoint;
    final sp = context.spacing;

    final children = <Widget>[
      if (compact)
        OiLabel.small(item.name, maxLines: 1, overflow: TextOverflow.ellipsis)
      else
        OiLabel.bodyStrong(
          item.name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
    ];

    if (item.variantLabel != null) {
      children.add(OiLabel.small(item.variantLabel!));
    }

    if (!editable) {
      children.add(OiLabel.small('× ${item.quantity}'));
    }

    return OiColumn(
      breakpoint: breakpoint,
      gap: OiResponsive(compact ? sp.xs / 2 : sp.xs),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  Widget _buildActions(BuildContext context) {
    final breakpoint = context.breakpoint;
    final sp = context.spacing;

    final children = <Widget>[];

    if (editable) {
      children.add(
        OiQuantitySelector(
          value: item.quantity,
          label: '${item.name} quantity',
          max: item.maxQuantity ?? 99,
          compact: compact,
          onChange: onQuantityChange,
        ),
      );
    }

    children.add(
      OiPriceTag(
        price: item.totalPrice,
        label: 'Line total for ${item.name}',
        currencyCode: currencyCode,
        size: compact ? OiPriceTagSize.small : OiPriceTagSize.medium,
      ),
    );

    if (editable && onRemove != null) {
      children.add(
        OiButton.ghost(
          label: 'Remove',
          icon: _kDeleteIcon,
          size: OiButtonSize.small,
          onTap: onRemove,
        ),
      );
    }

    return OiColumn(
      breakpoint: breakpoint,
      gap: OiResponsive(sp.xs),
      crossAxisAlignment: CrossAxisAlignment.end,
      children: children,
    );
  }

  Widget _buildRow(BuildContext context) {
    final breakpoint = context.breakpoint;
    final sp = context.spacing;

    Widget content = OiRow(
      breakpoint: breakpoint,
      gap: OiResponsive(compact ? sp.sm : sp.md),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildThumbnail(context),
        Expanded(child: _buildInfo(context)),
        _buildActions(context),
      ],
    );

    content = Padding(
      padding: EdgeInsets.symmetric(
        vertical: compact ? sp.xs : sp.sm,
        horizontal: compact ? sp.sm : sp.md,
      ),
      child: content,
    );

    if (onTap != null) {
      content = OiTappable(onTap: onTap, semanticLabel: label, child: content);
    }

    return content;
  }

  @override
  Widget build(BuildContext context) {
    var content = _buildRow(context);

    if (editable && onRemove != null) {
      content = OiSwipeable(
        trailingActions: [
          OiSwipeAction(
            label: 'Remove',
            color: context.colors.error.base,
            icon: _kDeleteIcon,
            onTap: onRemove!,
          ),
        ],
        child: content,
      );
    }

    return Semantics(
      label: label,
      child: ExcludeSemantics(excluding: onTap == null, child: content),
    );
  }
}
