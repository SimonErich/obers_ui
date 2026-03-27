import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_charts/src/foundation/oi_chart_behavior.dart';
import 'package:obers_ui_charts/src/foundation/oi_chart_controller.dart';
import 'package:obers_ui_charts/src/foundation/oi_chart_viewport.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Tooltip trigger mode
// ─────────────────────────────────────────────────────────────────────────────

/// How the tooltip is activated.
///
/// {@category Foundation}
enum OiChartTooltipTrigger {
  /// Show tooltip on pointer hover (desktop/web).
  hover,

  /// Show tooltip on tap/touch (mobile).
  tap,

  /// Show tooltip on both hover and tap.
  both,
}

// ─────────────────────────────────────────────────────────────────────────────
// Tooltip anchor mode
// ─────────────────────────────────────────────────────────────────────────────

/// How the tooltip is positioned relative to data.
///
/// {@category Foundation}
enum OiChartTooltipAnchor {
  /// Tooltip follows the raw pointer/touch position.
  pointer,

  /// Tooltip snaps to the nearest data point.
  nearestPoint,

  /// Tooltip anchors to the x-axis position, showing all series at
  /// that x value.
  xAxis,
}

// ─────────────────────────────────────────────────────────────────────────────
// Tooltip entry model
// ─────────────────────────────────────────────────────────────────────────────

/// A single entry in a chart tooltip, representing one series' data at
/// the hovered position.
///
/// {@category Foundation}
@immutable
class OiChartTooltipEntry {
  /// Creates an [OiChartTooltipEntry].
  const OiChartTooltipEntry({
    required this.seriesLabel,
    required this.formattedX,
    required this.formattedY,
    this.pointLabel,
    this.color,
    this.ref,
  });

  /// The display label of the series (e.g. "Revenue").
  final String seriesLabel;

  /// The formatted x-axis value (e.g. "Jan 2025").
  final String formattedX;

  /// The formatted y-axis value (e.g. "$1,234").
  final String formattedY;

  /// An optional custom label for this specific data point.
  final String? pointLabel;

  /// The series color, used for the color swatch indicator.
  final Color? color;

  /// The data reference for this entry.
  final OiChartDataRef? ref;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OiChartTooltipEntry &&
          other.seriesLabel == seriesLabel &&
          other.formattedX == formattedX &&
          other.formattedY == formattedY &&
          other.pointLabel == pointLabel &&
          other.color == color &&
          other.ref == ref;

  @override
  int get hashCode =>
      Object.hash(seriesLabel, formattedX, formattedY, pointLabel, color, ref);

  @override
  String toString() =>
      'OiChartTooltipEntry(series: $seriesLabel, x: $formattedX, '
      'y: $formattedY)';
}

// ─────────────────────────────────────────────────────────────────────────────
// Tooltip model
// ─────────────────────────────────────────────────────────────────────────────

/// The data model provided to tooltip builders, containing all
/// information needed to render a tooltip.
///
/// {@category Foundation}
@immutable
class OiChartTooltipModel {
  /// Creates an [OiChartTooltipModel].
  const OiChartTooltipModel({
    required this.globalPosition,
    required this.entries,
    this.title,
    this.footer,
    this.anchorPosition,
  });

  /// The global (screen) position where the tooltip should appear.
  final Offset globalPosition;

  /// The list of tooltip entries, one per series at the hovered point.
  final List<OiChartTooltipEntry> entries;

  /// An optional title displayed at the top of the tooltip (e.g. the
  /// x-axis label shared by all entries).
  final String? title;

  /// An optional footer displayed at the bottom of the tooltip.
  final String? footer;

  /// The widget-local anchor position (e.g. data point position)
  /// that the tooltip is anchored to.
  final Offset? anchorPosition;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OiChartTooltipModel &&
          other.globalPosition == globalPosition &&
          other.title == title &&
          other.footer == footer &&
          other.anchorPosition == anchorPosition &&
          listEquals(other.entries, entries);

  @override
  int get hashCode => Object.hash(
    globalPosition,
    title,
    footer,
    anchorPosition,
    Object.hashAll(entries),
  );

  @override
  String toString() =>
      'OiChartTooltipModel(entries: ${entries.length}, '
      'title: $title, pos: $globalPosition)';
}

// ─────────────────────────────────────────────────────────────────────────────
// Tooltip configuration
// ─────────────────────────────────────────────────────────────────────────────

/// Builder for custom tooltip content.
typedef OiChartTooltipBuilder =
    Widget Function(BuildContext context, OiChartTooltipModel model);

