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
                title: 'Horizontal divider',
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
              ComponentExample(
                title: 'Vertical divider',
                child: SizedBox(
                  height: 48,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
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

          // ── OiSurface ──────────────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Surface',
            widgetName: 'OiSurface',
            description:
                'A themed container that provides a background surface color.',
            examples: [
              ComponentExample(
                title: 'Basic surface',
                child: OiSurface(
                  child: Padding(
                    padding: EdgeInsets.all(spacing.lg),
                    child: const OiLabel.body('Surface content'),
                  ),
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
                'A persistent slide-in side panel for navigation or auxiliary content. Requires open/close state management.',
            examples: [
              ComponentExample(
                title: 'Description',
                child: OiLabel.body(
                  'OiPanel slides in from a given side when open is true. '
                  'It is designed for pointer-first desktop UIs and traps '
                  'focus while open. Use it for persistent side navigation '
                  'or detail panels.',
                ),
              ),
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
                title: '16:9 aspect ratio',
                child: OiAspectRatio(
                  breakpoint: bp,
                  ratio: const OiResponsive<double>(16 / 9),
                  child: _placeholder(context, '16 : 9'),
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
          const ComponentShowcaseSection(
            title: 'Page',
            widgetName: 'OiPage',
            description:
                'A page-level layout wrapper that fills available space and arranges children vertically with responsive padding and gap. Use as the outermost layout widget to represent a full page with safe area handling.',
            examples: [
              ComponentExample(
                title: 'Description',
                child: OiLabel.body(
                  'OiPage is the outermost layout widget for a full page. '
                  'It expands to fill its parent, applies responsive padding '
                  'and gap, and provides safe area handling. Nest OiSection '
                  'and OiGrid inside it for structured page layouts.',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
