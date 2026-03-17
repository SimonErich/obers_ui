import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/theme/oi_color_scheme.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/clipboard/oi_copy_button.dart';

// ---------------------------------------------------------------------------
// Simple regex-based tokeniser
// ---------------------------------------------------------------------------

/// A token kind produced by the syntax highlighter.
enum _TokenKind { keyword, string, comment, number, other }

/// A single syntax token.
class _Token {
  const _Token(this.text, this.kind);
  final String text;
  final _TokenKind kind;
}

// Common keywords shared across languages (duplicates intentionally removed).
const _keywords = {
  'abstract', 'assert', 'async', 'await', 'break', 'case', 'catch', 'class',
  'const', 'continue', 'default', 'do', 'else', 'enum', 'extends', 'false',
  'final', 'finally', 'for', 'if', 'implements', 'import', 'in', 'interface',
  'is', 'late', 'library', 'new', 'null', 'override', 'package', 'print',
  'return', 'static', 'super', 'switch', 'this', 'throw', 'true', 'try',
  'typedef', 'var', 'void', 'while', 'with', 'yield',
  // JS/TS extras (no duplicates from above).
  'let', 'function', 'export', 'from', 'require', 'type', 'string',
  'number', 'boolean',
};

List<_Token> _tokenise(String line) {
  final tokens = <_Token>[];
  var remaining = line;

  while (remaining.isNotEmpty) {
    // Single-line comment.
    final commentMatch = RegExp('(//.*|#.*)').firstMatch(remaining);
    if (commentMatch != null && commentMatch.start == 0) {
      tokens.add(_Token(commentMatch.group(0)!, _TokenKind.comment));
      break;
    }

    // String literal (single or double-quoted, or backtick).
    final stringMatch =
        RegExp(r'''("(?:[^"\\]|\\.)*"|'(?:[^'\\]|\\.)*'|`[^`]*`)''')
            .firstMatch(remaining);
    if (stringMatch != null && stringMatch.start == 0) {
      tokens.add(_Token(stringMatch.group(0)!, _TokenKind.string));
      remaining = remaining.substring(stringMatch.end);
      continue;
    }

    // Number literal.
    final numMatch = RegExp(r'\b\d+(\.\d+)?\b').firstMatch(remaining);
    if (numMatch != null && numMatch.start == 0) {
      tokens.add(_Token(numMatch.group(0)!, _TokenKind.number));
      remaining = remaining.substring(numMatch.end);
      continue;
    }

    // Identifier or keyword.
    final wordMatch = RegExp(r'\b[a-zA-Z_]\w*\b').firstMatch(remaining);
    if (wordMatch != null && wordMatch.start == 0) {
      final word = wordMatch.group(0)!;
      final kind =
          _keywords.contains(word) ? _TokenKind.keyword : _TokenKind.other;
      tokens.add(_Token(word, kind));
      remaining = remaining.substring(wordMatch.end);
      continue;
    }

    // Non-word characters: consume one character at a time.
    tokens.add(_Token(remaining[0], _TokenKind.other));
    remaining = remaining.substring(1);
  }

  return tokens;
}

// ---------------------------------------------------------------------------
// Widget
// ---------------------------------------------------------------------------

/// A styled code block with optional syntax highlighting, line numbers, and
/// a copy button.
///
/// Renders [code] in a monospace font with basic token-based syntax
/// highlighting for keywords, strings, comments, and numbers. No external
/// dependency is required — a simple regex tokeniser handles common languages.
///
/// When [showCopyButton] is `true`, an [OiCopyButton] appears in the top-right
/// corner. When [lineNumbers] is `true`, each line is prefixed with its
/// 1-based number.
///
/// {@category Components}
class OiCodeBlock extends StatelessWidget {
  /// Creates an [OiCodeBlock].
  const OiCodeBlock({
    required this.code,
    this.language,
    this.showCopyButton = true,
    this.lineNumbers = false,
    this.maxHeight,
    super.key,
  });

  /// The source code to display.
  final String code;

  /// Optional language hint (currently used only for documentation).
  final String? language;

  /// Whether to show a copy-to-clipboard button. Defaults to `true`.
  final bool showCopyButton;

  /// Whether to show line numbers. Defaults to `false`.
  final bool lineNumbers;

  /// Maximum height before the block scrolls.
  final double? maxHeight;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final monoStyle = TextStyle(
      fontFamily: 'monospace',
      fontSize: 13,
      height: 1.6,
      color: colors.text,
    );

    final lines = code.split('\n');

    Widget codeContent = SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(lines.length, (i) {
          final lineText = lines[i];
          final tokens = _tokenise(lineText);
          final spans = tokens.map(
            (t) => TextSpan(
              text: t.text,
              style: _styleForKind(t.kind, colors, monoStyle),
            ),
          );

          Widget lineWidget = Text.rich(
            TextSpan(children: [...spans]),
            style: monoStyle,
          );

          if (lineNumbers) {
            final numStr = '${i + 1}'.padLeft('${lines.length}'.length);
            lineWidget = Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$numStr  ',
                  style: monoStyle.copyWith(color: colors.textMuted),
                ),
                lineWidget,
              ],
            );
          }

          return lineWidget;
        }),
      ),
    );

    if (maxHeight != null) {
      codeContent = SizedBox(
        height: maxHeight,
        child: SingleChildScrollView(child: codeContent),
      );
    }

    final block = Container(
      decoration: BoxDecoration(
        color: colors.surfaceSubtle,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.border),
      ),
      padding: const EdgeInsets.all(16),
      child: codeContent,
    );

    if (!showCopyButton) return block;

    return Stack(
      children: [
        block,
        Positioned(
          top: 8,
          right: 8,
          child: OiCopyButton(
            value: code,
            icon: Text(
              '⎘',
              style: TextStyle(fontSize: 14, color: colors.textMuted),
            ),
          ),
        ),
      ],
    );
  }

  TextStyle _styleForKind(
    _TokenKind kind,
    OiColorScheme colors,
    TextStyle base,
  ) {
    switch (kind) {
      case _TokenKind.keyword:
        return base.copyWith(
          color: colors.primary.base,
          fontWeight: FontWeight.w600,
        );
      case _TokenKind.string:
        return base.copyWith(color: colors.success.base);
      case _TokenKind.comment:
        return base.copyWith(color: colors.textMuted);
      case _TokenKind.number:
        return base.copyWith(color: colors.accent.base);
      case _TokenKind.other:
        return base;
    }
  }
}
