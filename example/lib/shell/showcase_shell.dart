import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';

import 'package:obers_ui_example/theme/theme_state.dart';

/// Lightweight top-bar wrapper for all showcase screens.
///
/// Provides a back button, title, and theme toggle. This is intentionally
/// *not* an [OiAppShell] — that module is showcased inside the Admin and CMS
/// mini-apps where it belongs.
class ShowcaseShell extends StatelessWidget {
  const ShowcaseShell({
    required this.title,
    required this.themeState,
    required this.child,
    this.showBack = true,
    super.key,
  });

  final String title;
  final ThemeState themeState;
  final Widget child;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Top bar ─────────────────────────────────────────────────────
        Container(
          height: 56,
          padding: EdgeInsets.symmetric(horizontal: spacing.md),
          decoration: BoxDecoration(
            color: colors.surface,
            border: Border(bottom: BorderSide(color: colors.borderSubtle)),
          ),
          child: Row(
            children: [
              if (showBack)
                Padding(
                  padding: EdgeInsets.only(right: spacing.sm),
                  child: OiTappable(
                    semanticLabel: 'Go back',
                    onTap: () => Navigator.of(context).pop(),
                    child: Icon(
                      OiIcons.chevronLeft,
                      size: 24,
                      color: colors.text,
                    ),
                  ),
                ),
              OiLabel.h4(title),
              const Spacer(),
              // ── Theme preset switcher ──
              OiTappable(
                semanticLabel: 'Switch theme preset',
                onTap: () => themeState.cyclePreset(),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: spacing.sm,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: colors.primary.base.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: OiLabel.smallStrong(switch (themeState.preset) {
                    ThemePreset.alpine => 'Alpine',
                    ThemePreset.blueDanube => 'Blue Danube',
                    ThemePreset.arco => 'Arco',
                    ThemePreset.finesse => 'Finesse',
                  }, color: colors.primary.base),
                ),
              ),
              SizedBox(width: spacing.sm),
              OiThemeToggle(
                currentMode: themeState.value,
                onModeChange: (_) => themeState.toggle(),
              ),
            ],
          ),
        ),
        // ── Content ─────────────────────────────────────────────────────
        Expanded(child: child),
      ],
    );
  }
}
