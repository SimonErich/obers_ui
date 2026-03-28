import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';

import 'package:obers_ui_example/apps/autoforms/registration_wizard_screen.dart';
import 'package:obers_ui_example/apps/autoforms/signup_form_screen.dart';
import 'package:obers_ui_example/shell/showcase_shell.dart';
import 'package:obers_ui_example/theme/theme_state.dart';

/// Available demos inside the AutoForms mini-app.
enum _AutoFormsDemo { menu, signup, wizard }

/// Root widget for the AutoForms showcase mini-app.
///
/// Presents a menu of two demos:
/// - **Signup Form** — single-screen form with all common field types.
/// - **Registration Wizard** — multi-step form wizard.
class AutoFormsApp extends StatefulWidget {
  const AutoFormsApp({required this.themeState, super.key});

  final ThemeState themeState;

  @override
  State<AutoFormsApp> createState() => _AutoFormsAppState();
}

class _AutoFormsAppState extends State<AutoFormsApp> {
  _AutoFormsDemo _current = _AutoFormsDemo.menu;

  void _goTo(_AutoFormsDemo demo) => setState(() => _current = demo);
  void _goBack() => setState(() => _current = _AutoFormsDemo.menu);

  @override
  Widget build(BuildContext context) {
    return ShowcaseShell(
      title: 'AutoForms',
      themeState: widget.themeState,
      child: _current == _AutoFormsDemo.menu
          ? _DemoMenu(onSelect: _goTo)
          : _DemoShell(
              title: _current == _AutoFormsDemo.signup
                  ? 'Signup Form'
                  : 'Registration Wizard',
              onBack: _goBack,
              child: _current == _AutoFormsDemo.signup
                  ? const SignupFormScreen()
                  : const RegistrationWizardScreen(),
            ),
    );
  }
}

// ── Demo menu ───────────────────────────────────────────────────────────────

class _DemoMenu extends StatelessWidget {
  const _DemoMenu({required this.onSelect});

  final void Function(_AutoFormsDemo demo) onSelect;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final colors = context.colors;

    return SingleChildScrollView(
      padding: EdgeInsets.all(spacing.lg),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: spacing.lg),
              const OiLabel.h2('AutoForms Demos'),
              SizedBox(height: spacing.xs),
              OiLabel.body(
                'Explore controller-first, enum-keyed form handling '
                'with validation, derived fields, and conditional visibility.',
                color: colors.textSubtle,
              ),
              SizedBox(height: spacing.xl),

              // ── Signup Form card ─────────────────────────────────────
              _DemoCard(
                title: 'Signup Form',
                description:
                    'A single-screen form with text inputs, derived username, '
                    'password with confirmation, conditional radio, date '
                    'picker, slider, and error summary.',
                icon: OiIcons.userPlus,
                onTap: () => onSelect(_AutoFormsDemo.signup),
              ),
              SizedBox(height: spacing.md),

              // ── Registration Wizard card ─────────────────────────────
              _DemoCard(
                title: 'Registration Wizard',
                description:
                    'A multi-step wizard with progress indicator, '
                    'per-step validation, segmented theme control, '
                    'tag input, and step navigation.',
                icon: OiIcons.listChecks,
                onTap: () => onSelect(_AutoFormsDemo.wizard),
              ),

              SizedBox(height: spacing.xl),
              Center(
                child: OiLabel.caption(
                  'Powered by obers_ui_autoforms',
                  color: colors.textMuted,
                ),
              ),
              SizedBox(height: spacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Demo card ───────────────────────────────────────────────────────────────

class _DemoCard extends StatelessWidget {
  const _DemoCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final radius = context.radius;

    return OiTappable(
      semanticLabel: 'Open $title demo',
      clipBorderRadius: radius.md,
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(spacing.lg),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: radius.md,
          border: Border.all(color: colors.borderSubtle),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: colors.primary.muted,
                borderRadius: radius.sm,
              ),
              child: Center(
                child: Icon(icon, size: 24, color: colors.primary.base),
              ),
            ),
            SizedBox(width: spacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  OiLabel.h4(title),
                  SizedBox(height: spacing.xs),
                  OiLabel.body(description, color: colors.textSubtle),
                ],
              ),
            ),
            Icon(
              OiIcons.chevronRight,
              size: 20,
              color: colors.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Demo shell ──────────────────────────────────────────────────────────────

class _DemoShell extends StatelessWidget {
  const _DemoShell({
    required this.title,
    required this.onBack,
    required this.child,
  });

  final String title;
  final VoidCallback onBack;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Sub-navigation bar ──────────────────────────────────────
        Container(
          height: 44,
          padding: EdgeInsets.symmetric(horizontal: spacing.md),
          decoration: BoxDecoration(
            color: colors.surface,
            border: Border(
              bottom: BorderSide(color: colors.borderSubtle),
            ),
          ),
          child: Row(
            children: [
              OiTappable(
                semanticLabel: 'Back to demo list',
                onTap: onBack,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      OiIcons.chevronLeft,
                      size: 18,
                      color: colors.primary.base,
                    ),
                    SizedBox(width: spacing.xs),
                    OiLabel.bodyStrong(title, color: colors.primary.base),
                  ],
                ),
              ),
            ],
          ),
        ),
        // ── Content ─────────────────────────────────────────────────
        Expanded(child: child),
      ],
    );
  }
}
