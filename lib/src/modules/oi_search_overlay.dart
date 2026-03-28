import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/display/oi_badge.dart';
import 'package:obers_ui/src/components/display/oi_empty_state.dart';
import 'package:obers_ui/src/components/display/oi_progress.dart';
import 'package:obers_ui/src/components/inputs/oi_text_input.dart';
import 'package:obers_ui/src/foundation/oi_icons.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/display/oi_divider.dart';
import 'package:obers_ui/src/primitives/display/oi_label.dart';
import 'package:obers_ui/src/primitives/interaction/oi_tappable.dart';

// ---------------------------------------------------------------------------
// Data classes
// ---------------------------------------------------------------------------

/// A search suggestion result.
///
/// {@category Modules}
@immutable
class OiSearchSuggestion {
  /// Creates an [OiSearchSuggestion].
  const OiSearchSuggestion({
    required this.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.category,
    this.trailing,
  });

  /// Unique identifier for this suggestion.
  final Object key;

  /// The main display text of the suggestion.
  final String title;

  /// Optional secondary text shown below [title].
  final String? subtitle;

  /// Optional leading icon for the suggestion row.
  final IconData? icon;

  /// Optional category label shown as a badge.
  final String? category;

  /// Optional trailing widget (e.g. a shortcut hint or action).
  final Widget? trailing;
}

/// A category filter for search.
///
/// {@category Modules}
@immutable
class OiSearchCategory {
  /// Creates an [OiSearchCategory].
  const OiSearchCategory({required this.key, required this.label, this.icon});

  /// Unique key identifying this category for filter callbacks.
  final String key;

  /// The display label for this category chip.
  final String label;

  /// Optional icon shown alongside the label.
  final IconData? icon;
}

// ---------------------------------------------------------------------------
// Main widget
// ---------------------------------------------------------------------------

/// A search overlay with recent searches, async suggestions, category
/// filters, and keyboard navigation.
///
/// Provide an [onSearch] callback that returns a [Future] of
/// [OiSearchSuggestion] results. The overlay debounces input changes by
/// [debounce] before invoking the callback.
///
/// When the text field is empty and [recentSearches] is non-empty, recent
/// search terms are displayed instead. The [onClearRecents] and [onRecentTap]
/// callbacks allow the host to manage recent search state.
///
/// Category filter chips are rendered when [categories] is non-empty.
/// Selecting a category re-triggers the search with the category key.
///
/// Keyboard navigation is supported: Up/Down arrows move the highlighted
/// result, Enter selects the currently highlighted item.
///
/// {@category Modules}
class OiSearchOverlay extends StatefulWidget {
  /// Creates an [OiSearchOverlay].
  const OiSearchOverlay({
    required this.label,
    this.onSearch,
    this.onSuggestionTap,
    this.onRecentTap,
    this.onClearRecents,
    this.categories = const [],
    this.recentSearches = const [],
    this.placeholder = 'Search...',
    this.debounce = const Duration(milliseconds: 300),
    this.maxRecents = 5,
    this.emptyStateTitle = 'No results found',
    this.emptyStateDescription = 'Try a different search term.',
    this.maxWidth = 640,
    super.key,
  });

  /// Semantic label for accessibility.
  final String label;

  /// Async callback invoked when the user types a query. Receives the current
  /// query string and the selected [OiSearchCategory.key] (or `null` for all).
  final Future<List<OiSearchSuggestion>> Function(
    String query,
    String? categoryKey,
  )?
  onSearch;

  /// Called when the user selects a suggestion from the results.
  final void Function(OiSearchSuggestion)? onSuggestionTap;

  /// Called when the user taps a recent search term.
  final void Function(String query)? onRecentTap;

  /// Called when the user taps the "Clear" button in the recent searches
  /// section header.
  final VoidCallback? onClearRecents;

  /// Available category filters shown as horizontal chips.
  final List<OiSearchCategory> categories;

  /// Recent search terms shown when the query is empty.
  final List<String> recentSearches;

  /// Placeholder text for the search input.
  final String placeholder;

  /// Debounce duration before triggering [onSearch].
  final Duration debounce;

  /// Maximum number of recent searches to display.
  final int maxRecents;

  /// Title shown when the search returns no results.
  final String emptyStateTitle;

