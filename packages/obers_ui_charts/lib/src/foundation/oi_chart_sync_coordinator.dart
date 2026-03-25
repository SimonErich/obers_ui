import 'package:flutter/foundation.dart';

import 'package:obers_ui_charts/src/foundation/oi_chart_controller.dart';
import 'package:obers_ui_charts/src/foundation/oi_chart_viewport.dart';

/// Abstract coordinator that synchronises state across linked charts.
///
/// When multiple charts share an [OiChartSyncCoordinator], actions like
/// zoom, pan, selection, and crosshair position are broadcast to all
/// participants so that they stay in sync.
///
/// {@category Foundation}
abstract class OiChartSyncCoordinator extends ChangeNotifier {
  /// A unique identifier for this sync group.
  String get groupId;

  /// Broadcasts a viewport change to all other participants.
  void syncViewport(OiChartViewport viewport);

  /// Broadcasts a selection change to all other participants.
  void syncSelection(Set<OiChartDataRef> selection);

  /// Broadcasts a crosshair / hover position to all other participants.
  ///
  /// The [normalizedX] value is in the 0–1 range relative to the plot
  /// area width.
  void syncCrosshair(double? normalizedX);

  /// Registers a listener that is called when a peer changes the viewport.
  void addViewportListener(ValueChanged<OiChartViewport> listener);

  /// Removes a previously registered viewport listener.
  void removeViewportListener(ValueChanged<OiChartViewport> listener);

  /// Registers a listener that is called when a peer changes the selection.
  void addSelectionListener(ValueChanged<Set<OiChartDataRef>> listener);

  /// Removes a previously registered selection listener.
  void removeSelectionListener(ValueChanged<Set<OiChartDataRef>> listener);

  /// Registers a listener that is called when a peer moves the crosshair.
  void addCrosshairListener(ValueChanged<double?> listener);

  /// Removes a previously registered crosshair listener.
  void removeCrosshairListener(ValueChanged<double?> listener);
}
