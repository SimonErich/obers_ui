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

part 'oi_context_menu/oi_context_menu_layout_delegates.part.dart';
part 'oi_context_menu/oi_context_menu_interactions.part.dart';
part 'oi_context_menu/oi_context_menu_panel.part.dart';
part 'oi_context_menu/oi_context_menu_item_row.part.dart';
part 'oi_context_menu/oi_context_menu_submenu.part.dart';
part 'oi_context_menu/oi_context_menu_root.part.dart';

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
