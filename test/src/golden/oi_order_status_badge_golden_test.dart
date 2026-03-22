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

  // ── Light theme ───────────────────────────────────────────────────────────

  testGoldens('OiOrderStatusBadge all statuses — light', (tester) async {
    final builder = obersGoldenBuilder(
      columns: 4,
      children: _buildAllStatuses(),
    );
    await tester.pumpWidgetBuilder(builder);
    await screenMatchesGolden(
      tester,
      'oi_order_status_badge_all_statuses_light',
    );
  });

  // ── Dark theme ────────────────────────────────────────────────────────────

  testGoldens('OiOrderStatusBadge all statuses — dark', (tester) async {
    final builder = obersGoldenBuilder(
      columns: 4,
      theme: OiThemeData.dark(),
      children: _buildAllStatuses(),
    );
    await tester.pumpWidgetBuilder(builder);
    await screenMatchesGolden(
      tester,
      'oi_order_status_badge_all_statuses_dark',
    );
  });

  // ── Scenario-based golden tests ─────────────────────────────────────────

  testGoldens('OiOrderStatusBadge scenarios', (tester) async {
    final scenarios = GoldenBuilder.grid(columns: 4, widthToHeightRatio: 2)
      ..addScenario('Pending', _modify(OiOrderStatus.pending))
      ..addScenario('Confirmed', _modify(OiOrderStatus.confirmed))
      ..addScenario('Processing', _modify(OiOrderStatus.processing))
      ..addScenario('Shipped', _modify(OiOrderStatus.shipped))
      ..addScenario('Delivered', _modify(OiOrderStatus.delivered))
      ..addScenario('Cancelled', _modify(OiOrderStatus.cancelled))
      ..addScenario('Refunded', _modify(OiOrderStatus.refunded));
    await tester.pumpWidgetBuilder(
      scenarios.build(),
      wrapper: (child) => OiApp(theme: OiThemeData.light(), home: child),
    );
    await screenMatchesGolden(tester, 'oi_order_status_badge_scenarios');
  });

  // ── Multi-screen golden test ────────────────────────────────────────────

  testGoldens('OiOrderStatusBadge multi-screen', (tester) async {
    await tester.pumpWidgetBuilder(
      _buildAllStatusesWidget(),
      wrapper: (child) => OiApp(theme: OiThemeData.light(), home: child),
      surfaceSize: const Size(800, 200),
    );
    await multiScreenGolden(
      tester,
      'oi_order_status_badge_multi_screen',
      devices: [
        Device.phone.copyWith(size: const Size(800, 200)),
        Device.tabletLandscape.copyWith(size: const Size(1200, 200)),
      ],
    );
  });
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

/// Builds all 7 order status badges as a single widget for multi-screen tests.
Widget _buildAllStatusesWidget() {
  return const Wrap(
    spacing: 8,
    runSpacing: 8,
    children: [
      OiOrderStatusBadge(status: OiOrderStatus.pending, label: 'Pending'),
      OiOrderStatusBadge(status: OiOrderStatus.confirmed, label: 'Confirmed'),
      OiOrderStatusBadge(status: OiOrderStatus.processing, label: 'Processing'),
      OiOrderStatusBadge(status: OiOrderStatus.shipped, label: 'Shipped'),
      OiOrderStatusBadge(status: OiOrderStatus.delivered, label: 'Delivered'),
      OiOrderStatusBadge(status: OiOrderStatus.cancelled, label: 'Cancelled'),
      OiOrderStatusBadge(status: OiOrderStatus.refunded, label: 'Refunded'),
    ],
  );
}
