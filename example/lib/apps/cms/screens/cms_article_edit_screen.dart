import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_autoforms/obers_ui_autoforms.dart';

import 'package:obers_ui_example/data/mock_cms.dart';

// ── Field enum & controller ───────────────────────────────────────────────────

final _categoryOptions = [
  for (final c in kArticleCategories) OiAfOption(value: c, label: c),
];

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
      options: _categoryOptions,
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

/// Article edit form with a full-width rich text editor and a collapsible
/// right-side panel for article configuration (title, slug, category, etc.).
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
  bool _panelOpen = true;

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

  // ── Shared widgets ────────────────────────────────────────────────────────

  Widget _buildConfigFields(BuildContext context) {
    final spacing = context.spacing;

    return OiAfForm<_ArticleField, Map<String, dynamic>>(
      controller: _controller,
      onSubmit: (_, __) async => _handleSave(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          const OiAfTextInput(
            field: _ArticleField.title,
            label: 'Title',
          ),
          SizedBox(height: spacing.sm),
          const OiAfTextInput(
            field: _ArticleField.slug,
            label: 'Slug',
          ),
          SizedBox(height: spacing.sm),
          OiAfSelect<_ArticleField, String>(
            field: _ArticleField.category,
            label: 'Category',
            options: _categoryOptions,
          ),
          SizedBox(height: spacing.sm),
          const OiAfTagInput(
            field: _ArticleField.tags,
            label: 'Tags',
          ),
          SizedBox(height: spacing.sm),
          const OiAfDateInput(
            field: _ArticleField.publishDate,
            label: 'Publish Date',
          ),
          SizedBox(height: spacing.sm),
          const OiAfTextInput(
            field: _ArticleField.excerpt,
            label: 'Excerpt',
            maxLines: 4,
          ),
          SizedBox(height: spacing.md),
          OiFileInput(
            label: 'Cover Image',
            hint: 'Upload an image for the article header',
            allowedExtensions: const ['jpg', 'jpeg', 'png', 'webp'],
            dropZone: true,
            onChanged: (_) {},
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final spacing = context.spacing;
    final colors = context.colors;

    return Container(
      padding: EdgeInsets.fromLTRB(
        spacing.lg,
        spacing.lg,
        spacing.lg,
        spacing.md,
      ),
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
                semanticLabel: 'Back to article',
                onTap: widget.onCancel,
                size: OiButtonSize.large,
              ),
              SizedBox(width: spacing.sm),
              Expanded(child: OiLabel.h3(widget.article.title)),
              OiButton.outline(
                label: 'Cancel',
                onTap: widget.onCancel,
              ),
              SizedBox(width: spacing.sm),
              OiButton.primary(
                label: 'Publish',
                onTap: _handleSave,
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
    );
  }

  Widget _buildCollapseToggle(BuildContext context) {
    final colors = context.colors;
    return OiTappable(
      semanticLabel: _panelOpen ? 'Collapse panel' : 'Expand panel',
      onTap: () => setState(() => _panelOpen = !_panelOpen),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: colors.borderSubtle)),
        ),
        alignment: Alignment.center,
        child: Icon(
          _panelOpen ? OiIcons.chevronRight : OiIcons.chevronLeft,
          size: 20,
          color: colors.textMuted,
        ),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final colors = context.colors;
    final isSmall = !context.isExpandedOrWider;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeader(context),

        // Content area — responsive
        if (isSmall)
          // Mobile / tablet: config fields first, then editor, all scrollable
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(spacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildConfigFields(context),
                  SizedBox(height: spacing.lg),
                  OiRichEditor(
                    controller: _editorController,
                    label: '',
                    placeholder: 'Write your article content here...',
                    minHeight: 300,
                    maxHeight: 500,
                    showWordCount: true,
                  ),
                ],
              ),
            ),
          )
        else
          // Desktop: editor fills left, collapsible panel on right
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(spacing.sm),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final bodyHeight = constraints.maxHeight - 100;
                        return OiRichEditor(
                          controller: _editorController,
                          label: '',
                          placeholder: 'Write your article content here...',
                          maxHeight: bodyHeight > 100 ? bodyHeight : 100,
                          showWordCount: true,
                        );
                      },
                    ),
                  ),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 240),
                  curve: Curves.easeOutCubic,
                  width: _panelOpen ? 360 : 48,
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(color: colors.borderSubtle),
                    ),
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_panelOpen)
                        Expanded(
                          child: SingleChildScrollView(
                            padding: EdgeInsets.all(spacing.md),
                            child: _buildConfigFields(context),
                          ),
                        )
                      else
                        const Spacer(),
                      _buildCollapseToggle(context),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
