import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/display/oi_avatar.dart';
import 'package:obers_ui/src/components/display/oi_skeleton_group.dart';
import 'package:obers_ui/src/foundation/theme/oi_spacing_scale.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';

/// Pre-shaped skeleton loading placeholders.
///
/// Compose multiple presets to build realistic loading states that match
/// your content layout. All presets use [OiSkeletonGroup] with
/// [OiSkeletonLine] and [OiSkeletonBox] internally.
///
/// ```dart
/// const OiSkeletonPreset.text(lines: 3)
/// const OiSkeletonPreset.listTile()
/// OiSkeletonPreset.list(itemSkeleton: const OiSkeletonPreset.listTile())
/// ```
///
/// {@category Components}
class OiSkeletonPreset extends StatelessWidget {
  const OiSkeletonPreset._({
    required _SkeletonPresetType type,
    this.lines = 3,
    this.lastLineWidth = 0.6,
    this.lineHeight = 14,
    this.lineSpacing,
    this.height,
    this.width,
    this.aspectRatio,
    this.columns = 4,
    this.showAvatar = true,
    this.showTrailing = false,
    this.subtitleWidth = 0.5,
    this.avatarSize,
    super.key,
  }) : _type = type;

  /// Rectangle placeholder for text lines.
  const OiSkeletonPreset.text({
    int lines = 3,
    double lastLineWidth = 0.6,
    double lineHeight = 14,
    double? lineSpacing,
    double? width,
    Key? key,
  }) : this._(
         type: _SkeletonPresetType.text,
         lines: lines,
         lastLineWidth: lastLineWidth,
         lineHeight: lineHeight,
         lineSpacing: lineSpacing,
         width: width,
         key: key,
       );

  /// Circular placeholder for avatars.
  const OiSkeletonPreset.avatar({OiAvatarSize size = OiAvatarSize.md, Key? key})
    : this._(type: _SkeletonPresetType.avatar, avatarSize: size, key: key);

  /// Rounded rectangle placeholder for cards.
  const OiSkeletonPreset.card({
    double height = 120,
    double? width,
    double? aspectRatio,
    Key? key,
  }) : this._(
         type: _SkeletonPresetType.card,
         height: height,
         width: width,
         aspectRatio: aspectRatio,
         key: key,
       );

  /// Full-width rectangle for images/banners.
  const OiSkeletonPreset.image({
    double height = 200,
    double? width,
    double? aspectRatio,
    Key? key,
  }) : this._(
         type: _SkeletonPresetType.image,
         height: height,
         width: width,
         aspectRatio: aspectRatio,
         key: key,
       );

  /// Small rounded rectangle for badges/chips.
  const OiSkeletonPreset.badge({double width = 60, Key? key})
    : this._(type: _SkeletonPresetType.badge, width: width, key: key);

  /// Standard list tile: avatar + 2 text lines + trailing element.
  const OiSkeletonPreset.listTile({
    bool showAvatar = true,
    bool showTrailing = false,
    double subtitleWidth = 0.5,
    Key? key,
  }) : this._(
         type: _SkeletonPresetType.listTile,
         showAvatar: showAvatar,
         showTrailing: showTrailing,
         subtitleWidth: subtitleWidth,
         key: key,
       );

  /// Table row with N columns of varying width.
  const OiSkeletonPreset.tableRow({int columns = 4, Key? key})
    : this._(type: _SkeletonPresetType.tableRow, columns: columns, key: key);

  /// Metric card: large number + label below.
  const OiSkeletonPreset.metric({Key? key})
    : this._(type: _SkeletonPresetType.metric, key: key);

