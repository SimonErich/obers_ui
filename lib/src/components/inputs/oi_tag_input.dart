import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/_internal/oi_input_frame.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/animation/oi_shimmer.dart';
import 'package:obers_ui/src/primitives/interaction/oi_tappable.dart';
import 'package:obers_ui/src/primitives/overlay/oi_floating.dart';

/// A tag/chip input that lets users add and remove string tags.
///
/// Existing [tags] are shown as removable chips inside the frame. A text
/// field at the end of the chip list lets users type new tags and confirm them
/// by pressing Enter or typing a comma. [maxTags] optionally limits how many
/// tags may be entered.
///
/// When [suggestions] or [asyncSuggestions] is provided, a dropdown popover
/// appears as the user types, showing matching items. Selecting a suggestion
/// adds it as a tag chip. When [allowCustomTags] is false, only items from
/// suggestions are accepted.
///
/// {@category Components}
class OiTagInput extends StatefulWidget {
  /// Creates an [OiTagInput].
  const OiTagInput({
    required this.tags,
    this.onChanged,
    this.label,
    this.hint,
    this.error,
    this.placeholder,
    this.enabled = true,
    this.maxTags,
    this.suggestions,
    this.asyncSuggestions,
    this.suggestionDebounce = const Duration(milliseconds: 300),
    this.allowCustomTags = true,
    super.key,
  });

  /// The current list of tags.
  final List<String> tags;

  /// Called with the updated list when a tag is added or removed.
  final ValueChanged<List<String>>? onChanged;

  /// Optional label rendered above the frame.
  final String? label;

  /// Optional hint rendered below the frame.
  final String? hint;

  /// Validation error message.
  final String? error;

  /// Placeholder shown inside the text field when no text has been typed.
  final String? placeholder;

  /// Whether the field accepts interaction.
  final bool enabled;

  /// Maximum number of tags allowed. Unlimited when null.
  final int? maxTags;

  /// Static list of suggestions to filter from as the user types.
  final List<String>? suggestions;

  /// Async callback to fetch suggestions based on the user's query.
  ///
  /// When both [suggestions] and [asyncSuggestions] are provided,
  /// [asyncSuggestions] takes priority while [suggestions] is used for
  /// immediate filtering.
  final Future<List<String>> Function(String query)? asyncSuggestions;

  /// Debounce delay before firing [asyncSuggestions]. Defaults to 300ms.
  final Duration suggestionDebounce;

  /// Whether the user can enter tags not present in [suggestions].
  ///
  /// When `false`, only items from [suggestions] or [asyncSuggestions] are
  /// accepted. Defaults to `true`.
  final bool allowCustomTags;

  /// Whether autocomplete suggestions are configured.
  bool get _hasSuggestions => suggestions != null || asyncSuggestions != null;

  @override
  State<OiTagInput> createState() => _OiTagInputState();
}

class _OiTagInputState extends State<OiTagInput> {
  late TextEditingController _ctrl;
  late FocusNode _focusNode;
  bool _focused = false;

