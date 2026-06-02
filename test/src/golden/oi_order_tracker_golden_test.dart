// Golden tests have no public API.

import 'package:alchemist/alchemist.dart';
import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';

import '../../helpers/golden_helper.dart';

Future<void> main() async {
  // ── Delivered with timeline ─────────────────────────────────────────────

  await goldenTest(
    'OiOrderTracker delivered with timeline — light',
    fileName: 'oi_order_tracker_delivered_with_timeline_light',
    builder: () => obersGoldenGroup(
      columns: 1,
      cellSize: const Size(760, 520),
      children: {'Delivered + Timeline': _buildDeliveredWithTimeline()},
    ),
  );

  await goldenTest(
    'OiOrderTracker delivered with timeline — dark',
    fileName: 'oi_order_tracker_delivered_with_timeline_dark',
    builder: () => obersGoldenGroup(
      columns: 1,
      cellSize: const Size(760, 520),
      theme: OiThemeData.dark(),
      children: {'Delivered + Timeline': _buildDeliveredWithTimeline()},
    ),
  );

  // ── Shipped without timeline ────────────────────────────────────────────

  await goldenTest(
    'OiOrderTracker shipped without timeline — light',
    fileName: 'oi_order_tracker_shipped_without_timeline_light',
    builder: () => obersGoldenGroup(
      columns: 1,
      cellSize: const Size(760, 220),
      children: {'Shipped (no timeline)': _buildShippedWithoutTimeline()},
    ),
  );

  await goldenTest(
    'OiOrderTracker shipped without timeline — dark',
    fileName: 'oi_order_tracker_shipped_without_timeline_dark',
    builder: () => obersGoldenGroup(
      columns: 1,
      cellSize: const Size(760, 220),
      theme: OiThemeData.dark(),
      children: {'Shipped (no timeline)': _buildShippedWithoutTimeline()},
    ),
  );
}

/// Builds an [OiOrderTracker] in delivered status with timeline visible.
Widget _buildDeliveredWithTimeline() {
  final now = DateTime(2026, 1, 15, 14, 30);
  return SizedBox(
    width: 700,
    child: OiOrderTracker(
      currentStatus: OiOrderStatus.delivered,
      label: 'Order tracker',
      showTimeline: true,
      timeline: [
        OiOrderEvent(
          timestamp: now.subtract(const Duration(days: 4)),
          title: 'Order placed',
          status: OiOrderStatus.pending,
          description: 'Your order has been received.',
        ),
        OiOrderEvent(
          timestamp: now.subtract(const Duration(days: 3)),
          title: 'Order confirmed',
          status: OiOrderStatus.confirmed,
        ),
        OiOrderEvent(
          timestamp: now.subtract(const Duration(days: 2)),
          title: 'Processing',
          status: OiOrderStatus.processing,
        ),
        OiOrderEvent(
          timestamp: now.subtract(const Duration(days: 1)),
          title: 'Shipped',
          status: OiOrderStatus.shipped,
          description: 'Package is on its way.',
        ),
        OiOrderEvent(
          timestamp: now,
          title: 'Delivered',
          status: OiOrderStatus.delivered,
          description: 'Package delivered successfully.',
        ),
      ],
    ),
  );
}

/// Builds an [OiOrderTracker] in shipped status without timeline.
Widget _buildShippedWithoutTimeline() {
  return const SizedBox(
    width: 700,
    child: OiOrderTracker(
      currentStatus: OiOrderStatus.shipped,
      label: 'Order tracker',
    ),
  );
}
