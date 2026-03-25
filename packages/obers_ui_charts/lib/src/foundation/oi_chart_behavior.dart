import 'package:flutter/gestures.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';

import 'package:obers_ui_charts/src/foundation/oi_chart_accessibility_bridge.dart';
import 'package:obers_ui_charts/src/foundation/oi_chart_controller.dart';
import 'package:obers_ui_charts/src/foundation/oi_chart_hit_tester.dart';
import 'package:obers_ui_charts/src/foundation/oi_chart_sync_coordinator.dart';
import 'package:obers_ui_charts/src/foundation/oi_chart_viewport.dart';

/// The context provided to each [OiChartBehavior] when it is attached.
///
/// This gives the behavior access to all chart subsystems it may need:
/// the Flutter [BuildContext], the [OiChartController] for state,
/// the [OiChartViewport] for geometry, the [OiChartHitTester] for
/// pointer-to-data mapping, the [OiChartThemeData] for visual tokens,
/// the [OiChartSyncCoordinator] for cross-chart synchronisation, and
/// the [OiChartAccessibilityBridge] for assistive-technology support.
///
/// {@category Foundation}
@immutable
class OiChartBehaviorContext {
  /// Creates an [OiChartBehaviorContext].
  const OiChartBehaviorContext({
    required this.buildContext,
    required this.controller,
    required this.viewport,
    required this.hitTester,
    required this.theme,
    this.syncCoordinator,
    this.accessibilityBridge,
  });

  /// The Flutter [BuildContext] of the chart widget.
  final BuildContext buildContext;

  /// The chart controller that manages selection and hover state.
  final OiChartController controller;

  /// The current chart viewport geometry.
  final OiChartViewport viewport;

  /// The hit tester for resolving pointer positions to data elements.
  final OiChartHitTester hitTester;

  /// The current chart theme data.
  final OiChartThemeData theme;

  /// An optional sync coordinator for linked charts.
  ///
  /// When null, the chart is not part of a sync group.
  final OiChartSyncCoordinator? syncCoordinator;

  /// An optional accessibility bridge.
  ///
  /// When null, accessibility features are handled by the chart widget
  /// itself rather than through behaviour delegation.
  final OiChartAccessibilityBridge? accessibilityBridge;
}

/// Abstract base class for composable chart interaction behaviors.
///
/// Behaviors are the primary mechanism for adding interaction to charts.
/// Each behavior encapsulates a single concern (e.g. tooltip on hover,
/// selection on tap, zoom on scroll) and can be composed together by
/// passing a list of behaviors to a chart widget.
///
/// ## Lifecycle
///
/// When a chart mounts or updates, it calls [attach] with an
/// [OiChartBehaviorContext] providing access to all chart subsystems.
/// When the chart unmounts or the behavior is removed, [detach] is
/// called to clean up resources.
///
/// ## Event Handlers
///
/// Behaviors can optionally handle:
/// - **Pointer events**: [onPointerDown], [onPointerMove], [onPointerUp],
///   [onPointerHover], [onPointerScroll], [onPointerCancel]
/// - **Key events**: [onKeyEvent]
/// - **State changes**: [onSelectionChanged], [onViewportChanged]
///
/// All handlers are no-ops by default. Override only the ones you need.
///
/// ## Example
///
/// ```dart
/// class TooltipBehavior extends OiChartBehavior {
///   @override
///   void onPointerHover(PointerHoverEvent event) {
///     final hit = context.hitTester.hitTest(event.localPosition);
///     if (hit != null) {
///       context.controller.hover(hit.ref);
///     } else {
///       context.controller.hover(null);
///     }
///   }
/// }
/// ```
///
/// {@category Foundation}
abstract class OiChartBehavior {
  OiChartBehaviorContext? _context;

  /// The current behavior context, available after [attach] and before
  /// [detach].
  ///
  /// Throws [StateError] if accessed when not attached.
  @protected
  OiChartBehaviorContext get context {
    final ctx = _context;
    if (ctx == null) {
      throw StateError(
        'OiChartBehavior.context accessed before attach() or after detach().',
      );
    }
    return ctx;
  }

  /// Whether this behavior is currently attached to a chart.
  bool get isAttached => _context != null;

  /// Called when this behavior is added to a chart.
  ///
  /// Override to set up listeners, timers, or other resources. Always
  /// call `super.attach(context)` first.
  @mustCallSuper
  // Lifecycle method, not a property setter.
  // ignore: use_setters_to_change_properties
  void attach(OiChartBehaviorContext context) {
    _context = context;
  }

  /// Called when this behavior is removed from a chart or the chart
  /// is disposed.
  ///
  /// Override to clean up any resources acquired in [attach]. Always
  /// call `super.detach()` last.
  @mustCallSuper
  void detach() {
    _context = null;
  }

  // ── Pointer events ──────────────────────────────────────────────────

  /// Called when a pointer contacts the chart surface.
  void onPointerDown(PointerDownEvent event) {}

  /// Called when a pointer that is in contact moves within the chart.
  void onPointerMove(PointerMoveEvent event) {}

  /// Called when a pointer is lifted from the chart surface.
  void onPointerUp(PointerUpEvent event) {}

  /// Called when a pointer hovers over the chart without pressing.
  void onPointerHover(PointerHoverEvent event) {}

  /// Called when a scroll event occurs over the chart.
  void onPointerScroll(PointerScrollEvent event) {}

  /// Called when a pointer interaction is cancelled.
  void onPointerCancel(PointerCancelEvent event) {}

  // ── Key events ──────────────────────────────────────────────────────

  /// Called when a keyboard event occurs while the chart has focus.
  ///
  /// Return `true` if the event was handled and should not propagate.
  bool onKeyEvent(KeyEvent event) => false;

  // ── State change events ─────────────────────────────────────────────

  /// Called when the chart's selection changes.
  void onSelectionChanged(Set<OiChartDataRef> selection) {}

  /// Called when the chart's viewport changes (e.g. zoom, pan, resize).
  void onViewportChanged(OiChartViewport viewport) {}

  // ── Overlay rendering ──────────────────────────────────────────────

  /// Returns overlay widgets this behavior wants rendered above the chart.
  ///
  /// Called by composites during build to collect tooltip, crosshair, and
  /// other overlay widgets from all attached behaviors.
  ///
  /// Override to provide custom overlays. Default returns empty list.
  List<Widget> buildOverlays() => const [];
}
