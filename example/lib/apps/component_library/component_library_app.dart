import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';

import 'package:obers_ui_example/apps/component_library/screens/buttons_screen.dart';
import 'package:obers_ui_example/apps/component_library/screens/charts_screen.dart';
import 'package:obers_ui_example/apps/component_library/screens/display_screen.dart';
import 'package:obers_ui_example/apps/component_library/screens/editors_media_screen.dart';
import 'package:obers_ui_example/apps/component_library/screens/feedback_screen.dart';
import 'package:obers_ui_example/apps/component_library/screens/files_screen.dart';
import 'package:obers_ui_example/apps/component_library/screens/form_inputs_screen.dart';
import 'package:obers_ui_example/apps/component_library/screens/forms_wizards_screen.dart';
import 'package:obers_ui_example/apps/component_library/screens/layout_screen.dart';
import 'package:obers_ui_example/apps/component_library/screens/modules_screen.dart';
import 'package:obers_ui_example/apps/component_library/screens/navigation_screen.dart';
import 'package:obers_ui_example/apps/component_library/screens/overlays_screen.dart';
import 'package:obers_ui_example/apps/component_library/screens/scheduling_workflow_screen.dart';
import 'package:obers_ui_example/apps/component_library/screens/search_screen.dart';
import 'package:obers_ui_example/apps/component_library/screens/shop_screen.dart';
import 'package:obers_ui_example/apps/component_library/screens/social_interaction_screen.dart';
import 'package:obers_ui_example/apps/component_library/screens/tables_trees_screen.dart';
import 'package:obers_ui_example/apps/component_library/screens/typography_screen.dart';
import 'package:obers_ui_example/apps/icons/icons_app.dart';
import 'package:obers_ui_example/theme/theme_state.dart';

/// Component library app with sidebar navigation for browsing all widgets.
class ComponentLibraryApp extends StatefulWidget {
  const ComponentLibraryApp({required this.themeState, super.key});

  final ThemeState themeState;

  @override
  State<ComponentLibraryApp> createState() => _ComponentLibraryAppState();
}

class _ComponentLibraryAppState extends State<ComponentLibraryApp> {
  String _currentRoute = 'typography';

  // ── Route labels for breadcrumbs ──────────────────────────────────────────

  static const _routeLabels = <String, String>{
    'typography': 'Typography & Text',
    'layout': 'Layout',
    'buttons': 'Buttons',
    'form-inputs': 'Form Inputs',
    'forms-wizards': 'Forms & Wizards',
    'display': 'Display',
    'tables-trees': 'Tables & Trees',
    'feedback': 'Feedback & Rating',
    'navigation': 'Navigation',
    'overlays': 'Overlays & Dialogs',
    'search': 'Search & Command',
    'editors-media': 'Editors & Media',
    'charts': 'Charts & Visualization',
    'scheduling-workflow': 'Scheduling & Workflow',
    'files': 'Files',
    'shop': 'Shop',
    'social-interaction': 'Social, Animation & Interaction',
    'modules': 'Modules',
  };

  // ── Route → screen mapping ────────────────────────────────────────────────

  Widget _buildScreen() {
    return switch (_currentRoute) {
      'typography' => const TypographyScreen(),
      'layout' => const LayoutScreen(),
      'buttons' => const ButtonsScreen(),
      'form-inputs' => const FormInputsScreen(),
      'forms-wizards' => const FormsWizardsScreen(),
      'display' => const DisplayScreen(),
      'tables-trees' => const TablesTreesScreen(),
      'feedback' => const FeedbackScreen(),
      'navigation' => const NavigationScreen(),
      'overlays' => const OverlaysScreen(),
      'search' => const SearchScreen(),
      'editors-media' => const EditorsMediaScreen(),
      'charts' => const ChartsScreen(),
      'scheduling-workflow' => const SchedulingWorkflowScreen(),
      'files' => const FilesScreen(),
      'shop' => const ShopScreen(),
      'social-interaction' => const SocialInteractionScreen(),
      'modules' => const ModulesScreen(),
      _ => const TypographyScreen(),
    };
  }

  // ── Breadcrumbs ───────────────────────────────────────────────────────────

