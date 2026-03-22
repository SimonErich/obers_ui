import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/buttons/oi_button.dart';
import 'package:obers_ui/src/components/buttons/oi_icon_button.dart';
import 'package:obers_ui/src/foundation/oi_responsive.dart';
import 'package:obers_ui/src/foundation/theme/oi_decoration_theme.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/display/oi_label.dart';
import 'package:obers_ui/src/primitives/display/oi_surface.dart';
import 'package:obers_ui/src/primitives/layout/oi_row.dart';

// Material Icons codepoints.
const IconData _kRemoveIcon = IconData(0xe15b, fontFamily: 'MaterialIcons');
const IconData _kAddIcon = IconData(0xe145, fontFamily: 'MaterialIcons');

/// A compact, touch-friendly number stepper for product quantities.
///
/// Coverage: REQ-0045
///
/// Minus button, display value, plus button. Boundary buttons are disabled at
/// [min] / [max]. Supports [compact] mode for dense layouts, [disabled] state,
/// and keyboard arrow up/down for accessibility.
///
/// Composes [OiRow], [OiIconButton], [OiLabel], [OiSurface].
///
/// {@category Components}
class OiQuantitySelector extends StatelessWidget {
  /// Creates an [OiQuantitySelector].
  const OiQuantitySelector({
    required this.value,
    required this.label,
    this.onChange,
    this.min = 1,
    this.max = 99,
    this.compact = false,
    this.disabled = false,
    super.key,
  });

  /// The current quantity value.
  final int value;

  /// Accessibility label announced by screen readers.
  final String label;

  /// Called when the user changes the quantity.
  final ValueChanged<int>? onChange;

  /// Minimum allowed value. Defaults to 1.
  final int min;

  /// Maximum allowed value. Defaults to 99.
  final int max;

  /// When `true`, renders smaller controls suitable for cart rows.
  final bool compact;

  /// When `true`, all controls are disabled.
  final bool disabled;

  /// Whether the value is at the minimum.
  bool get _atMin => value <= min;

  /// Whether the value is at the maximum.
  bool get _atMax => value >= max;

  /// Whether the widget responds to interactions.
  bool get _interactive => !disabled && onChange != null;

  Widget _buildMinusButton(BuildContext context) {
    return OiIconButton(
      icon: _kRemoveIcon,
      semanticLabel: 'Decrease quantity',
      onTap: _interactive && !_atMin ? () => onChange!(value - 1) : null,
      size: compact ? OiButtonSize.small : OiButtonSize.medium,
      enabled: _interactive && !_atMin,
    );
  }

  Widget _buildPlusButton(BuildContext context) {
    return OiIconButton(
      icon: _kAddIcon,
      semanticLabel: 'Increase quantity',
      onTap: _interactive && !_atMax ? () => onChange!(value + 1) : null,
      size: compact ? OiButtonSize.small : OiButtonSize.medium,
      enabled: _interactive && !_atMax,
    );
  }

  Widget _buildValueDisplay(BuildContext context) {
    final width = compact ? 28.0 : 36.0;
    return SizedBox(
      width: width,
      child: Center(
        child: compact
            ? OiLabel.small('$value', textAlign: TextAlign.center)
            : OiLabel.body('$value', textAlign: TextAlign.center),
      ),
    );
  }

  KeyEventResult _onKeyEvent(FocusNode node, KeyEvent event) {
    if (!_interactive) return KeyEventResult.ignored;
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }

    if (event.logicalKey == LogicalKeyboardKey.arrowUp && !_atMax) {
      onChange!(value + 1);
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowDown && !_atMin) {
      onChange!(value - 1);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final breakpoint = context.breakpoint;
    final colors = context.colors;
    final sp = context.spacing;

    Widget content = OiRow(
      breakpoint: breakpoint,
      children: [
        _buildMinusButton(context),
        _buildValueDisplay(context),
        _buildPlusButton(context),
      ],
    );

    content = OiSurface(
      borderRadius: context.radius.sm,
      border: OiBorderStyle.solid(colors.borderSubtle, 1),
      padding: EdgeInsets.symmetric(
        horizontal: compact ? sp.xs : sp.sm,
        vertical: compact ? 2 : sp.xs,
      ),
      child: content,
    );

    if (disabled) {
      content = Opacity(opacity: 0.4, child: content);
    }

    return Semantics(
      label: '$label, Quantity: $value, minimum $min, maximum $max',
      value: '$value',
      increasedValue: _atMax ? null : '${value + 1}',
      decreasedValue: _atMin ? null : '${value - 1}',
      child: Focus(
        onKeyEvent: _onKeyEvent,
        child: ExcludeSemantics(child: content),
      ),
    );
  }
}
