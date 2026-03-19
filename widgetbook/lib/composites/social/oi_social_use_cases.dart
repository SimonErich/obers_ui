import 'package:flutter/material.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_widgetbook/helpers/knob_helpers.dart';
import 'package:widgetbook/widgetbook.dart';

final oiSocialComponent = WidgetbookComponent(
  name: 'Social',
  useCases: [
    WidgetbookUseCase(
      name: 'OiAvatarStack',
      builder: (context) {
        const users = [
          OiAvatarStackItem(label: 'Alice', initials: 'AL'),
          OiAvatarStackItem(label: 'Bob', initials: 'BO'),
          OiAvatarStackItem(label: 'Charlie', initials: 'CH'),
          OiAvatarStackItem(label: 'Diana', initials: 'DI'),
          OiAvatarStackItem(label: 'Eve', initials: 'EV'),
        ];
        return useCaseWrapper(const OiAvatarStack(users: users, maxVisible: 3));
      },
    ),
    WidgetbookUseCase(
      name: 'OiTypingIndicator',
      builder: (context) {
        return useCaseWrapper(
          const OiTypingIndicator(typingUsers: ['Alice', 'Bob']),
        );
      },
    ),
    WidgetbookUseCase(
      name: 'OiLiveRing',
      builder: (context) {
        return useCaseWrapper(
          const OiLiveRing(
            child: OiAvatar(semanticLabel: 'Live user', initials: 'LR'),
          ),
        );
      },
    ),
    WidgetbookUseCase(
      name: 'OiCursorPresence',
      builder: (context) {
        return useCaseWrapper(
          SizedBox(
            width: 300,
            height: 200,
            child: OiCursorPresence(
              cursors: [
                OiRemoteCursor(
                  userId: 'u1',
                  name: 'Alice',
                  color: const Color(0xFF2563EB),
                  position: const Offset(50, 80),
                  lastMoved: DateTime.now(),
                ),
                OiRemoteCursor(
                  userId: 'u2',
                  name: 'Bob',
                  color: const Color(0xFFDC2626),
                  position: const Offset(150, 120),
                  lastMoved: DateTime.now(),
                ),
              ],
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFD1D5DB)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(child: Text('Shared canvas')),
              ),
            ),
          ),
        );
      },
    ),
    WidgetbookUseCase(
      name: 'OiSelectionPresence',
      builder: (context) {
        return useCaseWrapper(
          const OiSelectionPresence(
            selections: [
              OiRemoteSelection(
                userId: 'u1',
                name: 'Alice',
                color: Color(0xFF2563EB),
                selectedKeys: {'item1'},
              ),
            ],
            child: Text('Selection presence wrapper'),
          ),
        );
      },
    ),
  ],
);
