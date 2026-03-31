import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';

import 'package:obers_ui_example/data/mock_dashboard.dart';

/// Activity feed screen with category filter tabs and Feed/Timeline toggle.
class AdminActivityScreen extends StatefulWidget {
  const AdminActivityScreen({super.key});

  @override
  State<AdminActivityScreen> createState() => _AdminActivityScreenState();
}

class _AdminActivityScreenState extends State<AdminActivityScreen> {
  String? _activeCategory;
  int _selectedTab = 0;
  int _visibleCount = 5;

  List<OiActivityEvent> get _filteredEvents {
    final events = _activeCategory == null
        ? kActivityEvents
        : kActivityEvents.where((e) => e.category == _activeCategory).toList();
    return events;
  }

  List<OiTimelineEvent> _toTimelineEvents(List<OiActivityEvent> events) {
    return events.take(_visibleCount).map((e) {
      return OiTimelineEvent(
        timestamp: e.timestamp ?? DateTime.now(),
        title: e.title,
        description: e.description,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final categories =
        kActivityEvents
            .map((e) => e.category)
            .whereType<String>()
            .toSet()
            .toList()
          ..sort();

    final filteredEvents = _filteredEvents;
    final hasMore = _visibleCount < filteredEvents.length;

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: spacing.lg,
            vertical: spacing.sm,
          ),
          child: OiTabs(
            tabs: const [
              OiTabItem(label: 'Feed'),
              OiTabItem(label: 'Timeline'),
            ],
            selectedIndex: _selectedTab,
            onSelected: (index) => setState(() => _selectedTab = index),
          ),
        ),
        Expanded(
          child: _selectedTab == 0
              ? OiActivityFeed(
                  label: 'Recent activity',
                  events: filteredEvents,
                  categories: categories,
                  activeCategory: _activeCategory,
                  onCategoryChange: (cat) =>
                      setState(() => _activeCategory = cat),
                )
              : Column(
                  children: [
                    Expanded(
                      child: OiTimeline(
                        label: 'Activity timeline',
                        events: _toTimelineEvents(filteredEvents),
                        collapsible: true,
                      ),
                    ),
                    if (hasMore)
                      Padding(
                        padding: EdgeInsets.all(spacing.md),
                        child: OiButton.outline(
                          label: 'Load More',
                          fullWidth: false,
                          onTap: () {
                            setState(() {
                              _visibleCount += 5;
                            });
                          },
                        ),
                      ),
                  ],
                ),
        ),
      ],
    );
  }
}
