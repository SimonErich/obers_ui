import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/display/oi_badge.dart';

/// The stock availability status of a product.
///
/// {@category Components}
enum OiStockStatus {
  /// Product is available.
  inStock,

  /// Product has limited availability.
  lowStock,

  /// Product is not available.
  outOfStock,
}

/// The texts of an [OiStockBadge], in English by default; pass translations
/// to localize the badge.
///
/// {@category Components}
class OiStockBadgeLabels {
  /// Creates an [OiStockBadgeLabels].
  const OiStockBadgeLabels({
    this.inStock = englishInStock,
    this.lowStock = englishLowStock,
    this.outOfStock = 'Out of Stock',
  });

  /// "In Stock (12)", or "In Stock" without a count: the default [inStock].
  static String englishInStock(int? count) =>
      count != null ? 'In Stock ($count)' : 'In Stock';

  /// "Low Stock (3 left)", or "Low Stock" without a count: the default
  /// [lowStock].
  static String englishLowStock(int? count) =>
      count != null ? 'Low Stock ($count left)' : 'Low Stock';

  /// Shown while in stock, with the remaining count when known.
  final String Function(int? count) inStock;

  /// Shown while low on stock, with the remaining count when known.
  final String Function(int? count) lowStock;

  /// Shown while out of stock.
  final String outOfStock;
}

/// A badge indicating the stock availability of a product.
///
/// Coverage: REQ-0071
///
/// Displays a colored badge based on [status]: green for [OiStockStatus.inStock],
/// amber for [OiStockStatus.lowStock], and red for [OiStockStatus.outOfStock].
/// An optional [count] appends the remaining quantity to the badge text.
///
/// Use [OiStockBadge.fromCount] to derive the status automatically from a
/// stock count integer.
///
/// {@category Components}
class OiStockBadge extends StatelessWidget {
  /// Creates an [OiStockBadge] with an explicit status.
  const OiStockBadge({
    required this.status,
    required this.label,
    this.count,
    this.labels = const OiStockBadgeLabels(),
    super.key,
  });

  /// Creates an [OiStockBadge] by deriving [status] from [stockCount].
  ///
  /// - `null` or values above [lowStockThreshold] → [OiStockStatus.inStock]
  /// - `0` → [OiStockStatus.outOfStock]
  /// - `1..lowStockThreshold` → [OiStockStatus.lowStock]
  factory OiStockBadge.fromCount({
    required int? stockCount,
    required String label,
    int lowStockThreshold = 5,
    OiStockBadgeLabels labels = const OiStockBadgeLabels(),
    Key? key,
  }) {
    final OiStockStatus resolvedStatus;
    if (stockCount == null) {
      resolvedStatus = OiStockStatus.inStock;
    } else if (stockCount <= 0) {
      resolvedStatus = OiStockStatus.outOfStock;
    } else if (stockCount <= lowStockThreshold) {
      resolvedStatus = OiStockStatus.lowStock;
    } else {
      resolvedStatus = OiStockStatus.inStock;
    }
    return OiStockBadge(
      status: resolvedStatus,
      label: label,
      count: stockCount,
      labels: labels,
      key: key,
    );
  }

  /// The stock availability status.
  final OiStockStatus status;

  /// Accessibility label announced by screen readers.
  final String label;

  /// Optional remaining item count shown alongside the status text.
  final int? count;

  /// The badge's texts; pass translations to localize it.
  final OiStockBadgeLabels labels;

  String get _statusText {
    switch (status) {
      case OiStockStatus.inStock:
        return labels.inStock(count);
      case OiStockStatus.lowStock:
        return labels.lowStock(count);
      case OiStockStatus.outOfStock:
        return labels.outOfStock;
    }
  }

  OiBadgeColor get _badgeColor {
    switch (status) {
      case OiStockStatus.inStock:
        return OiBadgeColor.success;
      case OiStockStatus.lowStock:
        return OiBadgeColor.warning;
      case OiStockStatus.outOfStock:
        return OiBadgeColor.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      child: ExcludeSemantics(
        child: OiBadge.soft(
          label: _statusText,
          color: _badgeColor,
          size: OiBadgeSize.small,
        ),
      ),
    );
  }
}
