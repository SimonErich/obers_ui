import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/_internal/oi_input_frame.dart';
import 'package:obers_ui/src/foundation/theme/oi_text_theme.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';

// ── Data models ──────────────────────────────────────────────────────────────

/// Block types in the rich editor.
///
/// Each value corresponds to a semantic content block that the editor
/// can render and produce.
///
/// {@category Composites}
enum OiBlockType {
  /// A plain paragraph block.
  paragraph,

  /// A top-level heading (H1).
  heading1,

  /// A second-level heading (H2).
  heading2,

  /// A third-level heading (H3).
  heading3,

  /// An unordered (bullet) list item.
  bulletList,

  /// An ordered (numbered) list item.
  numberedList,

  /// A code block.
  code,

  /// A block quote.
  quote,

  /// A horizontal divider.
  divider,
}

/// A block of content in the rich editor.
///
/// Each block has a [type] that determines its rendering, a [text] body,
/// optional [metadata] (e.g. `language` for code blocks), and optional
/// inline formatting flags ([isBold], [isItalic], [isUnderline]).
///
/// {@category Composites}
@immutable
class OiContentBlock {
  /// Creates an [OiContentBlock].
  const OiContentBlock({
    required this.type,
    required this.text,
    this.metadata,
    this.isBold = false,
    this.isItalic = false,
    this.isUnderline = false,
  });

  /// The type of block.
  final OiBlockType type;

  /// The text content of the block.
  final String text;

  /// Optional metadata such as `{"language": "dart"}` for code blocks.
  final Map<String, dynamic>? metadata;

  /// Whether the block text is rendered in bold.
  final bool isBold;

  /// Whether the block text is rendered in italic.
  final bool isItalic;

  /// Whether the block text is rendered with underline.
  final bool isUnderline;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OiContentBlock &&
        other.type == type &&
        other.text == text &&
        other.isBold == isBold &&
        other.isItalic == isItalic &&
        other.isUnderline == isUnderline &&
        _mapEquals(other.metadata, metadata);
  }

  @override
  int get hashCode =>
      Object.hash(type, text, isBold, isItalic, isUnderline, metadata?.length);
}

/// The content of the rich editor.
///
/// Holds a list of [OiContentBlock]s and provides serialisation helpers
/// ([toHtml], [toMarkdown], [toPlainText], [toDelta]) as well as a
/// [wordCount] getter.
///
/// {@category Composites}
@immutable
class OiRichContent {
  /// Creates an [OiRichContent] with the given [blocks].
  const OiRichContent({this.blocks = const []});

  /// Creates an [OiRichContent] from plain text.
  ///
  /// Splits on double newlines to produce paragraph blocks. Single newlines
  /// within a paragraph are preserved in the block text.
  factory OiRichContent.fromPlainText(String text) {
    if (text.isEmpty) return const OiRichContent();
    final paragraphs = text.split(RegExp(r'\n\n+'));
    return OiRichContent(
      blocks: paragraphs
          .map(
            (p) => OiContentBlock(type: OiBlockType.paragraph, text: p.trim()),
          )
          .where((b) => b.text.isNotEmpty)
          .toList(),
    );
  }

  /// Creates empty content with a single empty paragraph block.
  factory OiRichContent.empty() {
    return const OiRichContent(
      blocks: [OiContentBlock(type: OiBlockType.paragraph, text: '')],
    );
  }

  /// The content blocks.
  final List<OiContentBlock> blocks;

