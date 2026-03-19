import 'package:flutter/material.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_widgetbook/helpers/knob_helpers.dart';
import 'package:widgetbook/widgetbook.dart';

final _sampleMessages = [
  OiChatMessage(
    key: '1',
    senderId: 'user-1',
    senderName: 'Alice',
    content: 'Hey, has anyone reviewed the latest PR?',
    timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
  ),
  OiChatMessage(
    key: '2',
    senderId: 'user-2',
    senderName: 'Bob',
    content: 'Yes, I left a few comments. Looks good overall!',
    timestamp: DateTime.now().subtract(const Duration(minutes: 28)),
  ),
  OiChatMessage(
    key: '3',
    senderId: 'current-user',
    senderName: 'You',
    content: 'Great, I will address the feedback now.',
    timestamp: DateTime.now().subtract(const Duration(minutes: 25)),
  ),
  OiChatMessage(
    key: '4',
    senderId: 'user-2',
    senderName: 'Bob',
    content: 'Let me know if you need help with the API changes.',
    timestamp: DateTime.now().subtract(const Duration(minutes: 20)),
  ),
  OiChatMessage(
    key: '5',
    senderId: 'current-user',
    senderName: 'You',
    content: 'Will do, thanks!',
    timestamp: DateTime.now().subtract(const Duration(minutes: 18)),
  ),
];

final oiChatComponent = WidgetbookComponent(
  name: 'OiChat',
  useCases: [
    WidgetbookUseCase(
      name: 'Playground',
      builder: (context) {
        final showAvatars = context.knobs.boolean(
          label: 'Show Avatars',
          initialValue: true,
        );
        final showTimestamps = context.knobs.boolean(
          label: 'Show Timestamps',
          initialValue: true,
        );
        final enableReactions = context.knobs.boolean(
          label: 'Enable Reactions',
          initialValue: true,
        );
        final enableAttachments = context.knobs.boolean(
          label: 'Enable Attachments',
          initialValue: true,
        );
        final groupConsecutive = context.knobs.boolean(
          label: 'Group Consecutive',
          initialValue: true,
        );
        final showTyping = context.knobs.boolean(
          label: 'Show Typing Indicator',
        );

        return useCaseWrapper(
          SizedBox(
            height: 600,
            width: 500,
            child: OiChat(
              messages: _sampleMessages,
              currentUserId: 'current-user',
              label: 'Chat',
              showAvatars: showAvatars,
              showTimestamps: showTimestamps,
              enableReactions: enableReactions,
              enableAttachments: enableAttachments,
              groupConsecutive: groupConsecutive,
              typingUsers: showTyping ? const ['Alice'] : null,
              onSend: (_) {},
              onReact: (_, __) {},
            ),
          ),
        );
      },
    ),
  ],
);
