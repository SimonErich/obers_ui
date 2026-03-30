import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';

import 'package:obers_ui_example/apps/component_library/shared/component_showcase_section.dart';

/// Showcase screen for layout primitives and containers.
class LayoutScreen extends StatelessWidget {
  const LayoutScreen({super.key});

  /// Builds a colored placeholder box for visualizing layout behavior.
  static Widget _placeholder(
    BuildContext context,
    String label, {
    double? width,
    double? height,
  }) {
    final colors = context.colors;
    final radius = context.radius;
    final spacing = context.spacing;

    return Container(
      width: width,
      height: height ?? 48,
      padding: EdgeInsets.all(spacing.sm),
      decoration: BoxDecoration(
        color: colors.primary.muted,
        borderRadius: radius.sm,
      ),
      alignment: Alignment.center,
      child: OiLabel.caption(label),
    );
  }

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final bp = context.breakpoint;

    return SingleChildScrollView(
      padding: EdgeInsets.all(spacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const OiLabel.h2('Layout'),
          SizedBox(height: spacing.lg),

          // ── OiRow ──────────────────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Row',
            widgetName: 'OiRow',
            description:
                'A horizontal layout primitive with responsive gap and optional collapse behavior.',
            examples: [
              ComponentExample(
                title: 'Three items with gap',
                child: OiRow(
                  breakpoint: bp,
                  gap: OiResponsive<double>(spacing.md),
                  children: [
                    Expanded(child: _placeholder(context, 'A')),
                    Expanded(child: _placeholder(context, 'B')),
                    Expanded(child: _placeholder(context, 'C')),
                  ],
                ),
              ),
            ],
          ),

          // ── OiColumn ───────────────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Column',
            widgetName: 'OiColumn',
            description: 'A vertical layout primitive with responsive gap.',
            examples: [
              ComponentExample(
                title: 'Stacked items',
                child: OiColumn(
                  breakpoint: bp,
                  gap: OiResponsive<double>(spacing.md),
                  children: [
                    _placeholder(context, 'Top'),
                    _placeholder(context, 'Bottom'),
                  ],
                ),
              ),
            ],
          ),

