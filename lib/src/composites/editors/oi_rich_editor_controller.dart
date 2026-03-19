import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/composites/editors/oi_rich_content.dart';

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
        bold: last.bold,
        italic: last.italic,
        underline: last.underline,
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