  /// Composes a skeleton in a vertical list, repeating [count] times.
  static Widget list({
    required Widget itemSkeleton,
    int count = 5,
    Widget? separator,
    Key? key,
  }) {
    return Column(
      key: key,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < count; i++) ...[
          itemSkeleton,
          if (separator != null && i < count - 1) separator,
        ],
      ],
    );
  }

  final _SkeletonPresetType _type;
  final int lines;
  final double lastLineWidth;
  final double lineHeight;

  /// Space between lines in the text preset. Defaults to [OiSpacingScale.xs].
  final double? lineSpacing;

  final double? height;
  final double? width;
  final double? aspectRatio;
  final int columns;
  final bool showAvatar;
  final bool showTrailing;
  final double subtitleWidth;

  /// The avatar size, used only by [_SkeletonPresetType.avatar].
  final OiAvatarSize? avatarSize;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;

    return switch (_type) {
      _SkeletonPresetType.text => _buildText(spacing),
      _SkeletonPresetType.avatar => _buildAvatar(),
      _SkeletonPresetType.card => _buildCard(spacing),
      _SkeletonPresetType.image => _buildImage(),
      _SkeletonPresetType.badge => _buildBadge(),
      _SkeletonPresetType.listTile => _buildListTile(spacing),
      _SkeletonPresetType.tableRow => _buildTableRow(spacing),
      _SkeletonPresetType.metric => _buildMetric(spacing),
    };
  }

  Widget _buildText(OiSpacingScale spacing) {
    final gap = lineSpacing ?? spacing.xs;
    return OiSkeletonGroup(
      children: [
        for (var i = 0; i < lines; i++)
          Padding(
            padding: EdgeInsets.only(bottom: i < lines - 1 ? gap : 0),
            child: FractionallySizedBox(
              widthFactor: i == lines - 1 ? lastLineWidth : 1.0,
              alignment: Alignment.centerLeft,
              child: OiSkeletonLine(height: lineHeight, width: width),
            ),
          ),
      ],
    );
  }

  Widget _buildAvatar() {
    final size = switch (avatarSize ?? OiAvatarSize.md) {
      OiAvatarSize.xs => 24.0,
      OiAvatarSize.sm => 32.0,
      OiAvatarSize.md => 40.0,
      OiAvatarSize.lg => 56.0,
      OiAvatarSize.xl => 72.0,
    };
    return OiSkeletonGroup(
      children: [
        ClipOval(
          child: OiSkeletonBox(width: size, height: size),
        ),
      ],
    );
  }

  Widget _buildCard(OiSpacingScale spacing) {
    Widget child = OiSkeletonBox(height: height, width: width);
    if (aspectRatio != null) {
      child = AspectRatio(aspectRatio: aspectRatio!, child: child);
    }
    return OiSkeletonGroup(children: [child]);
  }

  Widget _buildImage() {
    Widget child = OiSkeletonBox(height: height, width: width);
    if (aspectRatio != null) {
      child = AspectRatio(aspectRatio: aspectRatio!, child: child);
    }
    return OiSkeletonGroup(children: [child]);
  }

  Widget _buildBadge() {
    return OiSkeletonGroup(
      children: [OiSkeletonLine(width: width, height: 20)],
    );
  }

  Widget _buildListTile(OiSpacingScale spacing) {
    return OiSkeletonGroup(
      children: [
        Row(
          children: [
            if (showAvatar) ...[
              ClipOval(child: OiSkeletonBox(width: 40, height: 40)),
              SizedBox(width: spacing.sm),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const OiSkeletonLine(height: 14),
                  SizedBox(height: spacing.xs),
                  FractionallySizedBox(
                    widthFactor: subtitleWidth,
                    alignment: Alignment.centerLeft,
                    child: const OiSkeletonLine(height: 12),
                  ),
                ],
              ),
            ),
            if (showTrailing) ...[
              SizedBox(width: spacing.sm),
              const OiSkeletonBox(width: 24, height: 24),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildTableRow(OiSpacingScale spacing) {
    return OiSkeletonGroup(
      children: [
        Row(
          children: [
            for (var i = 0; i < columns; i++) ...[
              Expanded(child: OiSkeletonLine(height: 14)),
              if (i < columns - 1) SizedBox(width: spacing.sm),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildMetric(OiSpacingScale spacing) {
    return OiSkeletonGroup(
      children: [
        const OiSkeletonLine(width: 80, height: 28),
        SizedBox(height: spacing.xs),
        const OiSkeletonLine(width: 120, height: 12),
      ],
    );
  }
}

enum _SkeletonPresetType {
  text,
  avatar,
  card,
  image,
  badge,
  listTile,
  tableRow,
  metric,
}
