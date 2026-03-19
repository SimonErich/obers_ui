// Tests do not require documentation comments.
// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/src/composites/editors/oi_rich_editor.dart';

import '../../../helpers/pump_app.dart';

// ── OiRichContent tests ─────────────────────────────────────────────────────

void main() {
  group('OiRichContent', () {
    test('toHtml produces valid output', () {
      const content = OiRichContent(
        blocks: [
          OiContentBlock(type: OiBlockType.heading1, text: 'Title'),
          OiContentBlock(type: OiBlockType.paragraph, text: 'Hello world'),
          OiContentBlock(type: OiBlockType.bulletList, text: 'Item A'),
          OiContentBlock(type: OiBlockType.bulletList, text: 'Item B'),
          OiContentBlock(type: OiBlockType.numberedList, text: 'First'),
          OiContentBlock(type: OiBlockType.numberedList, text: 'Second'),
          OiContentBlock(
            type: OiBlockType.code,
            text: 'print("hi")',
            metadata: {'language': 'dart'},
          ),
          OiContentBlock(type: OiBlockType.quote, text: 'A quote'),
          OiContentBlock(type: OiBlockType.divider, text: ''),
        ],
      );

      final html = content.toHtml();

      expect(html, contains('<h1>Title</h1>'));
      expect(html, contains('<p>Hello world</p>'));
      expect(html, contains('<ul><li>Item A</li><li>Item B</li></ul>'));
      expect(html, contains('<ol><li>First</li><li>Second</li></ol>'));
      expect(html, contains('<pre><code class="language-dart">'));
      expect(html, contains('print(&quot;hi&quot;)'));
      expect(html, contains('<blockquote>A quote</blockquote>'));
      expect(html, contains('<hr/>'));
    });

    test('toHtml escapes HTML entities', () {
      const content = OiRichContent(
        blocks: [
          OiContentBlock(
            type: OiBlockType.paragraph,
            text: '<script>alert("xss")</script>',
          ),
        ],
      );

      final html = content.toHtml();
      expect(html, isNot(contains('<script>')));
      expect(html, contains('&lt;script&gt;'));
    });

    test('toMarkdown produces valid output', () {
      const content = OiRichContent(
        blocks: [
          OiContentBlock(type: OiBlockType.heading1, text: 'Title'),
          OiContentBlock(type: OiBlockType.heading2, text: 'Subtitle'),
          OiContentBlock(type: OiBlockType.heading3, text: 'Section'),
          OiContentBlock(type: OiBlockType.paragraph, text: 'Body text'),
          OiContentBlock(type: OiBlockType.bulletList, text: 'Bullet'),
          OiContentBlock(type: OiBlockType.numberedList, text: 'First'),
          OiContentBlock(type: OiBlockType.numberedList, text: 'Second'),
          OiContentBlock(
            type: OiBlockType.code,
            text: 'var x = 1;',
            metadata: {'language': 'dart'},
          ),
          OiContentBlock(type: OiBlockType.quote, text: 'Quoted text'),
          OiContentBlock(type: OiBlockType.divider, text: ''),
        ],
      );

      final md = content.toMarkdown();

      expect(md, contains('# Title'));
      expect(md, contains('## Subtitle'));
      expect(md, contains('### Section'));
      expect(md, contains('Body text'));
      expect(md, contains('- Bullet'));
      expect(md, contains('1. First'));
      expect(md, contains('2. Second'));
      expect(md, contains('```dart'));
      expect(md, contains('var x = 1;'));
      expect(md, contains('> Quoted text'));
      expect(md, contains('---'));
    });

    test('toPlainText strips formatting', () {
      const content = OiRichContent(
        blocks: [
          OiContentBlock(type: OiBlockType.heading1, text: 'Title'),
          OiContentBlock(type: OiBlockType.paragraph, text: 'Body'),
          OiContentBlock(type: OiBlockType.divider, text: ''),
          OiContentBlock(type: OiBlockType.quote, text: 'Quote'),
        ],
      );

      final plain = content.toPlainText();

      expect(plain, 'Title\nBody\nQuote');
    });

    test('wordCount is correct', () {
      const content = OiRichContent(
        blocks: [
          OiContentBlock(type: OiBlockType.paragraph, text: 'Hello world'),
          OiContentBlock(type: OiBlockType.paragraph, text: 'One two three'),
          OiContentBlock(type: OiBlockType.paragraph, text: ''),
        ],
      );

      expect(content.wordCount, 5);
    });

    test('wordCount is zero for empty content', () {
      const content = OiRichContent();
      expect(content.wordCount, 0);
    });

    test('fromPlainText creates paragraph blocks', () {
      final content = OiRichContent.fromPlainText(
        'First paragraph\n\nSecond paragraph',
      );

      expect(content.blocks.length, 2);
      expect(content.blocks[0].type, OiBlockType.paragraph);
      expect(content.blocks[0].text, 'First paragraph');
      expect(content.blocks[1].type, OiBlockType.paragraph);
      expect(content.blocks[1].text, 'Second paragraph');
    });

    test('fromPlainText with empty string creates empty content', () {
      final content = OiRichContent.fromPlainText('');
      expect(content.blocks, isEmpty);
    });

    test('empty() creates content with one empty paragraph', () {
      final content = OiRichContent.empty();

      expect(content.blocks.length, 1);
      expect(content.blocks.first.type, OiBlockType.paragraph);
      expect(content.blocks.first.text, isEmpty);
    });

    test('toDelta encodes paragraphs and headings', () {
      const content = OiRichContent(
        blocks: [
          OiContentBlock(type: OiBlockType.heading1, text: 'Title'),
          OiContentBlock(type: OiBlockType.paragraph, text: 'Body'),
        ],
      );

      final delta = content.toDelta();
      final ops = delta['ops'] as List<dynamic>;

      // Verify specific insert values and block attributes exist in ops.
      expect(ops.any((op) => op['insert'] == 'Title'), isTrue);
      expect(
        ops.any(
          (op) =>
              op['insert'] == '\n' &&
              (op['attributes'] as Map?)?['header'] == 1,
        ),
        isTrue,
      );
      expect(ops.any((op) => op['insert'] == 'Body'), isTrue);
      expect(
        ops.any((op) => op['insert'] == '\n' && op['attributes'] == null),
        isTrue,
      );
    });

    test('toDelta encodes list blocks', () {
      const content = OiRichContent(
        blocks: [
          OiContentBlock(type: OiBlockType.bulletList, text: 'Item'),
          OiContentBlock(type: OiBlockType.numberedList, text: 'One'),
        ],
      );

      final delta = content.toDelta();
      final ops = delta['ops'] as List<dynamic>;

      expect(
        ops.any(
          (op) =>
              op['insert'] == '\n' &&
              (op['attributes'] as Map?)?['list'] == 'bullet',
        ),
        isTrue,
      );
      expect(
        ops.any(
          (op) =>
              op['insert'] == '\n' &&
              (op['attributes'] as Map?)?['list'] == 'ordered',
        ),
        isTrue,
      );
    });

    test('toDelta encodes inline formatting', () {
      const content = OiRichContent(
        blocks: [
          OiContentBlock(
            type: OiBlockType.paragraph,
            text: 'Bold text',
            bold: true,
          ),
          OiContentBlock(
            type: OiBlockType.paragraph,
            text: 'Italic text',
            italic: true,
          ),
          OiContentBlock(
            type: OiBlockType.paragraph,
            text: 'Underlined',
            underline: true,
          ),
        ],
      );

      final delta = content.toDelta();
      final ops = delta['ops'] as List<dynamic>;

      expect(
        ops.any(
          (op) =>
              op['insert'] == 'Bold text' &&
              (op['attributes'] as Map?)?['bold'] == true,
        ),
        isTrue,
      );
      expect(
        ops.any(
          (op) =>
              op['insert'] == 'Italic text' &&
              (op['attributes'] as Map?)?['italic'] == true,
        ),
        isTrue,
      );
      expect(
        ops.any(
          (op) =>
              op['insert'] == 'Underlined' &&
              (op['attributes'] as Map?)?['underline'] == true,
        ),
        isTrue,
      );
    });

    test('toDelta encodes code and quote blocks', () {
      const content = OiRichContent(
        blocks: [
          OiContentBlock(type: OiBlockType.code, text: 'var x = 1;'),
          OiContentBlock(type: OiBlockType.quote, text: 'Quoted'),
        ],
      );

      final delta = content.toDelta();
      final ops = delta['ops'] as List<dynamic>;

      expect(
        ops.any(
          (op) =>
              op['insert'] == '\n' &&
              (op['attributes'] as Map?)?['code-block'] == true,
        ),
        isTrue,
      );
      expect(
        ops.any(
          (op) =>
              op['insert'] == '\n' &&
              (op['attributes'] as Map?)?['blockquote'] == true,
        ),
        isTrue,
      );
    });

    test('OiContentBlock equality includes formatting flags', () {
      const a = OiContentBlock(
        type: OiBlockType.paragraph,
        text: 'Hello',
        bold: true,
      );
      const b = OiContentBlock(
        type: OiBlockType.paragraph,
        text: 'Hello',
      );
      const c = OiContentBlock(
        type: OiBlockType.paragraph,
        text: 'Hello',
        bold: true,
      );

      expect(a, isNot(equals(b)));
      expect(a, equals(c));
    });
  });

  // ── OiRichEditorController tests ──────────────────────────────────────────

  group('OiRichEditorController', () {
    test('content getter returns initial content', () {
      final controller = OiRichEditorController();
      addTearDown(controller.dispose);

      expect(controller.content.blocks.length, 1);
      expect(controller.content.blocks.first.type, OiBlockType.paragraph);
    });

    test('content setter updates content', () {
      final controller = OiRichEditorController();
      addTearDown(controller.dispose);

      const newContent = OiRichContent(
        blocks: [OiContentBlock(type: OiBlockType.heading1, text: 'Title')],
      );
      controller.content = newContent;

      expect(controller.content.blocks.length, 1);
      expect(controller.content.blocks.first.text, 'Title');
    });

    test('insertText appends to last block', () {
      final controller = OiRichEditorController(
        initialContent: const OiRichContent(
          blocks: [OiContentBlock(type: OiBlockType.paragraph, text: 'Hello')],
        ),
      );
      addTearDown(controller.dispose);

      controller.insertText(' world');

      expect(controller.content.blocks.last.text, 'Hello world');
    });

    test('insertText creates paragraph when blocks are empty', () {
      final controller = OiRichEditorController(
        initialContent: const OiRichContent(),
      );
      addTearDown(controller.dispose);

      controller.insertText('New text');

      expect(controller.content.blocks.length, 1);
      expect(controller.content.blocks.first.text, 'New text');
      expect(controller.content.blocks.first.type, OiBlockType.paragraph);
    });

    test('notifies listeners on content change', () {
      final controller = OiRichEditorController();
      addTearDown(controller.dispose);

      var notified = false;
      controller
        ..addListener(() => notified = true)
        ..content = const OiRichContent(
          blocks: [
            OiContentBlock(type: OiBlockType.paragraph, text: 'Updated'),
          ],
        );

      expect(notified, isTrue);
    });

    test('notifies listeners on insertText', () {
      final controller = OiRichEditorController();
      addTearDown(controller.dispose);

      var notified = false;
      controller
        ..addListener(() => notified = true)
        ..insertText('text');

      expect(notified, isTrue);
    });

    test('toHtml delegates to content', () {
      final controller = OiRichEditorController(
        initialContent: const OiRichContent(
          blocks: [OiContentBlock(type: OiBlockType.paragraph, text: 'Hello')],
        ),
      );
      addTearDown(controller.dispose);

      expect(controller.toHtml(), '<p>Hello</p>');
    });

    test('toMarkdown delegates to content', () {
      final controller = OiRichEditorController(
        initialContent: const OiRichContent(
          blocks: [OiContentBlock(type: OiBlockType.heading1, text: 'Title')],
        ),
      );
      addTearDown(controller.dispose);

      expect(controller.toMarkdown(), '# Title');
    });

    test('toPlainText delegates to content', () {
      final controller = OiRichEditorController(
        initialContent: const OiRichContent(
          blocks: [
            OiContentBlock(type: OiBlockType.heading1, text: 'Title'),
            OiContentBlock(type: OiBlockType.paragraph, text: 'Body'),
          ],
        ),
      );
      addTearDown(controller.dispose);

      expect(controller.toPlainText(), 'Title\nBody');
    });

    test('toDelta delegates to content', () {
      final controller = OiRichEditorController(
        initialContent: const OiRichContent(
          blocks: [OiContentBlock(type: OiBlockType.paragraph, text: 'Hello')],
        ),
      );
      addTearDown(controller.dispose);

      final delta = controller.toDelta();
      expect(delta, containsPair('ops', isA<List>()));
    });

    test('wordCount delegates to content', () {
      final controller = OiRichEditorController(
        initialContent: const OiRichContent(
          blocks: [
            OiContentBlock(type: OiBlockType.paragraph, text: 'One two three'),
          ],
        ),
      );
      addTearDown(controller.dispose);

      expect(controller.wordCount, 3);
    });
  });

  // ── OiRichEditor widget tests ─────────────────────────────────────────────

  group('OiRichEditor', () {
    testWidgets('renders editor with label', (tester) async {
      final controller = OiRichEditorController();
      addTearDown(controller.dispose);

      await tester.pumpObers(
        Center(
          child: OiRichEditor(controller: controller, label: 'Description'),
        ),
      );

      expect(find.text('Description'), findsWidgets);
    });

    testWidgets('placeholder shows when empty', (tester) async {
      final controller = OiRichEditorController();
      addTearDown(controller.dispose);

      await tester.pumpObers(
        Center(
          child: OiRichEditor(
            controller: controller,
            label: 'Notes',
            placeholder: 'Start typing...',
          ),
        ),
      );

      expect(find.text('Start typing...'), findsOneWidget);
    });

    testWidgets('placeholder hides when content has text', (tester) async {
      final controller = OiRichEditorController(
        initialContent: const OiRichContent(
          blocks: [OiContentBlock(type: OiBlockType.paragraph, text: 'Hello')],
        ),
      );
      addTearDown(controller.dispose);

      await tester.pumpObers(
        Center(
          child: OiRichEditor(
            controller: controller,
            label: 'Notes',
            placeholder: 'Start typing...',
          ),
        ),
      );

      expect(find.text('Start typing...'), findsNothing);
    });

    testWidgets('readOnly prevents editing', (tester) async {
      final controller = OiRichEditorController(
        initialContent: const OiRichContent(
          blocks: [
            OiContentBlock(type: OiBlockType.paragraph, text: 'Read only'),
          ],
        ),
      );
      addTearDown(controller.dispose);

      await tester.pumpObers(
        Center(
          child: OiRichEditor(
            controller: controller,
            label: 'Viewer',
            readOnly: true,
          ),
        ),
      );

      // All EditableText widgets should be readOnly.
      final editableTexts = tester.widgetList<EditableText>(
        find.byType(EditableText),
      );
      for (final et in editableTexts) {
        expect(et.readOnly, isTrue);
      }
    });

    testWidgets('toolbar renders bold italic underline buttons', (
      tester,
    ) async {
      final controller = OiRichEditorController();
      addTearDown(controller.dispose);

      await tester.pumpObers(
        Center(
          child: OiRichEditor(controller: controller, label: 'Editor'),
        ),
      );

      expect(find.text('B'), findsOneWidget);
      expect(find.text('I'), findsOneWidget);
      expect(find.text('U'), findsOneWidget);
    });

    testWidgets('toolbar renders when mode is fixed', (tester) async {
      final controller = OiRichEditorController();
      addTearDown(controller.dispose);

      await tester.pumpObers(
        Center(
          child: OiRichEditor(controller: controller, label: 'Editor'),
        ),
      );

      // The toolbar should contain heading buttons.
      expect(find.text('H1'), findsOneWidget);
      expect(find.text('H2'), findsOneWidget);
      expect(find.text('H3'), findsOneWidget);
    });

    testWidgets('toolbar does not render when mode is none', (tester) async {
      final controller = OiRichEditorController();
      addTearDown(controller.dispose);

      await tester.pumpObers(
        Center(
          child: OiRichEditor(
            controller: controller,
            label: 'Editor',
            toolbar: OiToolbarMode.none,
          ),
        ),
      );

      expect(find.text('H1'), findsNothing);
      expect(find.text('B'), findsNothing);
    });

    testWidgets('minimal toolbar shows fewer buttons', (tester) async {
      final controller = OiRichEditorController();
      addTearDown(controller.dispose);

      await tester.pumpObers(
        Center(
          child: OiRichEditor(
            controller: controller,
            label: 'Editor',
            toolbar: OiToolbarMode.minimal,
          ),
        ),
      );

      // Minimal shows H1 but not H2/H3.
      expect(find.text('H1'), findsOneWidget);
      expect(find.text('H2'), findsNothing);
      expect(find.text('H3'), findsNothing);
    });

    testWidgets('bold button toggles bold on active block', (tester) async {
      final controller = OiRichEditorController(
        initialContent: const OiRichContent(
          blocks: [OiContentBlock(type: OiBlockType.paragraph, text: 'Hello')],
        ),
      );
      addTearDown(controller.dispose);

      await tester.pumpObers(
        Center(
          child: OiRichEditor(controller: controller, label: 'Editor'),
        ),
      );

      expect(controller.content.blocks.first.bold, isFalse);

      // Tap the Bold button.
      await tester.tap(find.text('B'));
      await tester.pump();

      expect(controller.content.blocks.first.bold, isTrue);

      // Tap again to toggle off.
      await tester.tap(find.text('B'));
      await tester.pump();

      expect(controller.content.blocks.first.bold, isFalse);
    });

    testWidgets('italic button toggles italic on active block', (
      tester,
    ) async {
      final controller = OiRichEditorController(
        initialContent: const OiRichContent(
          blocks: [OiContentBlock(type: OiBlockType.paragraph, text: 'Hello')],
        ),
      );
      addTearDown(controller.dispose);

      await tester.pumpObers(
        Center(
          child: OiRichEditor(controller: controller, label: 'Editor'),
        ),
      );

      await tester.tap(find.text('I'));
      await tester.pump();

      expect(controller.content.blocks.first.italic, isTrue);
    });

    testWidgets('underline button toggles underline on active block', (
      tester,
    ) async {
      final controller = OiRichEditorController(
        initialContent: const OiRichContent(
          blocks: [OiContentBlock(type: OiBlockType.paragraph, text: 'Hello')],
        ),
      );
      addTearDown(controller.dispose);

      await tester.pumpObers(
        Center(
          child: OiRichEditor(controller: controller, label: 'Editor'),
        ),
      );

      await tester.tap(find.text('U'));
      await tester.pump();

      expect(controller.content.blocks.first.underline, isTrue);
    });

    testWidgets('word count shows when enabled', (tester) async {
      final controller = OiRichEditorController(
        initialContent: const OiRichContent(
          blocks: [
            OiContentBlock(
              type: OiBlockType.paragraph,
              text: 'Hello beautiful world',
            ),
          ],
        ),
      );
      addTearDown(controller.dispose);

      await tester.pumpObers(
        Center(
          child: OiRichEditor(
            controller: controller,
            label: 'Editor',
            showWordCount: true,
          ),
        ),
      );

      expect(find.text('3 words'), findsOneWidget);
    });

    testWidgets('word count does not show when disabled', (tester) async {
      final controller = OiRichEditorController(
        initialContent: const OiRichContent(
          blocks: [
            OiContentBlock(type: OiBlockType.paragraph, text: 'Hello world'),
          ],
        ),
      );
      addTearDown(controller.dispose);

      await tester.pumpObers(
        Center(
          child: OiRichEditor(controller: controller, label: 'Editor'),
        ),
      );

      expect(find.textContaining('words'), findsNothing);
    });

    testWidgets('minHeight is applied', (tester) async {
      final controller = OiRichEditorController();
      addTearDown(controller.dispose);

      await tester.pumpObers(
        Center(
          child: OiRichEditor(
            controller: controller,
            label: 'Editor',
            minHeight: 200,
          ),
        ),
      );

      // Find the ConstrainedBox that has our minHeight constraint.
      final boxes = tester.widgetList<ConstrainedBox>(
        find.byType(ConstrainedBox),
      );
      final match = boxes.where((b) => b.constraints.minHeight == 200);
      expect(match, isNotEmpty);
    });

    testWidgets('maxHeight is applied', (tester) async {
      final controller = OiRichEditorController();
      addTearDown(controller.dispose);

      await tester.pumpObers(
        Center(
          child: OiRichEditor(
            controller: controller,
            label: 'Editor',
            maxHeight: 400,
          ),
        ),
      );

      final boxes = tester.widgetList<ConstrainedBox>(
        find.byType(ConstrainedBox),
      );
      final match = boxes.where((b) => b.constraints.maxHeight == 400);
      expect(match, isNotEmpty);
    });

    testWidgets('has correct semantics', (tester) async {
      final controller = OiRichEditorController();
      addTearDown(controller.dispose);

      await tester.pumpObers(
        Center(
          child: OiRichEditor(controller: controller, label: 'Rich Editor'),
        ),
      );

      // The Semantics widget wrapping the editor should expose the label.
      final semanticsWidgets = tester.widgetList<Semantics>(
        find.byWidgetPredicate(
          (w) => w is Semantics && w.properties.label == 'Rich Editor',
        ),
      );
      expect(semanticsWidgets, isNotEmpty);
    });

    testWidgets('renders multiple block types', (tester) async {
      final controller = OiRichEditorController(
        initialContent: const OiRichContent(
          blocks: [
            OiContentBlock(type: OiBlockType.heading1, text: 'Title'),
            OiContentBlock(type: OiBlockType.paragraph, text: 'Body'),
            OiContentBlock(type: OiBlockType.bulletList, text: 'Bullet'),
            OiContentBlock(type: OiBlockType.quote, text: 'Quote'),
          ],
        ),
      );
      addTearDown(controller.dispose);

      await tester.pumpObers(
        Center(
          child: OiRichEditor(controller: controller, label: 'Editor'),
        ),
      );

      // Each block should have an EditableText.
      expect(find.byType(EditableText), findsAtLeast(4));
    });

    testWidgets('divider block renders', (tester) async {
      final controller = OiRichEditorController(
        initialContent: const OiRichContent(
          blocks: [
            OiContentBlock(type: OiBlockType.paragraph, text: 'Before'),
            OiContentBlock(type: OiBlockType.divider, text: ''),
            OiContentBlock(type: OiBlockType.paragraph, text: 'After'),
          ],
        ),
      );
      addTearDown(controller.dispose);

      await tester.pumpObers(
        Center(
          child: OiRichEditor(controller: controller, label: 'Editor'),
        ),
      );

      // Two paragraph EditableText widgets (divider does not create one).
      expect(find.byType(EditableText), findsAtLeast(2));
    });
  });
}
