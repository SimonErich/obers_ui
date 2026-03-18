// Internal widget — no need for public doc comments on private class
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/theme/oi_decoration_theme.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/display/oi_label.dart';
import 'package:obers_ui/src/primitives/display/oi_surface.dart';

class OiInputFrame extends StatelessWidget {
  const OiInputFrame({
    required this.child,
    this.label,
    this.hint,
    this.error,
    this.focused = false,
    this.enabled = true,
    this.readOnly = false,
    this.leading,
    this.trailing,
    this.padding,
    super.key,
  });

  final Widget child;
  final String? label;
  final String? hint;
  final String? error;
  final bool focused;
  final bool enabled;
  final bool readOnly;
  final Widget? leading;
  final Widget? trailing;
  final EdgeInsetsGeometry? padding;

  OiBorderStyle _resolveBorder(BuildContext context) {
    final dec = context.decoration;
    if (error != null && error!.isNotEmpty) {
      return dec.errorBorder;
    }
    if (focused) {
      return dec.focusBorder;
    }
    return dec.defaultBorder;
  }

  @override
  Widget build(BuildContext context) {
    final border = _resolveBorder(context);
    final colors = context.colors;
    final effectivePadding =
        padding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 8);

    final row = Row(
      children: [
        if (leading != null) leading!,
        Expanded(child: child),
        if (trailing != null) trailing!,
      ],
    );

    final surfaceWidget = OiSurface(
      border: border,
      color: enabled ? colors.surface : colors.surfaceSubtle,
      padding: effectivePadding,
      child: row,
    );

    Widget frame = surfaceWidget;

    if (!enabled) {
      frame = Opacity(opacity: 0.6, child: frame);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          OiLabel.small(label!),
          const SizedBox(height: 4),
        ],
        frame,
        if (error != null && error!.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            error!,
            style: TextStyle(
              fontSize: 12,
              color: colors.error.base,
              height: 1.3,
            ),
          ),
        ] else if (hint != null) ...[
          const SizedBox(height: 4),
          Text(
            hint!,
            style: TextStyle(
              fontSize: 12,
              color: colors.textMuted,
              height: 1.3,
            ),
          ),
        ],
      ],
    );
  }
}
