import 'dart:async';

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
  final List<String> _reorderItems = ['Item A', 'Item B', 'Item C'];
  String? _pastedText;
  bool _spotlightActive = false;
  final GlobalKey _spotlightTarget = GlobalKey();

  // Animation demo state
  double _springValue = 0;
  bool _morphToggle = false;
  Timer? _loopTimer;
  double _pinchScale = 1;
  int _staggerKey = 0;
  final _animListController = OiAnimatedListController<String>();
  final List<String> _animListItems = [];
  int _animListCycle = 0;
  static const _animListAllItems = ['Apple', 'Banana', 'Cherry', 'Date'];

  @override
  void initState() {
    super.initState();
    _loopTimer = Timer.periodic(const Duration(milliseconds: 1500), (_) {
      if (!mounted) return;
      setState(() {
        _springValue = _springValue == 0.0 ? 1.0 : 0.0;
        _morphToggle = !_morphToggle;
        _staggerKey++;
      });
    });
    // Kick off animated list cycle after first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _runAnimListCycle();
    });
  }

  void _runAnimListCycle() {
    if (!mounted) return;
    // Insert items one by one, then remove them, then repeat.
    if (_animListCycle < _animListAllItems.length) {
      // Insert next item.
      final item = _animListAllItems[_animListCycle];
      _animListItems.add(item);
      _animListController.insert(_animListItems.length - 1, item);
      _animListCycle++;
      Future.delayed(const Duration(milliseconds: 600), _runAnimListCycle);
    } else if (_animListItems.isNotEmpty) {
      // Remove first item.
      _animListItems.removeAt(0);
      _animListController.remove(0);
      Future.delayed(const Duration(milliseconds: 600), _runAnimListCycle);
    } else {
      // All removed — restart cycle after a short pause.
      _animListCycle = 0;
      Future.delayed(const Duration(milliseconds: 800), _runAnimListCycle);
    }
  }

  @override
  void dispose() {
    _loopTimer?.cancel();
    super.dispose();
  }

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
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    OiLiveRing(
                      child: OiAvatar(
                        initials: 'JD',
                        semanticLabel: 'Live user',
                      ),
                    ),
                    SizedBox(width: 12),
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
          ComponentShowcaseSection(
            title: 'Cursor & Selection Presence',
            widgetName: 'OiCursorPresence / OiSelectionPresence',
            description:
                'Real-time collaboration indicators. OiCursorPresence shows '
                'named cursors for remote users. OiSelectionPresence '
                'highlights text or cell selections made by collaborators. \n\n'
                'OiCursorPresence renders labeled cursor markers at '
                  'remote user positions.\n'
                  'OiSelectionPresence overlays '
                  'colored highlights for remote selections. Both are '
                  'driven by a stream of presence events. Key parameters: '
                  'cursors, selections, userColors.',
            examples: [
              ComponentExample(
                title: 'Remote Cursors',
                child: SizedBox(
                  height: 120,
                  child: OiCursorPresence(
                    cursors: [
                      OiRemoteCursor(
                        userId: 'u1',
                        name: 'Alice',
                        color: const Color(0xFF4CAF50),
                        position: const Offset(80, 40),
                        lastMoved: DateTime.now(),
                      ),
                      OiRemoteCursor(
                        userId: 'u2',
                        name: 'Bob',
                        color: const Color(0xFF2196F3),
                        position: const Offset(200, 70),
                        lastMoved: DateTime.now(),
                      ),
                    ],
                    child: Container(
                      width: double.infinity,
                      height: 120,
                      decoration: BoxDecoration(
                        color: colors.surfaceSubtle,
                        borderRadius: context.radius.sm,
                      ),
                      child: const Center(
                        child: OiLabel.body('Collaborative canvas'),
                      ),
                    ),
                  ),
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

          // ── OiSpring ──────────────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Spring',
            widgetName: 'OiSpring',
            description:
                'Physics-based spring animation wrapper with configurable '
                'mass, stiffness, and damping. The box below bounces back '
                'and forth on an infinite loop.',
            examples: [
              ComponentExample(
                title: 'Looping Spring Translation',
                child: ClipRect(
                  child: SizedBox(
                    height: 60,
                    child: OiSpring(
                      value: _springValue,
                      stiffness: 180,
                      damping: 12,
                      builder: (context, v, child) => Align(
                        alignment: Alignment(
                          (-1.0 + v * 2.0).clamp(-1.0, 1.0),
                          0,
                        ),
                        child: child,
                      ),
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: colors.primary.base,
                          borderRadius: context.radius.sm,
                        ),
                        child: const Center(
                          child: OiIcon(
                            icon: OiIcons.arrowRight,
                            label: 'spring',
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // ── OiStagger ──────────────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Stagger',
            widgetName: 'OiStagger',
            description:
                'Staggers entrance animations across a list of children '
                'with configurable delay. Items fade in one after another.',
            examples: [
              ComponentExample(
                title: 'Staggered Entrance',
                child: OiStagger(
                  key: ValueKey('stagger-$_staggerKey'),
                  staggerDelay: const Duration(milliseconds: 100),
                  children: [
                    Container(
                      height: 40,
                      width: double.infinity,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colors.surfaceSubtle,
                        borderRadius: context.radius.sm,
                      ),
                      child: const OiLabel.body('Item 1 — fades in first'),
                    ),
                    Container(
                      height: 40,
                      width: double.infinity,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colors.surfaceSubtle,
                        borderRadius: context.radius.sm,
                      ),
                      child: const OiLabel.body('Item 2 — fades in second'),
                    ),
                    Container(
                      height: 40,
                      width: double.infinity,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colors.surfaceSubtle,
                        borderRadius: context.radius.sm,
                      ),
                      child: const OiLabel.body('Item 3 — fades in third'),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ── OiMorph ────────────────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Morph',
            widgetName: 'OiMorph',
            description:
                'Smoothly transitions between two child widgets with '
                'cross-fade and size interpolation. Toggles on a loop '
                'between two states.',
            examples: [
              ComponentExample(
                title: 'Looping Morph Transition',
                child: OiMorph(
                  transition: OiTransition.fadeScale,
                  child: _morphToggle
                      ? Container(
                          key: const ValueKey('state-a'),
                          height: 60,
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: colors.success.muted,
                            borderRadius: context.radius.sm,
                          ),
                          child: const Center(
                            child: OiLabel.body('State A — Active'),
                          ),
                        )
                      : Container(
                          key: const ValueKey('state-b'),
                          height: 60,
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: colors.info.muted,
                            borderRadius: context.radius.sm,
                          ),
                          child: const Center(
                            child: OiLabel.body('State B — Idle'),
                          ),
                        ),
                ),
              ),
            ],
          ),

          // ── OiAnimatedList ─────────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Animated List',
            widgetName: 'OiAnimatedList',
            description:
                'An animated list that auto-animates item insertions and '
                'removals with fade transitions.',
            examples: [
              ComponentExample(
                title: 'Animated Items',
                child: SizedBox(
                  height: 200,
                  child: OiAnimatedList<String>(
                    shrinkWrap: true,
                    controller: _animListController,
                    items: const [],
                    itemBuilder: (context, item, animation, index) =>
                        SizeTransition(
                      sizeFactor: animation,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: colors.surfaceSubtle,
                            borderRadius: context.radius.sm,
                          ),
                          child: OiLabel.body(item),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // ═══════════════════════════════════════════════════════════════
          // Drag & Drop
          // ═══════════════════════════════════════════════════════════════

          // ── OiReorderable ─────────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Reorderable',
            widgetName: 'OiReorderable',
            description:
                'A drag-to-reorder list that supports both touch and '
                'pointer-based reordering with animated transitions. \n\n'
                'OiReorderable wraps a list of items and enables '
                  'drag-to-reorder. Key parameters: items, itemBuilder, '
                  'onReorder, dragHandleBuilder. Provides haptic feedback '
                  'and animated placeholder positioning.',
            examples: [
              ComponentExample(
                title: 'Drag to Reorder',
                child: OiReorderable(
                  shrinkWrap: true,
                  onReorder: (oldIndex, newIndex) {
                    setState(() {
                      final adjustedIndex =
                          newIndex > oldIndex ? newIndex - 1 : newIndex;
                      final item = _reorderItems.removeAt(oldIndex);
                      _reorderItems.insert(adjustedIndex, item);
                    });
                  },
                  children: [
                    for (final item in _reorderItems)
                      Container(
                        key: ValueKey(item),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colors.surface,
                          border: Border.all(color: colors.borderSubtle),
                          borderRadius: context.radius.sm,
                        ),
                        child: OiLabel.body('Drag me — $item'),
                      ),
                  ],
                ),
              ),
            ],
          ),

          // ── OiDraggable / OiDropZone / OiDragGhost ────────────────────
          ComponentShowcaseSection(
            title: 'Draggable, Drop Zone & Drag Ghost',
            widgetName: 'OiDraggable / OiDropZone / OiDragGhost',
            description:
                'Low-level drag-and-drop primitives for custom drag '
                'interactions. \n\n'
                'OiDraggable: makes a widget draggable with typed data '
                  'payload. Key parameters: data, child, feedback.\n'
                  'OiDropZone: defines a zone that accepts dropped items. '
                  'Key parameters: onDrop, onHover, accepts.\n'
                  'OiDragGhost: the visual feedback widget shown during '
                  'a drag operation. Customizable opacity and scale.',
            examples: [
              ComponentExample(
                title: 'Drag & Drop',
                child: Row(
                  children: [
                    OiDraggable<String>(
                      data: 'hello',
                      feedback: OiDragGhost(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: colors.primary.base,
                            borderRadius: context.radius.sm,
                          ),
                          child: const OiLabel.body('Dragging...'),
                        ),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colors.surfaceSubtle,
                          borderRadius: context.radius.sm,
                        ),
                        child: const OiLabel.body('Drag me'),
                      ),
                    ),
                    SizedBox(width: spacing.md),
                    Expanded(
                      child: OiDropZone<String>(
                        onAccept: (_) {},
                        builder: (context, state) => Container(
                          height: 60,
                          decoration: BoxDecoration(
                            color: state == OiDropState.hovering
                                ? colors.primary.muted
                                : colors.surfaceSubtle,
                            borderRadius: context.radius.sm,
                            border: Border.all(
                              color: state == OiDropState.hovering
                                  ? colors.primary.base
                                  : colors.borderSubtle,
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: OiLabel.body(
                              state == OiDropState.hovering
                                  ? 'Release to drop'
                                  : 'Drop here',
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ═══════════════════════════════════════════════════════════════
          // Gestures
          // ═══════════════════════════════════════════════════════════════

          // ── OiSwipeable ───────────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Swipeable',
            widgetName: 'OiSwipeable',
            description:
                'A swipe-to-dismiss or swipe-to-reveal widget for list '
                'items. Supports left and right swipe actions. \n\n'
                'OiSwipeable enables swipe gestures on list items. '
                  'Key parameters: onSwipeLeft, onSwipeRight, '
                  'leftActions, rightActions, dismissThreshold, child.',
            examples: [
              ComponentExample(
                title: 'Swipe Actions',
                child: OiSwipeable(
                  leadingActions: [
                    OiSwipeAction(
                      label: 'Archive',
                      color: colors.info.base,
                      icon: OiIcons.archive,
                      onTap: () {},
                    ),
                  ],
                  trailingActions: [
                    OiSwipeAction(
                      label: 'Delete',
                      color: colors.error.base,
                      icon: OiIcons.trash2,
                      onTap: () {},
                    ),
                  ],
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      border: Border.all(color: colors.borderSubtle),
                    ),
                    child: const OiLabel.body(
                      'Swipe left or right to reveal actions',
                    ),
                  ),
                ),
              ),
            ],
          ),

          // ── OiPinchZoom / OiDoubleTap / OiLongPressMenu ──────────────
          ComponentShowcaseSection(
            title: 'Pinch Zoom, Double Tap & Long Press Menu',
            widgetName: 'OiPinchZoom / OiDoubleTap / OiLongPressMenu',
            description: 'Gesture handlers for advanced touch interactions. \n\n'
                'OiPinchZoom: wraps a child with pinch-to-zoom and '
                  'pan gestures. Key parameters: minScale, maxScale, '
                  'child.\n'
                  'OiDoubleTap: detects double-tap gestures with '
                  'configurable timeout. Key parameters: onDoubleTap, '
                  'child.\n'
                  'OiLongPressMenu: shows a context menu on long press. '
                  'Key parameters: items, onSelected, child.',
            examples: [
              ComponentExample(
                title: 'Pinch to Zoom',
                child: Column(
                  children: [
                    SizedBox(
                      height: 150,
                      width: double.infinity,
                      child: OiPinchZoom(
                        maxScale: 3,
                        onScaleChanged: (scale) =>
                            setState(() => _pinchScale = scale),
                        child: Container(
                          height: 150,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: colors.surfaceSubtle,
                            borderRadius: context.radius.sm,
                          ),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const OiIcon(
                                  icon: OiIcons.search,
                                  label: 'zoom',
                                  size: 32,
                                ),
                                const SizedBox(height: 8),
                                OiLabel.body(
                                  'Scale: ${_pinchScale.toStringAsFixed(2)}x',
                                ),
                                const SizedBox(height: 4),
                                const OiLabel.caption(
                                  'Pinch, scroll-wheel, or trackpad to zoom',
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ComponentExample(
                title: 'Long Press Menu',
                child: OiLongPressMenu(
                  items: [
                    OiLongPressMenuItem(
                      label: 'Copy',
                      icon: OiIcons.copy,
                      onTap: () {},
                    ),
                    OiLongPressMenuItem(
                      label: 'Edit',
                      icon: OiIcons.pencil,
                      onTap: () {},
                    ),
                    OiLongPressMenuItem(
                      label: 'Delete',
                      icon: OiIcons.trash2,
                      onTap: () {},
                    ),
                  ],
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colors.surfaceSubtle,
                      borderRadius: context.radius.sm,
                    ),
                    child: const OiLabel.body('Long press for context menu'),
                  ),
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
          ComponentShowcaseSection(
            title: 'Focus Trap, Touch Target & Selection Overlay',
            widgetName: 'OiFocusTrap / OiTouchTarget / OiSelectionOverlay',
            description:
                'Interaction primitives for focus management, touch target '
                'sizing, and selection visualization. \n\n'
                'OiFocusTrap: traps keyboard focus within a subtree '
                  '(for modals/dialogs). Key parameters: child, '
                  'autoFocus.\n'
                  'OiTouchTarget: ensures a minimum 48x48 hit area for '
                  'accessibility. Wraps small interactive widgets.\n'
                  'OiSelectionOverlay: renders a selection highlight '
                  'overlay for selected items in lists or grids.',
            examples: [
              ComponentExample(
                title: 'Focus Trap',
                child: OiFocusTrap(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colors.surfaceSubtle,
                      borderRadius: context.radius.sm,
                      border: Border.all(color: colors.borderSubtle),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const OiLabel.body('Focus is trapped in this area'),
                        SizedBox(height: spacing.sm),
                        OiButton.primary(
                          label: 'Focusable Button',
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const ComponentExample(
                title: 'Touch Target',
                child: OiTouchTarget(
                  child: OiIcon(
                    icon: OiIcons.settings,
                    label: 'Settings',
                    size: 16,
                  ),
                ),
              ),
            ],
          ),

          // ═══════════════════════════════════════════════════════════════
          // Scroll
          // ═══════════════════════════════════════════════════════════════

          // ── OiScrollbar ───────────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Scrollbar',
            widgetName: 'OiScrollbar',
            description:
                'A themed scrollbar wrapper that matches the obers_ui design '
                'system. Supports both overlay and classic styles. '
                'Wraps a ScrollView and renders a themed scrollbar track '
                'and thumb. Key parameters: controller, '
                'thumbVisibility, thickness, radius, child.',
            examples: [
              ComponentExample(
                title: 'Themed Scrollbar',
                child: SizedBox(
                  height: 150,
                  child: OiScrollbar(
                    alwaysShow: true,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          for (int i = 1; i <= 20; i++)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: OiLabel.body('Scrollable item $i'),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // ── Scroll Optimization Widgets ───────────────────────────────
          ComponentShowcaseSection(
            title: 'Infinite Scroll, Virtual List & Virtual Grid',
            widgetName:
                'OiInfiniteScroll / OiVirtualList / OiVirtualGrid / '
                'OiSliverList / OiSliverGrid',
            description:
                'Scroll optimization widgets for handling large data sets '
                'efficiently. '
                'OiInfiniteScroll: triggers a callback when the user '
                'scrolls near the bottom to load more data.\n\n'
                'OiVirtualList / OiVirtualGrid: only build visible items '
                'for large data sets using viewport-aware rendering.\n'
                'OiSliverList / OiSliverGrid: sliver-based list and grid '
                'widgets for use inside CustomScrollView with lazy '
                'building and efficient layout.',
            examples: [
              ComponentExample(
                title: 'Virtual List',
                child: SizedBox(
                  height: 200,
                  child: OiVirtualList(
                    itemCount: 100,
                    itemBuilder: (context, index) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colors.surfaceSubtle,
                          borderRadius: context.radius.sm,
                        ),
                        child: OiLabel.body('Virtual item ${index + 1}'),
                      ),
                    ),
                  ),
                ),
              ),
              ComponentExample(
                title: 'Virtual Grid',
                child: SizedBox(
                  height: 200,
                  child: OiVirtualGrid(
                    itemCount: 20,
                    crossAxisCount: 3,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    itemBuilder: (context, index) => Container(
                      decoration: BoxDecoration(
                        color: colors.surfaceSubtle,
                        borderRadius: context.radius.sm,
                      ),
                      child: Center(
                        child: OiLabel.body('${index + 1}'),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // ═══════════════════════════════════════════════════════════════
          // Clipboard
          // ═══════════════════════════════════════════════════════════════

          // ── OiPasteZone ───────────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Paste Zone',
            widgetName: 'OiPasteZone',
            description:
                'A zone that receives pasted content from the clipboard '
                '(text, images, files). '
                'Listens for paste events (Ctrl+V / Cmd+V) '
                'and invokes callbacks with the pasted data. '
                'Key parameters: onPaste, child.',
            examples: [
              ComponentExample(
                title: 'Paste Area',
                child: OiPasteZone(
                  onPaste: (text) =>
                      setState(() => _pastedText = text),
                  child: Container(
                    height: 100,
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colors.surfaceSubtle,
                      borderRadius: context.radius.sm,
                      border: Border.all(
                        color: colors.borderSubtle,
                      ),
                    ),
                    child: Center(
                      child: OiLabel.body(
                        _pastedText ??
                            'Click here and press Ctrl+V / Cmd+V to paste',
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // ═══════════════════════════════════════════════════════════════
          // Onboarding
          // ═══════════════════════════════════════════════════════════════

          // ── OiTour ────────────────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Tour',
            widgetName: 'OiTour',
            description:
                'A multi-step guided tour overlay that highlights UI '
                'elements and shows instructional tooltips. '
                'Displays a step-by-step guided tour with '
                'spotlight highlights and instructional tooltips. '
                'Key parameters: steps (List<OiTourStep>), onComplete, '
                'onSkip, currentStep.',
            examples: [
              ComponentExample(
                title: 'Tour Overlay',
                child: SizedBox(
                  height: 120,
                  child: OiTour(
                    steps: [
                      OiTourStep(
                        target: GlobalKey(),
                        title: 'Welcome',
                        description: 'This is the first step of the tour.',
                      ),
                      OiTourStep(
                        target: GlobalKey(),
                        title: 'Features',
                        description: 'Discover the key features here.',
                      ),
                      OiTourStep(
                        target: GlobalKey(),
                        title: 'Get Started',
                        description: 'You are ready to go!',
                      ),
                    ],
                    onComplete: () {},
                    onSkip: () {},
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colors.surfaceSubtle,
                        borderRadius: context.radius.sm,
                      ),
                      child: const Center(
                        child: OiLabel.body(
                          'Tour target area — activate to see guided steps',
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // ── OiSpotlight ───────────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Spotlight',
            widgetName: 'OiSpotlight',
            description:
                'A spotlight/highlight overlay for tutorial and onboarding '
                'flows. Dims the background while highlighting a target '
                'widget. Creates a dark overlay with a cutout '
                'around the target widget, drawing attention to it. '
                'Key parameters: target, padding, borderRadius, '
                'onTapOutside, child.',
            examples: [
              ComponentExample(
                title: 'Spotlight Highlight',
                child: SizedBox(
                  height: 180,
                  child: OiSpotlight(
                    target: _spotlightTarget,
                    active: _spotlightActive,
                    onTapOutside: () =>
                        setState(() => _spotlightActive = false),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          key: _spotlightTarget,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: colors.surfaceSubtle,
                            borderRadius: context.radius.sm,
                          ),
                          child: const OiLabel.body(
                            'This widget gets spotlighted',
                          ),
                        ),
                        SizedBox(height: spacing.md),
                        OiButton.primary(
                          label: _spotlightActive
                              ? 'Spotlight Active'
                              : 'Activate Spotlight',
                          onTap: () =>
                              setState(() => _spotlightActive = true),
                        ),
                      ],
                    ),
                  ),
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
                child: SizedBox(
                  height: 350,
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
              ),
            ],
          ),
        ],
      ),
    );
  }
}
