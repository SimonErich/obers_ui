import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/interaction/oi_tappable.dart';

// ── Emoji data ─────────────────────────────────────────────────────────────

class _EmojiCategory {
  const _EmojiCategory(this.name, this.emojis);
  final String name;
  final List<String> emojis;
}

const List<_EmojiCategory> _kCategories = [
  _EmojiCategory('Smileys', [
    '😀',
    '😃',
    '😄',
    '😁',
    '😆',
    '😅',
    '😂',
    '🤣',
    '😊',
    '😇',
    '🙂',
    '🙃',
    '😉',
    '😌',
    '😍',
    '🥰',
    '😘',
    '😗',
    '😙',
    '😚',
    '😋',
    '😛',
    '😝',
    '😜',
    '🤪',
    '🤨',
    '🧐',
    '🤓',
    '😎',
    '🥸',
    '🤩',
    '🥳',
    '😏',
    '😒',
    '😞',
    '😔',
    '😟',
    '😕',
    '🙁',
    '☹️',
    '😣',
    '😖',
    '😫',
    '😩',
    '🥺',
    '😢',
    '😭',
    '😤',
    '😠',
    '😡',
  ]),
  _EmojiCategory('People', [
    '👋',
    '🤚',
    '🖐️',
    '✋',
    '🖖',
    '👌',
    '🤌',
    '🤏',
    '✌️',
    '🤞',
    '🤟',
    '🤘',
    '🤙',
    '👈',
    '👉',
    '👆',
    '🖕',
    '👇',
    '☝️',
    '👍',
    '👎',
    '✊',
    '👊',
    '🤛',
    '🤜',
    '👏',
    '🙌',
    '🤲',
    '🤝',
    '🙏',
    '💅',
    '🤳',
    '💪',
    '🦾',
    '🦿',
    '🦵',
    '🦶',
    '👂',
    '🦻',
    '👃',
    '🫀',
    '🫁',
    '🧠',
    '🦷',
    '🦴',
    '👀',
    '👁️',
    '👅',
    '👄',
    '🫦',
  ]),
  _EmojiCategory('Animals', [
    '🐶',
    '🐱',
    '🐭',
    '🐹',
    '🐰',
    '🦊',
    '🐻',
    '🐼',
    '🐻‍❄️',
    '🐨',
    '🐯',
    '🦁',
    '🐮',
    '🐷',
    '🐸',
    '🐵',
    '🙈',
    '🙉',
    '🙊',
    '🐒',
    '🐔',
    '🐧',
    '🐦',
    '🐤',
    '🦆',
    '🦅',
    '🦉',
    '🦇',
    '🐺',
    '🐗',
    '🐴',
    '🦄',
    '🐝',
    '🐛',
    '🦋',
    '🐌',
    '🐞',
    '🐜',
    '🦟',
    '🦗',
    '🐢',
    '🐍',
    '🦎',
    '🦖',
    '🦕',
    '🐙',
    '🦑',
    '🦐',
    '🦀',
    '🐡',
  ]),
  _EmojiCategory('Food', [
    '🍎',
    '🍊',
    '🍋',
    '🍇',
    '🍓',
    '🍒',
    '🍑',
    '🥭',
    '🍍',
    '🥥',
    '🥝',
    '🍅',
    '🥦',
    '🥬',
    '🥒',
    '🌶️',
    '🧅',
    '🧄',
    '🥔',
    '🌽',
    '🍕',
    '🍔',
    '🍟',
    '🌭',
    '🍿',
    '🧂',
    '🥓',
    '🥚',
    '🍳',
    '🧇',
    '🥞',
    '🧈',
    '🍞',
    '🥐',
    '🥨',
    '🥯',
    '🧀',
    '🍖',
    '🍗',
    '🥩',
    '🍣',
    '🍱',
    '🍛',
    '🍜',
    '🍝',
    '🍲',
    '🥘',
    '🫕',
    '🥗',
    '🍿',
  ]),
  _EmojiCategory('Activities', [
    '⚽',
    '🏀',
    '🏈',
    '⚾',
    '🥎',
    '🎾',
    '🏐',
    '🏉',
    '🥏',
    '🎱',
    '🏓',
    '🏸',
    '🏒',
    '🏑',
    '🥍',
    '🏏',
    '🪃',
    '🥅',
    '⛳',
    '🪁',
    '🎣',
    '🤿',
    '🎽',
    '🎿',
    '🛷',
    '🥌',
    '🎯',
    '🪀',
    '🪄',
    '🎮',
    '🎰',
    '🎲',
    '🧩',
    '🪅',
    '🎭',
    '🎨',
    '🎬',
    '🎤',
    '🎧',
    '🎼',
    '🎵',
    '🎶',
    '🎸',
    '🪕',
    '🎹',
    '🥁',
    '🪘',
    '🎷',
    '🎺',
    '🎻',
  ]),
  _EmojiCategory('Travel', [
    '🚗',
    '🚕',
    '🚙',
    '🚌',
    '🚎',
    '🏎️',
    '🚓',
    '🚑',
    '🚒',
    '🚐',
    '🛻',
    '🚚',
    '🚛',
    '🚜',
    '🏍️',
    '🛵',
    '🛺',
    '🚲',
    '🛴',
    '🛹',
    '🚁',
    '🛸',
    '✈️',
    '🚀',
    '🛶',
    '⛵',
    '🚤',
    '🛥️',
    '🚢',
    '⚓',
    '🗺️',
    '🧭',
    '🏔️',
    '⛰️',
    '🌋',
    '🗻',
    '🏕️',
    '🏖️',
    '🏜️',
    '🏝️',
    '🏟️',
    '🏛️',
    '🏗️',
    '🧱',
    '🏘️',
    '🏚️',
    '🏠',
    '🏡',
    '🏢',
    '🏣',
  ]),
  _EmojiCategory('Objects', [
    '⌚',
    '📱',
    '💻',
    '⌨️',
    '🖥️',
    '🖨️',
    '🖱️',
    '🖲️',
    '💾',
    '💿',
    '📷',
    '📸',
    '📹',
    '🎥',
    '📞',
    '☎️',
    '📟',
    '📠',
    '📺',
    '📻',
    '🎙️',
    '🎚️',
    '🎛️',
    '🧭',
    '⏱️',
    '⏲️',
    '⏰',
    '🕰️',
    '⌛',
    '⏳',
    '📡',
    '🔋',
    '🪫',
    '🔌',
    '💡',
    '🔦',
    '🕯️',
    '🪔',
    '🧯',
    '🛢️',
    '💰',
    '💴',
    '💵',
    '💶',
    '💷',
    '💸',
    '💳',
    '🪙',
    '💎',
    '⚖️',
  ]),
  _EmojiCategory('Symbols', [
    '❤️',
    '🧡',
    '💛',
    '💚',
    '💙',
    '💜',
    '🖤',
    '🤍',
    '🤎',
    '💔',
    '❣️',
    '💕',
    '💞',
    '💓',
    '💗',
    '💖',
    '💘',
    '💝',
    '💟',
    '☮️',
    '✝️',
    '☪️',
    '🕉️',
    '☸️',
    '✡️',
    '🔯',
    '🕎',
    '☯️',
    '☦️',
    '🛐',
    '⛎',
    '♈',
    '♉',
    '♊',
    '♋',
    '♌',
    '♍',
    '♎',
    '♏',
    '♐',
    '🔴',
    '🟠',
    '🟡',
    '🟢',
    '🔵',
    '🟣',
    '⚫',
    '⚪',
    '🟤',
    '🔶',
  ]),
];

