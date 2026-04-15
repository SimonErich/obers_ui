import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';

import 'package:obers_ui_example/data/mock_cms.dart';

/// Shows a full-screen-ish preview dialog for a blog article.
Future<void> showArticlePreviewDialog(
  BuildContext context, {
  required MockBlogPost article,
}) async {
  final size = MediaQuery.sizeOf(context);
  await OiDialogShell.show<void>(
    context: context,
    semanticLabel: 'Article preview',
    minWidth: 0,
    maxWidth: size.width * 0.96,
    maxHeight: size.height * 0.94,
    padding: EdgeInsets.zero,
    builder: (close) {
      final spacing = context.spacing;
      final colors = context.colors;
      return SizedBox(
        width: size.width * 0.96,
        height: size.height * 0.94,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                spacing.lg,
                spacing.md,
                spacing.md,
                spacing.md,
              ),
              child: Row(
                children: [
                  const Expanded(child: OiLabel.h4('Preview')),
                  OiIconButton(
                    icon: OiIcons.x,
                    semanticLabel: 'Close preview',
                    onTap: close,
                  ),
                ],
              ),
            ),
            SizedBox(height: spacing.xs),
            Container(height: 1, color: colors.borderSubtle),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (article.imageUrl != null)
                      OiSurface(
                        borderRadius: BorderRadius.zero,
                        child: AspectRatio(
                          // Keep hero a bit flatter for preview readability.
                          aspectRatio: 16 / 4.5,
                          child: Image.network(
                            article.imageUrl!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        ),
                      ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(148, spacing.xxl, 148, 96),
                      child: const OiMarkdown(data: kArticleContent),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
