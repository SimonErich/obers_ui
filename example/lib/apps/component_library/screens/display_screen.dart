import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';

import 'package:obers_ui_example/apps/component_library/shared/component_showcase_section.dart';

/// Showcase screen for display and data-presentation widgets.
class DisplayScreen extends StatefulWidget {
  const DisplayScreen({super.key});

  @override
  State<DisplayScreen> createState() => _DisplayScreenState();
}

class _DisplayScreenState extends State<DisplayScreen> {
  int _pageIndex = 2;
  int _pillPageIndex = 1;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final colors = context.colors;

    return SingleChildScrollView(
      padding: EdgeInsets.all(spacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const OiLabel.h2('Display'),
          SizedBox(height: spacing.xs),
          OiLabel.body(
            'Data presentation and visual feedback components.',
            color: colors.textSubtle,
          ),
          SizedBox(height: spacing.xl),

          // ── Avatar ──────────────────────────────────────────────────────
          const ComponentShowcaseSection(
            title: 'Avatar',
            widgetName: 'OiAvatar',
            description:
                'A circular avatar rendering an image, initials, or icon. '
                'Supports presence status indicators and multiple sizes.',
            examples: [
              ComponentExample(
                title: 'Sizes',
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    OiAvatar(
                      semanticLabel: 'Extra small avatar',
                      initials: 'XS',
                      size: OiAvatarSize.xs,
                    ),
                    OiAvatar(
                      semanticLabel: 'Small avatar',
                      initials: 'SM',
                      size: OiAvatarSize.sm,
                    ),
                    OiAvatar(
                      semanticLabel: 'Medium avatar',
                      initials: 'MD',
                    ),
                    OiAvatar(
                      semanticLabel: 'Large avatar',
                      initials: 'LG',
                      size: OiAvatarSize.lg,
                    ),
                    OiAvatar(
                      semanticLabel: 'Extra large avatar',
                      initials: 'XL',
                      size: OiAvatarSize.xl,
                    ),
                  ],
                ),
              ),
              ComponentExample(
                title: 'With presence status',
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    OiAvatar(
                      semanticLabel: 'Online user',
                      initials: 'JD',
                      presence: OiPresenceStatus.online,
                    ),
                    OiAvatar(
                      semanticLabel: 'Away user',
                      initials: 'AB',
                      presence: OiPresenceStatus.away,
                    ),
                    OiAvatar(
                      semanticLabel: 'Busy user',
                      initials: 'CD',
                      presence: OiPresenceStatus.busy,
                    ),
                    OiAvatar(
                      semanticLabel: 'Offline user',
                      initials: 'EF',
                      presence: OiPresenceStatus.offline,
                    ),
                  ],
                ),
              ),
              ComponentExample(
                title: 'With icon fallback',
                child: OiAvatar(
                  semanticLabel: 'User with icon',
                  icon: OiIcons.user,
                  size: OiAvatarSize.lg,
                ),
              ),
            ],
          ),

          // ── Badge ───────────────────────────────────────────────────────
          const ComponentShowcaseSection(
            title: 'Badge',
            widgetName: 'OiBadge',
            description:
                'A small label chip for status, category, or metadata. '
                'Supports filled, soft, and outline styles with seven '
                'semantic colors.',
            examples: [
              ComponentExample(
                title: 'Filled badges',
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    OiBadge.filled(label: 'Primary'),
                    OiBadge.filled(
                      label: 'Success',
                      color: OiBadgeColor.success,
                    ),
                    OiBadge.filled(
                      label: 'Warning',
                      color: OiBadgeColor.warning,
                    ),
                    OiBadge.filled(label: 'Error', color: OiBadgeColor.error),
                    OiBadge.filled(label: 'Info', color: OiBadgeColor.info),
                    OiBadge.filled(
                      label: 'Neutral',
                      color: OiBadgeColor.neutral,
                    ),
                  ],
                ),
              ),
              ComponentExample(
                title: 'Soft badges',
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    OiBadge.soft(label: 'Primary'),
                    OiBadge.soft(label: 'Success', color: OiBadgeColor.success),
                    OiBadge.soft(label: 'Warning', color: OiBadgeColor.warning),
                    OiBadge.soft(label: 'Error', color: OiBadgeColor.error),
                    OiBadge.soft(label: 'Info', color: OiBadgeColor.info),
                    OiBadge.soft(label: 'Neutral', color: OiBadgeColor.neutral),
                  ],
                ),
              ),
              ComponentExample(
                title: 'Outline badges',
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    OiBadge.outline(label: 'Primary'),
                    OiBadge.outline(
                      label: 'Success',
                      color: OiBadgeColor.success,
                    ),
                    OiBadge.outline(
                      label: 'v2.1.0',
                      color: OiBadgeColor.neutral,
                    ),
                  ],
                ),
              ),
              ComponentExample(
                title: 'Sizes',
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    OiBadge.filled(
                      label: 'Small',
                      size: OiBadgeSize.small,
                    ),
                    OiBadge.filled(
                      label: 'Medium',
                    ),
                    OiBadge.filled(
                      label: 'Large',
                      size: OiBadgeSize.large,
                    ),
                    OiBadge.soft(
                      label: 'Small',
                      size: OiBadgeSize.small,
                      color: OiBadgeColor.success,
                    ),
                    OiBadge.soft(
                      label: 'Medium',
                      color: OiBadgeColor.success,
                    ),
                    OiBadge.soft(
                      label: 'Large',
                      size: OiBadgeSize.large,
                      color: OiBadgeColor.success,
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ── Card ────────────────────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Card',
            widgetName: 'OiCard',
            description:
                'A themed card container with optional header, footer, '
                'collapsible body, and tap interaction.',
            examples: [
              ComponentExample(
                title: 'Elevated (default)',
                child: OiCard(
                  child: Padding(
                    padding: EdgeInsets.all(spacing.md),
                    child: const OiLabel.body('Elevated card with default shadow.'),
                  ),
                ),
              ),
              ComponentExample(
                title: 'Flat',
                child: OiCard.flat(
                  child: Padding(
                    padding: EdgeInsets.all(spacing.md),
                    child: const OiLabel.body('Flat card with no shadow.'),
                  ),
                ),
              ),
              ComponentExample(
                title: 'Outlined',
                child: OiCard.outlined(
                  child: Padding(
                    padding: EdgeInsets.all(spacing.md),
                    child: const OiLabel.body('Outlined card with border only.'),
                  ),
                ),
              ),
              ComponentExample(
                title: 'Interactive',
                child: OiCard.interactive(
                  label: 'Interactive card',
                  onTap: () {},
                  child: Padding(
                    padding: EdgeInsets.all(spacing.md),
                    child: const OiLabel.body('Tap me - shows hover/focus effects.'),
                  ),
                ),
              ),
              ComponentExample(
                title: 'With header and footer',
                child: OiCard.outlined(
                  title: const OiLabel.h4('Card Title'),
                  subtitle: const OiLabel.caption('Subtitle text'),
                  footer: const OiLabel.caption('Footer content'),
                  child: Padding(
                    padding: EdgeInsets.all(spacing.md),
                    child: const OiLabel.body(
                      'Card body content with header and footer slots.',
                    ),
                  ),
                ),
              ),
            ],
          ),

          // ── Metric ──────────────────────────────────────────────────────
          const ComponentShowcaseSection(
            title: 'Metric',
            widgetName: 'OiMetric',
            description:
                'A metric display showing a primary value, label, optional '
                'sub-value, and trend indicator.',
            examples: [
              ComponentExample(
                title: 'Metrics row',
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    SizedBox(
                      width: 180,
                      child: OiMetric(
                        label: 'Revenue',
                        value: r'$12,340',
                        trend: OiMetricTrend.up,
                        trendPercent: 12.5,
                      ),
                    ),
                    SizedBox(
                      width: 180,
                      child: OiMetric(
                        label: 'Users',
                        value: '1,284',
                        trend: OiMetricTrend.down,
                        trendPercent: 3.2,
                      ),
                    ),
                    SizedBox(
                      width: 180,
                      child: OiMetric(
                        label: 'Uptime',
                        value: '99.9%',
                        trend: OiMetricTrend.neutral,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ── Progress ────────────────────────────────────────────────────
          const ComponentShowcaseSection(
            title: 'Progress',
            widgetName: 'OiProgress',
            description:
                'Progress indicators in linear, circular, and step styles. '
                'Supports determinate and indeterminate modes.',
            examples: [
              ComponentExample(
                title: 'Linear',
                child: OiProgress.linear(value: 0.7, label: 'Uploading...'),
              ),
              ComponentExample(
                title: 'Circular',
                child: OiProgress.circular(value: 0.5, label: 'Loading'),
              ),
              ComponentExample(
                title: 'Steps',
                child: OiProgress.steps(
                  steps: 5,
                  currentStep: 3,
                  label: 'Step 3 of 5',
                ),
              ),
              ComponentExample(
                title: 'Indeterminate',
                child: OiProgress.linear(
                  indeterminate: true,
                  label: 'Processing...',
                ),
              ),
            ],
          ),

          // ── Tooltip ─────────────────────────────────────────────────────
          const ComponentShowcaseSection(
            title: 'Tooltip',
            widgetName: 'OiTooltip',
            description:
                'Shows a message near its child on hover or long-press.',
            examples: [
              ComponentExample(
                title: 'Hover to see tooltip',
                child: OiTooltip(
                  label: 'Example tooltip',
                  message: 'This is a tooltip message',
                  child: OiLabel.body('Hover over me'),
                ),
              ),
            ],
          ),

          // ── Popover ─────────────────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Popover',
            widgetName: 'OiPopover',
            description:
                'An overlay anchored to a widget, with focus trapping and '
                'dismiss-on-Escape. Use for rich contextual content.',
            examples: [
              ComponentExample(
                title: 'Description',
                child: OiLabel.body(
                  'OiPopover renders content in a floating overlay anchored '
                  'to a child widget. It traps focus and dismisses on Escape '
                  'or outside tap. See OiPopover API for interactive usage.',
                  color: colors.textSubtle,
                ),
              ),
            ],
          ),

          // ── List Tile ───────────────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'List Tile',
            widgetName: 'OiListTile',
            description:
                'A single-row list item with optional leading, trailing, '
                'title, subtitle, and selection state.',
            examples: [
              ComponentExample(
                title: 'List tiles',
                child: Column(
                  children: [
                    OiListTile(
                      title: 'Inbox',
                      subtitle: '3 unread messages',
                      leading: Icon(OiIcons.mail, size: 20, color: colors.text),
                      trailing: const OiBadge.filled(label: '3'),
                      onTap: () {},
                    ),
                    OiListTile(
                      title: 'Settings',
                      subtitle: 'Manage your preferences',
                      leading: Icon(
                        OiIcons.settings,
                        size: 20,
                        color: colors.text,
                      ),
                      onTap: () {},
                    ),
                    OiListTile(
                      title: 'Selected item',
                      subtitle: 'This item is selected',
                      selected: true,
                      leading: Icon(
                        OiIcons.circleCheck,
                        size: 20,
                        color: colors.primary.base,
                      ),
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ── Image ───────────────────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Image',
            widgetName: 'OiImage',
            description:
                'A component-level image with required accessibility alt text. '
                'Supports placeholder and error fallback widgets.',
            examples: [
              const ComponentExample(
                title: 'Network image',
                child: SizedBox(
                  width: 200,
                  height: 150,
                  child: OiImage(
                    src: 'https://picsum.photos/200/150',
                    alt: 'Random sample image',
                    width: 200,
                    height: 150,
                  ),
                ),
              ),
              ComponentExample(
                title: 'With error fallback',
                child: SizedBox(
                  width: 200,
                  height: 150,
                  child: OiImage(
                    src: 'https://invalid.example/broken-image.png',
                    alt: 'Image that fails to load',
                    width: 200,
                    height: 150,
                    errorWidget: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            OiIcons.image,
                            size: 32,
                            color: colors.textMuted,
                          ),
                          SizedBox(height: spacing.xs),
                          OiLabel.caption(
                            'Image unavailable',
                            color: colors.textMuted,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // ── Field Display ───────────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Field Display',
            widgetName: 'OiFieldDisplay',
            description:
                'A universal read-only field renderer that formats values '
                'based on field type. Supports 16 field types.',
            examples: [
              ComponentExample(
                title: 'Basic field displays',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const OiFieldDisplay(label: 'Email', value: 'user@example.com'),
                    SizedBox(height: spacing.sm),
                    const OiFieldDisplay(label: 'Status', value: 'Active'),
                    SizedBox(height: spacing.sm),
                    const OiFieldDisplay(label: 'Role', value: 'Administrator'),
                    SizedBox(height: spacing.sm),
                    const OiFieldDisplay(label: 'Notes', value: null),
                  ],
                ),
              ),
            ],
          ),

          // ── Empty State ─────────────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Empty State',
            widgetName: 'OiEmptyState',
            description:
                'A centered layout for empty containers. Includes built-in '
                'presets for not-found and error states.',
            examples: [
              const ComponentExample(
                title: 'Custom empty state',
                child: SizedBox(
                  height: 200,
                  child: OiEmptyState(
                    title: 'No results found',
                    description: 'Try adjusting your search or filters.',
                    icon: OiIcons.search,
                  ),
                ),
              ),
              ComponentExample(
                title: 'Not found preset',
                child: SizedBox(
                  height: 200,
                  child: OiEmptyState.notFound(
                    description: 'The page you are looking for does not exist.',
                  ),
                ),
              ),
              ComponentExample(
                title: 'Error preset',
                child: SizedBox(
                  height: 250,
                  child: OiEmptyState.error(
                    description: 'An unexpected error occurred.',
                    actionLabel: 'Retry',
                    onAction: () {},
                  ),
                ),
              ),
            ],
          ),

          // ── Skeleton Group ──────────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Skeleton Group',
            widgetName: 'OiSkeletonGroup',
            description:
                'A group of shimmer placeholder elements for loading states. '
                'Includes line and box variants.',
            examples: [
              ComponentExample(
                title: 'Skeleton loading',
                child: OiSkeletonGroup(
                  children: [
                    const OiSkeletonLine(width: 200, height: 18),
                    SizedBox(height: spacing.sm),
                    const OiSkeletonLine(),
                    SizedBox(height: spacing.xs),
                    const OiSkeletonLine(),
                    SizedBox(height: spacing.xs),
                    const OiSkeletonLine(width: 160),
                    SizedBox(height: spacing.md),
                    const OiSkeletonBox(height: 80),
                  ],
                ),
              ),
            ],
          ),

          // ── Storage Indicator ───────────────────────────────────────────
          const ComponentShowcaseSection(
            title: 'Storage Indicator',
            widgetName: 'OiStorageIndicator',
            description:
                'A compact storage usage indicator showing used/total space '
                'with a progress bar and optional breakdown.',
            examples: [
              ComponentExample(
                title: 'Storage usage',
                child: OiStorageIndicator(
                  usedBytes: 7500000000,
                  totalBytes: 10000000000,
                ),
              ),
            ],
          ),

          // ── Rename Field ────────────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Rename Field',
            widgetName: 'OiRenameField',
            description:
                'A specialized inline text input for renaming files/folders. '
                'Auto-selects the filename without extension.',
            examples: [
              ComponentExample(
                title: 'File rename',
                child: OiRenameField(
                  currentName: 'document.pdf',
                  onRename: (_) {},
                  onCancel: () {},
                ),
              ),
            ],
          ),

          // ── Page Indicator ──────────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Page Indicator',
            widgetName: 'OiPageIndicator',
            description:
                'A row of dots indicating the current page. Supports circular '
                'dots and pill-shaped active indicators.',
            examples: [
              ComponentExample(
                title: 'Dot indicator (tap dots to change)',
                child: Column(
                  children: [
                    OiPageIndicator(
                      count: 5,
                      current: _pageIndex,
                      onDotTap: (i) => setState(() => _pageIndex = i),
                      semanticLabel: 'Page indicator',
                    ),
                    SizedBox(height: spacing.md),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: List.generate(5, (i) {
                        return GestureDetector(
                          onTap: () => setState(() => _pageIndex = i),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: spacing.sm,
                              vertical: spacing.xs,
                            ),
                            decoration: BoxDecoration(
                              color: _pageIndex == i
                                  ? colors.primary.base
                                  : colors.surfaceHover,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: OiLabel.caption(
                              'Page ${i + 1}',
                              color: _pageIndex == i
                                  ? colors.textOnPrimary
                                  : colors.text,
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
              ComponentExample(
                title: 'Pill variant (tap dots to change)',
                child: OiPageIndicator.pill(
                  count: 4,
                  current: _pillPageIndex,
                  onDotTap: (i) => setState(() => _pillPageIndex = i),
                  semanticLabel: 'Pill page indicator',
                ),
              ),
            ],
          ),

          // ── Reply Preview ───────────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Reply Preview',
            widgetName: 'OiReplyPreview',
            description:
                'A compact preview of a message being replied to, with an '
                'accent bar and optional dismiss button.',
            examples: [
              ComponentExample(
                title: 'Reply preview',
                child: OiReplyPreview(
                  senderName: 'Alice',
                  content:
                      'Hey, can you review the latest pull request when you '
                      'get a chance?',
                  dismissible: true,
                  onDismiss: () {},
                  label: 'Reply preview',
                ),
              ),
            ],
          ),

          // ── Drop Highlight ──────────────────────────────────────────────
          const ComponentShowcaseSection(
            title: 'Drop Highlight',
            widgetName: 'OiDropHighlight',
            description:
                'A visual overlay that indicates a valid drop target. '
                'Renders a dashed border and centered label.',
            examples: [
              ComponentExample(
                title: 'Active drop highlight',
                child: SizedBox(
                  height: 120,
                  width: double.infinity,
                  child: OiDropHighlight(
                    active: true,
                    message: 'Drop files here',
                    icon: OiIcons.upload,
                    child: SizedBox(height: 120, width: double.infinity),
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
