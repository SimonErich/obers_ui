import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';

/// Reaction data for a chat message.
///
/// Represents a single emoji reaction with count and user state.
class OiReactionData {
  /// Creates an [OiReactionData].
  const OiReactionData({
    required this.emoji,
    required this.count,
    required this.reacted,
    this.reactorNames,
  });

  /// The emoji string.
  final String emoji;

  /// How many users reacted with this emoji.
  final int count;

  /// Whether the current user has reacted with this emoji.
  final bool reacted;

  /// Optional list of names who reacted.
  final List<String>? reactorNames;
}

/// File attachment data for a chat message.
///
/// Represents a file that can be attached to a message.
class OiFileData {
  /// Creates an [OiFileData].
  const OiFileData({
    required this.name,
    required this.size,
    this.mimeType = '',
    this.bytes,
    this.url,
  });

  /// The file name.
  final String name;

  /// The file size in bytes.
  final int size;

  /// The MIME type of the file.
  final String mimeType;

  /// Optional raw bytes of the file.
  final Object? bytes;

  /// Optional URL to the file.
  final String? url;
}

/// A chat message in the conversation.
///
/// Represents a single message with sender info, content, and metadata.
class OiChatMessage {
  /// Creates an [OiChatMessage].
  const OiChatMessage({
    required this.key,
    required this.senderId,
    required this.senderName,
    this.senderAvatar,
    required this.content,
    required this.timestamp,
    this.reactions,
    this.attachments,
    this.pending = false,
  });

  /// Unique identifier for this message.
  final Object key;

  /// The ID of the sender.
  final String senderId;

  /// The display name of the sender.
  final String senderName;

  /// Optional avatar URL of the sender.
  final String? senderAvatar;

  /// The text content of the message.
  final String content;

  /// When the message was sent.
  final DateTime timestamp;

  /// Optional list of reactions on this message.
  final List<OiReactionData>? reactions;

  /// Optional list of file attachments.
  final List<OiFileData>? attachments;

  /// Whether this message is still being sent.
  final bool pending;
}

/// A chat/messaging interface with message list, input bar, and typing
/// indicator.
///
/// Displays a list of [OiChatMessage] objects with the current user's messages
/// aligned to the right and others' messages aligned to the left. Includes a
/// text input bar at the bottom for composing new messages.
///
/// {@category Modules}
class OiChat extends StatefulWidget {
  /// Creates an [OiChat].
  const OiChat({
    super.key,
    required this.messages,
    required this.currentUserId,
    required this.label,
    this.onSend,
    this.onAttach,
    this.onReact,
    this.onLoadOlder,
    this.hasOlderMessages = false,
    this.typingUsers,
    this.showAvatars = true,
    this.showTimestamps = true,
    this.enableReactions = true,
    this.enableAttachments = true,
    this.enableRichText = false,
  });

  /// The list of chat messages to display.
  final List<OiChatMessage> messages;

  /// The ID of the currently authenticated user.
  final String currentUserId;

  /// Accessibility label for the chat interface.
  final String label;

  /// Called when the user sends a new message.
  final ValueChanged<String>? onSend;

  /// Called when the user attaches files.
  final ValueChanged<List<OiFileData>>? onAttach;

  /// Called when the user reacts to a message.
  final void Function(OiChatMessage, String emoji)? onReact;

  /// Called when the user scrolls to load older messages.
  final VoidCallback? onLoadOlder;

  /// Whether there are older messages available to load.
  final bool hasOlderMessages;

  /// List of user names currently typing.
  final List<String>? typingUsers;

  /// Whether to show sender avatars next to messages.
  final bool showAvatars;

  /// Whether to show timestamps on messages.
  final bool showTimestamps;

  /// Whether emoji reactions are enabled.
  final bool enableReactions;

  /// Whether file attachments are enabled.
  final bool enableAttachments;

  /// Whether rich text formatting is enabled.
  final bool enableRichText;

  @override
  State<OiChat> createState() => _OiChatState();
}

