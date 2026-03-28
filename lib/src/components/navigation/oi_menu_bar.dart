import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/overlays/oi_menu_item.dart';
import 'package:obers_ui/src/foundation/oi_icons.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/display/oi_icon.dart';
import 'package:obers_ui/src/primitives/display/oi_label.dart';
import 'package:obers_ui/src/primitives/interaction/oi_tappable.dart';

/// Deprecated. Use [OiMenuItem] instead.
@Deprecated('Use OiMenuItem instead')
typedef OiMenuBarItem = OiMenuItem;

/// Deprecated. Use [OiMenuDivider] instead.
@Deprecated('Use OiMenuDivider instead')
typedef OiMenuBarDivider = OiMenuDivider;

// ── Widget ──────────────────────────────────────────────────────────────────

/// A horizontal desktop-style menu bar with dropdown menus.
///
/// Displays a row of top-level [items] as tappable labels. Tapping a top-level
/// item opens a dropdown overlay positioned below it. When a dropdown is open,
/// hovering over a different top-level item switches the dropdown.
///
/// Pressing Escape or tapping outside the dropdown dismisses it. Left/Right
/// arrow keys navigate between top-level items while a dropdown is open.
///
/// ```dart
/// OiMenuBar(
///   label: 'Application menu',
///   items: [
///     OiMenuItem(
///       label: 'File',
///       children: [
///         OiMenuItem(label: 'New', shortcut: 'Cmd+N', onTap: () {}),
///         const OiMenuDivider(),
///         OiMenuItem(label: 'Save', shortcut: 'Cmd+S', onTap: () {}),
///       ],
///     ),
///     OiMenuItem(
///       label: 'Edit',
///       children: [
///         OiMenuItem(label: 'Undo', shortcut: 'Cmd+Z', onTap: () {}),
///       ],
///     ),
///   ],
/// )
/// ```
///
/// {@category Components}
class OiMenuBar extends StatefulWidget {
  /// Creates an [OiMenuBar].
  const OiMenuBar({
    required this.items,
    required this.label,
    this.height = 28,
    this.backgroundColor,
    super.key,
  });

  /// The top-level menu items. Each item's [OiMenuItem.children] defines
  /// its dropdown content.
  final List<OiMenuItem> items;

  /// An accessibility label for the menu bar.
  final String label;

  /// The height of the menu bar in logical pixels.
  final double height;

  /// An optional background color override for the menu bar.
  final Color? backgroundColor;

  @override
  State<OiMenuBar> createState() => _OiMenuBarState();
}

class _OiMenuBarState extends State<OiMenuBar> {
  /// Index of the currently open top-level dropdown, or -1 for none.
  int _openIndex = -1;

  /// One [LayerLink] per top-level item, used to anchor the dropdown overlay.
  late List<LayerLink> _layerLinks;

  /// The active overlay entry, if any.
  OverlayEntry? _overlayEntry;

