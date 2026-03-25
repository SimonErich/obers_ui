import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';

import 'package:obers_ui_example/data/mock_cms.dart';

/// Article edit form with rich text editor and file input for featured image.
class CmsArticleEditScreen extends StatefulWidget {
  const CmsArticleEditScreen({
    required this.article,
    required this.onSaved,
    required this.onCancel,
    super.key,
  });

  final MockBlogPost article;
  final VoidCallback onSaved;
  final VoidCallback onCancel;

  @override
  State<CmsArticleEditScreen> createState() => _CmsArticleEditScreenState();
}

class _CmsArticleEditScreenState extends State<CmsArticleEditScreen> {
  late final OiFormController _controller;
  late final OiRichEditorController _editorController;

  @override
  void initState() {
    super.initState();
    _controller = OiFormController(
      initialValues: {
        'title': widget.article.title,
        'slug': widget.article.id,
        'category': widget.article.category,
        'tags': widget.article.tags,
        'publishDate': widget.article.publishedAt,
        'featured': false,
        'excerpt': widget.article.excerpt,
      },
    );
    _editorController = OiRichEditorController(
      initialContent: OiRichContent.fromPlainText(kArticleContent),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _editorController.dispose();
    super.dispose();
  }

  void _handleSave() {
    OiToast.show(
      context,
      message: 'Article saved successfully',
      level: OiToastLevel.success,
    );
    widget.onSaved();
  }

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        Container(
          padding: EdgeInsets.all(spacing.md),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: colors.borderSubtle)),
          ),
          child: Row(
            children: [
              OiTappable(
                semanticLabel: 'Cancel editing',
                onTap: widget.onCancel,
                child: Icon(OiIcons.chevronLeft, size: 20, color: colors.text),
              ),
              SizedBox(width: spacing.sm),
              const Expanded(child: OiLabel.h4('Edit Article')),
              OiTappable(
                semanticLabel: 'Save article',
                onTap: _handleSave,
                child: Icon(
                  OiIcons.save,
                  size: 20,
                  color: colors.primary.base,
                ),
              ),
            ],
          ),
        ),

        // Form + Rich Editor
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(spacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Article metadata form
                OiForm(
                  controller: _controller,
                  onSubmit: (values) => _handleSave(),
                  onCancel: widget.onCancel,
                  sections: [
                    OiFormSection(
                      title: 'Article Details',
                      fields: kCmsFormFields,
                    ),
                  ],
                ),

                SizedBox(height: spacing.lg),

                // Featured image upload
                OiFileInput(
                  label: 'Featured Image',
                  hint: 'Upload an image for the article header',
                  allowedExtensions: const ['jpg', 'jpeg', 'png', 'webp'],
                  dropZone: true,
                  onChanged: (_) {},
                ),

                SizedBox(height: spacing.lg),

                // Rich text editor for article body
                const OiLabel.h4('Article Body'),
                SizedBox(height: spacing.sm),
                OiRichEditor(
                  controller: _editorController,
                  label: 'Article body',
                  placeholder: 'Write your article content here...',
                  maxHeight: 350,
                  showWordCount: true,
                ),

                SizedBox(height: spacing.lg),

                // Save button
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OiButton.primary(
                      label: 'Save Article',
                      onTap: _handleSave,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
