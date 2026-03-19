import 'package:flutter/material.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:widgetbook/widgetbook.dart';

import '../helpers/knob_helpers.dart';

final _sampleComments = [
  OiComment(
    key: '1',
    authorId: 'user-1',
    authorName: 'Alice',
    content: 'This looks great! I love the new color scheme.',
    timestamp: DateTime.now().subtract(const Duration(hours: 2)),
    replies: [
      OiComment(
        key: '1-1',
        authorId: 'user-2',
        authorName: 'Bob',
        content: 'Agreed, the contrast is much better now.',
        timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 45)),
      ),
      OiComment(
        key: '1-2',
        authorId: 'current-user',
        authorName: 'You',
        content: 'Thanks! Took a while to get the palette right.',
        timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
        edited: true,
      ),
    ],
  ),
  OiComment(
    key: '2',
    authorId: 'user-3',
    authorName: 'Carol',
    content: 'Could we add a dark mode variant as well?',
    timestamp: DateTime.now().subtract(const Duration(hours: 1)),
  ),
  OiComment(
    key: '3',
    authorId: 'user-2',
    authorName: 'Bob',
    content: 'I noticed a small alignment issue on mobile. See screenshot.',
    timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
  ),
];

final oiCommentsComponent = WidgetbookComponent(
  name: 'OiComments',
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
        final maxDepth = context.knobs.int.slider(
          label: 'Max Reply Depth',
          initialValue: 5,
          min: 1,
          max: 10,
        );

        return useCaseWrapper(
          SizedBox(
            height: 600,
            width: 500,
            child: OiComments(
              comments: _sampleComments,
              currentUserId: 'current-user',
              label: 'Comments',
              showAvatars: showAvatars,
              showTimestamps: showTimestamps,
              maxDepth: maxDepth,
              onComment: (_) {},
              onReply: (_, __) {},
              onEdit: (_, __) {},
              onDelete: (_) {},
              onReact: (_, __) {},
            ),
          ),
        );
      },
    ),
    WidgetbookUseCase(
      name: 'Empty State',
      builder: (context) {
        return useCaseWrapper(
          SizedBox(
            height: 400,
            width: 500,
            child: OiComments(
              comments: const [],
              currentUserId: 'current-user',
              label: 'Empty comments',
              onComment: (_) {},
            ),
          ),
        );
      },
    ),
  ],
);
