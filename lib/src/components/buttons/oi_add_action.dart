import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/oi_icons.dart';
import 'package:obers_ui/src/foundation/theme/oi_decoration_theme.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/display/oi_icon.dart';
import 'package:obers_ui/src/primitives/display/oi_label.dart';
import 'package:obers_ui/src/primitives/display/oi_surface.dart';
import 'package:obers_ui/src/primitives/interaction/oi_tappable.dart';

/// Presentation for a managed collection insertion action.
enum OiAddActionPresentation {
  /// Quiet dashed insertion control.
  dashed,

  /// Outlined search-shaped trigger without an editable text connection.
  search,
}

/// A quiet full-width collection insertion action with optional guidance.
/// Uses the shared interaction, focus, touch target and surface contracts.
class OiAddAction extends StatelessWidget {
  /// Creates an insertion action. A null callback disables interaction.
  const OiAddAction({
    required this.label,
    this.caption,
    this.onTap,
    this.presentation = OiAddActionPresentation.dashed,
    this.placeholder,
    super.key,
  });

  /// Visible and accessible action name.
  final String label;

  /// Visual treatment; keyboard and pointer behavior remain identical.
  final OiAddActionPresentation presentation;

  /// Optional search hint; [label] remains the accessible action name.
  final String? placeholder;

  /// Optional trailing context, such as an availability deadline.
  final String? caption;

  /// Action performed by the host owning the collection.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => OiTappable(
    semanticLabel: label,
    enabled: onTap != null,
    onTap: onTap,
    clipBorderRadius: context.radius.sm,
    child: ExcludeSemantics(
      child: OiSurface(
        color: presentation == OiAddActionPresentation.search
            ? context.colors.surface
            : const Color(0x00000000),
        borderRadius: context.radius.sm,
        border: OiBorderStyle(
          width: 1,
          color: context.colors.border,
          lineStyle: presentation == OiAddActionPresentation.search
              ? OiBorderLineStyle.solid
              : OiBorderLineStyle.dashed,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: 12,
          vertical: presentation == OiAddActionPresentation.search ? 0 : 8,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: presentation == OiAddActionPresentation.search
                ? (context.components.textInput?.height ?? 36) - 2
                : 0,
          ),
          child: Row(
            children: [
              OiIcon.raw(
                presentation == OiAddActionPresentation.search
                    ? OiIcons.search
                    : OiIcons.plus,
                size: 16,
                color: context.colors.textMuted,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: OiLabel.body(
                  placeholder ?? label,
                  color: context.colors.textMuted,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (caption != null) ...[
                const SizedBox(width: 8),
                OiLabel.caption(caption!, color: context.colors.textMuted),
              ],
            ],
          ),
        ),
      ),
    ),
  );
}
