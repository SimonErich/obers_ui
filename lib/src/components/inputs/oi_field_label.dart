import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/theme/oi_text_theme.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/display/oi_label.dart';

/// Shared field heading with an optional semantic marker from its input theme.
/// The marker changes presentation only; the owning form supplies its state.
class OiFieldLabel extends StatelessWidget {
  /// Creates a heading that retains the input's independent accessible name.
  const OiFieldLabel(
    this.label, {
    this.style,
    this.excludeLabelSemantics = true,
    super.key,
  });

  /// Visible field name.
  final String label;

  /// Typography override, otherwise following the text-input label theme.
  final TextStyle? style;

  /// Whether the input already exposes the same accessible field name.
  final bool excludeLabelSemantics;

  @override
  Widget build(BuildContext context) {
    final theme = context.components.textInput;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: ExcludeSemantics(
            excluding: excludeLabelSemantics,
            child: OiLabel.variant(
              label,
              variant: OiLabelVariant.smallStrong,
              style: style ?? theme?.labelStyle,
            ),
          ),
        ),
        if (theme?.labelMarkerColor case final color?) ...[
          const SizedBox(width: 6),
          Semantics(
            label: '$label: ${theme?.labelMarkerDescription ?? 'Modified'}',
            child: SizedBox.square(
              dimension: 6,
              child: DecoratedBox(
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
