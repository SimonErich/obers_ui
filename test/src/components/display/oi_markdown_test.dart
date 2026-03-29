// Tests do not require documentation comments.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/components/display/oi_code_block.dart';
import 'package:obers_ui/src/components/display/oi_markdown.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('renders h1 heading', (tester) async {
    await tester.pumpObers(const OiMarkdown(data: '# Hello World'));
    expect(find.text('Hello World'), findsOneWidget);
  });

  testWidgets('renders h2 heading', (tester) async {
    await tester.pumpObers(const OiMarkdown(data: '## Section'));
    expect(find.text('Section'), findsOneWidget);
  });

  testWidgets('renders h3 heading', (tester) async {
    await tester.pumpObers(const OiMarkdown(data: '### Sub'));
    expect(find.text('Sub'), findsOneWidget);
  });

  testWidgets('renders bold text', (tester) async {
    await tester.pumpObers(const OiMarkdown(data: '**bold**'));
    expect(find.textContaining('bold'), findsOneWidget);
  });

  testWidgets('renders italic text', (tester) async {
    await tester.pumpObers(const OiMarkdown(data: '*italic*'));
    expect(find.textContaining('italic'), findsOneWidget);
  });

  testWidgets('renders inline code', (tester) async {
    await tester.pumpObers(const OiMarkdown(data: 'Use `myFunc()` here'));
    expect(find.textContaining('myFunc'), findsOneWidget);
  });

  testWidgets('renders unordered list item', (tester) async {
    await tester.pumpObers(const OiMarkdown(data: '- First item'));
    expect(find.textContaining('First item'), findsOneWidget);
    expect(find.text('• '), findsOneWidget);
  });

  testWidgets('renders paragraph text', (tester) async {
    await tester.pumpObers(const OiMarkdown(data: 'Just a paragraph.'));
    expect(find.textContaining('Just a paragraph'), findsOneWidget);
  });

  testWidgets('renders fenced code block', (tester) async {
    await tester.pumpObers(const OiMarkdown(data: '```\nvoid main() {}\n```'));
    expect(find.textContaining('main'), findsOneWidget);
  });

  // ── Mermaid support ─────────────────────────────────────────────────────

  testWidgets('mermaid block renders placeholder when enableMermaid is true', (
    tester,
  ) async {
    await tester.pumpObers(
      const OiMarkdown(data: '```mermaid\ngraph TD\nA-->B\n```'),
    );
    expect(find.text('Mermaid Diagram'), findsOneWidget);
  });

  testWidgets(
    'mermaid block renders as OiCodeBlock when enableMermaid is false',
    (tester) async {
      await tester.pumpObers(
        const OiMarkdown(
          data: '```mermaid\ngraph TD\nA-->B\n```',
          enableMermaid: false,
        ),
      );
      expect(find.text('Mermaid Diagram'), findsNothing);
      expect(find.byType(OiCodeBlock), findsOneWidget);
    },
  );

  testWidgets('mermaid block uses mermaidBuilder when provided', (
    tester,
  ) async {
    await tester.pumpObers(
      OiMarkdown(
        data: '```mermaid\ngraph TD\n```',
        mermaidBuilder: (source) => Text('Custom: $source'),
      ),
    );
    expect(find.text('Custom: graph TD'), findsOneWidget);
  });

  testWidgets('mermaid block calls onMermaidError when builder throws', (
    tester,
  ) async {
    String? capturedError;
    await tester.pumpObers(
      OiMarkdown(
        data: '```mermaid\ngraph TD\n```',
        mermaidBuilder: (_) => throw Exception('render fail'),
        onMermaidError: (error) => capturedError = error,
      ),
    );
    expect(capturedError, isNotNull);
    expect(capturedError, contains('render fail'));
    // Falls back to placeholder
    expect(find.text('Mermaid Diagram'), findsOneWidget);
  });

  testWidgets('non-mermaid code blocks still render as OiCodeBlock', (
    tester,
  ) async {
    await tester.pumpObers(
      const OiMarkdown(data: '```dart\nvoid main() {}\n```'),
    );
    expect(find.text('Mermaid Diagram'), findsNothing);
    expect(find.byType(OiCodeBlock), findsOneWidget);
  });
}
