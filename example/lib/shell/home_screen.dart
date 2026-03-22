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
class HomeScreen extends StatefulWidget {
  const HomeScreen({required this.themeState, super.key});

  final ThemeState themeState;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  OiOverlayHandle? _dialogHandle;

  @override
  void dispose() {
    _dialogHandle?.dismiss();
    super.dispose();
  }

  void _showWhatsNew() {
    _dialogHandle?.dismiss();
    _dialogHandle = OiDialog.show(
      context,
      label: "What's New",
      dialog: OiDialog.standard(
        label: "What's New",
        title: "What's New",
        content: OiWhatsNew(
          items: const [
            OiWhatsNewItem(
              title: 'Kanban Board',
              description:
                  'Drag and drop cards between columns with smooth '
                  'animations and keyboard support.',
              icon: OiIcons.viewColumns,
              version: 'v1.2.0',
            ),
            OiWhatsNewItem(
              title: 'Product Gallery',
              description:
                  'Multi-image gallery with zoom, thumbnails, '
                  'and swipe navigation.',
              icon: OiIcons.photo,
              version: 'v1.2.0',
            ),
            OiWhatsNewItem(
              title: 'CMS Categories',
              description:
                  'Hierarchical tree management for organizing '
                  'articles and content.',
              icon: OiIcons.newspaper,
              version: 'v1.1.0',
            ),
            OiWhatsNewItem(
              title: 'File Explorer Preview',
              description:
                  'Right-panel file preview with mime-type detection '
                  'and custom context menus.',
              icon: OiIcons.folder,
              version: 'v1.2.0',
            ),
          ],
          onDismiss: () {
            _dialogHandle?.dismiss();
            _dialogHandle = null;
          },
        ),
        onClose: () {
          _dialogHandle?.dismiss();
          _dialogHandle = null;
        },
      ),
    );
  }

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
          Row(
            children: [
              const Expanded(child: OiLabel.h1('obers_ui Showcase')),
              OiButton.ghost(
                label: "What's New",
                icon: OiIcons.sparkles,
                onTap: _showWhatsNew,
              ),
            ],
          ),
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
                themeState: widget.themeState,
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
    icon: OiIcons.shoppingCart,
    builder: (ts) => ShopApp(themeState: ts),
  ),
  _Category(
    title: 'Chat',
    description: 'Team messaging with channels, reactions, and auto-replies.',
    icon: OiIcons.chatBubbleLeft,
    builder: (ts) => ChatApp(themeState: ts),
  ),
  _Category(
    title: 'Admin',
    description: 'Dashboard analytics, user management, and settings.',
    icon: OiIcons.chartBar,
    builder: (ts) => AdminApp(themeState: ts),
  ),
  _Category(
    title: 'Projects',
    description: 'Kanban boards, Gantt charts, calendars, and timelines.',
    icon: OiIcons.viewColumns,
    builder: (ts) => ProjectApp(themeState: ts),
  ),
  _Category(
    title: 'Files',
    description: 'File explorer with folders, search, and drag-and-drop.',
    icon: OiIcons.folder,
    builder: (ts) => FilesApp(themeState: ts),
  ),
  _Category(
    title: 'Content',
    description: 'CMS with articles, rich editor, and threaded comments.',
    icon: OiIcons.newspaper,
    builder: (ts) => CmsApp(themeState: ts),
  ),
  _Category(
    title: 'Auth',
    description: 'Login, registration, and password reset flows.',
    icon: OiIcons.lockClosed,
    builder: (ts) => AuthApp(themeState: ts),
  ),
];

// ── Category card ───────────────────────────────────────────────────────────

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.category, required this.themeState});

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
            OiLabel.body(category.description, color: colors.textSubtle),
          ],
        ),
      ),
    );
  }
}