class _OiChatState extends State<OiChat> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    widget.onSend?.call(text);
    _controller.clear();
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;

    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: widget.label,
      child: Column(
        children: [
          // Message list
          Expanded(
            child: widget.messages.isEmpty
                ? Center(
                    child: Text(
                      'No messages yet',
                      style: TextStyle(color: colors.textMuted),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.all(spacing.sm),
                    itemCount: widget.messages.length,
                    itemBuilder: (context, index) =>
                        _buildMessage(context, widget.messages[index]),
                  ),
          ),

          // Typing indicator
          if (widget.typingUsers != null && widget.typingUsers!.isNotEmpty)
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: spacing.sm,
                vertical: spacing.xs,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _typingText(widget.typingUsers!),
                  style: TextStyle(
                    color: colors.textMuted,
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),

          // Input bar
          Container(
            padding: EdgeInsets.all(spacing.sm),
            decoration: BoxDecoration(
              color: colors.surface,
              border: Border(
                top: BorderSide(color: colors.borderSubtle),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: EditableText(
                    controller: _controller,
                    focusNode: FocusNode(),
                    style: TextStyle(color: colors.text, fontSize: 14),
                    cursorColor: colors.primary.base,
                    backgroundCursorColor: colors.surfaceHover,
                  ),
                ),
                SizedBox(width: spacing.sm),
                GestureDetector(
                  onTap: _handleSend,
                  child: Semantics(
                    container: true,
                    explicitChildNodes: true,
                    label: 'Send message',
                    button: true,
                    child: Container(
                      padding: EdgeInsets.all(spacing.sm),
                      decoration: BoxDecoration(
                        color: colors.primary.base,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        const IconData(0xe571, fontFamily: 'MaterialIcons'),
                        size: 20,
                        color: colors.textOnPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessage(BuildContext context, OiChatMessage message) {
    final colors = context.colors;
    final spacing = context.spacing;
    final isOwn = message.senderId == widget.currentUserId;

    final bubbleColor =
        isOwn ? colors.primary.base : colors.surfaceHover;
    final textColor =
        isOwn ? colors.textOnPrimary : colors.text;

    final bubble = Container(
      constraints: const BoxConstraints(maxWidth: 280),
      padding: EdgeInsets.symmetric(
        horizontal: spacing.sm + 4,
        vertical: spacing.sm,
      ),
      decoration: BoxDecoration(
        color: bubbleColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isOwn)
            Padding(
              padding: EdgeInsets.only(bottom: spacing.xs),
              child: Text(
                message.senderName,
                style: TextStyle(
                  color: isOwn ? colors.textOnPrimary : colors.primary.base,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          Text(
            message.content,
            style: TextStyle(color: textColor, fontSize: 14),
          ),
          if (widget.showTimestamps)
            Padding(
              padding: EdgeInsets.only(top: spacing.xs),
              child: Text(
                _formatTime(message.timestamp),
                style: TextStyle(
                  color: isOwn
                      ? colors.textOnPrimary.withValues(alpha: 0.7)
                      : colors.textMuted,
                  fontSize: 10,
                ),
              ),
            ),
        ],
      ),
    );

    final pendingWrapper = message.pending
        ? Opacity(opacity: 0.5, child: bubble)
        : bubble;

    final avatar = widget.showAvatars && !isOwn
        ? Padding(
            padding: EdgeInsets.only(right: spacing.sm),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: colors.primary.muted,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  message.senderName.isNotEmpty
                      ? message.senderName[0].toUpperCase()
                      : '?',
                  style: TextStyle(
                    color: colors.primary.base,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          )
        : null;

    return Padding(
      padding: EdgeInsets.only(bottom: spacing.sm),
      child: Row(
        mainAxisAlignment:
            isOwn ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (avatar != null) avatar,
          Flexible(child: pendingWrapper),
        ],
      ),
    );
  }

  String _typingText(List<String> users) {
    if (users.length == 1) return '${users[0]} is typing...';
    if (users.length == 2) return '${users[0]} and ${users[1]} are typing...';
    return '${users[0]} and ${users.length - 1} others are typing...';
  }
}
