import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/theme/oi_color_scheme.dart';
import 'package:obers_ui/src/foundation/theme/oi_text_theme.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/interaction/oi_tappable.dart';

/// A single item in an [OiContextMenu].
///
/// Set [separator] to `true` to render a divider rule instead of a label.
/// Set [subMenu] to nest a child menu that opens on hover.
///
/// {@category Components}
@immutable
class OiMenuItem {
  /// Creates an [OiMenuItem].
  const OiMenuItem({
    required this.label,
    this.icon,
    this.onTap,
    this.disabled = false,
    this.separator = false,
    this.subMenu,
  });

  /// The display label for this item.
  final String label;

  /// An optional leading icon.
  final IconData? icon;

  /// Called when the item is tapped (ignored when [disabled] is `true`).
  final VoidCallback? onTap;

  /// Whether the item is non-interactive.
  final bool disabled;

  /// When `true`, renders a horizontal divider instead of a labelled row.
  final bool separator;

  /// Nested sub-menu items, opened on hover.
  final List<OiMenuItem>? subMenu;
}

// ── Internal menu panel ──────────────────────────────────────────────────────

class _MenuPanel extends StatefulWidget {
  const _MenuPanel({required this.items, required this.onClose});

  final List<OiMenuItem> items;
  final VoidCallback onClose;

  @override
  State<_MenuPanel> createState() => _MenuPanelState();
}

class _MenuPanelState extends State<_MenuPanel> {
  int _focusedIndex = -1;
  int _hoveredSubMenu = -1;

  void _handleKey(KeyEvent event) {
    if (event is! KeyDownEvent) return;
    final key = event.logicalKey;
    final interactable = _interactableIndices();
    if (interactable.isEmpty) return;

    if (key == LogicalKeyboardKey.arrowDown) {
      final pos = interactable.indexOf(_focusedIndex);
      setState(() {
        _focusedIndex = interactable[(pos + 1) % interactable.length];
      });
    } else if (key == LogicalKeyboardKey.arrowUp) {
      final pos = interactable.indexOf(_focusedIndex);
      setState(() {
        _focusedIndex =
            interactable[(pos - 1 + interactable.length) % interactable.length];
      });
    } else if (key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.space) {
      if (_focusedIndex >= 0 && _focusedIndex < widget.items.length) {
        final item = widget.items[_focusedIndex];
        if (!item.disabled && !item.separator) {
          item.onTap?.call();
          widget.onClose();
        }
      }
    } else if (key == LogicalKeyboardKey.escape) {
      widget.onClose();
    }
  }

  List<int> _interactableIndices() => [
    for (var i = 0; i < widget.items.length; i++)
      if (!widget.items[i].separator && !widget.items[i].disabled) i,
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = context.textTheme;

    return KeyboardListener(
      focusNode: FocusNode()..requestFocus(),
      onKeyEvent: _handleKey,
      child: Container(
        constraints: const BoxConstraints(minWidth: 160, maxWidth: 280),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: colors.border),
          boxShadow: [
            BoxShadow(
              color: colors.overlay.withValues(alpha: 0.15),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < widget.items.length; i++)
                _buildItem(i, colors, textTheme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItem(int i, OiColorScheme colors, OiTextTheme textTheme) {
    final item = widget.items[i];

    if (item.separator) {
      return Container(
        height: 1,
        margin: const EdgeInsets.symmetric(vertical: 4),
        color: colors.borderSubtle,
      );
    }

    final isFocused = _focusedIndex == i;
    final bg = isFocused ? colors.surfaceHover : const Color(0x00000000);

    Widget row = Container(
      color: bg,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          if (item.icon != null) ...[
            Icon(
              item.icon,
              size: 16,
              color: item.disabled ? colors.textMuted : colors.textSubtle,
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(
              item.label,
              style: textTheme.small.copyWith(
                color: item.disabled ? colors.textMuted : colors.text,
              ),
            ),
          ),
          if (item.subMenu != null)
            Text('›', style: TextStyle(color: colors.textMuted, fontSize: 14)),
        ],
      ),
    );

    if (item.subMenu != null) {
      final hasSubMenu = item.subMenu!.isNotEmpty;
      row = MouseRegion(
        onEnter: (_) => setState(() => _hoveredSubMenu = i),
        onExit: (_) => setState(() {
          if (_hoveredSubMenu == i) _hoveredSubMenu = -1;
        }),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            row,
            if (_hoveredSubMenu == i && hasSubMenu)
              Positioned(
                left: double.infinity,
                top: 0,
                child: _MenuPanel(
                  items: item.subMenu!,
                  onClose: widget.onClose,
                ),
              ),
          ],
        ),
      );
    }

    if (!item.disabled && !item.separator) {
      row = OiTappable(
        onTap: () {
          item.onTap?.call();
          widget.onClose();
        },
        child: row,
      );
    }

    return row;
  }
}

/// A widget that opens a context menu on right-click (pointer) or long-press
/// (touch).
///
/// The menu appears at the cursor/finger position via the [Overlay]. Keyboard
/// navigation with arrow keys, Enter/Space to select, and Escape to dismiss
/// is supported. Disabled items are shown greyed-out and cannot be selected.
/// Sub-menus open on hover.
///
/// {@category Components}
class OiContextMenu extends StatefulWidget {
  /// Creates an [OiContextMenu].
  const OiContextMenu({
    required this.child,
    required this.items,
    this.enabled = true,
    super.key,
  });

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
  OverlayEntry? _entry;

  void _show(Offset globalPosition) {
    _close();
    final overlay = Overlay.of(context);

    _entry = OverlayEntry(
      builder: (ctx) => _OiContextMenuOverlay(
        position: globalPosition,
        items: widget.items,
        onClose: _close,
      ),
    );
    overlay.insert(_entry!);
  }

  void _close() {
    _entry?.remove();
    _entry?.dispose();
    _entry = null;
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

/// Overlay content: full-screen barrier + positioned menu panel.
class _OiContextMenuOverlay extends StatelessWidget {
  const _OiContextMenuOverlay({
    required this.position,
    required this.items,
    required this.onClose,
  });

  final Offset position;
  final List<OiMenuItem> items;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Full-screen barrier — tap outside closes.
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onClose,
            child: const SizedBox.expand(),
          ),
        ),
        // Menu panel at cursor position.
        Positioned(
          left: position.dx,
          top: position.dy,
          child: _MenuPanel(items: items, onClose: onClose),
        ),
      ],
    );
  }
}
