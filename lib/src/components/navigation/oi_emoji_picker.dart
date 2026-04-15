import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/interaction/oi_tappable.dart';
import 'package:unicode_emojis/unicode_emojis.dart';

part 'oi_emoji_picker_data.part.dart';
part 'oi_emoji_picker_grid.part.dart';

// ── Widget ─────────────────────────────────────────────────────────────────

/// A categorized emoji picker grid with optional search.
///
/// Displays emoji grouped by category. When [showSearch] is `true` a text
/// input is rendered at the top; typing filters emoji across all categories
/// by Unicode emoji metadata keywords and emoji characters.
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
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void dispose() {
    _searchFocusNode.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  List<_EmojiCategory> get _filtered {
    final query = _query.trim();
    if (query.isEmpty) return _kCategories;
    final metadataMatches = UnicodeEmojis.search(
      query,
    ).map((entry) => entry.emoji).toSet();
    final normalizedQuery = query.toLowerCase();
    return _kCategories
        .map((cat) {
          if (cat.name.toLowerCase().contains(normalizedQuery)) {
            return cat;
          }
          final matches = cat.emojis
              .where(
                (emoji) =>
                    emoji.contains(query) || metadataMatches.contains(emoji),
              )
              .toList();
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  child: EditableText(
                    controller: _searchCtrl,
                    focusNode: _searchFocusNode,
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
