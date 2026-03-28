import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_autoforms/obers_ui_autoforms.dart';

import 'package:obers_ui_example/data/mock_cms.dart';

// ── Field enum & controller ───────────────────────────────────────────────────

enum _ArticleField {
  title,
  slug,
  category,
  tags,
  publishDate,
  featured,
  excerpt,
}

class _ArticleController
    extends OiAfController<_ArticleField, Map<String, dynamic>> {
  _ArticleController({required MockBlogPost article}) : _article = article;

  final MockBlogPost _article;

  @override
  void defineFields() {
    addTextField(
      _ArticleField.title,
      initialValue: _article.title,
      required: true,
    );
    addTextField(_ArticleField.slug, initialValue: _article.id);
    addSelectField<String>(
      _ArticleField.category,
      initialValue: _article.category,
      options: [
        for (final c in kArticleCategories) OiAfOption(value: c, label: c),
      ],
    );
    addTagField(_ArticleField.tags, initialValue: _article.tags);
    addDateField(_ArticleField.publishDate, initialValue: _article.publishedAt);
    addBoolField(_ArticleField.featured, initialValue: false);
    addTextField(_ArticleField.excerpt, initialValue: _article.excerpt);
  }

  @override
  Map<String, dynamic> buildData() => json();
}

// ── Screen ───────────────────────────────────────────────────────────────────

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
  late final _ArticleController _controller;
  late final OiRichEditorController _editorController;

  @override
  void initState() {
    super.initState();
    _controller = _ArticleController(article: widget.article);
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
                child: Icon(OiIcons.save, size: 20, color: colors.primary.base),
              ),
            ],
          ),
        ),

        // Form + Rich Editor
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(spacing.lg),
            child: OiAfForm<_ArticleField, Map<String, dynamic>>(
              controller: _controller,
              onSubmit: (_, __) async => _handleSave(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Article metadata
                  OiFormSection(
                    title: 'Article Details',
                    children: [
                      const OiAfTextInput(
                        field: _ArticleField.title,
                        label: 'Title',
                      ),
                      const OiAfTextInput(
                        field: _ArticleField.slug,
                        label: 'URL Slug',
                      ),
                      OiAfSelect<_ArticleField, String>(
                        field: _ArticleField.category,
                        label: 'Category',
                        options: [
                          for (final c in kArticleCategories)
                            OiAfOption(value: c, label: c),
                        ],
                      ),
                      const OiAfTagInput(
                        field: _ArticleField.tags,
                        label: 'Tags',
                      ),
                      const OiAfDateInput(
                        field: _ArticleField.publishDate,
                        label: 'Publish Date',
                      ),
                      const OiAfCheckbox(
                        field: _ArticleField.featured,
                        label: 'Featured',
                      ),
                      const OiAfTextInput(
                        field: _ArticleField.excerpt,
                        label: 'Excerpt',
                        maxLines: 3,
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
        ),
      ],
    );
  }
}
