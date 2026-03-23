import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_example/apps/component_library/shared/component_showcase_section.dart';

/// Showcase screen for typography and text-related widgets.
class TypographyScreen extends StatefulWidget {
  const TypographyScreen({super.key});

  @override
  State<TypographyScreen> createState() => _TypographyScreenState();
}

class _TypographyScreenState extends State<TypographyScreen> {
  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final colors = context.colors;

    return SingleChildScrollView(
      padding: EdgeInsets.all(spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── OiLabel ─────────────────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Label',
            widgetName: 'OiLabel',
            description:
                'The core text display primitive. Replaces Flutter Text widget '
                'with themed variants for consistent typography.',
            examples: [
              ComponentExample(
                title: 'All Variants',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const OiLabel.display('Display'),
                    SizedBox(height: spacing.sm),
                    const OiLabel.h1('Heading 1'),
                    SizedBox(height: spacing.sm),
                    const OiLabel.h2('Heading 2'),
                    SizedBox(height: spacing.sm),
                    const OiLabel.h3('Heading 3'),
                    SizedBox(height: spacing.sm),
                    const OiLabel.h4('Heading 4'),
                    SizedBox(height: spacing.sm),
                    const OiLabel.body('Body text for paragraphs and content.'),
                    SizedBox(height: spacing.sm),
                    const OiLabel.small(
                      'Small text for secondary information.',
                    ),
                    SizedBox(height: spacing.sm),
                    const OiLabel.tiny('Tiny text for fine print.'),
                    SizedBox(height: spacing.sm),
                    const OiLabel.caption(
                      'Caption text for media descriptions.',
                    ),
                    SizedBox(height: spacing.sm),
                    const OiLabel.code('final greeting = "Hello, world!";'),
                    SizedBox(height: spacing.sm),
                    const OiLabel.overline('OVERLINE TEXT'),
                    SizedBox(height: spacing.sm),
                    const OiLabel.link('Clickable link text'),
                  ],
                ),
              ),
              ComponentExample(
                title: 'Styled with Colors',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const OiLabel.body('Default text color'),
                    SizedBox(height: spacing.sm),
                    OiLabel.body('Primary color', color: colors.primary.base),
                    SizedBox(height: spacing.sm),
                    OiLabel.body('Subtle text', color: colors.textSubtle),
                    SizedBox(height: spacing.sm),
                    OiLabel.body('Muted text', color: colors.textMuted),
                    SizedBox(height: spacing.sm),
                    OiLabel.body('Success color', color: colors.success.base),
                    SizedBox(height: spacing.sm),
                    OiLabel.body('Error color', color: colors.error.base),
                    SizedBox(height: spacing.sm),
                    OiLabel.body('Warning color', color: colors.warning.base),
                  ],
                ),
              ),
              const ComponentExample(
                title: 'Truncation',
                child: SizedBox(
                  width: 200,
                  child: OiLabel.body(
                    'This is a very long text that will be truncated after '
                    'a single line to demonstrate the maxLines and overflow '
                    'parameters.',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),

          // ── OiCodeBlock ─────────────────────────────────────────────────
          const ComponentShowcaseSection(
            title: 'Code Block',
            widgetName: 'OiCodeBlock',
            description:
                'A syntax-highlighted code block with optional copy button '
                'and line numbers.',
            examples: [
              ComponentExample(
                title: 'Dart Code',
                child: OiCodeBlock(
                  language: 'dart',
                  code:
                      "import 'package:obers_ui/obers_ui.dart';\n"
                      '\n'
                      'void main() {\n'
                      '  final greeting = "Hello, ObersUI!";\n'
                      '  print(greeting);\n'
                      '}',
                ),
              ),
              ComponentExample(
                title: 'With Line Numbers',
                child: OiCodeBlock(
                  language: 'dart',
                  lineNumbers: true,
                  code:
                      'class Counter {\n'
                      '  int _value = 0;\n'
                      '\n'
                      '  int get value => _value;\n'
                      '\n'
                      '  void increment() => _value++;\n'
                      '}',
                ),
              ),
            ],
          ),

          // ── OiMarkdown ──────────────────────────────────────────────────
          const ComponentShowcaseSection(
            title: 'Markdown',
            widgetName: 'OiMarkdown',
            description:
                'Renders Markdown content with support for headings, bold, '
                'italic, code blocks, and links.',
            examples: [
              ComponentExample(
                title: 'Rich Markdown',
                child: OiMarkdown(
                  data:
                      '# Welcome to ObersUI\n'
                      '\n'
                      'A comprehensive Flutter UI library with **160+ widgets** '
                      'organized in a *4-tier architecture*.\n'
                      '\n'
                      '## Features\n'
                      '\n'
                      '- Zero Material/Cupertino dependency\n'
                      '- Theme-driven styling\n'
                      '- Built-in accessibility\n'
                      '\n'
                      'Use `OiLabel` instead of `Text` for all text display.\n'
                      '\n'
                      '```dart\n'
                      "OiButton.primary(label: 'Get Started', onTap: () {})\n"
                      '```',
                ),
              ),
            ],
          ),

          // ── OiDiffView ──────────────────────────────────────────────────
          const ComponentShowcaseSection(
            title: 'Diff View',
            widgetName: 'OiDiffView',
            description:
                'Displays a unified or side-by-side diff with color-coded '
                'additions and removals.',
            examples: [
              ComponentExample(
                title: 'Unified Diff',
                child: OiDiffView(
                  lines: [
                    OiDiffLine(
                      content: 'import "package:flutter/material.dart";',
                      lineNumber: 1,
                      removed: true,
                    ),
                    OiDiffLine(
                      content: 'import "package:obers_ui/obers_ui.dart";',
                      lineNumber: 1,
                      added: true,
                    ),
                    OiDiffLine(content: '', lineNumber: 2, unchanged: true),
                    OiDiffLine(
                      content: 'void main() {',
                      lineNumber: 3,
                      unchanged: true,
                    ),
                    OiDiffLine(
                      content: '  Text("Hello")',
                      lineNumber: 4,
                      removed: true,
                    ),
                    OiDiffLine(
                      content: '  OiLabel.body("Hello")',
                      lineNumber: 4,
                      added: true,
                    ),
                    OiDiffLine(content: '}', lineNumber: 5, unchanged: true),
                  ],
                ),
              ),
            ],
          ),

          // ── OiRelativeTime ──────────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Relative Time',
            widgetName: 'OiRelativeTime',
            description:
                'Displays a DateTime as a human-readable relative string. '
                'Auto-refreshes when live mode is enabled.',
            examples: [
              ComponentExample(
                title: 'Various Durations',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        OiLabel.small('5 min ago:', color: colors.textSubtle),
                        SizedBox(width: spacing.md),
                        OiRelativeTime(
                          dateTime: DateTime.now().subtract(
                            const Duration(minutes: 5),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: spacing.sm),
                    Row(
                      children: [
                        OiLabel.small('2 hours ago:', color: colors.textSubtle),
                        SizedBox(width: spacing.md),
                        OiRelativeTime(
                          dateTime: DateTime.now().subtract(
                            const Duration(hours: 2),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: spacing.sm),
                    Row(
                      children: [
                        OiLabel.small('3 days ago:', color: colors.textSubtle),
                        SizedBox(width: spacing.md),
                        OiRelativeTime(
                          dateTime: DateTime.now().subtract(
                            const Duration(days: 3),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              ComponentExample(
                title: 'Long Style',
                child: OiRelativeTime(
                  dateTime: DateTime.now().subtract(
                    const Duration(hours: 1, minutes: 30),
                  ),
                  style: OiRelativeTimeStyle.long,
                ),
              ),
              ComponentExample(
                title: 'Narrow Style',
                child: OiRelativeTime(
                  dateTime: DateTime.now().subtract(
                    const Duration(minutes: 45),
                  ),
                  style: OiRelativeTimeStyle.narrow,
                ),
              ),
            ],
          ),

          // ── OiCopyable ──────────────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Copyable',
            widgetName: 'OiCopyable',
            description:
                'Wraps any child widget so that tapping copies a value to the '
                'system clipboard.',
            examples: [
              ComponentExample(
                title: 'Tap to Copy',
                child: OiCopyable(
                  value: 'Hello, ObersUI!',
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const OiLabel.body('Hello, ObersUI!'),
                      SizedBox(width: spacing.sm),
                      OiLabel.small('(tap to copy)', color: colors.textMuted),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ── OiCopyButton ────────────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Copy Button',
            widgetName: 'OiCopyButton',
            description:
                'A tappable button that copies a value to the clipboard and '
                'shows brief visual feedback.',
            examples: [
              ComponentExample(
                title: 'Copy a Command',
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const OiLabel.code('flutter pub add obers_ui'),
                    SizedBox(width: spacing.sm),
                    const OiCopyButton(
                      value: 'flutter pub add obers_ui',
                      semanticLabel: 'Copy install command',
                    ),
                  ],
                ),
              ),
              ComponentExample(
                title: 'Copy an API Key',
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const OiLabel.code('sk-abc123xyz789'),
                    SizedBox(width: spacing.sm),
                    const OiCopyButton(
                      value: 'sk-abc123xyz789',
                      semanticLabel: 'Copy API key',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