/// Configuration for chart tooltip behavior.
///
/// Controls how and when tooltips are shown, their trigger mode,
/// positioning, and timing.
///
/// {@category Foundation}
@immutable
class OiChartTooltipConfig {
  /// Creates an [OiChartTooltipConfig].
  const OiChartTooltipConfig({
    this.enabled = true,
    this.trigger = OiChartTooltipTrigger.both,
    this.anchor = OiChartTooltipAnchor.nearestPoint,
    this.showDelay = const Duration(milliseconds: 200),
    this.hideDelay = const Duration(milliseconds: 100),
    this.builder,
    this.hitTestTolerance = 24.0,
  });

  /// Whether the tooltip is enabled.
  final bool enabled;

  /// How the tooltip is activated.
  final OiChartTooltipTrigger trigger;

  /// How the tooltip is positioned relative to data.
  final OiChartTooltipAnchor anchor;

  /// Delay before showing the tooltip after the trigger activates.
  final Duration showDelay;

  /// Delay before hiding the tooltip after the trigger deactivates.
  final Duration hideDelay;

  /// Optional custom builder for tooltip content.
  ///
  /// When null, a default tooltip widget is rendered.
  final OiChartTooltipBuilder? builder;

  /// The hit test tolerance in logical pixels for finding nearby data
  /// points.
  final double hitTestTolerance;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OiChartTooltipConfig &&
          other.enabled == enabled &&
          other.trigger == trigger &&
          other.anchor == anchor &&
          other.showDelay == showDelay &&
          other.hideDelay == hideDelay &&
          other.hitTestTolerance == hitTestTolerance;

