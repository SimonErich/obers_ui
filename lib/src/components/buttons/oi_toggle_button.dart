import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/buttons/oi_button.dart';
import 'package:obers_ui/src/foundation/oi_app.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/interaction/oi_tappable.dart';

/// A button that toggles between selected and unselected states.
///
/// When [selected] is `true` the button renders with a filled primary style.
/// When [selected] is `false` it renders as a ghost/outline button. Tapping
/// calls [onChanged] with the opposite of [selected].
///
/// **Accessibility (REQ-0014):** [semanticLabel] is required so every toggle
/// button has an accessible description announced by screen readers.
///
/// ```dart
/// OiToggleButton(
///   label: 'Bold',
///   selected: _bold,
///   semanticLabel: 'Bold',
///   onChanged: (v) => setState(() => _bold = v),
/// )
/// ```
///
/// {@category Components}
class OiToggleButton extends StatelessWidget {
  /// Creates an [OiToggleButton].
  const OiToggleButton({
    required this.selected,
    required this.semanticLabel,
    this.label,
    this.icon,
    this.onChanged,
    this.size = OiButtonSize.medium,
    this.enabled = true,
    super.key,
  });

  /// Accessibility label announced by screen readers.
  final String semanticLabel;

  /// Optional text label.
  final String? label;

  /// Optional icon displayed alongside or instead of [label].
  final IconData? icon;

  /// Whether this button is in the selected / active state.
  final bool selected;

  /// Called when the button is tapped with the new selected value.
  final ValueChanged<bool>? onChanged;

  /// The size tier.
  final OiButtonSize size;

  /// Whether the button responds to interactions.
  final bool enabled;

  double _buttonHeight(OiDensity density) {
    switch (size) {
      case OiButtonSize.small:
        switch (density) {
          case OiDensity.comfortable:
            return 28;
          case OiDensity.compact:
            return 24;
          case OiDensity.dense:
            return 20;
        }
      case OiButtonSize.medium:
        switch (density) {
          case OiDensity.comfortable:
            return 36;
          case OiDensity.compact:
            return 32;
          case OiDensity.dense:
            return 28;
        }
      case OiButtonSize.large:
        switch (density) {
          case OiDensity.comfortable:
            return 44;
          case OiDensity.compact:
            return 40;
          case OiDensity.dense:
            return 36;
        }
    }
  }

  double _iconSize() {
    switch (size) {
      case OiButtonSize.small:
        return 14;
      case OiButtonSize.medium:
        return 16;
      case OiButtonSize.large:
        return 18;
    }
  }

  double _fontSize() {
    switch (size) {
      case OiButtonSize.small:
        return 12;
      case OiButtonSize.medium:
        return 14;
      case OiButtonSize.large:
        return 16;
    }
  }

  @override
  Widget build(BuildContext context) {
    final density = OiDensityScope.of(context);
    final colors = context.colors;
    final spacing = context.spacing;
    final radius = context.radius;

    final height = _buttonHeight(density);

    final bgColor = selected ? colors.primary.base : const Color(0x00000000);
    final fgColor = selected ? colors.primary.foreground : colors.text;
    final border = selected ? null : Border.all(color: colors.border);
    final borderRadius = context.components.button?.borderRadius ?? radius.sm;

    double hPad;
    switch (size) {
      case OiButtonSize.small:
        hPad = spacing.sm;
      case OiButtonSize.medium:
        hPad = spacing.md;
      case OiButtonSize.large:
        hPad = spacing.lg;
    }

    Widget content;
    if (icon != null && label != null) {
      content = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: _iconSize(), color: fgColor),
          SizedBox(width: spacing.xs),
          Text(
            label!,
            style: TextStyle(
              fontSize: _fontSize(),
              fontWeight: FontWeight.w500,
              color: fgColor,
              height: 1,
            ),
          ),
        ],
      );
    } else if (icon != null) {
      content = Icon(icon, size: _iconSize(), color: fgColor);
    } else {
      content = Text(
        label ?? '',
        style: TextStyle(
          fontSize: _fontSize(),
          fontWeight: FontWeight.w500,
          color: fgColor,
          height: 1,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }

    return OiTappable(
      onTap: enabled ? () => onChanged?.call(!selected) : null,
      enabled: enabled,
      semanticLabel: semanticLabel,
      child: Container(
        height: height,
        padding: EdgeInsets.symmetric(horizontal: hPad),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: borderRadius,
          border: border,
        ),
        child: Center(child: content),
      ),
    );
  }
}