  List<OiBreadcrumbItem> _buildBreadcrumbs() {
    return [
      OiBreadcrumbItem(
        label: 'Component Library',
        onTap: () => setState(() => _currentRoute = 'typography'),
      ),
      OiBreadcrumbItem(label: _routeLabels[_currentRoute] ?? _currentRoute),
    ];
  }

  // ── Handle navigation ────────────────────────────────────────────────────

  void _onNavigate(String route) {
    if (route == 'icons') {
      Navigator.of(context).push(
        PageRouteBuilder<void>(
          pageBuilder: (context, animation, secondaryAnimation) =>
              IconsApp(themeState: widget.themeState),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    } else {
      setState(() => _currentRoute = route);
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return OiAppShell(
      label: 'Component Library',
      currentRoute: _currentRoute,
      onNavigate: _onNavigate,
      breadcrumbs: _buildBreadcrumbs(),
      leading: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: OiLabel.h4('Components', color: colors.primary.base),
      ),
      navigation: const [
        // ── Fundamentals ─────────────────────────────────────────────
        OiNavItem(
          label: 'Typography & Text',
          icon: OiIcons.aLargeSmall,
          route: 'typography',
          section: 'Fundamentals',
        ),
        OiNavItem(
          label: 'Icons',
          icon: OiIcons.sparkles,
          route: 'icons',
          section: 'Fundamentals',
        ),
        OiNavItem(
          label: 'Layout',
          icon: OiIcons.layoutGrid,
          route: 'layout',
          section: 'Fundamentals',
        ),

        // ── Controls ─────────────────────────────────────────────────
        OiNavItem(
          label: 'Buttons',
          icon: OiIcons.mousePointerClick,
          route: 'buttons',
          section: 'Controls',
        ),
        OiNavItem(
          label: 'Form Inputs',
          icon: OiIcons.textCursorInput,
          route: 'form-inputs',
          section: 'Controls',
        ),
        OiNavItem(
          label: 'Forms & Wizards',
          icon: OiIcons.clipboardList,
          route: 'forms-wizards',
          section: 'Controls',
        ),

        // ── Data & Display ───────────────────────────────────────────
        OiNavItem(
          label: 'Display',
          icon: OiIcons.eye,
          route: 'display',
          section: 'Data & Display',
        ),
        OiNavItem(
          label: 'Tables & Trees',
          icon: OiIcons.table2,
          route: 'tables-trees',
          section: 'Data & Display',
        ),
        OiNavItem(
          label: 'Feedback & Rating',
          icon: OiIcons.star,
          route: 'feedback',
          section: 'Data & Display',
        ),

        // ── Navigation ───────────────────────────────────────────────
        OiNavItem(
          label: 'Navigation',
          icon: OiIcons.navigation,
          route: 'navigation',
          section: 'Navigation',
        ),
        OiNavItem(
          label: 'Overlays & Dialogs',
          icon: OiIcons.layers,
          route: 'overlays',
          section: 'Navigation',
        ),
        OiNavItem(
          label: 'Search & Command',
          icon: OiIcons.search,
          route: 'search',
          section: 'Navigation',
        ),

        // ── Rich Content ─────────────────────────────────────────────
        OiNavItem(
          label: 'Editors & Media',
          icon: OiIcons.penLine,
          route: 'editors-media',
          section: 'Rich Content',
        ),
        OiNavItem(
          label: 'Charts & Visualization',
          icon: OiIcons.barChart3,
          route: 'charts',
          section: 'Rich Content',
        ),
        OiNavItem(
          label: 'Scheduling & Workflow',
          icon: OiIcons.calendar,
          route: 'scheduling-workflow',
          section: 'Rich Content',
        ),

        // ── Specialized ──────────────────────────────────────────────
        OiNavItem(
          label: 'Files',
          icon: OiIcons.folder,
          route: 'files',
          section: 'Specialized',
        ),
        OiNavItem(
          label: 'Shop',
          icon: OiIcons.shoppingBag,
          route: 'shop',
          section: 'Specialized',
        ),
        OiNavItem(
          label: 'Social & Interaction',
          icon: OiIcons.users,
          route: 'social-interaction',
          section: 'Specialized',
        ),
        OiNavItem(
          label: 'Modules',
          icon: OiIcons.blocks,
          route: 'modules',
          section: 'Specialized',
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