  @override
  int get hashCode => Object.hash(
    enabled,
    trigger,
    anchor,
    showDelay,
    hideDelay,
    hitTestTolerance,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Entry resolver
// ─────────────────────────────────────────────────────────────────────────────

/// Resolves hit results into tooltip entries.
///
/// Chart widgets implement this to convert [OiChartHitResult] values
/// into formatted [OiChartTooltipEntry] objects with series labels,
/// formatted values, and colors.
///
/// {@category Foundation}
// ignore: one_member_abstracts — intentional named interface; chart widgets implement this contract
abstract interface class OiChartTooltipEntryResolver {
  /// Resolves a list of hit results into tooltip entries.
  ///
  /// The [hits] are the data points near the pointer. The
  /// [pointerPosition] is the widget-local position of the pointer.
  ///
  /// Returns a list of tooltip entries, optionally with a shared title
  /// and footer wrapped in an [OiChartTooltipModel].
  OiChartTooltipModel resolve({
    required List<OiChartHitResult> hits,
    required Offset pointerPosition,
    required Offset globalPosition,
    required OiChartViewport viewport,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Tooltip behavior (OiChartBehavior subclass)
// ─────────────────────────────────────────────────────────────────────────────

/// A chart behavior that shows tooltips on hover or tap.
///
/// This behavior integrates with the obers_ui [OiOverlays] system
/// to render tooltips at the appropriate z-order level, ensuring
/// they participate in the same overlay stack as dialogs, sheets, and
/// other overlays.
///
/// ## Usage
///
/// ```dart
/// OiLineChart(
///   behaviors: [
///     OiChartTooltipBehavior(
///       config: OiChartTooltipConfig(
///         trigger: OiChartTooltipTrigger.hover,
///         anchor: OiChartTooltipAnchor.nearestPoint,
///       ),
///       resolver: myResolver,
///     ),
///   ],
///   ...
/// )
/// ```
///
/// {@category Foundation}
class OiChartTooltipBehavior extends OiChartBehavior {
  /// Creates an [OiChartTooltipBehavior].
  OiChartTooltipBehavior({
    required this.resolver,
    this.config = const OiChartTooltipConfig(),
  });

  /// The tooltip configuration.
  final OiChartTooltipConfig config;

  /// Resolves hit results into tooltip entries.
  final OiChartTooltipEntryResolver resolver;

  OiOverlayHandle? _overlayHandle;
  Timer? _showTimer;
  Timer? _hideTimer;
  OiChartTooltipModel? _currentModel;

  /// The currently displayed tooltip model, or null if no tooltip is
  /// shown.
  OiChartTooltipModel? get currentModel => _currentModel;

  @override
  void detach() {
    _dismissTooltip();
    _showTimer?.cancel();
    _hideTimer?.cancel();
    _showTimer = null;
    _hideTimer = null;
    super.detach();
  }

  @override
  void onPointerHover(PointerHoverEvent event) {
    if (!config.enabled) return;
    if (config.trigger != OiChartTooltipTrigger.hover &&
        config.trigger != OiChartTooltipTrigger.both) {
      return;
    }

    final localPos = event.localPosition;
    if (!context.viewport.hitTestPlot(localPos)) {
      _scheduleHide();
      return;
    }

    _handlePointerAt(localPos, event.position);
  }

  @override
  void onPointerDown(PointerDownEvent event) {
    if (!config.enabled) return;
    if (config.trigger != OiChartTooltipTrigger.tap &&
        config.trigger != OiChartTooltipTrigger.both) {
      return;
    }

    final localPos = event.localPosition;
    if (!context.viewport.hitTestPlot(localPos)) {
      _scheduleHide();
      return;
    }

    _handlePointerAt(localPos, event.position);
  }

  @override
  void onPointerMove(PointerMoveEvent event) {
    if (!config.enabled) return;
    if (config.trigger == OiChartTooltipTrigger.tap) return;

    final localPos = event.localPosition;
    if (!context.viewport.hitTestPlot(localPos)) {
      _scheduleHide();
      return;
    }

    _handlePointerAt(localPos, event.position);
  }

  @override
  void onPointerCancel(PointerCancelEvent event) {
    _scheduleHide();
  }

  void _handlePointerAt(Offset localPosition, Offset globalPosition) {
    _hideTimer?.cancel();
    _hideTimer = null;

    final hits = context.hitTester.hitTestAll(
      localPosition,
      tolerance: config.hitTestTolerance,
    );

    if (hits.isEmpty) {
      _scheduleHide();
      return;
    }

    final model = resolver.resolve(
      hits: hits,
      pointerPosition: localPosition,
      globalPosition: globalPosition,
      viewport: context.viewport,
    );

    if (_currentModel == model) return;
    _currentModel = model;

    _showTimer?.cancel();
    if (_overlayHandle != null) {
      // Update existing overlay immediately.
      _showTooltipOverlay(model);
    } else {
      // Schedule show with delay.
      _showTimer = Timer(config.showDelay, () {
        if (!isAttached) return;
        _showTooltipOverlay(model);
      });
    }
  }

  void _showTooltipOverlay(OiChartTooltipModel model) {
    if (!isAttached) return;

    final buildContext = context.buildContext;
    final service = OiOverlays.maybeOf(buildContext);

    if (service == null) return;

    // Dismiss previous overlay.
    _overlayHandle?.dismiss();

    final tooltipConfig = config;

    _overlayHandle = service.show(
      label: 'Chart tooltip',
      zOrder: OiOverlayZOrder.tooltip,
      dismissible: false,
      builder: (_) {
        return _OiChartTooltipOverlay(model: model, config: tooltipConfig);
      },
    );
  }

  void _scheduleHide() {
    _showTimer?.cancel();
    _showTimer = null;

    if (_overlayHandle == null) return;

    _hideTimer?.cancel();
    _hideTimer = Timer(config.hideDelay, _dismissTooltip);
  }

  void _dismissTooltip() {
    _overlayHandle?.dismiss();
    _overlayHandle = null;
    _currentModel = null;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Default tooltip overlay widget
// ─────────────────────────────────────────────────────────────────────────────

class _OiChartTooltipOverlay extends StatelessWidget {
  const _OiChartTooltipOverlay({required this.model, required this.config});

  final OiChartTooltipModel model;
  final OiChartTooltipConfig config;

  @override
  Widget build(BuildContext context) {
    final Widget content;

    if (config.builder != null) {
      content = config.builder!(context, model);
    } else {
      content = _DefaultTooltipContent(model: model);
    }

    // Position the tooltip near the global position with a small offset.
    const offset = Offset(12, 12);
    final pos = model.globalPosition + offset;

    return Positioned(
      left: pos.dx,
      top: pos.dy,
      child: IgnorePointer(child: content),
    );
  }
}

class _DefaultTooltipContent extends StatelessWidget {
  const _DefaultTooltipContent({required this.model});

  final OiChartTooltipModel model;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 240),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xF0222222),
        borderRadius: BorderRadius.circular(6),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (model.title != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: OiLabel.small(
                model.title!,
                color: const Color(0xFFCCCCCC),
              ),
            ),
          for (final entry in model.entries)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 1),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (entry.color != null) ...[
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: entry.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                  ],
                  OiLabel.caption(
                    '${entry.seriesLabel}: ',
                    color: const Color(0xFFAAAAAA),
                  ),
                  OiLabel.caption(
                    entry.pointLabel ?? entry.formattedY,
                    color: const Color(0xFFFFFFFF),
                  ),
                ],
              ),
            ),
          if (model.footer != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: OiLabel.caption(
                model.footer!,
                color: const Color(0xFF999999),
              ),
            ),
        ],
      ),
    );
  }
}
