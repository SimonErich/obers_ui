import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/buttons/oi_button.dart';
import 'package:obers_ui/src/components/display/oi_badge.dart';
import 'package:obers_ui/src/components/display/oi_markdown.dart';
import 'package:obers_ui/src/components/display/oi_tooltip.dart';
import 'package:obers_ui/src/components/inputs/oi_text_input.dart';
import 'package:obers_ui/src/foundation/oi_icons.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/interaction/oi_tappable.dart';

// ---------------------------------------------------------------------------
// Data classes
// ---------------------------------------------------------------------------

/// The suggestion type determines selection behavior.
///
/// {@category Modules}
enum OiSuggestionType {
  /// Only one suggestion can be selected.
  single,

  /// Multiple suggestions can be selected.
  multi,
}

/// A suggestion chip attached to an assistant message.
///
/// {@category Modules}
@immutable
class OiChatSuggestion {
  /// Creates an [OiChatSuggestion].
  const OiChatSuggestion({
    required this.id,
    required this.text,
    this.type = OiSuggestionType.single,
    this.selected = false,
  });

  /// Unique identifier for this suggestion.
  final String id;

  /// The display text.
  final String text;

  /// Whether single or multi selection is allowed.
  final OiSuggestionType type;

  /// Whether this suggestion is currently selected.
  final bool selected;
}

/// An attachment (image, file, etc.) that can be shown above a message bubble.
///
/// {@category Modules}
@immutable
class OiChatAttachment {
  /// Creates an [OiChatAttachment].
  const OiChatAttachment({
    required this.id,
    required this.name,
    this.mimeType,
    this.thumbnailUrl,
    this.bytes,
  });

  /// Unique identifier for this attachment.
  final String id;

  /// Display name (file name or caption).
  final String name;

  /// MIME type (e.g. `'image/png'`, `'application/pdf'`).
  final String? mimeType;

  /// Optional thumbnail URL for image previews.
  final String? thumbnailUrl;

  /// Optional raw bytes for in-memory attachments.
  final Object? bytes;
}

/// A message in the [OiChatWindow] conversation.
///
/// {@category Modules}
@immutable
class OiChatWindowMessage {
  /// Creates an [OiChatWindowMessage].
  const OiChatWindowMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.timestamp,
    this.suggestions,
    this.selectedSuggestionIds,
    this.freeTextResponse,
    this.error = false,
    this.attachments,
    this.reactions,
  });

  /// Unique identifier for this message.
  final String id;

  /// The sender role — typically `'user'` or `'assistant'`.
  final String role;

  /// The message content in Markdown format.
  final String content;

  /// When the message was sent.
  final DateTime timestamp;

  /// Optional suggestion chips attached to this message.
  final List<OiChatSuggestion>? suggestions;

  /// IDs of the suggestions that were selected.
  final List<String>? selectedSuggestionIds;

  /// Optional free-text response to a suggestion prompt.
  final String? freeTextResponse;

  /// Whether this message represents an error.
  final bool error;

  /// Optional list of attachments (images, files) shown above the bubble.
  final List<OiChatAttachment>? attachments;

  /// Map of reaction emoji to the count of users who reacted.
  ///
  /// e.g. `{'👍': 2, '👎': 1}`.
  final Map<String, int>? reactions;
}

// ---------------------------------------------------------------------------
// Streaming cursor
// ---------------------------------------------------------------------------

class _StreamingCursor extends StatefulWidget {
  const _StreamingCursor({required this.color});

  final Color color;

  @override
  State<_StreamingCursor> createState() => _StreamingCursorState();
}

