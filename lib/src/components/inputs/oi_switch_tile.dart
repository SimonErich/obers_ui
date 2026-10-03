import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/display/oi_list_tile.dart';
import 'package:obers_ui/src/components/inputs/oi_checkbox.dart';
import 'package:obers_ui/src/components/inputs/oi_radio.dart';
import 'package:obers_ui/src/components/inputs/oi_switch.dart';
import 'package:obers_ui/src/foundation/oi_icons.dart';
import 'package:obers_ui/src/foundation/theme/oi_text_theme.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/display/oi_icon.dart';
import 'package:obers_ui/src/primitives/display/oi_label.dart';
import 'package:obers_ui/src/primitives/interaction/oi_tappable.dart';

// ---------------------------------------------------------------------------
// OiSwitchTile
// ---------------------------------------------------------------------------

/// A list tile with an [OiSwitch] as its trailing widget.
///
/// Tapping anywhere on the tile toggles the switch. When [enabled] is `false`
/// the tile is rendered at reduced opacity and does not respond to taps.
///
/// {@category Components}
class OiSwitchTile extends StatelessWidget {
  /// Creates an [OiSwitchTile].
  const OiSwitchTile({
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle,
    this.leading,
    this.enabled = true,
    this.dense = false,
    this.contentPadding,
    this.semanticLabel,
    super.key,
  });

  /// Primary text content.
  final String title;

  /// Whether the switch is currently on.
  final bool value;

  /// Called when the user toggles the switch.
  final ValueChanged<bool> onChanged;

  /// Optional secondary text rendered below [title].
  final String? subtitle;

  /// Optional widget placed at the start of the row.
  final Widget? leading;

  /// Whether the tile accepts interaction.
  final bool enabled;

  /// When `true`, vertical padding is reduced for a more compact appearance.
  final bool dense;

  /// Optional custom padding around the tile content.
  ///
  /// When `null` the default [OiListTile] padding is used.
  final EdgeInsetsGeometry? contentPadding;

  /// Semantic label for accessibility.
  ///
  /// Falls back to [title] when `null`.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    Widget tile = OiListTile(
      title: title,
      subtitle: subtitle,
      leading: leading,
      dense: dense,
      enabled: enabled,
      onTap: enabled ? () => onChanged(!value) : null,
      trailing: OiSwitch(
        value: value,
        onChanged: enabled ? onChanged : null,
        enabled: enabled,
      ),
    );

    if (contentPadding != null) {
      tile = Padding(padding: contentPadding!, child: tile);
    }

    if (!enabled) {
      tile = Opacity(opacity: 0.6, child: tile);
    }

    return Semantics(
      toggled: value,
      label: semanticLabel ?? title,
      child: tile,
    );
  }
}

// ---------------------------------------------------------------------------
// OiCheckboxTile
// ---------------------------------------------------------------------------

/// A list tile with an [OiCheckbox] as its trailing widget.
///
/// Tapping anywhere on the tile toggles the checkbox. Supports tristate
/// (`true` / `false` / `null`) when [tristate] is `true`. When [enabled] is
/// `false` the tile is rendered at reduced opacity and does not respond to
/// taps.
///
/// {@category Components}
class OiCheckboxTile extends StatelessWidget {
  /// Creates an [OiCheckboxTile].
  const OiCheckboxTile({
    required this.title,
    required this.onChanged,
    this.value,
    this.tristate = false,
    this.subtitle,
    this.leading,
    this.enabled = true,
    this.dense = false,
    this.contentPadding,
    this.semanticLabel,
    super.key,
  });

  /// Primary text content.
  final String title;

  /// The current checkbox state.
  ///
  /// `true` = checked, `false` = unchecked, `null` = indeterminate (only
  /// when [tristate] is `true`).
  final bool? value;

  /// Called when the user toggles the checkbox.
  ///
  /// Receives `true` when the new state is checked, `false` otherwise.
  final ValueChanged<bool> onChanged;

  /// When `true`, the checkbox cycles through three states: unchecked,
  /// checked, and indeterminate.
  final bool tristate;

  /// Optional secondary text rendered below [title].
  final String? subtitle;

  /// Optional widget placed at the start of the row.
  final Widget? leading;

  /// Whether the tile accepts interaction.
  final bool enabled;

