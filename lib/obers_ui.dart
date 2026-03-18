/// A comprehensive Flutter UI kit with design tokens, responsive utilities,
/// and accessible components.
///
/// To use, import `package:obers_ui/obers_ui.dart`.
///
/// {@category Getting Started}
library;

// ── Foundation: Theme ────────────────────────────────────────────────────────

export 'src/foundation/theme/oi_animation_config.dart';
export 'src/foundation/theme/oi_color_scheme.dart';
export 'src/foundation/theme/oi_color_swatch.dart';
export 'src/foundation/theme/oi_component_themes.dart';
export 'src/foundation/theme/oi_decoration_theme.dart';
export 'src/foundation/theme/oi_effects_theme.dart';
export 'src/foundation/theme/oi_radius_scale.dart';
export 'src/foundation/theme/oi_shadow_scale.dart';
export 'src/foundation/theme/oi_spacing_scale.dart';
export 'src/foundation/theme/oi_text_theme.dart';
export 'src/foundation/theme/oi_theme.dart';
export 'src/foundation/theme/oi_theme_data.dart';

// ── Foundation: Core Services ────────────────────────────────────────────────

export 'src/foundation/oi_accessibility.dart';
export 'src/foundation/oi_app.dart';
export 'src/foundation/oi_overlays.dart';
export 'src/foundation/oi_platform.dart';
export 'src/foundation/oi_responsive.dart';
export 'src/foundation/oi_span.dart';
export 'src/foundation/oi_shortcut_scope.dart';
export 'src/foundation/oi_tour_scope.dart';
export 'src/foundation/oi_undo_stack.dart';

// ── Foundation: Persistence ──────────────────────────────────────────────────

export 'src/foundation/persistence/drivers/oi_in_memory_driver.dart';
export 'src/foundation/persistence/drivers/oi_local_storage_driver.dart';
export 'src/foundation/persistence/oi_settings_data.dart';
export 'src/foundation/persistence/oi_settings_driver.dart';
export 'src/foundation/persistence/oi_settings_mixin.dart';
export 'src/foundation/persistence/oi_settings_provider.dart';

// ── Primitives: Interaction ──────────────────────────────────────────────────

export 'src/primitives/interaction/oi_focus_trap.dart';
export 'src/primitives/interaction/oi_tappable.dart';

// ── Primitives: Display ──────────────────────────────────────────────────────

export 'src/primitives/display/oi_divider.dart';
export 'src/primitives/display/oi_icon.dart';
export 'src/components/display/oi_image.dart';
export 'src/primitives/display/oi_label.dart';
export 'src/primitives/display/oi_surface.dart';

// ── Primitives: Input ────────────────────────────────────────────────────────

export 'src/primitives/input/oi_raw_input.dart';

// ── Primitives: Layout ───────────────────────────────────────────────────────

export 'src/primitives/layout/oi_aspect_ratio.dart';
export 'src/primitives/layout/oi_column.dart';
export 'src/primitives/layout/oi_container.dart';
export 'src/primitives/layout/oi_grid.dart';
export 'src/primitives/layout/oi_masonry.dart';
export 'src/primitives/layout/oi_page.dart';
export 'src/primitives/layout/oi_row.dart';
export 'src/primitives/layout/oi_section.dart';
export 'src/primitives/layout/oi_spacer.dart';
export 'src/primitives/layout/oi_wrap_layout.dart';

// ── Primitives: Overlay ──────────────────────────────────────────────────────

export 'src/primitives/overlay/oi_floating.dart';
export 'src/primitives/overlay/oi_portal.dart';
export 'src/primitives/overlay/oi_visibility.dart';

// ── Primitives: Scroll ───────────────────────────────────────────────────────

export 'src/primitives/scroll/oi_infinite_scroll.dart';
export 'src/primitives/scroll/oi_scrollbar.dart';
export 'src/primitives/scroll/oi_virtual_grid.dart';
export 'src/primitives/scroll/oi_virtual_list.dart';

// ── Primitives: Gesture ──────────────────────────────────────────────────────

export 'src/primitives/gesture/oi_double_tap.dart';
export 'src/primitives/gesture/oi_long_press_menu.dart';
export 'src/primitives/gesture/oi_pinch_zoom.dart';
export 'src/primitives/gesture/oi_swipeable.dart';

// ── Primitives: Drag & Drop ──────────────────────────────────────────────────

export 'src/primitives/drag_drop/oi_drag_ghost.dart';
export 'src/primitives/drag_drop/oi_draggable.dart';
export 'src/primitives/drag_drop/oi_drop_zone.dart';
export 'src/primitives/drag_drop/oi_reorderable.dart';

