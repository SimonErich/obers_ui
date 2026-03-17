import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/buttons/oi_button.dart';
import 'package:obers_ui/src/foundation/oi_app.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/interaction/oi_tappable.dart';

/// A group of buttons displayed inline with a connected visual appearance.
///
/// Buttons in a group share their borders so that adjacent buttons appear
/// joined together. In [segmented] mode exactly one button is active at a time
/// (the one at [selectedIndex]); tapping any button calls [onSelected] with
/// its index.
///
/// ```dart
/// OiButtonGroup(
///   buttons: [
///     OiButton.outline(label: 'Day'),
///     OiButton.outline(label: 'Week'),
///     OiButton.outline(label: 'Month'),
///   ],
///   segmented: true,
///   selectedIndex: _tab,
///   onSelected: (i) => setState(() => _tab = i),
/// )
/// ```
///
/// {@category Components}
class OiButtonGroup extends StatelessWidget {
  /// Creates an [OiButtonGroup].
  const OiButtonGroup({
    required this.buttons,
    this.orientation = Axis.horizontal,
    this.segmented = false,
    this.selectedIndex,
    this.onSelected,
    super.key,
  });

  /// The buttons to render inside the group.
  final List<OiButton> buttons;

  /// Whether buttons are arranged horizontally or vertically.
  final Axis orientation;

  /// When `true`, tapping a button marks it as selected and calls [onSelected].
  final bool segmented;

  /// The index of the currently selected button in [segmented] mode.
  final int? selectedIndex;

  /// Called with the tapped button's index when [segmented] is `true`.
  final ValueChanged<int>? onSelected;

  @override
  Widget build(BuildContext context) {
    final count = buttons.length;
    if (count == 0) return const SizedBox.shrink();

    final items = List<Widget>.generate(count, (i) {
      return _GroupButtonItem(
        button: buttons[i],
        index: i,
        count: count,
        orientation: orientation,
        segmented: segmented,
        selected: segmented && selectedIndex == i,
        onSelected: onSelected,
      );
    });

    if (orientation == Axis.horizontal) {
      return Row(mainAxisSize: MainAxisSize.min, children: items);
    } else {
      return Column(mainAxisSize: MainAxisSize.min, children: items);
    }
  }
}

// ── Internal per-item widget ──────────────────────────────────────────────

class _GroupButtonItem extends StatelessWidget {
  const _GroupButtonItem({
    required this.button,
    required this.index,
    required this.count,
    required this.orientation,
    required this.segmented,
    required this.selected,
    required this.onSelected,
  });

  final OiButton button;
  final int index;
  final int count;
  final Axis orientation;
  final bool segmented;
  final bool selected;
  final ValueChanged<int>? onSelected;

