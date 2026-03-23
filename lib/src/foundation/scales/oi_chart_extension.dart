import 'package:flutter/widgets.dart';

import 'package:obers_ui/src/foundation/scales/oi_chart_controller.dart';
import 'package:obers_ui/src/foundation/scales/oi_chart_viewport.dart';
import 'package:obers_ui/src/foundation/theme/component_themes/oi_chart_theme_data.dart';

/// Context provided to [OiChartExtension] lifecycle hooks.
///
/// Gives extensions read-only access to the chart's subsystems so they
/// can react to layout, painting, hit-testing, and pointer events
/// without modifying core chart code.
///
/// {@category Foundation}
@immutable
class OiChartExtensionContext {
  /// Creates an [OiChartExtensionContext].
  const OiChartExtensionContext({
    required this.buildContext,
    required this.controller,
    required this.viewport,
    required this.theme,
    required this.chartSize,
    required this.plotArea,
  });

  /// The Flutter [BuildContext] of the chart widget.
  final BuildContext buildContext;

  /// The chart controller for reading selection and hover state.
  final OiChartController controller;

  /// The current chart viewport geometry.
  final OiChartViewport viewport;

  /// The current chart theme data.
  final OiChartThemeData theme;

  /// The total size of the chart widget.
  final Size chartSize;

  /// The rectangular area where data is plotted (excluding axis labels,
  /// legends, and padding).
  final Rect plotArea;
}

/// An event forwarded to [OiChartExtension.onEvent].
///
/// Wraps a pointer or gesture event with the chart-local position and
/// an optional [OiChartDataRef] if the event occurred over a data
/// element.
///
/// {@category Foundation}
@immutable
class OiChartEvent {
  /// Creates an [OiChartEvent].
  const OiChartEvent({
    required this.type,
    required this.localPosition,
    this.dataRef,
  });

  /// The kind of event (e.g. [OiChartEventType.tap],
  /// [OiChartEventType.hover]).
  final OiChartEventType type;

  /// The chart-local position where the event occurred.
  final Offset localPosition;

  /// The data element under the pointer, if any.
  final OiChartDataRef? dataRef;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OiChartEvent &&
        other.type == type &&
        other.localPosition == localPosition &&
        other.dataRef == dataRef;
  }

  @override
  int get hashCode => Object.hash(type, localPosition, dataRef);
}

/// Types of chart events forwarded to extensions.
///
/// {@category Foundation}
enum OiChartEventType {
  /// A tap/click on the chart surface.
  tap,

  /// A pointer hover over the chart surface.
  hover,

  /// A pointer exiting the chart surface.
  hoverExit,

  /// A long press on the chart surface.
  longPress,

  /// A scroll/zoom gesture on the chart surface.
  scroll,
}

/// Abstract base class for chart extensions.
///
/// Extensions provide lifecycle hooks that run at well-defined points
/// during a chart's layout, paint, hit-test, and event cycles. This
/// enables custom overlays, annotations, debug views, experimental
/// renderers, and custom statistical guides without modifying core
/// chart code.
///
/// ## Lifecycle Hooks
///
/// | Hook | Timing |
/// |------|--------|
/// | [beforeLayout] | Before the chart computes its layout |
/// | [afterLayout] | After layout is complete |
/// | [beforePaint] | Before the chart paints its data |
/// | [afterPaint] | After data painting is complete |
/// | [beforeHitTest] | Before a hit test is resolved |
/// | [afterHitTest] | After a hit test is resolved |
/// | [onEvent] | When a user interaction event occurs |
///
/// ## Example
///
/// ```dart
/// class DebugGridExtension extends OiChartExtension {
///   @override
///   String get id => 'debug-grid';
///
///   @override
///   void afterPaint(Canvas canvas, OiChartExtensionContext context) {
///     // Paint a debug grid overlay on top of the chart.
///     final paint = Paint()
///       ..color = const Color(0x20FF0000)
///       ..strokeWidth = 0.5;
///     for (var x = context.plotArea.left;
///         x <= context.plotArea.right;
///         x += 50) {
///       canvas.drawLine(
///         Offset(x, context.plotArea.top),
///         Offset(x, context.plotArea.bottom),
///         paint,
///       );
///     }
///   }
/// }
/// ```
///
/// {@category Foundation}
abstract class OiChartExtension {
  /// A unique identifier for this extension.
  ///
  /// Used to prevent duplicate registration and for debugging.
  String get id;

  /// Called before the chart computes its layout.
  ///
  /// Can be used to inject constraints or modify layout parameters.
  /// The [context] provides the chart's current state;
  /// [OiChartExtensionContext.chartSize] is the proposed size (may
  /// change after layout).
  void beforeLayout(OiChartExtensionContext context) {}

  /// Called after the chart has completed its layout.
  ///
  /// At this point [OiChartExtensionContext.plotArea] and
  /// [OiChartExtensionContext.chartSize] reflect the final layout.
  void afterLayout(OiChartExtensionContext context) {}

  /// Called before the chart paints its data series.
  ///
  /// Paint to the [canvas] to draw underneath the chart data (e.g.
  /// background highlights, reference bands).
  void beforePaint(Canvas canvas, OiChartExtensionContext context) {}

  /// Called after the chart has painted its data series.
  ///
  /// Paint to the [canvas] to draw on top of the chart data (e.g.
  /// annotations, trend lines, debug overlays).
  void afterPaint(Canvas canvas, OiChartExtensionContext context) {}

  /// Called before a hit test is resolved at [position].
  ///
  /// Return `true` to consume the hit test and prevent the chart from
  /// processing it. Return `false` to let the chart handle it normally.
  bool beforeHitTest(Offset position, OiChartExtensionContext context) {
    return false;
  }

  /// Called after a hit test has been resolved.
  ///
  /// [hitRef] is the resolved data reference, or `null` if no data
  /// element was hit.
  void afterHitTest(
    Offset position,
    OiChartDataRef? hitRef,
    OiChartExtensionContext context,
  ) {}

  /// Called when a user interaction event occurs on the chart.
  ///
  /// Receives an [OiChartEvent] describing the interaction type,
  /// position, and any associated data element.
  void onEvent(OiChartEvent event, OiChartExtensionContext context) {}
}
