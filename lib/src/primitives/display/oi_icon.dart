import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/icons/oi_icon_data.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';

/// A semantically-annotated icon widget.
///
/// [OiIcon] wraps an [IconData] with an [Icon] widget and adds a
/// [Semantics] node so that screen readers can announce the icon's purpose.
///
/// **Accessibility (REQ-0020):** [label] is required so every meaningful icon
/// has an accessible description. Use [OiIcon.decorative] for purely decorative
/// icons that should be excluded from the accessibility tree.
///
/// The [size] defaults to the body font size from the active theme when not
/// supplied.
///
/// {@category Primitives}
class OiIcon extends StatelessWidget {
  /// Creates a semantic [OiIcon].
  ///
  /// [label] is announced by screen readers; it is required so that
  /// every meaningful icon has an accessible description.
  const OiIcon({
    required this.icon,
    required this.label,
    this.size,
    this.color,
    super.key,
  }) : _decorative = false;

  /// Creates a purely decorative [OiIcon] that is excluded from the
  /// accessibility tree.
  const OiIcon.decorative({
    required this.icon,
    this.size,
    this.color,
    super.key,
  }) : label = '',
       _decorative = true;

  /// The icon glyph to render.
  final OiIconData icon;

  /// The accessibility label announced by screen readers.
  ///
  /// Empty for decorative icons created via [OiIcon.decorative].
  final String label;

  /// The size of the icon in logical pixels.
  ///
  /// Defaults to `iconSizes.md` from the nearest [OiTheme]. Prefer passing a
  /// value from that ladder over a literal, so icon sizes can be retuned in
  /// one place.
  final double? size;

  /// The color of the icon.
  ///
  /// When null the nearest [DefaultTextStyle] color is used.
  final Color? color;

  final bool _decorative;

  @override
  Widget build(BuildContext context) {
    // The icon ladder, not the body font size: an interface with 15dp body
    // text does not want 15dp icons, and sizing a glyph off a text style makes
    // it drift every time the type scale is retuned.
    final resolvedSize = size ?? context.iconSizes.md;

    final resolvedColor = color ?? context.colors.text;
    final iconWidget = Icon(icon, size: resolvedSize, color: resolvedColor);

    if (_decorative) {
      return ExcludeSemantics(child: iconWidget);
    }

    return Semantics(
      label: label,
      image: true,
      child: ExcludeSemantics(child: iconWidget),
    );
  }
}
