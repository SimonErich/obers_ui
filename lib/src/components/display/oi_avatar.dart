import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/theme/oi_color_scheme.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/animation/oi_shimmer.dart';

/// The size of an [OiAvatar].
///
/// {@category Components}
enum OiAvatarSize {
  /// Extra-small: 24 × 24 dp.
  xs,

  /// Small: 32 × 32 dp.
  sm,

  /// Medium: 40 × 40 dp.
  md,

  /// Large: 56 × 56 dp.
  lg,

  /// Extra-large: 72 × 72 dp.
  xl,
}

/// The presence / availability status ring shown around an [OiAvatar].
///
/// {@category Components}
enum OiPresenceStatus {
  /// Online — green ring.
  online,

  /// Offline — grey ring.
  offline,

  /// Away — yellow ring.
  away,

  /// Busy — red ring.
  busy,
}

/// A circular avatar widget that renders an image, initials, or icon.
///
/// Priority order:
/// 1. [imageUrl] — loads a network image via [Image.network].
/// 2. [initials] — up to two characters rendered on the primary background.
/// 3. [icon] — an [IconData] rendered on the primary background.
///
/// When [skeleton] is `true` an [OiShimmer] placeholder is shown instead.
/// When [presence] is set, a colored ring is drawn around the avatar.
///
/// {@category Components}
class OiAvatar extends StatelessWidget {
  /// Creates an [OiAvatar].
  const OiAvatar({
    required this.semanticLabel,
    this.imageUrl,
    this.initials,
    this.icon,
    this.size = OiAvatarSize.md,
    this.skeleton = false,
    this.presence,
    super.key,
  });

  /// The image URL (first priority). Must start with `http://` or `https://`.
  final String? imageUrl;

  /// User initials shown when no image is available (second priority).
  final String? initials;

  /// Icon shown when neither image nor initials are available (third priority).
  final IconData? icon;

  /// The avatar size.
  final OiAvatarSize size;

  /// When `true`, an [OiShimmer] loading skeleton is shown.
  final bool skeleton;

  /// When set, a colored presence ring is drawn around the avatar.
  final OiPresenceStatus? presence;

  /// Accessibility label announced by screen readers.
  final String semanticLabel;

  // ---------------------------------------------------------------------------
  // Dimension helpers
  // ---------------------------------------------------------------------------

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
        return 10;
      case OiAvatarSize.sm:
        return 12;
      case OiAvatarSize.md:
        return 14;
      case OiAvatarSize.lg:
        return 20;
      case OiAvatarSize.xl:
        return 26;
    }
  }

  double get _iconSize {
    return _diameter * 0.5;
  }

  Color _presenceColor(OiPresenceStatus status, OiColorScheme colors) {
    switch (status) {
      case OiPresenceStatus.online:
        return colors.success.base;
      case OiPresenceStatus.offline:
        return colors.textMuted;
      case OiPresenceStatus.away:
        return colors.warning.base;
      case OiPresenceStatus.busy:
        return colors.error.base;
    }
  }

  String _presenceLabel(OiPresenceStatus status) {
    switch (status) {
      case OiPresenceStatus.online:
        return 'online';
      case OiPresenceStatus.offline:
        return 'offline';
      case OiPresenceStatus.away:
        return 'away';
      case OiPresenceStatus.busy:
        return 'busy';
    }
  }

  /// Returns a distinct icon per presence status so color is never the sole
  /// indicator (REQ-0025).
  IconData _presenceIcon(OiPresenceStatus status) {
    switch (status) {
      case OiPresenceStatus.online:
        // Filled circle — distinct from the hollow offline circle.
        return const IconData(0xe061, fontFamily: 'MaterialIcons'); // circle
      case OiPresenceStatus.offline:
        // Outlined (hollow) circle.
        return const IconData(
          0xef52,
          fontFamily: 'MaterialIcons',
        ); // circle_outlined
      case OiPresenceStatus.away:
        // Clock/schedule icon.
        return const IconData(
          0xe8b5,
          fontFamily: 'MaterialIcons',
        ); // schedule
      case OiPresenceStatus.busy:
        // "Do not disturb" / remove-circle icon.
        return const IconData(
          0xe15b,
          fontFamily: 'MaterialIcons',
        ); // remove_circle
    }
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final d = _diameter;

    Widget avatar;

    if (skeleton) {
      avatar = OiShimmer(
        child: Container(
          width: d,
          height: d,
          decoration: BoxDecoration(
            color: colors.surfaceHover,
            shape: BoxShape.circle,
          ),
        ),
      );
    } else {
      avatar = ClipOval(
        child: SizedBox(
          width: d,
          height: d,
          child: _buildContent(context, colors, d),
        ),
      );
    }

    if (presence != null && !skeleton) {
      final ringColor = _presenceColor(presence!, colors);
      const ringWidth = 2.5;
      const ringGap = 1.5;
      final totalD = d + (ringWidth + ringGap) * 2;
      // REQ-0025: icon size scales with avatar so the indicator is visible
      // but proportional.
      final indicatorSize = (d * 0.35).clamp(10.0, 20.0);

      avatar = SizedBox(
        width: totalD,
        height: totalD,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: totalD,
              height: totalD,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: ringColor, width: ringWidth),
              ),
            ),
            avatar,
            // REQ-0025: distinct icon per status so color is not the sole
            // indicator.
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: indicatorSize,
                height: indicatorSize,
                decoration: BoxDecoration(
                  color: colors.surface,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    _presenceIcon(presence!),
                    size: indicatorSize * 0.7,
                    color: ringColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    final fullLabel = presence != null && !skeleton
        ? '$semanticLabel, ${_presenceLabel(presence!)}'
        : semanticLabel;

    return Semantics(
      label: fullLabel,
      image: imageUrl != null,
      child: ExcludeSemantics(child: avatar),
    );
  }

  Widget _buildContent(BuildContext context, OiColorScheme colors, double d) {
    if (imageUrl != null) {
      return Image.network(
        imageUrl!,
        width: d,
        height: d,
        fit: BoxFit.cover,
        errorBuilder: (ctx, _, __) => _buildFallback(context, colors, d),
      );
    }
    return _buildFallback(context, colors, d);
  }

  Widget _buildFallback(BuildContext context, OiColorScheme colors, double d) {
    if (initials != null && initials!.isNotEmpty) {
      final text = initials!.length > 2
          ? initials!.substring(0, 2).toUpperCase()
          : initials!.toUpperCase();
      return ColoredBox(
        color: colors.primary.base,
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: colors.textOnPrimary,
              fontSize: _fontSize,
              fontWeight: FontWeight.w600,
              height: 1,
            ),
          ),
        ),
      );
    }

    if (icon != null) {
      return ColoredBox(
        color: colors.primary.base,
        child: Center(
          child: Icon(icon, size: _iconSize, color: colors.textOnPrimary),
        ),
      );
    }

    // Default placeholder.
    return ColoredBox(
      color: colors.surfaceHover,
      child: Center(
        child: Icon(
          const IconData(0xe7fd, fontFamily: 'MaterialIcons'),
          size: _iconSize,
          color: colors.textMuted,
        ),
      ),
    );
  }
}
