import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/display/oi_image.dart';
import 'package:obers_ui/src/foundation/theme/oi_component_themes.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/interaction/oi_tappable.dart';

/// A selectable media frame with stable bounds and independent overlays.
///
/// The caller supplies content, commonly an [OiImage], and owns selection.
/// Overlays are stack children and stay fully opaque when media is dimmed.
/// A null callback produces a read-only frame; disabled interactive frames
/// preserve selection and do not respond to pointer or keyboard input.
///
/// {@category Components}
class OiMediaTile extends StatelessWidget {
  /// Creates a media frame without coupling it to a media source or model.
  const OiMediaTile({
    required this.child,
    required this.label,
    this.selected = true,
    this.onChanged,
    this.enabled = true,
    this.aspectRatio = 1,
    this.overlays = const [],
    this.style,
    super.key,
  }) : assert(aspectRatio > 0, 'aspectRatio must be positive.');

  /// Media content; image decoding remains the content's responsibility.
  final Widget child;

  /// Accessible name for the selection action.
  final String label;

  /// Selection owned by the caller.
  final bool selected;

  /// Called with the requested selection; null renders a read-only frame.
  final ValueChanged<bool>? onChanged;

  /// Whether an interactive frame accepts input.
  final bool enabled;

  /// Width divided by height.
  final double aspectRatio;

  /// Stack children, such as positioned badges or selection indicators.
  final List<Widget> overlays;

  /// Optional complete presentation override for a different tile treatment.
  final OiMediaTileThemeData? style;

  static const _grayscale = ColorFilter.matrix([
    .2126,
    .7152,
    .0722,
    0,
    0,
    .2126,
    .7152,
    .0722,
    0,
    0,
    .2126,
    .7152,
    .0722,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
  ]);

  @override
  Widget build(BuildContext context) {
    final theme =
        style ?? context.components.mediaTile ?? const OiMediaTileThemeData();
    final radius = theme.borderRadius ?? context.radius.md;
    final reducedMotion =
        context.animations.reducedMotion ||
        MediaQuery.disableAnimationsOf(context);
    final content = ClipRRect(
      borderRadius: radius,
      child: AspectRatio(
        aspectRatio: aspectRatio,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(
              color: theme.backgroundColor ?? context.colors.surfaceSubtle,
            ),
            AnimatedOpacity(
              duration: reducedMotion
                  ? Duration.zero
                  : theme.transitionDuration ?? context.animations.fast,
              opacity: selected ? 1 : theme.unselectedOpacity,
              child: !selected && theme.desaturateUnselected
                  ? ColorFiltered(colorFilter: _grayscale, child: child)
                  : child,
            ),
            ...overlays,
          ],
        ),
      ),
    );
    final frame = selected && theme.selectedBorder != null
        ? Stack(
            clipBehavior: Clip.none,
            children: [
              content,
              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: radius,
                      border: Border.fromBorderSide(theme.selectedBorder!),
                    ),
                  ),
                ),
              ),
            ],
          )
        : content;
    if (onChanged == null) return frame;
    return Semantics(
      selected: selected,
      child: OiTappable(
        semanticLabel: label,
        enabled: enabled,
        onTap: () => onChanged!(!selected),
        child: ExcludeSemantics(child: frame),
      ),
    );
  }
}
