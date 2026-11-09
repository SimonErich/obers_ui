import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:obers_ui/src/foundation/icons/oi_icon_data.dart';
import 'package:obers_ui/src/foundation/icons/oi_icon_source.dart';
import 'package:obers_ui/src/foundation/theme/oi_text_theme.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';

/// The common semantic icon renderer for font and local SVG sources.
///
/// Existing [IconData] tokens can be remapped through the icon component theme.
/// Explicit widget size/color wins over theme defaults. Vector sources retain
/// their authored stroke geometry and use the resolved foreground color.
class OiIcon extends StatelessWidget {
  /// Creates a meaningful icon, announced with [label].
  const OiIcon({
    required this.icon,
    required this.label,
    this.size,
    this.color,
    super.key,
  }) : textDirection = null,
       shadows = null,
       weight = null,
       fill = null,
       grade = null,
       opticalSize = null,
       applyTextScaling = false,
       _decorative = false;

  /// Creates an icon excluded from the accessibility tree.
  const OiIcon.decorative({
    required this.icon,
    this.size,
    this.color,
    super.key,
  }) : label = '',
       textDirection = null,
       shadows = null,
       weight = null,
       fill = null,
       grade = null,
       opticalSize = null,
       applyTextScaling = false,
       _decorative = true;

  /// Flutter-compatible internal rendering entry point for existing controls.
  ///
  /// Use the named semantic/decorative constructors in application code.
  const OiIcon.raw(
    this.icon, {
    this.size,
    this.color,
    this.textDirection,
    this.shadows,
    this.weight,
    this.fill,
    this.grade,
    this.opticalSize,
    this.applyTextScaling,
    String? semanticLabel,
    super.key,
  }) : label = semanticLabel ?? '',
       _decorative = semanticLabel == null;

  /// Stable font token, optionally replaced by the active icon set.
  final OiIconData? icon;

  /// Accessible label.
  final String label;

  /// Explicit size in logical pixels.
  final double? size;

  /// Explicit foreground color.
  final Color? color;

  /// Direction used for directional font glyphs.
  final TextDirection? textDirection;

  /// Font glyph shadows.
  final List<Shadow>? shadows;

  /// Variable icon font weight, when supported by the source font.
  final double? weight;

  /// Variable icon font fill.
  final double? fill;

  /// Variable icon font grade.
  final double? grade;

  /// Variable icon font optical size.
  final double? opticalSize;

  /// Whether system text scaling applies to font icons.
  final bool? applyTextScaling;
  final bool _decorative;

  @override
  Widget build(BuildContext context) {
    final theme = OiTheme.maybeOf(context);
    final iconTheme = theme?.components.icon;
    final inherited = IconTheme.of(context);
    final resolvedSize =
        size ??
        iconTheme?.size ??
        theme?.textTheme.styleFor(OiLabelVariant.body).fontSize ??
        inherited.size ??
        16;
    final resolvedColor =
        color ?? iconTheme?.color ?? theme?.colors.text ?? inherited.color;
    final source = iconTheme?.sources[icon];
    final Widget child = switch (source) {
      OiSvgIconSource(:final markup) => SvgPicture.string(
        markup,
        width: resolvedSize,
        height: resolvedSize,
        theme: SvgTheme(currentColor: resolvedColor ?? const Color(0xff000000)),
        colorFilter: resolvedColor == null
            ? null
            : ColorFilter.mode(resolvedColor, BlendMode.srcIn),
      ),
      OiAssetIconSource(:final asset, :final package) => SvgPicture.asset(
        asset,
        package: package,
        width: resolvedSize,
        height: resolvedSize,
        theme: SvgTheme(currentColor: resolvedColor ?? const Color(0xff000000)),
        colorFilter: resolvedColor == null
            ? null
            : ColorFilter.mode(resolvedColor, BlendMode.srcIn),
      ),
      _ => Icon(
        source is OiFontIconSource ? source.icon : icon,
        size: resolvedSize,
        color: resolvedColor,
        textDirection: textDirection,
        shadows: shadows,
        weight: weight,
        fill: fill,
        grade: grade,
        opticalSize: opticalSize,
        applyTextScaling: applyTextScaling,
      ),
    };
    final excluded = ExcludeSemantics(child: child);
    return _decorative
        ? excluded
        : Semantics(label: label, image: true, child: excluded);
  }
}
