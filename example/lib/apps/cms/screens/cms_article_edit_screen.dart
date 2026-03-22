import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';

import 'package:obers_ui_example/data/mock_cms.dart';

/// Article edit form using OiForm with CMS form field definitions.
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

  @override
  void initState() {
    super.initState();
    _controller = OiFormController(
      initialValues: {
        'title': widget.article.title,
        'slug': widget.article.id,
        'category': widget.article.category,
        'tags': widget.article.tags,
        'featured': false,
        'excerpt': widget.article.excerpt,
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
            border: Border(
              bottom: BorderSide(color: colors.borderSubtle),
            ),
          ),
          child: Row(
            children: [
              OiTappable(
                semanticLabel: 'Cancel editing',
                onTap: widget.onCancel,
                child: Icon(
                  OiIcons.chevronLeft,
                  size: 20,
                  color: colors.text,
                ),
              ),
              SizedBox(width: spacing.sm),
              const OiLabel.h4('Edit Article'),
            ],
          ),
        ),

        // Form
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(spacing.lg),
            child: OiForm(
              controller: _controller,
              onSubmit: (values) {
                OiToast.show(
                  context,
                  message: 'Article saved successfully',
                  level: OiToastLevel.success,
                );
                widget.onSaved();
              },
              onCancel: widget.onCancel,
              sections: [
                OiFormSection(
                  title: 'Article Details',
                  fields: kCmsFormFields,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
