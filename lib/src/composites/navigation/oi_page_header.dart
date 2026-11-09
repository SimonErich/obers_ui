import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/navigation/oi_breadcrumbs.dart';
import 'package:obers_ui/src/foundation/theme/oi_text_theme.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/display/oi_label.dart';

/// A reusable page heading with metadata and responsive actions.
class OiPageHeader extends StatelessWidget {
  /// Creates a page heading. The action row wraps when space is constrained.
  const OiPageHeader({
    required this.title,
    this.subtitle,
    this.leading,
    this.metadata,
    this.trailing,
    this.actions = const [],
    this.actionAlignment = CrossAxisAlignment.start,
    this.breadcrumbs,
    this.statusBadge,
    this.bottom,
    this.padding,
    this.titleVariant = OiLabelVariant.h4,
    this.titleContent,
    super.key,
  });

  /// Breadcrumb trail above the heading.
  final List<OiBreadcrumbItem>? breadcrumbs;

  /// Badge beside the title.
  final Widget? statusBadge;

  /// Content below the header, such as tabs.
  final Widget? bottom;

  /// Header insets; defaults to theme medium spacing.
  final EdgeInsetsGeometry? padding;

  /// Title style, preserving the original h4 default.
  final OiLabelVariant titleVariant;

  /// Primary page title.
  final String title;

  /// Optional composed identity replacing the plain title, retaining its label.
  final Widget? titleContent;

  /// Supporting text below the title.
  final String? subtitle;

  /// Content before the title, such as a back control.
  final Widget? leading;

  /// Badges or supplementary information below the description.
  final Widget? metadata;

  /// Content after the heading text.
  final Widget? trailing;

  /// Vertical alignment of actions beside the heading on wide layouts.
  ///
  /// Use [CrossAxisAlignment.end] to align actions with the bottom of a title,
  /// subtitle and metadata group. Narrow layouts still place actions below it.
  final CrossAxisAlignment actionAlignment;

  /// Page actions, preserving declaration order.
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final heading = Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (leading != null)
            Padding(
              padding: EdgeInsetsDirectional.only(end: context.spacing.sm),
              child: leading,
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (titleContent != null)
                  titleContent!
                else
                  Row(
                    children: [
                      Flexible(
                        child: OiLabel.variant(title, variant: titleVariant),
                      ),
                      if (statusBadge != null) ...[
                        SizedBox(width: context.spacing.sm),
                        statusBadge!,
                      ],
                    ],
                  ),
                if (subtitle != null)
                  Padding(
                    padding: EdgeInsets.only(top: context.spacing.xs),
                    child: OiLabel.body(
                      subtitle!,
                      color: context.colors.textMuted,
                    ),
                  ),
                if (metadata != null)
                  Padding(
                    padding: EdgeInsets.only(top: context.spacing.sm),
                    child: metadata,
                  ),
              ],
            ),
          ),
          ?trailing,
        ],
      );
      final actionRow = Wrap(
        spacing: context.spacing.sm,
        runSpacing: context.spacing.sm,
        children: actions ?? const [],
      );
      final body = constraints.maxWidth < 640
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                heading,
                if (actions?.isNotEmpty ?? false)
                  Padding(
                    padding: EdgeInsets.only(top: context.spacing.md),
                    child: actionRow,
                  ),
              ],
            )
          : Row(
              crossAxisAlignment: actionAlignment,
              children: [
                Expanded(child: heading),
                if (actions?.isNotEmpty ?? false)
                  Padding(
                    padding: EdgeInsetsDirectional.only(
                      start: context.spacing.lg,
                    ),
                    child: actionRow,
                  ),
              ],
            );
      return Semantics(
        header: true,
        child: Padding(
          padding: padding ?? EdgeInsets.all(context.spacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (breadcrumbs?.isNotEmpty ?? false)
                OiBreadcrumbs(items: breadcrumbs!),
              body,
              if (bottom != null)
                Padding(
                  padding: EdgeInsets.only(top: context.spacing.sm),
                  child: bottom,
                ),
            ],
          ),
        ),
      );
    },
  );
}
