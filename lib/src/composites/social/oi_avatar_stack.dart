import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/display/oi_avatar.dart';
import 'package:obers_ui/src/components/display/oi_tooltip.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';

/// Data for a single user displayed in an [OiAvatarStack].
///
/// {@category Composites}
class OiAvatarStackItem {
  /// Creates an [OiAvatarStackItem].
  const OiAvatarStackItem({required this.label, this.imageUrl, this.initials});

  /// The display name of the user. Used for the tooltip and semantic label.
  final String label;

  /// An optional network image URL for the user's avatar.
  final String? imageUrl;

  /// Optional initials to display when no image is available.
  final String? initials;
}

/// A horizontal stack of overlapping [OiAvatar] widgets with a "+N more"
/// overflow indicator when the list exceeds [maxVisible].
///
/// Each avatar can be tapped individually when [onTap] is provided. Hovering
/// over an avatar shows a tooltip with the user's [OiAvatarStackItem.label].
///
/// {@category Composites}
class OiAvatarStack extends StatelessWidget {
  /// Creates an [OiAvatarStack].
  const OiAvatarStack({
    required this.users,
    super.key,
    this.maxVisible = 4,
    this.size = OiAvatarSize.sm,
    this.overlap = 8,
    this.onTap,
  });

  /// The list of users to display in the stack.
  final List<OiAvatarStackItem> users;

  /// The maximum number of avatars to show before displaying the "+N" badge.
  final int maxVisible;

  /// The size of each avatar in the stack.
  final OiAvatarSize size;

  /// The number of logical pixels each avatar overlaps its predecessor.
  final double overlap;

  /// Called when a user avatar is tapped.
  final ValueChanged<OiAvatarStackItem>? onTap;

  double get _diameter {
    switch (size) {
      case OiAvatarSize.xs:
        return 24;
      case OiAvatarSize.sm:
        return 32;
      case OiAvatarSize.md:
        return 40;
      case OiAvatarSize.lg:
        return 56;
      case OiAvatarSize.xl:
        return 72;
    }
  }

  double get _fontSize {
    switch (size) {
      case OiAvatarSize.xs:
        return 9;
      case OiAvatarSize.sm:
        return 11;
      case OiAvatarSize.md:
        return 13;
      case OiAvatarSize.lg:
        return 16;
      case OiAvatarSize.xl:
        return 20;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (users.isEmpty) return const SizedBox.shrink();

    final colors = context.colors;
    final visible = users.take(maxVisible).toList();
    final overflow = users.length - maxVisible;
    final d = _diameter;

    final children = <Widget>[];

    for (var i = 0; i < visible.length; i++) {
      final user = visible[i];
      final left = i * (d - overlap);

      Widget avatar = OiAvatar(
        semanticLabel: user.label,
        imageUrl: user.imageUrl,
        initials: user.initials,
        size: size,
      );

      if (onTap != null) {
        avatar = GestureDetector(onTap: () => onTap!(user), child: avatar);
      }

      children.add(
        Positioned(
          left: left,
          child: OiTooltip(
            message: user.label,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: colors.surface, width: 2),
              ),
              child: avatar,
            ),
          ),
        ),
      );
    }

    if (overflow > 0) {
      final left = visible.length * (d - overlap);
      children.add(
        Positioned(
          left: left,
          child: OiTooltip(
            message: users.skip(maxVisible).map((u) => u.label).join(', '),
            child: Container(
              width: d,
              height: d,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.surfaceHover,
                border: Border.all(color: colors.surface, width: 2),
              ),
              child: Center(
                child: Text(
                  '+$overflow',
                  style: TextStyle(
                    color: colors.textSubtle,
                    fontSize: _fontSize,
                    fontWeight: FontWeight.w600,
                    height: 1,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    final totalItems = visible.length + (overflow > 0 ? 1 : 0);
    // Add 4 for the border width on both sides.
    final totalWidth = totalItems > 0
        ? (totalItems - 1) * (d - overlap) + d + 4
        : 0.0;

    return Semantics(
      label: '${users.length} users',
      child: SizedBox(
        width: totalWidth,
        height: d + 4,
        child: Stack(children: children),
      ),
    );
  }
}
