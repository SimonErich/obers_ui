import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/oi_icons.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/animation/oi_shimmer.dart';
import 'package:obers_ui/src/primitives/display/oi_icon.dart';
import 'package:obers_ui/src/primitives/display/oi_label.dart';
import 'package:obers_ui/src/primitives/interaction/oi_tappable.dart';

/// A card that displays an image preview with optional loading, regenerating,
/// badge, edit-overlay, and version-label states.
///
/// When [imageUrl] is null or [loading] is true, a shimmer placeholder is
/// shown. When [regenerating] is true, a shimmer overlay pulses on top of the
/// existing image. An optional [statusBadge] is positioned in the top-right
/// corner, and a [versionLabel] appears in the bottom-right corner.
///
/// Hovering over the card when [onEdit] is provided reveals a semi-transparent
/// overlay with an edit icon.
///
/// The card requires an [alt] accessibility description that is exposed via
/// [Semantics].
///
/// {@category Components}
class OiImagePreviewCard extends StatefulWidget {
  /// Creates an [OiImagePreviewCard].
  const OiImagePreviewCard({
    required this.alt,
    this.imageUrl,
    this.statusBadge,
    this.onTap,
    this.onEdit,
    this.loading = false,
    this.regenerating = false,
    this.enableZoom = false,
    this.versionLabel,
    this.aspectRatio,
    this.placeholder,
    super.key,
  });

  /// Required accessibility description.
  final String alt;

  /// Image URL. Null shows shimmer placeholder.
  final String? imageUrl;

  /// Optional overlay badge widget (e.g. OiBadge).
  final Widget? statusBadge;

  /// Tap callback for the card.
  final VoidCallback? onTap;

  /// Edit callback. Shows edit overlay icon on hover.
  final VoidCallback? onEdit;

  /// Shows shimmer loading animation.
  final bool loading;

  /// Shows shimmer pulse over existing image.
  final bool regenerating;

  /// Wraps image in pinch-to-zoom via [InteractiveViewer].
  final bool enableZoom;

  /// Version label shown in bottom-right corner (e.g. "v3").
  final String? versionLabel;

  /// When non-null, wraps the card in an [AspectRatio] widget.
  ///
  /// Useful for enforcing landscape (`16/9`) or portrait (`2/3`) ratios.
  final double? aspectRatio;

  /// Custom widget shown instead of [OiShimmer] when [imageUrl] is null or
  /// [loading] is true.
  final Widget? placeholder;

  @override
  State<OiImagePreviewCard> createState() => _OiImagePreviewCardState();
}

class _OiImagePreviewCardState extends State<OiImagePreviewCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final radius = context.radius.md;
    final spacing = context.spacing;

    // -- Determine the image content -----------------------------------------
    Widget content;

    if (widget.imageUrl == null || widget.loading) {
      // Custom placeholder overrides the default shimmer.
      content =
          widget.placeholder ??
          OiShimmer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: colors.surfaceHover,
                borderRadius: radius,
              ),
              child: const SizedBox.expand(),
            ),
          );
    } else {
      // Render the network image.
      Widget image = Image.network(
        widget.imageUrl!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) => Center(
          child: OiIcon.decorative(
            icon: OiIcons.imageOff,
            size: 32,
            color: colors.textMuted,
          ),
        ),
      );

      if (widget.enableZoom) {
        image = InteractiveViewer(minScale: 1, maxScale: 4, child: image);
      }

      image = ClipRRect(borderRadius: radius, child: image);

      if (widget.regenerating) {
        // Shimmer overlay on top of the existing image.
        content = Stack(
          fit: StackFit.expand,
          children: [
            image,
            ClipRRect(
              borderRadius: radius,
              child: OiShimmer(
                child: ColoredBox(
                  color: colors.overlay,
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ],
        );
      } else {
        content = image;
      }
    }

    // -- Build the full stack with overlays ----------------------------------
    final children = <Widget>[content];

    // Status badge in top-right corner.
    if (widget.statusBadge != null) {
      children.add(
        Positioned(
          top: spacing.xs,
          right: spacing.xs,
          child: widget.statusBadge!,
        ),
      );
    }

    // Version label in bottom-right corner.
    if (widget.versionLabel != null) {
      children.add(
        Positioned(
          bottom: spacing.xs,
          right: spacing.xs,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colors.surfaceHover,
              borderRadius: context.radius.sm,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: spacing.xs,
                vertical: spacing.xs / 2,
              ),
              child: OiLabel.tiny(
                widget.versionLabel!,
                color: colors.textSubtle,
              ),
            ),
          ),
        ),
      );
    }

    // Edit overlay on hover.
    if (widget.onEdit != null && _hovered) {
      children.add(
        Positioned.fill(
          child: ClipRRect(
            borderRadius: radius,
            child: GestureDetector(
              onTap: widget.onEdit,
              child: ColoredBox(
                color: colors.overlay,
                child: Center(
                  child: OiIcon.decorative(
                    icon: OiIcons.pencil,
                    size: 24,
                    color: colors.textInverse,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    Widget card = DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        border: Border.all(color: colors.borderSubtle),
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Stack(fit: StackFit.expand, children: children),
      ),
    );

    // Hover detection for the edit overlay.
    if (widget.onEdit != null) {
      card = MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: card,
      );
    }

    // Wrap in OiTappable if onTap is provided.
    if (widget.onTap != null) {
      card = OiTappable(
        onTap: widget.onTap,
        semanticLabel: widget.alt,
        clipBorderRadius: radius,
        child: card,
      );
    }

    // Wrap in AspectRatio when requested.
    Widget result = Semantics(image: true, label: widget.alt, child: card);
    if (widget.aspectRatio != null) {
      result = AspectRatio(aspectRatio: widget.aspectRatio!, child: result);
    }
    return result;
  }
}
