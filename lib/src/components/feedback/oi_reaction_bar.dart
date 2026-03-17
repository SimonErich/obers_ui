import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/interaction/oi_tappable.dart';
import 'package:obers_ui/src/primitives/overlay/oi_floating.dart';

/// Data for a single emoji reaction chip.
///
/// {@category Components}
@immutable
class OiReactionData {
  /// Creates an [OiReactionData].
  const OiReactionData({
    required this.emoji,
    required this.count,
    this.selected = false,
  });

  /// The emoji character for this reaction.
  final String emoji;

  /// The number of users who reacted with this emoji.
  final int count;

  /// Whether the current user has selected this reaction.
  final bool selected;
}

/// A row of emoji reaction chips with counts, plus an "Add reaction" button.
///
/// Each chip shows an [OiReactionData.emoji] and its [OiReactionData.count].
/// Selected chips are highlighted. Tapping a chip calls [onReact] with the
/// chip's emoji. Tapping the add button shows a small emoji picker popover;
/// selecting an emoji from it also calls [onReact].
///
/// {@category Components}
class OiReactionBar extends StatefulWidget {
  /// Creates an [OiReactionBar].
  const OiReactionBar({
    required this.reactions,
    this.onReact,
    this.onAddReaction,
    super.key,
  });

  /// The list of reactions to display.
  final List<OiReactionData> reactions;

  /// Called with the emoji string when the user taps a reaction chip or
  /// selects an emoji from the picker.
  final void Function(String emoji)? onReact;

  /// Called when the "add reaction" button is tapped (before the picker
  /// opens). Can be used to handle the add action externally.
  final VoidCallback? onAddReaction;

  @override
  State<OiReactionBar> createState() => _OiReactionBarState();
}

class _OiReactionBarState extends State<OiReactionBar> {
  bool _pickerOpen = false;

  // Emoji set shown in the quick picker popover.
  static const _quickEmojis = [
    '👍', '❤️', '😂', '😮', '😢', '😡',
    '🎉', '🔥', '👏', '🙌', '💯', '✨',
  ];

  void _togglePicker() {
    setState(() => _pickerOpen = !_pickerOpen);
    if (!_pickerOpen) widget.onAddReaction?.call();
  }

  void _pickEmoji(String emoji) {
    setState(() => _pickerOpen = false);
    widget.onReact?.call(emoji);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = context.textTheme;

    Widget chip(OiReactionData r) {
      final bg = r.selected ? colors.primary.muted : colors.surfaceSubtle;
      final border = r.selected ? colors.primary.base : colors.borderSubtle;

      return OiTappable(
        onTap: () => widget.onReact?.call(r.emoji),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(r.emoji, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 4),
              Text(
                '${r.count}',
                style: textTheme.small.copyWith(
                  color: r.selected
                      ? colors.primary.base
                      : colors.textSubtle,
                  fontWeight: r.selected
                      ? FontWeight.w700
                      : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final pickerGrid = Container(
      width: 160,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.border),
        boxShadow: [
          BoxShadow(
            color: colors.overlay.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Wrap(
        spacing: 4,
        runSpacing: 4,
        children: _quickEmojis
            .map(
              (e) => OiTappable(
                onTap: () => _pickEmoji(e),
                child: SizedBox(
                  width: 32,
                  height: 32,
                  child: Center(
                    child: Text(e, style: const TextStyle(fontSize: 18)),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );

    final addButton = OiFloating(
      alignment: OiFloatingAlignment.topEnd,
      visible: _pickerOpen,
      anchor: OiTappable(
        onTap: _togglePicker,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: colors.surfaceSubtle,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colors.borderSubtle),
          ),
          child: Text(
            '+ Add',
            style: textTheme.small.copyWith(color: colors.textMuted),
          ),
        ),
      ),
      child: _pickerOpen
          ? Stack(
              children: [
                Positioned.fill(
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () => setState(() => _pickerOpen = false),
                    child: const SizedBox.expand(),
                  ),
                ),
                pickerGrid,
              ],
            )
          : const SizedBox.shrink(),
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...widget.reactions.map(chip),
        if (widget.reactions.isNotEmpty) const SizedBox(width: 4),
        addButton,
      ],
    );
  }
}
