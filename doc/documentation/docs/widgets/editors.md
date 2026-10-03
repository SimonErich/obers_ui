# Editors, Code & Markdown

These widgets let people write formatted text, and let you show code, Markdown,
diffs, and keyboard shortcuts. Two are full editors you bind to a controller.
The rest are display widgets that render a string you already have. All of them
read colors and spacing from the theme, and none pull in an external code or
Markdown package.

| Widget | What it does |
| --- | --- |
| `OiRichEditor` | A block-based editor with a formatting toolbar. |
| `OiRichContent` | The content model behind the editor. Converts to HTML, Markdown, plain text, or a Quill delta. |
| `OiSmartInput` | A text field that styles patterns like @mentions, #tags, and URLs as you type. |
| `OiCodeBlock` | Shows code in monospace with light syntax highlighting and a copy button. |
| `OiMarkdown` | Renders a subset of Markdown to widgets. |
| `OiDiffView` | Shows a diff, unified or side by side. |
| `OiKbd` | Renders keyboard shortcuts as small key chips. |

## OiRichEditor

A block-based rich text editor. Each paragraph, heading, list item, quote, and
code block is its own block. It ships with a formatting toolbar, and you bind it
to an `OiRichEditorController` that holds the content. Reach for it when people
write longer content: comments, descriptions, articles.

```dart
final controller = OiRichEditorController();

OiRichEditor(
  controller: controller,
  label: 'Description',
  placeholder: 'Write something...',
)
```

You read the content back off the controller, or listen with `onChange`.

```dart
OiRichEditor(
  controller: controller,
  label: 'Description',
  showWordCount: true,
  onChange: (content) => print(content.toMarkdown()),
)

// Anywhere you hold the controller:
final markdown = controller.toMarkdown();
final html = controller.toHtml();
```

### Attributes

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `controller` | `OiRichEditorController` | **required** | Holds and updates the content. |
| `label` | `String` | **required** | Field label, also the accessibility label. |
| `toolbar` | `OiToolbarMode` | `fixed` | `fixed`, `floating`, `minimal`, or `none`. |
| `placeholder` | `String?` | `null` | Shown when the editor is empty. |
| `readOnly` | `bool` | `false` | Render the content without editing. |
| `autoFocus` | `bool` | `false` | Request focus when first shown. |
| `minHeight` / `maxHeight` | `double?` | `null` | Constrain the editor area height. |
| `enableCodeBlocks` | `bool` | `true` | Show the code block toolbar button. |
| `showWordCount` | `bool` | `false` | Show a word count below the frame. |
| `mentionProvider` | `Future<List<OiMention>> Function(String)?` | `null` | Fetches @mention candidates. |
| `slashCommands` | `List<OiSlashCommand>?` | `null` | Actions offered when the user types "/". |
| `onChange` | `ValueChanged<OiRichContent>?` | `null` | Fires when the content changes. |
| `onFocusChange` | `ValueChanged<bool>?` | `null` | Fires when focus enters or leaves. |

!!! note
    The controller keeps a `TextEditingController` per block internally. Create
    the `OiRichEditorController` in your `State` and dispose it with the rest of
    your state, not inline in `build`.

!!! tip "When to reach for something else"
    For read-only content that is already Markdown, use `OiMarkdown`. Use
    `OiRichEditor` only when the user edits.

## OiRichContent

The content model the editor produces and consumes. It is a list of
`OiContentBlock`s. You rarely build it by hand for editing, but you use it to
seed an editor or to serialize what a user wrote.

```dart
// Seed an editor from plain text.
final controller = OiRichEditorController(
  initialContent: OiRichContent.fromPlainText('First line.\n\nSecond paragraph.'),
);

// Serialize the current content.
final content = controller.content;
final markdown = content.toMarkdown();
final html = content.toHtml();
final plain = content.toPlainText();
final delta = content.toDelta(); // Quill-compatible ops map
```

### Constructors and helpers

