import 'package:flutter/widgets.dart';

/// A single item in an OiContextMenu or OiMenuBar dropdown.
///
/// Each item has a [label] and can optionally include an [icon], a keyboard
/// [shortcut] hint, nested [children] for sub-menus, a [checked] state for
/// toggle items, and a [destructive] flag for dangerous actions.
///
/// Use [OiMenuDivider] to render a horizontal separator instead of a
/// labelled row.
///
/// ```dart
/// OiMenuItem(
///   label: 'Delete',
///   icon: OiIcons.trash,
///   shortcut: 'Del',
///   destructive: true,
///   onTap: _handleDelete,
/// )
/// ```
///
/// {@category Components}
@immutable
class OiMenuItem {
  /// Creates an [OiMenuItem].
  const OiMenuItem({
    required this.label,
    this.icon,
    this.shortcut,
    this.onTap,
    this.enabled = true,
    this.checked,
    this.children,
    this.semanticLabel,
    this.destructive = false,
  });

  /// The display label for this item.
  final String label;

  /// An optional leading icon rendered before the label.
  final IconData? icon;

  /// A display-only keyboard shortcut hint (e.g. 'Cmd+S').
  ///
  /// This is purely visual — it does not register an actual key binding.
  final String? shortcut;

  /// Called when the item is tapped (ignored when [enabled] is `false`).
  final VoidCallback? onTap;

  /// Whether this item is interactive.
  ///
  /// When `false`, the item is shown greyed-out and taps are ignored.
  final bool enabled;

  /// The checked state of this item.
  ///
  /// When `null`, no check indicator is shown. When `true`, a checkmark icon
  /// is rendered. When `false`, an empty space of the same width is reserved
  /// so that checked and unchecked items remain aligned.
  final bool? checked;

  /// Nested child items that form a sub-menu.
  ///
  /// When non-null and non-empty, a chevron indicator is shown on the trailing
  /// edge and the sub-menu opens on hover (pointer) or tap (touch).
  final List<OiMenuItem>? children;

  /// An optional accessibility label for screen readers.
  ///
  /// Falls back to [label] when `null`.
  final String? semanticLabel;

  /// Whether this item represents a destructive action.
  ///
  /// When `true`, the item label is rendered with the error color.
  final bool destructive;
}

/// A visual separator in an OiContextMenu or OiMenuBar dropdown.
///
/// Renders as a thin horizontal divider line. Has no interactive behaviour.
///
/// {@category Components}
class OiMenuDivider extends OiMenuItem {
  /// Creates an [OiMenuDivider].
  const OiMenuDivider() : super(label: '');
}