  /// A focus node for the menu bar to handle keyboard events.
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _layerLinks = List.generate(widget.items.length, (_) => LayerLink());
  }

  @override
  void didUpdateWidget(OiMenuBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.items.length != oldWidget.items.length) {
      _closeDropdown();
      _layerLinks = List.generate(widget.items.length, (_) => LayerLink());
    }
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _focusNode.dispose();
    super.dispose();
  }

  // ── Dropdown lifecycle ──────────────────────────────────────────────────

  void _openDropdown(int index) {
    if (index == _openIndex) return;

    _overlayEntry?.remove();
    _overlayEntry = null;

    if (index < 0 ||
        index >= widget.items.length ||
        widget.items[index].children == null ||
        widget.items[index].children!.isEmpty) {
      setState(() => _openIndex = -1);
      return;
    }

    setState(() => _openIndex = index);
    _focusNode.requestFocus();

    _overlayEntry = OverlayEntry(
      builder: (_) => _DropdownOverlay(
        items: widget.items[index].children!,
        link: _layerLinks[index],
        onClose: _closeDropdown,
        onItemTap: (item) {
          _closeDropdown();
          item.onTap?.call();
        },
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _closeDropdown() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (_openIndex != -1) {
      setState(() => _openIndex = -1);
    }
  }

  void _toggleDropdown(int index) {
    if (_openIndex == index) {
      _closeDropdown();
    } else {
      _openDropdown(index);
    }
  }

  void _onTopLevelHover(int index) {
    if (_openIndex != -1 && _openIndex != index) {
      _openDropdown(index);
    }
  }

  // ── Keyboard ────────────────────────────────────────────────────────────

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    if (event.logicalKey == LogicalKeyboardKey.escape) {
      _closeDropdown();
      return KeyEventResult.handled;
    }

    if (_openIndex == -1) return KeyEventResult.ignored;

    if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      final prev = (_openIndex - 1 + widget.items.length) % widget.items.length;
      _openDropdown(prev);
      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      final next = (_openIndex + 1) % widget.items.length;
      _openDropdown(next);
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  // ── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final effectiveBg = widget.backgroundColor ?? colors.surface;

    return Semantics(
      label: widget.label,
      container: true,
      explicitChildNodes: true,
      child: Focus(
        focusNode: _focusNode,
        onKeyEvent: _handleKeyEvent,
        child: Container(
          height: widget.height,
          color: effectiveBg,
          child: Row(
            children: [
              for (var i = 0; i < widget.items.length; i++)
                CompositedTransformTarget(
                  link: _layerLinks[i],
                  child: _TopLevelItem(
                    item: widget.items[i],
                    open: _openIndex == i,
                    onTap: () => _toggleDropdown(i),
                    onHover: () => _onTopLevelHover(i),
                    horizontalPadding: spacing.sm,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Top-level item ──────────────────────────────────────────────────────────

class _TopLevelItem extends StatelessWidget {
  const _TopLevelItem({
    required this.item,
    required this.open,
    required this.onTap,
    required this.onHover,
    required this.horizontalPadding,
  });

  final OiMenuItem item;
  final bool open;
  final VoidCallback onTap;
  final VoidCallback onHover;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final radius = context.radius;

    return MouseRegion(
      onEnter: (_) => onHover(),
      child: OiTappable(
        onTap: onTap,
        semanticLabel: item.semanticLabel ?? item.label,
        clipBorderRadius: radius.sm,
        child: Container(
          decoration: BoxDecoration(
            color: open ? colors.surfaceActive : null,
            borderRadius: radius.sm,
          ),
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          alignment: Alignment.center,
          child: OiLabel.small(item.label, color: colors.text),
        ),
      ),
    );
  }
}

// ── Dropdown overlay ────────────────────────────────────────────────────────

class _DropdownOverlay extends StatelessWidget {
  const _DropdownOverlay({
    required this.items,
    required this.link,
    required this.onClose,
    required this.onItemTap,
  });

  final List<OiMenuItem> items;
  final LayerLink link;
  final VoidCallback onClose;
  final ValueChanged<OiMenuItem> onItemTap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Tap-outside barrier.
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: onClose,
            child: const SizedBox.expand(),
          ),
        ),
        // Positioned dropdown panel.
        CompositedTransformFollower(
          link: link,
          showWhenUnlinked: false,
          offset: const Offset(0, 28),
          targetAnchor: Alignment.bottomLeft,
          child: _DropdownPanel(
            items: items,
            onClose: onClose,
            onItemTap: onItemTap,
          ),
        ),
      ],
    );
  }
}

class _DropdownPanel extends StatelessWidget {
  const _DropdownPanel({
    required this.items,
    required this.onClose,
    required this.onItemTap,
  });

  final List<OiMenuItem> items;
  final VoidCallback onClose;
  final ValueChanged<OiMenuItem> onItemTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final radius = context.radius;
    final shadows = context.shadows;
    final spacing = context.spacing;

    return Container(
      constraints: const BoxConstraints(minWidth: 180),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(color: colors.borderSubtle),
        borderRadius: radius.md,
        boxShadow: shadows.md,
      ),
      padding: EdgeInsets.symmetric(vertical: spacing.xs),
      child: IntrinsicWidth(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [for (final item in items) _buildItem(context, item)],
        ),
      ),
    );
  }

  Widget _buildItem(BuildContext context, OiMenuItem item) {
    if (item is OiMenuDivider) {
      return const _OiMenuDividerWidget();
    }

    return _DropdownItemWidget(item: item, onTap: () => onItemTap(item));
  }
}

// ── Dropdown item widget ────────────────────────────────────────────────────

class _DropdownItemWidget extends StatelessWidget {
  const _DropdownItemWidget({required this.item, required this.onTap});

  final OiMenuItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;

    // Determine the text color.
    Color textColor;
    if (!item.enabled) {
      textColor = colors.textMuted;
    } else if (item.destructive) {
      textColor = colors.error.base;
    } else {
      textColor = colors.text;
    }

    // Build the item content row.
    final children = <Widget>[];

    // Check indicator column (fixed width).
    if (item.checked != null) {
      children
        ..add(
          SizedBox(
            width: 16,
            child: item.checked!
                ? OiIcon.decorative(
                    icon: OiIcons.check,
                    size: 12,
                    color: textColor,
                  )
                : const SizedBox.shrink(),
          ),
        )
        ..add(SizedBox(width: spacing.xs));
    }

    // Optional leading icon.
    if (item.icon != null) {
      children
        ..add(OiIcon.decorative(icon: item.icon!, size: 14, color: textColor))
        ..add(SizedBox(width: spacing.sm));
    }

    // Label.
    children.add(Expanded(child: OiLabel.small(item.label, color: textColor)));

    // Shortcut hint (right-aligned, muted).
    if (item.shortcut != null) {
      children
        ..add(SizedBox(width: spacing.md))
        ..add(OiLabel.tiny(item.shortcut!, color: colors.textMuted));
    }

    return OiTappable(
      onTap: item.enabled ? onTap : null,
      enabled: item.enabled,
      semanticLabel: item.semanticLabel ?? item.label,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: spacing.sm,
          vertical: spacing.xs,
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: children),
      ),
    );
  }
}

// ── Divider widget ──────────────────────────────────────────────────────────

class _OiMenuDividerWidget extends StatelessWidget {
  const _OiMenuDividerWidget();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: spacing.xs),
      child: Container(height: 1, color: colors.borderSubtle),
    );
  }
}