```dart
OiRichContent()                        // empty, no blocks
OiRichContent.empty()                  // one empty paragraph block
OiRichContent.fromPlainText('...')     // paragraphs split on blank lines
OiRichContent(blocks: [
  OiContentBlock(type: OiBlockType.heading1, text: 'Title'),
  OiContentBlock(type: OiBlockType.paragraph, text: 'Body text.'),
])
```

| Member | Type | Description |
| --- | --- | --- |
| `blocks` | `List<OiContentBlock>` | The content, in order. |
| `wordCount` | `int` | Total words across all blocks. |
| `toHtml()` | `String` | Renders the content as HTML. |
| `toMarkdown()` | `String` | Renders the content as Markdown. |
| `toPlainText()` | `String` | Strips all formatting. |
| `toDelta()` | `Map<String, dynamic>` | Quill delta `ops` map. |

Each `OiContentBlock` takes a `type` (`OiBlockType`), a `text` body, optional
`metadata` (for example `{'language': 'dart'}` on a code block), and the
`bold`, `italic`, and `underline` flags. `OiBlockType` covers `paragraph`,
`heading1`, `heading2`, `heading3`, `bulletList`, `numberedList`, `code`,
`quote`, and `divider`.

## OiSmartInput

A single-line or multi-line text field that recognizes patterns as the user
types and styles them inline. You supply `recognizers`, each a trigger character
plus a regex and a `TextStyle`. Good for comment boxes and search inputs where
@mentions, #tags, or URLs should stand out.

```dart
OiSmartInput(
  label: 'Comment',
  placeholder: 'Add a comment...',
  recognizers: [
    OiPatternRecognizer(
      trigger: '@',
      pattern: RegExp(r'@\w+'),
      style: TextStyle(color: context.colors.primary.base),
      showSuggestions: true,
    ),
    OiPatternRecognizer(
      trigger: '#',
      pattern: RegExp(r'#\w+'),
      style: TextStyle(color: context.colors.accent.base),
    ),
  ],
  onSuggestionQuery: (trigger, query) async => fetchPeople(query),
  onChange: (text) => setState(() => _text = text),
)
```

### Attributes

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `label` | `String` | **required** | Field label and accessibility label. |
| `value` | `String?` | `null` | Initial text. Ignored if you pass a `controller`. |
| `recognizers` | `List<OiPatternRecognizer>` | `const []` | Patterns to detect and style. |
| `onSuggestionQuery` | `Future<List<OiSuggestion>> Function(String, String)?` | `null` | Fetches suggestions after a trigger. Gets the trigger and the query. |
| `onSpanTap` | `ValueChanged<OiRecognizedSpan>?` | `null` | Fires when a styled span is tapped. |
| `onChange` | `ValueChanged<String>?` | `null` | Fires when the text changes. |
| `placeholder` | `String?` | `null` | Shown when the field is empty. |
| `maxLines` | `int` | `1` | Set higher for a multi-line field. |
| `enabled` | `bool` | `true` | Set `false` to make it read-only. |
| `hint` | `String?` | `null` | Helper text below the field. |
| `error` | `String?` | `null` | Error message. Shows the error border when set. |
| `controller` | `TextEditingController?` | `null` | Bring your own controller. |
| `focusNode` | `FocusNode?` | `null` | Bring your own focus node. |

!!! note
    A recognizer only shows a suggestion popup when its `showSuggestions` is
    `true` and you provide `onSuggestionQuery`. Without those, the pattern is
    still styled, just not completed.

## OiCodeBlock

Shows a block of code in a monospace font with light token highlighting for
keywords, strings, comments, and numbers. A copy button sits in the top-right
corner by default. Highlighting is regex-based and needs no external package.

```dart
OiCodeBlock(
  code: "void main() {\n  print('hello');\n}",
  language: 'dart',
)
```