class _StreamingCursorState extends State<_StreamingCursor>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    unawaited(_controller.repeat(reverse: true));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _controller.value,
          child: Text(
            '\u258C', // ▌
            style: TextStyle(color: widget.color, fontSize: 16),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Main widget
// ---------------------------------------------------------------------------

/// An LLM-focused chat interface with streaming support and suggestion chips.
///
/// Displays a list of [OiChatWindowMessage] objects with user messages aligned
/// to the right and assistant messages aligned to the left. Supports real-time
/// streaming via [streamingContent] and [streaming], suggestion chips
/// attached to assistant messages, inline message reactions, copy-to-clipboard,
/// message editing, and a compose bar with optional actions.
///
/// {@category Modules}
class OiChatWindow extends StatefulWidget {
  /// Creates an [OiChatWindow].
  const OiChatWindow({
    required this.messages,
    required this.label,
    this.onSendMessage,
    this.streamingContent,
    this.streaming = false,
    this.inputPlaceholder = 'Type a message...',
    this.inputActions,
    this.inputMaxLines = 6,
    this.providerSelector,
    this.onNewSession,
    this.autoScrollToBottom = true,
    this.onScrollToTop,
    this.onSuggestionTap,
    this.onMessageReaction,
    this.onMessageEdit,
    this.submitOnEnter = false,
    super.key,
  });

  /// The list of messages to display.
  final List<OiChatWindowMessage> messages;

  /// Accessibility label for the chat window.
  final String label;

  /// Called when the user sends a text message.
  final void Function(String text)? onSendMessage;

  /// The content currently being streamed from the assistant.
  final String? streamingContent;

  /// Whether the assistant is currently streaming a response.
  final bool streaming;

  /// Placeholder text for the input field.
  final String inputPlaceholder;

  /// Optional action widgets shown beside the input.
  final List<Widget>? inputActions;

  /// Maximum lines for the text input before scrolling.
  final int inputMaxLines;

  /// Optional widget for selecting the LLM provider.
  final Widget? providerSelector;

  /// Called when the user starts a new session.
  final VoidCallback? onNewSession;

  /// Whether to auto-scroll to the latest message.
  final bool autoScrollToBottom;

  /// Called when the user scrolls to the top of the message list.
  final VoidCallback? onScrollToTop;

  /// Called when a suggestion chip is tapped.
  final void Function(OiChatWindowMessage message, OiChatSuggestion suggestion)?
  onSuggestionTap;

  /// Called when the user reacts to a message.
  ///
  /// `emoji` is the reaction string (e.g. `'👍'`). A positive or negative
  /// thumbs reaction is shown as a hover action on assistant messages.
  final void Function(OiChatWindowMessage message, String emoji)?
  onMessageReaction;

  /// Called when the user confirms an edit to a user message.
  ///
  /// When non-null, a pencil icon is shown on hover for user messages.
  /// The consumer is responsible for updating the message in the list.
  final void Function(OiChatWindowMessage message, String newContent)?
  onMessageEdit;

  /// When `true`, pressing Enter (without Shift) submits the message.
  ///
  /// When `false` (default), Cmd/Ctrl+Enter submits. This mirrors the
  /// preference of different LLM interfaces.
  final bool submitOnEnter;

  @override
  State<OiChatWindow> createState() => _OiChatWindowState();
}

class _OiChatWindowState extends State<OiChatWindow> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  /// The ID of the message currently being edited, or null.
  String? _editingMessageId;

  /// Controller for the inline edit input.
  final TextEditingController _editController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
  }

  @override
  void didUpdateWidget(OiChatWindow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.autoScrollToBottom &&
        widget.messages.length > oldWidget.messages.length) {
      _scrollToBottom();
    }
    if (widget.autoScrollToBottom &&
        widget.streaming &&
        widget.streamingContent != oldWidget.streamingContent) {
      _scrollToBottom();
    }
  }

  @override
  void dispose() {
    _inputController.dispose();
    _editController.dispose();
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    super.dispose();
  }

  void _handleScroll() {
    // In a reversed ListView, maxScrollExtent corresponds to the top
    // (oldest messages).
    if (_scrollController.hasClients &&
        _scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent) {
      widget.onScrollToTop?.call();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        unawaited(
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
          ),
        );
      }
    });
  }

  void _handleSend() {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;
    widget.onSendMessage?.call(text);
    _inputController.clear();
  }

  bool _shouldSubmitOnKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return false;
    if (event.logicalKey != LogicalKeyboardKey.enter) return false;
    final isShift = HardwareKeyboard.instance.isShiftPressed;
    final isMeta = HardwareKeyboard.instance.isMetaPressed;
    final isCtrl = HardwareKeyboard.instance.isControlPressed;
    if (widget.submitOnEnter) {
      return !isShift;
    } else {
      return isMeta || isCtrl;
    }
  }

  void _startEditing(OiChatWindowMessage message) {
    setState(() {
      _editingMessageId = message.id;
      _editController.text = message.content;
    });
  }

  void _confirmEdit(OiChatWindowMessage message) {
    final newContent = _editController.text.trim();
    if (newContent.isNotEmpty) {
      widget.onMessageEdit?.call(message, newContent);
    }
    setState(() => _editingMessageId = null);
    _editController.clear();
  }

  void _cancelEdit() {
    setState(() => _editingMessageId = null);
    _editController.clear();
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
          Expanded(child: _buildMessageList(context)),

          // Provider selector.
          if (widget.providerSelector != null)
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: spacing.sm,
                vertical: spacing.xs,
              ),
              child: widget.providerSelector,
            ),

          // Input area.
          Container(
            padding: EdgeInsets.all(spacing.sm),
            decoration: BoxDecoration(
              color: colors.surface,
              border: Border(top: BorderSide(color: colors.borderSubtle)),
            ),
            child: KeyboardListener(
              focusNode: FocusNode(),
              onKeyEvent: (event) {
                if (_shouldSubmitOnKeyEvent(event)) _handleSend();
              },
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (widget.inputActions != null)
                    ...widget.inputActions!.map(
                      (action) => Padding(
                        padding: EdgeInsets.only(right: spacing.xs),
                        child: action,
                      ),
                    ),
                  Expanded(
                    child: OiTextInput.multiline(
                      controller: _inputController,
                      placeholder: widget.inputPlaceholder,
                      maxLines: widget.inputMaxLines,
                      minLines: 1,
                      onSubmitted: (_) {
                        if (widget.submitOnEnter) _handleSend();
                      },
                    ),
                  ),
                  SizedBox(width: spacing.xs),
                  OiButton.primary(
                    label: 'Send',
                    icon: OiIcons.sendHorizontal,
                    onTap: widget.streaming ? null : _handleSend,
                    enabled: !widget.streaming,
                    size: OiButtonSize.small,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList(BuildContext context) {
    final spacing = context.spacing;

    return ListView.builder(
      controller: _scrollController,
      reverse: true,
      padding: EdgeInsets.all(spacing.sm),
      itemCount: widget.messages.length + (widget.streaming ? 1 : 0),
      itemBuilder: (context, index) {
        // In a reversed list, index 0 is the bottom-most (newest).
        // The streaming bubble appears at index 0 when streaming.
        if (widget.streaming && index == 0) {
          return _buildStreamingBubble(context);
        }

        final msgIndex = widget.streaming
            ? widget.messages.length - index
            : widget.messages.length - 1 - index;

        if (msgIndex < 0 || msgIndex >= widget.messages.length) {
          return const SizedBox.shrink();
        }

        return _buildMessageBubble(context, widget.messages[msgIndex]);
      },
    );
  }

  Widget _buildStreamingBubble(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final radius = context.radius;

    return Padding(
      padding: EdgeInsets.only(bottom: spacing.sm),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          padding: EdgeInsets.symmetric(
            horizontal: spacing.md,
            vertical: spacing.sm,
          ),
          decoration: BoxDecoration(
            color: colors.surfaceHover,
            borderRadius: radius.md,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.streamingContent != null &&
                  widget.streamingContent!.isNotEmpty)
                OiMarkdown(data: widget.streamingContent!),
              _StreamingCursor(color: colors.text),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(
    BuildContext context,
    OiChatWindowMessage message,
  ) {
    final colors = context.colors;
    final spacing = context.spacing;
    final radius = context.radius;
    final isUser = message.role == 'user';
    final isEditing = _editingMessageId == message.id;

    final bubbleColor = message.error
        ? colors.surfaceHover
        : isUser
        ? colors.primary.base
        : colors.surfaceHover;

    final textColor = isUser && !message.error
        ? colors.textOnPrimary
        : colors.text;

    final bubbleDecoration = BoxDecoration(
      color: bubbleColor,
      borderRadius: radius.md,
      border: message.error
          ? Border.all(color: colors.error.base, width: 1.5)
          : null,
    );

    // Attachments shown above the bubble.
    Widget? attachmentsRow;
    if (message.attachments != null && message.attachments!.isNotEmpty) {
      attachmentsRow = Padding(
        padding: EdgeInsets.only(bottom: spacing.xs),
        child: Wrap(
          spacing: spacing.xs,
          runSpacing: spacing.xs,
          alignment: isUser ? WrapAlignment.end : WrapAlignment.start,
          children: message.attachments!.map((a) {
            if (a.thumbnailUrl != null) {
              return ClipRRect(
                borderRadius: radius.sm,
                child: Image.network(
                  a.thumbnailUrl!,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) =>
                      _buildAttachmentChip(context, a, textColor: colors.text),
                ),
              );
            }
            return _buildAttachmentChip(context, a, textColor: colors.text);
          }).toList(),
        ),
      );
    }

    // Reactions row below the bubble.
    Widget? reactionsRow;
    if (message.reactions != null && message.reactions!.isNotEmpty) {
      reactionsRow = Padding(
        padding: EdgeInsets.only(top: spacing.xs),
        child: Wrap(
          spacing: spacing.xs,
          runSpacing: spacing.xs,
          children: message.reactions!.entries.map((entry) {
            return OiTappable(
              semanticLabel: '${entry.key} ${entry.value}',
              onTap: widget.onMessageReaction != null
                  ? () => widget.onMessageReaction!(message, entry.key)
                  : null,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.surfaceHover,
                  borderRadius: radius.full,
                  border: Border.all(color: colors.borderSubtle),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: spacing.xs,
                    vertical: 2,
                  ),
                  child: Text(
                    '${entry.key} ${entry.value}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      );
    }

    // Hover action bar (copy + reaction + edit).
    Widget buildHoverActions() {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Copy to clipboard.
          OiTooltip(
            label: 'Copy',
            message: 'Copy',
            child: OiTappable(
              semanticLabel: 'Copy message',
              onTap: () =>
                  Clipboard.setData(ClipboardData(text: message.content)),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Icon(OiIcons.copy, size: 14, color: colors.textMuted),
              ),
            ),
          ),
          // Reaction buttons (thumbs up / down for assistant messages).
          if (!isUser && widget.onMessageReaction != null) ...[
            OiTooltip(
              label: 'Good response',
              message: 'Good response',
              child: OiTappable(
                semanticLabel: 'Good response',
                onTap: () => widget.onMessageReaction!(message, '👍'),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Text(
                    '👍',
                    style: TextStyle(fontSize: 13, color: colors.textMuted),
                  ),
                ),
              ),
            ),
            OiTooltip(
              label: 'Bad response',
              message: 'Bad response',
              child: OiTappable(
                semanticLabel: 'Bad response',
                onTap: () => widget.onMessageReaction!(message, '👎'),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Text(
                    '👎',
                    style: TextStyle(fontSize: 13, color: colors.textMuted),
                  ),
                ),
              ),
            ),
          ],
          // Edit button (user messages only).
          if (isUser && widget.onMessageEdit != null)
            OiTooltip(
              label: 'Edit message',
              message: 'Edit message',
              child: OiTappable(
                semanticLabel: 'Edit message',
                onTap: () => _startEditing(message),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    OiIcons.pencil,
                    size: 14,
                    color: colors.textMuted,
                  ),
                ),
              ),
            ),
        ],
      );
    }

    Widget bubbleContent;
    if (isEditing) {
      bubbleContent = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          OiTextInput.multiline(
            controller: _editController,
            maxLines: 8,
            minLines: 2,
          ),
          SizedBox(height: spacing.xs),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              OiButton.primary(
                label: 'Save',
                onTap: () => _confirmEdit(message),
                size: OiButtonSize.small,
              ),
              SizedBox(width: spacing.xs),
              OiButton.ghost(
                label: 'Cancel',
                onTap: _cancelEdit,
                size: OiButtonSize.small,
              ),
            ],
          ),
        ],
      );
    } else {
      bubbleContent = OiMarkdown(
        data: message.content,
        style: TextStyle(color: textColor),
      );
    }

    return Padding(
      padding: EdgeInsets.only(bottom: spacing.sm),
      child: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: isUser
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Attachments row.
            ?attachmentsRow,

            // Bubble.
            _HoverActionWrapper(
              actionBar: buildHoverActions(),
              userAligned: isUser,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 600),
                padding: EdgeInsets.symmetric(
                  horizontal: spacing.md,
                  vertical: spacing.sm,
                ),
                decoration: bubbleDecoration,
                child: bubbleContent,
              ),
            ),

            // Reactions row.
            ?reactionsRow,

            // Suggestion chips.
            if (message.suggestions != null &&
                message.suggestions!.isNotEmpty) ...[
              SizedBox(height: spacing.xs),
              _buildSuggestionChips(context, message),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentChip(
    BuildContext context,
    OiChatAttachment attachment, {
    required Color textColor,
  }) {
    final colors = context.colors;
    final radius = context.radius;
    final spacing = context.spacing;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceHover,
        borderRadius: radius.sm,
        border: Border.all(color: colors.borderSubtle),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: spacing.xs,
          vertical: spacing.xs / 2,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(OiIcons.paperclip, size: 12, color: colors.textMuted),
            SizedBox(width: spacing.xs / 2),
            Text(
              attachment.name,
              style: TextStyle(fontSize: 11, color: colors.textMuted),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionChips(
    BuildContext context,
    OiChatWindowMessage message,
  ) {
    final spacing = context.spacing;
    final suggestions = message.suggestions!;
    final selectedIds = message.selectedSuggestionIds ?? const [];

    return Padding(
      padding: EdgeInsets.only(left: spacing.xs),
      child: Wrap(
        spacing: spacing.xs,
        runSpacing: spacing.xs,
        children: suggestions.map((suggestion) {
          final isSelected =
              selectedIds.contains(suggestion.id) || suggestion.selected;
          return OiTappable(
            onTap: widget.onSuggestionTap != null
                ? () => widget.onSuggestionTap!(message, suggestion)
                : null,
            child: OiBadge.soft(
              label: suggestion.text,
              color: isSelected ? OiBadgeColor.primary : OiBadgeColor.neutral,
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Hover action wrapper
// ---------------------------------------------------------------------------

/// Wraps [child] and shows [actionBar] on hover.
///
/// The action bar is positioned above user messages and below assistant
/// messages to avoid covering content.
class _HoverActionWrapper extends StatefulWidget {
  const _HoverActionWrapper({
    required this.child,
    required this.actionBar,
    required this.userAligned,
  });

  final Widget child;
  final Widget actionBar;
  final bool userAligned;

  @override
  State<_HoverActionWrapper> createState() => _HoverActionWrapperState();
}

class _HoverActionWrapperState extends State<_HoverActionWrapper> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final radius = context.radius;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          widget.child,
          if (_hovered)
            Positioned(
              top: -28,
              right: widget.userAligned ? 0 : null,
              left: widget.userAligned ? null : 0,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: radius.sm,
                  border: Border.all(color: colors.borderSubtle),
                  boxShadow: [
                    BoxShadow(
                      color: colors.overlay.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: widget.actionBar,
              ),
            ),
        ],
      ),
    );
  }
}