// ── Widget ─────────────────────────────────────────────────────────────────

/// A categorised emoji picker grid with optional search.
///
/// Displays emoji grouped by category. When [showSearch] is `true` a text
/// input is rendered at the top; typing filters emoji across all categories
/// by a simple substring match on the emoji character itself.
///
/// Tapping an emoji calls [onSelected] with the emoji string.
///
/// {@category Components}
class OiEmojiPicker extends StatefulWidget {
  /// Creates an [OiEmojiPicker].
  const OiEmojiPicker({
    required this.onSelected,
    this.showSearch = true,
    super.key,
  });

  /// Called when the user taps an emoji.
  final ValueChanged<String> onSelected;

  /// Whether to show the search input at the top of the picker.
  final bool showSearch;

  @override
  State<OiEmojiPicker> createState() => _OiEmojiPickerState();
}

class _OiEmojiPickerState extends State<OiEmojiPicker> {
  String _query = '';
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<_EmojiCategory> get _filtered {
    if (_query.isEmpty) return _kCategories;
    return _kCategories
        .map((cat) {
          final matches = cat.emojis.where((e) => e.contains(_query)).toList();
          return _EmojiCategory(cat.name, matches);
        })
        .where((cat) => cat.emojis.isNotEmpty)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final categories = _filtered;

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.showSearch)
            Padding(
              padding: const EdgeInsets.all(8),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.surfaceSubtle,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: colors.border),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: EditableText(
                    controller: _searchCtrl,
                    focusNode: FocusNode(),
                    onChanged: (v) => setState(() => _query = v),
                    style: TextStyle(fontSize: 14, color: colors.text),
                    cursorColor: colors.primary.base,
                    backgroundCursorColor: colors.primary.muted,
                  ),
                ),
              ),
            ),
          if (categories.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Text(
                  'No emoji found',
                  style: TextStyle(fontSize: 14, color: colors.textMuted),
                ),
              ),
            )
          else
            for (final cat in categories) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
                child: Text(
                  cat.name,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: colors.textMuted,
                  ),
                ),
              ),
              _EmojiGrid(emojis: cat.emojis, onSelected: widget.onSelected),
            ],
        ],
      ),
    );
  }
}

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