```dart
// Line numbers, and a max height so long snippets scroll.
OiCodeBlock(
  code: source,
  language: 'dart',
  lineNumbers: true,
  showCopyButton: false,
  maxHeight: 320,
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `code` | `String` | **required** | The source to display. |
| `language` | `String?` | `null` | Language hint. Currently informational only. |
| `showCopyButton` | `bool` | `true` | Show the copy-to-clipboard button. |
| `lineNumbers` | `bool` | `false` | Prefix each line with its number. |
| `maxHeight` | `double?` | `null` | Height before the block scrolls vertically. |

!!! note
    `language` does not change the highlighting today. The tokenizer uses one
    shared keyword set that covers common Dart, JavaScript, and TypeScript
    keywords.

## OiMarkdown

Renders a subset of Markdown to widgets. It handles headings, bold, italic,
inline code, links, unordered lists, and fenced code blocks. Fenced blocks
render through `OiCodeBlock`. Use it to display content you store as Markdown.

```dart
OiMarkdown(
  data: '# Title\n\nSome **bold** and `inline code`.\n\n- one\n- two',
)
```

Fenced blocks tagged `mermaid` get special handling. By default a placeholder is
shown. Pass `mermaidBuilder` to render diagrams yourself.

```dart
OiMarkdown(
  data: readme,
  enableMermaid: true,
  mermaidBuilder: (source) => MyMermaidWidget(source),
  onMermaidError: (error) => log(error),
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `data` | `String` | **required** | The Markdown source. |
| `style` | `TextStyle?` | `null` | Base text style override, merged over the default. |
| `codeBlockMaxWidth` | `double?` | `null` | Caps the width of rendered code blocks. |
| `enableMermaid` | `bool` | `true` | Route `mermaid` fences to `mermaidBuilder`. |
| `mermaidBuilder` | `Widget Function(String)?` | `null` | Renders a mermaid block. `null` shows a placeholder. |
| `onMermaidError` | `void Function(String)?` | `null` | Called if `mermaidBuilder` throws. |

!!! note
    This is a lightweight renderer, not a full CommonMark parser. It supports
    the elements listed above. Ordered lists, tables, and nested lists are not
    parsed. For editing, use `OiRichEditor`.

## OiDiffView

Renders a diff from a list of `OiDiffLine` entries. Added lines get a green
background and a `+` prefix. Removed lines get a red background and a `-`
prefix. The prefix means color is never the only signal.

```dart
OiDiffView(
  lines: const [
    OiDiffLine(content: 'final a = 1;', lineNumber: 1, unchanged: true),
    OiDiffLine(content: 'final b = 2;', lineNumber: 2, removed: true),
    OiDiffLine(content: 'final b = 3;', lineNumber: 2, added: true),
  ],
)
```

### Modes

```dart
// Unified: every line in one column (the default).
OiDiffView(lines: lines, mode: OiDiffMode.unified)

// Side by side: removed lines on the left, added on the right.
OiDiffView(lines: lines, mode: OiDiffMode.sideBySide)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `lines` | `List<OiDiffLine>` | **required** | The diff lines to render. |
| `mode` | `OiDiffMode` | `unified` | `unified` or `sideBySide`. |
| `showLineNumbers` | `bool` | `true` | Show line numbers in unified mode. |

Each `OiDiffLine` takes `content`, an optional `lineNumber`, and one of the
flags `added`, `removed`, or `unchanged`. `OiDiffView` does not compute the diff
for you. You build the line list from your own diff logic.

## OiKbd

Renders a keyboard shortcut as a row of small key chips. It maps logical key
names to the right glyph for the platform, so `meta` shows as the command symbol
on Apple devices and as `Ctrl` elsewhere. Common in menus and help text.

```dart
OiKbd(keys: const ['meta', 'shift', 'K'])
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `keys` | `List<String>` | **required** | Logical key names, in order. |

Recognized names are case-insensitive: `meta`, `ctrl`, `shift`, `alt`, `enter`,
`tab`, `esc`, `backspace`, `delete`, `up`, `down`, `left`, `right`, and `space`.
Any other string is shown as-is, capitalized. The joined names become the
screen-reader label, so `['meta', 'K']` reads as "meta + K".

## Related

- [Text Inputs](text-inputs.md) for plain and validated text fields.
- [Buttons & Actions](buttons.md) for the copy and toolbar buttons these editors use.
- [Search & Command](search-command.md) for the command bar where `OiKbd` shows shortcuts.
