import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/overlays/oi_menu_item.dart';
import 'package:obers_ui/src/foundation/oi_icons.dart';
import 'package:obers_ui/src/foundation/oi_overlays.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/display/oi_icon.dart';
import 'package:obers_ui/src/primitives/display/oi_label.dart';
import 'package:obers_ui/src/primitives/interaction/oi_tappable.dart';

export 'package:obers_ui/src/components/overlays/oi_menu_item.dart';

/// A widget that opens a context menu on right-click (pointer) or long-press
/// (touch).
///
/// The menu appears at the cursor/finger position via the [Overlay]. Keyboard
/// navigation with arrow keys, Enter/Space to select, and Escape to dismiss
/// is supported. Disabled items are shown greyed-out and cannot be selected.
/// Sub-menus open on hover (pointer) or tap (touch), and via right-arrow key.
///
/// ```dart
/// OiContextMenu(
///   label: 'File options',
///   items: [
///     OiMenuItem(label: 'Cut', shortcut: 'Cmd+X', onTap: _cut),
///     OiMenuItem(label: 'Copy', shortcut: 'Cmd+C', onTap: _copy),
///     const OiMenuDivider(),
///     OiMenuItem(
///       label: 'Share',
///       icon: OiIcons.share,
///       children: [
///         OiMenuItem(label: 'Email', onTap: _shareEmail),
///         OiMenuItem(label: 'Link', onTap: _shareLink),
///       ],
///     ),
///     const OiMenuDivider(),
///     OiMenuItem(label: 'Delete', destructive: true, onTap: _delete),
///   ],
///   child: myWidget,
/// )
/// ```
///
/// {@category Components}
class OiContextMenu extends StatefulWidget {
  /// Creates an [OiContextMenu].
  const OiContextMenu({
    required this.label,
    required this.child,
    required this.items,
    this.enabled = true,
    super.key,
  });

  /// The accessible label describing this context menu for screen readers.
  final String label;

  /// The widget that triggers the context menu.
  final Widget child;

  /// The menu items to display.
  final List<OiMenuItem> items;

  /// Whether the context menu is active. Defaults to `true`.
  final bool enabled;

  @override
  State<OiContextMenu> createState() => _OiContextMenuState();
}

class _OiContextMenuState extends State<OiContextMenu> {
  OiOverlayHandle? _handle;

  void _show(Offset globalPosition) {
    _close();

    final overlays = OiOverlays.maybeOf(context);
    if (overlays != null) {
      _handle = overlays.show(
        label: widget.label,
        zOrder: OiOverlayZOrder.dropdown,
        onDismiss: _close,
        builder: (_) => _ContextMenuRoot(
          position: globalPosition,
          items: widget.items,
          onClose: _close,
        ),
      );
    } else {
      // Fallback when OiOverlays is not in the tree (e.g. tests).
      final overlay = Overlay.of(context);
      late final OverlayEntry entry;
      entry = OverlayEntry(
        builder: (_) => Semantics(
          label: widget.label,
          scopesRoute: true,
          explicitChildNodes: true,
          child: Stack(
            children: [
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: _close,
                  child: const SizedBox.expand(),
                ),
              ),
              _ContextMenuRoot(
                position: globalPosition,
                items: widget.items,
                onClose: _close,
              ),
            ],
          ),
        ),
      );
      overlay.insert(entry);
      _handle = createOiOverlayHandle(entry);
    }
  }

  void _close() {
    final handle = _handle;
    _handle = null;
    handle?.dismiss();
  }

  @override
  void dispose() {
    _close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;

    return Listener(
      // Right-click on pointer devices.
      onPointerDown: (e) {
        if (e.buttons == kSecondaryMouseButton) {
          _show(e.position);
        }
      },
      child: GestureDetector(
        onLongPressStart: (d) => _show(d.globalPosition),
        child: widget.child,
      ),
    );
  }
}

// ── Root overlay content ───────────────────────────────────────────────────

