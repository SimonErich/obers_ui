import 'package:flutter/material.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_widgetbook/helpers/knob_helpers.dart';
import 'package:widgetbook/widgetbook.dart';

final _sampleMessages = [
  OiChatWindowMessage(
    id: '1',
    role: 'user',
    content: 'Can you help me design a login screen for my app?',
    timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
  ),
  OiChatWindowMessage(
    id: '2',
    role: 'assistant',
    content:
        'Of course! Here are a few approaches:\n\n'
        '1. **Minimal** - email + password with social login buttons\n'
        '2. **Branded** - full-bleed hero image with overlay form\n'
        '3. **Step-by-step** - progressive disclosure wizard\n\n'
        'Which style fits your brand best?',
    timestamp: DateTime.now().subtract(const Duration(minutes: 9)),
    suggestions: const [
      OiChatSuggestion(id: 'minimal', text: 'Minimal'),
      OiChatSuggestion(id: 'branded', text: 'Branded'),
      OiChatSuggestion(id: 'wizard', text: 'Step-by-step'),
    ],
  ),
  OiChatWindowMessage(
    id: '3',
    role: 'user',
    content: 'Let us go with the Minimal approach.',
    timestamp: DateTime.now().subtract(const Duration(minutes: 7)),
  ),
  OiChatWindowMessage(
    id: '4',
    role: 'assistant',
    content:
        'Great choice! I will generate a minimal login screen with:\n\n'
        '- Email input with validation\n'
        '- Password input with show/hide toggle\n'
        '- "Forgot password?" link\n'
        '- Primary sign-in button\n'
        '- Google and Apple social login options\n\n'
        'Give me a moment to create the layout...',
    timestamp: DateTime.now().subtract(const Duration(minutes: 6)),
  ),
];

final oiChatWindowComponent = WidgetbookComponent(
  name: 'OiChatWindow',
  useCases: [
    WidgetbookUseCase(
      name: 'Playground',
      builder: (context) {
        final isStreaming = context.knobs.boolean(label: 'Is Streaming');
        final showProviderSelector = context.knobs.boolean(
          label: 'Show Provider Selector',
        );

        return useCaseWrapper(
          SizedBox(
            width: 520,
            height: 600,
            child: OiChatWindow(
              label: 'AI Chat',
              messages: _sampleMessages,
              streaming: isStreaming,
              streamingContent: isStreaming
                  ? 'Here is the layout I am generating for you...'
                  : null,
              inputPlaceholder: 'Describe your design...',
              providerSelector: showProviderSelector
                  ? const OiBadge.soft(label: 'GPT-4o')
                  : null,
              onSendMessage: (_) {},
              onSuggestionTap: (_, __) {},
            ),
          ),
        );
      },
    ),
  ],
);
