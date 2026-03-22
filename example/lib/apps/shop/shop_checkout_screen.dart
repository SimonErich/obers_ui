import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';

import 'package:obers_ui_example/data/mock_countries.dart';
import 'package:obers_ui_example/data/mock_shop.dart';

/// Checkout screen wrapping the [OiCheckout] wizard.
class ShopCheckoutScreen extends StatelessWidget {
  const ShopCheckoutScreen({
    required this.cartItems,
    required this.cartSummary,
    required this.onPlaceOrder,
    required this.onCancel,
    super.key,
  });

  final List<OiCartItem> cartItems;
  final OiCartSummary cartSummary;
  final Future<OiOrderData> Function(OiCheckoutData) onPlaceOrder;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;

    return SingleChildScrollView(
      padding: EdgeInsets.all(spacing.lg),
      child: OiCheckout(
        items: cartItems,
        summary: cartSummary,
        label: 'Checkout',
        shippingMethods: kShippingMethods,
        paymentMethods: kPaymentMethods,
        countries: kCountries,
        initialShippingAddress: kSampleAddress,
        currencyCode: 'EUR',
        onPlaceOrder: onPlaceOrder,
        onCancel: onCancel,
      ),
    );
  }
}
