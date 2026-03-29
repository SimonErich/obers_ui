import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/navigation/oi_emoji_picker.dart';
import 'package:obers_ui/src/foundation/oi_icons.dart';
import 'package:obers_ui/src/foundation/theme/oi_spacing_scale.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/gesture/oi_long_press_menu.dart';
import 'package:obers_ui/src/primitives/interaction/oi_tappable.dart';
import 'package:obers_ui/src/primitives/scroll/oi_infinite_scroll.dart';

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
    required this.content,
    required this.timestamp,
    this.senderAvatar,
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
/// On compact screens the interface fills the available space with the compose
/// bar positioned to stay above the software keyboard.
///
/// Long-pressing a message on touch devices shows a reaction picker when
/// [enableReactions] is `true`.
///
/// {@category Modules}
class OiChat extends StatefulWidget {
  /// Creates an [OiChat].
  const OiChat({
    required this.messages,
    required this.currentUserId,
    required this.label,
    super.key,
    this.onSend,
    this.onAttach,
    this.onReact,
    this.onLoadOlder,
    this.olderMessagesAvailable = false,
    this.typingUsers,
    this.showAvatars = true,
    this.showTimestamps = true,
    this.enableReactions = true,
    this.enableAttachments = true,
    this.enableRichText = false,
    this.groupConsecutive = true,
    this.consecutiveThreshold = const Duration(minutes: 2),
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
  final Future<void> Function()? onLoadOlder;

  /// Whether there are older messages available to load.
  final bool olderMessagesAvailable;

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

  /// Whether to group consecutive messages from the same sender.
  ///
  /// When `true`, consecutive messages from the same sender within
  /// [consecutiveThreshold] are visually grouped: only the first message
  /// in a group shows the avatar and sender name, while subsequent messages
  /// show only their content with reduced top spacing.
  final bool groupConsecutive;

  /// The maximum time gap between consecutive messages for them to be grouped.
  ///
  /// Only applies when [groupConsecutive] is `true`. Defaults to 2 minutes.
  final Duration consecutiveThreshold;

  @override
  State<OiChat> createState() => _OiChatState();
}

// Common emoji reactions for the long-press reaction picker.
const List<String> _kDefaultReactions = ['👍', '❤️', '😂', '😮', '😢', '🎉'];

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

  /// Whether the message at [index] is a continuation of a group started by
  /// a previous message (same sender, within the consecutive threshold).
  bool _isContinuation(int index) {
    if (!widget.groupConsecutive || index == 0) return false;
    final current = widget.messages[index];
    final previous = widget.messages[index - 1];
    if (current.senderId != previous.senderId) return false;
    return current.timestamp.difference(previous.timestamp).abs() <=
        widget.consecutiveThreshold;
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
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
          // Message list.
          Expanded(
            child: widget.messages.isEmpty
                ? Center(
                    child: Text(
                      'No messages yet',
                      style: TextStyle(color: colors.textMuted),
                    ),
                  )
                : _buildMessageList(spacing),
          ),

          // Typing indicator.
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

          // Input bar – hidden when the empty state is displayed.
          if (widget.messages.isNotEmpty)
            Container(
              padding: EdgeInsets.all(spacing.sm),
              decoration: BoxDecoration(
                color: colors.surface,
                border: Border(top: BorderSide(color: colors.borderSubtle)),
              ),
              child: Row(
                children: [
                  if (widget.enableAttachments) ...[
                    Semantics(
                      button: true,
                      label: 'Attach file',
                      child: OiTappable(
                        onTap: () => widget.onAttach?.call(const []),
                        child: Padding(
                          padding: EdgeInsets.only(right: spacing.xs),
                          child: Icon(
                            OiIcons.paperclip,
                            size: 22,
                            color: colors.textSubtle,
                          ),
                        ),
                      ),
                    ),
                  ],
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
                          OiIcons.sendHorizontal,
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

  Widget _buildMessageList(OiSpacingScale spacing) {
    final listView = ListView.builder(
      controller: _scrollController,
      reverse: true,
      padding: EdgeInsets.all(spacing.sm),
      itemCount: widget.messages.length,
      itemBuilder: (context, index) {
        final msgIndex = widget.messages.length - 1 - index;
        return _buildMessage(
          context,
          widget.messages[msgIndex],
          continuation: _isContinuation(msgIndex),
        );
      },
    );

    if (widget.onLoadOlder != null) {
      return OiInfiniteScroll(
        moreAvailable: widget.olderMessagesAvailable,
        onLoadMore: widget.onLoadOlder!,
        child: listView,
      );
    }

    return listView;
  }

  Widget _buildMessage(
    BuildContext context,
    OiChatMessage message, {
    bool continuation = false,
  }) {
    final colors = context.colors;
    final spacing = context.spacing;
    final ownMessage = message.senderId == widget.currentUserId;

    final bubbleColor = ownMessage ? colors.primary.base : colors.surfaceHover;
    final textColor = ownMessage ? colors.textOnPrimary : colors.text;

    final bubbleContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!ownMessage && !continuation)
          Padding(
            padding: EdgeInsets.only(bottom: spacing.xs),
            child: Text(
              message.senderName,
              style: TextStyle(
                color: ownMessage ? colors.textOnPrimary : colors.primary.base,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        Text(message.content, style: TextStyle(color: textColor, fontSize: 14)),
        // Attachments.
        if (message.attachments != null && message.attachments!.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(top: spacing.xs),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final file in message.attachments!)
                  _buildAttachmentChip(context, file, ownMessage),
              ],
            ),
          ),
        if (widget.showTimestamps)
          Padding(
            padding: EdgeInsets.only(top: spacing.xs),
            child: Text(
              _formatTime(message.timestamp),
              style: TextStyle(
                color: ownMessage
                    ? colors.textOnPrimary.withValues(alpha: 0.7)
                    : colors.textMuted,
                fontSize: 10,
              ),
            ),
          ),
      ],
    );

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
      child: bubbleContent,
    );

    final pendingWrapper = message.pending
        ? Opacity(opacity: 0.5, child: bubble)
        : bubble;

    // Reactions row below the bubble.
    final reactions = message.reactions;
    final reactionsWidget =
        widget.enableReactions && reactions != null && reactions.isNotEmpty
        ? Padding(
            padding: EdgeInsets.only(
              top: spacing.xs,
              left: ownMessage ? 0 : 4,
              right: ownMessage ? 4 : 0,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: ownMessage
                  ? MainAxisAlignment.end
                  : MainAxisAlignment.start,
              children: [
                for (final r in reactions) _buildReactionChip(context, r),
              ],
            ),
          )
        : null;

    // Wrap bubble with long-press menu for reactions.
    Widget messageBody;
    if (widget.enableReactions && widget.onReact != null) {
      messageBody = OiLongPressMenu(
        direction: Axis.horizontal,
        items: [
          for (final emoji in _kDefaultReactions)
            OiLongPressMenuItem(
              label: emoji,
              onTap: () => widget.onReact!.call(message, emoji),
            ),
        ],
        trailing: _MoreEmojiButton(
          onSelected: (emoji) => widget.onReact!.call(message, emoji),
        ),
        child: pendingWrapper,
      );
    } else {
      messageBody = pendingWrapper;
    }

    final showAvatar = widget.showAvatars && !ownMessage && !continuation;

    final avatar = showAvatar
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

    // Use reduced spacing for continuation messages within a group.
    final bottomSpacing = continuation ? spacing.sm : spacing.md;

    return Padding(
      padding: EdgeInsets.only(
        bottom: bottomSpacing,
        // Indent continuation messages to align with the bubble above the
        // avatar column (avatar 32 + right padding spacing.sm).
        left: continuation && widget.showAvatars && !ownMessage
            ? 32 + spacing.sm
            : 0,
      ),
      child: Row(
        mainAxisAlignment: ownMessage
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          ?avatar,
          Flexible(
            child: Column(
              crossAxisAlignment: ownMessage
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                messageBody,
                ?reactionsWidget,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReactionChip(BuildContext context, OiReactionData reaction) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: OiTappable(
        onTap: () => widget.onReact?.call(
          widget.messages.firstWhere(
            (m) => m.reactions?.contains(reaction) ?? false,
            orElse: () => widget.messages.first,
          ),
          reaction.emoji,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: reaction.reacted
                ? colors.primary.base.withValues(alpha: 0.15)
                : colors.surfaceHover,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: reaction.reacted
                  ? colors.primary.base.withValues(alpha: 0.4)
                  : colors.borderSubtle,
            ),
          ),
          child: Text(
            '${reaction.emoji} ${reaction.count}',
            style: TextStyle(fontSize: 11, color: colors.text),
          ),
        ),
      ),
    );
  }

  Widget _buildAttachmentChip(
    BuildContext context,
    OiFileData file,
    bool ownMessage,
  ) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: ownMessage
              ? colors.textOnPrimary.withValues(alpha: 0.15)
              : colors.surfaceHover,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              OiIcons.mail,
              size: 14,
              color: ownMessage ? colors.textOnPrimary : colors.textSubtle,
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                file.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  color: ownMessage ? colors.textOnPrimary : colors.text,
                ),
              ),
            ),
            const SizedBox(width: 4),
            Text(
              _formatFileSize(file.size),
              style: TextStyle(
                fontSize: 10,
                color: ownMessage
                    ? colors.textOnPrimary.withValues(alpha: 0.7)
                    : colors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _typingText(List<String> users) {
    if (users.length == 1) return '${users[0]} is typing...';
    if (users.length == 2) return '${users[0]} and ${users[1]} are typing...';
    return '${users[0]} and ${users.length - 1} others are typing...';
  }
}

/// A "+" button that opens the full [OiEmojiPicker] in an overlay.
class _MoreEmojiButton extends StatefulWidget {
  const _MoreEmojiButton({required this.onSelected});

  final ValueChanged<String> onSelected;

  @override
  State<_MoreEmojiButton> createState() => _MoreEmojiButtonState();
}

class _MoreEmojiButtonState extends State<_MoreEmojiButton> {
  OverlayEntry? _overlayEntry;

  void _showPicker() {
    _removeOverlay();
    final overlay = Overlay.maybeOf(context);
    if (overlay == null) return;

    final box = context.findRenderObject()! as RenderBox;
    final position = box.localToGlobal(Offset.zero);
    final colors = context.colors;

    _overlayEntry = OverlayEntry(
      builder: (_) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: _removeOverlay,
              child: const ColoredBox(color: Color(0x00000000)),
            ),
          ),
          Positioned(
            left: position.dx - 260,
            top: position.dy + box.size.height + 4,
            child: Container(
              width: 320,
              height: 360,
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: const BorderRadius.all(Radius.circular(8)),
                boxShadow: [
                  BoxShadow(
                    color: colors.overlay,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: OiEmojiPicker(
                onSelected: (emoji) {
                  _removeOverlay();
                  widget.onSelected(emoji);
                },
              ),
            ),
          ),
        ],
      ),
    );
    overlay.insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry?.dispose();
    _overlayEntry = null;
  }

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _showPicker,
      child: const Icon(OiIcons.smilePlus, size: 20, color: Color(0xFF888888)),
    );
  }
}