  @override
  Widget build(BuildContext context) {
    final radius = context.components.button?.borderRadius ?? context.radius.sm;

    // Compute per-corner radii so the group looks connected.
    final BorderRadius borderRadius;
    if (count == 1) {
      borderRadius = radius;
    } else if (orientation == Axis.horizontal) {
      if (index == 0) {
        borderRadius = BorderRadius.only(
          topLeft: radius.topLeft,
          bottomLeft: radius.bottomLeft,
        );
      } else if (index == count - 1) {
        borderRadius = BorderRadius.only(
          topRight: radius.topRight,
          bottomRight: radius.bottomRight,
        );
      } else {
        borderRadius = BorderRadius.zero;
      }
    } else {
      // vertical
      if (index == 0) {
        borderRadius = BorderRadius.only(
          topLeft: radius.topLeft,
          topRight: radius.topRight,
        );
      } else if (index == count - 1) {
        borderRadius = BorderRadius.only(
          bottomLeft: radius.bottomLeft,
          bottomRight: radius.bottomRight,
        );
      } else {
        borderRadius = BorderRadius.zero;
      }
    }

    // In segmented mode, selected = primary fill, others = ghost with border.
    final OiButtonVariant effectiveVariant;
    if (segmented) {
      effectiveVariant =
          selected ? OiButtonVariant.primary : OiButtonVariant.ghost;
    } else {
      effectiveVariant = button.variant;
    }

    final bgColor = _bgColor(context, effectiveVariant);
    final fgColor = _fgColor(context, effectiveVariant);
    final density = OiDensityScope.of(context);
    final height = _buttonHeight(density);
    final hPad = _hPadding(context);

    // Build border: for connected group, share the edge between neighbours.
    final border = _buildBorder(context, effectiveVariant);

    final content = button.label != null
        ? Text(
            button.label!,
            style: TextStyle(
              fontSize: _fontSize(),
              fontWeight: FontWeight.w500,
              color: fgColor,
              height: 1,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          )
        : (button.icon != null
            ? Icon(button.icon, size: _iconSize(), color: fgColor)
            : const SizedBox.shrink());

    final isEnabled = button.enabled;
    final tapCallback = segmented
        ? (isEnabled ? () => onSelected?.call(index) : null)
        : (isEnabled ? button.onTap : null);

    return OiTappable(
      onTap: tapCallback,
      enabled: isEnabled,
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

  Color _bgColor(BuildContext context, OiButtonVariant variant) {
    final c = context.colors;
    switch (variant) {
      case OiButtonVariant.primary:
        return c.primary.base;
      case OiButtonVariant.secondary:
        return c.accent.base;
      case OiButtonVariant.outline:
      case OiButtonVariant.ghost:
        return const Color(0x00000000);
      case OiButtonVariant.destructive:
        return c.error.base;
      case OiButtonVariant.soft:
        return c.primary.muted;
    }
  }

  Color _fgColor(BuildContext context, OiButtonVariant variant) {
    final c = context.colors;
    switch (variant) {
      case OiButtonVariant.primary:
        return c.primary.foreground;
      case OiButtonVariant.secondary:
        return c.accent.foreground;
      case OiButtonVariant.outline:
      case OiButtonVariant.ghost:
        return c.text;
      case OiButtonVariant.destructive:
        return c.error.foreground;
      case OiButtonVariant.soft:
        return c.primary.base;
    }
  }

  Border? _buildBorder(BuildContext context, OiButtonVariant variant) {
    if (variant != OiButtonVariant.outline &&
        variant != OiButtonVariant.ghost &&
        !segmented) {
      return null;
    }
    final borderColor = context.colors.border;
    final side = BorderSide(color: borderColor);

    if (count == 1) {
      return Border.all(color: borderColor);
    }

    if (orientation == Axis.horizontal) {
      // For horizontal groups: left border only on first, right border on last,
      // internal items share a border so we only draw left for non-first.
      if (index == 0) {
        return Border(top: side, bottom: side, left: side);
      } else if (index == count - 1) {
        return Border(top: side, bottom: side, left: side, right: side);
      } else {
        return Border(top: side, bottom: side, left: side);
      }
    } else {
      // Vertical: top border only on first, internal share borders.
      if (index == 0) {
        return Border(top: side, left: side, right: side);
      } else if (index == count - 1) {
        return Border(top: side, left: side, right: side, bottom: side);
      } else {
        return Border(top: side, left: side, right: side);
      }
    }
  }

  double _buttonHeight(OiDensity density) {
    switch (button.size) {
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
    switch (button.size) {
      case OiButtonSize.small:
        return 14;
      case OiButtonSize.medium:
        return 16;
      case OiButtonSize.large:
        return 18;
    }
  }

  double _fontSize() {
    switch (button.size) {
      case OiButtonSize.small:
        return 12;
      case OiButtonSize.medium:
        return 14;
      case OiButtonSize.large:
        return 16;
    }
  }

  double _hPadding(BuildContext context) {
    final sp = context.spacing;
    switch (button.size) {
      case OiButtonSize.small:
        return sp.sm;
      case OiButtonSize.medium:
        return sp.md;
      case OiButtonSize.large:
        return sp.lg;
    }
  }
}
