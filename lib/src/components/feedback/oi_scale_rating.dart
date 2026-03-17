import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/interaction/oi_tappable.dart';

/// A numeric scale rating widget (e.g. NPS 1–10).
///
/// Renders a [Row] of numbered buttons from 1 to [scale]. The currently
/// selected button (matching [value]) is highlighted with the primary color.
/// Optional [startLabel] and [endLabel] strings are shown at the left and right
/// ends of the scale. When [enabled] is `false` all buttons are non-interactive.
///
/// {@category Components}
class OiScaleRating extends StatelessWidget {
  /// Creates an [OiScaleRating].
  const OiScaleRating({
    this.value,
    this.scale = 10,
    this.onChanged,
    this.startLabel,
    this.endLabel,
    this.enabled = true,
    super.key,
  });

  /// The currently selected value (1 to [scale]), or null for no selection.
  final int? value;

  /// The maximum scale value. Defaults to 10.
  final int scale;

  /// Called when the user selects a number.
  final ValueChanged<int>? onChanged;

  /// Label shown to the left of the scale buttons (e.g. "Not likely").
  final String? startLabel;

  /// Label shown to the right of the scale buttons (e.g. "Very likely").
  final String? endLabel;

  /// Whether the widget is interactive. Defaults to `true`.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = context.textTheme;

    final buttons = List<Widget>.generate(scale, (i) {
      final n = i + 1;
      final selected = value == n;
      final bg = selected ? colors.primary.base : colors.surface;
      final fg = selected ? colors.textOnPrimary : colors.text;

      return OiTappable(
        enabled: enabled,
        onTap: enabled ? () => onChanged?.call(n) : null,
        child: Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: selected ? colors.primary.base : colors.border,
            ),
          ),
          child: Text(
            '$n',
            style: textTheme.small.copyWith(
              color: fg,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
        ),
      );
    });

    Widget row = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < buttons.length; i++) ...[
          if (i > 0) const SizedBox(width: 4),
          buttons[i],
        ],
      ],
    );

    if (startLabel != null || endLabel != null) {
      row = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          row,
          const SizedBox(height: 4),
          Row(
            children: [
              if (startLabel != null)
                Text(
                  startLabel!,
                  style: textTheme.tiny.copyWith(color: colors.textMuted),
                ),
              const Spacer(),
              if (endLabel != null)
                Text(
                  endLabel!,
                  style: textTheme.tiny.copyWith(color: colors.textMuted),
                ),
            ],
          ),
        ],
      );
    }

    return Semantics(
      label: 'Scale rating, selected: ${value ?? 'none'} of $scale',
      child: row,
    );
  }
}
