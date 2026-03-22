import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/display/oi_badge.dart';
import 'package:obers_ui/src/models/oi_order_data.dart';

/// A badge that displays the current status of an order.
///
/// Coverage: REQ-0022
///
/// Maps each [OiOrderStatus] to a semantic colour and human-readable text.
/// Use [OiOrderStatusBadge.soft] for the muted-background variant (default)
/// or [OiOrderStatusBadge.filled] for the solid-background variant.
///
/// {@category Components}
class OiOrderStatusBadge extends StatelessWidget {
  /// Creates an [OiOrderStatusBadge] with a soft (muted) background.
  const OiOrderStatusBadge({
    required this.status,
    required this.label,
    this.statusColors,
    this.statusLabels,
    this.size = OiBadgeSize.small,
    super.key,
  }) : _style = OiBadgeStyle.soft;

  /// Creates an [OiOrderStatusBadge] with a soft (muted) background.
  const OiOrderStatusBadge.soft({
    required this.status,
    required this.label,
    this.statusColors,
    this.statusLabels,
    this.size = OiBadgeSize.small,
    super.key,
  }) : _style = OiBadgeStyle.soft;

  /// Creates an [OiOrderStatusBadge] with a filled (solid) background.
  const OiOrderStatusBadge.filled({
    required this.status,
    required this.label,
    this.statusColors,
    this.statusLabels,
    this.size = OiBadgeSize.small,
    super.key,
  }) : _style = OiBadgeStyle.filled;

  /// Creates an [OiOrderStatusBadge] from an [OiOrderData], extracting the
  /// status automatically.
  OiOrderStatusBadge.fromOrder({
    required OiOrderData order,
    this.label = 'Order status',
    this.statusColors,
    this.statusLabels,
    this.size = OiBadgeSize.small,
    super.key,
  }) : status = order.status,
       _style = OiBadgeStyle.soft;

  /// The order status to display.
  final OiOrderStatus status;

  /// Accessibility label announced by screen readers.
  final String label;

  /// Custom label overrides for specific statuses.
  ///
  /// When provided, the label for a given status is looked up here first.
  /// If the status is not present in the map, the default label is used.
  final Map<OiOrderStatus, String>? statusLabels;

  /// Custom color overrides for specific statuses.
  ///
  /// When provided, the badge color for a given status is looked up here
  /// first. If the status is not present in the map, the default color
  /// mapping is used.
  final Map<OiOrderStatus, OiBadgeColor>? statusColors;

  /// Badge size. Defaults to [OiBadgeSize.small].
  final OiBadgeSize size;

  final OiBadgeStyle _style;

  String get _statusText {
    if (statusLabels != null && statusLabels!.containsKey(status)) {
      return statusLabels![status]!;
    }
    return _defaultLabelForStatus(status);
  }

  /// Returns the default label for the given [status].
  static String _defaultLabelForStatus(OiOrderStatus status) {
    switch (status) {
      case OiOrderStatus.pending:
        return 'Pending';
      case OiOrderStatus.confirmed:
        return 'Confirmed';
      case OiOrderStatus.processing:
        return 'Processing';
      case OiOrderStatus.shipped:
        return 'Shipped';
      case OiOrderStatus.delivered:
        return 'Delivered';
      case OiOrderStatus.cancelled:
        return 'Cancelled';
      case OiOrderStatus.refunded:
        return 'Refunded';
    }
  }

  OiBadgeColor get _badgeColor {
    if (statusColors != null && statusColors!.containsKey(status)) {
      return statusColors![status]!;
    }
    return _defaultColorForStatus(status);
  }

  /// Returns the default [OiBadgeColor] for the given [status].
  static OiBadgeColor _defaultColorForStatus(OiOrderStatus status) {
    switch (status) {
      case OiOrderStatus.pending:
        return OiBadgeColor.warning;
      case OiOrderStatus.confirmed:
        return OiBadgeColor.primary;
      case OiOrderStatus.processing:
        return OiBadgeColor.primary;
      case OiOrderStatus.shipped:
        return OiBadgeColor.accent;
      case OiOrderStatus.delivered:
        return OiBadgeColor.success;
      case OiOrderStatus.cancelled:
        return OiBadgeColor.error;
      case OiOrderStatus.refunded:
        return OiBadgeColor.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Widget badge;
    if (_style == OiBadgeStyle.filled) {
      badge = OiBadge.filled(
        label: _statusText,
        color: _badgeColor,
        size: size,
      );
    } else {
      badge = OiBadge.soft(label: _statusText, color: _badgeColor, size: size);
    }

    return Semantics(
      label: label,
      child: ExcludeSemantics(child: badge),
    );
  }
}
