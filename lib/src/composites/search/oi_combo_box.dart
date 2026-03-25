import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/_internal/oi_input_frame.dart';
import 'package:obers_ui/src/components/display/oi_badge.dart';
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

  /// Custom option builder.
  final Widget Function(T, {required bool highlighted, required bool selected})?
  optionBuilder;

  @override
  State<OiComboBox<T>> createState() => _OiComboBoxState<T>();
}

class _OiComboBoxState<T> extends State<OiComboBox<T>> {
  late TextEditingController _textController;
  late FocusNode _inputFocusNode;
  bool _open = false;
  int _highlightedIndex = -1;
  List<T> _filteredItems = [];
  List<T> _asyncResults = [];
  bool _loading = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _inputFocusNode = FocusNode(onKeyEvent: _handleKeyEvent);
    _filteredItems = List<T>.from(widget.items);
  }

  @override
  void didUpdateWidget(OiComboBox<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items != widget.items) {
      _applyFilter(_textController.text);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _textController.dispose();
    _inputFocusNode.dispose();
    super.dispose();
  }

  // ── Filtering ─────────────────────────────────────────────────────────────

  void _applyFilter(String query) {
    if (widget.search != null) {
      _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 200), () {
        _performAsyncSearch(query);
      });
      return;
    }

    final lower = query.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredItems = List<T>.from(widget.items);
      } else {
        _filteredItems = widget.items
            .where((item) => widget.labelOf(item).toLowerCase().contains(lower))
            .toList();
      }
      _highlightedIndex = _filteredItems.isEmpty ? -1 : 0;
    });
  }

  Future<void> _performAsyncSearch(String query) async {
    setState(() => _loading = true);
    try {
      final results = await widget.search!(query);
      if (mounted) {
        setState(() {
          _asyncResults = results;
          _filteredItems = results;
          _loading = false;
          _highlightedIndex = _filteredItems.isEmpty ? -1 : 0;
        });
      }
    } on Exception {
      if (mounted) {
        setState(() {
          _loading = false;
          _filteredItems = [];
          _asyncResults = [];
        });
      }
    }
  }

  // ── Effective items list ──────────────────────────────────────────────────

  List<T> get _effectiveItems {
    if (widget.search != null) return _asyncResults;
    return _filteredItems;
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
      _highlightedIndex = _filteredItems.isEmpty ? -1 : 0;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _inputFocusNode.requestFocus();
    });
  }

  void _closeDropdown() {
    setState(() => _open = false);
    _textController.clear();
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
    _closeDropdown();
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

    final items = _effectiveItems;

    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      setState(() {
        _highlightedIndex = (_highlightedIndex + 1).clamp(0, items.length - 1);
      });
      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      setState(() {
        _highlightedIndex = (_highlightedIndex - 1).clamp(0, items.length - 1);
      });
      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.enter) {
      if (_highlightedIndex >= 0 && _highlightedIndex < items.length) {
        _selectItem(items[_highlightedIndex]);
      } else if (widget.onCreate != null && _textController.text.isNotEmpty) {
        widget.onCreate!(_textController.text);
        _closeDropdown();
      }
      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.escape) {
      _closeDropdown();
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
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
                placeholder: 'Search\u2026',
                onChanged: _applyFilter,
              ),
            ),
            // Loading state
            if (_loading)
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  'Loading\u2026',
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
                      'No results',
                      style: TextStyle(color: colors.textMuted, fontSize: 14),
                    ),
                    if (widget.onCreate != null &&
                        _textController.text.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          widget.onCreate!(_textController.text);
                          _closeDropdown();
                        },
                        child: Text(
                          'Create "${_textController.text}"',
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
                        _buildSectionHeader(context, 'Recent'),
                        ...widget.recentItems!.map(
                          (item) => _buildOptionTile(
                            context,
                            item,
                            effectiveItemHeight,
                          ),
                        ),
                      ],
                      // Favorites section
                      if (hasFavorite) ...[
                        _buildSectionHeader(context, 'Favorites'),
                        ...widget.favoriteItems!.map(
                          (item) => _buildOptionTile(
                            context,
                            item,
                            effectiveItemHeight,
                          ),
                        ),
                      ],
                      // Main sections (possibly grouped)
                      for (final section in sections) ...[
                        if (section.header != null)
                          _buildSectionHeader(context, section.header!),
                        ...section.items.map(
                          (item) => _buildOptionTile(
                            context,
                            item,
                            effectiveItemHeight,
                          ),
                        ),
                      ],
                      // Load more
                      if (widget.moreAvailable && widget.loadMore != null)
                        GestureDetector(
                          onTap: () async {
                            final more = await widget.loadMore!();
                            if (mounted) {
                              setState(() {
                                _filteredItems.addAll(more);
                                _asyncResults.addAll(more);
                              });
                            }
                          },
                          child: Container(
                            height: effectiveItemHeight,
                            alignment: Alignment.center,
                            child: Text(
                              'Load more\u2026',
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

  Widget _buildOptionTile(BuildContext context, T item, double height) {
    final items = _effectiveItems;
    final index = items.indexOf(item);
    final isHighlighted = index == _highlightedIndex;
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

    final anchor = Semantics(
      label: widget.label,
      enabled: widget.enabled,
      child: GestureDetector(
        onTap: widget.enabled ? _openDropdown : null,
        behavior: HitTestBehavior.opaque,
        child: OiInputFrame(
          label: widget.label,
          hint: widget.hint,
          error: widget.error,
          focused: _open,
          enabled: widget.enabled,
          trailing: chevron,
          child: _buildTrigger(context),
        ),
      ),
    );

    return OiFloating(
      visible: _open,
      anchor: anchor,
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