  /// Converts the content to an HTML string.
  String toHtml() {
    final buffer = StringBuffer();
    var inOrderedList = false;
    var inUnorderedList = false;

    for (var i = 0; i < blocks.length; i++) {
      final block = blocks[i];

      // Close lists when block type changes.
      if (block.type != OiBlockType.numberedList && inOrderedList) {
        buffer.write('</ol>');
        inOrderedList = false;
      }
      if (block.type != OiBlockType.bulletList && inUnorderedList) {
        buffer.write('</ul>');
        inUnorderedList = false;
      }

      switch (block.type) {
        case OiBlockType.paragraph:
          buffer.write('<p>${_escapeHtml(block.text)}</p>');
        case OiBlockType.heading1:
          buffer.write('<h1>${_escapeHtml(block.text)}</h1>');
        case OiBlockType.heading2:
          buffer.write('<h2>${_escapeHtml(block.text)}</h2>');
        case OiBlockType.heading3:
          buffer.write('<h3>${_escapeHtml(block.text)}</h3>');
        case OiBlockType.bulletList:
          if (!inUnorderedList) {
            buffer.write('<ul>');
            inUnorderedList = true;
          }
          buffer.write('<li>${_escapeHtml(block.text)}</li>');
        case OiBlockType.numberedList:
          if (!inOrderedList) {
            buffer.write('<ol>');
            inOrderedList = true;
          }
          buffer.write('<li>${_escapeHtml(block.text)}</li>');
        case OiBlockType.code:
          final lang = block.metadata?['language'] as String?;
          if (lang != null && lang.isNotEmpty) {
            buffer.write(
              '<pre><code class="language-$lang">'
              '${_escapeHtml(block.text)}'
              '</code></pre>',
            );
          } else {
            buffer.write('<pre><code>${_escapeHtml(block.text)}</code></pre>');
          }
        case OiBlockType.quote:
          buffer.write('<blockquote>${_escapeHtml(block.text)}</blockquote>');
        case OiBlockType.divider:
          buffer.write('<hr/>');
      }
    }

    // Close any open lists at the end.
    if (inOrderedList) buffer.write('</ol>');
    if (inUnorderedList) buffer.write('</ul>');

    return buffer.toString();
  }

  /// Converts the content to a Markdown string.
  String toMarkdown() {
    final buffer = StringBuffer();
    var numberedIndex = 0;
    OiBlockType? prevType;

    for (final block in blocks) {
      // Reset numbered index when leaving a numbered list.
      if (block.type != OiBlockType.numberedList &&
          prevType == OiBlockType.numberedList) {
        numberedIndex = 0;
      }

      if (prevType != null) buffer.writeln();

      switch (block.type) {
        case OiBlockType.paragraph:
          buffer.write(block.text);
        case OiBlockType.heading1:
          buffer.write('# ${block.text}');
        case OiBlockType.heading2:
          buffer.write('## ${block.text}');
        case OiBlockType.heading3:
          buffer.write('### ${block.text}');
        case OiBlockType.bulletList:
          buffer.write('- ${block.text}');
        case OiBlockType.numberedList:
          numberedIndex++;
          buffer.write('$numberedIndex. ${block.text}');
        case OiBlockType.code:
          final lang = block.metadata?['language'] as String? ?? '';
          buffer.write('```$lang\n${block.text}\n```');
        case OiBlockType.quote:
          buffer.write('> ${block.text}');
        case OiBlockType.divider:
          buffer.write('---');
      }

      prevType = block.type;
    }

    return buffer.toString();
  }

  /// Converts the content to plain text, stripping all formatting.
  String toPlainText() {
    return blocks
        .where((b) => b.type != OiBlockType.divider)
        .map((b) => b.text)
        .join('\n');
  }

  /// Converts the content to a Quill Delta map.
  ///
  /// Returns a map with an `"ops"` key containing a list of insert operations
  /// compatible with the Quill delta format.
  Map<String, dynamic> toDelta() {
    final ops = <Map<String, dynamic>>[];

    for (final block in blocks) {
      if (block.type == OiBlockType.divider) {
        // Represent divider as a thematic break operation.
        ops.add({'insert': {'divider': true}});
        ops.add({'insert': '\n'});
        continue;
      }

      // Build inline attributes for text formatting.
      final inlineAttrs = <String, dynamic>{};
      if (block.isBold) inlineAttrs['bold'] = true;
      if (block.isItalic) inlineAttrs['italic'] = true;
      if (block.isUnderline) inlineAttrs['underline'] = true;

      if (inlineAttrs.isEmpty) {
        ops.add({'insert': block.text});
      } else {
        ops.add({
          'insert': block.text,
          'attributes': Map<String, dynamic>.from(inlineAttrs),
        });
      }

      // Build line-level attributes for block type.
      final lineAttrs = <String, dynamic>{};
      switch (block.type) {
        case OiBlockType.heading1:
          lineAttrs['header'] = 1;
        case OiBlockType.heading2:
          lineAttrs['header'] = 2;
        case OiBlockType.heading3:
          lineAttrs['header'] = 3;
        case OiBlockType.bulletList:
          lineAttrs['list'] = 'bullet';
        case OiBlockType.numberedList:
          lineAttrs['list'] = 'ordered';
        case OiBlockType.code:
          lineAttrs['code-block'] = true;
        case OiBlockType.quote:
          lineAttrs['blockquote'] = true;
        case OiBlockType.paragraph:
        case OiBlockType.divider:
          break;
      }

      if (lineAttrs.isEmpty) {
        ops.add({'insert': '\n'});
      } else {
        ops.add({'insert': '\n', 'attributes': Map<String, dynamic>.from(lineAttrs)});
      }
    }

    return {'ops': ops};
  }

