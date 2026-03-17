import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';

/// An event in the timeline.
///
/// Holds all the data needed to render a single entry in an [OiTimeline].
@immutable
class OiTimelineEvent {
  /// Creates an [OiTimelineEvent].
  const OiTimelineEvent({
    required this.timestamp,
    required this.title,
    this.description,
    this.content,
    this.icon,
    this.color,
  });

  /// The date/time at which this event occurred.
  final DateTime timestamp;

  /// The headline text for this event.
  final String title;

  /// An optional secondary description rendered below the [title].
  final String? description;

  /// An optional custom widget rendered inside the event card.
  final Widget? content;

  /// An optional icon displayed on the timeline dot.
  final IconData? icon;

  /// An optional color applied to the timeline dot and connector.
  final Color? color;
}

/// A vertical timeline showing events in chronological order.
///
/// Used for activity history, changelogs, project milestones.
/// Events are displayed as cards connected by a vertical line with dots.
///
/// {@category Composites}
class OiTimeline extends StatelessWidget {
  /// Creates an [OiTimeline].
  const OiTimeline({
    required this.events,
    required this.label,
    super.key,
    this.showTimestamps = true,
    this.alternating = false,
    this.collapsible = false,
    this.onEventTap,
  });

  /// The list of events to display.
  final List<OiTimelineEvent> events;

  /// An accessibility label describing this timeline.
  final String label;

  /// Whether to display timestamps alongside each event.
  final bool showTimestamps;

  /// Whether event cards alternate between left and right sides.
  final bool alternating;

  /// Whether event cards can be collapsed/expanded.
  final bool collapsible;

  /// Called when a user taps on an event.
  final ValueChanged<OiTimelineEvent>? onEventTap;

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return Semantics(label: label, child: const SizedBox.shrink());
    }

    return Semantics(
      label: label,
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];
          final leftAligned = alternating && index.isOdd;

          return _OiTimelineEntry(
            key: ValueKey('timeline_event_$index'),
            event: event,
            showTimestamp: showTimestamps,
            leftAligned: leftAligned,
            alternating: alternating,
            collapsible: collapsible,
            last: index == events.length - 1,
            onTap: onEventTap != null ? () => onEventTap!(event) : null,
          );
        },
      ),
    );
  }
}

/// A single entry in the [OiTimeline].
class _OiTimelineEntry extends StatefulWidget {
  const _OiTimelineEntry({
    required this.event,
    required this.showTimestamp,
    required this.leftAligned,
    required this.alternating,
    required this.collapsible,
    required this.last,
    super.key,
    this.onTap,
  });

  final OiTimelineEvent event;
  final bool showTimestamp;
  final bool leftAligned;
  final bool alternating;
  final bool collapsible;
  final bool last;
  final VoidCallback? onTap;

  @override
  State<_OiTimelineEntry> createState() => _OiTimelineEntryState();
}

class _OiTimelineEntryState extends State<_OiTimelineEntry> {
  bool _expanded = true;

  void _toggle() {
    if (widget.collapsible) {
      setState(() => _expanded = !_expanded);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final dotColor = widget.event.color ?? colors.primary.base;
    const dotSize = 16.0;
    const lineWidth = 2.0;
    const cardPadding = EdgeInsets.all(12);
    const gutter = 12.0;

    // Timeline dot with optional icon.
    final dot = Container(
      key: const ValueKey('timeline_dot'),
      width: dotSize,
      height: dotSize,
      decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
      child: widget.event.icon != null
          ? Center(
              child: Icon(
                widget.event.icon,
                size: dotSize * 0.6,
                color: colors.textOnPrimary,
              ),
            )
          : null,
    );

    // Vertical connector line.
    final line = widget.last
        ? const SizedBox(width: lineWidth)
        : Container(width: lineWidth, color: colors.borderSubtle);

    // Card content.
    Widget card = Container(
      padding: cardPadding,
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(color: colors.borderSubtle),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header row with optional collapse toggle.
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.collapsible ? _toggle : null,
            child: Row(
              children: [
                if (widget.collapsible)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Text(
                      _expanded ? '\u25BC' : '\u25B6',
                      style: TextStyle(fontSize: 10, color: colors.textMuted),
                    ),
                  ),
                Expanded(
                  child: Text(
                    widget.event.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: colors.text,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Collapsible body.
          if (_expanded) ...[
            if (widget.event.description != null) ...[
              const SizedBox(height: 4),
              Text(
                widget.event.description!,
                style: TextStyle(color: colors.textSubtle),
              ),
            ],
            if (widget.event.content != null) ...[
              const SizedBox(height: 8),
              widget.event.content!,
            ],
          ],
        ],
      ),
    );

    // Wrap the card in a tap detector.
    if (widget.onTap != null) {
      card = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: card,
      );
    }

    // Timestamp widget.
    Widget? timestamp;
    if (widget.showTimestamp) {
      timestamp = Text(
        _formatTimestamp(widget.event.timestamp),
        key: const ValueKey('timeline_timestamp'),
        style: TextStyle(fontSize: 12, color: colors.textMuted),
      );
    }

    // Layout: for alternating mode, swap sides.
    if (widget.alternating) {
      return IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left side.
            Expanded(
              child: widget.leftAligned
                  ? Padding(
                      padding: const EdgeInsets.only(right: gutter, bottom: 16),
                      child: card,
                    )
                  : (timestamp != null
                        ? Align(
                            alignment: Alignment.topRight,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                right: gutter,
                                top: 2,
                              ),
                              child: timestamp,
                            ),
                          )
                        : const SizedBox.shrink()),
            ),
            // Center column: dot + line.
            Column(
              children: [
                dot,
                Expanded(child: line),
              ],
            ),
            // Right side.
            Expanded(
              child: !widget.leftAligned
                  ? Padding(
                      padding: const EdgeInsets.only(left: gutter, bottom: 16),
                      child: card,
                    )
                  : (timestamp != null
                        ? Align(
                            alignment: Alignment.topLeft,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                left: gutter,
                                top: 2,
                              ),
                              child: timestamp,
                            ),
                          )
                        : const SizedBox.shrink()),
            ),
          ],
        ),
      );
    }

    // Default: single-column layout (dot on the left, card on the right).
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Dot + line column.
          Column(
            children: [
              dot,
              Expanded(child: line),
            ],
          ),
          const SizedBox(width: gutter),
          // Card + optional timestamp.
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (timestamp != null) ...[
                    timestamp,
                    const SizedBox(height: 4),
                  ],
                  card,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Formats a [DateTime] into a readable string.
  String _formatTimestamp(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    final h = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '$y-$m-$d $h:$min';
  }
}
