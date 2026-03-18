import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/display/oi_badge.dart';
import 'package:obers_ui/src/components/display/oi_tooltip.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/interaction/oi_tappable.dart';

// ── Data models ──────────────────────────────────────────────────────────────

/// A section within the sidebar.
///
/// Sections group related [items] under an optional [title]. When
/// [collapsible] is `true` the section can be expanded and collapsed by
/// tapping its header.
@immutable
class OiSidebarSection {
  /// Creates an [OiSidebarSection].
  const OiSidebarSection({
    required this.items,
    this.title,
    this.collapsible = true,
  });

  /// The optional header title for this section.
  ///
  /// When `null` no header is rendered and the items appear without a
  /// visual grouping label.
  final String? title;

  /// The navigation items displayed in this section.
  final List<OiSidebarItem> items;

  /// Whether the section can be collapsed by the user.
  ///
  /// When `true` (the default) a tap on the section header toggles
  /// visibility of its [items].
  final bool collapsible;
}

/// An item in the sidebar.
///
/// Each item has a unique [id], a display [label], and an [icon]. Items may
/// optionally carry a [badgeCount], nested [children], or be [disabled].
@immutable
class OiSidebarItem {
  /// Creates an [OiSidebarItem].
  const OiSidebarItem({
    required this.id,
    required this.label,
    required this.icon,
    this.badgeCount,
    this.children,
    this.disabled = false,
  });

  /// A unique identifier used to track selection.
  final String id;

  /// The display label shown next to the icon in full mode.
  final String label;

  /// The icon displayed for this item.
  final IconData icon;

  /// An optional badge count displayed to the right of the label.
  ///
  /// When `null` no badge is shown.
  final int? badgeCount;

  /// Optional nested child items.
  ///
  /// When non-null the item acts as a parent that can be expanded to reveal
  /// its children.
  final List<OiSidebarItem>? children;

  /// Whether this item is non-interactive.
  final bool disabled;
}

// ── Display mode ─────────────────────────────────────────────────────────────

/// The display mode of the sidebar.
///
/// {@category Composites}
enum OiSidebarMode {
  /// Shows icons and labels (default ~260px wide).
  full,

  /// Shows only icons with tooltips (~64px wide).
  compact,

  /// Not visible.
  hidden,
}

// ── OiSidebar ────────────────────────────────────────────────────────────────

/// The main application sidebar with collapsible sections and nested items.
///
/// Supports three modes:
/// - [OiSidebarMode.full]: Shows icons and labels (default ~260px wide)
/// - [OiSidebarMode.compact]: Shows only icons with tooltips (~64px wide)
/// - [OiSidebarMode.hidden]: Not visible
///
/// The sidebar supports:
/// - Collapsible sections with optional titles
/// - Nested items with indentation
/// - Badge counts on items
/// - Keyboard navigation with arrow keys and Enter
/// - Accessible semantics with a navigation role
/// - Optional header and footer widgets
/// - Optional resizable width
///
/// {@category Composites}
class OiSidebar extends StatefulWidget {
  /// Creates an [OiSidebar].
  const OiSidebar({
    required this.sections,
    required this.selectedId,
    required this.onSelect,
    required this.label,
    this.mode = OiSidebarMode.full,
    this.width = 260,
    this.compactWidth = 64,
    this.resizable = false,
    this.header,
    this.footer,
    super.key,
  });

  /// The sections containing navigation items.
  final List<OiSidebarSection> sections;

  /// The [OiSidebarItem.id] of the currently selected item.
  ///
  /// When `null` no item is highlighted as selected.
  final String? selectedId;

  /// Called when the user selects an item.
  final ValueChanged<String> onSelect;

  /// The accessibility label for the sidebar navigation landmark.
  final String label;

  /// The display mode controlling visibility and width.
  final OiSidebarMode mode;

  /// The width in logical pixels when [mode] is [OiSidebarMode.full].
  final double width;

  /// The width in logical pixels when [mode] is [OiSidebarMode.compact].
  final double compactWidth;

