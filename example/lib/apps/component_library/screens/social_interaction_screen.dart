import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_example/apps/component_library/shared/component_showcase_section.dart';

/// Showcase screen for social, animation, drag-and-drop, gesture, scroll,
/// clipboard, and onboarding widgets.
class SocialInteractionScreen extends StatefulWidget {
  const SocialInteractionScreen({super.key});

  @override
  State<SocialInteractionScreen> createState() =>
      _SocialInteractionScreenState();
}

class _SocialInteractionScreenState extends State<SocialInteractionScreen> {
  int _tapCount = 0;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final colors = context.colors;

    return SingleChildScrollView(
      padding: EdgeInsets.all(spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ═══════════════════════════════════════════════════════════════
          // Social & Collaboration
          // ═══════════════════════════════════════════════════════════════

          // ── OiAvatarStack ─────────────────────────────────────────────
          const ComponentShowcaseSection(
            title: 'Avatar Stack',
            widgetName: 'OiAvatarStack',
            description:
                'A horizontal stack of overlapping avatars with a "+N more" '
                'overflow indicator.',
            examples: [
              ComponentExample(
                title: 'Team Members',
                child: OiAvatarStack(
                  users: [
                    OiAvatarStackItem(initials: 'AB', label: 'Alice Brown'),
                    OiAvatarStackItem(initials: 'CD', label: 'Carol Davis'),
                    OiAvatarStackItem(initials: 'EF', label: 'Eve Foster'),
                    OiAvatarStackItem(initials: 'GH', label: 'Grace Hall'),
                    OiAvatarStackItem(initials: 'IJ', label: 'Iris Jones'),
                    OiAvatarStackItem(initials: 'KL', label: 'Kate Lee'),
                  ],
                ),
              ),
            ],
          ),

          // ── OiTypingIndicator ─────────────────────────────────────────
          const ComponentShowcaseSection(
            title: 'Typing Indicator',
            widgetName: 'OiTypingIndicator',
            description:
                'Displays a "typing..." indicator with animated dots. '
                'Formats contextually based on user count.',
            examples: [
              ComponentExample(
                title: 'One User Typing',
                child: OiTypingIndicator(typingUsers: ['Alice']),
              ),
              ComponentExample(
                title: 'Multiple Users Typing',
                child: OiTypingIndicator(
                  typingUsers: ['Alice', 'Bob', 'Carol'],
                ),
              ),
            ],
          ),

          // ── OiLiveRing ────────────────────────────────────────────────
          const ComponentShowcaseSection(
            title: 'Live Ring',
            widgetName: 'OiLiveRing',
            description:
                'Wraps a child widget with a pulsing ring to indicate '
                '"live" status. The ring color defaults to the success color.',
            examples: [
              ComponentExample(
                title: 'Active & Inactive',
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    OiLiveRing(
                      child: OiAvatar(
                        initials: 'JD',
                        semanticLabel: 'Live user',
                      ),
                    ),
                    OiLiveRing(
                      active: false,
                      child: OiAvatar(
                        initials: 'AB',
                        semanticLabel: 'Offline user',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ── OiCursorPresence / OiSelectionPresence ────────────────────
          const ComponentShowcaseSection(
            title: 'Cursor & Selection Presence',
            widgetName: 'OiCursorPresence / OiSelectionPresence',
            description:
                'Real-time collaboration indicators. OiCursorPresence shows '
                'named cursors for remote users. OiSelectionPresence '
                'highlights text or cell selections made by collaborators.',
            examples: [
              ComponentExample(
                title: 'Description',
                child: OiLabel.body(
                  'OiCursorPresence renders labeled cursor markers at '
                  'remote user positions. OiSelectionPresence overlays '
                  'colored highlights for remote selections. Both are '
                  'driven by a stream of presence events. Key parameters: '
                  'cursors, selections, userColors.',
                ),
              ),
            ],
          ),

          // ═══════════════════════════════════════════════════════════════
          // Animation
          // ═══════════════════════════════════════════════════════════════

          // ── OiShimmer ─────────────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Shimmer',
            widgetName: 'OiShimmer',
            description:
                'A shimmer loading-placeholder effect that sweeps a gradient '
                'across the child widget. Respects reduced-motion settings.',
            examples: [
              ComponentExample(
                title: 'Loading Placeholder',
                child: OiShimmer(
                  child: Container(
                    height: 60,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: colors.surfaceSubtle,
                      borderRadius: context.radius.sm,
                    ),
                  ),
                ),
              ),
              ComponentExample(
                title: 'Skeleton Lines',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    OiShimmer(
                      child: Container(
                        height: 14,
                        width: double.infinity,
                        color: colors.surfaceSubtle,
                      ),
                    ),
                    SizedBox(height: spacing.xs),
                    OiShimmer(
                      child: Container(
                        height: 14,
                        width: 200,
                        color: colors.surfaceSubtle,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ── OiPulse ───────────────────────────────────────────────────
          const ComponentShowcaseSection(
            title: 'Pulse',
            widgetName: 'OiPulse',
            description:
                'Applies a looping opacity and/or scale pulse animation to '
                'a child widget. Respects reduced-motion settings.',
            examples: [
              ComponentExample(
                title: 'Pulsing Icon',
                child: OiPulse(
                  child: OiIcon(
                    icon: OiIcons.bell,
                    label: 'Notification bell',
                    size: 24,
                  ),
                ),
              ),
            ],
          ),

          // ── OiSpring / OiStagger / OiMorph / OiAnimatedList ──────────
          const ComponentShowcaseSection(
            title: 'Spring, Stagger, Morph & Animated List',
            widgetName: 'OiSpring / OiStagger / OiMorph / OiAnimatedList',
            description:
                'Advanced animation primitives for physics-based springs, '
                'staggered entrance animations, smooth morphing transitions, '
                'and animated list item insertion/removal.',
            examples: [
              ComponentExample(
                title: 'Description',
                child: OiLabel.body(
                  'OiSpring: physics-based spring animation wrapper with '
                  'configurable mass, stiffness, and damping.\n\n'
                  'OiStagger: staggers entrance animations across a list '
                  'of children with configurable delay.\n\n'
                  'OiMorph: smoothly transitions between two child widgets '
                  'with cross-fade and size interpolation.\n\n'
                  'OiAnimatedList: an animated list that auto-animates '
                  'item insertions and removals.',
                ),
              ),
            ],
          ),

          // ═══════════════════════════════════════════════════════════════
          // Drag & Drop
          // ═══════════════════════════════════════════════════════════════

          // ── OiReorderable ─────────────────────────────────────────────
          const ComponentShowcaseSection(
            title: 'Reorderable',
            widgetName: 'OiReorderable',
            description:
                'A drag-to-reorder list that supports both touch and '
                'pointer-based reordering with animated transitions.',
            examples: [
              ComponentExample(
                title: 'Description',
                child: OiLabel.body(
                  'OiReorderable wraps a list of items and enables '
                  'drag-to-reorder. Key parameters: items, itemBuilder, '
                  'onReorder, dragHandleBuilder. Provides haptic feedback '
                  'and animated placeholder positioning.',
                ),
              ),
            ],
          ),

          // ── OiDraggable / OiDropZone / OiDragGhost ────────────────────
          const ComponentShowcaseSection(
            title: 'Draggable, Drop Zone & Drag Ghost',
            widgetName: 'OiDraggable / OiDropZone / OiDragGhost',
            description:
                'Low-level drag-and-drop primitives for custom drag '
                'interactions.',
            examples: [
              ComponentExample(
                title: 'Description',
                child: OiLabel.body(
                  'OiDraggable: makes a widget draggable with typed data '
                  'payload. Key parameters: data, child, feedback.\n\n'
                  'OiDropZone: defines a zone that accepts dropped items. '
                  'Key parameters: onDrop, onHover, accepts.\n\n'
                  'OiDragGhost: the visual feedback widget shown during '
                  'a drag operation. Customizable opacity and scale.',
                ),
              ),
            ],
          ),

          // ═══════════════════════════════════════════════════════════════
          // Gestures
          // ═══════════════════════════════════════════════════════════════

          // ── OiSwipeable ───────────────────────────────────────────────
          const ComponentShowcaseSection(
            title: 'Swipeable',
            widgetName: 'OiSwipeable',
            description:
                'A swipe-to-dismiss or swipe-to-reveal widget for list '
                'items. Supports left and right swipe actions.',
            examples: [
              ComponentExample(
                title: 'Description',
                child: OiLabel.body(
                  'OiSwipeable enables swipe gestures on list items. '
                  'Key parameters: onSwipeLeft, onSwipeRight, '
                  'leftActions, rightActions, dismissThreshold, child.',
                ),
              ),
            ],
          ),

          // ── OiPinchZoom / OiDoubleTap / OiLongPressMenu ──────────────
          const ComponentShowcaseSection(
            title: 'Pinch Zoom, Double Tap & Long Press Menu',
            widgetName: 'OiPinchZoom / OiDoubleTap / OiLongPressMenu',
            description: 'Gesture handlers for advanced touch interactions.',
            examples: [
              ComponentExample(
                title: 'Description',
                child: OiLabel.body(
                  'OiPinchZoom: wraps a child with pinch-to-zoom and '
                  'pan gestures. Key parameters: minScale, maxScale, '
                  'child.\n\n'
                  'OiDoubleTap: detects double-tap gestures with '
                  'configurable timeout. Key parameters: onDoubleTap, '
                  'child.\n\n'
                  'OiLongPressMenu: shows a context menu on long press. '
                  'Key parameters: items, onSelected, child.',
                ),
              ),
            ],
          ),

          // ═══════════════════════════════════════════════════════════════
          // Interaction
          // ═══════════════════════════════════════════════════════════════

          // ── OiTappable ────────────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Tappable',
            widgetName: 'OiTappable',
            description:
                'The foundational interactive primitive. Wraps any widget '
                'with tap, hover, and focus handling plus accessibility '
                'semantics.',
            examples: [
              ComponentExample(
                title: 'Interactive Area',
                child: OiTappable(
                  semanticLabel: 'Tap me',
                  onTap: () => setState(() => _tapCount++),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colors.primary.muted,
                      borderRadius: context.radius.sm,
                    ),
                    child: OiLabel.body(
                      'Tappable area (tapped $_tapCount times)',
                    ),
                  ),
                ),
              ),
            ],
          ),

          // ── OiFocusTrap / OiTouchTarget / OiSelectionOverlay ──────────
          const ComponentShowcaseSection(
            title: 'Focus Trap, Touch Target & Selection Overlay',
            widgetName: 'OiFocusTrap / OiTouchTarget / OiSelectionOverlay',
            description:
                'Interaction primitives for focus management, touch target '
                'sizing, and selection visualization.',
            examples: [
              ComponentExample(
                title: 'Description',
                child: OiLabel.body(
                  'OiFocusTrap: traps keyboard focus within a subtree '
                  '(for modals/dialogs). Key parameters: child, '
                  'autoFocus.\n\n'
                  'OiTouchTarget: ensures a minimum 48x48 hit area for '
                  'accessibility. Wraps small interactive widgets.\n\n'
                  'OiSelectionOverlay: renders a selection highlight '
                  'overlay for selected items in lists or grids.',
                ),
              ),
            ],
          ),

          // ═══════════════════════════════════════════════════════════════
          // Scroll
          // ═══════════════════════════════════════════════════════════════

          // ── OiScrollbar ───────────────────────────────────────────────
          const ComponentShowcaseSection(
            title: 'Scrollbar',
            widgetName: 'OiScrollbar',
            description:
                'A themed scrollbar wrapper that matches the obers_ui design '
                'system. Supports both overlay and classic styles.',
            examples: [
              ComponentExample(
                title: 'Description',
                child: OiLabel.body(
                  'OiScrollbar wraps a ScrollView and renders a themed '
                  'scrollbar track and thumb. Key parameters: controller, '
                  'thumbVisibility, thickness, radius, child.',
                ),
              ),
            ],
          ),

          // ── Scroll Optimization Widgets ───────────────────────────────
          const ComponentShowcaseSection(
            title: 'Infinite Scroll, Virtual List & Virtual Grid',
            widgetName:
                'OiInfiniteScroll / OiVirtualList / OiVirtualGrid / '
                'OiSliverList / OiSliverGrid',
            description:
                'Scroll optimization widgets for handling large data sets '
                'efficiently.',
            examples: [
              ComponentExample(
                title: 'Description',
                child: OiLabel.body(
                  'OiInfiniteScroll: triggers a callback when the user '
                  'scrolls near the bottom to load more data.\n\n'
                  'OiVirtualList / OiVirtualGrid: only build visible items '
                  'for large data sets using viewport-aware rendering.\n\n'
                  'OiSliverList / OiSliverGrid: sliver-based list and grid '
                  'widgets for use inside CustomScrollView with lazy '
                  'building and efficient layout.',
                ),
              ),
            ],
          ),

          // ═══════════════════════════════════════════════════════════════
          // Clipboard
          // ═══════════════════════════════════════════════════════════════

          // ── OiPasteZone ───────────────────────────────────────────────
          const ComponentShowcaseSection(
            title: 'Paste Zone',
            widgetName: 'OiPasteZone',
            description:
                'A zone that receives pasted content from the clipboard '
                '(text, images, files).',
            examples: [
              ComponentExample(
                title: 'Description',
                child: OiLabel.body(
                  'OiPasteZone listens for paste events (Ctrl+V / Cmd+V) '
                  'and invokes callbacks with the pasted data. '
                  'Key parameters: onPasteText, onPasteImage, '
                  'onPasteFiles, child.',
                ),
              ),
            ],
          ),

          // ═══════════════════════════════════════════════════════════════
          // Onboarding
          // ═══════════════════════════════════════════════════════════════

          // ── OiTour ────────────────────────────────────────────────────
          const ComponentShowcaseSection(
            title: 'Tour',
            widgetName: 'OiTour',
            description:
                'A multi-step guided tour overlay that highlights UI '
                'elements and shows instructional tooltips.',
            examples: [
              ComponentExample(
                title: 'Description',
                child: OiLabel.body(
                  'OiTour displays a step-by-step guided tour with '
                  'spotlight highlights and instructional tooltips. '
                  'Key parameters: steps (List<OiTourStep>), onComplete, '
                  'onSkip, currentStep.',
                ),
              ),
            ],
          ),

          // ── OiSpotlight ───────────────────────────────────────────────
          const ComponentShowcaseSection(
            title: 'Spotlight',
            widgetName: 'OiSpotlight',
            description:
                'A spotlight/highlight overlay for tutorial and onboarding '
                'flows. Dims the background while highlighting a target '
                'widget.',
            examples: [
              ComponentExample(
                title: 'Description',
                child: OiLabel.body(
                  'OiSpotlight creates a dark overlay with a cutout '
                  'around the target widget, drawing attention to it. '
                  'Key parameters: targetKey, padding, borderRadius, '
                  'onDismiss, child.',
                ),
              ),
            ],
          ),

          // ── OiWhatsNew ────────────────────────────────────────────────
          ComponentShowcaseSection(
            title: "What's New",
            widgetName: 'OiWhatsNew',
            description:
                'A changelog dialog showing recent feature updates with '
                'optional version badges and icons.',
            examples: [
              ComponentExample(
                title: 'Changelog Dialog',
                child: OiWhatsNew(
                  items: const [
                    OiWhatsNewItem(
                      title: 'Dark Mode',
                      description:
                          'Full dark mode support across all components.',
                      icon: OiIcons.moon,
                      version: 'v2.1.0',
                    ),
                    OiWhatsNewItem(
                      title: 'File Explorer',
                      description:
                          'New drag-and-drop file management with folder '
                          'tree navigation.',
                      icon: OiIcons.folderOpen,
                      version: 'v2.0.0',
                    ),
                    OiWhatsNewItem(
                      title: 'Performance',
                      description:
                          'Virtual scrolling for lists with 10,000+ items.',
                      icon: OiIcons.zap,
                      version: 'v1.9.0',
                    ),
                  ],
                  onDismiss: () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
