import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/_internal/oi_input_frame.dart';
import 'package:obers_ui/src/foundation/theme/oi_text_theme.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';

/// A pattern recognizer for the smart input.
///
/// Each recognizer defines a [trigger] character, a [pattern] to match,
/// and a [style] to apply to matched spans. When [showSuggestions] is `true`
/// a suggestion popup is displayed after the user types the [trigger].
///
/// {@category Composites}
class OiPatternRecognizer {
  /// Creates an [OiPatternRecognizer].
  const OiPatternRecognizer({
    required this.trigger,
    required this.pattern,
    required this.style,
    this.showSuggestions = false,
  });

  /// The trigger character (e.g., "@", "#", ":").
  final String trigger;

  /// The regex pattern to match.
  final RegExp pattern;

  /// The text style to apply to matched spans.
  final TextStyle style;

  /// Whether to show a suggestion popup when the trigger is typed.
  final bool showSuggestions;
}

/// A suggestion item for the smart input.
///
/// Used by [OiSmartInput.onSuggestionQuery] to provide completion candidates
/// when a recognizer trigger is detected.
///
/// {@category Composites}
class OiSuggestion {
  /// Creates an [OiSuggestion].
  const OiSuggestion({required this.value, required this.label, this.leading});

  /// The value to insert when this suggestion is selected.
  final String value;

  /// The display label shown in the suggestion list.
  final String label;

  /// An optional leading widget (e.g., avatar or icon).
  final Widget? leading;
}

/// A recognized span in the smart input.
///
/// Represents a portion of text that matched a [OiPatternRecognizer],
/// including its [trigger], matched [value], and [range] within the text.
///
/// {@category Composites}
class OiRecognizedSpan {
  /// Creates an [OiRecognizedSpan].
  const OiRecognizedSpan({
    required this.trigger,
    required this.value,
    required this.range,
  });

  /// The trigger character that started this span.
  final String trigger;

  /// The matched value text.
  final String value;

  /// The text range of this span within the input text.
  final TextRange range;
}

/// A text input that recognizes patterns and renders them inline.
///
/// Recognizes @mentions, #tags, :emoji:, dates, URLs, phone numbers,
/// emails, etc. Each pattern gets distinct styling and can be tapped
/// for actions.
///
/// Provide a list of [recognizers] to define the patterns to detect and
/// their visual styling. Use [onSuggestionQuery] to supply suggestion
/// candidates when a trigger character is typed. Use [onSpanTap] to
/// respond when the user taps on a recognized span.
///
/// {@category Composites}
class OiSmartInput extends StatefulWidget {
  /// Creates an [OiSmartInput].
  const OiSmartInput({
    required this.label,
    super.key,
    this.value,
    this.onChange,
    this.recognizers = const [],
    this.onSuggestionQuery,
    this.onSpanTap,
    this.placeholder,
    this.maxLines = 1,
    this.enabled = true,
    this.hint,
    this.error,
    this.controller,
    this.focusNode,
  });

  /// The label displayed above the input frame.
  final String label;

  /// The initial text value. Ignored when [controller] is provided.
  final String? value;

  /// Called when the text value changes.
  final ValueChanged<String>? onChange;

  /// The list of pattern recognizers to apply to the input text.
  final List<OiPatternRecognizer> recognizers;

  /// Called to fetch suggestions when a recognizer trigger is typed.
  ///
  /// Receives the trigger character and the current query text after the
  /// trigger. Returns a future that resolves to a list of suggestions.
  final Future<List<OiSuggestion>> Function(String trigger, String query)?
  onSuggestionQuery;

  /// Called when the user taps on a recognized span.
  final ValueChanged<OiRecognizedSpan>? onSpanTap;

  /// Placeholder text shown inside the field when it is empty.
  final String? placeholder;

  /// Maximum number of lines for the input.
  final int maxLines;

  /// Whether the field accepts user input.
  final bool enabled;

