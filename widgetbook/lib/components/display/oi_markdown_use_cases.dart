import 'package:flutter/material.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:widgetbook/widgetbook.dart';

import '../../helpers/knob_helpers.dart';

const _sampleMarkdown = '''# Heading 1

## Heading 2

This is a paragraph with **bold** and *italic* text, plus `inline code`.

- First item
- Second item
- Third item

```dart
void main() {
  print('Hello, World!');
}
```

[Link to docs](https://example.com)
''';

final oiMarkdownComponent = WidgetbookComponent(
  name: 'OiMarkdown',
  useCases: [
    WidgetbookUseCase(
      name: 'Playground',
      builder: (context) {
        final data = context.knobs.string(
          label: 'Markdown',
          initialValue: _sampleMarkdown,
        );

        return catalogWrapper(
          SizedBox(
            width: 500,
            child: OiMarkdown(data: data),
          ),
        );
      },
    ),
  ],
);
