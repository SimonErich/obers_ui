import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/oi_responsive.dart';
import 'package:obers_ui/src/foundation/theme/oi_component_themes.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/modules/oi_page_layout.dart';

/// A bounded page with independently scrolling content and pinned actions.
///
/// Composes [OiPageLayout]. Header and dock share a maximum content width while
/// the dock decoration spans the page. Safe areas and keyboard insets are
/// consumed here; use inside a shell that does not consume keyboard insets.
///
/// {@category Modules}
class OiDockedPage extends StatelessWidget {
  /// Creates a page; its parent must supply bounded height.
  const OiDockedPage({
    required Widget this.child,
    this.header,
    this.dock,
    this.centered = false,
    this.maxWidth,
    this.bodyPadding,
    this.scrollController,
    super.key,
  }) : slivers = null;

  /// Creates a page with lazily built slivers in the same fixed-chrome layout.
  const OiDockedPage.slivers({
    required List<Widget> this.slivers,
    this.header,
    this.dock,
    this.maxWidth,
    this.bodyPadding,
    this.scrollController,
    super.key,
  }) : child = null,
       centered = false;

  /// Sliver content; null for the intrinsic child constructor.
  final List<Widget>? slivers;

  /// Intrinsically sized, scrollable content.
  final Widget? child;

  /// Fixed heading outside the body scroll region.
  final Widget? header;

  /// Pinned actions that remain above the keyboard.
  final Widget? dock;

  /// Centers short body content vertically; long content still scrolls.
  final bool centered;

  /// Optional content width override, otherwise read from the component theme.
  final double? maxWidth;

  /// Body inset override for sections that supply their own content gutters.
  /// Header/dock padding and maximum content width continue to use the theme.
  final EdgeInsetsGeometry? bodyPadding;

  /// Optional caller-owned controller for the body scroll region.
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    final theme =
        context.components.dockedPage ?? const OiDockedPageThemeData();
    final width = maxWidth ?? theme.maxWidth ?? double.infinity;
    final defaultPadding = EdgeInsets.all(context.spacing.lg);
    EdgeInsetsGeometry resolve(OiResponsive<EdgeInsetsGeometry>? value) =>
        value?.resolve(context.breakpoint, context.breakpointScale) ??
        defaultPadding;
    Widget region(Widget content, EdgeInsetsGeometry padding) => Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: width),
        child: Padding(
          padding: padding,
          child: SizedBox(width: double.infinity, child: content),
        ),
      ),
    );
    return ColoredBox(
      color: theme.backgroundColor ?? context.colors.background,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: SafeArea(
          child: OiPageLayout(
            padding: EdgeInsets.zero,
            gap: 0,
            footerGap: 0,
            header: header == null
                ? null
                : region(
                    header!,
                    resolve(theme.headerPadding),
                  ),
            footer: dock == null
                ? null
                : DecoratedBox(
                    decoration:
                        theme.dockDecoration ??
                        BoxDecoration(color: context.colors.surface),
                    child: region(dock!, resolve(theme.dockPadding)),
                  ),
            child: LayoutBuilder(
              builder: (context, bounds) {
                final bodyPadding =
                    this.bodyPadding ??
                    resolve(
                      header == null
                          ? theme.bodyPadding
                          : theme.bodyPaddingWithHeader ?? theme.bodyPadding,
                    );
                if (slivers != null) {
                  final gutter = bounds.maxWidth > width
                      ? (bounds.maxWidth - width) / 2
                      : 0.0;
                  return CustomScrollView(
                    controller: scrollController,
                    slivers: [
                      SliverPadding(
                        padding: bodyPadding.add(
                          EdgeInsets.symmetric(horizontal: gutter),
                        ),
                        sliver: SliverMainAxisGroup(slivers: slivers!),
                      ),
                    ],
                  );
                }
                return SingleChildScrollView(
                  controller: scrollController,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: centered ? bounds.maxHeight : 0,
                    ),
                    child: region(
                      child!,
                      bodyPadding,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
