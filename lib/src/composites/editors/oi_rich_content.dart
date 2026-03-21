import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart' show OiRichEditor;
import 'package:obers_ui/src/composites/editors/oi_rich_editor.dart'
    show OiRichEditor;

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
/// inline formatting flags ([bold], [italic], [underline]).
///
/// {@category Composites}
@immutable
class OiContentBlock {
  /// Creates an [OiContentBlock].
  const OiContentBlock({
    required this.type,
    required this.text,
    this.metadata,
    this.bold = false,
    this.italic = false,
    this.underline = false,
  });

  /// The type of block.
  final OiBlockType type;

  /// The text content of the block.
  final String text;

  /// Optional metadata such as `{"language": "dart"}` for code blocks.
  final Map<String, dynamic>? metadata;

  /// Whether the block text is rendered in bold.
  final bool bold;

  /// Whether the block text is rendered in italic.
  final bool italic;

  /// Whether the block text is rendered with underline.
  final bool underline;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OiContentBlock &&
        other.type == type &&
        other.text == text &&
        other.bold == bold &&
        other.italic == italic &&
        other.underline == underline &&
        mapEquals(other.metadata, metadata);
  }

  @override
  int get hashCode =>
      Object.hash(type, text, bold, italic, underline, metadata?.length);
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
          buffer.write('<p>${escapeHtml(block.text)}</p>');
        case OiBlockType.heading1:
          buffer.write('<h1>${escapeHtml(block.text)}</h1>');
        case OiBlockType.heading2:
          buffer.write('<h2>${escapeHtml(block.text)}</h2>');
        case OiBlockType.heading3:
          buffer.write('<h3>${escapeHtml(block.text)}</h3>');
        case OiBlockType.bulletList:
          if (!inUnorderedList) {
            buffer.write('<ul>');
            inUnorderedList = true;
          }
          buffer.write('<li>${escapeHtml(block.text)}</li>');
        case OiBlockType.numberedList:
          if (!inOrderedList) {
            buffer.write('<ol>');
            inOrderedList = true;
          }
          buffer.write('<li>${escapeHtml(block.text)}</li>');
        case OiBlockType.code:
          final lang = block.metadata?['language'] as String?;
          if (lang != null && lang.isNotEmpty) {
            buffer.write(
              '<pre><code class="language-$lang">'
              '${escapeHtml(block.text)}'
              '</code></pre>',
            );
          } else {
            buffer.write('<pre><code>${escapeHtml(block.text)}</code></pre>');
          }
        case OiBlockType.quote:
          buffer.write('<blockquote>${escapeHtml(block.text)}</blockquote>');
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
        ops
          ..add({
            'insert': {'divider': true},
          })
          ..add({'insert': '\n'});
        continue;
      }

      // Build inline attributes for text formatting.
      final inlineAttrs = <String, dynamic>{};
      if (block.bold) inlineAttrs['bold'] = true;
      if (block.italic) inlineAttrs['italic'] = true;
      if (block.underline) inlineAttrs['underline'] = true;

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
        ops.add({
          'insert': '\n',
          'attributes': Map<String, dynamic>.from(lineAttrs),
        });
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

// ── Internal helpers ─────────────────────────────────────────────────────────

/// Escapes HTML special characters.
String escapeHtml(String text) {
  return text
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;');
}

/// Compares two nullable maps for equality.
bool mapEquals(Map<String, dynamic>? a, Map<String, dynamic>? b) {
  if (a == null && b == null) return true;
  if (a == null || b == null) return false;
  if (a.length != b.length) return false;
  for (final key in a.keys) {
    if (a[key] != b[key]) return false;
  }
  return true;
}
