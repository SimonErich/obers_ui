import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/buttons/oi_button.dart';
import 'package:obers_ui/src/components/buttons/oi_icon_button.dart';
import 'package:obers_ui/src/foundation/oi_icons.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/utils/color_utils.dart';

/// A compact preview of a message being replied to.
///
/// Displays a coloured accent bar on the left, the sender name and a
/// single-line content preview with ellipsis overflow.  When [dismissible]
/// is `true` a close button is shown so the user can cancel the reply
/// (typical usage: inside a compose bar).
///
/// {@category Components}
class OiReplyPreview extends StatelessWidget {
  /// Creates an [OiReplyPreview].
  const OiReplyPreview({
    required this.senderName,
    required this.content,
    super.key,
    this.accentColor,
    this.dismissible = false,
    this.onDismiss,
    this.label,
  });

  /// Display name of the original message sender.
  final String senderName;

  /// Text content of the original message (shown as single-line preview).
  final String content;

  /// Colour of the 3 px accent bar on the leading edge.
  ///
  /// When `null` the colour is auto-derived from [senderName] via a
  /// deterministic hash so the same sender always gets the same colour.
  final Color? accentColor;

  /// Whether a close button is rendered to dismiss this preview.
  final bool dismissible;

  /// Called when the close button is tapped.
  ///
  /// Only invoked when [dismissible] is `true`.
  final VoidCallback? onDismiss;

  /// Accessibility label for the reply preview region.
  ///
  /// Defaults to `'Replying to <senderName>'`.
  final String? label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;

    final resolvedAccent = accentColor ?? OiColorUtils.fromString(senderName);

    return Semantics(
      container: true,
      label: label ?? 'Replying to $senderName',
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: spacing.sm,
          vertical: spacing.xs,
        ),
        child: Row(
          children: [
            // ── Accent bar ──────────────────────────────────────────────
            Container(
              width: 3,
              constraints: const BoxConstraints(minHeight: 32),
              decoration: BoxDecoration(
                color: resolvedAccent,
                borderRadius: BorderRadius.circular(1.5),
              ),
            ),
            SizedBox(width: spacing.sm),

            // ── Content ─────────────────────────────────────────────────
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    senderName,
                    style: TextStyle(
                      color: resolvedAccent,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    content,
                    style: TextStyle(color: colors.textSubtle, fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // ── Dismiss button ──────────────────────────────────────────
            if (dismissible)
              Padding(
                padding: EdgeInsets.only(left: spacing.xs),
                child: OiIconButton(
                  icon: OiIcons.undo2,
                  semanticLabel: 'Cancel reply',
                  onTap: onDismiss,
                  size: OiButtonSize.small,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
