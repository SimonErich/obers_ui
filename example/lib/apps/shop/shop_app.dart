import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';

import 'package:obers_ui_example/apps/shop/shop_browse_screen.dart';
import 'package:obers_ui_example/apps/shop/shop_cart_screen.dart';
import 'package:obers_ui_example/apps/shop/shop_checkout_screen.dart';
import 'package:obers_ui_example/apps/shop/shop_order_confirm_screen.dart';
import 'package:obers_ui_example/apps/shop/shop_product_screen.dart';
import 'package:obers_ui_example/apps/shop/shop_wishlist_screen.dart';
import 'package:obers_ui_example/data/mock_shop.dart';
import 'package:obers_ui_example/shell/showcase_shell.dart';
import 'package:obers_ui_example/theme/theme_state.dart';

/// The screens available in the shop mini-app.
enum _ShopScreen {
  browse,
  product,
  cart,
  checkout,
  orderConfirm,
  wishlist,
}

/// Root widget for the Shop showcase mini-app.
///
/// Manages cart state and internal screen navigation.
class ShopApp extends StatefulWidget {
  const ShopApp({required this.themeState, super.key});

  final ThemeState themeState;

  @override
  State<ShopApp> createState() => _ShopAppState();
}

class _ShopAppState extends State<ShopApp> {
  late List<OiCartItem> _cartItems = List.of(kInitialCartItems);
  late _ShopScreen _currentScreen = _ShopScreen.browse;
  // Written multiple times across screen transitions.
  // ignore: use_late_for_private_fields_and_variables
  OiProductData? _selectedProduct;
  OiOrderData? _confirmedOrder;

  // Wishlist state
  final Set<Object> _wishlisted = {};

  // Coupon state
  String? _appliedCouponCode;
  double? _discountAmount;
  String? _discountLabel;

  // ── Cart helpers ───────────────────────────────────────────────────────────

  OiCartSummary get _cartSummary => computeCartSummary(
        _cartItems,
        discountAmount: _discountAmount,
        discountLabel: _discountLabel,
      );

  void _addToCart(OiProductData product) {
    setState(() {
      final existingIndex = _cartItems.indexWhere(
        (item) => item.productKey == product.key,
      );
      if (existingIndex >= 0) {
        final existing = _cartItems[existingIndex];
        _cartItems = List.of(_cartItems);
        _cartItems[existingIndex] = existing.copyWith(
          quantity: existing.quantity + 1,
        );
      } else {
        _cartItems = [
          ..._cartItems,
          OiCartItem(
            productKey: product.key,
            name: product.name,
            unitPrice: product.price,
            imageUrl: product.imageUrl,
          ),
        ];
      }
    });
  }

  void _addCartItem(OiCartItem item) {
    setState(() {
      final existingIndex = _cartItems.indexWhere(
        (existing) =>
            existing.productKey == item.productKey &&
            existing.variantKey == item.variantKey,
      );
      if (existingIndex >= 0) {
        final existing = _cartItems[existingIndex];
        _cartItems = List.of(_cartItems);
        _cartItems[existingIndex] = existing.copyWith(
          quantity: existing.quantity + item.quantity,
        );
      } else {
        _cartItems = [..._cartItems, item];
      }
    });
  }

  void _removeFromCart(Object productKey) {
    setState(() {
      _cartItems =
          _cartItems.where((item) => item.productKey != productKey).toList();
    });
  }

  void _updateQuantity(({Object productKey, int quantity}) change) {
    setState(() {
      if (change.quantity <= 0) {
        _removeFromCart(change.productKey);
        return;
      }
      final index = _cartItems.indexWhere(
        (item) => item.productKey == change.productKey,
      );
      if (index >= 0) {
        _cartItems = List.of(_cartItems);
        _cartItems[index] = _cartItems[index].copyWith(
          quantity: change.quantity,
        );
      }
    });
  }

  Future<OiCouponResult> _applyCoupon(String code) async {
    final subtotal =
        _cartItems.fold<double>(0, (sum, item) => sum + item.totalPrice);
    final result = validateCoupon(code, subtotal);

    if (result.valid) {
      setState(() {
        _appliedCouponCode = code.trim().toUpperCase();
        _discountAmount = result.discountAmount;
        _discountLabel = '$_appliedCouponCode (${result.message})';
      });
    }

    return result;
  }

  void _removeCoupon() {
    setState(() {
      _appliedCouponCode = null;
      _discountAmount = null;
      _discountLabel = null;
    });
  }

