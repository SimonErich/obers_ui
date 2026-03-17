import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/display/oi_code_block.dart';
import 'package:obers_ui/src/foundation/theme/oi_color_scheme.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';

// ---------------------------------------------------------------------------
// Inline parser
// ---------------------------------------------------------------------------

/// A segment of parsed inline content.
class _Span {
  const _Span(
    this.text, {
    this.bold = false,
    this.italic = false,
    this.code = false,
    this.link = false,
    this.href,
  });
  final String text;
  final bool bold;
  final bool italic;
  final bool code;
  final bool link;
  final String? href;
}

/// Parses inline Markdown: **bold**, *italic*, `code`, [text](url).
List<_Span> _parseInline(String text) {
  final spans = <_Span>[];
  var remaining = text;

  while (remaining.isNotEmpty) {
    // Link: [text](url)
    final linkMatch = RegExp(r'\[([^\]]+)\]\(([^)]+)\)').firstMatch(remaining);
    if (linkMatch != null && linkMatch.start == 0) {
      spans.add(
        _Span(linkMatch.group(1)!, link: true, href: linkMatch.group(2)),
      );
      remaining = remaining.substring(linkMatch.end);
      continue;
    }

    // Bold: **text**
    final boldMatch = RegExp(r'\*\*(.+?)\*\*').firstMatch(remaining);
    if (boldMatch != null && boldMatch.start == 0) {
      spans.add(_Span(boldMatch.group(1)!, bold: true));
      remaining = remaining.substring(boldMatch.end);
      continue;
    }

    // Italic: *text*
    final italicMatch = RegExp(r'\*(.+?)\*').firstMatch(remaining);
    if (italicMatch != null && italicMatch.start == 0) {
      spans.add(_Span(italicMatch.group(1)!, italic: true));
      remaining = remaining.substring(italicMatch.end);
      continue;
    }

    // Inline code: `code`
    final codeMatch = RegExp('`([^`]+)`').firstMatch(remaining);
    if (codeMatch != null && codeMatch.start == 0) {
      spans.add(_Span(codeMatch.group(1)!, code: true));
      remaining = remaining.substring(codeMatch.end);
      continue;
    }

    // Advance to the next special character or end.
    final nextSpecial = RegExp(r'[\[*`]').firstMatch(remaining);
    if (nextSpecial == null) {
      spans.add(_Span(remaining));
      break;
    }
    spans.add(_Span(remaining.substring(0, nextSpecial.start)));
    remaining = remaining.substring(nextSpecial.start);
  }

  return spans;
}

// ---------------------------------------------------------------------------
// Block types
// ---------------------------------------------------------------------------

abstract class _Block {}

class _HeadingBlock extends _Block {
  _HeadingBlock(this.level, this.text);
  final int level;
  final String text;
}

class _ParagraphBlock extends _Block {
  _ParagraphBlock(this.text);
  final String text;
}

class _ListItemBlock extends _Block {
  _ListItemBlock(this.text);
  final String text;
}

class _FenceBlock extends _Block {
  _FenceBlock(this.code, this.lang);
  final String code;
  final String? lang;
}

class _BlankBlock extends _Block {}

// ---------------------------------------------------------------------------
// Parser
// ---------------------------------------------------------------------------

List<_Block> _parseBlocks(String data) {
  final blocks = <_Block>[];
  final lines = data.split('\n');
  var i = 0;

  while (i < lines.length) {
    final line = lines[i];

    // Fenced code block.
    final fenceMatch = RegExp(r'^```(\w*)').firstMatch(line);
    if (fenceMatch != null) {
      final lang = (fenceMatch.group(1)?.isNotEmpty ?? false)
          ? fenceMatch.group(1)
          : null;
      final codeLines = <String>[];
      i++;
      while (i < lines.length && !lines[i].startsWith('```')) {
        codeLines.add(lines[i]);
        i++;
      }
      blocks.add(_FenceBlock(codeLines.join('\n'), lang));
      i++; // skip closing ```
      continue;
    }

    // Headings (match from longest prefix to shortest to avoid false positives).
    final h3 = RegExp('^### (.+)').firstMatch(line);
    if (h3 != null) {
      blocks.add(_HeadingBlock(3, h3.group(1)!));
      i++;
      continue;
    }
    final h2 = RegExp('^## (.+)').firstMatch(line);
    if (h2 != null) {
      blocks.add(_HeadingBlock(2, h2.group(1)!));
      i++;
      continue;
    }
    final h1 = RegExp('^# (.+)').firstMatch(line);
    if (h1 != null) {
      blocks.add(_HeadingBlock(1, h1.group(1)!));
      i++;
      continue;
    }

    // List item.
    final listMatch = RegExp('^[-*+] (.+)').firstMatch(line);
    if (listMatch != null) {
      blocks.add(_ListItemBlock(listMatch.group(1)!));
      i++;
      continue;
    }

    // Blank line.
    if (line.trim().isEmpty) {
      blocks.add(_BlankBlock());
      i++;
      continue;
    }

    // Paragraph (accumulate consecutive non-special lines).
    final paraLines = <String>[];
    while (i < lines.length) {
      final l = lines[i];
      if (l.trim().isEmpty) break;
      if (RegExp('^#{1,3} ').hasMatch(l)) break;
      if (RegExp('^[-*+] ').hasMatch(l)) break;
      if (l.startsWith('```')) break;
      paraLines.add(l);
      i++;
    }
    if (paraLines.isNotEmpty) {
      blocks.add(_ParagraphBlock(paraLines.join(' ')));
    }
  }

  return blocks;
}

