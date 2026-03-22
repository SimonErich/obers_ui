import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/shop/oi_order_status_badge.dart';
import 'package:obers_ui/src/composites/forms/oi_stepper.dart';
import 'package:obers_ui/src/composites/scheduling/oi_timeline.dart';
import 'package:obers_ui/src/foundation/oi_responsive.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/models/oi_order_data.dart';
import 'package:obers_ui/src/primitives/display/oi_label.dart';
import 'package:obers_ui/src/primitives/layout/oi_column.dart';

// Material Icons codepoints.
const IconData _kCheckIcon = IconData(0xe5ca, fontFamily: 'MaterialIcons');
const IconData _kCloseIcon = IconData(0xe5cd, fontFamily: 'MaterialIcons');
const IconData _kRefundIcon = IconData(0xe042, fontFamily: 'MaterialIcons');

/// The five happy-path order statuses in progression order.
const List<OiOrderStatus> _happyPathStatuses = [
  OiOrderStatus.pending,
  OiOrderStatus.confirmed,
  OiOrderStatus.processing,
  OiOrderStatus.shipped,
  OiOrderStatus.delivered,
];

/// A horizontal stepper showing order status progression with an optional
/// expandable timeline of order events.
///
/// Coverage: REQ-0013
///
/// Maps the 5 happy-path [OiOrderStatus] values (pending → confirmed →
/// processing → shipped → delivered) to stepper steps. Cancelled and refunded
/// are rendered as terminal states. An optional [timeline] of [OiOrderEvent]
/// entries can be shown below the stepper.
///
/// Composes [OiStepper], [OiTimeline], [OiColumn], [OiLabel].
///
/// {@category Composites}
class OiOrderTracker extends StatefulWidget {
  /// Creates an [OiOrderTracker].
  const OiOrderTracker({
    required this.currentStatus,
    required this.label,
    this.timeline,
    this.showTimeline = false,
    this.statusLabels,
    super.key,
  });

  /// Creates a compact [OiOrderTracker] from an [OiOrderData], extracting
  /// status and timeline automatically. Shows only the stepper without
  /// the expanded timeline section.
  OiOrderTracker.compact({
    required OiOrderData order,
    this.label = 'Order tracker',
    this.statusLabels,
    super.key,
  }) : currentStatus = order.status,
       timeline = order.timeline,
       showTimeline = false;

  /// The current order status to highlight in the stepper.
  final OiOrderStatus currentStatus;

  /// Accessibility label announced by screen readers.
  final String label;

  /// Optional chronological list of order events for the timeline section.
  final List<OiOrderEvent>? timeline;

  /// Whether to show the timeline section below the stepper.
  ///
  /// Defaults to `false`.
  final bool showTimeline;

  /// Custom labels for each order status. When not provided, default labels
  /// are used (e.g. "Pending", "Confirmed", etc.).
  final Map<OiOrderStatus, String>? statusLabels;

  @override
  State<OiOrderTracker> createState() => _OiOrderTrackerState();
}

class _OiOrderTrackerState extends State<OiOrderTracker> {
  bool _timelineExpanded = true;

  // ---------------------------------------------------------------------------
  // Status helpers
  // ---------------------------------------------------------------------------

  Map<OiOrderStatus, String> _defaultStatusLabels() {
    return const {
      OiOrderStatus.pending: 'Pending',
      OiOrderStatus.confirmed: 'Confirmed',
      OiOrderStatus.processing: 'Processing',
      OiOrderStatus.shipped: 'Shipped',
      OiOrderStatus.delivered: 'Delivered',
      OiOrderStatus.cancelled: 'Cancelled',
      OiOrderStatus.refunded: 'Refunded',
    };
  }

  String _labelForStatus(OiOrderStatus status) {
    if (widget.statusLabels != null &&
        widget.statusLabels!.containsKey(status)) {
      return widget.statusLabels![status]!;
    }
    return _defaultStatusLabels()[status] ?? status.name;
  }

  int _statusIndex(OiOrderStatus status) {
    final idx = _happyPathStatuses.indexOf(status);
    return idx >= 0 ? idx : -1;
  }

