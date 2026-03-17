// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter_test/flutter_test.dart';
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
}
