import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';

import 'package:obers_ui_example/apps/admin/admin_app.dart';
import 'package:obers_ui_example/apps/auth/auth_app.dart';
import 'package:obers_ui_example/apps/chat/chat_app.dart';
import 'package:obers_ui_example/apps/cms/cms_app.dart';
import 'package:obers_ui_example/apps/files/files_app.dart';
import 'package:obers_ui_example/apps/project/project_app.dart';
import 'package:obers_ui_example/apps/shop/shop_app.dart';
import 'package:obers_ui_example/theme/theme_state.dart';

/// Home screen showing a grid of showcase category cards.
class HomeScreen extends StatelessWidget {
  const HomeScreen({required this.themeState, super.key});

  final ThemeState themeState;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final bp = context.breakpoint;

    return SingleChildScrollView(
      padding: EdgeInsets.all(spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: spacing.lg),
          OiLabel.h1('obers_ui Showcase'),
          SizedBox(height: spacing.xs),
          OiLabel.body(
            'Explore every widget through interactive mini-applications.',
            color: colors.textSubtle,
          ),
          SizedBox(height: spacing.xl),
          OiGrid(
            breakpoint: bp,
            columns: OiResponsive.breakpoints({
              OiBreakpoint.compact: 1,
              OiBreakpoint.medium: 2,
              OiBreakpoint.expanded: 3,
              OiBreakpoint.large: 4,
            }),
            gap: OiResponsive<double>(spacing.md),
            children: _categories.map((cat) {
              return _CategoryCard(
                category: cat,
                themeState: themeState,
              );
            }).toList(),
          ),
          SizedBox(height: spacing.xl),
          Center(
            child: OiLabel.caption(
              'Alpenglueck GmbH — Premium Austrian Lifestyle',
              color: colors.textMuted,
            ),
          ),
          SizedBox(height: spacing.lg),
        ],
      ),
    );
  }
}

// ── Category data ───────────────────────────────────────────────────────────

class _Category {
  const _Category({
    required this.title,
    required this.description,
    required this.icon,
    required this.builder,
  });

  final String title;
  final String description;
  final IconData icon;
  final Widget Function(ThemeState themeState) builder;
}

final _categories = [
  _Category(
    title: 'Shop',
    description: 'Browse products, manage your cart, and complete checkout.',
    icon: const IconData(0xe8cc, fontFamily: 'MaterialIcons'), // shopping_cart
    builder: (ts) => ShopApp(themeState: ts),
  ),
  _Category(
    title: 'Chat',
    description: 'Team messaging with channels, reactions, and auto-replies.',
    icon: const IconData(0xe0ca, fontFamily: 'MaterialIcons'), // chat_bubble
    builder: (ts) => ChatApp(themeState: ts),
  ),
  _Category(
    title: 'Admin',
    description: 'Dashboard analytics, user management, and settings.',
    icon: const IconData(0xe871, fontFamily: 'MaterialIcons'), // dashboard
    builder: (ts) => AdminApp(themeState: ts),
  ),
  _Category(
    title: 'Projects',
    description: 'Kanban boards, Gantt charts, calendars, and timelines.',
    icon: const IconData(0xf04b, fontFamily: 'MaterialIcons'), // view_kanban
    builder: (ts) => ProjectApp(themeState: ts),
  ),
  _Category(
    title: 'Files',
    description: 'File explorer with folders, search, and drag-and-drop.',
    icon: const IconData(0xe2c7, fontFamily: 'MaterialIcons'), // folder
    builder: (ts) => FilesApp(themeState: ts),
  ),
  _Category(
    title: 'Content',
    description: 'CMS with articles, rich editor, and threaded comments.',
    icon: const IconData(0xe261, fontFamily: 'MaterialIcons'), // article
    builder: (ts) => CmsApp(themeState: ts),
  ),
  _Category(
    title: 'Auth',
    description: 'Login, registration, and password reset flows.',
    icon: const IconData(0xe899, fontFamily: 'MaterialIcons'), // lock
    builder: (ts) => AuthApp(themeState: ts),
  ),
];

// ── Category card ───────────────────────────────────────────────────────────

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.category,
    required this.themeState,
  });

  final _Category category;
  final ThemeState themeState;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final radius = context.radius;

    return OiTappable(
      semanticLabel: 'Open ${category.title} showcase',
      onTap: () {
        Navigator.of(context).push(
          PageRouteBuilder<void>(
            pageBuilder: (context, animation, secondaryAnimation) =>
                category.builder(themeState),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.all(spacing.lg),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: radius.md,
          border: Border.all(color: colors.borderSubtle),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: colors.primary.muted,
                borderRadius: radius.sm,
              ),
              child: Center(
                child: Icon(
                  category.icon,
                  size: 24,
                  color: colors.primary.base,
                ),
              ),
            ),
            SizedBox(height: spacing.md),
            OiLabel.h4(category.title),
            SizedBox(height: spacing.xs),
            OiLabel.body(
              category.description,
              color: colors.textSubtle,
            ),
          ],
        ),
      ),
    );
  }
}
