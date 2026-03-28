import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/icons/oi_icon_data.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/display/oi_icon.dart';
import 'package:obers_ui/src/primitives/display/oi_label.dart';
import 'package:obers_ui/src/primitives/interaction/oi_tappable.dart';

/// A compact bottom status bar with leading and trailing widget slots.
///
/// Typically placed at the bottom of an application for displaying
/// status indicators, line/column information, or connection status.
///
/// ```dart
/// OiStatusBar(
///   label: 'Application status',
///   leading: [OiStatusBarItem(label: 'UTF-8')],
///   trailing: [OiStatusBarItem(label: 'Ln 42, Col 8')],
/// )
/// ```
///
/// {@category Components}
class OiStatusBar extends StatelessWidget {
  /// Creates an [OiStatusBar].
  const OiStatusBar({
    required this.label,
    this.leading = const [],
    this.trailing = const [],
    this.height = 24,
    this.backgroundColor,
    super.key,
  });

  /// Accessibility label for the status bar landmark.
  final String label;

  /// Widgets displayed on the left side of the bar.
  final List<Widget> leading;

  /// Widgets displayed on the right side of the bar.
  final List<Widget> trailing;

  /// Height of the status bar. Defaults to 24 dp.
  final double height;

  /// Optional background color override. Defaults to theme surface.
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      label: label,
      container: true,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: backgroundColor ?? colors.surface,
          border: Border(top: BorderSide(color: colors.borderSubtle)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(children: [...leading, const Spacer(), ...trailing]),
      ),
    );
  }
}

/// An individual status indicator for use in [OiStatusBar].
///
/// Shows a compact label with an optional leading icon and color status dot.
///
/// {@category Components}
class OiStatusBarItem extends StatelessWidget {
  /// Creates an [OiStatusBarItem].
  const OiStatusBarItem({
    required this.label,
    this.icon,
    this.color,
    this.onTap,
    super.key,
  });

  /// The display text.
  final String label;

  /// Optional leading icon.
  final OiIconData? icon;

  /// Optional color dot indicating status (e.g. green for connected).
  final Color? color;

  /// Called when the item is tapped.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null)
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: OiIcon.decorative(
              icon: icon!,
              size: 14,
              color: colors.textSubtle,
            ),
          ),
        OiLabel.tiny(label, color: colors.textSubtle),
        if (color != null)
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
          ),
      ],
    );

    if (onTap != null) {
      content = OiTappable(
        onTap: onTap,
        semanticLabel: label,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: content,
        ),
      );
    } else {
      content = Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: content,
      );
    }

    return content;
  }
}
