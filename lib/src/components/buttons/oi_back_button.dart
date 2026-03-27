import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart' show OiSliverHeader;
import 'package:obers_ui/src/components/display/oi_sliver_header.dart'
    show OiSliverHeader;
import 'package:obers_ui/src/foundation/oi_icons.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/interaction/oi_tappable.dart';

/// A themed back-navigation button.
///
/// Renders a chevron-left icon that is RTL-aware (flips to chevron-right in
/// right-to-left layouts). Typically used as the leading widget in
/// [OiSliverHeader] or custom app bars.
///
/// {@category Components}
class OiBackButton extends StatelessWidget {
  /// Creates an [OiBackButton].
  const OiBackButton({
    required this.onPressed,
    required this.semanticLabel,
    this.color,
    this.size = 24.0,
    super.key,
  });

  /// Called when the button is tapped.
  final VoidCallback onPressed;

  /// Icon color override. Defaults to theme text color.
  final Color? color;

  /// Icon size. Default: 24.
  final double size;

  /// Accessibility label. Default: "Go back".
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return OiTappable(
      onTap: onPressed,
      semanticLabel: semanticLabel,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Icon(
          isRtl ? OiIcons.chevronRight : OiIcons.chevronLeft,
          size: size,
          color: color ?? colors.text,
        ),
      ),
    );
  }
}
