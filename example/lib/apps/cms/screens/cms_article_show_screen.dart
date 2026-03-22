import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';

import 'package:obers_ui_example/data/mock_cms.dart';
import 'package:obers_ui_example/data/mock_users.dart';

/// Article detail screen with content and threaded comments.
class CmsArticleShowScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Article header
        Container(
          padding: EdgeInsets.all(spacing.lg),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: colors.borderSubtle),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  OiTappable(
                    semanticLabel: 'Back to articles',
                    onTap: onBack,
                    child: Icon(
                      OiIcons.chevronLeft,
                      size: 20,
                      color: colors.text,
                    ),
                  ),
                  SizedBox(width: spacing.sm),
                  Expanded(child: OiLabel.h3(article.title)),
                  OiTappable(
                    semanticLabel: 'Edit article',
                    onTap: onEdit,
                    child: Icon(
                      const IconData(0xe3c9, fontFamily: 'MaterialIcons'),
                      size: 20,
                      color: colors.primary.base,
                    ),
                  ),
                ],
              ),
              SizedBox(height: spacing.sm),
              Row(
                children: [
                  OiLabel.small(
                    article.author.name,
                    color: colors.textMuted,
                  ),
                  SizedBox(width: spacing.sm),
                  OiBadge.soft(
                    label: article.category,
                    color: OiBadgeColor.info,
                    size: OiBadgeSize.small,
                  ),
                  SizedBox(width: spacing.sm),
                  OiBadge.soft(
                    label: article.status,
                    color: article.status == 'published'
                        ? OiBadgeColor.success
                        : OiBadgeColor.warning,
                    size: OiBadgeSize.small,
                  ),
                ],
              ),
            ],
          ),
        ),

        // Article content and comments
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Content
              Padding(
                padding: EdgeInsets.all(spacing.lg),
                child: const OiLabel.body(kArticleContent),
              ),

              // Divider
              Container(
                height: 1,
                color: colors.borderSubtle,
              ),

              // Comments section
              Expanded(
                child: OiComments(
                  label: 'Article comments',
                  comments: buildBlogComments(),
                  currentUserId: kCurrentUser.id,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
