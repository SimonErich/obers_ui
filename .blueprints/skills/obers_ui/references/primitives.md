# Primitives (tier 1)

Overview: low-level layout, motion, scroll, gestures, clipboard, and interaction primitives. Use these when no higher-tier widget fits. [← Skill](../SKILL.md)

Paths: `lib/src/primitives/<category>/oi_*.dart`.

## Animation


| Name             | Path                              | Role                              |
| ---------------- | --------------------------------- | --------------------------------- |
| `OiAnimatedList` | `animation/oi_animated_list.dart` | List insert/remove animations     |
| `OiMorph`        | `animation/oi_morph.dart`         | Shape or layout morph transitions |
| `OiPulse`        | `animation/oi_pulse.dart`         | Pulsing emphasis                  |
| `OiShimmer`      | `animation/oi_shimmer.dart`       | Loading shimmer placeholder       |
| `OiSpring`       | `animation/oi_spring.dart`        | Spring-driven motion wrapper      |
| `OiStagger`      | `animation/oi_stagger.dart`       | Staggered child animations        |


## Clipboard


| Name           | Path                            | Role                               |
| -------------- | ------------------------------- | ---------------------------------- |
| `OiCopyButton` | `clipboard/oi_copy_button.dart` | Copies value to clipboard          |
| `OiCopyable`   | `clipboard/oi_copyable.dart`    | Wraps content with copy affordance |
| `OiPasteZone`  | `clipboard/oi_paste_zone.dart`  | Drop target for paste              |


## Display


| Name        | Path                      | Role                                 |
| ----------- | ------------------------- | ------------------------------------ |
| `OiDivider` | `display/oi_divider.dart` | Themed separator                     |
| `OiIcon`    | `display/oi_icon.dart`    | Themed icon with a11y                |
| `OiImage`   | `display/oi_image.dart`   | Constrained image primitive          |
| `OiLabel`   | `display/oi_label.dart`   | All text variants (H1–caption, etc.) |
| `OiSurface` | `display/oi_surface.dart` | Background/elevation surface         |


## Drag and drop


| Name            | Path                            | Role                        |
| --------------- | ------------------------------- | --------------------------- |
| `OiDraggable`   | `drag_drop/oi_draggable.dart`   | Draggable source            |
| `OiDragGhost`   | `drag_drop/oi_drag_ghost.dart`  | Drag preview ghost          |
| `OiDropZone`    | `drag_drop/oi_drop_zone.dart`   | Drop target                 |
| `OiReorderable` | `drag_drop/oi_reorderable.dart` | Reorder drag handle pattern |


## Gesture


| Name              | Path                              | Role                            |
| ----------------- | --------------------------------- | ------------------------------- |
| `OiDoubleTap`     | `gesture/oi_double_tap.dart`      | Double-tap detector             |
| `OiLongPressMenu` | `gesture/oi_long_press_menu.dart` | Long-press context menu trigger |
| `OiPinchZoom`     | `gesture/oi_pinch_zoom.dart`      | Pinch-to-zoom viewport          |
| `OiSwipeable`     | `gesture/oi_swipeable.dart`       | Swipe actions on a child        |


## Input


| Name         | Path                      | Role                                |
| ------------ | ------------------------- | ----------------------------------- |
| `OiRawInput` | `input/oi_raw_input.dart` | Low-level text input building block |


## Interaction


| Name            | Path                               | Role                             |
| --------------- | ---------------------------------- | -------------------------------- |
| `OiFocusTrap`   | `interaction/oi_focus_trap.dart`   | Keeps focus inside modal subtree |
| `OiTappable`    | `interaction/oi_tappable.dart`     | Hit target + feedback            |
| `OiTouchTarget` | `interaction/oi_touch_target.dart` | Minimum touch size wrapper       |


## Layout


| Name                 | Path                                | Role                        |
| -------------------- | ----------------------------------- | --------------------------- |
| `OiAspectRatio`      | `layout/oi_aspect_ratio.dart`       | Aspect ratio box            |
| `OiColumn`           | `layout/oi_column.dart`             | Vertical flex layout        |
| `OiRow`              | `layout/oi_row.dart`                | Horizontal flex layout      |
| `OiContainer`        | `layout/oi_container.dart`          | Box constraints + padding   |
| `OiGrid`             | `layout/oi_grid.dart`               | Responsive grid             |
| `OiGridZoomControls` | `layout/oi_grid_zoom_controls.dart` | Zoom UI for grids           |
| `OiMasonry`          | `layout/oi_masonry.dart`            | Masonry-style flow          |
| `OiPage`             | `layout/oi_page.dart`               | Page scaffold body          |
| `OiSection`          | `layout/oi_section.dart`            | Section with optional title |
| `OiSpacer`           | `layout/oi_spacer.dart`             | Fixed flex gap              |
| `OiWrapLayout`       | `layout/oi_wrap_layout.dart`        | Wrap flow                   |


## Overlay


| Name           | Path                         | Role                                |
| -------------- | ---------------------------- | ----------------------------------- |
| `OiFloating`   | `overlay/oi_floating.dart`   | Anchored floating layer             |
| `OiPortal`     | `overlay/oi_portal.dart`     | Portal overlay slot                 |
| `OiVisibility` | `overlay/oi_visibility.dart` | Visibility without removing subtree |


## Scroll


| Name               | Path                             | Role                         |
| ------------------ | -------------------------------- | ---------------------------- |
| `OiInfiniteScroll` | `scroll/oi_infinite_scroll.dart` | Infinite loading sliver/list |
| `OiScrollbar`      | `scroll/oi_scrollbar.dart`       | Themed scrollbar             |
| `OiSliverGrid`     | `scroll/oi_sliver_grid.dart`     | Sliver grid                  |
| `OiSliverList`     | `scroll/oi_sliver_list.dart`     | Sliver list                  |
| `OiVirtualGrid`    | `scroll/oi_virtual_grid.dart`    | Virtualized grid             |
| `OiVirtualList`    | `scroll/oi_virtual_list.dart`    | Virtualized list             |