// ── Primitives: Clipboard ────────────────────────────────────────────────────

export 'src/primitives/clipboard/oi_copy_button.dart';
export 'src/primitives/clipboard/oi_copyable.dart';
export 'src/primitives/clipboard/oi_paste_zone.dart';

// ── Primitives: Animation ────────────────────────────────────────────────────

export 'src/primitives/animation/oi_animated_list.dart';
export 'src/primitives/animation/oi_morph.dart';
export 'src/primitives/animation/oi_pulse.dart';
export 'src/primitives/animation/oi_shimmer.dart';
export 'src/primitives/animation/oi_spring.dart';
export 'src/primitives/animation/oi_stagger.dart';

// ── Components: Buttons ──────────────────────────────────────────────────────

export 'src/components/buttons/oi_button.dart';
export 'src/components/buttons/oi_button_group.dart';
export 'src/components/buttons/oi_icon_button.dart';
export 'src/components/buttons/oi_toggle_button.dart';

// ── Components: Inputs ───────────────────────────────────────────────────────

export 'src/components/inputs/oi_checkbox.dart';
export 'src/components/inputs/oi_color_input.dart';
export 'src/components/inputs/oi_date_input.dart';
export 'src/components/inputs/oi_file_input.dart';
export 'src/components/inputs/oi_number_input.dart';
export 'src/components/inputs/oi_radio.dart';
export 'src/components/inputs/oi_select.dart';
export 'src/components/inputs/oi_slider.dart';
export 'src/components/inputs/oi_switch.dart';
export 'src/components/inputs/oi_tag_input.dart';
export 'src/components/inputs/oi_text_input.dart';
export 'src/components/inputs/oi_time_input.dart';

// ── Components: Inline Edit ──────────────────────────────────────────────────

export 'src/components/inline_edit/oi_editable.dart';
export 'src/components/inline_edit/oi_editable_date.dart';
export 'src/components/inline_edit/oi_editable_number.dart';
export 'src/components/inline_edit/oi_editable_select.dart';
export 'src/components/inline_edit/oi_editable_text.dart';

// ── Components: Display ──────────────────────────────────────────────────────

export 'src/components/display/oi_avatar.dart';
export 'src/components/display/oi_badge.dart';
export 'src/components/display/oi_card.dart';
export 'src/components/display/oi_code_block.dart';
export 'src/components/display/oi_diff_view.dart';
export 'src/components/display/oi_empty_state.dart';
export 'src/components/display/oi_list_tile.dart';
export 'src/components/display/oi_markdown.dart';
export 'src/components/display/oi_metric.dart';
export 'src/components/display/oi_popover.dart';
export 'src/components/display/oi_progress.dart';
export 'src/components/display/oi_skeleton_group.dart';
export 'src/components/display/oi_tooltip.dart';

// ── Components: Feedback ─────────────────────────────────────────────────────

export 'src/components/feedback/oi_reaction_bar.dart';
export 'src/components/feedback/oi_scale_rating.dart';
export 'src/components/feedback/oi_sentiment.dart';
export 'src/components/feedback/oi_star_rating.dart';
export 'src/components/feedback/oi_thumbs.dart';

// ── Components: Overlays ─────────────────────────────────────────────────────

export 'src/components/overlays/oi_context_menu.dart';
export 'src/components/overlays/oi_dialog.dart';
export 'src/components/overlays/oi_sheet.dart';
export 'src/components/overlays/oi_toast.dart';

// ── Components: Navigation ───────────────────────────────────────────────────

export 'src/components/navigation/oi_accordion.dart';
export 'src/components/navigation/oi_bottom_bar.dart';
export 'src/components/navigation/oi_breadcrumbs.dart';
export 'src/components/navigation/oi_date_picker.dart';
export 'src/components/navigation/oi_drawer.dart';
export 'src/components/navigation/oi_emoji_picker.dart';
export 'src/components/navigation/oi_tabs.dart';
export 'src/components/navigation/oi_time_picker.dart';

// ── Components: Panels ───────────────────────────────────────────────────────

export 'src/components/panels/oi_panel.dart';
export 'src/components/panels/oi_resizable.dart';
export 'src/components/panels/oi_split_pane.dart';

// ── Composites: Data ─────────────────────────────────────────────────────────

export 'src/composites/data/oi_pagination_controller.dart';
export 'src/composites/data/oi_table.dart';
export 'src/composites/data/oi_table_controller.dart';
export 'src/composites/data/oi_tree.dart';

// ── Composites: Navigation ───────────────────────────────────────────────────

