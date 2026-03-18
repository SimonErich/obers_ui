import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/display/oi_badge.dart';
import 'package:obers_ui/src/components/overlays/oi_context_menu.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/interaction/oi_tappable.dart';

// ── Data model ───────────────────────────────────────────────────────────────

/// An item in the nav menu.
///
/// Each item has a unique [id] and a display [label]. Items may optionally
/// carry an [icon], a [badgeCount], a custom [color], or be [disabled].
@immutable
class OiNavMenuItem {
  /// Creates an [OiNavMenuItem].
  const OiNavMenuItem({
    required this.id,
    required this.label,
    this.icon,
    this.badgeCount,
    this.color,
    this.disabled = false,
  });

  /// A unique identifier used to track selection.
  final String id;

  /// The display label for this item.
  final String label;

  /// An optional leading icon.
  final IconData? icon;

  /// An optional badge count displayed to the right of the label.
  ///
  /// When `null` no badge is shown.
  final int? badgeCount;

  /// An optional color applied to the leading icon and badge.
  final Color? color;

  /// Whether this item is non-interactive.
  final bool disabled;
}

// ── OiNavMenu ────────────────────────────────────────────────────────────────

/// A submenu / secondary navigation list with optional reorder and context menu.
///
/// Displays a vertical list of [OiNavMenuItem] entries. The currently active
/// item is highlighted based on [selectedId]. Keyboard navigation with arrow
/// keys and Enter is supported.
///
/// When [reorderable] is `true` and [onReorder] is provided, items can be
/// reordered via drag-and-drop.
///
/// When [contextMenu] is provided, each item responds to right-click (pointer)
/// or long-press (touch) to show a context menu built from [OiMenuItem] entries.
///
/// {@category Composites}
class OiNavMenu extends StatelessWidget {
  /// Creates an [OiNavMenu].
  const OiNavMenu({
    required this.items,
    required this.selectedId,
    required this.onSelect,
    required this.label,
    this.reorderable = false,
    this.onReorder,
    this.contextMenu,
    this.header,
    this.footer,
    super.key,
  });

  /// The navigation items to display.
  final List<OiNavMenuItem> items;

  /// The [OiNavMenuItem.id] of the currently selected item.
  ///
  /// When `null` no item is highlighted as selected.
  final String? selectedId;

  /// Called when the user selects an item.
  final ValueChanged<String> onSelect;

  /// The accessibility label for the navigation landmark.
  final String label;

  /// Whether items can be reordered via drag-and-drop.
  final bool reorderable;

  /// Called after the user drops an item at a new position.
  ///
  /// Ignored when [reorderable] is `false`.
  final void Function(int oldIndex, int newIndex)? onReorder;

  /// Builds a context menu for the given item.
  ///
  /// When non-null each item will respond to right-click / long-press.
  final List<OiMenuItem> Function(OiNavMenuItem)? contextMenu;

  /// An optional widget rendered above the navigation items.
  final Widget? header;

  /// An optional widget rendered below the navigation items.
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: label,
      explicitChildNodes: true,
      child: _OiNavMenuBody(
        items: items,
        selectedId: selectedId,
        onSelect: onSelect,
        reorderable: reorderable,
        onReorder: onReorder,
        contextMenu: contextMenu,
        header: header,
        footer: footer,
      ),
    );
  }
}

/// Internal stateful body that manages keyboard focus.
class _OiNavMenuBody extends StatefulWidget {
  const _OiNavMenuBody({
    required this.items,
    required this.selectedId,
    required this.onSelect,
    required this.reorderable,
    this.onReorder,
    this.contextMenu,
    this.header,
    this.footer,
  });

  final List<OiNavMenuItem> items;
  final String? selectedId;
  final ValueChanged<String> onSelect;
  final bool reorderable;
  final void Function(int oldIndex, int newIndex)? onReorder;
  final List<OiMenuItem> Function(OiNavMenuItem)? contextMenu;
  final Widget? header;
  final Widget? footer;

  @override
  State<_OiNavMenuBody> createState() => _OiNavMenuBodyState();
}

class _OiNavMenuBodyState extends State<_OiNavMenuBody> {
  int _focusedIndex = -1;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
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
      if (_focusedIndex >= 0 && _focusedIndex < widget.items.length) {
        final item = widget.items[_focusedIndex];
        if (!item.disabled) {
          widget.onSelect(item.id);
        }
      }
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  void _moveFocus(int delta) {
    if (widget.items.isEmpty) return;
    var next = _focusedIndex + delta;
    while (next >= 0 &&
        next < widget.items.length &&
        widget.items[next].disabled) {
      next += delta;
    }
    if (next >= 0 && next < widget.items.length) {
      setState(() => _focusedIndex = next);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focusNode,
      onKeyEvent: _handleKeyEvent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.header != null) widget.header!,
          for (var i = 0; i < widget.items.length; i++)
            _buildItem(context, widget.items[i], i),
          if (widget.footer != null) widget.footer!,
        ],
      ),
    );
  }

  Widget _buildItem(BuildContext context, OiNavMenuItem item, int index) {
    final colors = context.colors;
    final isSelected = item.id == widget.selectedId;
    final isFocused = index == _focusedIndex;

    Color bg;
    if (isSelected) {
      bg = colors.primary.base.withValues(alpha: 0.1);
    } else if (isFocused) {
      bg = colors.surfaceHover;
    } else {
      bg = const Color(0x00000000);
    }

    final textColor = isSelected
        ? colors.primary.base
        : item.disabled
        ? colors.textMuted
        : colors.text;

    final iconColor =
        item.color ?? (isSelected ? colors.primary.base : colors.textSubtle);

    Widget row = Container(
      color: bg,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          if (item.icon != null) ...[
            Icon(
              item.icon,
              size: 18,
              color: item.disabled ? colors.textMuted : iconColor,
            ),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Text(
              item.label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: textColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (item.badgeCount != null && item.badgeCount! > 0)
            OiBadge.filled(label: item.badgeCount.toString(), size: OiBadgeSize.small),
        ],
      ),
    );

    row = OiTappable(
      enabled: !item.disabled,
      semanticLabel: item.label,
      onTap: () => widget.onSelect(item.id),
      child: row,
    );

    if (widget.contextMenu != null) {
      row = OiContextMenu(items: widget.contextMenu!(item), child: row);
    }

    return row;
  }
}
