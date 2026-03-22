import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';

/// Order confirmation screen with tracker and a back-to-shop button.
class ShopOrderConfirmScreen extends StatelessWidget {
  const ShopOrderConfirmScreen({
    required this.order,
    required this.onBackToShop,
    super.key,
  });

  final OiOrderData order;
  final VoidCallback onBackToShop;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final bp = context.breakpoint;

    return SingleChildScrollView(
      padding: EdgeInsets.all(spacing.lg),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: OiColumn(
            breakpoint: bp,
            gap: OiResponsive<double>(spacing.lg),
            children: [
              const OiLabel.h2('Order Confirmed!'),
              OiLabel.body(
                'Thank you for your order. Your order number is '
                '${order.orderNumber}.',
              ),
              OiOrderSummary(
                summary: order.summary,
                label: 'Order summary',
                items: order.items,
                expandedByDefault: true,
              ),
              OiOrderTracker(
                currentStatus: order.status,
                label: 'Order status tracker',
                timeline: order.timeline,
                showTimeline: order.timeline != null,
              ),
              OiButton.primary(
                label: 'Back to Shop',
                onTap: onBackToShop,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