export 'src/composites/navigation/oi_arrow_nav.dart';
export 'src/composites/navigation/oi_filter_bar.dart';
export 'src/composites/navigation/oi_nav_menu.dart';
export 'src/composites/navigation/oi_shortcuts.dart';
export 'src/composites/navigation/oi_sidebar.dart';

// ── Composites: Forms ────────────────────────────────────────────────────────

export 'src/composites/forms/oi_form.dart';
export 'src/composites/forms/oi_stepper.dart';
export 'src/composites/forms/oi_wizard.dart';

// ── Composites: Search ───────────────────────────────────────────────────────

export 'src/composites/search/oi_combo_box.dart';
export 'src/composites/search/oi_command_bar.dart';
export 'src/composites/search/oi_search.dart';

// ── Composites: Editors ──────────────────────────────────────────────────────

export 'src/composites/editors/oi_rich_editor.dart';
export 'src/composites/editors/oi_smart_input.dart';

// ── Composites: Social ───────────────────────────────────────────────────────

export 'src/composites/social/oi_avatar_stack.dart';
export 'src/composites/social/oi_cursor_presence.dart';
export 'src/composites/social/oi_live_ring.dart';
export 'src/composites/social/oi_selection_presence.dart';
export 'src/composites/social/oi_typing_indicator.dart';

// ── Composites: Onboarding ───────────────────────────────────────────────────

export 'src/composites/onboarding/oi_spotlight.dart';
export 'src/composites/onboarding/oi_tour.dart';
export 'src/composites/onboarding/oi_whats_new.dart';

// ── Composites: Scheduling ───────────────────────────────────────────────────

export 'src/composites/scheduling/oi_calendar.dart';
export 'src/composites/scheduling/oi_gantt.dart';
export 'src/composites/scheduling/oi_scheduler.dart';
export 'src/composites/scheduling/oi_timeline.dart';

// ── Composites: Workflow ─────────────────────────────────────────────────────

export 'src/composites/workflow/oi_flow_graph.dart';
export 'src/composites/workflow/oi_pipeline.dart';
export 'src/composites/workflow/oi_state_diagram.dart';

// ── Composites: Visualization ────────────────────────────────────────────────

export 'src/composites/visualization/oi_funnel_chart.dart';
export 'src/composites/visualization/oi_gauge.dart';
export 'src/composites/visualization/oi_heatmap.dart';
export 'src/composites/visualization/oi_radar_chart.dart';
export 'src/composites/visualization/oi_sankey.dart';
export 'src/composites/visualization/oi_treemap.dart';

// ── Composites: Media ────────────────────────────────────────────────────────

export 'src/composites/media/oi_gallery.dart' hide OiSelectionMode;
export 'src/composites/media/oi_image_annotator.dart';
export 'src/composites/media/oi_image_cropper.dart';
export 'src/composites/media/oi_lightbox.dart';
export 'src/composites/media/oi_video_player.dart';

// ── Modules ──────────────────────────────────────────────────────────────────

export 'src/modules/oi_activity_feed.dart';
export 'src/modules/oi_chat.dart' hide OiFileData, OiReactionData;
export 'src/modules/oi_comments.dart';
export 'src/modules/oi_dashboard.dart';
export 'src/modules/oi_file_manager.dart';
export 'src/modules/oi_kanban.dart';
export 'src/modules/oi_list_view.dart' hide OiSelectionMode;
export 'src/modules/oi_metadata_editor.dart';
export 'src/modules/oi_notification_center.dart';
export 'src/modules/oi_permissions.dart';

// ── Models: Settings ─────────────────────────────────────────────────────────

export 'src/models/settings/oi_dashboard_settings.dart';
export 'src/models/settings/oi_file_explorer_settings.dart';
export 'src/models/settings/oi_kanban_settings.dart';
export 'src/models/settings/oi_list_view_settings.dart' hide OiListViewLayout;
export 'src/models/settings/oi_sidebar_settings.dart' hide OiSidebarMode;
export 'src/models/settings/oi_split_pane_settings.dart';
export 'src/models/settings/oi_table_settings.dart';

// ── Utils ────────────────────────────────────────────────────────────────────

export 'src/utils/calendar_utils.dart';
export 'src/utils/color_utils.dart';
export 'src/utils/file_utils.dart';
export 'src/utils/formatters.dart';
export 'src/utils/fuzzy_search.dart';
export 'src/utils/spring_physics.dart';

// ── Tools ────────────────────────────────────────────────────────────────────

export 'src/tools/oi_dynamic_theme.dart';
export 'src/tools/oi_playground.dart';
export 'src/tools/oi_theme_exporter.dart';
export 'src/tools/oi_theme_preview.dart';
