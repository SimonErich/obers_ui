import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/buttons/oi_button.dart';
import 'package:obers_ui/src/components/overlays/oi_sheet.dart';
import 'package:obers_ui/src/foundation/oi_responsive.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';

/// Shared bounded page regions for lists, forms and record detail screens.
///
/// Header, navigation and footer remain outside the body scroll region. On
/// narrow layouts the aside is accessible in a sheet, leaving the full width
/// available to the primary content. Set [scrollable] for intrinsically sized
/// content; leave it false for tables or content that owns its scrolling.
class OiPageLayout extends StatelessWidget {
  /// Creates a page layout.
  const OiPageLayout({
    required this.child,
    this.header,
    this.navigation,
    this.aside,
    this.asideFooter,
    this.footer,
    this.asideWidth = 360,
    this.asideFraction,
    this.asideLabel = 'Summary',
    this.padding,
    this.gap,
    this.footerGap,
    this.scrollable = false,
    this.scrollHeaderWhenCompact = false,
    this.collapseBreakpoint = OiBreakpoint.expanded,
    super.key,
  }) : assert(
         asideFraction == null || (asideFraction > 0 && asideFraction < 1),
         'asideFraction must be between zero and one.',
       );

  /// Primary content.
  final Widget child;

  /// Page heading.
  final Widget? header;

  /// Tabs or other page-local navigation.
  final Widget? navigation;

  /// Supporting panel.
  final Widget? aside;

  /// Content pinned below the independently scrollable supporting panel.
  final Widget? asideFooter;

  /// Pinned actions below the body.
  final Widget? footer;

  /// Desktop aside width.
  final double asideWidth;

  /// Fraction of the available body width, after the column gap, for the aside.
  /// Omitted, [asideWidth] supplies its fixed desktop width. Compact sheets
  /// continue to use [asideWidth].
  final double? asideFraction;

  /// Accessible label for the compact aside trigger and sheet.
  /// Also appears in the sheet's pinned header beside its close action.
  final String asideLabel;

  /// Page insets; defaults to the theme's large spacing.
  final EdgeInsetsGeometry? padding;

  /// Space between regions.
  final double? gap;

  /// Optional spacing above pinned actions, independent of body region gaps.
  final double? footerGap;

  /// Whether this layout scrolls the content itself.
  final bool scrollable;

  /// Includes the heading, local navigation and aside trigger in the compact
  /// content scroll region when [scrollable] is true. The footer stays pinned.
  /// Useful for intrinsic form headers that stack beyond the available height.
  final bool scrollHeaderWhenCompact;

  /// Breakpoint below which the aside is presented in a sheet.
  final OiBreakpoint collapseBreakpoint;

  /// Prepends a containing page's heading to this layout's own header.
  /// All region, scrolling and sizing policies are retained. [headingGap]
  /// separates the two headings when this layout already has a header.
  OiPageLayout prependHeader(Widget heading, {required double headingGap}) =>
      OiPageLayout(
        key: key,
        header: header == null
            ? heading
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  heading,
                  SizedBox(height: headingGap),
                  header!,
                ],
              ),
        navigation: navigation,
        aside: aside,
        asideFooter: asideFooter,
        footer: footer,
        asideWidth: asideWidth,
        asideFraction: asideFraction,
        asideLabel: asideLabel,
        padding: padding,
        gap: gap,
        footerGap: footerGap,
        scrollable: scrollable,
        scrollHeaderWhenCompact: scrollHeaderWhenCompact,
        collapseBreakpoint: collapseBreakpoint,
        child: child,
      );

  void _showAside(BuildContext context) {
    OiSheet.show(
      context,
      label: asideLabel,
      side: OiPanelSide.right,
      size: asideWidth,
      scrollable: true,
      showHeader: true,
      footer: asideFooter,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          context.spacing.lg,
          0,
          context.spacing.lg,
          context.spacing.lg,
        ),
        child: aside ?? const SizedBox.shrink(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final spacing = gap ?? context.spacing.lg;
      final compact = constraints.maxWidth < collapseBreakpoint.minWidth;
      final scrollHeader = compact && scrollable && scrollHeaderWhenCompact;
      final chrome = <Widget>[
        if (header != null) ...[header!, SizedBox(height: spacing)],
        if (navigation != null) ...[navigation!, SizedBox(height: spacing)],
        if ((aside != null || asideFooter != null) && compact)
          Padding(
            padding: EdgeInsets.only(bottom: spacing),
            child: Align(
              alignment: AlignmentDirectional.centerEnd,
              child: OiButton.soft(
                label: asideLabel,
                onTap: () => _showAside(context),
              ),
            ),
          ),
      ];
      var body = child;
      if (scrollHeader) {
        body = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [...chrome, body],
        );
      }
      if (scrollable) body = SingleChildScrollView(child: body);
      if ((aside != null || asideFooter != null) && !compact) {
        body = Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: body),
            SizedBox(width: spacing),
            SizedBox(
              width: asideFraction == null
                  ? asideWidth
                  : (constraints.maxWidth -
                            (padding ?? EdgeInsets.all(context.spacing.lg))
                                .resolve(Directionality.of(context))
                                .horizontal -
                            spacing) *
                        asideFraction!,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: SingleChildScrollView(child: aside)),
                  if (asideFooter != null) ...[
                    SizedBox(height: spacing),
                    asideFooter!,
                  ],
                ],
              ),
            ),
          ],
        );
      }
      return Padding(
        padding: padding ?? EdgeInsets.all(context.spacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!scrollHeader) ...chrome,
            Expanded(child: body),
            if (footer != null) ...[
              SizedBox(height: footerGap ?? spacing),
              footer!,
            ],
          ],
        ),
      );
    },
  );
}
