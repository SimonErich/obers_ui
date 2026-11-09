import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/interaction/oi_kbd.dart';
import 'package:obers_ui/src/foundation/oi_icons.dart';
import 'package:obers_ui/src/foundation/theme/oi_text_theme.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/display/oi_icon.dart';
import 'package:obers_ui/src/primitives/display/oi_label.dart';
import 'package:obers_ui/src/primitives/interaction/oi_tappable.dart';

/// An accessible, search-shaped button that opens a command/search overlay.
///
/// It owns no editable text or focus connection. The overlay owns actual search;
/// Enter, Space and pointer activation use the shared interaction primitive.
class OiSearchTrigger extends StatelessWidget {
  /// Creates a search trigger; [shortcut] is a hint, not a key binding.
  const OiSearchTrigger({
    required this.label,
    required this.onPressed,
    this.shortcut = const ['meta', 'K'],
    super.key,
  });

  /// Visible hint and accessible button name.
  final String label;

  /// Opens the owning command/search overlay. Null disables the trigger.
  final VoidCallback? onPressed;

  /// Logical key names, or an empty list to omit the hint.
  final List<String> shortcut;

  @override
  Widget build(BuildContext context) {
    final theme = context.components.searchTrigger;
    final foreground = theme?.foreground ?? context.colors.textMuted;
    final decoration =
        theme?.decoration ??
        BoxDecoration(
          color: context.colors.surface,
          borderRadius: context.radius.md,
          border: Border.all(color: context.colors.borderSubtle),
        );
    final gap = theme?.gap ?? 8;
    return OiTappable(
      semanticLabel: label,
      enabled: onPressed != null,
      onTap: onPressed,
      clipBorderRadius: decoration.borderRadius?.resolve(
        Directionality.of(context),
      ),
      child: ExcludeSemantics(
        child: Container(
          height: theme?.height ?? context.theme.componentSizes.medium,
          padding:
              theme?.padding ??
              const EdgeInsetsDirectional.fromSTEB(12, 0, 8, 0),
          decoration: decoration,
          child: Row(
            children: [
              OiIcon.raw(
                OiIcons.search,
                size: theme?.iconSize ?? 16,
                color: foreground,
              ),
              SizedBox(width: gap),
              Expanded(
                child: OiLabel.variant(
                  label,
                  variant: OiLabelVariant.body,
                  style: theme?.textStyle,
                  color: foreground,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (shortcut.isNotEmpty) ...[
                SizedBox(width: gap),
                OiKbd(keys: shortcut, combineKeys: true),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
