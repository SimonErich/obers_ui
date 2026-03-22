import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';
// The barrel hides OiReactionData (chat variant) and OiFileData.
// OiChatMessage.reactions expects the chat-module variant, so import directly.
// ignore: implementation_imports
import 'package:obers_ui/src/modules/oi_chat.dart' as chat;

import 'package:obers_ui_example/apps/chat/logic/chat_auto_responder.dart';
import 'package:obers_ui_example/data/mock_chat.dart';
import 'package:obers_ui_example/data/mock_users.dart';
import 'package:obers_ui_example/shell/showcase_shell.dart';
import 'package:obers_ui_example/theme/theme_state.dart';

/// Chat mini-app with channels, reactions, and auto-replies.
class ChatApp extends StatefulWidget {
  const ChatApp({required this.themeState, super.key});

  final ThemeState themeState;

  @override
  State<ChatApp> createState() => _ChatAppState();
}

class _ChatAppState extends State<ChatApp> {
  String _activeChannelId = kChannels.first.id;
  final Map<String, List<OiChatMessage>> _channelMessages = {};
  final Map<String, int> _unreadCounts = {};
  List<String> _typingUsers = [];
  late ChatAutoResponder _autoResponder;
  int _messageCounter = 0;

  @override
  void initState() {
    super.initState();

    // Pre-populate messages for every channel.
    for (final channel in kChannels) {
      _channelMessages[channel.id] = buildChannelMessages(channel.id);
      _unreadCounts[channel.id] = channel.unreadCount;
    }

    _autoResponder = ChatAutoResponder(
      onTypingChange: (users) {
        if (mounted) setState(() => _typingUsers = users);
      },
      onResponse: (senderId, senderName, content) {
        if (!mounted) return;
        setState(() {
          _messageCounter++;
          _channelMessages[_activeChannelId]!.add(
            OiChatMessage(
              key: 'auto-$_messageCounter',
              senderId: senderId,
              senderName: senderName,
              content: content,
              timestamp: DateTime.now(),
            ),
          );
        });
      },
    );
  }

  @override
  void dispose() {
    _autoResponder.dispose();
    super.dispose();
  }

  void _onSend(String text) {
    setState(() {
      _messageCounter++;
      _channelMessages[_activeChannelId]!.add(
        OiChatMessage(
          key: 'sent-$_messageCounter',
          senderId: kCurrentUser.id,
          senderName: kCurrentUser.name,
          content: text,
          timestamp: DateTime.now(),
        ),
      );
    });
    _autoResponder.trigger(text, kCurrentUser.id);
  }

  void _onReact(OiChatMessage message, String emoji) {
    setState(() {
      final messages = _channelMessages[_activeChannelId]!;
      final index = messages.indexWhere((m) => m.key == message.key);
      if (index < 0) return;

      final existing = messages[index];
      final reactions =
          List<chat.OiReactionData>.from(existing.reactions ?? []);

      final reactionIndex = reactions.indexWhere((r) => r.emoji == emoji);
      if (reactionIndex >= 0) {
        final r = reactions[reactionIndex];
        if (r.reacted) {
          // Remove our reaction.
          if (r.count <= 1) {
            reactions.removeAt(reactionIndex);
          } else {
            reactions[reactionIndex] = chat.OiReactionData(
              emoji: r.emoji,
              count: r.count - 1,
              reacted: false,
              reactorNames: r.reactorNames,
            );
          }
        } else {
          // Add our reaction.
          reactions[reactionIndex] = chat.OiReactionData(
            emoji: r.emoji,
            count: r.count + 1,
            reacted: true,
            reactorNames: r.reactorNames,
          );
        }
      } else {
        // Brand new reaction.
        reactions.add(
          chat.OiReactionData(
            emoji: emoji,
            count: 1,
            reacted: true,
            reactorNames: [kCurrentUser.name],
          ),
        );
      }

      messages[index] = OiChatMessage(
        key: existing.key,
        senderId: existing.senderId,
        senderName: existing.senderName,
        content: existing.content,
        timestamp: existing.timestamp,
        senderAvatar: existing.senderAvatar,
        reactions: reactions,
        attachments: existing.attachments,
        pending: existing.pending,
      );
    });
  }

  void _selectChannel(String channelId) {
    setState(() {
      _activeChannelId = channelId;
      _unreadCounts[channelId] = 0;
      _typingUsers = [];
    });
    _autoResponder.dispose();
    _autoResponder = ChatAutoResponder(
      onTypingChange: (users) {
        if (mounted) setState(() => _typingUsers = users);
      },
      onResponse: (senderId, senderName, content) {
        if (!mounted) return;
        setState(() {
          _messageCounter++;
          _channelMessages[_activeChannelId]!.add(
            OiChatMessage(
              key: 'auto-$_messageCounter',
              senderId: senderId,
              senderName: senderName,
              content: content,
              timestamp: DateTime.now(),
            ),
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ShowcaseShell(
      title: 'Chat',
      themeState: widget.themeState,
      child: OiSplitPane(
        initialRatio: 0.22,
        minRatio: 0.15,
        maxRatio: 0.35,
        leading: _buildChannelSidebar(context),
        trailing: OiChat(
          label: 'Chat messages',
          messages: _channelMessages[_activeChannelId] ?? [],
          currentUserId: kCurrentUser.id,
          onSend: _onSend,
          onReact: _onReact,
          typingUsers: _typingUsers.isNotEmpty ? _typingUsers : null,
        ),
      ),
    );
  }

  Widget _buildChannelSidebar(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;

    return ColoredBox(
      color: colors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.all(spacing.md),
            child: const OiLabel.h4('Channels'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: kChannels.length,
              itemBuilder: (context, index) {
                final channel = kChannels[index];
                final isActive = channel.id == _activeChannelId;
                final unread = _unreadCounts[channel.id] ?? 0;

                return OiTappable(
                  semanticLabel: 'Select channel ${channel.name}',
                  onTap: () => _selectChannel(channel.id),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: spacing.md,
                      vertical: spacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: isActive ? colors.primary.muted : null,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              OiLabel.body(
                                channel.name,
                                color: isActive
                                    ? colors.primary.base
                                    : colors.text,
                              ),
                              OiLabel.caption(
                                channel.description,
                                color: colors.textMuted,
                              ),
                            ],
                          ),
                        ),
                        if (unread > 0)
                          OiBadge.soft(
                            label: '$unread',
                            size: OiBadgeSize.small,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