  bool get _isTerminal =>
      widget.currentStatus == OiOrderStatus.cancelled ||
      widget.currentStatus == OiOrderStatus.refunded;

  // ---------------------------------------------------------------------------
  // Terminal status
  // ---------------------------------------------------------------------------

  /// Returns an [OiOrderStatusBadge] for terminal statuses (cancelled/refunded).
  Widget _buildTerminalStatus(OiOrderStatus status) {
    return OiOrderStatusBadge(status: status, label: _labelForStatus(status));
  }

  // ---------------------------------------------------------------------------
  // Stepper
  // ---------------------------------------------------------------------------

  Widget _buildStepper(BuildContext context) {
    final currentIdx = _statusIndex(widget.currentStatus);

    // Build completed steps set (all steps before current).
    final completedSteps = <int>{};
    final errorSteps = <int>{};

    if (_isTerminal) {
      // For terminal states, mark all steps up to the last known progress
      // and show the terminal indicator separately.
      // No steps are completed — we show the terminal label below.
    } else if (currentIdx >= 0) {
      for (var i = 0; i < currentIdx; i++) {
        completedSteps.add(i);
      }
    }

    final stepLabels = _happyPathStatuses.map(_labelForStatus).toList();

    Widget stepper = OiStepper(
      totalSteps: _happyPathStatuses.length,
      currentStep: _isTerminal
          ? _happyPathStatuses.length - 1
          : (currentIdx >= 0 ? currentIdx : 0),
      stepLabels: stepLabels,
      completedSteps: completedSteps,
      errorSteps: errorSteps,
    );

    // For terminal states, delegate to OiOrderStatusBadge.
    if (_isTerminal) {
      stepper = OiColumn(
        breakpoint: context.breakpoint,
        gap: OiResponsive(context.spacing.sm),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          stepper,
          Center(child: _buildTerminalStatus(widget.currentStatus)),
        ],
      );
    }

    return stepper;
  }

  // ---------------------------------------------------------------------------
  // Timeline
  // ---------------------------------------------------------------------------

  Widget _buildTimeline(BuildContext context) {
    final sp = context.spacing;
    final colors = context.colors;
    final events = widget.timeline ?? [];

    if (events.isEmpty) {
      return const SizedBox.shrink();
    }

    // Convert OiOrderEvent to OiTimelineEvent.
    final timelineEvents = events.map((e) {
      Color? dotColor;
      IconData? icon;

      switch (e.status) {
        case OiOrderStatus.delivered:
          dotColor = colors.success.base;
          icon = _kCheckIcon;
        case OiOrderStatus.cancelled:
          dotColor = colors.error.base;
          icon = _kCloseIcon;
        case OiOrderStatus.refunded:
          dotColor = colors.textMuted;
          icon = _kRefundIcon;
        default:
          dotColor = colors.primary.base;
      }

      return OiTimelineEvent(
        timestamp: e.timestamp,
        title: e.title,
        description: e.description,
        color: dotColor,
        icon: icon,
      );
    }).toList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            setState(() {
              _timelineExpanded = !_timelineExpanded;
            });
          },
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: sp.sm),
            child: Row(
              children: [
                Text(
                  _timelineExpanded ? '\u25BC' : '\u25B6',
                  style: TextStyle(fontSize: 10, color: colors.textMuted),
                ),
                const SizedBox(width: 8),
                OiLabel.bodyStrong('Order Timeline'),
              ],
            ),
          ),
        ),
        if (_timelineExpanded)
          SizedBox(
            height: events.length * 100.0,
            child: OiTimeline(events: timelineEvents, label: 'Order timeline'),
          ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final sp = context.spacing;
    final breakpoint = context.breakpoint;
    final hasTimeline =
        widget.showTimeline &&
        widget.timeline != null &&
        widget.timeline!.isNotEmpty;

    return Semantics(
      label: widget.label,
      child: OiColumn(
        breakpoint: breakpoint,
        gap: OiResponsive(sp.md),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildStepper(context),
          if (hasTimeline) _buildTimeline(context),
        ],
      ),
    );
  }
}
