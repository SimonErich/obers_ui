import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/buttons/oi_button.dart';
import 'package:obers_ui/src/components/buttons/oi_button_group.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';

/// A numeric scale rating widget (e.g. NPS 1–10, satisfaction 1–7).
///
/// Renders a connected [OiButtonGroup] with numbered buttons from [min] to
/// [max]. The currently selected button (matching [value]) is highlighted.
/// Optional [minLabel] and [maxLabel] strings are shown at the left and right
/// ends below the scale. Arrow-key navigation is provided by [OiButtonGroup]
/// when the group is focused.
///
/// When [enabled] is `false` all buttons are non-interactive.
///
/// {@category Components}
class OiScaleRating extends StatelessWidget {
  /// Creates an [OiScaleRating].
  const OiScaleRating({
    this.label,
    this.value,
    this.min = 1,
    this.max = 10,
    this.onChanged,
    this.minLabel,
    this.maxLabel,
    this.enabled = true,
    super.key,
  }) : assert(min <= max, 'min must be <= max');

  /// Accessible label announced by screen readers.
  final String? label;

  /// The currently selected value ([min] to [max]), or null for no selection.
  final int? value;

  /// The minimum scale value. Defaults to 1.
  final int min;

  /// The maximum scale value. Defaults to 10.
  final int max;

  /// Called when the user selects a number.
  final ValueChanged<int>? onChanged;

  /// Label shown to the left of the scale buttons (e.g. "Not likely").
  final String? minLabel;

  /// Label shown to the right of the scale buttons (e.g. "Very likely").
  final String? maxLabel;

  /// Whether the widget is interactive. Defaults to `true`.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;
    final colors = context.colors;
    final count = max - min + 1;

    final items = List<OiButtonGroupItem>.generate(count, (i) {
      final n = min + i;
      return OiButtonGroupItem(label: '$n', enabled: enabled);
    });

    final selectedIndex = value != null ? value! - min : null;

    Widget group = OiButtonGroup(
      items: items,
      exclusive: true,
      selectedIndex: selectedIndex,
      onSelect: enabled ? (i) => onChanged?.call(min + i) : null,
      size: OiButtonSize.small,
    );

    if (minLabel != null || maxLabel != null) {
      group = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          group,
          const SizedBox(height: 4),
          Row(
            children: [
              if (minLabel != null)
                Text(
                  minLabel!,
                  style: textTheme.tiny.copyWith(color: colors.textMuted),
                ),
              const Spacer(),
              if (maxLabel != null)
                Text(
                  maxLabel!,
                  style: textTheme.tiny.copyWith(color: colors.textMuted),
                ),
            ],
          ),
        ],
      );
    }

    final semanticLabel =
        label ?? 'Scale rating, selected: ${value ?? 'none'} of $max';

    return Semantics(label: semanticLabel, child: group);
  }
}
