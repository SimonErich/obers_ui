import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/navigation/oi_breadcrumbs.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/display/oi_label.dart';

/// A standardised header for pages, combining breadcrumbs, title,
/// status badge, actions, and an optional bottom slot (e.g. tabs).
///
/// All slots except [title] are optional — the widget degrades
/// cleanly to a standalone title row when nothing else is provided.
///
/// {@category Composites}
class OiPageHeader extends StatelessWidget {
  /// Creates an [OiPageHeader].
  const OiPageHeader({
    required this.title,
    this.breadcrumbs,
    this.statusBadge,
    this.actions,
    this.bottom,
    super.key,
  });

  /// The page title.
  final String title;

  /// Optional breadcrumb trail rendered above the title row.
  final List<OiBreadcrumbItem>? breadcrumbs;

  /// An optional status badge displayed next to the title
  /// (e.g. [OiBadge]).
  final Widget? statusBadge;

  /// Action widgets placed at the trailing end of the title row
  /// (e.g. [OiButton]).
  final List<Widget>? actions;

  /// An optional widget rendered below the title row (e.g. [OiTabs]).
  final Widget? bottom;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;

    return Semantics(
      header: true,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: spacing.md,
          vertical: spacing.md,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Breadcrumbs.
            if (breadcrumbs != null && breadcrumbs!.isNotEmpty) ...[
              OiBreadcrumbs(items: breadcrumbs!),
              SizedBox(height: spacing.xs),
            ],
            // Title row.
            Row(
              children: [
                OiLabel.h4(title),
                if (statusBadge != null) ...[
                  SizedBox(width: spacing.sm),
                  statusBadge!,
                ],
                const Spacer(),
                if (actions != null)
                  for (var i = 0; i < actions!.length; i++) ...[
                    if (i > 0) SizedBox(width: spacing.sm),
                    actions![i],
                  ],
              ],
            ),
            // Bottom slot.
            if (bottom != null) ...[
              SizedBox(height: spacing.sm),
              bottom!,
            ],
          ],
        ),
      ),
    );
  }
}
