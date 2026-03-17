import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/display/oi_empty_state.dart';
import 'package:obers_ui/src/components/display/oi_progress.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/interaction/oi_tappable.dart';

// ---------------------------------------------------------------------------
// Supporting types
// ---------------------------------------------------------------------------

/// An activity event displayed in an [OiActivityFeed].
///
/// Each event has a unique [key], a [title], and optional metadata such as
/// [description], [timestamp], [icon], [leading] widget, and [category].
@immutable
class OiActivityEvent {
  /// Creates an [OiActivityEvent].
  const OiActivityEvent({
    required this.key,
    required this.title,
    this.description,
    this.timestamp,
    this.icon,
    this.leading,
    this.category,
  });

  /// Unique identifier for this event.
  final Object key;

  /// Primary title text of the event.
  final String title;

  /// Optional longer description of the event.
  final String? description;

  /// Optional timestamp for when the event occurred.
  final DateTime? timestamp;

  /// Optional icon displayed in the timeline indicator.
  final IconData? icon;

  /// Optional custom leading widget replacing the default icon indicator.
  final Widget? leading;

  /// Optional category string used for filtering events.
  final String? category;
}

// ---------------------------------------------------------------------------
// OiActivityFeed
// ---------------------------------------------------------------------------

/// A timeline of activity events with filtering and infinite scroll.
///
/// Displays a chronological list of [OiActivityEvent] entries with an
/// optional category filter bar, timestamps, and infinite-scroll pagination.
///
/// {@category Modules}
class OiActivityFeed extends StatelessWidget {
  /// Creates an [OiActivityFeed].
  const OiActivityFeed({
    super.key,
    required this.events,
    required this.label,
    this.onEventTap,
    this.onLoadMore,
    this.moreAvailable = false,
    this.loading = false,
    this.emptyState,
    this.showTimestamps = true,
    this.categories,
    this.activeCategory,
    this.onCategoryChange,
  });

  /// The activity events to display.
  final List<OiActivityEvent> events;

  /// Accessible label for the feed.
  final String label;

  /// Called when the user taps an event.
  final ValueChanged<OiActivityEvent>? onEventTap;

  /// Called when the user scrolls near the end to load more events.
  final Future<void> Function()? onLoadMore;

  /// Whether more events are available to load.
  final bool moreAvailable;

  /// Whether the feed is currently loading data.
  final bool loading;

  /// Widget displayed when there are no events and loading is false.
  final Widget? emptyState;

  /// Whether to display timestamps alongside events.
  final bool showTimestamps;

  /// Available category filters.
  final List<String>? categories;

  /// The currently active category filter.
  final String? activeCategory;

  /// Called when the user selects a category filter.
  final ValueChanged<String>? onCategoryChange;

  // ── Helpers ──────────────────────────────────────────────────────────────

  String _formatTimestamp(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} $h:$m';
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      container: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (categories != null && categories!.isNotEmpty)
            _buildCategoryBar(context),
          Expanded(child: _buildBody(context)),
        ],
      ),
    );
  }

  Widget _buildCategoryBar(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (final category in categories!)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: OiTappable(
                  onTap: () => onCategoryChange?.call(category),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: activeCategory == category
                          ? colors.primary.base.withValues(alpha: 0.1)
                          : null,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: activeCategory == category
                            ? colors.primary.base
                            : colors.borderSubtle,
                      ),
                    ),
                    child: Text(
                      category,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: activeCategory == category
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: colors.text,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (loading && events.isEmpty) {
      return const Center(child: OiProgress(indeterminate: true));
    }

    if (events.isEmpty && !loading) {
      return emptyState ?? const OiEmptyState(title: 'No activity');
    }

    return _OiActivityFeedList(
      events: events,
      moreAvailable: moreAvailable,
      loading: loading,
      showTimestamps: showTimestamps,
      onEventTap: onEventTap,
      onLoadMore: onLoadMore,
      formatTimestamp: _formatTimestamp,
    );
  }
}

// ---------------------------------------------------------------------------
// Internal scrollable list with load-more support
// ---------------------------------------------------------------------------

class _OiActivityFeedList extends StatefulWidget {
  const _OiActivityFeedList({
    required this.events,
    required this.moreAvailable,
    required this.loading,
    required this.showTimestamps,
    required this.formatTimestamp,
    this.onEventTap,
    this.onLoadMore,
  });

  final List<OiActivityEvent> events;
  final bool moreAvailable;
  final bool loading;
  final bool showTimestamps;
  final ValueChanged<OiActivityEvent>? onEventTap;
  final Future<void> Function()? onLoadMore;
  final String Function(DateTime) formatTimestamp;

  @override
  State<_OiActivityFeedList> createState() => _OiActivityFeedListState();
}

class _OiActivityFeedListState extends State<_OiActivityFeedList> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!widget.moreAvailable || widget.loading) return;
    if (widget.onLoadMore == null) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (currentScroll >= maxScroll - 100) {
      widget.onLoadMore!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      itemCount: widget.events.length + (widget.moreAvailable ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= widget.events.length) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: OiProgress(indeterminate: true)),
          );
        }
        return _OiActivityEventTile(
          event: widget.events[index],
          showTimestamp: widget.showTimestamps,
          onTap: widget.onEventTap,
          formatTimestamp: widget.formatTimestamp,
          last: index == widget.events.length - 1,
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Single event tile
// ---------------------------------------------------------------------------

class _OiActivityEventTile extends StatelessWidget {
  const _OiActivityEventTile({
    required this.event,
    required this.showTimestamp,
    required this.formatTimestamp,
    required this.last,
    this.onTap,
  });

  final OiActivityEvent event;
  final bool showTimestamp;
  final ValueChanged<OiActivityEvent>? onTap;
  final String Function(DateTime) formatTimestamp;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final leading =
        event.leading ??
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: colors.primary.base.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(
              event.icon ?? const IconData(0xe5ca, fontFamily: 'MaterialIcons'),
              size: 16,
              color: colors.primary.base,
            ),
          ),
        );

    Widget tile = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              leading,
              if (!last)
                Container(width: 2, height: 24, color: colors.borderSubtle),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: colors.text,
                  ),
                ),
                if (event.description != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    event.description!,
                    style: TextStyle(fontSize: 13, color: colors.textMuted),
                  ),
                ],
                if (showTimestamp && event.timestamp != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    formatTimestamp(event.timestamp!),
                    style: TextStyle(fontSize: 11, color: colors.textMuted),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      tile = OiTappable(onTap: () => onTap!(event), child: tile);
    }

    return tile;
  }
}