          // ── OiGrid ─────────────────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Grid',
            widgetName: 'OiGrid',
            description:
                'A non-scrolling grid that arranges children into equal-width columns with responsive column count and gap.',
            examples: [
              ComponentExample(
                title: '3-column grid',
                child: OiGrid(
                  breakpoint: bp,
                  columns: const OiResponsive<int>(3),
                  gap: OiResponsive<double>(spacing.md),
                  children: [
                    _placeholder(context, '1'),
                    _placeholder(context, '2'),
                    _placeholder(context, '3'),
                    _placeholder(context, '4'),
                    _placeholder(context, '5'),
                    _placeholder(context, '6'),
                  ],
                ),
              ),
            ],
          ),

          // ── OiDivider ──────────────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Divider',
            widgetName: 'OiDivider',
            description:
                'A thin line separator, horizontal by default or vertical when specified.',
            examples: [
              ComponentExample(
                title: 'Horizontal & vertical',
                child: OiRow(
                  breakpoint: bp,
                  gap: OiResponsive<double>(spacing.lg),
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          const OiLabel.body('Above'),
                          SizedBox(height: spacing.sm),
                          const OiDivider(),
                          SizedBox(height: spacing.sm),
                          const OiLabel.body('Below'),
                        ],
                      ),
                    ),
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const OiLabel.body('Left'),
                            SizedBox(width: spacing.sm),
                            const OiDivider(axis: Axis.vertical),
                            SizedBox(width: spacing.sm),
                            const OiLabel.body('Right'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ── OiSurface ──────────────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Surface',
            widgetName: 'OiSurface',
            description:
                'A themed container that provides a background surface color.',
            examples: [
              ComponentExample(
                title: 'Default surface',
                child: OiSurface(
                  color: context.colors.surfaceSubtle,
                  padding: EdgeInsets.all(spacing.lg),
                  child: const OiLabel.body(
                    'Default surface with subtle color',
                  ),
                ),
              ),
              ComponentExample(
                title: 'Primary surface',
                child: OiSurface(
                  color: context.colors.primary.muted,
                  borderRadius: context.radius.md,
                  padding: EdgeInsets.all(spacing.lg),
                  child: OiLabel.body(
                    'Primary muted surface',
                    color: context.colors.primary.dark,
                  ),
                ),
              ),
              ComponentExample(
                title: 'Surface with border',
                child: OiSurface(
                  color: context.colors.surface,
                  borderRadius: context.radius.md,
                  border: OiBorderStyle.solid(context.colors.borderSubtle, 1),
                  padding: EdgeInsets.all(spacing.lg),
                  child: const OiLabel.body('Surface with border'),
                ),
              ),
            ],
          ),

          // ── OiSpacer ───────────────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Spacer',
            widgetName: 'OiSpacer',
            description:
                'A flexible spacer that fills available space between widgets.',
            examples: [
              ComponentExample(
                title: 'Between two labels',
                child: Row(
                  children: [
                    const OiLabel.body('Start'),
                    OiSpacer(breakpoint: bp),
                    const OiLabel.body('End'),
                  ],
                ),
              ),
            ],
          ),

          // ── OiSection ──────────────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Section',
            widgetName: 'OiSection',
            description:
                'A semantic section grouping widget that arranges children vertically with optional gap and padding.',
            examples: [
              ComponentExample(
                title: 'Basic section',
                child: OiSection(
                  breakpoint: bp,
                  gap: OiResponsive<double>(spacing.md),
                  children: const [
                    OiLabel.h4('Section Title'),
                    OiLabel.body('Section content goes here.'),
                  ],
                ),
              ),
            ],
          ),

          // ── OiContainer ────────────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Container',
            widgetName: 'OiContainer',
            description:
                'A content-width constraining wrapper with optional padding and centering.',
            examples: [
              ComponentExample(
                title: 'Constrained container',
                child: OiContainer(
                  breakpoint: bp,
                  maxWidth: const OiResponsive<double>(600),
                  padding: OiResponsive<EdgeInsetsGeometry>(
                    EdgeInsets.all(spacing.md),
                  ),
                  child: _placeholder(context, 'Container content'),
                ),
              ),
            ],
          ),

          // ── OiPanel ────────────────────────────────────────────────────
          const ComponentShowcaseSection(
            title: 'Panel',
            widgetName: 'OiPanel',
            description:
                'A persistent slide-in side panel for navigation or '
                'auxiliary content. Slides in from a given side when open '
                'is true. Designed for pointer-first desktop UIs and traps '
                'focus while open. Use it for persistent side navigation '
                'or detail panels.',
            examples: [
              ComponentExample(title: 'Slide-in Panel', child: _PanelDemo()),
            ],
          ),

          // ── OiSplitPane ────────────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Split Pane',
            widgetName: 'OiSplitPane',
            description:
                'A two-pane layout with a draggable divider for resizable split views.',
            examples: [
              ComponentExample(
                title: 'Horizontal split',
                child: SizedBox(
                  height: 200,
                  child: OiSplitPane(
                    leading: _placeholder(context, 'Leading', height: 200),
                    trailing: _placeholder(context, 'Trailing', height: 200),
                  ),
                ),
              ),
            ],
          ),

          // ── OiResizable ────────────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Resizable',
            widgetName: 'OiResizable',
            description:
                'A wrapper that lets the user resize its child by dragging edges or corners.',
            examples: [
              ComponentExample(
                title: 'Resizable panel',
                child: SizedBox(
                  height: 200,
                  child: OiResizable(
                    initialWidth: 200,
                    initialHeight: 150,
                    minWidth: 100,
                    minHeight: 80,
                    child: _placeholder(
                      context,
                      'Drag edges to resize',
                      width: 200,
                      height: 150,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // ── OiMasonry ──────────────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Masonry',
            widgetName: 'OiMasonry',
            description:
                'A masonry-style layout distributing children across vertical columns with varying heights.',
            examples: [
              ComponentExample(
                title: '3-column masonry',
                child: OiMasonry(
                  breakpoint: bp,
                  columns: const OiResponsive<int>(3),
                  gap: OiResponsive<double>(spacing.md),
                  children: [
                    _placeholder(context, 'A', height: 60),
                    _placeholder(context, 'B', height: 100),
                    _placeholder(context, 'C', height: 80),
                    _placeholder(context, 'D', height: 120),
                    _placeholder(context, 'E', height: 70),
                    _placeholder(context, 'F', height: 90),
                  ],
                ),
              ),
            ],
          ),

          // ── OiAspectRatio ──────────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Aspect Ratio',
            widgetName: 'OiAspectRatio',
            description:
                'Forces its child to a given width-to-height ratio, responsive across breakpoints.',
            examples: [
              ComponentExample(
                title: 'Aspect ratios',
                child: OiRow(
                  breakpoint: bp,
                  gap: OiResponsive<double>(spacing.md),
                  children: [
                    Expanded(
                      child: OiAspectRatio(
                        breakpoint: bp,
                        ratio: const OiResponsive<double>(16 / 9),
                        child: _placeholder(context, '16 : 9'),
                      ),
                    ),
                    Expanded(
                      child: OiAspectRatio(
                        breakpoint: bp,
                        ratio: const OiResponsive<double>(4 / 3),
                        child: _placeholder(context, '4 : 3'),
                      ),
                    ),
                    Expanded(
                      child: OiAspectRatio(
                        breakpoint: bp,
                        ratio: const OiResponsive<double>(1),
                        child: _placeholder(context, '1 : 1'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ── OiWrapLayout ───────────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Wrap Layout',
            widgetName: 'OiWrapLayout',
            description:
                'A responsive wrap layout that flows children across lines with configurable spacing.',
            examples: [
              ComponentExample(
                title: 'Wrapped items',
                child: OiWrapLayout(
                  breakpoint: bp,
                  spacing: OiResponsive<double>(spacing.sm),
                  runSpacing: OiResponsive<double>(spacing.sm),
                  children: [
                    _placeholder(context, 'Tag 1', width: 80),
                    _placeholder(context, 'Tag 2', width: 100),
                    _placeholder(context, 'Tag 3', width: 70),
                    _placeholder(context, 'Tag 4', width: 90),
                    _placeholder(context, 'Tag 5', width: 110),
                    _placeholder(context, 'Tag 6', width: 85),
                    _placeholder(context, 'Tag 7', width: 75),
                  ],
                ),
              ),
            ],
          ),

          // ── OiPage ─────────────────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Page',
            widgetName: 'OiPage',
            description:
                'A page-level layout wrapper that fills available space and '
                'arranges children vertically with responsive padding and gap. '
                'Use as the outermost layout widget to represent a full page. '
                'Nest OiSection and OiGrid inside it for structured page layouts.',
            examples: [
              ComponentExample(
                title: 'Page with sections',
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: context.colors.borderSubtle),
                    borderRadius: context.radius.md,
                  ),
                  child: ClipRRect(
                    borderRadius: context.radius.md,
                    child: OiPage(
                      breakpoint: bp,
                      mainAxisSize: MainAxisSize.min,
                      padding: OiResponsive<EdgeInsetsGeometry>(
                        EdgeInsets.all(spacing.md),
                      ),
                      gap: OiResponsive<double>(spacing.md),
                      children: [
                        _placeholder(context, 'Header'),
                        _placeholder(context, 'Content'),
                        _placeholder(context, 'Footer'),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          // ── OiGridZoomControls ──────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Grid Zoom Controls',
            widgetName: 'OiGridZoomControls',
            description:
                'A wrapper around OiGrid that adds +/- zoom controls '
                'to interactively change the column count. Great for '
                'gallery or card views where users want to adjust '
                'density.',
            examples: [
              ComponentExample(
                title: 'Zoomable card grid',
                child: SizedBox(
                  height: 250,
                  child: OiGridZoomControls(
                    breakpoint: OiBreakpoint.expanded,
                    gap: OiResponsive<double>(spacing.xs),
                    children: List.generate(
                      9,
                      (i) => OiCard.outlined(
                        child: Center(child: OiLabel.body('Item ${i + 1}')),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PanelDemo extends StatefulWidget {
  const _PanelDemo();

  @override
  State<_PanelDemo> createState() => _PanelDemoState();
}

class _PanelDemoState extends State<_PanelDemo> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;

    return SizedBox(
      height: 200,
      child: ClipRRect(
        borderRadius: context.radius.md,
        child: Container(
          width: double.infinity,
          color: context.colors.surfaceSubtle,
          child: Stack(
            alignment: Alignment.center,
            children: [
              UnconstrainedBox(
                child: OiButton.primary(
                  label: _open ? 'Close Panel' : 'Open Panel',
                  onTap: () => setState(() => _open = !_open),
                ),
              ),
              OiPanel(
                label: 'Demo panel',
                open: _open,
                size: 200,
                onClose: () => setState(() => _open = false),
                child: Padding(
                  padding: EdgeInsets.all(spacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const OiLabel.bodyStrong('Panel Title'),
                      SizedBox(height: spacing.sm),
                      const OiLabel.body('Panel content here'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
