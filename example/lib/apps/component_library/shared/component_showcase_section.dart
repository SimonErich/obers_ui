import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';

/// A single example group within a [ComponentShowcaseSection].
class ComponentExample {
  const ComponentExample({required this.title, required this.child});

  final String title;
  final Widget child;
}

/// Reusable frame for showcasing a single widget with title, class name,
/// description, and one or more live example groups.
class ComponentShowcaseSection extends StatelessWidget {
  const ComponentShowcaseSection({
    required this.title,
    required this.widgetName,
    required this.description,
    required this.examples,
    super.key,
  });

  /// Human-readable display name, e.g. "Button".
  final String title;

  /// Dart class name, e.g. "OiButton".
  final String widgetName;

  /// Short description of the widget's purpose.
  final String description;

  /// One or more titled example groups showing the widget in action.
  final List<ComponentExample> examples;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final radius = context.radius;

    return Padding(
      padding: EdgeInsets.only(bottom: spacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ───────────────────────────────────────────────────
          OiLabel.h3(title),
          SizedBox(height: spacing.xs),
          OiLabel.code(widgetName, color: colors.primary.base),
          SizedBox(height: spacing.xs),
          OiLabel.body(description, color: colors.textSubtle),
          SizedBox(height: spacing.lg),

          // ── Example groups ───────────────────────────────────────────
          for (final example in examples) ...[
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(spacing.lg),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: radius.md,
                border: Border.all(color: colors.borderSubtle),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  OiLabel.caption(example.title, color: colors.textMuted),
                  SizedBox(height: spacing.md),
                  example.child,
                ],
              ),
            ),
            SizedBox(height: spacing.sm),
          ],

          // ── Separator ────────────────────────────────────────────────
          SizedBox(height: spacing.md),
          const OiDivider(),
        ],
      ),
    );
  }
}
