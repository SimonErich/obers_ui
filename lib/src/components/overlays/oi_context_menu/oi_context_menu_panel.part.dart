part of '../oi_context_menu.dart';

class _MenuPanel extends StatefulWidget {
  const _MenuPanel({
    required this.items,
    required this.onClose,
    this.onCloseSubMenu,
    this.isSubMenu = false,
  });

  final List<OiMenuItem> items;
  final VoidCallback onClose;
  final VoidCallback? onCloseSubMenu;
  final bool isSubMenu;

  @override
  State<_MenuPanel> createState() => _MenuPanelState();
}

class _MenuPanelState extends State<_MenuPanel> with _MenuPanelKeyboardMixin {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final radius = context.radius;
    final shadows = context.shadows;
    final spacing = context.spacing;
    final themeData = context.components.contextMenu;

    final maxH =
        themeData?.maxHeight ?? (MediaQuery.sizeOf(context).height - 16);

    return KeyboardListener(
      focusNode: _focusNode,
      onKeyEvent: _handleKey,
      child: Container(
        constraints: BoxConstraints(
          minWidth: themeData?.minWidth ?? 180,
          maxWidth: themeData?.maxWidth ?? 280,
          maxHeight: maxH,
        ),
        decoration: BoxDecoration(
          color: themeData?.backgroundColor ?? colors.surface,
          borderRadius: themeData?.borderRadius ?? radius.md,
          border: Border.all(
            color: themeData?.borderColor ?? colors.borderSubtle,
          ),
          boxShadow: themeData?.shadow ?? shadows.md,
        ),
        padding: EdgeInsets.symmetric(vertical: spacing.xs),
        child: SingleChildScrollView(
          child: IntrinsicWidth(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < widget.items.length; i++)
                  _MenuItemRow(
                    item: widget.items[i],
                    focused: _focusedIndex == i,
                    keyboardSubMenuOpen: _keyboardSubMenuIndex == i,
                    onClose: widget.onClose,
                    onHoverIndex: () => _onHoverRow(i),
                    onCloseKeyboardSubMenu: _clearKeyboardSubMenuAndRefocus,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