class _ContextMenuRoot extends StatefulWidget {
  const _ContextMenuRoot({
    required this.position,
    required this.items,
    required this.onClose,
  });

  final Offset position;
  final List<OiMenuItem> items;
  final VoidCallback onClose;

  @override
  State<_ContextMenuRoot> createState() => _ContextMenuRootState();
}

class _ContextMenuRootState extends State<_ContextMenuRoot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.92,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduced =
        context.animations.reducedMotion ||
        (MediaQuery.maybeDisableAnimationsOf(context) ?? false);
    _controller.duration = reduced
        ? Duration.zero
        : const Duration(milliseconds: 150);
    if (!_controller.isAnimating && _controller.value == 0) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Determine the scale origin based on where the menu would be placed.
  ///
  /// If the cursor is near the right/bottom edge of the screen, the menu is
  /// shifted left/up, so the animation should originate from the corresponding
  /// corner rather than always top-left.
  Alignment _scaleAlignment(BuildContext context) {
    final screen = MediaQuery.sizeOf(context);
    const padding = 8.0;
    // Use a rough estimate — the exact child size isn't available here, but
    // 200px is a reasonable menu height/width heuristic for alignment choice.
    const estimate = 200.0;

    final overflowsRight =
        widget.position.dx + estimate > screen.width - padding;
    final overflowsBottom =
        widget.position.dy + estimate > screen.height - padding;

    return Alignment(overflowsRight ? 1 : -1, overflowsBottom ? 1 : -1);
  }

  @override
  Widget build(BuildContext context) {
    return CustomSingleChildLayout(
      delegate: _CursorPositionDelegate(
        cursorPosition: widget.position,
        screenPadding: const EdgeInsets.all(8),
      ),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          alignment: _scaleAlignment(context),
          child: _MenuPanel(items: widget.items, onClose: widget.onClose),
        ),
      ),
    );
  }
}

// ── Cursor-relative positioning delegate ───────────────────────────────────

class _CursorPositionDelegate extends SingleChildLayoutDelegate {
  const _CursorPositionDelegate({
    required this.cursorPosition,
    required this.screenPadding,
  });

  final Offset cursorPosition;
  final EdgeInsets screenPadding;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    final maxW =
        (constraints.maxWidth - screenPadding.left - screenPadding.right).clamp(
          0.0,
          double.infinity,
        );
    final maxH =
        (constraints.maxHeight - screenPadding.top - screenPadding.bottom)
            .clamp(0.0, double.infinity);
    return BoxConstraints(maxWidth: maxW, maxHeight: maxH);
  }

  @override
  Offset getPositionForChild(Size screenSize, Size childSize) {
    final safeRight = screenSize.width - screenPadding.right;
    final safeBottom = screenSize.height - screenPadding.bottom;

    var x = cursorPosition.dx;
    var y = cursorPosition.dy;

    // Shift left if overflowing right edge.
    if (x + childSize.width > safeRight) {
      x = safeRight - childSize.width;
    }
    // Shift up if overflowing bottom edge.
    if (y + childSize.height > safeBottom) {
      y = safeBottom - childSize.height;
    }

    // Clamp to minimum safe area.
    x = x.clamp(screenPadding.left, safeRight);
    y = y.clamp(screenPadding.top, safeBottom);

    return Offset(x, y);
  }

  @override
  bool shouldRelayout(_CursorPositionDelegate old) =>
      cursorPosition != old.cursorPosition ||
      screenPadding != old.screenPadding;
}

// ── Menu panel ─────────────────────────────────────────────────────────────

class _MenuPanel extends StatefulWidget {
  const _MenuPanel({
    required this.items,
    required this.onClose,
    this.onCloseSubMenu,
    this.isSubMenu = false,
  });

  final List<OiMenuItem> items;
  final VoidCallback onClose;

  /// Called when this sub-menu should close itself (left-arrow in sub-menu).
  final VoidCallback? onCloseSubMenu;
  final bool isSubMenu;

  @override
  State<_MenuPanel> createState() => _MenuPanelState();
}

