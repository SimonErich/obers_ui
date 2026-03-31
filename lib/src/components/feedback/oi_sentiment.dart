import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/interaction/oi_tappable.dart';

/// The default set of sentiment emojis used by [OiSentiment].
const List<String> _kDefaultEmojis = ['😡', '😕', '😐', '🙂', '😄'];

/// An emoji-based sentiment picker widget.
///
/// Renders a row of emoji buttons. The selected emoji (matching [value]) is
/// visually highlighted with a primary-colored border and background. Tapping
/// an emoji calls [onChanged] with that emoji string. When [enabled] is
/// `false`, taps are ignored. [emojis] overrides the default emoji set
/// `['😡', '😕', '😐', '🙂', '😄']`.
///
/// {@category Components}
class OiSentiment extends StatelessWidget {
  /// Creates an [OiSentiment] widget.
  const OiSentiment({
    this.value,
    this.onChanged,
    this.emojis,
    this.enabled = true,
    super.key,
  });

  /// The currently selected emoji string, or null if none is selected.
  final String? value;

  /// Called when the user taps an emoji button.
  final ValueChanged<String>? onChanged;

  /// The emoji options to display. Defaults to `['😡', '😕', '😐', '🙂', '😄']`.
  final List<String>? emojis;

  /// Whether the widget is interactive. Defaults to `true`.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final items = emojis ?? _kDefaultEmojis;

    Widget emojiButton(String emoji) {
      final selected = value == emoji;
      final bg = selected ? colors.primary.muted : colors.surface;
      final border = selected ? colors.primary.base : colors.border;

      return Semantics(
        button: true,
        label: emoji,
        selected: selected,
        child: OiTappable(
          enabled: enabled,
          onTap: () => onChanged?.call(emoji),
          clipBorderRadius: BorderRadius.circular(8),
          child: AnimatedContainer(
            duration:
                context.animations.reducedMotion ||
                    MediaQuery.disableAnimationsOf(context)
                ? Duration.zero
                : const Duration(milliseconds: 150),
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: border, width: selected ? 2 : 1),
            ),
            child: Text(emoji, style: const TextStyle(fontSize: 24)),
          ),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          emojiButton(items[i]),
        ],
      ],
    );
  }
}
