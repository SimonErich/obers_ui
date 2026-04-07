part of '../oi_context_menu.dart';

class _MenuItemRow extends StatefulWidget {
  const _MenuItemRow({
    required this.item,
    required this.focused,
    required this.keyboardSubMenuOpen,
    required this.onClose,
    required this.onHoverIndex,
    required this.onCloseKeyboardSubMenu,
  });

  final OiMenuItem item;
  final bool focused;
  final bool keyboardSubMenuOpen;
  final VoidCallback onClose;
  final VoidCallback onHoverIndex;
  final VoidCallback onCloseKeyboardSubMenu;

  @override
  State<_MenuItemRow> createState() => _MenuItemRowState();
}

class _MenuItemRowState extends State<_MenuItemRow>
    with _MenuItemRowInteractionMixin {
  final OverlayPortalController _portalController = OverlayPortalController();
  final GlobalKey _itemKey = GlobalKey();

  bool get _hasChildren =>
      widget.item.children != null && widget.item.children!.isNotEmpty;

  bool get _isSubMenuVisible => _hoverSubMenuOpen || widget.keyboardSubMenuOpen;

  @override
  void initState() {
    super.initState();
    if (_hasChildren) {
      _portalController.show();
    }
  }

  @override
  void dispose() {
    _openTimer?.cancel();
    _closeTimer?.cancel();
    super.dispose();
  }

  Rect _getItemRect() {
    final box = _itemKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return Rect.zero;
    return box.localToGlobal(Offset.zero) & box.size;
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    if (item is OiMenuDivider) {
      final colors = context.colors;
      final spacing = context.spacing;
      return Padding(
        padding: EdgeInsets.symmetric(vertical: spacing.xs),
        child: Container(height: 1, color: colors.borderSubtle),
      );
    }

    final colors = context.colors;
    final spacing = context.spacing;

    Color textColor;
    if (!item.enabled) {
      textColor = colors.textMuted;
    } else if (item.destructive) {
      textColor = colors.error.base;
    } else {
      textColor = colors.text;
    }

    final isHighlighted = _hovered || widget.focused;
    final bg = isHighlighted && item.enabled ? colors.surfaceHover : null;

    final children = <Widget>[];

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

    if (item.icon != null) {
      children
        ..add(OiIcon.decorative(icon: item.icon!, size: 14, color: textColor))
        ..add(SizedBox(width: spacing.sm));
    }

    children.add(Expanded(child: OiLabel.small(item.label, color: textColor)));

    if (item.shortcut != null) {
      children
        ..add(SizedBox(width: spacing.md))
        ..add(OiLabel.tiny(item.shortcut!, color: colors.textMuted));
    }

    if (_hasChildren) {
      children
        ..add(SizedBox(width: spacing.sm))
        ..add(
          OiIcon.decorative(
            icon: OiIcons.chevronRight,
            size: 12,
            color: colors.textMuted,
          ),
        );
    }

    Widget row = MouseRegion(
      key: _itemKey,
      onEnter: (_) => _onMouseEnter(),
      onExit: (_) => _onMouseExit(),
      child: OiTappable(
        onTap: item.enabled && !_hasChildren
            ? () {
                item.onTap?.call();
                widget.onClose();
              }
            : item.enabled && _hasChildren
            ? _openHoverSubMenu
            : null,
        enabled: item.enabled,
        semanticLabel: item.semanticLabel ?? item.label,
        child: Container(
          color: bg,
          padding: EdgeInsets.symmetric(
            horizontal: spacing.sm,
            vertical: spacing.xs,
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: children),
        ),
      ),
    );

    if (_hasChildren) {
      row = OverlayPortal(
        controller: _portalController,
        overlayChildBuilder: (_) {
          if (!_isSubMenuVisible) return const SizedBox.shrink();

          return MouseRegion(
            onEnter: (_) => _onSubMenuMouseEnter(),
            onExit: (_) => _onSubMenuMouseExit(),
            child: _SubMenuWrapper(
              parentRect: _getItemRect(),
              items: item.children!,
              onClose: widget.onClose,
              onCloseSubMenu: widget.onCloseKeyboardSubMenu,
            ),
          );
        },
        child: row,
      );
    }

    return row;
  }
}