  /// When `true`, vertical padding is reduced for a more compact appearance.
  final bool dense;

  /// Optional custom padding around the tile content.
  ///
  /// When `null` the default [OiListTile] padding is used.
  final EdgeInsetsGeometry? contentPadding;

  /// Semantic label for accessibility.
  ///
  /// Falls back to [title] when `null`.
  final String? semanticLabel;

  void _handleTap() {
    if (value ?? false) {
      onChanged(false);
    } else {
      onChanged(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget tile = OiListTile(
      title: title,
      subtitle: subtitle,
      leading: leading,
      dense: dense,
      enabled: enabled,
      onTap: enabled ? _handleTap : null,
      trailing: OiCheckbox(
        value: value,
        onChanged: enabled ? onChanged : null,
        enabled: enabled,
      ),
    );

    if (contentPadding != null) {
      tile = Padding(padding: contentPadding!, child: tile);
    }

    if (!enabled) {
      tile = Opacity(opacity: 0.6, child: tile);
    }

    return Semantics(
      checked: value ?? false,
      label: semanticLabel ?? title,
      child: tile,
    );
  }
}

// ---------------------------------------------------------------------------
// OiRadioTile
// ---------------------------------------------------------------------------

/// Visual selection marker for a radio tile.
enum OiRadioTileIndicator {
  /// Uses the selected card outline and fill without reserving control space.
  /// Selection and keyboard semantics remain unchanged.
  none,

  /// Circular radio control.
  radio,

  /// A check on the selected option, with an empty slot otherwise.
  check,
}

/// A radio choice with optional rich card content.
class OiRadioTile<T> extends StatelessWidget {
  /// Creates an [OiRadioTile].
  const OiRadioTile({
    required this.title,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    this.titleWidget,
    this.bodyWidget,
    this.controlLeading = false,
    this.indicator = OiRadioTileIndicator.radio,
    this.bordered = true,
    this.details,
    this.badge,
    this.subtitle,
    this.leading,
    this.enabled = true,
    this.dense = false,
    this.contentPadding,
    this.semanticLabel,
    super.key,
  }) : _card = false;

  /// A bordered radio choice with rich supporting content.
  const OiRadioTile.card({
    required this.title,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    this.subtitle,
    this.leading,
    this.titleWidget,
    this.bodyWidget,
    this.controlLeading = false,
    this.indicator = OiRadioTileIndicator.radio,
    this.bordered = true,
    this.details,
    this.badge,
    this.enabled = true,
    this.dense = false,
    this.contentPadding,
    this.semanticLabel,
    super.key,
  }) : _card = true;

  final bool _card;

  /// Places a card's radio before its text instead of after it.
  final bool controlLeading;

  /// Visual selected-state indicator; selection semantics remain radio-like.
  final OiRadioTileIndicator indicator;

  /// Whether a rich card draws its outline. Inline choice lists can omit it.
  final bool bordered;

  /// Rich title content for a card; [title] remains its accessible label.
  final Widget? titleWidget;

  /// Full-width content below a card's title/control row.
  /// Unlike [details], this content is not indented by the selection indicator.
  final Widget? bodyWidget;

  /// Rich supporting content below the description.
  final Widget? details;

  /// Status or supplementary content beside the title.
  final Widget? badge;

  /// Primary text content.
  final String title;

  /// The value this tile represents.
  final T value;

  /// The currently selected value in the radio group.
  final T? groupValue;

  /// Called when the user taps the tile, passing [value].
  final ValueChanged<T> onChanged;

  /// Optional secondary text rendered below [title].
  final String? subtitle;

  /// Optional widget placed at the start of the row.
  final Widget? leading;

  /// Whether the tile accepts interaction.
  final bool enabled;

  /// When `true`, vertical padding is reduced for a more compact appearance.
  final bool dense;

  /// Optional custom padding around the tile content.
  ///
  /// When `null` the default [OiListTile] padding is used.
  final EdgeInsetsGeometry? contentPadding;

  /// Semantic label for accessibility.
  ///
  /// Falls back to [title] when `null`.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final isSelected = value == groupValue;

    final radioIndicator = OiRadioIndicator(selected: isSelected);

    if (_card) {
      final colors = context.colors;
      final tileTheme = context.components.radioTile;
      final radius = tileTheme?.borderRadius ?? context.radius.md;
      final control = indicator == OiRadioTileIndicator.check
          ? SizedBox(
              width: 20,
              height: 20,
              child: isSelected
                  ? OiIcon.decorative(
                      icon: OiIcons.check,
                      size: 18,
                      color: colors.primary.base,
                    )
                  : null,
            )
          : radioIndicator;
      return MergeSemantics(
        child: Semantics(
          button: true,
          label: semanticLabel,
          selected: isSelected,
          inMutuallyExclusiveGroup: true,
          enabled: enabled,
          child: OiTappable(
            enabled: enabled,
            disabledOpacity: 1,
            clipBorderRadius: radius,
            onTap: () => onChanged(value),
            child: Opacity(
              opacity: enabled ? 1 : .45,
              child: Container(
                constraints: BoxConstraints(
                  minHeight: tileTheme?.minHeight ?? 0,
                ),
                padding:
                    contentPadding ??
                    tileTheme?.padding ??
                    EdgeInsets.all(
                      dense ? context.spacing.sm : context.spacing.md,
                    ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? tileTheme?.selectedBackgroundColor ??
                            colors.primary.muted
                      : tileTheme?.backgroundColor ?? colors.surface,
                  borderRadius: radius,
                ),
                // Decoration-only outlines cannot reflow content on selection.
                foregroundDecoration: bordered
                    ? BoxDecoration(
                        borderRadius: radius,
                        border: Border.all(
                          color: isSelected
                              ? tileTheme?.selectedBorderColor ??
                                    colors.primary.base
                              : tileTheme?.borderColor ?? colors.border,
                          width: isSelected
                              ? tileTheme?.selectedBorderWidth ??
                                    tileTheme?.borderWidth ??
                                    1
                              : tileTheme?.borderWidth ?? 1,
                        ),
                      )
                    : null,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: bodyWidget == null
                      ? MainAxisAlignment.center
                      : MainAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: dense
                          ? CrossAxisAlignment.center
                          : CrossAxisAlignment.start,
                      children: [
                        if (controlLeading &&
                            indicator != OiRadioTileIndicator.none) ...[
                          control,
                          SizedBox(
                            width: tileTheme?.controlGap ?? context.spacing.sm,
                          ),
                        ],
                        if (leading != null)
                          Padding(
                            padding: EdgeInsetsDirectional.only(
                              end: context.spacing.sm,
                            ),
                            child: leading,
                          ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child:
                                        titleWidget ??
                                        OiLabel.variant(
                                          title,
                                          variant: OiLabelVariant.bodyStrong,
                                          style: tileTheme?.titleStyle,
                                        ),
                                  ),
                                  ?badge,
                                ],
                              ),
                              if (subtitle != null)
                                Padding(
                                  padding: EdgeInsets.only(
                                    top: context.spacing.xs,
                                  ),
                                  child: OiLabel.small(
                                    subtitle!,
                                    color: colors.textMuted,
                                  ),
                                ),
                              if (details != null)
                                Padding(
                                  padding: EdgeInsets.only(
                                    top: context.spacing.sm,
                                  ),
                                  child: details,
                                ),
                            ],
                          ),
                        ),
                        if (!controlLeading &&
                            indicator != OiRadioTileIndicator.none) ...[
                          SizedBox(
                            width: tileTheme?.controlGap ?? context.spacing.sm,
                          ),
                          control,
                        ],
                      ],
                    ),
                    if (bodyWidget != null)
                      Padding(
                        padding: EdgeInsets.only(
                          top: tileTheme?.bodyGap ?? context.spacing.sm,
                        ),
                        child: bodyWidget,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    Widget tile = OiListTile(
      title: title,
      subtitle: subtitle,
      leading: leading,
      dense: dense,
      enabled: enabled,
      selected: isSelected,
      onTap: enabled ? () => onChanged(value) : null,
      trailing: radioIndicator,
    );

    if (contentPadding != null) {
      tile = Padding(padding: contentPadding!, child: tile);
    }

    if (!enabled) {
      tile = Opacity(opacity: 0.6, child: tile);
    }

    return Semantics(
      selected: isSelected,
      label: semanticLabel ?? title,
      child: tile,
    );
  }
}
