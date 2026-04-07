part of '../oi_context_menu.dart';

/// Keyboard focus and sub-menu state for [_MenuPanelState].
///
/// All [setState] calls for the menu panel live here.
mixin _MenuPanelKeyboardMixin on State<_MenuPanel> {
  int _focusedIndex = -1;
  int _keyboardSubMenuIndex = -1;

  List<int> _interactableIndices() => [
    for (var i = 0; i < widget.items.length; i++)
      if (widget.items[i] is! OiMenuDivider && widget.items[i].enabled) i,
  ];

  bool _itemHasChildren(int index) {
    if (index < 0 || index >= widget.items.length) return false;
    final item = widget.items[index];
    return item.children != null && item.children!.isNotEmpty;
  }

  void _applyFocusNext() {
    final interactable = _interactableIndices();
    if (interactable.isEmpty) return;
    final pos = interactable.indexOf(_focusedIndex);
    setState(() {
      _focusedIndex = interactable[(pos + 1) % interactable.length];
      _keyboardSubMenuIndex = -1;
    });
  }

  void _applyFocusPrevious() {
    final interactable = _interactableIndices();
    if (interactable.isEmpty) return;
    final pos = interactable.indexOf(_focusedIndex);
    setState(() {
      _focusedIndex =
          interactable[(pos - 1 + interactable.length) % interactable.length];
      _keyboardSubMenuIndex = -1;
    });
  }

  void _openKeyboardSubMenuForFocusedItem() {
    if (_focusedIndex >= 0 && _itemHasChildren(_focusedIndex)) {
      setState(() => _keyboardSubMenuIndex = _focusedIndex);
    }
  }

  void _onHoverRow(int i) {
    setState(() {
      _focusedIndex = i;
      _keyboardSubMenuIndex = -1;
    });
  }

  void _clearKeyboardSubMenuAndRefocus() {
    setState(() => _keyboardSubMenuIndex = -1);
    final panel = this as _MenuPanelState;
    panel._focusNode.requestFocus();
  }

  void _handleKey(KeyEvent event) {
    if (event is! KeyDownEvent) return;
    final key = event.logicalKey;
    final interactable = _interactableIndices();
    if (interactable.isEmpty) return;

    if (key == LogicalKeyboardKey.arrowDown) {
      _applyFocusNext();
    } else if (key == LogicalKeyboardKey.arrowUp) {
      _applyFocusPrevious();
    } else if (key == LogicalKeyboardKey.arrowRight) {
      _openKeyboardSubMenuForFocusedItem();
    } else if (key == LogicalKeyboardKey.arrowLeft) {
      if (widget.isSubMenu) {
        widget.onCloseSubMenu?.call();
      }
    } else if (key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.space) {
      if (_focusedIndex >= 0 && _focusedIndex < widget.items.length) {
        final item = widget.items[_focusedIndex];
        if (item.enabled && item is! OiMenuDivider) {
          if (_itemHasChildren(_focusedIndex)) {
            setState(() => _keyboardSubMenuIndex = _focusedIndex);
            return;
          }
          item.onTap?.call();
          widget.onClose();
        }
      }
    } else if (key == LogicalKeyboardKey.escape) {
      widget.onClose();
    }
  }
}

/// Hover / sub-menu open state for [_MenuItemRowState].
///
/// All [setState] calls for the row live here.
mixin _MenuItemRowInteractionMixin on State<_MenuItemRow> {
  bool _hovered = false;
  bool _hoverSubMenuOpen = false;
  Timer? _openTimer;
  Timer? _closeTimer;

  void _setHovered(bool value) {
    if (_hovered == value) return;
    setState(() => _hovered = value);
  }

  void _openHoverSubMenu() {
    final row = this as _MenuItemRowState;
    if (!row._hasChildren || _hoverSubMenuOpen) return;
    setState(() => _hoverSubMenuOpen = true);
  }

  void _closeHoverSubMenu() {
    if (!_hoverSubMenuOpen) return;
    setState(() => _hoverSubMenuOpen = false);
  }

  void _onMouseEnter() {
    _setHovered(true);
    widget.onHoverIndex();
    final row = this as _MenuItemRowState;
    if (row._hasChildren) {
      _closeTimer?.cancel();
      _openTimer?.cancel();
      _openTimer = Timer(const Duration(milliseconds: 150), _openHoverSubMenu);
    }
  }

  void _onMouseExit() {
    _setHovered(false);
    final row = this as _MenuItemRowState;
    if (row._hasChildren && _hoverSubMenuOpen) {
      _openTimer?.cancel();
      _closeTimer?.cancel();
      _closeTimer = Timer(
        const Duration(milliseconds: 300),
        _closeHoverSubMenu,
      );
    }
  }

  void _onSubMenuMouseEnter() {
    _closeTimer?.cancel();
  }

  void _onSubMenuMouseExit() {
    _closeTimer?.cancel();
    _closeTimer = Timer(const Duration(milliseconds: 300), _closeHoverSubMenu);
  }
}
