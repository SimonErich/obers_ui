// Golden tests have no public API.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:obers_ui/obers_ui.dart';

import '../../helpers/golden_helper.dart';

void main() {
  // Enable autoUpdateGoldenFiles for initial generation; CI compares against
  // committed goldens.
  // ignore: deprecated_member_use
  autoUpdateGoldenFiles = true;

  // ── Delivered with timeline ─────────────────────────────────────────────

  testGoldens('OiOrderTracker delivered with timeline — light', (tester) async {
    final builder = obersGoldenBuilder(
      children: {'Delivered + Timeline': _buildDeliveredWithTimeline()},
    );
    await tester.pumpWidgetBuilder(builder);
    await screenMatchesGolden(
      tester,
      'oi_order_tracker_delivered_with_timeline_light',
    );
  });

  testGoldens('OiOrderTracker delivered with timeline — dark', (tester) async {
    final builder = obersGoldenBuilder(
      theme: OiThemeData.dark(),
      children: {'Delivered + Timeline': _buildDeliveredWithTimeline()},
    );
    await tester.pumpWidgetBuilder(builder);
    await screenMatchesGolden(
      tester,
      'oi_order_tracker_delivered_with_timeline_dark',
    );
  });

  // ── Shipped without timeline ────────────────────────────────────────────

  testGoldens('OiOrderTracker shipped without timeline — light', (
    tester,
  ) async {
    final builder = obersGoldenBuilder(
      children: {'Shipped (no timeline)': _buildShippedWithoutTimeline()},
    );
    await tester.pumpWidgetBuilder(builder, surfaceSize: const Size(800, 200));
    await screenMatchesGolden(
      tester,
      'oi_order_tracker_shipped_without_timeline_light',
    );
  });

  testGoldens('OiOrderTracker shipped without timeline — dark', (tester) async {
    final builder = obersGoldenBuilder(
      theme: OiThemeData.dark(),
      children: {'Shipped (no timeline)': _buildShippedWithoutTimeline()},
    );
    await tester.pumpWidgetBuilder(builder, surfaceSize: const Size(800, 200));
    await screenMatchesGolden(
      tester,
      'oi_order_tracker_shipped_without_timeline_dark',
    );
  });
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
