import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/display/oi_avatar.dart';
import 'package:obers_ui/src/components/display/oi_list_tile.dart';
import 'package:obers_ui/src/components/display/oi_popover.dart';
import 'package:obers_ui/src/components/overlays/oi_context_menu.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/display/oi_divider.dart';
import 'package:obers_ui/src/primitives/display/oi_icon.dart';
import 'package:obers_ui/src/primitives/display/oi_label.dart';
import 'package:obers_ui/src/primitives/interaction/oi_tappable.dart';

/// An avatar-triggered dropdown menu showing user info and account actions.
///
/// Tapping the avatar opens a popover with a header section (user name and
/// optional email) followed by grouped menu items separated by [OiDivider].
///
/// Composes [OiAvatar], [OiTappable], [OiPopover], [OiLabel], [OiDivider],
/// [OiListTile], and [OiIcon].
///
/// {@category Navigation}
class OiUserMenu extends StatefulWidget {
  /// Creates an [OiUserMenu].
  const OiUserMenu({
    required this.label,
    required this.userName,
    required this.items,
    this.userEmail,
    this.avatarUrl,
    this.avatarInitials,
    this.header,
    super.key,
  });

  /// Accessible label for screen readers.
  final String label;

  /// The user's display name shown in the header.
  final String userName;

  /// The user's email shown below the name in the header.
  final String? userEmail;

  /// URL for the user's avatar image.
  final String? avatarUrl;

  /// Fallback initials displayed when [avatarUrl] is not provided.
  final String? avatarInitials;

  /// The list of menu items displayed below the header.
  final List<OiMenuItem> items;

  /// Optional custom widget that replaces the default header.
  final Widget? header;

  @override
  State<OiUserMenu> createState() => _OiUserMenuState();
}

class _OiUserMenuState extends State<OiUserMenu> {
  bool _isOpen = false;

  Widget _buildDefaultHeader(BuildContext context) {
    final spacing = context.spacing;
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: spacing.md,
        vertical: spacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          OiLabel.bodyStrong(widget.userName),
          if (widget.userEmail != null) ...[
            SizedBox(height: spacing.xs),
            OiLabel.small(widget.userEmail!),
          ],
        ],
      ),
    );
  }

  Widget _buildMenuItems(BuildContext context) {
    final spacing = context.spacing;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: spacing.xs),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final item in widget.items)
            OiListTile(
              title: item.label,
              leading: item.icon != null
                  ? OiIcon.decorative(icon: item.icon!)
                  : null,
              onTap: !item.enabled
                  ? null
                  : () {
                      setState(() => _isOpen = false);
                      item.onTap?.call();
                    },
              enabled: item.enabled,
              dense: true,
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;

    final avatar = OiTappable(
      semanticLabel: widget.label,
      onTap: () => setState(() => _isOpen = !_isOpen),
      child: OiAvatar(
        semanticLabel: widget.label,
        imageUrl: widget.avatarUrl,
        initials: widget.avatarInitials,
      ),
    );

    final headerWidget = widget.header ?? _buildDefaultHeader(context);

    return OiPopover(
      label: widget.label,
      open: _isOpen,
      onClose: () => setState(() => _isOpen = false),
      anchor: avatar,
      content: UnconstrainedBox(
        alignment: Alignment.topLeft,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 200, maxWidth: 280),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: spacing.xs),
              headerWidget,
              if (widget.items.isNotEmpty) ...[
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: spacing.sm),
                  child: const OiDivider(),
                ),
                _buildMenuItems(context),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
