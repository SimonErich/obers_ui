part of '../oi_chat_window.dart';

// ── Pure style helpers ────────────────────────────────────────────────────────

Color _messageBubbleTextColor(
  OiChatWindowMessage message,
  bool isUser,
  OiColorScheme colors,
) {
  if (isUser && !message.error) return colors.textOnPrimary;
  return colors.text;
}

BoxDecoration _messageBubbleDecoration(
  OiChatWindowMessage message,
  bool isUser,
  OiColorScheme colors,
  OiRadiusScale radius,
) {
  final bubbleColor = message.error
      ? colors.surfaceHover
      : isUser
      ? colors.primary.base
      : colors.surfaceHover;
  return BoxDecoration(
    color: bubbleColor,
    borderRadius: radius.md,
    border: message.error
        ? Border.all(color: colors.error.base, width: 1.5)
        : null,
  );
}

// ── Message list, bubbles, attachments, and suggestions ──────────────────────

extension _OiChatWindowMessages on _OiChatWindowState {
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

    final textColor = _messageBubbleTextColor(message, isUser, colors);
    final bubbleDecoration = _messageBubbleDecoration(
      message,
      isUser,
      colors,
      radius,
    );

    final attachmentsRow = _buildMessageAttachmentsRow(
      context,
      message,
      isUser,
    );
    final reactionsRow = _buildMessageReactionsRow(context, message);

    final bubbleContent = isEditing
        ? _buildMessageEditContent(context, message)
        : OiMarkdown(
            data: message.content,
            style: TextStyle(color: textColor),
          );

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
            ?attachmentsRow,
            _HoverActionWrapper(
              actionBar: _buildMessageHoverActions(context, message, isUser),
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
            ?reactionsRow,
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

  Widget _buildMessageEditContent(
    BuildContext context,
    OiChatWindowMessage message,
  ) {
    final spacing = context.spacing;
    return Column(
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
  }

  Widget? _buildMessageAttachmentsRow(
    BuildContext context,
    OiChatWindowMessage message,
    bool isUser,
  ) {
    if (message.attachments == null || message.attachments!.isEmpty) {
      return null;
    }
    final colors = context.colors;
    final spacing = context.spacing;
    final radius = context.radius;

    return Padding(
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
                errorBuilder: (_, _, _) => _buildAttachmentChip(context, a),
              ),
            );
          }
          return _buildAttachmentChip(context, a);
        }).toList(),
      ),
    );
  }

  Widget? _buildMessageReactionsRow(
    BuildContext context,
    OiChatWindowMessage message,
  ) {
    if (message.reactions == null || message.reactions!.isEmpty) {
      return null;
    }
    final colors = context.colors;
    final spacing = context.spacing;
    final radius = context.radius;

    return Padding(
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

  Widget _buildMessageHoverActions(
    BuildContext context,
    OiChatWindowMessage message,
    bool isUser,
  ) {
    final colors = context.colors;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
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

  Widget _buildAttachmentChip(
    BuildContext context,
    OiChatAttachment attachment,
  ) {
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
