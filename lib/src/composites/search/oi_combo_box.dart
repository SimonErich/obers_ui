import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/_internal/oi_input_frame.dart';
import 'package:obers_ui/src/components/display/oi_badge.dart';
import 'package:obers_ui/src/composites/search/oi_combo_box_labels.dart';
import 'package:obers_ui/src/foundation/_oi_latest_request.dart';
import 'package:obers_ui/src/foundation/oi_icons.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/input/oi_raw_input.dart';
import 'package:obers_ui/src/primitives/overlay/oi_floating.dart';

/// A searchable select box with type-ahead filtering.
///
/// The user types to filter options, and the dropdown shows matching results.
/// Supports async search, multi-select, grouping, create-new, recent/favorite
/// sections, virtualization, and pagination.
///
/// {@category Composites}
class OiComboBox<T> extends StatefulWidget {
  /// Creates an [OiComboBox].
  const OiComboBox({
    required this.label,
    required this.labelOf,
    this.noResultsLabel = 'No results',
    this.recentLabel = 'Recent',
    this.favoritesLabel = 'Favorites',
    this.labels = const OiComboBoxLabels(),
    super.key,
    this.items = const [],
    this.value,
    this.onSelect,
    this.search,
    this.onCreate,
    this.placeholder,
    this.clearable = true,
    this.enabled = true,
    this.hint,
    this.error,
    this.multiSelect = false,
    this.selectedValues = const [],
    this.onMultiSelect,
    this.maxChipsVisible,
    this.groupBy,
    this.groupOrder,
    this.recentItems,
    this.favoriteItems,
    this.virtualScroll = false,
    this.itemHeight,
    this.loadMore,
    this.moreAvailable = false,
    this.optionBuilder,
  });

  /// Accessibility label for the combo box.
  final String label;

  /// Function to get display label from an item.
  final String Function(T) labelOf;

  /// Static list of items.
  final List<T> items;

  /// Currently selected value (single-select mode).
  final T? value;

  /// Called when an item is selected or cleared (single-select mode).
  ///
  /// When the selection is cleared, `null` is passed.
  final ValueChanged<T?>? onSelect;

  /// Async search function. Overrides [items] filtering when provided.
  final Future<List<T>> Function(String query)? search;

  /// Called when the user types a value that doesn't match any option.
  final ValueChanged<String>? onCreate;

  /// Placeholder text when no value is selected.
  final String? placeholder;

  /// Whether the selection can be cleared.
  final bool clearable;

  /// Whether the combo box is enabled.
  final bool enabled;

  /// Hint text below the input.
  final String? hint;

  /// Error text below the input (replaces hint).
  final String? error;

  /// Whether multi-select mode is enabled.
  final bool multiSelect;

  /// Currently selected values (multi-select mode).
  final List<T> selectedValues;

  /// Called when selection changes (multi-select mode).
  final ValueChanged<List<T>>? onMultiSelect;

  /// Maximum number of chips visible in multi-select trigger.
  final int? maxChipsVisible;

  /// Function to group options under headers.
  final String Function(T)? groupBy;

  /// Order of group headers.
  final List<String>? groupOrder;

  /// Recent items shown in a dedicated section.
  final List<T>? recentItems;

  /// Favorite items shown in a dedicated section.
  final List<T>? favoriteItems;

  /// Whether to use virtualized scrolling for large option lists.
  final bool virtualScroll;

  /// Item height for virtualized scrolling.
  final double? itemHeight;

  /// Callback to load more items (pagination).
  final Future<List<T>> Function()? loadMore;

  /// Whether there are more items to load.
  final bool moreAvailable;

  /// Shown when nothing matches the query.
  final String noResultsLabel;

  /// Heading of the recent options.
  final String recentLabel;

  /// Heading of the favorite options.
  final String favoritesLabel;

  /// The texts of the dropdown; pass translations to localize it.
  final OiComboBoxLabels labels;

  /// Custom option builder.
  final Widget Function(T, {required bool highlighted, required bool selected})?
  optionBuilder;

