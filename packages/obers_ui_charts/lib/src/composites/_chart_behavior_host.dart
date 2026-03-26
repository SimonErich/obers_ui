import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart' show OiChartThemeData, OiTheme;

import 'package:obers_ui_charts/src/foundation/oi_chart_accessibility_bridge.dart';
import 'package:obers_ui_charts/src/foundation/oi_chart_behavior.dart';
import 'package:obers_ui_charts/src/foundation/oi_chart_controller.dart';
import 'package:obers_ui_charts/src/foundation/oi_chart_hit_tester.dart';
import 'package:obers_ui_charts/src/foundation/oi_chart_sync_coordinator.dart';
import 'package:obers_ui_charts/src/foundation/oi_chart_sync_group.dart';
import 'package:obers_ui_charts/src/foundation/oi_chart_viewport.dart';
import 'package:obers_ui_charts/src/models/oi_chart_settings.dart';
import 'package:obers_ui_charts/src/models/oi_default_chart_controller.dart';

/// Shared mixin for chart [State] classes that host behaviors.
///
/// Manages behavior attach/detach lifecycle, pointer event forwarding,
/// and internal controller creation.
mixin ChartBehaviorHost<T extends StatefulWidget> on State<T> {
  /// Override to return the chart's behavior list.
  List<OiChartBehavior> get behaviors;

  /// Override to return the external controller (from widget props).
  OiChartController? get externalController;

  /// Override to return the current viewport.
  OiChartViewport get currentViewport;

  /// Override to return a hit tester (may be a no-op).
  OiChartHitTester get hitTester;

  // ── Internal controller ────────────────────────────────────────────────

  OiDefaultChartController? _internalController;

  /// The effective controller: external if provided, otherwise internal.
  OiChartController get effectiveController {
    if (externalController != null) return externalController!;
    return _internalController ??= OiDefaultChartController();
  }

  // ── Behavior lifecycle ─────────────────────────────────────────────────

  List<OiChartBehavior> _attachedBehaviors = const [];

  /// Attaches all [behaviors] with the current context.
  ///
  /// Call from [initState] and when behaviors or controller change.
  void attachBehaviors() {
    detachBehaviors();
    final ctx = OiChartBehaviorContext(
      buildContext: context,
      controller: effectiveController,
      viewport: currentViewport,
      hitTester: hitTester,
      theme: resolveTheme(context),
      accessibilityBridge: OiNoOpAccessibilityBridge(context),
    );
    for (final b in behaviors) {
      b.attach(ctx);
    }
    _attachedBehaviors = List.of(behaviors);
  }

  /// Detaches all currently attached behaviors.
  void detachBehaviors() {
    for (final b in _attachedBehaviors) {
      if (b.isAttached) b.detach();
    }
    _attachedBehaviors = const [];
  }

  /// Disposes internal controller, detaches behaviors, unregisters sync.
  ///
  /// Call from [dispose].
  void disposeBehaviorHost() {
    _unregisterSync();
    detachBehaviors();
    _internalController?.dispose();
    _internalController = null;
  }

  // ── Sync registration ──────────────────────────────────────────────────

  /// Override to return the sync group, if any.
  OiChartSyncGroup? get syncGroup => null;

  // Stored for future unregistration when the widget is disposed or
  // the sync group changes.
  // ignore: unused_field
  OiChartSyncCoordinator? _syncCoordinator;

  /// Registers with the sync coordinator if syncGroup is set.
  void registerSync() {
    if (syncGroup == null) return;
    _syncCoordinator = OiChartSyncProvider.of(context);
  }

  void _unregisterSync() {
    _syncCoordinator = null;
  }

  // ── Persistence ────────────────────────────────────────────────────────

  /// Restores controller state from persisted [settings].
  void restoreSettings(OiChartSettings? settings) {
    if (settings == null) return;
    final ctrl = effectiveController;

    // Restore hidden series → legend state.
    for (final id in settings.hiddenSeriesIds) {
      ctrl.toggleSeries(id);
    }

    // Restore viewport.
    if (settings.viewport != null) {
      ctrl.setVisibleDomain(
        xMin: settings.viewport!.xMin,
        xMax: settings.viewport!.xMax,
        yMin: settings.viewport!.yMin,
        yMax: settings.viewport!.yMax,
      );
    }
  }

  // ── Overlay collection ─────────────────────────────────────────────────

  /// Collects overlay widgets from all attached behaviors.
  List<Widget> collectBehaviorOverlays() {
    final overlays = <Widget>[];
    for (final b in _attachedBehaviors) {
      overlays.addAll(b.buildOverlays());
    }
    return overlays;
  }

  // ── Theme resolution ───────────────────────────────────────────────────

  /// Resolves the chart theme using the fallback chain:
  /// widget theme → context.components.chart → default.
  OiChartThemeData resolveTheme(
    BuildContext ctx, {
    OiChartThemeData? widgetTheme,
  }) {
    if (widgetTheme != null) return widgetTheme;
    // Try to get from component themes via OiTheme.
    try {
      final theme = OiTheme.maybeOf(ctx);
      if (theme?.components.chart != null) return theme!.components.chart!;
    } catch (_) {
      // Context may not have OiApp ancestor.
    }
    return OiChartThemeData();
  }

  // ── Pointer event forwarding ───────────────────────────────────────────

  /// Dispatches a [PointerEvent] to all attached behaviors.
  void dispatchPointerEvent(PointerEvent event) {
    for (final b in _attachedBehaviors) {
      switch (event) {
        case PointerDownEvent():
          b.onPointerDown(event);
        case PointerMoveEvent():
          b.onPointerMove(event);
        case PointerUpEvent():
          b.onPointerUp(event);
        case PointerHoverEvent():
          b.onPointerHover(event);
        case PointerScrollEvent():
          b.onPointerScroll(event);
        case PointerCancelEvent():
          b.onPointerCancel(event);
        default:
          break;
      }
    }
  }

  /// Wraps [child] in a [Listener] that forwards pointer events to behaviors.
  Widget wrapWithPointerListener(Widget child) {
    if (_attachedBehaviors.isEmpty) return child;
    return Listener(
      onPointerDown: (e) => dispatchPointerEvent(e),
      onPointerMove: (e) => dispatchPointerEvent(e),
      onPointerUp: (e) => dispatchPointerEvent(e),
      onPointerHover: (e) => dispatchPointerEvent(e),
      onPointerSignal: (e) {
        if (e is PointerScrollEvent) dispatchPointerEvent(e);
      },
      onPointerCancel: (e) => dispatchPointerEvent(e),
      child: child,
    );
  }
}

/// A no-op hit tester for charts that haven't set up hit testing yet.
class NoOpHitTester extends OiChartHitTester {
  @override
  OiChartHitResult? hitTest(Offset position, {double tolerance = 16}) => null;

  @override
  List<OiChartHitResult> hitTestAll(Offset position, {double tolerance = 16}) =>
      [];
}