class _MenuPanelState extends State<_MenuPanel> {
  final FocusNode _focusNode = FocusNode();
  int _focusedIndex = -1;

  /// Index of the item whose sub-menu is currently open via keyboard.
  int _keyboardSubMenuIndex = -1;

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

  List<int> _interactableIndices() => [
    for (var i = 0; i < widget.items.length; i++)
      if (widget.items[i] is! OiMenuDivider && widget.items[i].enabled) i,
  ];

  bool _itemHasChildren(int index) {
    if (index < 0 || index >= widget.items.length) return false;
    final item = widget.items[index];
    return item.children != null && item.children!.isNotEmpty;
  }

  void _handleKey(KeyEvent event) {
    if (event is! KeyDownEvent) return;
    final key = event.logicalKey;
    final interactable = _interactableIndices();
    if (interactable.isEmpty) return;

    if (key == LogicalKeyboardKey.arrowDown) {
      final pos = interactable.indexOf(_focusedIndex);
      setState(() {
        _focusedIndex = interactable[(pos + 1) % interactable.length];
        _keyboardSubMenuIndex = -1;
      });
    } else if (key == LogicalKeyboardKey.arrowUp) {
      final pos = interactable.indexOf(_focusedIndex);
      setState(() {
        _focusedIndex =
            interactable[(pos - 1 + interactable.length) % interactable.length];
        _keyboardSubMenuIndex = -1;
      });
    } else if (key == LogicalKeyboardKey.arrowRight) {
      // Open sub-menu of focused item.
      if (_focusedIndex >= 0 && _itemHasChildren(_focusedIndex)) {
        setState(() => _keyboardSubMenuIndex = _focusedIndex);
      }
    } else if (key == LogicalKeyboardKey.arrowLeft) {
      // Close this sub-menu panel and return focus to parent.
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
                    onHoverIndex: () => setState(() {
                      _focusedIndex = i;
                      _keyboardSubMenuIndex = -1;
                    }),
                    onCloseKeyboardSubMenu: () {
                      setState(() => _keyboardSubMenuIndex = -1);
                      _focusNode.requestFocus();
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Menu item row ──────────────────────────────────────────────────────────

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

class _MenuItemRowState extends State<_MenuItemRow> {
  bool _hovered = false;
  bool _hoverSubMenuOpen = false;
  Timer? _openTimer;
  Timer? _closeTimer;

  final OverlayPortalController _portalController = OverlayPortalController();
  final GlobalKey _itemKey = GlobalKey();

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

  bool get _hasChildren =>
      widget.item.children != null && widget.item.children!.isNotEmpty;

  /// Whether the sub-menu is visible via either hover or keyboard.
  bool get _isSubMenuVisible => _hoverSubMenuOpen || widget.keyboardSubMenuOpen;

  void _openHoverSubMenu() {
    if (!_hasChildren || _hoverSubMenuOpen) return;
    setState(() => _hoverSubMenuOpen = true);
  }

  void _closeHoverSubMenu() {
    if (!_hoverSubMenuOpen) return;
    setState(() => _hoverSubMenuOpen = false);
  }

  void _onMouseEnter() {
    setState(() => _hovered = true);
    widget.onHoverIndex();
    if (_hasChildren) {
      _closeTimer?.cancel();
      _openTimer?.cancel();
      _openTimer = Timer(const Duration(milliseconds: 150), _openHoverSubMenu);
    }
  }

  void _onMouseExit() {
    setState(() => _hovered = false);
    if (_hasChildren && _hoverSubMenuOpen) {
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

  Rect _getItemRect() {
    final box = _itemKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return Rect.zero;
    return box.localToGlobal(Offset.zero) & box.size;
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    // ── Divider ──
    if (item is OiMenuDivider) {
      final colors = context.colors;
      final spacing = context.spacing;
      return Padding(
        padding: EdgeInsets.symmetric(vertical: spacing.xs),
        child: Container(height: 1, color: colors.borderSubtle),
      );
    }

    // ── Regular item ──
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

    // Check indicator column.
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

    // Leading icon.
    if (item.icon != null) {
      children
        ..add(OiIcon.decorative(icon: item.icon!, size: 14, color: textColor))
        ..add(SizedBox(width: spacing.sm));
    }

    // Label.
    children.add(Expanded(child: OiLabel.small(item.label, color: textColor)));

    // Shortcut hint.
    if (item.shortcut != null) {
      children
        ..add(SizedBox(width: spacing.md))
        ..add(OiLabel.tiny(item.shortcut!, color: colors.textMuted));
    }

    // Sub-menu chevron.
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

    // Wrap with sub-menu portal if this item has children.
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

// ── Sub-menu wrapper with animation ────────────────────────────────────────

class _SubMenuWrapper extends StatefulWidget {
  const _SubMenuWrapper({
    required this.parentRect,
    required this.items,
    required this.onClose,
    required this.onCloseSubMenu,
  });

  final Rect parentRect;
  final List<OiMenuItem> items;
  final VoidCallback onClose;
  final VoidCallback onCloseSubMenu;

  @override
  State<_SubMenuWrapper> createState() => _SubMenuWrapperState();
}

class _SubMenuWrapperState extends State<_SubMenuWrapper>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 120),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduced =
        context.animations.reducedMotion ||
        (MediaQuery.maybeDisableAnimationsOf(context) ?? false);
    _controller.duration = reduced
        ? Duration.zero
        : const Duration(milliseconds: 120);
    if (!_controller.isAnimating && _controller.value == 0) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomSingleChildLayout(
      delegate: _SubMenuPositionDelegate(
        parentRect: widget.parentRect,
        screenPadding: const EdgeInsets.all(8),
      ),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          alignment: Alignment.topLeft,
          child: _MenuPanel(
            items: widget.items,
            onClose: widget.onClose,
            onCloseSubMenu: widget.onCloseSubMenu,
            isSubMenu: true,
          ),
        ),
      ),
    );
  }
}

// ── Sub-menu positioning delegate ──────────────────────────────────────────

class _SubMenuPositionDelegate extends SingleChildLayoutDelegate {
  const _SubMenuPositionDelegate({
    required this.parentRect,
    required this.screenPadding,
  });

  final Rect parentRect;
  final EdgeInsets screenPadding;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    final maxW =
        (constraints.maxWidth - screenPadding.left - screenPadding.right).clamp(
          0.0,
          double.infinity,
        );
    final maxH =
        (constraints.maxHeight - screenPadding.top - screenPadding.bottom)
            .clamp(0.0, double.infinity);
    return BoxConstraints(maxWidth: maxW, maxHeight: maxH);
  }

  @override
  Offset getPositionForChild(Size screenSize, Size childSize) {
    final safeLeft = screenPadding.left;
    final safeTop = screenPadding.top;
    final safeRight = screenSize.width - screenPadding.right;
    final safeBottom = screenSize.height - screenPadding.bottom;

    // Preferred: right-start (sub-menu opens to the right of parent item).
    var x = parentRect.right;
    var y = parentRect.top;

    // Flip to left if overflowing right edge.
    if (x + childSize.width > safeRight) {
      final flippedX = parentRect.left - childSize.width;
      if (flippedX >= safeLeft) {
        x = flippedX;
      } else {
        // Neither side fits fully — clamp to available space.
        x = safeRight - childSize.width;
      }
    }

    // Shift up if overflowing bottom edge.
    if (y + childSize.height > safeBottom) {
      y = safeBottom - childSize.height;
    }

    // Final clamp.
    x = x.clamp(safeLeft, math.max(safeLeft, safeRight - childSize.width));
    y = y.clamp(safeTop, math.max(safeTop, safeBottom - childSize.height));

    return Offset(x, y);
  }

  @override
  bool shouldRelayout(_SubMenuPositionDelegate old) =>
      parentRect != old.parentRect || screenPadding != old.screenPadding;
}
