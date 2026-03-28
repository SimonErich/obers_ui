import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/display/oi_avatar.dart';
import 'package:obers_ui/src/components/display/oi_badge.dart';
import 'package:obers_ui/src/components/inputs/oi_switch_tile.dart';
import 'package:obers_ui/src/foundation/oi_icons.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/display/oi_divider.dart';
import 'package:obers_ui/src/primitives/display/oi_label.dart';
import 'package:obers_ui/src/primitives/interaction/oi_tappable.dart';

// ---------------------------------------------------------------------------
// Data classes
// ---------------------------------------------------------------------------

/// Header configuration for an [OiDrawerNavigation].
///
/// {@category Modules}
@immutable
class OiDrawerHeader {
  /// Creates an [OiDrawerHeader].
  const OiDrawerHeader({
    required this.name,
    this.subtitle,
    this.avatarUrl,
    this.avatarWidget,
    this.onTap,
  });

  /// The user or account name shown in the header.
  final String name;

  /// Optional secondary text shown below [name].
  final String? subtitle;

  /// Optional avatar image URL passed to [OiAvatar].
  final String? avatarUrl;

  /// Optional custom avatar widget that overrides the default [OiAvatar].
  final Widget? avatarWidget;

  /// Called when the header area is tapped.
  final VoidCallback? onTap;
}

/// A navigation item in an [OiDrawerNavigation].
///
/// {@category Modules}
@immutable
class OiDrawerItem {
  /// Creates an [OiDrawerItem].
  const OiDrawerItem({
    required this.key,
    required this.label,
    this.icon,
    this.badge,
    this.children,
    this.trailing,
    this.onTap,
    this.disabled = false,
  });

  /// Unique key used to identify this item for selection.
  final Object key;

  /// The display label for this navigation item.
  final String label;

  /// Optional leading icon.
  final IconData? icon;

  /// Optional badge text shown to the right of the label.
  final String? badge;

  /// Child items that form a nested submenu.
  final List<OiDrawerItem>? children;

  /// Optional trailing widget displayed at the end of the row.
  final Widget? trailing;

  /// Called when this item is tapped (leaf items only).
  final VoidCallback? onTap;

  /// Whether this item is disabled and not tappable.
  final bool disabled;
}

/// A section in an [OiDrawerNavigation].
///
/// {@category Modules}
@immutable
class OiDrawerSection {
  /// Creates an [OiDrawerSection].
  const OiDrawerSection({required this.items, this.title, this.toggles});

  /// The navigation items in this section.
  final List<OiDrawerItem> items;

  /// Optional title displayed above the items.
  final String? title;

  /// Optional toggle switches displayed below the items.
  final List<OiDrawerToggle>? toggles;
}

/// A fast-toggle switch in an [OiDrawerNavigation].
///
/// {@category Modules}
@immutable
class OiDrawerToggle {
  /// Creates an [OiDrawerToggle].
  const OiDrawerToggle({
    required this.label,
    required this.value,
    required this.onChanged,
    this.icon,
  });

  /// The label for this toggle.
  final String label;

  /// Whether the toggle is currently on.
  final bool value;

  /// Called when the toggle value changes.
  final ValueChanged<bool> onChanged;

  /// Optional leading icon for the toggle row.
  final IconData? icon;
}

// ---------------------------------------------------------------------------
// Main widget
// ---------------------------------------------------------------------------

/// An animated navigation drawer with user header, sections, fast-toggle
/// tiles, and nested submenus with slide animation.
///
/// Sections are rendered as groups of tappable navigation items, optionally
/// preceded by a section title and followed by toggle switches. Items with
/// [OiDrawerItem.children] open a nested submenu view with a back button.
///
/// ```dart
/// OiDrawerNavigation(
///   label: 'Main navigation',
///   header: OiDrawerHeader(name: 'Jane Doe', subtitle: 'Admin'),
///   sections: [
///     OiDrawerSection(
///       title: 'Main',
///       items: [
///         OiDrawerItem(key: 'home', label: 'Home', icon: OiIcons.house),
///         OiDrawerItem(key: 'settings', label: 'Settings'),
///       ],
///     ),
///   ],
///   selectedKey: 'home',
///   onItemTap: (item) {},
/// )
/// ```
///
/// {@category Modules}
class OiDrawerNavigation extends StatefulWidget {
  /// Creates an [OiDrawerNavigation].
  const OiDrawerNavigation({
    required this.sections,
    required this.label,
    this.header,
    this.footer,
    this.selectedKey,
    this.onItemTap,
    this.width = 300,
    this.showDividers = true,
    super.key,
  });

