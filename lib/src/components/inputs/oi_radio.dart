import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/interaction/oi_tappable.dart';

/// A single option in an [OiRadio] group.
///
/// {@category Components}
@immutable
class OiRadioOption<T> {
  /// Creates an [OiRadioOption].
  const OiRadioOption({
    required this.value,
    required this.label,
    this.enabled = true,
  });

  /// The value this option represents.
  final T value;

  /// The human-readable label for this option.
  final String label;

  /// Whether this option can be selected.
  final bool enabled;
}

/// A group of radio-button options rendered in a row or column.
///
/// Each option shows a circular indicator and a text label, wrapped in an
/// [OiTappable]. Only one option may be selected at a time; tapping an option
/// calls [onChanged] with its value.
///
/// {@category Components}
class OiRadio<T> extends StatelessWidget {
  /// Creates an [OiRadio].
  const OiRadio({
    required this.options,
    this.value,
    this.onChanged,
    this.enabled = true,
    this.direction = Axis.vertical,
    super.key,
  });

  /// The currently selected value.
  final T? value;

  /// The list of options to display.
  final List<OiRadioOption<T>> options;

  /// Called when the user selects an option.
  final ValueChanged<T>? onChanged;

  /// Whether the group responds to taps.
  final bool enabled;

  /// The axis along which options are laid out.
  final Axis direction;

  Widget _buildOption(BuildContext context, OiRadioOption<T> option) {
    final colors = context.colors;
    final isSelected = option.value == value;
    final isDisabled = !enabled || !option.enabled;

    const outerSize = 18.0;
    const innerSize = 8.0;

    final outerColor = isSelected ? colors.primary.base : colors.border;

    final circle = CustomPaint(
      size: const Size(outerSize, outerSize),
      painter: _OiRadioPainter(
        selected: isSelected,
        outerColor: outerColor,
        innerColor: colors.textOnPrimary,
        outerSize: outerSize,
        innerSize: innerSize,
      ),
    );

    return OiTappable(
      onTap: isDisabled ? null : () => onChanged?.call(option.value),
      enabled: !isDisabled,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            circle,
            const SizedBox(width: 8),
            Text(
              option.label,
              style: TextStyle(
                fontSize: 14,
                color: isDisabled ? colors.textMuted : colors.text,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final children = options.map((o) => _buildOption(context, o)).toList();

    if (direction == Axis.horizontal) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children:
            children.expand((w) => [w, const SizedBox(width: 16)]).toList()
              ..removeLast(),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }
}

// ---------------------------------------------------------------------------
// Painter
// ---------------------------------------------------------------------------

class _OiRadioPainter extends CustomPainter {
  const _OiRadioPainter({
    required this.selected,
    required this.outerColor,
    required this.innerColor,
    required this.outerSize,
    required this.innerSize,
  });

  final bool selected;
  final Color outerColor;
  final Color innerColor;
  final double outerSize;
  final double innerSize;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = outerSize / 2;

    canvas
      ..drawCircle(
        center,
        radius,
        Paint()..color = selected ? outerColor : const Color(0x00000000),
      )
      ..drawCircle(
        center,
        radius,
        Paint()
          ..color = outerColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );

    if (selected) {
      // Inner filled dot on primary background.
      canvas.drawCircle(
        center,
        innerSize / 2,
        Paint()..color = innerColor,
      );
    }
  }

  @override
  bool shouldRepaint(_OiRadioPainter old) =>
      old.selected != selected ||
      old.outerColor != outerColor ||
      old.innerColor != innerColor;
}