  // Suggestion state
  List<String> _filteredSuggestions = const [];
  bool _suggestionsLoading = false;
  bool _showSuggestions = false;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController();
    _ctrl.addListener(_onTextChanged);
    _focusNode = FocusNode()..addListener(_handleFocusChange);
  }

  @override
  void didUpdateWidget(OiTagInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.suggestions != widget.suggestions) {
      // Re-filter with current query when static suggestions change.
      if (_ctrl.text.isNotEmpty && widget._hasSuggestions) {
        _filteredSuggestions = _filterSuggestions(_ctrl.text);
      }
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _ctrl.removeListener(_onTextChanged);
    _focusNode
      ..removeListener(_handleFocusChange)
      ..dispose();
    _ctrl.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    final focused = _focusNode.hasFocus;
    if (focused != _focused) {
      setState(() {
        _focused = focused;
        if (!focused) _showSuggestions = false;
      });
    }
  }

  bool get _canAdd =>
      widget.maxTags == null || widget.tags.length < widget.maxTags!;

  // ── Suggestion handling ──────────────────────────────────────────────────

  void _onTextChanged() {
    if (!widget._hasSuggestions) return;
    final query = _ctrl.text;

    if (query.isEmpty) {
      _debounceTimer?.cancel();
      setState(() {
        _filteredSuggestions = const [];
        _showSuggestions = false;
        _suggestionsLoading = false;
      });
      return;
    }

    // Immediate: filter static suggestions.
    final staticFiltered = _filterSuggestions(query);
    setState(() {
      _filteredSuggestions = staticFiltered;
      _showSuggestions = true;
    });

    // Async: debounced fetch.
    if (widget.asyncSuggestions != null) {
      _fetchAsyncSuggestions(query);
    }
  }

  List<String> _filterSuggestions(String query) {
    final source = widget.suggestions ?? const [];
    final lowerQuery = query.toLowerCase();
    return source
        .where(
          (s) =>
              s.toLowerCase().contains(lowerQuery) &&
              !widget.tags.contains(s),
        )
        .toList();
  }

  void _fetchAsyncSuggestions(String query) {
    _debounceTimer?.cancel();
    setState(() => _suggestionsLoading = true);

    _debounceTimer = Timer(widget.suggestionDebounce, () async {
      if (!mounted) return;
      try {
        final results = await widget.asyncSuggestions!(query);
        if (!mounted) return;
        setState(() {
          _filteredSuggestions = results
              .where((s) => !widget.tags.contains(s))
              .toList();
          _suggestionsLoading = false;
        });
      } catch (_) {
        if (!mounted) return;
        setState(() => _suggestionsLoading = false);
      }
    });
  }

  void _selectSuggestion(String suggestion) {
    final newTags = List<String>.from(widget.tags);
    if (!newTags.contains(suggestion) && _canAdd) {
      newTags.add(suggestion);
      widget.onChanged?.call(newTags);
    }
    _ctrl.clear();
    setState(() {
      _showSuggestions = false;
      _filteredSuggestions = const [];
    });
    _focusNode.requestFocus();
  }

  void _addTag(String raw) {
    final parts = raw
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty);
    final newTags = List<String>.from(widget.tags);
    for (final tag in parts) {
      if (!newTags.contains(tag) && _canAdd) {
        if (!widget.allowCustomTags && !_isInSuggestions(tag)) continue;
        newTags.add(tag);
      }
    }
    if (newTags.length != widget.tags.length) {
      widget.onChanged?.call(newTags);
    }
    _ctrl.clear();
    setState(() {
      _showSuggestions = false;
      _filteredSuggestions = const [];
    });
  }

  /// Checks if [tag] is in the current static or async suggestion results.
  bool _isInSuggestions(String tag) {
    final source = widget.suggestions ?? const <String>[];
    if (source.any((s) => s.toLowerCase() == tag.toLowerCase())) return true;
    if (_filteredSuggestions.any(
      (s) => s.toLowerCase() == tag.toLowerCase(),
    )) {
      return true;
    }
    return false;
  }

  void _removeTag(int index) {
    final newTags = List<String>.from(widget.tags)..removeAt(index);
    widget.onChanged?.call(newTags);
  }

  // ── Build ────────────────────────────────────────────────────────────────

  Widget _buildChip(BuildContext context, String tag, int index) {
    final colors = context.colors;
    return Container(
      margin: const EdgeInsets.only(right: 6, top: 2, bottom: 2),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colors.primary.base.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            tag,
            style: TextStyle(
              fontSize: 12,
              color: colors.primary.base,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (widget.enabled) ...[
            const SizedBox(width: 4),
            OiTappable(
              onTap: () => _removeTag(index),
              child: Icon(
                const IconData(0xe5cd, fontFamily: 'MaterialIcons'),
                size: 14,
                color: colors.primary.base,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSuggestionsDropdown(BuildContext context) {
    final colors = context.colors;
    final items = _filteredSuggestions;

    return Container(
      constraints: const BoxConstraints(maxHeight: 200),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(color: colors.border),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: const Color(0x1A000000),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: _suggestionsLoading && items.isEmpty
          ? _buildShimmerPlaceholder()
          : items.isEmpty
              ? const SizedBox.shrink()
              : ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  itemCount: items.length + (_suggestionsLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == items.length) {
                      return _buildShimmerPlaceholder();
                    }
                    final suggestion = items[index];
                    return OiTappable(
                      key: ValueKey('suggestion_$suggestion'),
                      onTap: () => _selectSuggestion(suggestion),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        child: Text(
                          suggestion,
                          style: TextStyle(
                            fontSize: 13,
                            color: colors.text,
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildShimmerPlaceholder() {
    return Padding(
      key: const Key('oi_tag_input_shimmer'),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: OiShimmer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 120,
              height: 12,
              decoration: BoxDecoration(
                color: const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 6),
            Container(
              width: 80,
              height: 12,
              decoration: BoxDecoration(
                color: const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canAdd = _canAdd;
    final input = OiRawInputInline(
      controller: _ctrl,
      focusNode: _focusNode,
      placeholder: canAdd ? (widget.placeholder ?? 'Add tag…') : '',
      enabled: widget.enabled && canAdd,
      onSubmitted: _addTag,
      inputFormatters: [_CommaFormatter(onComma: _addTag)],
    );

    final chips = widget.tags.asMap().entries.map(
      (e) => _buildChip(context, e.value, e.key),
    );

    final content = Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        ...chips,
        SizedBox(width: 80, child: input),
      ],
    );

    final frame = OiInputFrame(
      label: widget.label,
      hint: widget.hint,
      error: widget.error,
      focused: _focused,
      enabled: widget.enabled,
      child: content,
    );

    if (!widget._hasSuggestions) return frame;

    return OiFloating(
      visible: _showSuggestions &&
          (_filteredSuggestions.isNotEmpty || _suggestionsLoading),
      alignment: OiFloatingAlignment.bottomStart,
      anchor: frame,
      child: _buildSuggestionsDropdown(context),
    );
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// A minimal inline raw-input that does not add leading/trailing Row wrappers.
class OiRawInputInline extends StatelessWidget {
  /// Creates an [OiRawInputInline].
  const OiRawInputInline({
    required this.controller,
    required this.focusNode,
    this.placeholder,
    this.enabled = true,
    this.onSubmitted,
    this.inputFormatters,
    super.key,
  });

  /// The controller managing the editable text.
  final TextEditingController controller;

  /// The focus node for this field.
  final FocusNode focusNode;

  /// Placeholder text shown when the field is empty.
  final String? placeholder;

  /// Whether the field accepts input.
  final bool enabled;

  /// Called when the user submits the field.
  final ValueChanged<String>? onSubmitted;

  /// Optional list of input formatters applied per keystroke.
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    return EditableText(
      controller: controller,
      focusNode: focusNode,
      style: const TextStyle(fontSize: 13),
      cursorColor: const Color(0xFF2563EB),
      backgroundCursorColor: const Color(0xFF000000),
      onSubmitted: onSubmitted,
      readOnly: !enabled,
      inputFormatters: inputFormatters,
      textInputAction: TextInputAction.done,
      selectionColor: const Color(0x332563EB),
    );
  }
}

/// Intercepts comma characters and fires [onComma] with the accumulated text.
class _CommaFormatter extends TextInputFormatter {
  _CommaFormatter({required this.onComma});
  final ValueChanged<String> onComma;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.contains(',')) {
      final parts = newValue.text.split(',');
      final last = parts.last;
      final toAdd = parts.sublist(0, parts.length - 1).join(',');
      if (toAdd.isNotEmpty) {
        // Fire after the current frame to avoid re-entrant formatting.
        Future.microtask(() => onComma(toAdd));
      }
      return newValue.copyWith(
        text: last,
        selection: TextSelection.collapsed(offset: last.length),
      );
    }
    return newValue;
  }
}
