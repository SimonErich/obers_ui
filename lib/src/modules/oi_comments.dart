import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/display/oi_empty_state.dart';
import 'package:obers_ui/src/foundation/oi_icons.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/modules/oi_chat.dart';

/// A comment in the threaded comment system.
///
/// Supports nested replies, reactions, and edit state tracking.
class OiComment {
  /// Creates an [OiComment].
  const OiComment({
    required this.key,
    required this.authorId,
    required this.authorName,
    required this.content,
    required this.timestamp,
    this.authorAvatar,
    this.reactions,
    this.replies,
    this.edited = false,
  });

  /// Unique identifier for this comment.
  final Object key;

  /// The ID of the comment author.
  final String authorId;

  /// The display name of the author.
  final String authorName;

  /// Optional avatar URL of the author.
  final String? authorAvatar;

  /// The text content of the comment.
  final String content;

  /// When the comment was posted.
  final DateTime timestamp;

  /// Optional list of reactions on this comment.
  final List<OiReactionData>? reactions;

  /// Nested replies to this comment.
  final List<OiComment>? replies;

  /// Whether this comment has been edited.
  final bool edited;
}

/// A threaded comment system with reply, edit, delete, and reactions.
///
/// Renders a list of [OiComment] objects with nested replies indented up to
/// [maxDepth] levels. Includes a text input for posting new comments and
/// supports per-comment actions.
///
/// {@category Modules}
class OiComments extends StatefulWidget {
  /// Creates an [OiComments].
  const OiComments({
    required this.comments,
    required this.currentUserId,
    required this.label,
    super.key,
    this.onComment,
    this.onReply,
    this.onEdit,
    this.onDelete,
    this.onReact,
    this.maxDepth = 5,
    this.showAvatars = true,
    this.showTimestamps = true,
    this.emptyTitle = 'No comments yet',
    this.emptyDescription = 'Be the first to share your thoughts.',
  });

  /// The top-level comments to display.
  final List<OiComment> comments;

  /// The ID of the currently authenticated user.
  final String currentUserId;

  /// Accessibility label for the comments section.
  final String label;

  /// Called when the user posts a new top-level comment.
  final ValueChanged<String>? onComment;

  /// Called when the user replies to a comment.
  final void Function(OiComment parent, String content)? onReply;

  /// Called when the user edits a comment.
  final void Function(OiComment comment, String newContent)? onEdit;

  /// Called when the user deletes a comment.
  final ValueChanged<OiComment>? onDelete;

  /// Called when the user reacts to a comment.
  final void Function(OiComment comment, String emoji)? onReact;

  /// The maximum nesting depth for replies.
  final int maxDepth;

  /// Whether to show author avatars.
  final bool showAvatars;

  /// Whether to show comment timestamps.
  final bool showTimestamps;

  /// Title shown in the empty state when there are no comments.
  final String emptyTitle;

  /// Description shown in the empty state when there are no comments.
  final String emptyDescription;

  @override
  State<OiComments> createState() => _OiCommentsState();
}

class _OiCommentsState extends State<OiComments> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    widget.onComment?.call(text);
    _controller.clear();
  }

  String _formatTimestamp(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Comment list
          Expanded(
            child: widget.comments.isEmpty
                ? OiEmptyState(
                    icon: OiIcons.messageSquare,
                    title: widget.emptyTitle,
                    description: widget.emptyDescription,
                  )
                : ListView.builder(
                    padding: EdgeInsets.all(spacing.md),
                    itemCount: widget.comments.length,
                    itemBuilder: (context, index) =>
                        _buildComment(context, widget.comments[index], 0),
                  ),
          ),

          // Input bar
          Container(
            padding: EdgeInsets.all(spacing.sm),
            decoration: BoxDecoration(
              color: colors.surface,
              border: Border(top: BorderSide(color: colors.borderSubtle)),
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
                  onTap: _handleSubmit,
                  child: Semantics(
                    label: 'Post comment',
                    button: true,
                    child: Container(
                      padding: EdgeInsets.all(spacing.sm),
                      decoration: BoxDecoration(
                        color: colors.primary.base,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Post',
                        style: TextStyle(
                          color: colors.textOnPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
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

  Widget _buildComment(BuildContext context, OiComment comment, int depth) {
    final colors = context.colors;
    final spacing = context.spacing;

    return Padding(
      padding: EdgeInsets.only(left: depth * spacing.md, bottom: spacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Comment header
          Row(
            children: [
              if (widget.showAvatars)
                Padding(
                  padding: EdgeInsets.only(right: spacing.sm),
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: colors.primary.muted,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        comment.authorName.isNotEmpty
                            ? comment.authorName[0].toUpperCase()
                            : '?',
                        style: TextStyle(
                          color: colors.primary.base,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              Text(
                comment.authorName,
                style: TextStyle(
                  color: colors.text,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (widget.showTimestamps)
                Padding(
                  padding: EdgeInsets.only(left: spacing.sm),
                  child: Text(
                    _formatTimestamp(comment.timestamp),
                    style: TextStyle(color: colors.textMuted, fontSize: 11),
                  ),
                ),
              if (comment.edited)
                Padding(
                  padding: EdgeInsets.only(left: spacing.xs),
                  child: Text(
                    '(edited)',
                    style: TextStyle(
                      color: colors.textMuted,
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
            ],
          ),

          // Comment content
          Padding(
            padding: EdgeInsets.only(
              top: spacing.xs,
              left: widget.showAvatars ? 28.0 + spacing.sm : 0,
            ),
            child: Text(
              comment.content,
              style: TextStyle(color: colors.text, fontSize: 14),
            ),
          ),

          // Replies (up to maxDepth)
          if (comment.replies != null && depth < widget.maxDepth)
            Padding(
              padding: EdgeInsets.only(top: spacing.xs),
              child: Column(
                children: [
                  for (final reply in comment.replies!)
                    _buildComment(context, reply, depth + 1),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
