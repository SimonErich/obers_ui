import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/buttons/oi_button.dart';
import 'package:obers_ui/src/components/display/oi_empty_state.dart';
import 'package:obers_ui/src/components/inputs/oi_text_input.dart';
import 'package:obers_ui/src/foundation/oi_responsive.dart';
import 'package:obers_ui/src/foundation/theme/oi_color_scheme.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/display/oi_label.dart';
import 'package:obers_ui/src/primitives/interaction/oi_tappable.dart';
import 'package:obers_ui/src/primitives/layout/oi_column.dart';
import 'package:obers_ui/src/primitives/layout/oi_container.dart';

// ── Data models ─────────────────────────────────────────────────────────────

/// The type of change in a changelog entry.
///
/// {@category Modules}
enum OiChangeType {
  /// A new feature.
  added,

  /// A modification to existing functionality.
  changed,

  /// A bug fix.
  fixed,

  /// A removed feature.
  removed,

  /// A security-related change.
  security,

  /// A deprecation notice.
  deprecated,
}

/// A single change entry within a version.
///
/// {@category Modules}
@immutable
class OiChangeEntry {
  /// Creates an [OiChangeEntry].
  const OiChangeEntry({required this.description, required this.type});

  /// The change description text.
  final String description;

  /// The type of change.
  final OiChangeType type;
}

/// A version entry in a changelog.
///
/// {@category Modules}
@immutable
class OiVersionEntry {
  /// Creates an [OiVersionEntry].
  const OiVersionEntry({
    required this.version,
    required this.changes,
    this.date,
    this.isLatest = false,
    this.summary,
  });

  /// The version string (e.g. "2.1.0").
  final String version;

  /// The list of changes in this version.
  final List<OiChangeEntry> changes;

  /// The release date.
  final DateTime? date;

  /// Whether this is the latest/current version.
  final bool isLatest;

  /// Optional summary text for the version.
  final String? summary;
}

// ── Month names for date formatting ─────────────────────────────────────────

