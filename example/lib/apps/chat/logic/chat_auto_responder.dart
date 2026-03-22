import 'dart:async';
import 'dart:math';

import 'package:flutter/widgets.dart';

import 'package:obers_ui_example/data/mock_chat.dart';
import 'package:obers_ui_example/data/mock_users.dart';

/// Timer-based auto-response engine for the chat demo.
///
/// When triggered, waits briefly, shows a typing indicator, then posts a
/// contextual auto-reply from a random team member. There is a 20% chance
/// that a second team member will also respond shortly after.
class ChatAutoResponder {
  ChatAutoResponder({required this.onTypingChange, required this.onResponse});

  /// Called to update the list of currently-typing user names.
  final ValueChanged<List<String>> onTypingChange;

  /// Called when the auto-responder has produced a reply.
  final void Function(String senderId, String senderName, String content)
  onResponse;

  final _random = Random();
  Timer? _typingTimer;
  Timer? _responseTimer;
  Timer? _secondTypingTimer;
  Timer? _secondResponseTimer;

  /// Trigger an auto-response to [incomingMessage].
  ///
  /// Picks a random team member (excluding the current user and [senderId])
  /// and responds with a contextual message after a short delay. There is a
  /// ~20% chance that a second, different team member will follow up 2-5
  /// seconds after the first response.
  void trigger(String incomingMessage, String senderId) {
    // Cancel any pending timers from a previous trigger.
    _cancelAll();

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

        // Phase 3: 20% chance of a second responder.
        _maybeSecondResponse(
          incomingMessage: incomingMessage,
          senderId: senderId,
          firstResponderId: responder.id,
        );
      });
    });
  }

  /// With ~20% probability, triggers a second response from a different team
  /// member after a random 2-5 second delay.
  void _maybeSecondResponse({
    required String incomingMessage,
    required String senderId,
    required String firstResponderId,
  }) {
    if (_random.nextDouble() >= 0.2) return;

    // Pick a different team member (not the user, not the first responder).
    final candidates = kCoreTeam
        .where(
          (u) =>
              u.id != kCurrentUser.id &&
              u.id != senderId &&
              u.id != firstResponderId,
        )
        .toList();
    if (candidates.isEmpty) return;
    final secondResponder = candidates[_random.nextInt(candidates.length)];

    // Wait 2-5 seconds before showing the second typing indicator.
    final delayMs = 2000 + _random.nextInt(3001); // 2000..5000
    _secondTypingTimer = Timer(Duration(milliseconds: delayMs), () {
      onTypingChange([secondResponder.name]);

      // After 1-2 more seconds, deliver the second response.
      final typingMs = 1000 + _random.nextInt(1001); // 1000..2000
      _secondResponseTimer = Timer(Duration(milliseconds: typingMs), () {
        onTypingChange([]);
        final content = pickAutoResponse(incomingMessage);
        onResponse(secondResponder.id, secondResponder.name, content);
      });
    });
  }

  void _cancelAll() {
    _typingTimer?.cancel();
    _responseTimer?.cancel();
    _secondTypingTimer?.cancel();
    _secondResponseTimer?.cancel();
  }

  /// Cancel pending timers.
  void dispose() {
    _cancelAll();
  }
}
