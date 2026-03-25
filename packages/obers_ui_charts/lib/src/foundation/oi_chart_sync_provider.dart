import 'package:flutter/widgets.dart';

import 'package:obers_ui_charts/src/foundation/oi_chart_sync_coordinator.dart';

/// InheritedWidget that provides an [OiChartSyncCoordinator] to the tree.
///
/// Charts with `syncGroup` look up this provider to register themselves
/// with the coordinator. The coordinator is created lazily — only when
/// the first chart requests it.
///
/// {@category Foundation}
class OiChartSyncProvider extends InheritedWidget {
  /// Creates an [OiChartSyncProvider].
  const OiChartSyncProvider({
    super.key,
    required this.coordinator,
    required super.child,
  });

  /// The sync coordinator provided to descendant charts.
  final OiChartSyncCoordinator coordinator;

  /// Returns the [OiChartSyncCoordinator] from the nearest ancestor, or
  /// null if none exists.
  static OiChartSyncCoordinator? maybeOf(BuildContext context) {
    final provider = context
        .dependOnInheritedWidgetOfExactType<OiChartSyncProvider>();
    return provider?.coordinator;
  }

  @override
  bool updateShouldNotify(OiChartSyncProvider oldWidget) =>
      coordinator != oldWidget.coordinator;
}