const _monthNames = [
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

String _formatDate(DateTime date) {
  final month = _monthNames[date.month - 1];
  return '$month ${date.day}, ${date.year}';
}

// ── Main widget ─────────────────────────────────────────────────────────────

/// A version-grouped changelog / release notes viewer.
///
/// Displays a list of [OiVersionEntry] items grouped by version with
/// color-coded change type badges, optional search, and type filtering.
///
/// {@category Modules}
class OiChangelogView extends StatefulWidget {
  /// Creates an [OiChangelogView].
  const OiChangelogView({
    required this.versions,
    required this.label,
    this.onVersionTap,
    this.initiallyExpandedCount = 3,
    this.showSearch = true,
    this.showTypeFilters = true,
    this.maxWidth = 720,
    super.key,
  });

  /// The list of version entries to display, ordered newest first.
  final List<OiVersionEntry> versions;

  /// Accessibility label announced by screen readers.
  final String label;

  /// Called when the user taps a version header.
  final void Function(OiVersionEntry)? onVersionTap;

  /// How many versions to show initially before collapsing older ones.
  final int initiallyExpandedCount;

  /// Whether to show the search bar.
  final bool showSearch;

  /// Whether to show the change type filter chips.
  final bool showTypeFilters;

  /// Maximum width constraint for the changelog content.
  final double maxWidth;

  @override
  State<OiChangelogView> createState() => _OiChangelogViewState();
}

class _OiChangelogViewState extends State<OiChangelogView> {
  bool _showAll = false;
  String _searchQuery = '';
  final Set<OiChangeType> _activeFilters = {};
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  Color _colorForType(OiChangeType type, OiColorScheme colors) {
    return switch (type) {
      OiChangeType.added => colors.success.base,
      OiChangeType.changed => colors.info.base,
      OiChangeType.fixed => colors.warning.base,
      OiChangeType.removed => colors.error.base,
      OiChangeType.security => colors.error.base,
      OiChangeType.deprecated => colors.warning.base,
    };
  }

  String _labelForType(OiChangeType type) {
    return switch (type) {
      OiChangeType.added => 'Added',
      OiChangeType.changed => 'Changed',
      OiChangeType.fixed => 'Fixed',
      OiChangeType.removed => 'Removed',
      OiChangeType.security => 'Security',
      OiChangeType.deprecated => 'Deprecated',
    };
  }

  // ---------------------------------------------------------------------------
  // Filtering
  // ---------------------------------------------------------------------------

  List<OiVersionEntry> get _filteredVersions {
    final query = _searchQuery.toLowerCase();

    return widget.versions
        .map((version) {
          var changes = version.changes;

          // Apply type filter.
          if (_activeFilters.isNotEmpty) {
            changes = changes
                .where((c) => _activeFilters.contains(c.type))
                .toList();
          }

          // Apply search filter.
          if (query.isNotEmpty) {
            changes = changes
                .where((c) => c.description.toLowerCase().contains(query))
                .toList();
          }

          if (changes.isEmpty) return null;

          return OiVersionEntry(
            version: version.version,
            changes: changes,
            date: version.date,
            isLatest: version.isLatest,
            summary: version.summary,
          );
        })
        .whereType<OiVersionEntry>()
        .toList();
  }

  // ---------------------------------------------------------------------------
  // Build: search
  // ---------------------------------------------------------------------------

  Widget _buildSearch(BuildContext context) {
    return OiTextInput.search(
      controller: _searchController,
      onChanged: (value) {
        setState(() {
          _searchQuery = value;
        });
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Build: type filter chips
  // ---------------------------------------------------------------------------

  Widget _buildTypeFilters(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;

    return Wrap(
      spacing: spacing.xs,
      runSpacing: spacing.xs,
      children: [
        for (final type in OiChangeType.values)
          _buildFilterChip(context, type, colors),
      ],
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    OiChangeType type,
    OiColorScheme colors,
  ) {
    final spacing = context.spacing;
    final isActive = _activeFilters.contains(type);
    final badgeColor = _colorForType(type, colors);

    return OiTappable(
      semanticLabel: '${_labelForType(type)} filter',
      onTap: () {
        setState(() {
          if (isActive) {
            _activeFilters.remove(type);
          } else {
            _activeFilters.add(type);
          }
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: spacing.sm,
          vertical: spacing.xs,
        ),
        decoration: BoxDecoration(
          color: isActive
              ? badgeColor.withValues(alpha: 0.2)
              : colors.surfaceSubtle,
          borderRadius: context.radius.sm,
          border: Border.all(
            color: isActive ? badgeColor : colors.borderSubtle,
          ),
        ),
        child: OiLabel.caption(
          _labelForType(type),
          color: isActive ? badgeColor : colors.textSubtle,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Build: version list
  // ---------------------------------------------------------------------------

  Widget _buildVersionList(BuildContext context) {
    final filtered = _filteredVersions;
    final spacing = context.spacing;
    final breakpoint = context.breakpoint;

    if (filtered.isEmpty) {
      return const OiEmptyState(
        title: 'No matching changes',
        description: 'Try adjusting your search or filters.',
      );
    }

    final displayCount = _showAll
        ? filtered.length
        : filtered.length.clamp(0, widget.initiallyExpandedCount);
    final remaining = filtered.length - displayCount;

    return OiColumn(
      breakpoint: breakpoint,
      gap: OiResponsive(spacing.md),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < displayCount; i++)
          _buildVersionEntry(context, filtered[i]),
        if (remaining > 0 && !_showAll)
          OiButton.ghost(
            label: 'Show older versions ($remaining more)',
            fullWidth: true,
            onTap: () {
              setState(() {
                _showAll = true;
              });
            },
          ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Build: version entry
  // ---------------------------------------------------------------------------

  Widget _buildVersionEntry(BuildContext context, OiVersionEntry version) {
    final colors = context.colors;
    final spacing = context.spacing;
    final breakpoint = context.breakpoint;

    // Group changes by type.
    final grouped = <OiChangeType, List<OiChangeEntry>>{};
    for (final change in version.changes) {
      grouped.putIfAbsent(change.type, () => []).add(change);
    }

    return OiTappable(
      semanticLabel: 'Version ${version.version}',
      onTap: widget.onVersionTap != null
          ? () => widget.onVersionTap!(version)
          : null,
      child: Container(
        padding: EdgeInsets.all(spacing.md),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: context.radius.md,
          border: Border.all(color: colors.borderSubtle),
        ),
        child: OiColumn(
          breakpoint: breakpoint,
          gap: OiResponsive(spacing.sm),
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Version header.
            Wrap(
              spacing: spacing.sm,
              runSpacing: spacing.xs,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                OiLabel.h3(version.version),
                if (version.isLatest)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: spacing.sm,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: colors.primary.base.withValues(alpha: 0.15),
                      borderRadius: context.radius.sm,
                    ),
                    child: OiLabel.caption('NEW', color: colors.primary.base),
                  ),
                if (version.date != null)
                  OiLabel.small(
                    _formatDate(version.date!),
                    color: colors.textMuted,
                  ),
              ],
            ),

            // Summary.
            if (version.summary != null)
              OiLabel.body(version.summary!, color: colors.textSubtle),

            // Grouped changes.
            for (final type in OiChangeType.values)
              if (grouped.containsKey(type))
                _buildChangeGroup(context, type, grouped[type]!),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Build: change group (by type)
  // ---------------------------------------------------------------------------

  Widget _buildChangeGroup(
    BuildContext context,
    OiChangeType type,
    List<OiChangeEntry> entries,
  ) {
    final spacing = context.spacing;
    final breakpoint = context.breakpoint;

    return OiColumn(
      breakpoint: breakpoint,
      gap: OiResponsive(spacing.xs),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final entry in entries) _buildChangeEntry(context, entry),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Build: single change entry
  // ---------------------------------------------------------------------------

  Widget _buildChangeEntry(BuildContext context, OiChangeEntry entry) {
    final colors = context.colors;
    final spacing = context.spacing;
    final badgeColor = _colorForType(entry.type, colors);

    return Padding(
      padding: EdgeInsets.only(left: spacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: spacing.sm, vertical: 2),
            decoration: BoxDecoration(
              color: badgeColor.withValues(alpha: 0.15),
              borderRadius: context.radius.sm,
            ),
            child: OiLabel.caption(
              _labelForType(entry.type),
              color: badgeColor,
            ),
          ),
          SizedBox(width: spacing.sm),
          Expanded(child: OiLabel.body(entry.description)),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final breakpoint = context.breakpoint;

    return Semantics(
      label: widget.label,
      container: true,
      child: OiContainer(
        breakpoint: breakpoint,
        maxWidth: OiResponsive(widget.maxWidth),
        child: SingleChildScrollView(
          child: OiColumn(
            breakpoint: breakpoint,
            gap: OiResponsive(spacing.md),
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.showSearch) _buildSearch(context),
              if (widget.showTypeFilters) _buildTypeFilters(context),
              _buildVersionList(context),
            ],
          ),
        ),
      ),
    );
  }
}
