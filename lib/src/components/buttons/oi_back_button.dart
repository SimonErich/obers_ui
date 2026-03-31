import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart' show OiSliverHeader;
import 'package:obers_ui/src/components/display/oi_sliver_header.dart'
    show OiSliverHeader;
import 'package:obers_ui/src/foundation/oi_icons.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';

/// A themed back-navigation button.
///
/// Renders a chevron-left icon that is RTL-aware (flips to chevron-right in
/// right-to-left layouts). Typically used as the leading widget in
/// [OiSliverHeader] or custom app bars.
///
/// {@category Components}
class OiBackButton extends StatefulWidget {
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
  State<OiBackButton> createState() => _OiBackButtonState();
}

class _OiBackButtonState extends State<OiBackButton> {
  bool _highlighted = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final iconColor = _highlighted
        ? colors.primary.base
        : widget.color ?? colors.text;
    Widget icon = Icon(
      isRtl ? OiIcons.chevronRight : OiIcons.chevronLeft,
      size: widget.size,
      color: iconColor,
    );

    if (_highlighted) {
      icon = Transform.scale(scale: 1.15, child: icon);
    }

    Widget content = Padding(
      padding: const EdgeInsets.all(8),
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: Center(child: icon),
      ),
    );

    content = GestureDetector(
      onTap: widget.onPressed,
      behavior: HitTestBehavior.opaque,
      child: content,
    );

    content = MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _highlighted = true),
      onExit: (_) => setState(() => _highlighted = false),
      child: content,
    );

    content = Focus(
      canRequestFocus: true,
      onFocusChange: (focused) => setState(() => _highlighted = focused),
      child: content,
    );

    return Semantics(
      label: widget.semanticLabel,
      button: true,
      child: content,
    );
  }
}
