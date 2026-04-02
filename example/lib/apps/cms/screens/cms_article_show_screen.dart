import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';
// OiComment.reactions expects the chat-module OiReactionData (with `reacted`).
// ignore: implementation_imports
import 'package:obers_ui/src/modules/oi_chat.dart' as chat;

import 'package:obers_ui_example/data/mock_cms.dart';
import 'package:obers_ui_example/data/mock_users.dart';

/// Article detail screen with metadata, markdown content, and threaded
/// comments with full interactivity.
class CmsArticleShowScreen extends StatefulWidget {
  const CmsArticleShowScreen({
    required this.article,
    required this.onEdit,
    required this.onBack,
    super.key,
  });

  final MockBlogPost article;
  final VoidCallback onEdit;
  final VoidCallback onBack;

  @override
  State<CmsArticleShowScreen> createState() => _CmsArticleShowScreenState();
}

class _CmsArticleShowScreenState extends State<CmsArticleShowScreen> {
  late List<OiComment> _comments;
  int _nextKey = 100;

  @override
  void initState() {
    super.initState();
    _comments = buildBlogComments();
  }

  // ── Comment callbacks ─────────────────────────────────────────────────────

  void _onComment(String content) {
    setState(() {
      _comments = [
        ..._comments,
        OiComment(
          key: 'c-new-${_nextKey++}',
          authorId: kCurrentUser.id,
          authorName: kCurrentUser.name,
          content: content,
          timestamp: DateTime.now(),
        ),
      ];
    });
  }

  void _onReply(OiComment parent, String content) {
    final reply = OiComment(
      key: 'c-reply-${_nextKey++}',
      authorId: kCurrentUser.id,
      authorName: kCurrentUser.name,
      content: content,
      timestamp: DateTime.now(),
    );
    setState(() {
      _comments = _addReply(_comments, parent.key, reply);
    });
  }

  void _onEdit(OiComment comment, String newContent) {
    setState(() {
      _comments = _editComment(_comments, comment.key, newContent);
    });
  }

  void _onDelete(OiComment comment) {
    setState(() {
      _comments = _removeComment(_comments, comment.key);
    });
  }

  void _onReact(OiComment comment, String emoji) {
    setState(() {
      _comments = _toggleReaction(_comments, comment.key, emoji);
    });
  }

  // ── Tree helpers ──────────────────────────────────────────────────────────

  List<OiComment> _addReply(
    List<OiComment> comments,
    Object parentKey,
    OiComment reply,
  ) {
    return comments.map((c) {
      if (c.key == parentKey) {
        return OiComment(
          key: c.key,
          authorId: c.authorId,
          authorName: c.authorName,
          authorAvatar: c.authorAvatar,
          content: c.content,
          timestamp: c.timestamp,
          reactions: c.reactions,
          edited: c.edited,
          replies: [...?c.replies, reply],
        );
      }
      if (c.replies != null && c.replies!.isNotEmpty) {
        return OiComment(
          key: c.key,
          authorId: c.authorId,
          authorName: c.authorName,
          authorAvatar: c.authorAvatar,
          content: c.content,
          timestamp: c.timestamp,
          reactions: c.reactions,
          edited: c.edited,
          replies: _addReply(c.replies!, parentKey, reply),
        );
      }
      return c;
    }).toList();
  }

  List<OiComment> _editComment(
    List<OiComment> comments,
    Object key,
    String newContent,
  ) {
    return comments.map((c) {
      if (c.key == key) {
        return OiComment(
          key: c.key,
          authorId: c.authorId,
          authorName: c.authorName,
          authorAvatar: c.authorAvatar,
          content: newContent,
          timestamp: c.timestamp,
          reactions: c.reactions,
          edited: true,
          replies: c.replies,
        );
      }
      if (c.replies != null && c.replies!.isNotEmpty) {
        return OiComment(
          key: c.key,
          authorId: c.authorId,
          authorName: c.authorName,
          authorAvatar: c.authorAvatar,
          content: c.content,
          timestamp: c.timestamp,
          reactions: c.reactions,
          edited: c.edited,
          replies: _editComment(c.replies!, key, newContent),
        );
      }
      return c;
    }).toList();
  }

  List<OiComment> _removeComment(List<OiComment> comments, Object key) {
    final result = <OiComment>[];
    for (final c in comments) {
      if (c.key == key) continue;
      if (c.replies != null && c.replies!.isNotEmpty) {
        result.add(
          OiComment(
            key: c.key,
            authorId: c.authorId,
            authorName: c.authorName,
            authorAvatar: c.authorAvatar,
            content: c.content,
            timestamp: c.timestamp,
            reactions: c.reactions,
            edited: c.edited,
            replies: _removeComment(c.replies!, key),
          ),
        );
      } else {
        result.add(c);
      }
    }
    return result;
  }