  /// The sections to display in the drawer.
  final List<OiDrawerSection> sections;

  /// Accessibility label for the entire drawer.
  final String label;

  /// Optional header shown at the top of the drawer.
  final OiDrawerHeader? header;

  /// Optional footer widget pinned to the bottom.
  final Widget? footer;

  /// The key of the currently selected item.
  final Object? selectedKey;

  /// Called when a leaf item is tapped.
  final ValueChanged<OiDrawerItem>? onItemTap;

  /// The width of the drawer in logical pixels.
  final double width;

  /// Whether to show dividers between sections.
  final bool showDividers;

  @override
  State<OiDrawerNavigation> createState() => _OiDrawerNavigationState();
}

class _OiDrawerNavigationState extends State<OiDrawerNavigation>
    with TickerProviderStateMixin {
  /// Stack of parent items representing the current submenu path.
  /// Empty means root view.
  final List<OiDrawerItem> _submenuStack = [];

  late AnimationController _animationController;

  /// Direction of the slide: 1 = slide in from right, -1 = slide from left.
  double _slideDirection = 1;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _pushSubmenu(OiDrawerItem parent) {
    setState(() {
      _slideDirection = 1;
      _submenuStack.add(parent);
    });
    _animationController
      ..reset()
      ..forward();
  }

  void _popSubmenu() {
    setState(() {
      _slideDirection = -1;
      _submenuStack.removeLast();
    });
    _animationController
      ..reset()
      ..forward();
  }

  void _handleItemTap(OiDrawerItem item) {
    if (item.disabled) return;

    if (item.children != null && item.children!.isNotEmpty) {
      _pushSubmenu(item);
    } else {
      item.onTap?.call();
      widget.onItemTap?.call(item);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Semantics(
      label: widget.label,
      container: true,
      child: SizedBox(
        width: widget.width,
        child: DecoratedBox(
          decoration: BoxDecoration(color: colors.surface),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.header != null) _buildHeader(context),
              if (widget.header != null && widget.showDividers)
                const OiDivider(),
              Expanded(child: _buildContent(context)),
              if (widget.footer != null) ...[
                if (widget.showDividers) const OiDivider(),
                _buildFooter(context),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final header = widget.header!;
    final colors = context.colors;
    final spacing = context.spacing;

    final avatar =
        header.avatarWidget ??
        OiAvatar(
          semanticLabel: header.name,
          imageUrl: header.avatarUrl,
          initials: _initials(header.name),
        );

    final content = Padding(
      padding: EdgeInsets.symmetric(
        horizontal: spacing.md,
        vertical: spacing.md,
      ),
      child: Row(
        children: [
          avatar,
          SizedBox(width: spacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                OiLabel.body(
                  header.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (header.subtitle != null)
                  OiLabel.small(
                    header.subtitle!,
                    color: colors.textMuted,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ],
      ),
    );

    if (header.onTap != null) {
      return OiTappable(
        onTap: header.onTap,
        semanticLabel: 'User profile: ${header.name}',
        child: content,
      );
    }

    return content;
  }

  Widget _buildContent(BuildContext context) {
    final child = _submenuStack.isEmpty
        ? _buildRootSections(context)
        : _buildSubmenu(context);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        final offset = Tween<Offset>(
          begin: Offset(_slideDirection * 0.3, 0),
          end: Offset.zero,
        ).animate(animation);
        return SlideTransition(position: offset, child: child);
      },
      child: KeyedSubtree(
        key: ValueKey<int>(_submenuStack.length),
        child: child,
      ),
    );
  }

  Widget _buildRootSections(BuildContext context) {
    final spacing = context.spacing;
    final sections = widget.sections;
    final children = <Widget>[];

    for (var i = 0; i < sections.length; i++) {
      final section = sections[i];

      // Section title
      if (section.title != null) {
        children.add(
          Padding(
            padding: EdgeInsets.only(
              left: spacing.md,
              right: spacing.md,
              top: i == 0 ? spacing.sm : spacing.md,
              bottom: spacing.xs,
            ),
            child: OiLabel.caption(
              section.title!.toUpperCase(),
              color: context.colors.textMuted,
            ),
          ),
        );
      }

      // Items
      for (final item in section.items) {
        children.add(_buildItem(context, item));
      }

      // Toggles
      if (section.toggles != null) {
        for (final toggle in section.toggles!) {
          children.add(_buildToggle(context, toggle));
        }
      }

      // Divider between sections
      if (widget.showDividers && i < sections.length - 1) {
        children.add(
          Padding(
            padding: EdgeInsets.symmetric(vertical: spacing.xs),
            child: const OiDivider(),
          ),
        );
      }
    }

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(vertical: spacing.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }

  Widget _buildItem(BuildContext context, OiDrawerItem item) {
    final colors = context.colors;
    final spacing = context.spacing;
    final isSelected =
        widget.selectedKey != null && widget.selectedKey == item.key;
    final hasChildren = item.children != null && item.children!.isNotEmpty;

    const iconSize = 20.0;

    final rowChildren = <Widget>[
      if (item.icon != null)
        Padding(
          padding: EdgeInsets.only(right: spacing.sm),
          child: Icon(
            item.icon,
            size: iconSize,
            color: item.disabled
                ? colors.textMuted
                : isSelected
                ? colors.primary.base
                : colors.text,
          ),
        ),
      Expanded(
        child: OiLabel.body(
          item.label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          color: item.disabled
              ? colors.textMuted
              : isSelected
              ? colors.primary.base
              : null,
        ),
      ),
      if (item.badge != null)
        Padding(
          padding: EdgeInsets.only(left: spacing.xs),
          child: OiBadge.soft(label: item.badge!, size: OiBadgeSize.small),
        ),
      if (item.trailing case final trailing?)
        Padding(
          padding: EdgeInsets.only(left: spacing.xs),
          child: trailing,
        ),
      if (hasChildren)
        Padding(
          padding: EdgeInsets.only(left: spacing.xs),
          child: Icon(OiIcons.chevronRight, size: 16, color: colors.textMuted),
        ),
    ];

    Widget row = Padding(
      padding: EdgeInsets.symmetric(
        horizontal: spacing.md,
        vertical: spacing.sm,
      ),
      child: Row(children: rowChildren),
    );

    if (isSelected) {
      row = DecoratedBox(
        decoration: BoxDecoration(
          color: colors.primary.muted.withValues(alpha: 0.15),
          borderRadius: context.radius.sm,
        ),
        child: row,
      );
    }

    if (item.disabled) {
      return Opacity(opacity: 0.5, child: row);
    }

    return OiTappable(
      onTap: () => _handleItemTap(item),
      semanticLabel: item.label,
      child: row,
    );
  }

  Widget _buildToggle(BuildContext context, OiDrawerToggle toggle) {
    return OiSwitchTile(
      title: toggle.label,
      value: toggle.value,
      onChanged: toggle.onChanged,
      leading: toggle.icon != null
          ? Icon(toggle.icon, size: 20, color: context.colors.text)
          : null,
      dense: true,
      semanticLabel: toggle.label,
    );
  }

  Widget _buildSubmenu(BuildContext context) {
    final parent = _submenuStack.last;
    final colors = context.colors;
    final spacing = context.spacing;
    final items = parent.children ?? [];

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(vertical: spacing.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Back button
          OiTappable(
            onTap: _popSubmenu,
            semanticLabel:
                'Back to ${_submenuStack.length > 1 ? _submenuStack[_submenuStack.length - 2].label : "root"}',
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: spacing.md,
                vertical: spacing.sm,
              ),
              child: Row(
                children: [
                  Icon(OiIcons.arrowLeft, size: 20, color: colors.text),
                  SizedBox(width: spacing.sm),
                  Expanded(
                    child: OiLabel.body(
                      parent.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: spacing.xs),
            child: const OiDivider(),
          ),
          // Children items
          for (final item in items) _buildItem(context, item),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return widget.footer!;
  }

  /// Extracts up to two initials from a name string.
  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
}