  /// Returns the total word count across all blocks.
  int get wordCount {
    var count = 0;
    for (final block in blocks) {
      if (block.text.trim().isEmpty) continue;
      count += block.text.trim().split(RegExp(r'\s+')).length;
    }
    return count;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! OiRichContent) return false;
    if (blocks.length != other.blocks.length) return false;
    for (var i = 0; i < blocks.length; i++) {
      if (blocks[i] != other.blocks[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hashAll(blocks);
}

// ── Controller ───────────────────────────────────────────────────────────────

/// Controller for the rich editor.
///
/// Manages the [OiRichContent] and notifies listeners when the content
/// changes. Provides convenience methods for inserting text and
/// serialising the content.
///
/// {@category Composites}
class OiRichEditorController extends ChangeNotifier {
  /// Creates an [OiRichEditorController] with optional [initialContent].
  OiRichEditorController({OiRichContent? initialContent})
    : _content = initialContent ?? OiRichContent.empty();

  OiRichContent _content;

  /// The current content.
  OiRichContent get content => _content;

  /// Sets the content and notifies listeners.
  set content(OiRichContent value) {
    _content = value;
    notifyListeners();
  }

  /// Inserts [text] at the end of the last block.
  ///
  /// If there are no blocks a new paragraph block is created.
  void insertText(String text) {
    final blocks = List<OiContentBlock>.from(_content.blocks);
    if (blocks.isEmpty) {
      blocks.add(OiContentBlock(type: OiBlockType.paragraph, text: text));
    } else {
      final last = blocks.last;
      blocks[blocks.length - 1] = OiContentBlock(
        type: last.type,
        text: last.text + text,
        metadata: last.metadata,
        isBold: last.isBold,
        isItalic: last.isItalic,
        isUnderline: last.isUnderline,
      );
    }
    _content = OiRichContent(blocks: blocks);
    notifyListeners();
  }

  /// Directly sets the content without triggering the setter's public
  /// notification path. Used internally by the editor state to update
  /// individual blocks without a redundant rebuild.
  void updateContentSilently(OiRichContent value) {
    _content = value;
    notifyListeners();
  }

  /// Gets the content as HTML.
  String toHtml() => _content.toHtml();

  /// Gets the content as Markdown.
  String toMarkdown() => _content.toMarkdown();

  /// Gets the content as plain text.
  String toPlainText() => _content.toPlainText();

  /// Gets the content as a Quill Delta map.
  Map<String, dynamic> toDelta() => _content.toDelta();

  /// Gets the word count.
  int get wordCount => _content.wordCount;
}

// ── Supporting types ─────────────────────────────────────────────────────────

/// Toolbar display mode for the rich editor.
///
/// {@category Composites}
enum OiToolbarMode {
  /// A toolbar that floats near the text selection.
  floating,

  /// A toolbar fixed at the top of the editor.
  fixed,

  /// A compact toolbar showing only essential actions.
  minimal,

  /// No toolbar is displayed.
  none,
}

/// A mention item for the rich editor.
///
/// Used by [OiRichEditor.mentionProvider] to return user matches.
///
/// {@category Composites}
class OiMention {
  /// Creates an [OiMention].
  const OiMention({required this.id, required this.label, this.avatarUrl});

  /// The unique identifier for this mention.
  final String id;

  /// The display label (e.g. username).
  final String label;

  /// An optional avatar image URL.
  final String? avatarUrl;
}

/// A slash command for the rich editor.
///
/// Slash commands allow the user to type "/" and select an action from a
/// popup list, such as inserting a heading or code block.
///
/// {@category Composites}
class OiSlashCommand {
  /// Creates an [OiSlashCommand].
  const OiSlashCommand({
    required this.label,
    required this.icon,
    required this.onExecute,
    this.description,
  });

  /// The command label displayed in the popup.
  final String label;

  /// An optional description shown below the label.
  final String? description;

  /// The icon displayed alongside the command.
  final IconData icon;

  /// The callback executed when the user selects this command.
  final VoidCallback onExecute;
}

// ── Widget ───────────────────────────────────────────────────────────────────

/// A block-based rich text editor with toolbar and slash commands.
///
/// Supports headings, bold/italic/underline, lists, code blocks, quotes,
/// @mentions, and slash commands for block type insertion.
///
/// Each block of content is rendered with appropriate styling. The editor
/// content is managed by an [OiRichEditorController].
///
/// {@category Composites}
class OiRichEditor extends StatefulWidget {
  /// Creates an [OiRichEditor].
  const OiRichEditor({
    required this.controller,
    required this.label,
    super.key,
    this.toolbar = OiToolbarMode.fixed,
    this.placeholder,
    this.readOnly = false,
    this.autoFocus = false,
    this.minHeight,
    this.maxHeight,
    this.mentionProvider,
    this.onFileUpload,
    this.slashCommands,
    this.enableDragReorder = false,
    this.enableCodeBlocks = true,
    this.enableTables = false,
    this.enableFileEmbed = false,
    this.showWordCount = false,
    this.onChange,
    this.onFocusChange,
  });

  /// The controller managing the editor content.
  final OiRichEditorController controller;

  /// The label displayed above the editor frame.
  final String label;

  /// The toolbar display mode.
  final OiToolbarMode toolbar;

  /// Placeholder text shown when the editor is empty.
  final String? placeholder;

  /// Whether the editor is read-only.
  final bool readOnly;

  /// Whether the editor should request focus when first inserted.
  final bool autoFocus;

  /// The minimum height constraint for the editor area.
  final double? minHeight;

  /// The maximum height constraint for the editor area.
  final double? maxHeight;

  /// Called to fetch mention candidates for a query.
  final Future<List<OiMention>> Function(String query)? mentionProvider;

  /// Called when the user uploads a file.
  final Future<String> Function(Object file)? onFileUpload;

  /// Slash commands available in the editor.
  final List<OiSlashCommand>? slashCommands;

  /// Whether drag-to-reorder of blocks is enabled.
  final bool enableDragReorder;

  /// Whether code blocks are enabled.
  final bool enableCodeBlocks;

  /// Whether tables are enabled.
  final bool enableTables;

  /// Whether file embeds are enabled.
  final bool enableFileEmbed;

  /// Whether to display the word count below the editor.
  final bool showWordCount;

  /// Called when the content changes.
  final ValueChanged<OiRichContent>? onChange;

  /// Called when focus changes.
  final ValueChanged<bool>? onFocusChange;

  @override
  State<OiRichEditor> createState() => _OiRichEditorState();
}

class _OiRichEditorState extends State<OiRichEditor> {
  late FocusNode _focusNode;
  bool _focused = false;

  /// One controller per block — kept in sync with the model.
  final List<TextEditingController> _blockControllers = [];

  /// One focus node per block — kept in sync with the model.
  final List<FocusNode> _blockFocusNodes = [];

  /// Index of the block that most recently had focus.
  int _activeBlockIndex = 0;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode()..addListener(_handleFocusChange);
    widget.controller.addListener(_handleContentChange);
    _syncBlockControllers();
    if (widget.autoFocus) {
      _focusNode.requestFocus();
    }
  }

  @override
  void didUpdateWidget(OiRichEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_handleContentChange);
      widget.controller.addListener(_handleContentChange);
      _syncBlockControllers();
    }
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_handleFocusChange)
      ..dispose();
    widget.controller.removeListener(_handleContentChange);
    for (final c in _blockControllers) {
      c.dispose();
    }
    for (final fn in _blockFocusNodes) {
      fn.removeListener(_onBlockFocusChange);
      fn.dispose();
    }
    super.dispose();
  }

  void _handleFocusChange() {
    final focused = _focusNode.hasFocus;
    if (focused != _focused) {
      setState(() => _focused = focused);
      widget.onFocusChange?.call(focused);
    }
  }

  void _handleContentChange() {
    _syncBlockControllers();
    setState(() {});
    widget.onChange?.call(widget.controller.content);
  }

  void _onBlockFocusChange() {
    for (var i = 0; i < _blockFocusNodes.length; i++) {
      if (_blockFocusNodes[i].hasFocus) {
        if (_activeBlockIndex != i) {
          setState(() => _activeBlockIndex = i);
        }
        return;
      }
    }
  }

  void _syncBlockControllers() {
    final blocks = widget.controller.content.blocks;

    // Dispose excess controllers.
    while (_blockControllers.length > blocks.length) {
      _blockControllers.removeLast().dispose();
    }

    // Dispose excess focus nodes.
    while (_blockFocusNodes.length > blocks.length) {
      final fn = _blockFocusNodes.removeLast();
      fn.removeListener(_onBlockFocusChange);
      fn.dispose();
    }

    // Add missing controllers.
    while (_blockControllers.length < blocks.length) {
      _blockControllers.add(TextEditingController());
    }

    // Add missing focus nodes.
    while (_blockFocusNodes.length < blocks.length) {
      final fn = FocusNode()..addListener(_onBlockFocusChange);
      _blockFocusNodes.add(fn);
    }

    // Sync text content.
    for (var i = 0; i < blocks.length; i++) {
      if (_blockControllers[i].text != blocks[i].text) {
        _blockControllers[i].text = blocks[i].text;
      }
    }
  }

  void _onBlockChanged(int index, String text) {
    final blocks = List<OiContentBlock>.from(widget.controller.content.blocks);
    if (index < blocks.length) {
      blocks[index] = OiContentBlock(
        type: blocks[index].type,
        text: text,
        metadata: blocks[index].metadata,
        isBold: blocks[index].isBold,
        isItalic: blocks[index].isItalic,
        isUnderline: blocks[index].isUnderline,
      );
      widget.controller.updateContentSilently(OiRichContent(blocks: blocks));
    }
  }

  void _toggleFormatting(String format) {
    if (widget.readOnly) return;
    final blocks = List<OiContentBlock>.from(widget.controller.content.blocks);
    if (_activeBlockIndex >= blocks.length) return;

    final block = blocks[_activeBlockIndex];
    final updated = OiContentBlock(
      type: block.type,
      text: block.text,
      metadata: block.metadata,
      isBold: format == 'bold' ? !block.isBold : block.isBold,
      isItalic: format == 'italic' ? !block.isItalic : block.isItalic,
      isUnderline:
          format == 'underline' ? !block.isUnderline : block.isUnderline,
    );

    blocks[_activeBlockIndex] = updated;
    widget.controller.content = OiRichContent(blocks: blocks);
  }

  // ── Block rendering ────────────────────────────────────────────────────────

  TextStyle _styleForBlock(OiContentBlock block, BuildContext context) {
    final themeData = OiTheme.maybeOf(context);
    final textTheme = themeData?.textTheme;
    final colors = themeData?.colors;

    TextStyle base;
    switch (block.type) {
      case OiBlockType.heading1:
        base = textTheme?.styleFor(OiLabelVariant.h1) ??
            const TextStyle(fontSize: 40, fontWeight: FontWeight.w700);
      case OiBlockType.heading2:
        base = textTheme?.styleFor(OiLabelVariant.h2) ??
            const TextStyle(fontSize: 32, fontWeight: FontWeight.w600);
      case OiBlockType.heading3:
        base = textTheme?.styleFor(OiLabelVariant.h3) ??
            const TextStyle(fontSize: 24, fontWeight: FontWeight.w600);
      case OiBlockType.code:
        base = textTheme?.styleFor(OiLabelVariant.code) ??
            const TextStyle(fontSize: 14, fontFamily: 'monospace');
      case OiBlockType.quote:
        base = (textTheme?.styleFor(OiLabelVariant.body) ??
                const TextStyle(fontSize: 16))
            .copyWith(fontStyle: FontStyle.italic, color: colors?.textMuted);
      case OiBlockType.paragraph:
      case OiBlockType.bulletList:
      case OiBlockType.numberedList:
      case OiBlockType.divider:
        base = textTheme?.styleFor(OiLabelVariant.body) ??
            const TextStyle(fontSize: 16, fontWeight: FontWeight.w400);
    }

    // Apply inline formatting overrides.
    if (block.isBold) {
      base = base.copyWith(fontWeight: FontWeight.w700);
    }
    if (block.isItalic) {
      base = base.copyWith(fontStyle: FontStyle.italic);
    }
    if (block.isUnderline) {
      base = base.copyWith(decoration: TextDecoration.underline);
    }

    return base;
  }

  Widget _buildBlock(BuildContext context, int index, OiContentBlock block) {
    if (block.type == OiBlockType.divider) {
      final colors = OiTheme.maybeOf(context)?.colors;
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Container(
          height: 1,
          color: colors?.border ?? const Color(0xFFD1D5DB),
        ),
      );
    }

    final style = _styleForBlock(block, context);
    final cursorColor =
        OiTheme.maybeOf(context)?.colors.primary.base ??
        const Color(0xFF000000);

    Widget blockWidget = EditableText(
      controller: _blockControllers[index],
      focusNode: _blockFocusNodes[index],
      style: style,
      cursorColor: cursorColor,
      backgroundCursorColor: const Color(0xFF000000),
      maxLines: null,
      readOnly: widget.readOnly,
      onChanged: (text) => _onBlockChanged(index, text),
      selectionColor: cursorColor.withValues(alpha: 0.3),
    );

    // Add prefix for list items.
    if (block.type == OiBlockType.bulletList) {
      blockWidget = Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('\u2022 ', style: style),
          Expanded(child: blockWidget),
        ],
      );
    } else if (block.type == OiBlockType.numberedList) {
      // Count the index within contiguous numbered blocks.
      var num = 1;
      for (var j = index - 1; j >= 0; j--) {
        if (widget.controller.content.blocks[j].type ==
            OiBlockType.numberedList) {
          num++;
        } else {
          break;
        }
      }
      blockWidget = Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$num. ', style: style),
          Expanded(child: blockWidget),
        ],
      );
    } else if (block.type == OiBlockType.quote) {
      final colors = OiTheme.maybeOf(context)?.colors;
      blockWidget = Container(
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: colors?.border ?? const Color(0xFFD1D5DB),
              width: 3,
            ),
          ),
        ),
        padding: const EdgeInsets.only(left: 12),
        child: blockWidget,
      );
    } else if (block.type == OiBlockType.code) {
      final colors = OiTheme.maybeOf(context)?.colors;
      blockWidget = Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colors?.surfaceSubtle ?? const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(6),
        ),
        child: blockWidget,
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: blockWidget,
    );
  }

  // ── Toolbar ────────────────────────────────────────────────────────────────

  Widget _buildToolbar(BuildContext context) {
    if (widget.toolbar == OiToolbarMode.none) {
      return const SizedBox.shrink();
    }

    final colors = OiTheme.maybeOf(context)?.colors;
    final toolbarColor = colors?.surfaceSubtle ?? const Color(0xFFF9FAFB);
    final iconColor = colors?.text ?? const Color(0xFF111827);

    final isMinimal = widget.toolbar == OiToolbarMode.minimal;

    final actions = <Widget>[
      // ── Bold / Italic / Underline ─────────────────────────────────────────
      _ToolbarButton(
        icon: const Text(
          'B',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
        ),
        semanticLabel: 'Bold',
        onPressed: widget.readOnly ? null : () => _toggleFormatting('bold'),
      ),
      _ToolbarButton(
        icon: const Text(
          'I',
          style: TextStyle(fontStyle: FontStyle.italic, fontSize: 13),
        ),
        semanticLabel: 'Italic',
        onPressed: widget.readOnly ? null : () => _toggleFormatting('italic'),
      ),
      _ToolbarButton(
        icon: const Text(
          'U',
          style: TextStyle(
            decoration: TextDecoration.underline,
            fontSize: 13,
          ),
        ),
        semanticLabel: 'Underline',
        onPressed:
            widget.readOnly ? null : () => _toggleFormatting('underline'),
      ),

      // ── Block type buttons ────────────────────────────────────────────────
      _ToolbarButton(
        icon: const Text(
          'H1',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
        ),
        semanticLabel: 'Heading 1',
        onPressed: widget.readOnly
            ? null
            : () => _insertBlock(OiBlockType.heading1),
      ),
      if (!isMinimal) ...[
        _ToolbarButton(
          icon: const Text(
            'H2',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
          ),
          semanticLabel: 'Heading 2',
          onPressed: widget.readOnly
              ? null
              : () => _insertBlock(OiBlockType.heading2),
        ),
        _ToolbarButton(
          icon: const Text(
            'H3',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
          ),
          semanticLabel: 'Heading 3',
          onPressed: widget.readOnly
              ? null
              : () => _insertBlock(OiBlockType.heading3),
        ),
      ],
      _ToolbarButton(
        icon: Text('\u2022', style: TextStyle(fontSize: 16, color: iconColor)),
        semanticLabel: 'Bullet list',
        onPressed: widget.readOnly
            ? null
            : () => _insertBlock(OiBlockType.bulletList),
      ),
      _ToolbarButton(
        icon: Text(
          '1.',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: iconColor,
          ),
        ),
        semanticLabel: 'Numbered list',
        onPressed: widget.readOnly
            ? null
            : () => _insertBlock(OiBlockType.numberedList),
      ),
      if (widget.enableCodeBlocks && !isMinimal)
        _ToolbarButton(
          icon: Text(
            '</>',
            style: TextStyle(
              fontSize: 12,
              fontFamily: 'monospace',
              color: iconColor,
            ),
          ),
          semanticLabel: 'Code block',
          onPressed: widget.readOnly
              ? null
              : () => _insertBlock(OiBlockType.code),
        ),
      if (!isMinimal)
        _ToolbarButton(
          icon: Text(
            '\u275D',
            style: TextStyle(fontSize: 14, color: iconColor),
          ),
          semanticLabel: 'Quote',
          onPressed: widget.readOnly
              ? null
              : () => _insertBlock(OiBlockType.quote),
        ),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: toolbarColor,
        border: Border(
          bottom: BorderSide(
            color: colors?.borderSubtle ?? const Color(0xFFE5E7EB),
          ),
        ),
      ),
      child: Semantics(
        label: 'Editor toolbar',
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: actions),
        ),
      ),
    );
  }

  void _insertBlock(OiBlockType type) {
    final blocks = List<OiContentBlock>.from(widget.controller.content.blocks);
    blocks.add(OiContentBlock(type: type, text: ''));
    widget.controller.content = OiRichContent(blocks: blocks);
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final content = widget.controller.content;
    final isEmpty =
        content.blocks.isEmpty ||
        (content.blocks.length == 1 && content.blocks.first.text.isEmpty);
    final colors = OiTheme.maybeOf(context)?.colors;

    Widget editorBody = Focus(
      focusNode: _focusNode,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isEmpty && widget.placeholder != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                widget.placeholder!,
                style: TextStyle(
                  fontSize: 16,
                  color: (colors?.textMuted ?? const Color(0xFF6B7280))
                      .withValues(alpha: 0.6),
                ),
              ),
            ),
          for (var i = 0; i < content.blocks.length; i++)
            _buildBlock(context, i, content.blocks[i]),
        ],
      ),
    );

    // Apply height constraints.
    if (widget.minHeight != null || widget.maxHeight != null) {
      editorBody = ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: widget.minHeight ?? 0,
          maxHeight: widget.maxHeight ?? double.infinity,
        ),
        child: SingleChildScrollView(child: editorBody),
      );
    }

    return Semantics(
      label: widget.label,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          OiInputFrame(
            label: widget.label,
            focused: _focused,
            enabled: !widget.readOnly,
            readOnly: widget.readOnly,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildToolbar(context),
                Padding(padding: const EdgeInsets.all(8), child: editorBody),
              ],
            ),
          ),
          if (widget.showWordCount)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                '${widget.controller.wordCount} words',
                style: TextStyle(
                  fontSize: 12,
                  color: colors?.textMuted ?? const Color(0xFF6B7280),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Internal helpers ─────────────────────────────────────────────────────────

/// A small toolbar button that wraps a child widget with tap handling.
class _ToolbarButton extends StatelessWidget {
  const _ToolbarButton({
    required this.icon,
    required this.semanticLabel,
    this.onPressed,
  });

  /// The icon or label widget.
  final Widget icon;

  /// Accessibility label for the button.
  final String semanticLabel;

  /// The callback executed on tap. Null disables the button.
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      button: true,
      enabled: onPressed != null,
      child: GestureDetector(
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          child: Opacity(opacity: onPressed != null ? 1.0 : 0.4, child: icon),
        ),
      ),
    );
  }
}

/// Escapes HTML special characters.
String _escapeHtml(String text) {
  return text
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;');
}

/// Compares two nullable maps for equality.
bool _mapEquals(Map<String, dynamic>? a, Map<String, dynamic>? b) {
  if (a == null && b == null) return true;
  if (a == null || b == null) return false;
  if (a.length != b.length) return false;
  for (final key in a.keys) {
    if (a[key] != b[key]) return false;
  }
  return true;
}