  /// Description shown when the search returns no results.
  final String emptyStateDescription;

  /// Maximum width of the overlay container.
  final double maxWidth;

  @override
  State<OiSearchOverlay> createState() => _OiSearchOverlayState();
}

class _OiSearchOverlayState extends State<OiSearchOverlay> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  List<OiSearchSuggestion> _results = [];
  bool _isLoading = false;
  bool _hasSearched = false;
  String? _selectedCategory;
  int _highlightedIndex = -1;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onQueryChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController
      ..removeListener(_onQueryChanged)
      ..dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Behaviour
  // ---------------------------------------------------------------------------

  void _onQueryChanged() {
    _debounceTimer?.cancel();
    final query = _searchController.text.trim();

    if (query.isEmpty) {
      setState(() {
        _results = [];
        _hasSearched = false;
        _isLoading = false;
        _highlightedIndex = -1;
      });
      return;
    }

    setState(() => _isLoading = true);

    _debounceTimer = Timer(widget.debounce, () => _performSearch(query));
  }

  Future<void> _performSearch(String query) async {
    if (widget.onSearch == null) return;

    try {
      final results = await widget.onSearch!(query, _selectedCategory);
      if (!mounted) return;
      setState(() {
        _results = results;
        _hasSearched = true;
        _isLoading = false;
        _highlightedIndex = -1;
      });
    } on Exception {
      if (!mounted) return;
      setState(() {
        _results = [];
        _hasSearched = true;
        _isLoading = false;
      });
    }
  }

  void _selectCategory(String? key) {
    setState(() {
      _selectedCategory = key;
      _highlightedIndex = -1;
    });

    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      setState(() => _isLoading = true);
      _performSearch(query);
    }
  }

  void _onSuggestionSelected(OiSearchSuggestion suggestion) {
    widget.onSuggestionTap?.call(suggestion);
  }

  void _onRecentSelected(String query) {
    _searchController.text = query;
    widget.onRecentTap?.call(query);
  }

  KeyEventResult _onKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }

    final key = event.logicalKey;

    if (key == LogicalKeyboardKey.arrowDown) {
      final max = _results.length - 1;
      if (max >= 0) {
        setState(() {
          _highlightedIndex = (_highlightedIndex + 1).clamp(0, max);
        });
      }
      return KeyEventResult.handled;
    }

    if (key == LogicalKeyboardKey.arrowUp) {
      if (_highlightedIndex > 0) {
        setState(() => _highlightedIndex -= 1);
      }
      return KeyEventResult.handled;
    }

    if (key == LogicalKeyboardKey.enter) {
      if (_highlightedIndex >= 0 && _highlightedIndex < _results.length) {
        _onSuggestionSelected(_results[_highlightedIndex]);
      }
      return KeyEventResult.handled;
    }

    if (key == LogicalKeyboardKey.escape) {
      _searchController.clear();
      setState(() {
        _results = [];
        _hasSearched = false;
        _highlightedIndex = -1;
      });
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final radius = context.radius;

    return Semantics(
      label: widget.label,
      container: true,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: widget.maxWidth),
          child: Focus(
            onKeyEvent: _onKeyEvent,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: radius.lg,
                boxShadow: [
                  BoxShadow(
                    color: colors.overlay.withValues(alpha: 0.12),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.all(spacing.md),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildSearchInput(),
                    if (widget.categories.isNotEmpty) ...[
                      SizedBox(height: spacing.sm),
                      _buildCategoryChips(context),
                    ],
                    SizedBox(height: spacing.sm),
                    const OiDivider(),
                    SizedBox(height: spacing.sm),
                    Flexible(child: _buildBody(context)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchInput() {
    return OiTextInput.search(
      controller: _searchController,
      autofocus: true,
      focusNode: _focusNode,
      onSubmitted: (query) {
        if (_highlightedIndex >= 0 && _highlightedIndex < _results.length) {
          _onSuggestionSelected(_results[_highlightedIndex]);
        }
      },
    );
  }

  Widget _buildCategoryChips(BuildContext context) {
    final spacing = context.spacing;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildChip(
            context,
            label: 'All',
            selected: _selectedCategory == null,
            onTap: () => _selectCategory(null),
          ),
          ...widget.categories.map(
            (cat) => Padding(
              padding: EdgeInsets.only(left: spacing.xs),
              child: _buildChip(
                context,
                label: cat.label,
                icon: cat.icon,
                selected: _selectedCategory == cat.key,
                onTap: () => _selectCategory(cat.key),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(
    BuildContext context, {
    required String label,
    required bool selected,
    required VoidCallback onTap,
    IconData? icon,
  }) {
    return OiTappable(
      onTap: onTap,
      semanticLabel: label,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: selected
              ? context.colors.primary.base.withValues(alpha: 0.12)
              : context.colors.surfaceSubtle,
          borderRadius: context.radius.full,
          border: selected
              ? Border.all(color: context.colors.primary.base)
              : Border.all(color: context.colors.borderSubtle),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: context.spacing.sm,
            vertical: context.spacing.xs,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 14, color: context.colors.textSubtle),
                SizedBox(width: context.spacing.xs),
              ],
              OiLabel.small(
                label,
                color: selected
                    ? context.colors.primary.base
                    : context.colors.text,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final query = _searchController.text.trim();

    // Show recent searches when query is empty.
    if (query.isEmpty) {
      if (widget.recentSearches.isNotEmpty) {
        return _buildRecentSearches(context);
      }
      return const SizedBox.shrink();
    }

    // Loading state.
    if (_isLoading) {
      return _buildLoading(context);
    }

    // Empty state after search completes with no results.
    if (_hasSearched && _results.isEmpty) {
      return OiEmptyState(
        title: widget.emptyStateTitle,
        description: widget.emptyStateDescription,
        icon: OiIcons.search,
      );
    }

    // Results list.
    if (_results.isNotEmpty) {
      return _buildResultsList(context);
    }

    return const SizedBox.shrink();
  }

  Widget _buildLoading(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: context.spacing.lg),
      child: const Center(
        child: OiProgress.circular(indeterminate: true, size: 32),
      ),
    );
  }

  Widget _buildResultsList(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: _results.length,
      padding: EdgeInsets.zero,
      itemBuilder: (context, index) =>
          _buildResultItem(context, _results[index], index),
    );
  }

  Widget _buildResultItem(
    BuildContext context,
    OiSearchSuggestion suggestion,
    int index,
  ) {
    final colors = context.colors;
    final spacing = context.spacing;
    final radius = context.radius;
    final isHighlighted = index == _highlightedIndex;

    return OiTappable(
      onTap: () => _onSuggestionSelected(suggestion),
      semanticLabel: suggestion.title,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: isHighlighted
              ? colors.primary.base.withValues(alpha: 0.08)
              : null,
          borderRadius: radius.md,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: spacing.sm,
            vertical: spacing.sm,
          ),
          child: Row(
            children: [
              if (suggestion.icon != null) ...[
                Icon(suggestion.icon, size: 18, color: colors.textSubtle),
                SizedBox(width: spacing.sm),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    OiLabel.body(suggestion.title, maxLines: 1),
                    if (suggestion.subtitle != null)
                      OiLabel.small(
                        suggestion.subtitle!,
                        color: colors.textMuted,
                        maxLines: 1,
                      ),
                  ],
                ),
              ),
              if (suggestion.category != null) ...[
                SizedBox(width: spacing.sm),
                OiBadge.soft(label: suggestion.category!),
              ],
              if (suggestion.trailing != null) ...[
                SizedBox(width: spacing.sm),
                suggestion.trailing!,
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentSearches(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final recents = widget.recentSearches.take(widget.maxRecents).toList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: OiLabel.small('Recent Searches', color: colors.textMuted),
            ),
            if (widget.onClearRecents != null)
              OiTappable(
                onTap: widget.onClearRecents,
                semanticLabel: 'Clear recent searches',
                child: OiLabel.small('Clear', color: colors.primary.base),
              ),
          ],
        ),
        SizedBox(height: spacing.xs),
        ...recents.map(
          (query) => OiTappable(
            onTap: () => _onRecentSelected(query),
            semanticLabel: query,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: spacing.xs),
              child: Row(
                children: [
                  Icon(OiIcons.clock, size: 16, color: colors.textMuted),
                  SizedBox(width: spacing.sm),
                  Expanded(child: OiLabel.body(query, maxLines: 1)),
                  Icon(OiIcons.arrowRight, size: 14, color: colors.textMuted),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
