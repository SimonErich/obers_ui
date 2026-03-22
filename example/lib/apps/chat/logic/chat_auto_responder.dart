import 'dart:async';
import 'dart:math';

import 'package:flutter/widgets.dart';

import 'package:obers_ui_example/data/mock_chat.dart';
import 'package:obers_ui_example/data/mock_users.dart';

/// Timer-based auto-response engine for the chat demo.
///
/// When triggered, waits briefly, shows a typing indicator, then posts a
/// contextual auto-reply from a random team member.
class ChatAutoResponder {
  ChatAutoResponder({
    required this.onTypingChange,
    required this.onResponse,
  });

  /// Called to update the list of currently-typing user names.
  final ValueChanged<List<String>> onTypingChange;

  /// Called when the auto-responder has produced a reply.
  final void Function(String senderId, String senderName, String content)
      onResponse;

  final _random = Random();
  Timer? _typingTimer;
  Timer? _responseTimer;

  /// Trigger an auto-response to [incomingMessage].
  ///
  /// Picks a random team member (excluding the current user and [senderId])
  /// and responds with a contextual message after a short delay.
  void trigger(String incomingMessage, String senderId) {
    // Cancel any pending timers from a previous trigger.
    _typingTimer?.cancel();
    _responseTimer?.cancel();

    // Pick a random responder from the core team, excluding the current user
    // and the sender of the incoming message.
    final candidates = kCoreTeam
        .where((u) => u.id != kCurrentUser.id && u.id != senderId)
        .toList();
    if (candidates.isEmpty) return;
    final responder = candidates[_random.nextInt(candidates.length)];

    // Phase 1: After 1.5s, show typing indicator.
    _typingTimer = Timer(const Duration(milliseconds: 1500), () {
      onTypingChange([responder.name]);

      // Phase 2: After 2s more, deliver the response and clear typing.
      _responseTimer = Timer(const Duration(milliseconds: 2000), () {
        onTypingChange([]);
        final content = pickAutoResponse(incomingMessage);
        onResponse(responder.id, responder.name, content);
      });
    });
  }

  /// Cancel pending timers.
  void dispose() {
    _typingTimer?.cancel();
    _responseTimer?.cancel();
  }
}
