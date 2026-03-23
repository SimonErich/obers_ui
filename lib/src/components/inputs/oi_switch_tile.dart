import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/display/oi_list_tile.dart';
import 'package:obers_ui/src/components/inputs/oi_checkbox.dart';
import 'package:obers_ui/src/components/inputs/oi_radio.dart';
import 'package:obers_ui/src/components/inputs/oi_switch.dart';

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

/// A list tile with an [OiRadio] indicator as its trailing widget.
///
/// Tapping anywhere on the tile selects this option. When [enabled] is `false`
/// the tile is rendered at reduced opacity and does not respond to taps.
///
/// {@category Components}
class OiRadioTile<T> extends StatelessWidget {
  /// Creates an [OiRadioTile].
  const OiRadioTile({
    required this.title,
    required this.value,
    required this.groupValue,
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

    // Build a single-option OiRadio to render just the circle indicator.
    final radioIndicator = OiRadio<T>(
      options: [OiRadioOption<T>(value: value, label: '')],
      value: groupValue,
      onChanged: enabled ? onChanged : null,
      enabled: enabled,
    );

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