  /// Whether the sidebar edge can be dragged to resize.
  final bool resizable;

  /// An optional widget rendered above the navigation items.
  final Widget? header;

  /// An optional widget rendered below the navigation items.
  final Widget? footer;

  @override
  State<OiSidebar> createState() => _OiSidebarState();
}

class _OiSidebarState extends State<OiSidebar> {
  final Set<String> _collapsedSections = {};
  final Set<String> _expandedParents = {};
  int _focusedIndex = -1;
  late FocusNode _focusNode;

  /// Flattened list of all visible item ids for keyboard navigation.
  List<_FlatItem> _flatItems = [];

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _rebuildFlatItems();
  }

  @override
  void didUpdateWidget(OiSidebar oldWidget) {
    super.didUpdateWidget(oldWidget);
    _rebuildFlatItems();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _rebuildFlatItems() {
    final items = <_FlatItem>[];
    for (var si = 0; si < widget.sections.length; si++) {
      final section = widget.sections[si];
      final sectionKey = section.title ?? 'section_$si';
      if (_collapsedSections.contains(sectionKey)) continue;
      for (final item in section.items) {
        items.add(_FlatItem(item: item, depth: 0));
        if (item.children != null && _expandedParents.contains(item.id)) {
          for (final child in item.children!) {
            items.add(_FlatItem(item: child, depth: 1));
          }
        }
      }
    }
    _flatItems = items;
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }

    final key = event.logicalKey;

    if (key == LogicalKeyboardKey.arrowDown) {
      _moveFocus(1);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowUp) {
      _moveFocus(-1);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.numpadEnter) {
      if (_focusedIndex >= 0 && _focusedIndex < _flatItems.length) {
        final fi = _flatItems[_focusedIndex];
        if (!fi.item.disabled) {
          widget.onSelect(fi.item.id);
        }
      }
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  void _moveFocus(int delta) {
    if (_flatItems.isEmpty) return;
    var next = _focusedIndex + delta;
    // Skip disabled items.
    while (next >= 0 &&
        next < _flatItems.length &&
        _flatItems[next].item.disabled) {
      next += delta;
    }
    if (next >= 0 && next < _flatItems.length) {
      setState(() => _focusedIndex = next);
    }
  }

  void _toggleSection(String sectionKey) {
    setState(() {
      if (_collapsedSections.contains(sectionKey)) {
        _collapsedSections.remove(sectionKey);
      } else {
        _collapsedSections.add(sectionKey);
      }
      _rebuildFlatItems();
    });
  }

  void _toggleParent(String parentId) {
    setState(() {
      if (_expandedParents.contains(parentId)) {
        _expandedParents.remove(parentId);
      } else {
        _expandedParents.add(parentId);
      }
      _rebuildFlatItems();
    });
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (widget.mode == OiSidebarMode.hidden) {
      return const SizedBox.shrink();
    }

    final compact = widget.mode == OiSidebarMode.compact;
    final effectiveWidth = compact ? widget.compactWidth : widget.width;

    return Semantics(
      label: widget.label,
      explicitChildNodes: true,
      child: Focus(
        focusNode: _focusNode,
        onKeyEvent: _handleKeyEvent,
        child: SizedBox(
          width: effectiveWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.header != null) widget.header!,
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: _buildSections(context, compact),
                  ),
                ),
              ),
              if (widget.footer != null) widget.footer!,
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildSections(BuildContext context, bool compact) {
    final widgets = <Widget>[];
    for (var si = 0; si < widget.sections.length; si++) {
      final section = widget.sections[si];
      final sectionKey = section.title ?? 'section_$si';
      final collapsed = _collapsedSections.contains(sectionKey);

      // Section header.
      if (section.title != null && !compact) {
        widgets.add(
          _buildSectionHeader(context, section, sectionKey, collapsed),
        );
      }

      // Items.
      if (!collapsed) {
        for (final item in section.items) {
          widgets.add(_buildItem(context, item, 0, compact));
          if (item.children != null && _expandedParents.contains(item.id)) {
            for (final child in item.children!) {
              widgets.add(_buildItem(context, child, 1, compact));
            }
          }
        }
      }
    }
    return widgets;
  }

  Widget _buildSectionHeader(
    BuildContext context,
    OiSidebarSection section,
    String sectionKey,
    bool collapsed,
  ) {
    final colors = context.colors;
    Widget header = Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        section.title!,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.5,
          color: colors.textMuted,
        ),
      ),
    );

    if (section.collapsible) {
      header = GestureDetector(
        onTap: () => _toggleSection(sectionKey),
        behavior: HitTestBehavior.opaque,
        child: header,
      );
    }

    return header;
  }

  Widget _buildItem(
    BuildContext context,
    OiSidebarItem item,
    int depth,
    bool compact,
  ) {
    final colors = context.colors;
    final selected = item.id == widget.selectedId;
    final hasKids = item.children != null && item.children!.isNotEmpty;
    final kidsExpanded = _expandedParents.contains(item.id);

    // Determine the flat index for keyboard focus styling.
    final flatIndex = _flatItems.indexWhere((fi) => fi.item.id == item.id);
    final isFocused = flatIndex == _focusedIndex;

    Color bg;
    if (selected) {
      bg = colors.primary.base.withValues(alpha: 0.1);
    } else if (isFocused) {
      bg = colors.surfaceHover;
    } else {
      bg = const Color(0x00000000);
    }

    final textColor = selected
        ? colors.primary.base
        : item.disabled
        ? colors.textMuted
        : colors.text;

    final iconColor = selected
        ? colors.primary.base
        : item.disabled
        ? colors.textMuted
        : colors.textSubtle;

    if (compact) {
      return _buildCompactItem(context, item, bg, iconColor, selected);
    }

    // Full mode.
    final indent = depth * 24.0;

    final Widget content = Container(
      color: bg,
      padding: EdgeInsets.only(left: 12 + indent, right: 12, top: 8, bottom: 8),
      child: Row(
        children: [
          Icon(item.icon, size: 20, color: iconColor),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              item.label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                color: textColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (item.badgeCount != null && item.badgeCount! > 0)
            OiBadge.filled(label: item.badgeCount.toString(), size: OiBadgeSize.small),
          if (hasKids)
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Text(
                kidsExpanded ? '\u25BC' : '\u25B6',
                style: TextStyle(fontSize: 10, color: colors.textMuted),
              ),
            ),
        ],
      ),
    );

    return OiTappable(
      enabled: !item.disabled,
      semanticLabel: item.label,
      onTap: () {
        if (hasKids) {
          _toggleParent(item.id);
        }
        widget.onSelect(item.id);
      },
      child: content,
    );
  }

  Widget _buildCompactItem(
    BuildContext context,
    OiSidebarItem item,
    Color bg,
    Color iconColor,
    bool selected,
  ) {
    Widget icon = Container(
      color: bg,
      width: widget.compactWidth,
      height: 48,
      alignment: Alignment.center,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(item.icon, size: 24, color: iconColor),
          if (item.badgeCount != null && item.badgeCount! > 0)
            Positioned(
              top: -4,
              right: -8,
              child: OiBadge.filled(
                label: item.badgeCount.toString(),
                size: OiBadgeSize.small,
              ),
            ),
        ],
      ),
    );

    return OiTooltip(
      label: item.label,
      message: item.label,
      child: OiTappable(
        enabled: !item.disabled,
        semanticLabel: item.label,
        onTap: () => widget.onSelect(item.id),
        child: icon,
      ),
    );
  }
}

/// A flattened sidebar item with its nesting depth for keyboard navigation.
class _FlatItem {
  const _FlatItem({required this.item, required this.depth});

  /// The sidebar item.
  final OiSidebarItem item;

  /// The nesting depth (0 for top-level, 1 for children).
  final int depth;
}