  List<OiComment> _toggleReaction(
    List<OiComment> comments,
    Object key,
    String emoji,
  ) {
    return comments.map((c) {
      if (c.key == key) {
        final existing = List<chat.OiReactionData>.from(c.reactions ?? []);
        final idx = existing.indexWhere((r) => r.emoji == emoji);
        if (idx >= 0) {
          final r = existing[idx];
          if (r.reacted) {
            if (r.count <= 1) {
              existing.removeAt(idx);
            } else {
              existing[idx] = chat.OiReactionData(
                emoji: r.emoji,
                count: r.count - 1,
                reacted: false,
              );
            }
          } else {
            existing[idx] = chat.OiReactionData(
              emoji: r.emoji,
              count: r.count + 1,
              reacted: true,
            );
          }
        } else {
          existing.add(
            chat.OiReactionData(emoji: emoji, count: 1, reacted: true),
          );
        }
        return OiComment(
          key: c.key,
          authorId: c.authorId,
          authorName: c.authorName,
          authorAvatar: c.authorAvatar,
          content: c.content,
          timestamp: c.timestamp,
          reactions: existing,
          edited: c.edited,
          replies: c.replies,
        );
      }
      if (c.replies != null && c.replies!.isNotEmpty) {
        return OiComment(
          key: c.key,
          authorId: c.authorId,
          authorName: c.authorName,
          authorAvatar: c.authorAvatar,
          content: c.content,
          timestamp: c.timestamp,
          reactions: c.reactions,
          edited: c.edited,
          replies: _toggleReaction(c.replies!, key, emoji),
        );
      }
      return c;
    }).toList();
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Article header
        Container(
          padding: EdgeInsets.fromLTRB(spacing.lg, spacing.lg, spacing.lg, spacing.md),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: colors.borderSubtle)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  OiIconButton(
                    icon: OiIcons.chevronLeft,
                    semanticLabel: 'Back to articles',
                    onTap: widget.onBack,
                    size: OiButtonSize.large,
                  ),
                  SizedBox(width: spacing.sm),
                  Expanded(child: OiLabel.h3(widget.article.title)),
                  OiTappable(
                    semanticLabel: 'Edit article',
                    onTap: widget.onEdit,
                    child: Icon(
                      OiIcons.squarePen,
                      size: 20,
                      color: colors.primary.base,
                    ),
                  ),
                ],
              ),
              SizedBox(height: spacing.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OiBadge.soft(
                    label: widget.article.category,
                    color: OiBadgeColor.info,
                    size: OiBadgeSize.large,
                  ),
                  SizedBox(width: spacing.sm),
                  OiBadge.soft(
                    label: widget.article.status,
                    color: widget.article.status == 'published'
                        ? OiBadgeColor.success
                        : OiBadgeColor.warning,
                    size: OiBadgeSize.large,
                  ),
                ],
              ),
            ],
          ),
        ),

        // Article content and comments
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(spacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Metadata detail view
                OiDetailView(
                  label: 'Article metadata',
                  columns: 2,
                  sections: [
                    OiDetailSection(
                      title: 'Article Info',
                      fields: [
                        OiDetailField(
                          label: 'Author',
                          value: widget.article.author.name,
                        ),
                        OiDetailField(
                          label: 'Category',
                          value: widget.article.category,
                        ),
                        OiDetailField(
                          label: 'Status',
                          value: widget.article.status,
                        ),
                        OiDetailField(
                          label: 'Published',
                          value:
                              '${widget.article.publishedAt.year}-'
                              '${widget.article.publishedAt.month.toString().padLeft(2, '0')}-'
                              '${widget.article.publishedAt.day.toString().padLeft(2, '0')}',
                        ),
                        OiDetailField(
                          label: 'Comments',
                          value: '${widget.article.commentCount}',
                        ),
                      ],
                    ),
                  ],
                ),

                SizedBox(height: spacing.lg),

                // Article content as Markdown
                const OiMarkdown(data: kArticleContent),

                SizedBox(height: spacing.lg),

                // Divider
                Container(height: 1, color: colors.borderSubtle),

                SizedBox(height: spacing.lg),

                // Comments section
                SizedBox(
                  height: 400,
                  child: OiComments(
                    label: 'Article comments',
                    comments: _comments,
                    currentUserId: kCurrentUser.id,
                    onComment: _onComment,
                    onReply: _onReply,
                    onEdit: _onEdit,
                    onDelete: _onDelete,
                    onReact: _onReact,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
