import 'package:flutter/widgets.dart';

/// A navigation destination used by `OiNavigationRail` and `OiBottomBar`.
///
/// Each item defines an [icon], a text [label], and optional overrides
/// for the active state ([activeIcon]), a textual [badge], a [tooltip],
/// and a [semanticLabel] for accessibility.
///
/// Use [OiNavigationItem.fromLegacy] to convert from the older
/// `OiBottomBarItem` API where badges were expressed as integer counts.
///
/// {@category Models}
@immutable
class OiNavigationItem {
  /// Creates an [OiNavigationItem].
  const OiNavigationItem({
    required this.icon,
    required this.label,
    this.activeIcon,
    this.badge,
    this.tooltip,
    this.semanticLabel,
  });

  /// Creates an [OiNavigationItem] from legacy `OiBottomBarItem` fields.
  ///
  /// When [showBadge] is `true` and [badgeCount] is a positive integer,
  /// the badge text is set to the count (capped at `'99+'`). Otherwise
  /// no badge is shown.
  factory OiNavigationItem.fromLegacy({
    required IconData icon,
    required String label,
    IconData? activeIcon,
    int? badgeCount,
    bool showBadge = true,
  }) {
    return OiNavigationItem(
      icon: icon,
      label: label,
      activeIcon: activeIcon,
      badge: (showBadge && badgeCount != null && badgeCount > 0)
          ? (badgeCount > 99 ? '99+' : '$badgeCount')
          : null,
    );
  }

  /// The icon displayed in the default (inactive) state.
  final IconData icon;

  /// The text label displayed below (or beside) the icon.
  final String label;

  /// An optional icon displayed when this item is selected.
  ///
  /// Falls back to [icon] when `null`.
  final IconData? activeIcon;

  /// An optional textual badge shown on the item (e.g. `'3'`, `'99+'`).
  final String? badge;

  /// An optional tooltip shown on long press or hover.
  final String? tooltip;

  /// An optional accessibility label announced by screen readers.
  ///
  /// Falls back to [label] when `null`.
  final String? semanticLabel;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OiNavigationItem &&
        other.icon == icon &&
        other.label == label &&
        other.activeIcon == activeIcon &&
        other.badge == badge &&
        other.tooltip == tooltip &&
        other.semanticLabel == semanticLabel;
  }

  @override
  int get hashCode =>
      Object.hash(icon, label, activeIcon, badge, tooltip, semanticLabel);
}
