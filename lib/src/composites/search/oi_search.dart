import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/input/oi_raw_input.dart';

/// A search result item.
///
/// Represents a single result returned by an [OiSearchSource].
///
/// {@category Composites}
@immutable
class OiSearchResult {
  /// Creates an [OiSearchResult].
  const OiSearchResult({
    required this.id,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.preview,
  });

  /// Unique identifier for this result.
  final String id;

  /// The primary display text.
  final String title;

  /// Optional secondary text shown below the title.
  final String? subtitle;

  /// Optional widget shown before the title (e.g. an icon or avatar).
  final Widget? leading;

  /// Optional widget shown after the title (e.g. a shortcut hint).
  final Widget? trailing;

  /// Optional preview widget shown in the preview pane.
  final Widget? preview;
}

/// A search data source.
///
/// Each source searches a specific category and returns [OiSearchResult] items.
///
/// {@category Composites}
@immutable
class OiSearchSource {
  /// Creates an [OiSearchSource].
  const OiSearchSource({
    required this.category,
    required this.icon,
    required this.search,
    this.maxResults = 5,
  });

  /// The display name for this category (e.g. "Files", "Commands").
  final String category;

  /// The icon displayed next to the category header.
  final IconData icon;

  /// The search function that returns results for a given query.
  final Future<List<OiSearchResult>> Function(String query) search;

  /// Maximum number of results to display from this source.
  final int maxResults;
}

/// A search filter option.
///
/// Allows the user to narrow results by selecting filter values.
///
/// {@category Composites}
@immutable
class OiSearchFilter {
  /// Creates an [OiSearchFilter].
  const OiSearchFilter({
    required this.label,
    required this.key, required this.options, this.icon,
  });

  /// The display label for this filter.
  final String label;

  /// Optional icon shown next to the filter label.
  final IconData? icon;

  /// The key used to identify this filter programmatically.
  final String key;

  /// The available options for this filter.
  final List<String> options;
}

/// A global search overlay with multiple search sources and categories.
///
/// Like Spotlight/Alfred -- searches across multiple data sources,
/// groups results by category, supports filters and a preview pane.
///
/// {@category Composites}
class OiSearch extends StatefulWidget {
  /// Creates an [OiSearch].
  const OiSearch({
    required this.sources, required this.label, super.key,
    this.onSelect,
    this.onDismiss,
    this.showRecent = true,
    this.maxRecent = 10,
    this.showPreview = true,
    this.debounce = const Duration(milliseconds: 200),
    this.filters,
  });

  /// The search sources to query.
  final List<OiSearchSource> sources;

  /// Called when the user selects a result.
  final ValueChanged<OiSearchResult>? onSelect;

  /// Called when the user dismisses the search overlay.
  final VoidCallback? onDismiss;

  /// Whether to show recent searches when the query is empty.
  final bool showRecent;

  /// Maximum number of recent items to keep.
  final int maxRecent;

  /// Whether to show the preview pane for the highlighted result.
  final bool showPreview;

  /// Debounce duration before triggering search after typing.
  final Duration debounce;

  /// Optional filters shown below the search input.
  final List<OiSearchFilter>? filters;

  /// Accessibility label for the search overlay.
  final String label;

  @override
  State<OiSearch> createState() => _OiSearchState();
}