  // ── Navigation ─────────────────────────────────────────────────────────────

  void _goTo(_ShopScreen screen) {
    setState(() {
      _currentScreen = screen;
    });
  }

  // ── Order placement ────────────────────────────────────────────────────────

  Future<OiOrderData> _placeOrder(OiCheckoutData data) async {
    // Simulate a network delay.
    await Future<void>.delayed(const Duration(milliseconds: 800));

    final order = OiOrderData(
      key: 'order-001',
      orderNumber: 'AG-2026-0042',
      createdAt: DateTime.now(),
      status: OiOrderStatus.confirmed,
      items: _cartItems,
      summary: _cartSummary,
      shippingAddress: data.shippingAddress,
      billingAddress: data.billingAddress,
      paymentMethod: data.paymentMethod,
      shippingMethod: data.shippingMethod,
      timeline: [
        OiOrderEvent(
          timestamp: DateTime.now(),
          title: 'Order Confirmed',
          status: OiOrderStatus.confirmed,
          description: 'Your order has been confirmed.',
        ),
        OiOrderEvent(
          timestamp: DateTime.now().subtract(const Duration(minutes: 1)),
          title: 'Order Placed',
          status: OiOrderStatus.pending,
          description: 'Order received and is being processed.',
        ),
      ],
    );

    setState(() {
      _confirmedOrder = order;
      _currentScreen = _ShopScreen.orderConfirm;
    });

    return order;
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  Widget _buildCurrentScreen() {
    switch (_currentScreen) {
      case _ShopScreen.browse:
        return ShopBrowseScreen(
          cartItems: _cartItems,
          cartSummary: _cartSummary,
          onSelectProduct: (product) {
            setState(() {
              _selectedProduct = product;
              _currentScreen = _ShopScreen.product;
            });
          },
          onAddToCart: _addToCart,
          onViewCart: () => _goTo(_ShopScreen.cart),
          onCheckout: () => _goTo(_ShopScreen.checkout),
          wishlistCount: _wishlisted.length,
          onViewWishlist: () => _goTo(_ShopScreen.wishlist),
        );

      case _ShopScreen.product:
        return ShopProductScreen(
          product: _selectedProduct!,
          onAddToCart: _addCartItem,
          onBack: () => _goTo(_ShopScreen.browse),
          isWishlisted: _wishlisted.contains(_selectedProduct!.key),
          onWishlistToggle: () {
            setState(() {
              final key = _selectedProduct!.key;
              if (_wishlisted.contains(key)) {
                _wishlisted.remove(key);
              } else {
                _wishlisted.add(key);
              }
            });
          },
        );

      case _ShopScreen.cart:
        return ShopCartScreen(
          cartItems: _cartItems,
          cartSummary: _cartSummary,
          onQuantityChange: _updateQuantity,
          onRemove: _removeFromCart,
          onApplyCoupon: _applyCoupon,
          onRemoveCoupon: _removeCoupon,
          appliedCouponCode: _appliedCouponCode,
          onCheckout: () => _goTo(_ShopScreen.checkout),
          onContinueShopping: () => _goTo(_ShopScreen.browse),
        );

      case _ShopScreen.checkout:
        return ShopCheckoutScreen(
          cartItems: _cartItems,
          cartSummary: _cartSummary,
          onPlaceOrder: _placeOrder,
          onCancel: () => _goTo(_ShopScreen.cart),
        );

      case _ShopScreen.orderConfirm:
        return ShopOrderConfirmScreen(
          order: _confirmedOrder!,
          onBackToShop: () {
            setState(() {
              _cartItems = List.of(kInitialCartItems);
              _appliedCouponCode = null;
              _discountAmount = null;
              _discountLabel = null;
              _confirmedOrder = null;
              _currentScreen = _ShopScreen.browse;
            });
          },
        );

      case _ShopScreen.wishlist:
        return ShopWishlistScreen(
          wishlistedKeys: _wishlisted,
          products: kProducts,
          onRemoveFromWishlist: (key) {
            setState(() {
              _wishlisted.remove(key);
            });
          },
          onSelectProduct: (product) {
            setState(() {
              _selectedProduct = product;
              _currentScreen = _ShopScreen.product;
            });
          },
          onBack: () => _goTo(_ShopScreen.browse),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ShowcaseShell(
      title: 'Shop',
      themeState: widget.themeState,
      child: _buildCurrentScreen(),
    );
  }
}
