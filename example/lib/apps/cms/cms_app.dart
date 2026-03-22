import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';

import 'package:obers_ui_example/apps/cms/screens/cms_article_edit_screen.dart';
import 'package:obers_ui_example/apps/cms/screens/cms_article_show_screen.dart';
import 'package:obers_ui_example/apps/cms/screens/cms_articles_screen.dart';
import 'package:obers_ui_example/data/mock_cms.dart';
import 'package:obers_ui_example/theme/theme_state.dart';

/// CMS mini-app showcasing OiAppShell, OiCard, OiComments, and OiForm.
class CmsApp extends StatefulWidget {
  const CmsApp({required this.themeState, super.key});

  final ThemeState themeState;

  @override
  State<CmsApp> createState() => _CmsAppState();
}

class _CmsAppState extends State<CmsApp> {
  String _currentRoute = 'articles';
  MockBlogPost? _selectedArticle;

  void _navigateToArticle(MockBlogPost article) {
    setState(() {
      _selectedArticle = article;
      _currentRoute = 'article-show';
    });
  }

  void _navigateToEdit(MockBlogPost article) {
    setState(() {
      _selectedArticle = article;
      _currentRoute = 'article-edit';
    });
  }

  Widget _buildScreen() {
    switch (_currentRoute) {
      case 'article-show':
        if (_selectedArticle != null) {
          return CmsArticleShowScreen(
            article: _selectedArticle!,
            onEdit: () => _navigateToEdit(_selectedArticle!),
            onBack: () => setState(() => _currentRoute = 'articles'),
          );
        }
        return CmsArticlesScreen(onArticleTap: _navigateToArticle);
      case 'article-edit':
        if (_selectedArticle != null) {
          return CmsArticleEditScreen(
            article: _selectedArticle!,
            onSaved: () => setState(() => _currentRoute = 'article-show'),
            onCancel: () => setState(() => _currentRoute = 'article-show'),
          );
        }
        return CmsArticlesScreen(onArticleTap: _navigateToArticle);
      case 'categories':
      case 'media':
      case 'settings':
        return _buildPlaceholder(_currentRoute);
      case 'articles':
      default:
        return CmsArticlesScreen(onArticleTap: _navigateToArticle);
    }
  }

  Widget _buildPlaceholder(String section) {
    final colors = context.colors;
    final spacing = context.spacing;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            const IconData(0xe86c, fontFamily: 'MaterialIcons'),
            size: 48,
            color: colors.textMuted,
          ),
          SizedBox(height: spacing.md),
          OiLabel.h4(
            '${section[0].toUpperCase()}${section.substring(1)}',
          ),
          SizedBox(height: spacing.xs),
          OiLabel.body(
            'This section is a placeholder for the showcase.',
            color: colors.textSubtle,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return OiAppShell(
      label: 'Content management',
      currentRoute: _currentRoute,
      onNavigate: (route) => setState(() => _currentRoute = route),
      leading: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: OiLabel.h4('Alpenglueck CMS', color: colors.primary.base),
      ),
      navigation: const [
        OiNavItem(
          label: 'Articles',
          icon: IconData(0xe261, fontFamily: 'MaterialIcons'),
          route: 'articles',
          section: 'Content',
        ),
        OiNavItem(
          label: 'Categories',
          icon: IconData(0xe574, fontFamily: 'MaterialIcons'),
          route: 'categories',
          section: 'Content',
        ),
        OiNavItem(
          label: 'Media',
          icon: IconData(0xe332, fontFamily: 'MaterialIcons'),
          route: 'media',
          section: 'Content',
        ),
        OiNavItem(
          label: 'Settings',
          icon: IconData(0xe8b8, fontFamily: 'MaterialIcons'),
          route: 'settings',
          section: 'System',
        ),
      ],
      actions: [
        OiTappable(
          semanticLabel: 'Go back to showcase',
          onTap: () => Navigator.of(context).pop(),
          child: Icon(
            OiIcons.chevronLeft,
            size: 20,
            color: colors.text,
          ),
        ),
        OiThemeToggle(
          currentMode: widget.themeState.value,
          onModeChange: (_) => widget.themeState.toggle(),
        ),
      ],
      child: _buildScreen(),
    );
  }
}