class _OiSearchState extends State<OiSearch> {
  late TextEditingController _textController;
  late FocusNode _inputFocusNode;
  Timer? _debounceTimer;
  bool _loading = false;
  int _highlightedIndex = -1;
  Map<String, List<OiSearchResult>> _resultsByCategory = {};
  final List<OiSearchResult> _recentItems = [];
  final Map<String, String> _activeFilters = {};

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _inputFocusNode = FocusNode(onKeyEvent: _handleKeyEvent);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _inputFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _textController.dispose();
    _inputFocusNode.dispose();
    super.dispose();
  }

  // ── All results flattened ─────────────────────────────────────────────────

  List<OiSearchResult> get _allResults {
    final results = <OiSearchResult>[];
    for (final source in widget.sources) {
      final categoryResults = _resultsByCategory[source.category];
      if (categoryResults != null) {
        results.addAll(categoryResults.take(source.maxResults));
      }
    }
    return results;
  }

  // ── Search ────────────────────────────────────────────────────────────────

  void _onQueryChanged(String query) {
    _debounceTimer?.cancel();
    if (query.isEmpty) {
      setState(() {
        _resultsByCategory = {};
        _highlightedIndex = -1;
        _loading = false;
      });
      return;
    }
    _debounceTimer = Timer(widget.debounce, () => _performSearch(query));
  }

  Future<void> _performSearch(String query) async {
    setState(() => _loading = true);

    final results = <String, List<OiSearchResult>>{};
    try {
      final futures = widget.sources.map((source) async {
        final sourceResults = await source.search(query);
        return MapEntry(
          source.category,
          sourceResults.take(source.maxResults).toList(),
        );
      });

      final entries = await Future.wait(futures);
      for (final entry in entries) {
        results[entry.key] = entry.value;
      }
    } on Exception {
      // Silently handle search errors; results stay empty.
    }

    if (mounted) {
      setState(() {
        _resultsByCategory = results;
        _loading = false;
        _highlightedIndex = _allResults.isEmpty ? -1 : 0;
      });
    }
  }

  // ── Selection ─────────────────────────────────────────────────────────────

  void _selectResult(OiSearchResult result) {
    // Track in recents.
    _recentItems
      ..removeWhere((r) => r.id == result.id)
      ..insert(0, result);
    if (_recentItems.length > widget.maxRecent) {
      _recentItems.removeRange(widget.maxRecent, _recentItems.length);
    }

    widget.onSelect?.call(result);
  }

  // ── Keyboard ──────────────────────────────────────────────────────────────

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }

    final results = _allResults;

    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      setState(() {
        _highlightedIndex = (_highlightedIndex + 1).clamp(
          0,
          results.length - 1,
        );
      });
      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      setState(() {
        _highlightedIndex = (_highlightedIndex - 1).clamp(
          0,
          results.length - 1,
        );
      });
      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.enter) {
      if (_highlightedIndex >= 0 && _highlightedIndex < results.length) {
        _selectResult(results[_highlightedIndex]);
      }
      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.escape) {
      widget.onDismiss?.call();
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  // ── Filter chips ──────────────────────────────────────────────────────────

  Widget _buildFilters(BuildContext context) {
    if (widget.filters == null || widget.filters!.isEmpty) {
      return const SizedBox.shrink();
    }

    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Wrap(
        spacing: 8,
        children: widget.filters!.map((filter) {
          final active = _activeFilters[filter.key];
          return GestureDetector(
            onTap: () {
              setState(() {
                if (active != null) {
                  _activeFilters.remove(filter.key);
                } else if (filter.options.isNotEmpty) {
                  _activeFilters[filter.key] = filter.options.first;
                }
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: active != null
                    ? colors.primary.base.withValues(alpha: 0.1)
                    : colors.surfaceSubtle,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: active != null
                      ? colors.primary.base
                      : colors.borderSubtle,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (filter.icon != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Icon(filter.icon, size: 14, color: colors.text),
                    ),
                  Text(
                    active ?? filter.label,
                    style: TextStyle(fontSize: 12, color: colors.text),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final allResults = _allResults;
    final showEmpty = _textController.text.isEmpty;
    final highlightedResult =
        _highlightedIndex >= 0 && _highlightedIndex < allResults.length
        ? allResults[_highlightedIndex]
        : null;

    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: widget.label,
      child: Container(
        width: widget.showPreview ? 700 : 480,
        constraints: const BoxConstraints(maxHeight: 480),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: colors.overlay,
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Search input
            Padding(
              padding: const EdgeInsets.all(12),
              child: OiRawInput(
                controller: _textController,
                focusNode: _inputFocusNode,
                placeholder: 'Search\u2026',
                onChanged: _onQueryChanged,
                leading: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Icon(
                    const IconData(0xe8b6, fontFamily: 'MaterialIcons'),
                    size: 20,
                    color: colors.textMuted,
                  ),
                ),
              ),
            ),
            // Filters
            _buildFilters(context),
            // Content area
            Flexible(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Results list
                  Expanded(
                    child: _buildResultsList(context, allResults, showEmpty),
                  ),
                  // Preview pane
                  if (widget.showPreview && highlightedResult?.preview != null)
                    Container(
                      width: 260,
                      decoration: BoxDecoration(
                        border: Border(
                          left: BorderSide(color: colors.borderSubtle),
                        ),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: highlightedResult!.preview,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsList(
    BuildContext context,
    List<OiSearchResult> allResults,
    bool showEmpty,
  ) {
    final colors = context.colors;

    if (_loading) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Text(
            'Searching\u2026',
            style: TextStyle(color: colors.textMuted, fontSize: 14),
          ),
        ),
      );
    }

    if (showEmpty) {
      if (widget.showRecent && _recentItems.isNotEmpty) {
        return _buildCategorySection(
          context,
          'Recent',
          const IconData(0xe889, fontFamily: 'MaterialIcons'),
          _recentItems,
          allResults,
        );
      }
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Text(
            'Type to search',
            style: TextStyle(color: colors.textMuted, fontSize: 14),
          ),
        ),
      );
    }

    if (allResults.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Text(
            'No results found',
            style: TextStyle(color: colors.textMuted, fontSize: 14),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final source in widget.sources)
            if (_resultsByCategory.containsKey(source.category) &&
                _resultsByCategory[source.category]!.isNotEmpty)
              _buildCategorySection(
                context,
                source.category,
                source.icon,
                _resultsByCategory[source.category]!
                    .take(source.maxResults)
                    .toList(),
                allResults,
              ),
        ],
      ),
    );
  }

  Widget _buildCategorySection(
    BuildContext context,
    String category,
    IconData icon,
    List<OiSearchResult> results,
    List<OiSearchResult> allResults,
  ) {
    final colors = context.colors;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Category header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            children: [
              Icon(icon, size: 14, color: colors.textMuted),
              const SizedBox(width: 6),
              Text(
                category,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: colors.textMuted,
                ),
              ),
            ],
          ),
        ),
        // Results
        for (final result in results)
          _buildResultTile(context, result, allResults),
      ],
    );
  }

  Widget _buildResultTile(
    BuildContext context,
    OiSearchResult result,
    List<OiSearchResult> allResults,
  ) {
    final colors = context.colors;
    final index = allResults.indexOf(result);
    final isHighlighted = index == _highlightedIndex;

    return GestureDetector(
      onTap: () => _selectResult(result),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        color: isHighlighted ? colors.surfaceHover : null,
        child: Row(
          children: [
            if (result.leading != null)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: result.leading,
              ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    result.title,
                    style: TextStyle(fontSize: 14, color: colors.text),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (result.subtitle != null)
                    Text(
                      result.subtitle!,
                      style: TextStyle(fontSize: 12, color: colors.textMuted),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            if (result.trailing != null) result.trailing!,
          ],
        ),
      ),
    );
  }
}
