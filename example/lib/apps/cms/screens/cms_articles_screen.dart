import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';

import 'package:obers_ui_example/data/mock_cms.dart';

/// Article list screen showing blog posts as cards.
class CmsArticlesScreen extends StatelessWidget {
  const CmsArticlesScreen({required this.onArticleTap, super.key});

  /// Called when the user taps an article card.
  final ValueChanged<MockBlogPost> onArticleTap;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final colors = context.colors;

    return SingleChildScrollView(
      padding: EdgeInsets.all(spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const OiLabel.h3('Articles'),
          SizedBox(height: spacing.md),
          for (final post in kBlogPosts)
            Padding(
              padding: EdgeInsets.only(bottom: spacing.md),
              child: OiCard(
                label: 'Open article: ${post.title}',
                onTap: () => onArticleTap(post),
                title: OiLabel.h4(post.title),
                subtitle: OiLabel.small(
                  '${post.author.name}  \u2022  '
                  '${post.publishedAt.year}-'
                  '${post.publishedAt.month.toString().padLeft(2, '0')}-'
                  '${post.publishedAt.day.toString().padLeft(2, '0')}',
                  color: colors.textMuted,
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (post.commentCount > 0) ...[
                      Icon(
                        const IconData(
                          0xe24c,
                          fontFamily: 'MaterialIcons',
                        ),
                        size: 16,
                        color: colors.textMuted,
                      ),
                      const SizedBox(width: 4),
                      OiLabel.small(
                        '${post.commentCount}',
                        color: colors.textMuted,
                      ),
                      const SizedBox(width: 12),
                    ],
                    OiBadge.soft(
                      label: post.status,
                      color: post.status == 'published'
                          ? OiBadgeColor.success
                          : OiBadgeColor.warning,
                    ),
                  ],
                ),
                child: OiLabel.body(
                  post.excerpt,
                  color: colors.textSubtle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
