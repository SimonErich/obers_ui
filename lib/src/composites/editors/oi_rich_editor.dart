import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/_internal/oi_input_frame.dart';
import 'package:obers_ui/src/composites/editors/oi_rich_content.dart';
import 'package:obers_ui/src/composites/editors/oi_rich_editor_controller.dart';
import 'package:obers_ui/src/foundation/theme/oi_text_theme.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';

export 'package:obers_ui/src/composites/editors/oi_rich_content.dart';
export 'package:obers_ui/src/composites/editors/oi_rich_editor_controller.dart';

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
      fn
        ..removeListener(_onBlockFocusChange)
        ..dispose();
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
      _blockFocusNodes.removeLast()
        ..removeListener(_onBlockFocusChange)
        ..dispose();
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
        bold: blocks[index].bold,
        italic: blocks[index].italic,
        underline: blocks[index].underline,
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
      bold: format == 'bold' ? !block.bold : block.bold,
      italic: format == 'italic' ? !block.italic : block.italic,
      underline: format == 'underline' ? !block.underline : block.underline,
    );

    blocks[_activeBlockIndex] = updated;
    widget.controller.content = OiRichContent(blocks: blocks);
  }

  /// Handles Enter key to create a new paragraph block after the current one.
  KeyEventResult _onBlockKeyEvent(int index, FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }

    if (event.logicalKey == LogicalKeyboardKey.enter) {
      if (widget.readOnly) return KeyEventResult.ignored;

      final controller = _blockControllers[index];
      final cursorPos = controller.selection.baseOffset;
      final text = controller.text;

      // Text after cursor goes to the new block.
      final before = cursorPos >= 0 ? text.substring(0, cursorPos) : text;
      final after = cursorPos >= 0 ? text.substring(cursorPos) : '';

      final blocks =
          List<OiContentBlock>.from(widget.controller.content.blocks);
      blocks[index] = OiContentBlock(
        type: blocks[index].type,
        text: before,
        metadata: blocks[index].metadata,
        bold: blocks[index].bold,
        italic: blocks[index].italic,
        underline: blocks[index].underline,
      );
      blocks.insert(
        index + 1,
        OiContentBlock(type: OiBlockType.paragraph, text: after),
      );
      widget.controller.content = OiRichContent(blocks: blocks);

      // Focus the new block after rebuild.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (index + 1 < _blockFocusNodes.length) {
          _blockFocusNodes[index + 1].requestFocus();
          _blockControllers[index + 1].selection =
              const TextSelection.collapsed(offset: 0);
        }
      });

      return KeyEventResult.handled;
    }

    if (event.logicalKey == LogicalKeyboardKey.backspace) {
      if (widget.readOnly) return KeyEventResult.ignored;
      final controller = _blockControllers[index];
      // Merge with previous block when cursor is at the start.
      if (index > 0 && controller.selection.baseOffset == 0 &&
          controller.selection.extentOffset == 0) {
        final blocks =
            List<OiContentBlock>.from(widget.controller.content.blocks);
        final prevText = blocks[index - 1].text;
        final curText = blocks[index].text;
        blocks[index - 1] = OiContentBlock(
          type: blocks[index - 1].type,
          text: prevText + curText,
          metadata: blocks[index - 1].metadata,
          bold: blocks[index - 1].bold,
          italic: blocks[index - 1].italic,
          underline: blocks[index - 1].underline,
        );
        blocks.removeAt(index);
        widget.controller.content = OiRichContent(blocks: blocks);

        // Place cursor at the join point.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (index - 1 < _blockFocusNodes.length) {
            _blockFocusNodes[index - 1].requestFocus();
            _blockControllers[index - 1].selection =
                TextSelection.collapsed(offset: prevText.length);
          }
        });

        return KeyEventResult.handled;
      }
    }

    return KeyEventResult.ignored;
  }

  // ── Block rendering ────────────────────────────────────────────────────────

  TextStyle _styleForBlock(OiContentBlock block, BuildContext context) {
    final themeData = OiTheme.maybeOf(context);
    final textTheme = themeData?.textTheme;
    final colors = themeData?.colors;

    TextStyle base;
    switch (block.type) {
      case OiBlockType.heading1:
        base =
            textTheme?.styleFor(OiLabelVariant.h1) ??
            const TextStyle(fontSize: 40, fontWeight: FontWeight.w700);
      case OiBlockType.heading2:
        base =
            textTheme?.styleFor(OiLabelVariant.h2) ??
            const TextStyle(fontSize: 32, fontWeight: FontWeight.w600);
      case OiBlockType.heading3:
        base =
            textTheme?.styleFor(OiLabelVariant.h3) ??
            const TextStyle(fontSize: 24, fontWeight: FontWeight.w600);
      case OiBlockType.code:
        base =
            textTheme?.styleFor(OiLabelVariant.code) ??
            const TextStyle(fontSize: 14, fontFamily: 'monospace');
      case OiBlockType.quote:
        base =
            (textTheme?.styleFor(OiLabelVariant.body) ??
                    const TextStyle(fontSize: 16))
                .copyWith(
                  fontStyle: FontStyle.italic,
                  color: colors?.textMuted,
                );
      case OiBlockType.paragraph:
      case OiBlockType.bulletList:
      case OiBlockType.numberedList:
      case OiBlockType.divider:
        base =
            textTheme?.styleFor(OiLabelVariant.body) ??
            const TextStyle(fontSize: 16, fontWeight: FontWeight.w400);
    }

    // Apply inline formatting overrides.
    if (block.bold) {
      base = base.copyWith(fontWeight: FontWeight.w700);
    }
    if (block.italic) {
      base = base.copyWith(fontStyle: FontStyle.italic);
    }
    if (block.underline) {
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

    Widget blockWidget = Focus(
      onKeyEvent: (node, event) => _onBlockKeyEvent(index, node, event),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 24),
        child: EditableText(
          controller: _blockControllers[index],
          focusNode: _blockFocusNodes[index],
          style: style,
          cursorColor: cursorColor,
          backgroundCursorColor: const Color(0xFF000000),
          maxLines: null,
          readOnly: widget.readOnly,
          onChanged: (text) => _onBlockChanged(index, text),
          selectionColor: cursorColor.withValues(alpha: 0.3),
        ),
      ),
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
          style: TextStyle(decoration: TextDecoration.underline, fontSize: 13),
        ),
        semanticLabel: 'Underline',
        onPressed: widget.readOnly
            ? null
            : () => _toggleFormatting('underline'),
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
    if (widget.readOnly) return;
    final blocks = List<OiContentBlock>.from(widget.controller.content.blocks);
    if (_activeBlockIndex < blocks.length) {
      // Change the type of the active block.
      final block = blocks[_activeBlockIndex];
      blocks[_activeBlockIndex] = OiContentBlock(
        type: block.type == type ? OiBlockType.paragraph : type,
        text: block.text,
        metadata: block.metadata,
        bold: block.bold,
        italic: block.italic,
        underline: block.underline,
      );
    } else {
      blocks.add(OiContentBlock(type: type, text: ''));
    }
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
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < content.blocks.length; i++)
                _buildBlock(context, i, content.blocks[i]),
              // Tap target below content to focus the last block.
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  if (_blockFocusNodes.isNotEmpty) {
                    _blockFocusNodes.last.requestFocus();
                  }
                },
                child: const SizedBox(height: 40, width: double.infinity),
              ),
            ],
          ),
          if (isEmpty && widget.placeholder != null)
            IgnorePointer(
              child: Padding(
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
            ),
        ],
      ),
    );

    // Always wrap in a scrollable view so content doesn't overflow.
    if (widget.minHeight != null || widget.maxHeight != null) {
      editorBody = ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: widget.minHeight ?? 0,
          maxHeight: widget.maxHeight ?? double.infinity,
        ),
        child: SingleChildScrollView(child: editorBody),
      );
    } else {
      editorBody = SingleChildScrollView(child: editorBody);
    }

    final wordCount = widget.showWordCount
        ? Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '${widget.controller.wordCount} words',
              style: TextStyle(
                fontSize: 12,
                color: colors?.textMuted ?? const Color(0xFF6B7280),
              ),
            ),
          )
        : null;

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
          if (wordCount != null) wordCount,
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
