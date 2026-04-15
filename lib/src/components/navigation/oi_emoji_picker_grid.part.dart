part of 'oi_emoji_picker.dart';

// ── Emoji grid ─────────────────────────────────────────────────────────────

class _EmojiGrid extends StatelessWidget {
  const _EmojiGrid({required this.emojis, required this.onSelected});

  final List<String> emojis;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: emojis.map((emoji) {
        return OiTappable(
          semanticLabel: 'emoji $emoji',
          onTap: () => onSelected(emoji),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Text(emoji, style: const TextStyle(fontSize: 24)),
          ),
        );
      }).toList(),
    );
  }
}
