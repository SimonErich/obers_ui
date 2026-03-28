import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/primitives/interaction/oi_touch_target.dart';

/// A menu item for the long-press context menu.
///
/// Each item has a [label], an [onTap] callback, and an optional [icon].
class OiLongPressMenuItem {
  /// Creates an [OiLongPressMenuItem].
  const OiLongPressMenuItem({
    required this.label,
    required this.onTap,
    this.icon,
  });

  /// The text label shown in the menu.
  final String label;

  /// Called when this menu item is tapped.
  final VoidCallback onTap;

  /// Optional icon shown alongside the [label].
  final IconData? icon;
}

/// A widget that shows a context menu overlay when its [child] is long-pressed.
///
/// When the user long-presses [child], an overlay menu containing [items] is
/// inserted near the press location. Tapping any item invokes its
/// [OiLongPressMenuItem.onTap] and closes the menu. Tapping outside the menu
/// also closes it. When [enabled] is `false` the long press is ignored.
///
/// ```dart
/// OiLongPressMenu(
///   items: [
///     OiLongPressMenuItem(label: 'Copy', onTap: _copy),
///     OiLongPressMenuItem(label: 'Share', onTap: _share),
///   ],
///   child: const Text('Long press me'),
/// )
/// ```
///
/// {@category Primitives}
class OiLongPressMenu extends StatefulWidget {
  /// Creates an [OiLongPressMenu].
  const OiLongPressMenu({
    required this.child,
    required this.items,
    this.enabled = true,
    this.direction = Axis.vertical,
    this.trailing,
    super.key,
  });

  /// The child that triggers the menu on long press.
  final Widget child;

  /// The menu items to show.
  final List<OiLongPressMenuItem> items;

  /// Whether the menu is enabled.
  ///
  /// When `false`, long presses on [child] are ignored.
  final bool enabled;

  /// The layout direction for menu items.
  ///
  /// Defaults to [Axis.vertical]. Use [Axis.horizontal] for compact
  /// emoji-style menus.
  final Axis direction;

  /// An optional trailing widget appended after all [items].
  final Widget? trailing;

  @override
  State<OiLongPressMenu> createState() => _OiLongPressMenuState();
}

class _OiLongPressMenuState extends State<OiLongPressMenu> {
  OverlayEntry? _overlayEntry;
  Offset _pressPosition = Offset.zero;

  void _showMenu() {
    _removeMenu();
    final overlay = Overlay.maybeOf(context);
    if (overlay == null) return;

    _overlayEntry = OverlayEntry(
      builder: (_) => _OiLongPressMenuOverlay(
        position: _pressPosition,
        items: widget.items,
        onClose: _removeMenu,
        direction: widget.direction,
        trailing: widget.trailing,
      ),
    );
    overlay.insert(_overlayEntry!);
  }

  void _removeMenu() {
    _overlayEntry?.remove();
    _overlayEntry?.dispose();
    _overlayEntry = null;
  }

  @override
  void dispose() {
    _removeMenu();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return OiTouchTarget(
      child: GestureDetector(
        onLongPress: widget.enabled ? _showMenu : null,
        onLongPressStart: widget.enabled
            ? (details) {
                _pressPosition = details.globalPosition;
              }
            : null,
        child: widget.child,
      ),
    );
  }
}

/// Internal overlay widget that positions and renders the menu.
class _OiLongPressMenuOverlay extends StatelessWidget {
  const _OiLongPressMenuOverlay({
    required this.position,
    required this.items,
    required this.onClose,
    required this.direction,
    this.trailing,
  });

  final Offset position;
  final List<OiLongPressMenuItem> items;
  final VoidCallback onClose;
  final Axis direction;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Full-screen transparent barrier — tap outside dismisses the menu.
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: onClose,
            child: const ColoredBox(color: Color(0x00000000)),
          ),
        ),
        // Menu panel positioned near the press point.
        Positioned(
          left: position.dx,
          top: position.dy,
          child: _OiMenuPanel(
            items: items,
            onClose: onClose,
            direction: direction,
            trailing: trailing,
          ),
        ),
      ],
    );
  }
}

/// Internal panel that renders the list of menu items.
class _OiMenuPanel extends StatelessWidget {
  const _OiMenuPanel({
    required this.items,
    required this.onClose,
    required this.direction,
    this.trailing,
  });

  final List<OiLongPressMenuItem> items;
  final VoidCallback onClose;
  final Axis direction;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final itemWidgets = items
        .map(
          (item) => GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              onClose();
              item.onTap();
            },
            child: Padding(
              padding: direction == Axis.horizontal
                  ? const EdgeInsets.symmetric(horizontal: 5, vertical: 5)
                  : const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Text(
                item.label,
                style: direction == Axis.horizontal
                    ? const TextStyle(fontSize: 20)
                    : null,
              ),
            ),
          ),
        )
        .toList();

    if (trailing != null) {
      itemWidgets.add(
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: direction == Axis.horizontal
                ? const EdgeInsets.symmetric(horizontal: 8, vertical: 8)
                : const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: trailing,
          ),
        ),
      );
    }

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Color(0xFFFFFFFF),
        borderRadius: BorderRadius.all(Radius.circular(8)),
        boxShadow: [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: direction == Axis.horizontal
          ? Row(mainAxisSize: MainAxisSize.min, children: itemWidgets)
          : IntrinsicWidth(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: itemWidgets,
              ),
            ),
    );
  }
}