// ---------------------------------------------------------------------------
// Widget
// ---------------------------------------------------------------------------

/// A lightweight Markdown renderer.
///
/// Supports a subset of Markdown:
/// - Headings: `# h1`, `## h2`, `### h3`
/// - **Bold** and *italic* inline text.
/// - `` `inline code` ``
/// - Fenced ``` code blocks ``` rendered via [OiCodeBlock].
/// - Unordered lists: `- item`.
/// - Links: `[text](url)`.
/// - Line breaks between paragraphs.
///
/// No external dependency is used.
///
/// {@category Components}
class OiMarkdown extends StatelessWidget {
  /// Creates an [OiMarkdown].
  const OiMarkdown({
    required this.data,
    this.style,
    this.codeBlockMaxWidth,
    super.key,
  });

  /// The Markdown source text.
  final String data;

  /// Optional base [TextStyle] override.
  final TextStyle? style;

  /// Maximum width for rendered code blocks.
  final double? codeBlockMaxWidth;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final baseStyle = TextStyle(
      fontSize: 16,
      height: 1.6,
      color: colors.text,
    ).merge(style);

    final blocks = _parseBlocks(data);
    final widgets = <Widget>[];

    for (final block in blocks) {
      if (block is _BlankBlock) {
        widgets.add(const SizedBox(height: 8));
      } else if (block is _HeadingBlock) {
        final fontSize = switch (block.level) {
          1 => 28.0,
          2 => 22.0,
          _ => 18.0,
        };
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 4),
            child: Text(
              block.text,
              style: baseStyle.copyWith(
                fontSize: fontSize,
                fontWeight: FontWeight.w700,
                color: colors.text,
              ),
            ),
          ),
        );
      } else if (block is _FenceBlock) {
        Widget codeWidget = OiCodeBlock(code: block.code, language: block.lang);
        if (codeBlockMaxWidth != null) {
          codeWidget = SizedBox(width: codeBlockMaxWidth, child: codeWidget);
        }
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: codeWidget,
          ),
        );
      } else if (block is _ListItemBlock) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('• ', style: baseStyle),
                Expanded(child: _buildInline(block.text, baseStyle, colors)),
              ],
            ),
          ),
        );
      } else if (block is _ParagraphBlock) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: _buildInline(block.text, baseStyle, colors),
          ),
        );
      }
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  Widget _buildInline(String text, TextStyle base, OiColorScheme colors) {
    final spans = _parseInline(text);
    final textSpans = spans.map((s) {
      if (s.bold) {
        return TextSpan(
          text: s.text,
          style: base.copyWith(fontWeight: FontWeight.w700),
        );
      }
      if (s.italic) {
        return TextSpan(
          text: s.text,
          style: base.copyWith(fontStyle: FontStyle.italic),
        );
      }
      if (s.code) {
        return TextSpan(
          text: s.text,
          style: base.copyWith(
            fontFamily: 'monospace',
            fontSize: (base.fontSize ?? 16) * 0.9,
            color: colors.primary.base,
          ),
        );
      }
      if (s.link) {
        return TextSpan(
          text: s.text,
          style: base.copyWith(
            color: colors.primary.base,
            decoration: TextDecoration.underline,
          ),
        );
      }
      return TextSpan(text: s.text, style: base);
    }).toList();

    return Text.rich(TextSpan(children: textSpans));
  }
}
