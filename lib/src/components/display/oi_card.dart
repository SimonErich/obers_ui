import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/theme/oi_decoration_theme.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/display/oi_surface.dart';
import 'package:obers_ui/src/primitives/interaction/oi_tappable.dart';

/// The visual style of an [OiCard].
///
/// {@category Components}
enum OiCardVariant {
  /// A card with a drop shadow and no border.
  elevated,

  /// A card with a border and no shadow.
  outlined,

  /// A plain card with no border or shadow.
  flat,

  /// Like [outlined] but with a hover effect via [OiTappable].
  interactive,
}

/// A themed card container that renders its [child] inside a styled surface.
///
/// The visual treatment depends on [variant]:
/// - [OiCardVariant.elevated]: drop shadow, no border.
/// - [OiCardVariant.outlined]: border, no shadow.
/// - [OiCardVariant.flat]: plain surface, no border or shadow.
/// - [OiCardVariant.interactive]: bordered surface with hover/press feedback
///   via [OiTappable]; fires [onTap] when tapped.
///
/// {@category Components}
class OiCard extends StatelessWidget {
  /// Creates an [OiCard].
  const OiCard({
    required this.child,
    this.variant = OiCardVariant.elevated,
    this.padding,
    this.onTap,
    this.width,
    this.height,
    super.key,
  });

  /// The visual style variant.
  final OiCardVariant variant;

  /// The widget rendered inside the card.
  final Widget child;

  /// Padding applied inside the card surface.
  final EdgeInsetsGeometry? padding;

  /// Tap callback. Only used for [OiCardVariant.interactive].
  final VoidCallback? onTap;

  /// Optional width constraint.
  final double? width;

  /// Optional height constraint.
  final double? height;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final effectivePadding =
        padding ?? const EdgeInsets.all(16);

    OiBorderStyle? border;
    List<BoxShadow>? shadow;

    switch (variant) {
      case OiCardVariant.elevated:
        shadow = [
          BoxShadow(
            color: colors.overlay.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
          BoxShadow(
            color: colors.overlay.withValues(alpha: 0.04),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ];
      case OiCardVariant.outlined:
      case OiCardVariant.interactive:
        border = OiBorderStyle.solid(
          colors.border,
          1,
          borderRadius: BorderRadius.circular(8),
        );
      case OiCardVariant.flat:
        break;
    }

    final surface = SizedBox(
      width: width,
      height: height,
      child: OiSurface(
        border: border,
        shadow: shadow,
        borderRadius: BorderRadius.circular(8),
        padding: effectivePadding,
        child: child,
      ),
    );

    if (variant == OiCardVariant.interactive) {
      return OiTappable(
        onTap: onTap,
        enabled: onTap != null,
        child: surface,
      );
    }

    return surface;
  }
}
