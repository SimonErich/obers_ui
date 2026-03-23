import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';

import 'package:obers_ui_example/apps/cms/screens/cms_article_edit_screen.dart';
import 'package:obers_ui_example/apps/cms/screens/cms_article_show_screen.dart';
import 'package:obers_ui_example/apps/cms/screens/cms_articles_screen.dart';
import 'package:obers_ui_example/apps/cms/screens/cms_categories_screen.dart';
import 'package:obers_ui_example/apps/cms/screens/cms_media_screen.dart';
import 'package:obers_ui_example/apps/cms/screens/cms_settings_screen.dart';
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
        return const CmsCategoriesScreen();
      case 'media':
        return const CmsMediaScreen();
      case 'settings':
        return const CmsSettingsScreen();
      case 'articles':
      default:
        return CmsArticlesScreen(onArticleTap: _navigateToArticle);
    }
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
          icon: OiIcons.newspaper,
          route: 'articles',
          section: 'Content',
        ),
        OiNavItem(
          label: 'Categories',
          icon: OiIcons.tag,
          route: 'categories',
          section: 'Content',
        ),
        OiNavItem(
          label: 'Media',
          icon: OiIcons.image,
          route: 'media',
          section: 'Content',
        ),
        OiNavItem(
          label: 'Settings',
          icon: OiIcons.settings,
          route: 'settings',
          section: 'System',
        ),
      ],
      actions: [
        OiTappable(
          semanticLabel: 'Go back to showcase',
          onTap: () => Navigator.of(context).pop(),
          child: Icon(OiIcons.chevronLeft, size: 20, color: colors.text),
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
