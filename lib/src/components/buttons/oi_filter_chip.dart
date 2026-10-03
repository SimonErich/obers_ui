import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/oi_icons.dart';
import 'package:obers_ui/src/foundation/theme/oi_decoration_theme.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/display/oi_icon.dart';
import 'package:obers_ui/src/primitives/display/oi_surface.dart';
import 'package:obers_ui/src/primitives/interaction/oi_tappable.dart';

/// A compact filter trigger or selectable facet with an optional remove action.
///
/// Unselected filters use a dashed outline and plus icon; selected filters use
/// the theme's soft primary surface. Both actions retain keyboard focus and
/// activation, and expand their hit targets automatically for touch input.
///
/// {@category Components}
class OiFilterChip extends StatelessWidget {
  /// Creates a filter chip; [value] describes an already-applied filter.
  const OiFilterChip({
    required this.label,
    this.value,
    this.selected = false,
    this.onTap,
    this.onRemove,
    this.semanticLabel,
    this.removeLabel,
    this.dashed = true,
    this.showCheckmark = true,
    this.showAddIcon = true,
    this.height = 32,
    this.textStyle,
    this.borderRadius,
    super.key,
  });

  /// Filter name or facet label.
  final String label;

  /// Optional summary of the currently applied value.
  final String? value;

  /// Whether the filter or facet is active.
  final bool selected;

  /// Opens the filter editor or toggles the facet.
  final VoidCallback? onTap;

  /// Optional separate action to clear the applied filter.
  final VoidCallback? onRemove;

  /// Overrides the accessible name of the primary action.
  final String? semanticLabel;

  /// Localized accessible name for removal; defaults to `Remove [label]`.
  final String? removeLabel;

  /// Uses a dashed inactive border; false uses an ordinary solid border.
  final bool dashed;

  /// Shows a checkmark for selected facets without a separate remove action.
  final bool showCheckmark;

  /// Shows a plus on inactive filters; hide it for ordinary choice chips.
  final bool showAddIcon;

  /// Visual height; touch targets remain independent of visual density.
  final double height;

  /// Optional text style; otherwise uses the theme body style.
  final TextStyle? textStyle;

  /// Optional corner radius; otherwise uses the button theme radius.
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final radius =
        borderRadius ??
        context.components.button?.borderRadius ??
        BorderRadius.circular(8);
    final solidBorder = !dashed;
    final style =
        textStyle ??
        context.textTheme.body.copyWith(
          fontFeatures: solidBorder
              ? const [FontFeature.tabularFigures()]
              : null,
          fontWeight: solidBorder && selected ? FontWeight.w500 : null,
        );
    final foreground = selected
        ? (solidBorder ? colors.primary.dark : colors.primary.base)
        : (solidBorder ? colors.text : colors.textMuted);
    final icon = !selected
        ? (showAddIcon ? OiIcons.plus : null)
        : onRemove == null && showCheckmark
        ? OiIcons.check
        : null;
    final contentHeight = (height - (solidBorder ? 2 : 0)).clamp(
      0.0,
      double.infinity,
    );
    return OiSurface(
      color: selected ? colors.primary.muted : const Color(0x00000000),
      borderRadius: radius,
      border: selected
          ? (dashed
                ? null
                : OiBorderStyle.solid(
                    colors.primary.base,
                    1,
                    borderRadius: radius,
                  ))
          : dashed
          ? OiBorderStyle.dashed(colors.border, 1, borderRadius: radius)
          : OiBorderStyle.solid(colors.border, 1, borderRadius: radius),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Semantics(
              selected: selected,
              child: OiTappable(
                semanticLabel:
                    semanticLabel ?? '$label${value == null ? '' : ' $value'}',
                enabled: onTap != null,
                onTap: onTap,
                clipBorderRadius: radius,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: contentHeight),
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: solidBorder ? 12 : 10,
                      right: onRemove == null ? (solidBorder ? 12 : 10) : 6,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (icon != null) ...[
                          OiIcon.raw(
                            icon,
                            size: 16,
                            color: foreground,
                          ),
                          const SizedBox(width: 6),
                        ],
                        Flexible(
                          child: ExcludeSemantics(
                            child: Text.rich(
                              TextSpan(
                                text: label,
                                style: style.copyWith(
                                  color: value == null
                                      ? foreground
                                      : colors.textMuted,
                                ),
                                children: [
                                  if (value != null) ...[
                                    const WidgetSpan(child: SizedBox(width: 6)),
                                    TextSpan(
                                      text: value,
                                      style: style.copyWith(
                                        color: foreground,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (onRemove != null)
            OiTappable(
              semanticLabel: removeLabel ?? 'Remove $label',
              onTap: onRemove,
              clipBorderRadius: radius,
              child: SizedBox(
                width: 28,
                height: contentHeight,
                child: Center(
                  child: OiIcon.raw(OiIcons.x, size: 12, color: foreground),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
