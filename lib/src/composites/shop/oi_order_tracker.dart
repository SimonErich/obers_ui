import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/navigation/oi_accordion.dart';
import 'package:obers_ui/src/components/shop/oi_order_status_badge.dart';
import 'package:obers_ui/src/composites/forms/oi_stepper.dart';
import 'package:obers_ui/src/foundation/oi_responsive.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/models/oi_order_data.dart';
import 'package:obers_ui/src/primitives/display/oi_label.dart';
import 'package:obers_ui/src/primitives/layout/oi_column.dart';

/// The five happy-path order statuses in progression order.
const List<OiOrderStatus> _happyPathStatuses = [
  OiOrderStatus.pending,
  OiOrderStatus.confirmed,
  OiOrderStatus.processing,
  OiOrderStatus.shipped,
  OiOrderStatus.delivered,
];

/// Month abbreviations for timestamp formatting.
const List<String> _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

/// A visual order status tracker showing progression through statuses as a
/// horizontal stepper with an optional detailed timeline.
///
/// Coverage: REQ-0015, REQ-0016
///
/// Maps the 5 happy-path [OiOrderStatus] values (pending → confirmed →
/// processing → shipped → delivered) to stepper steps. All steps up to and
/// including the [currentStatus] are marked completed. Cancelled and refunded
/// are rendered as terminal states with an [OiOrderStatusBadge] below the
/// stepper.
///
/// When [showTimeline] is `true` and [timeline] is non-null and non-empty,
/// an [OiAccordion] titled "Order History" renders below the stepper with
/// events sorted newest-first.
///
/// On narrow breakpoints the stepper renders vertically.
///
/// Composes [OiStepper], [OiAccordion], [OiOrderStatusBadge], [OiColumn],
/// [OiLabel].
///
/// {@category Composites}
class OiOrderTracker extends StatelessWidget {
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
  /// are used via [OiOrderStatusBadge.defaultLabel].
  final Map<OiOrderStatus, String>? statusLabels;

  // ---------------------------------------------------------------------------
  // Status helpers
  // ---------------------------------------------------------------------------

  bool get _isTerminal =>
      currentStatus == OiOrderStatus.cancelled ||
      currentStatus == OiOrderStatus.refunded;

  int _statusIndex(OiOrderStatus status) {
    final idx = _happyPathStatuses.indexOf(status);
    return idx >= 0 ? idx : -1;
  }

  String _labelForStatus(OiOrderStatus status) {
    if (statusLabels != null && statusLabels!.containsKey(status)) {
      return statusLabels![status]!;
    }
    return OiOrderStatusBadge.defaultLabel(status);
  }

  /// Returns the theme [Color] for a timeline dot based on [status].
  Color _colorForStatus(BuildContext context, OiOrderStatus status) {
    final colors = context.colors;
    switch (status) {
      case OiOrderStatus.pending:
        return colors.warning.base;
      case OiOrderStatus.confirmed:
      case OiOrderStatus.processing:
        return colors.info.base;
      case OiOrderStatus.shipped:
        return colors.primary.base;
      case OiOrderStatus.delivered:
        return colors.success.base;
      case OiOrderStatus.cancelled:
        return colors.error.base;
      case OiOrderStatus.refunded:
        return colors.textMuted;
    }
  }

  int _completedIndex() => _statusIndex(currentStatus);

  // ---------------------------------------------------------------------------
  // Stepper
  // ---------------------------------------------------------------------------

  Widget _buildStepper(BuildContext context) {
    final currentIdx = _completedIndex();

    // All steps up to and including currentStatus are completed.
    final completedSteps = <int>{};
    if (!_isTerminal && currentIdx >= 0) {
      for (var i = 0; i <= currentIdx; i++) {
        completedSteps.add(i);
      }
    }

    final stepLabels = _happyPathStatuses.map(_labelForStatus).toList();
    final isNarrow = context.isCompact;

    Widget stepper = OiStepper(
      totalSteps: _happyPathStatuses.length,
      currentStep: _isTerminal
          ? _happyPathStatuses.length - 1
          : (currentIdx >= 0 ? currentIdx : 0),
      stepLabels: stepLabels,
      completedSteps: completedSteps,
      style: isNarrow ? OiStepperStyle.vertical : OiStepperStyle.horizontal,
    );

    if (_isTerminal) {
      stepper = OiColumn(
        breakpoint: context.breakpoint,
        gap: OiResponsive(context.spacing.sm),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          stepper,
          Center(child: _buildTerminalBadge()),
        ],
      );
    }

    return stepper;
  }

  Widget _buildTerminalBadge() {
    return OiOrderStatusBadge(
      status: currentStatus,
      label: _labelForStatus(currentStatus),
    );
  }

  // ---------------------------------------------------------------------------
  // Timeline (REQ-0016)
  // ---------------------------------------------------------------------------

  Widget _buildTimeline(BuildContext context) {
    final events = List<OiOrderEvent>.of(timeline!);
    if (events.isEmpty) return const SizedBox.shrink();

    // Sort newest-first.
    events.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return OiAccordion(
      sections: [
        OiAccordionSection(
          title: 'Order History',
          initiallyExpanded: true,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < events.length; i++)
                _buildTimelineEvent(
                  context,
                  events[i],
                  isFirst: i == 0,
                  isLast: i == events.length - 1,
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineEvent(
    BuildContext context,
    OiOrderEvent event, {
    required bool isFirst,
    required bool isLast,
  }) {
    final sp = context.spacing;
    final dotColor = _colorForStatus(context, event.status);
    final formattedTime = _formatTimestamp(event.timestamp);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Left: colored dot + vertical connector lines.
          SizedBox(
            width: 12,
            child: Column(
              children: [
                // Top connector to bridge gap from previous dot.
                Container(
                  width: 2,
                  height: sp.xs,
                  color: isFirst ? null : context.colors.textMuted,
                ),
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: dotColor,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: context.colors.textMuted,
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(width: sp.sm),
          // Right: timestamp, title, optional description.
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : sp.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  OiLabel.small(formattedTime),
                  OiLabel.bodyStrong(event.title),
                  if (event.description != null && event.description!.isNotEmpty)
                    OiLabel.small(event.description!),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Formats a [DateTime] as "Jan 1, 2024 10:00".
  static String _formatTimestamp(DateTime dt) {
    final month = _months[dt.month - 1];
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$month ${dt.day}, ${dt.year} $hour:$minute';
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final sp = context.spacing;
    final breakpoint = context.breakpoint;
    final hasTimeline =
        showTimeline && timeline != null && timeline!.isNotEmpty;

    return Semantics(
      label: label,
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
