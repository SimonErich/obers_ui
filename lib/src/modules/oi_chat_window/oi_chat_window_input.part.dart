part of '../oi_chat_window.dart';

// ── Input area ───────────────────────────────────────────────────────────────

extension _OiChatWindowInput on _OiChatWindowState {
  Widget _buildInputArea(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;

    return Container(
      padding: EdgeInsets.all(spacing.sm),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(top: BorderSide(color: colors.borderSubtle)),
      ),
      child: KeyboardListener(
        focusNode: _keyboardFocusNode,
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
            ),
          ],
        ),
      ),
    );
  }
}