  @override
  State<OiComboBox<T>> createState() => _OiComboBoxState<T>();
}

class _OiComboBoxState<T> extends State<OiComboBox<T>> {
  late TextEditingController _textController;
  late FocusNode _inputFocusNode;
  late FocusNode _triggerFocusNode;
  bool _open = false;
  bool _triggerFocused = false;

  /// Position of the highlighted option in [_visibleOptions], or -1.
  int _highlightedIndex = -1;
  List<T> _filteredItems = [];
  List<T> _asyncResults = [];
  bool _loading = false;
  Timer? _debounce;
  final OiLatestRequest _searches = OiLatestRequest();
  final OiLatestRequest _loadMores = OiLatestRequest();

  /// Whether a "load more" page is on its way.
  bool _loadingMore = false;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _inputFocusNode = FocusNode(onKeyEvent: _handleKeyEvent);
    _triggerFocusNode = FocusNode(onKeyEvent: _handleTriggerKeyEvent)
      ..addListener(_handleTriggerFocusChange);
    _filteredItems = List<T>.from(widget.items);
  }

  @override
  void didUpdateWidget(OiComboBox<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Compared by content: a parent that builds its list inline passes a new
    // instance on every rebuild. With a search callback the options come from
    // the search, so the static items do not matter.
    final itemsChanged =
        widget.search == null && !listEquals(oldWidget.items, widget.items);
    final pinnedChanged =
        !listEquals(oldWidget.recentItems, widget.recentItems) ||
        !listEquals(oldWidget.favoriteItems, widget.favoriteItems);
    if (!itemsChanged && !pinnedChanged) return;

    // Keep the highlight on the tile it was on: the same item in the same
    // section, wherever that tile is now. An item can be listed twice, pinned
    // and in the main list, and each copy is its own tile.
    final oldSections = [
      oldWidget.recentItems ?? const [],
      oldWidget.favoriteItems ?? const [],
      _mainOptions(),
    ];
    var section = 0;
    var offset = _highlightedIndex;
    while (section < oldSections.length &&
        offset >= oldSections[section].length) {
      offset -= oldSections[section].length;
      section++;
    }
    final highlighted = offset >= 0 && section < oldSections.length;
    final item = highlighted ? oldSections[section][offset] : null;

    if (itemsChanged) {
      // The page on its way belongs to the old list.
      _cancelLoadMore();
      _filteredItems = _filterItems(_textController.text);
    }

    if (!highlighted) {
      _highlightedIndex = _initialHighlight();
      return;
    }
    final newSections = [
      widget.recentItems ?? const [],
      widget.favoriteItems ?? const [],
      _mainOptions(),
    ];
    final index = newSections[section].indexOf(item as T);
    _highlightedIndex = index < 0
        ? _initialHighlight()
        : index +
              newSections
                  .take(section)
                  .fold<int>(0, (sum, list) => sum + list.length);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searches.cancel();
    _loadMores.cancel();
    _textController.dispose();
    _inputFocusNode.dispose();
    _triggerFocusNode
      ..removeListener(_handleTriggerFocusChange)
      ..dispose();
    super.dispose();
  }

  // ── Filtering ─────────────────────────────────────────────────────────────

  List<T> _filterItems(String query) {
    if (query.isEmpty) return List<T>.from(widget.items);
    final lower = query.toLowerCase();
    return widget.items
        .where((item) => widget.labelOf(item).toLowerCase().contains(lower))
        .toList();
  }

  void _applyFilter(String query) {
    // A page still on its way belongs to the list being replaced.
    _cancelLoadMore();

    if (widget.search != null) {
      _debounce?.cancel();
      // The search in flight answers a query that is no longer the current
      // one. It is dropped now, not when the next search starts: otherwise
      // its answer would be shown, and end the loading state, during the
      // debounce.
      _searches.cancel();
      setState(() => _loading = true);
      _debounce = Timer(const Duration(milliseconds: 200), () {
        unawaited(_performAsyncSearch(query));
      });
      return;
    }

    setState(() {
      _filteredItems = _filterItems(query);
      _highlightedIndex = _initialHighlight();
    });
  }

  Future<void> _performAsyncSearch(String query) {
    setState(() => _loading = true);
    return _searches.run(
      () => widget.search!(query),
      active: () => mounted,
      onResult: (results) => setState(() {
        // Copied: "load more" appends to both lists, and the caller's list
        // may be unmodifiable.
        _asyncResults = List<T>.of(results);
        _filteredItems = List<T>.of(results);
        _loading = false;
        _highlightedIndex = _initialHighlight();
      }),
      onError: (_, _) => setState(() {
        _loading = false;
        _filteredItems = [];
        _asyncResults = [];
        _highlightedIndex = _initialHighlight();
      }),
    );
  }

  /// Loads the next page and appends it to the list it was asked for.
  ///
  /// Taps while a page is loading are ignored, and a page that arrives after
  /// the query or the items changed is dropped (see [_cancelLoadMore]).
  void _loadMore() {
    final loadMore = widget.loadMore;
    if (loadMore == null || _loadingMore) return;
    _loadingMore = true;
    unawaited(
      _loadMores.run(
        loadMore,
        active: () => mounted,
        onResult: (more) => setState(() {
          _loadingMore = false;
          _filteredItems = [..._filteredItems, ...more];
          _asyncResults = [..._asyncResults, ...more];
        }),
        // The list stays as it is and the row can be tapped again.
        onError: (_, _) => _loadingMore = false,
      ),
    );
  }

  void _cancelLoadMore() {
    _loadMores.cancel();
    _loadingMore = false;
  }

  // ── Effective items list ──────────────────────────────────────────────────

  List<T> get _effectiveItems {
    if (widget.search != null) return _asyncResults;
    return _filteredItems;
  }

  /// Number of recent and favorite options shown above the main list.
  int get _pinnedCount =>
      (widget.recentItems?.length ?? 0) + (widget.favoriteItems?.length ?? 0);

  /// The main list in the order the dropdown shows it, group by group.
  List<T> _mainOptions() => [
    for (final section in _buildGroupedSections()) ...section.items,
  ];

  /// Every option in the order the dropdown shows it: recent, favorites, then
  /// the main list. The keyboard highlight walks this list.
  List<T> _visibleOptions() => [
    ...?widget.recentItems,
    ...?widget.favoriteItems,
    ..._mainOptions(),
  ];

  /// Where the highlight starts: the first match while a query is typed (so
  /// Enter picks it rather than a recent item, and still creates when nothing
  /// matches), otherwise the first option on screen.
  int _initialHighlight() {
    if (_effectiveItems.isNotEmpty) {
      return _textController.text.isEmpty ? 0 : _pinnedCount;
    }
    return _textController.text.isEmpty && _pinnedCount > 0 ? 0 : -1;
  }

  // ── Grouped items ─────────────────────────────────────────────────────────

  /// Returns items organized into groups (with headers) if groupBy is set.
  List<_GroupedSection<T>> _buildGroupedSections() {
    final items = _effectiveItems;
    if (widget.groupBy == null) {
      return [_GroupedSection<T>(header: null, items: items)];
    }

    final groups = <String, List<T>>{};
    for (final item in items) {
      final key = widget.groupBy!(item);
      groups.putIfAbsent(key, () => []).add(item);
    }

    final order = widget.groupOrder;
    final keys = order != null
        ? order.where(groups.containsKey).toList()
        : groups.keys.toList();

    return keys
        .map((k) => _GroupedSection<T>(header: k, items: groups[k]!))
        .toList();
  }

  // ── Open / Close ──────────────────────────────────────────────────────────

  void _openDropdown() {
    if (!widget.enabled) return;
    _textController.clear();
    _applyFilter('');
    setState(() {
      _open = true;
      _highlightedIndex = _initialHighlight();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _inputFocusNode.requestFocus();
    });
  }

  /// Closes the dropdown. [restoreFocus] hands focus back to the trigger, for
  /// closes that come from the dropdown itself; a click elsewhere keeps the
  /// focus where the click put it.
  void _closeDropdown({bool restoreFocus = false}) {
    setState(() => _open = false);
    _textController.clear();
    if (restoreFocus && widget.enabled) _triggerFocusNode.requestFocus();
  }

  // ── Selection ─────────────────────────────────────────────────────────────

  void _selectItem(T item) {
    if (widget.multiSelect) {
      final current = List<T>.from(widget.selectedValues);
      if (current.contains(item)) {
        current.remove(item);
      } else {
        current.add(item);
      }
      widget.onMultiSelect?.call(current);
      // Keep dropdown open in multi-select mode.
      return;
    }

    widget.onSelect?.call(item);
    _closeDropdown(restoreFocus: true);
  }

  void _clearSelection() {
    if (widget.multiSelect) {
      widget.onMultiSelect?.call([]);
    } else {
      widget.onSelect?.call(null);
    }
  }

  bool _isSelected(T item) {
    if (widget.multiSelect) {
      return widget.selectedValues.contains(item);
    }
    return widget.value == item;
  }

  // ── Keyboard ──────────────────────────────────────────────────────────────

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }

    final options = _visibleOptions();

    if (event.logicalKey == LogicalKeyboardKey.arrowDown ||
        event.logicalKey == LogicalKeyboardKey.arrowUp) {
      // Nothing to move through; clamping to an empty range would throw.
      if (options.isEmpty) return KeyEventResult.handled;
      final step = event.logicalKey == LogicalKeyboardKey.arrowDown ? 1 : -1;
      setState(() {
        _highlightedIndex = (_highlightedIndex + step).clamp(
          0,
          options.length - 1,
        );
      });
      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.enter) {
      if (_highlightedIndex >= 0 && _highlightedIndex < options.length) {
        _selectItem(options[_highlightedIndex]);
      } else if (widget.onCreate != null && _textController.text.isNotEmpty) {
        widget.onCreate!(_textController.text);
        _closeDropdown(restoreFocus: true);
      }
      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.escape) {
      _closeDropdown(restoreFocus: true);
      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.tab) {
      // Tab leaves the combo box: the dropdown closes and focus moves to the
      // trigger's neighbour. The search field lives in an overlay, so the
      // traversal has to start from the trigger, which is where the user
      // was. Traversal goes from the scope's focused child; the request below
      // makes that the trigger and is itself replaced by the move.
      _closeDropdown();
      _triggerFocusNode.requestFocus();
      if (HardwareKeyboard.instance.isShiftPressed) {
        _triggerFocusNode.previousFocus();
      } else {
        _triggerFocusNode.nextFocus();
      }
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  /// Opens the dropdown from the focused trigger.
  KeyEventResult _handleTriggerKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent || !widget.enabled || _open) {
      return KeyEventResult.ignored;
    }
    if (event.logicalKey == LogicalKeyboardKey.enter ||
        event.logicalKey == LogicalKeyboardKey.space ||
        event.logicalKey == LogicalKeyboardKey.arrowDown) {
      _openDropdown();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  void _handleTriggerFocusChange() {
    final focused = _triggerFocusNode.hasPrimaryFocus;
    if (focused != _triggerFocused) setState(() => _triggerFocused = focused);
  }

  // ── Build dropdown ────────────────────────────────────────────────────────

  Widget _buildDropdown(BuildContext context) {
    final colors = context.colors;
    const itemHeight = 40.0;
    final effectiveItemHeight = widget.itemHeight ?? itemHeight;
    final items = _effectiveItems;

    final sections = _buildGroupedSections();
    final hasRecent =
        widget.recentItems != null && widget.recentItems!.isNotEmpty;
    final hasFavorite =
        widget.favoriteItems != null && widget.favoriteItems!.isNotEmpty;

    // Position of the next option tile in the on-screen order; it matches the
    // tile's index in [_visibleOptions], which the highlight refers to.
    var position = 0;
    Widget nextTile(T item) =>
        _buildOptionTile(context, item, position++, effectiveItemHeight);

    return UnconstrainedBox(
      alignment: Alignment.topLeft,
      child: Container(
        width: 280,
        constraints: const BoxConstraints(maxHeight: 300),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: colors.overlay,
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Search input
            Padding(
              padding: const EdgeInsets.all(8),
              child: OiRawInput(
                controller: _textController,
                focusNode: _inputFocusNode,
                placeholder: widget.labels.searchPlaceholder,
                onChanged: _applyFilter,
              ),
            ),
            // Loading state
            if (_loading)
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  widget.labels.loading,
                  style: TextStyle(color: colors.textMuted, fontSize: 14),
                ),
              )
            // Empty state
            else if (items.isEmpty && !hasRecent && !hasFavorite)
              Padding(
                padding: const EdgeInsets.all(12),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    Text(
                      widget.noResultsLabel,
                      style: TextStyle(color: colors.textMuted, fontSize: 14),
                    ),
                    if (widget.onCreate != null &&
                        _textController.text.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          widget.onCreate!(_textController.text);
                          _closeDropdown(restoreFocus: true);
                        },
                        child: Text(
                          widget.labels.create(_textController.text),
                          style: TextStyle(
                            color: colors.primary.base,
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              )
            // Items list
            else
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Recent section
                      if (hasRecent) ...[
                        _buildSectionHeader(context, widget.recentLabel),
                        ...widget.recentItems!.map(nextTile),
                      ],
                      // Favorites section
                      if (hasFavorite) ...[
                        _buildSectionHeader(context, widget.favoritesLabel),
                        ...widget.favoriteItems!.map(nextTile),
                      ],
                      // Main sections (possibly grouped)
                      for (final section in sections) ...[
                        if (section.header != null)
                          _buildSectionHeader(context, section.header!),
                        ...section.items.map(nextTile),
                      ],
                      // Load more
                      if (widget.moreAvailable && widget.loadMore != null)
                        GestureDetector(
                          onTap: _loadMore,
                          child: Container(
                            height: effectiveItemHeight,
                            alignment: Alignment.center,
                            child: Text(
                              widget.labels.loadMore,
                              style: TextStyle(
                                color: colors.primary.base,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: colors.textMuted,
        ),
      ),
    );
  }

  /// Builds the tile of [item], the [position]-th option on screen.
  Widget _buildOptionTile(
    BuildContext context,
    T item,
    int position,
    double height,
  ) {
    final isHighlighted = position == _highlightedIndex;
    final selected = _isSelected(item);

    if (widget.optionBuilder != null) {
      return GestureDetector(
        onTap: () => _selectItem(item),
        behavior: HitTestBehavior.opaque,
        child: widget.optionBuilder!(
          item,
          highlighted: isHighlighted,
          selected: selected,
        ),
      );
    }

    return _ComboBoxOptionTile(
      label: widget.labelOf(item),
      height: height,
      highlighted: isHighlighted,
      selected: selected,
      multiSelect: widget.multiSelect,
      onTap: () => _selectItem(item),
    );
  }

  // ── Build trigger ─────────────────────────────────────────────────────────

  Widget _buildTrigger(BuildContext context) {
    final colors = context.colors;

    // Multi-select: show chips
    if (widget.multiSelect && widget.selectedValues.isNotEmpty) {
      final visible = widget.maxChipsVisible ?? widget.selectedValues.length;
      final visibleItems = widget.selectedValues.take(visible).toList();
      final remaining = widget.selectedValues.length - visible;

      return Row(
        children: [
          Expanded(
            child: Wrap(
              spacing: 4,
              runSpacing: 2,
              children: [
                for (final item in visibleItems)
                  OiBadge.soft(
                    label: widget.labelOf(item),
                    size: OiBadgeSize.small,
                    color: OiBadgeColor.neutral,
                  ),
                if (remaining > 0)
                  Text(
                    '+$remaining',
                    style: TextStyle(fontSize: 12, color: colors.textMuted),
                  ),
              ],
            ),
          ),
          if (widget.clearable)
            GestureDetector(
              onTap: _clearSelection,
              child: Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Icon(
                  OiIcons.x,
                  size: 16,
                  color: colors.textMuted,
                ),
              ),
            ),
        ],
      );
    }

    // Single-select: show selected label or placeholder
    final hasValue = widget.value != null;
    final displayText = hasValue
        ? widget.labelOf(widget.value as T)
        : widget.placeholder ?? '';

    return Row(
      children: [
        Expanded(
          child: Text(
            displayText,
            style: TextStyle(
              fontSize: 14,
              color: hasValue ? colors.text : colors.textMuted,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (hasValue && widget.clearable)
          GestureDetector(
            onTap: _clearSelection,
            child: Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Icon(
                OiIcons.x,
                size: 16,
                color: colors.textMuted,
              ),
            ),
          ),
      ],
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final chevron = Icon(
      OiIcons.arrowDown,
      size: 16,
      color: colors.textMuted,
    );

    // The trigger takes keyboard focus so the dropdown can be opened without
    // a pointer; the frame's focused border shows where the focus is.
    final anchor = Semantics(
      label: widget.label,
      enabled: widget.enabled,
      child: Focus(
        focusNode: _triggerFocusNode,
        canRequestFocus: widget.enabled,
        child: GestureDetector(
          onTap: widget.enabled ? _openDropdown : null,
          behavior: HitTestBehavior.opaque,
          child: OiInputFrame(
            label: widget.label,
            hint: widget.hint,
            error: widget.error,
            focused: _open || _triggerFocused,
            enabled: widget.enabled,
            trailing: chevron,
            child: _buildTrigger(context),
          ),
        ),
      ),
    );

    return OiFloating(
      visible: _open,
      anchor: anchor,
      onDismiss: _closeDropdown,
      child: _buildDropdown(context),
    );
  }
}

// ── Internal helpers ──────────────────────────────────────────────────────────

/// A grouped section with an optional header and a list of items.
class _GroupedSection<T> {
  /// Creates a [_GroupedSection].
  const _GroupedSection({required this.header, required this.items});

  /// The section header text, or null for the default section.
  final String? header;

  /// The items in this section.
  final List<T> items;
}

/// A single option tile with hover tracking.
class _ComboBoxOptionTile extends StatefulWidget {
  const _ComboBoxOptionTile({
    required this.label,
    required this.height,
    required this.highlighted,
    required this.selected,
    required this.multiSelect,
    required this.onTap,
  });

  final String label;
  final double height;
  final bool highlighted;
  final bool selected;
  final bool multiSelect;
  final VoidCallback onTap;

  @override
  State<_ComboBoxOptionTile> createState() => _ComboBoxOptionTileState();
}

class _ComboBoxOptionTileState extends State<_ComboBoxOptionTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final showHover = _hovered || widget.highlighted;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: widget.height,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          color: showHover
              ? colors.surfaceHover
              : widget.selected
              ? colors.primary.base.withValues(alpha: 0.08)
              : null,
          child: Row(
            children: [
              if (widget.multiSelect)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _OiCheckMark(checked: widget.selected),
                ),
              Expanded(
                child: Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: 14,
                    color: widget.selected ? colors.primary.base : colors.text,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A simple check mark indicator for multi-select mode.
class _OiCheckMark extends StatelessWidget {
  const _OiCheckMark({required this.checked});

  final bool checked;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(3),
        border: Border.all(
          color: checked ? colors.primary.base : colors.border,
        ),
        color: checked ? colors.primary.base : null,
      ),
      child: checked
          ? Icon(
              OiIcons.check,
              size: 12,
              color: colors.textOnPrimary,
            )
          : null,
    );
  }
}
