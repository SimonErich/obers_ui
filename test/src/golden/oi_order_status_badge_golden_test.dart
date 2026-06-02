// Golden tests have no public API.

import 'package:alchemist/alchemist.dart';
import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';

import '../../helpers/golden_helper.dart';

Future<void> main() async {
  // ── Light theme ───────────────────────────────────────────────────────────

  await goldenTest(
    'OiOrderStatusBadge all statuses — light',
    fileName: 'oi_order_status_badge_all_statuses_light',
    builder: () => obersGoldenGroup(
      columns: 4,
      children: _buildAllStatuses(),
    ),
  );

  // ── Dark theme ────────────────────────────────────────────────────────────

  await goldenTest(
    'OiOrderStatusBadge all statuses — dark',
    fileName: 'oi_order_status_badge_all_statuses_dark',
    builder: () => obersGoldenGroup(
      columns: 4,
      theme: OiThemeData.dark(),
      children: _buildAllStatuses(),
    ),
  );

  // ── Scenario-based golden test ──────────────────────────────────────────

  await goldenTest(
    'OiOrderStatusBadge scenarios',
    fileName: 'oi_order_status_badge_scenarios',
    builder: () => obersGoldenGroup(
      columns: 4,
      children: {
        'Pending': _modify(OiOrderStatus.pending),
        'Confirmed': _modify(OiOrderStatus.confirmed),
        'Processing': _modify(OiOrderStatus.processing),
        'Shipped': _modify(OiOrderStatus.shipped),
        'Delivered': _modify(OiOrderStatus.delivered),
        'Cancelled': _modify(OiOrderStatus.cancelled),
        'Refunded': _modify(OiOrderStatus.refunded),
      },
    ),
  );
}

/// Creates a badge widget for the given [status], used by scenarios to
/// modify the status under test.
Widget _modify(OiOrderStatus status) {
  return OiOrderStatusBadge(status: status, label: status.name);
}

/// Builds all 7 order status badges for golden snapshot comparison.
Map<String, Widget> _buildAllStatuses() {
  return {
    'Pending': const OiOrderStatusBadge(
      status: OiOrderStatus.pending,
      label: 'Pending',
    ),
    'Confirmed': const OiOrderStatusBadge(
      status: OiOrderStatus.confirmed,
      label: 'Confirmed',
    ),
    'Processing': const OiOrderStatusBadge(
      status: OiOrderStatus.processing,
      label: 'Processing',
    ),
    'Shipped': const OiOrderStatusBadge(
      status: OiOrderStatus.shipped,
      label: 'Shipped',
    ),
    'Delivered': const OiOrderStatusBadge(
      status: OiOrderStatus.delivered,
      label: 'Delivered',
    ),
    'Cancelled': const OiOrderStatusBadge(
      status: OiOrderStatus.cancelled,
      label: 'Cancelled',
    ),
    'Refunded': const OiOrderStatusBadge(
      status: OiOrderStatus.refunded,
      label: 'Refunded',
    ),
  };
}
