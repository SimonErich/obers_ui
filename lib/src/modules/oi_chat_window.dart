import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/buttons/oi_button.dart';
import 'package:obers_ui/src/components/display/oi_badge.dart';
import 'package:obers_ui/src/components/display/oi_markdown.dart';
import 'package:obers_ui/src/components/display/oi_tooltip.dart';
import 'package:obers_ui/src/components/inputs/oi_text_input.dart';
import 'package:obers_ui/src/foundation/oi_icons.dart';
import 'package:obers_ui/src/foundation/theme/oi_color_scheme.dart';
import 'package:obers_ui/src/foundation/theme/oi_radius_scale.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/interaction/oi_tappable.dart';

part 'oi_chat_window/oi_chat_window_widgets.part.dart';
part 'oi_chat_window/oi_chat_window_input.part.dart';
part 'oi_chat_window/oi_chat_window_messages.part.dart';

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
  final TextEditingController _editController = TextEditingController();
  final FocusNode _keyboardFocusNode = FocusNode();

  /// The ID of the message currently being edited, or null.
  String? _editingMessageId;

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
    _keyboardFocusNode.dispose();
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
          _buildInputArea(context),
        ],
      ),
    );
  }
}