  /// Optional hint text rendered below the input frame.
  final String? hint;

  /// Validation error message. When non-null the error border is shown.
  final String? error;

  /// An optional external controller. When null one is created internally.
  final TextEditingController? controller;

  /// An optional external focus node. When null one is created internally.
  final FocusNode? focusNode;

  @override
  State<OiSmartInput> createState() => _OiSmartInputState();
}

class _OiSmartInputState extends State<OiSmartInput> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _ownsController = false;
  bool _ownsFocusNode = false;
  bool _focused = false;

  // ── Suggestion overlay state ──────────────────────────────────────────────

  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  String? _activeTrigger;
  String _suggestionQuery = '';
  List<OiSuggestion> _suggestions = const [];
  int _selectedSuggestionIndex = 0;
  bool _loadingSuggestions = false;
  int _suggestionQueryVersion = 0;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _controller = TextEditingController(text: widget.value);
      _ownsController = true;
    } else {
      _controller = widget.controller!;
    }
    if (widget.focusNode == null) {
      _focusNode = FocusNode();
      _ownsFocusNode = true;
    } else {
      _focusNode = widget.focusNode!;
    }
    _focusNode.addListener(_handleFocusChange);
    _controller.addListener(_handleTextChange);
  }

  @override
  void didUpdateWidget(OiSmartInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      _controller.removeListener(_handleTextChange);
      if (_ownsController) {
        _controller.dispose();
      }
      if (widget.controller == null) {
        _controller = TextEditingController(text: widget.value);
        _ownsController = true;
      } else {
        _controller = widget.controller!;
        _ownsController = false;
      }
      _controller.addListener(_handleTextChange);
    }
    if (oldWidget.focusNode != widget.focusNode) {
      _focusNode.removeListener(_handleFocusChange);
      if (_ownsFocusNode) {
        _focusNode.dispose();
      }
      if (widget.focusNode == null) {
        _focusNode = FocusNode();
        _ownsFocusNode = true;
      } else {
        _focusNode = widget.focusNode!;
        _ownsFocusNode = false;
      }
      _focusNode.addListener(_handleFocusChange);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_handleTextChange);
    _focusNode.removeListener(_handleFocusChange);
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (_ownsController) _controller.dispose();
    if (_ownsFocusNode) _focusNode.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    final focused = _focusNode.hasFocus;
    if (focused != _focused) {
      setState(() => _focused = focused);
    }
    if (!focused) {
      _hideSuggestions();
    }
  }

  void _handleTextChange() {
    setState(() {});
    widget.onChange?.call(_controller.text);
    _checkForTrigger();
  }

  // ── Pattern matching ───────────────────────────────────────────────────────

  /// Builds a list of [TextSpan]s from the current text, applying recognizer
  /// styles to matched portions.
  List<InlineSpan> _buildTextSpans(String text, TextStyle baseStyle) {
    if (widget.recognizers.isEmpty || text.isEmpty) {
      return [TextSpan(text: text, style: baseStyle)];
    }

    // Collect all matches with their recognizer styles.
    final matches = <_MatchEntry>[];
    for (final recognizer in widget.recognizers) {
      for (final match in recognizer.pattern.allMatches(text)) {
        matches.add(
          _MatchEntry(
            start: match.start,
            end: match.end,
            style: recognizer.style,
            trigger: recognizer.trigger,
            value: match.group(0) ?? '',
          ),
        );
      }
    }

    if (matches.isEmpty) {
      return [TextSpan(text: text, style: baseStyle)];
    }

    // Sort by start position; on tie, longer match first.
    matches.sort((a, b) {
      final cmp = a.start.compareTo(b.start);
      if (cmp != 0) return cmp;
      return b.end.compareTo(a.end);
    });

    // Remove overlapping matches (keep the earliest / longest).
    final filtered = <_MatchEntry>[];
    var lastEnd = 0;
    for (final m in matches) {
      if (m.start >= lastEnd) {
        filtered.add(m);
        lastEnd = m.end;
      }
    }

    // Build spans.
    final spans = <InlineSpan>[];
    var cursor = 0;
    for (final m in filtered) {
      if (m.start > cursor) {
        spans.add(
          TextSpan(text: text.substring(cursor, m.start), style: baseStyle),
        );
      }

      final span = OiRecognizedSpan(
        trigger: m.trigger,
        value: m.value,
        range: TextRange(start: m.start, end: m.end),
      );

      spans.add(
        WidgetSpan(
          alignment: PlaceholderAlignment.baseline,
          baseline: TextBaseline.alphabetic,
          child: GestureDetector(
            onTap: widget.onSpanTap != null
                ? () => widget.onSpanTap!(span)
                : null,
            child: Text(m.value, style: baseStyle.merge(m.style)),
          ),
        ),
      );
      cursor = m.end;
    }
    if (cursor < text.length) {
      spans.add(TextSpan(text: text.substring(cursor), style: baseStyle));
    }
    return spans;
  }

  // ── Suggestion popup ───────────────────────────────────────────────────────

  /// Checks whether the cursor is positioned after a trigger character and
  /// initiates a suggestion query if so.
  void _checkForTrigger() {
    if (widget.onSuggestionQuery == null || widget.recognizers.isEmpty) {
      return;
    }

    final text = _controller.text;
    final cursorOffset = _controller.selection.baseOffset;
    if (cursorOffset <= 0) {
      _hideSuggestions();
      return;
    }

    final textBeforeCursor = text.substring(0, cursorOffset);

    for (final recognizer in widget.recognizers) {
      if (!recognizer.showSuggestions) continue;

      final trigger = recognizer.trigger;
      final lastTriggerIdx = textBeforeCursor.lastIndexOf(trigger);
      if (lastTriggerIdx < 0) continue;

      // Trigger must be at start of text or preceded by whitespace.
      if (lastTriggerIdx > 0) {
        final charBefore = textBeforeCursor[lastTriggerIdx - 1];
        if (charBefore != ' ' && charBefore != '\n' && charBefore != '\t') {
          continue;
        }
      }

      // No whitespace between trigger and cursor.
      final query =
          textBeforeCursor.substring(lastTriggerIdx + trigger.length);
      if (query.contains(' ') || query.contains('\n')) continue;

      // Active trigger found.
      if (trigger != _activeTrigger || query != _suggestionQuery) {
        _activeTrigger = trigger;
        _suggestionQuery = query;
        _selectedSuggestionIndex = 0;
        _loadSuggestions(trigger, query);
      }
      return;
    }

    _hideSuggestions();
  }

  Future<void> _loadSuggestions(String trigger, String query) async {
    if (!mounted || widget.onSuggestionQuery == null) return;
    _suggestionQueryVersion++;
    final version = _suggestionQueryVersion;

    setState(() => _loadingSuggestions = true);

    final results = await widget.onSuggestionQuery!(trigger, query);

    if (!mounted || version != _suggestionQueryVersion) return;

    setState(() {
      _suggestions = results;
      _loadingSuggestions = false;
      _selectedSuggestionIndex = 0;
    });

    if (results.isNotEmpty) {
      _showSuggestionsOverlay();
    } else {
      _hideSuggestions();
    }
  }

  void _showSuggestionsOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (_suggestions.isEmpty) return;

    _overlayEntry = OverlayEntry(builder: (_) => _buildOverlayContent());
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hideSuggestions() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _activeTrigger = null;
    _suggestions = const [];
    _selectedSuggestionIndex = 0;
    _loadingSuggestions = false;
    _suggestionQueryVersion++;
  }

  void _selectSuggestion(OiSuggestion suggestion) {
    if (_activeTrigger == null) return;

    final text = _controller.text;
    final cursorOffset = _controller.selection.baseOffset;
    if (cursorOffset < 0) return;

    final textBeforeCursor = text.substring(0, cursorOffset);
    final trigger = _activeTrigger!;
    final triggerLen = trigger.length;

    // Find the trigger position (last occurrence before cursor at word boundary).
    int triggerIdx = -1;
    for (var i = textBeforeCursor.length - triggerLen; i >= 0; i--) {
      if (textBeforeCursor.substring(i, i + triggerLen) == trigger) {
        if (i == 0 ||
            textBeforeCursor[i - 1] == ' ' ||
            textBeforeCursor[i - 1] == '\n' ||
            textBeforeCursor[i - 1] == '\t') {
          triggerIdx = i;
          break;
        }
      }
    }

    if (triggerIdx < 0) {
      _hideSuggestions();
      return;
    }

    final newText =
        text.substring(0, triggerIdx) +
        suggestion.value +
        text.substring(cursorOffset);
    final newCursorPos = triggerIdx + suggestion.value.length;

    _controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newCursorPos),
    );

    _hideSuggestions();
    widget.onChange?.call(newText);
  }

  Widget _buildOverlayContent() {
    return Positioned(
      width: 260,
      child: CompositedTransformFollower(
        link: _layerLink,
        targetAnchor: Alignment.bottomLeft,
        followerAnchor: Alignment.topLeft,
        showWhenUnlinked: false,
        child: _OiSuggestionPopup(
          suggestions: _suggestions,
          selectedIndex: _selectedSuggestionIndex,
          onSelect: _selectSuggestion,
          isLoading: _loadingSuggestions,
        ),
      ),
    );
  }

  KeyEventResult _handleSuggestionKeyEvent(FocusNode node, KeyEvent event) {
    if (_suggestions.isEmpty || event is! KeyDownEvent) {
      return KeyEventResult.ignored;
    }

    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      setState(() {
        _selectedSuggestionIndex =
            (_selectedSuggestionIndex + 1) % _suggestions.length;
      });
      _overlayEntry?.markNeedsBuild();
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      setState(() {
        _selectedSuggestionIndex =
            (_selectedSuggestionIndex - 1 + _suggestions.length) %
            _suggestions.length;
      });
      _overlayEntry?.markNeedsBuild();
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.escape) {
      _hideSuggestions();
      if (mounted) setState(() {});
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final themeData = OiTheme.maybeOf(context);
    final baseStyle =
        themeData?.textTheme.styleFor(OiLabelVariant.body) ??
        const TextStyle(fontSize: 16, fontWeight: FontWeight.w400);
    final cursorColor =
        themeData?.colors.primary.base ?? const Color(0xFF000000);

    final text = _controller.text;
    final showPlaceholder = text.isEmpty && widget.placeholder != null;

    // The rich-text display overlay showing pattern-styled spans.
    // When onSpanTap is set, the overlay must NOT be IgnorePointer so that
    // GestureDetector widgets inside WidgetSpans can receive taps.
    Widget richOverlay;
    if (text.isNotEmpty && widget.recognizers.isNotEmpty) {
      final spans = _buildTextSpans(text, baseStyle);
      final richText = Text.rich(
        TextSpan(children: spans),
        maxLines: widget.maxLines == 1 ? 1 : null,
      );
      richOverlay = widget.onSpanTap != null
          ? richText
          : IgnorePointer(child: richText);
    } else {
      richOverlay = const SizedBox.shrink();
    }

    // The underlying editable text.
    final editableText = EditableText(
      controller: _controller,
      focusNode: _focusNode,
      style: widget.recognizers.isNotEmpty
          ? baseStyle.copyWith(color: const Color(0x00000000))
          : baseStyle,
      cursorColor: cursorColor,
      backgroundCursorColor: const Color(0xFF000000),
      maxLines: widget.maxLines,
      readOnly: !widget.enabled,
      onChanged: (_) {},
      selectionColor: cursorColor.withValues(alpha: 0.3),
    );

    // Stack the rich overlay on top of the invisible editable text so the
    // user sees styled text while typing into the actual field.
    Widget field;
    if (widget.recognizers.isNotEmpty) {
      field = Stack(
        children: [
          // Placeholder
          if (showPlaceholder)
            Positioned.fill(
              child: IgnorePointer(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    widget.placeholder!,
                    style: baseStyle.copyWith(
                      color: (baseStyle.color ?? const Color(0xFF000000))
                          .withValues(alpha: 0.45),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          editableText,
          Positioned.fill(child: richOverlay),
        ],
      );
    } else {
      // No recognizers — render as plain input with visible text.
      field = Stack(
        children: [
          if (showPlaceholder)
            Positioned.fill(
              child: IgnorePointer(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    widget.placeholder!,
                    style: baseStyle.copyWith(
                      color: (baseStyle.color ?? const Color(0xFF000000))
                          .withValues(alpha: 0.45),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          EditableText(
            controller: _controller,
            focusNode: _focusNode,
            style: baseStyle,
            cursorColor: cursorColor,
            backgroundCursorColor: const Color(0xFF000000),
            maxLines: widget.maxLines,
            readOnly: !widget.enabled,
            onChanged: (_) {},
            selectionColor: cursorColor.withValues(alpha: 0.3),
          ),
        ],
      );
    }

    return CompositedTransformTarget(
      link: _layerLink,
      child: Focus(
        onKeyEvent: _handleSuggestionKeyEvent,
        child: Semantics(
          label: widget.label,
          textField: true,
          enabled: widget.enabled,
          child: OiInputFrame(
            label: widget.label,
            hint: widget.hint,
            error: widget.error,
            focused: _focused,
            enabled: widget.enabled,
            child: field,
          ),
        ),
      ),
    );
  }
}

// ── Internal suggestion popup ─────────────────────────────────────────────────

class _OiSuggestionPopup extends StatelessWidget {
  const _OiSuggestionPopup({
    required this.suggestions,
    required this.selectedIndex,
    required this.onSelect,
    required this.isLoading,
  });

  final List<OiSuggestion> suggestions;
  final int selectedIndex;
  final ValueChanged<OiSuggestion> onSelect;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final decoration = BoxDecoration(
      color: const Color(0xFFFFFFFF),
      borderRadius: BorderRadius.circular(8),
      boxShadow: const [
        BoxShadow(
          color: Color(0x1F000000),
          blurRadius: 8,
          offset: Offset(0, 2),
        ),
      ],
    );

    if (isLoading) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: decoration,
        child: const Text(
          'Loading…',
          style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
        ),
      );
    }

    return Container(
      constraints: const BoxConstraints(maxHeight: 200),
      decoration: decoration,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < suggestions.length; i++)
                _OiSuggestionItem(
                  suggestion: suggestions[i],
                  isSelected: i == selectedIndex,
                  onTap: () => onSelect(suggestions[i]),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OiSuggestionItem extends StatelessWidget {
  const _OiSuggestionItem({
    required this.suggestion,
    required this.isSelected,
    required this.onTap,
  });

  final OiSuggestion suggestion;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        color: isSelected ? const Color(0xFFEFF6FF) : const Color(0x00000000),
        child: Row(
          children: [
            if (suggestion.leading != null) ...[
              suggestion.leading!,
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Text(
                suggestion.label,
                style: const TextStyle(fontSize: 14, color: Color(0xFF111827)),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Internal helpers ───────────────────────────────────────────────────────────

/// Internal helper to track a regex match with its recognizer style.
class _MatchEntry {
  const _MatchEntry({
    required this.start,
    required this.end,
    required this.style,
    required this.trigger,
    required this.value,
  });

  final int start;
  final int end;
  final TextStyle style;
  final String trigger;
  final String value;
}
