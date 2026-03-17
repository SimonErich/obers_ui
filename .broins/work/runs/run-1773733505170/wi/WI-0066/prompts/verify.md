## QA Engineer Role

You are the **QA Engineer** on this task.

Your responsibilities:
- Design the test strategy covering unit, integration, and E2E layers.
- Identify edge cases, boundary conditions, and failure scenarios.
- Define test-data requirements and fixture strategies.
- Ensure test coverage meets project thresholds (80%+ target).
- Validate that acceptance criteria are testable and tested.
- Review test quality — tests should be deterministic and independent.

Guidelines:
- Follow Arrange-Act-Assert (AAA) convention in all tests.
- Name tests clearly: "should [behaviour] when [condition]".
- Test behaviour, not implementation — focus on public APIs.
- Use mocks/stubs for external dependencies, not for value objects.
- Group related tests with `group()` blocks.
- Ensure tests are fast, isolated, and repeatable.

Required Output:
- Per-atom verdict: covered, partial, or missing.
- Evidence for each atom: file path and line range.
- Concrete recommended fix for every gap found.
- Overall pass/fail verdict with justification.


**Frontend/UX focus:**
- Test widget rendering across screen sizes and orientations.
- Verify accessibility properties (semantics, labels, contrast).
- Test navigation flows and deep-linking scenarios.
- Validate loading, error, and empty-state rendering.


**DX/Refactor focus:**
- Verify existing tests still pass after refactoring.
- Test new public API surface for completeness.
- Validate code-generation output if applicable.
- Ensure migration-guide examples compile and run.


## Specialist Considerations

Also consider the perspective of these specialists: UX/UI Expert, DevOps / SRE, Technical Writer. Apply their domain expertise where relevant.

IMPORTANT: You MUST respond with ONLY a JSON object. No markdown, no code fences, no prose, no explanation. Start your response with { and end with }.

# Verification Phase

## Work Item: Obersui Complete Library Specification V4 (Part 1/4)

**ID:** WI-0066
**Description:** - obers_ui — Complete Library Specification v4 > Table of Contents: [Naming & Conventions](#naming--conventions)
- obers_ui — Complete Library Specification v4 > Table of Contents: [Package Structure](#package-structure)
- obers_ui — Complete Library Specification v4 > Table of Contents: [Theming System](#theming-system)
**Risk:** medium

### Definition of Done

- [ ] Atom REQ-0001 fully implemented: obers_ui — Complete Library Specification v4 > Table of Contents: [Naming & Conventions](#naming--conventions)
- [ ] Atom REQ-0002 fully implemented: obers_ui — Complete Library Specification v4 > Table of Contents: [Package Structure](#package-structure)
- [ ] Atom REQ-0003 fully implemented: obers_ui — Complete Library Specification v4 > Table of Contents: [Theming System](#theming-system)
- [ ] All project checks pass (format, analyze, test)
- [ ] Coverage ledger updated for all atoms

## Requirement Atoms to Verify

- [ ] REQ-0001: [Naming & Conventions](#naming--conventions)
- [ ] REQ-0002: [Package Structure](#package-structure)
- [ ] REQ-0003: [Theming System](#theming-system)

Every item above must be verified individually. Do not skip any.

## Changed Files (STRICT SCOPE)

CRITICAL: You MUST ONLY read the files listed below. Do NOT explore, search, or read any other files in the codebase. Base your verification ENTIRELY on the diff content and these changed files.

- `.broins/tmp/drivers/claude/last_invocation.txt`
- `.broins/tmp/drivers/claude/last_pid.txt`
- `.broins/tmp/drivers/claude/last_raw_stream.jsonl`
- `.broins/work/autopilot/ap-1773727433798/epic-verification-checklist.json`
- `.broins/work/autopilot/ap-1773727433798/verification/epic-EPIC-0003-cycle-1.json`
- `.broins/work/autopilot/ap-1773727433798/verification/epic-EPIC-0003-cycle-2.json`
- `.broins/work/backlog.json`
- `.broins/work/runs/run-1773733505170/sentinel_WI-0066.txt`
- `.broins/work/runs/run-1773733505170/wi/WI-0066/classification.json`
- `.broins/work/runs/run-1773733505170/wi/WI-0066/events.jsonl`
- `.broins/work/runs/run-1773733505170/wi/WI-0066/prompts/implement.md`
- `.broins/work/runs/run-1773733505170/wi/WI-0066/prompts/plan.md`
- `.broins/work/runs/run-1773733505170/wi/WI-0066/results/implement.json`
- `.broins/work/runs/run-1773733505170/wi/WI-0066/task_packet.json`
- `.broins/work/runs/run-1773739762740/context/repo_digest.md`
- `.broins/work/runs/run-1773739762740/events.jsonl`
- `.broins/work/runs/run-1773739762740/sentinel_FV-1-373.txt`
- `.broins/work/runs/run-1773739762740/state.json`
- `.broins/work/runs/run-1773739762740/summary.json`
- `.broins/work/runs/run-1773739762740/wi/FV-1-373/classification.json`
- `.broins/work/runs/run-1773739762740/wi/FV-1-373/events.jsonl`
- `.broins/work/runs/run-1773739762740/wi/FV-1-373/prompt_manifest.json`
- `.broins/work/runs/run-1773739762740/wi/FV-1-373/prompts/implement.md`
- `.broins/work/runs/run-1773739762740/wi/FV-1-373/prompts/plan.md`
- `.broins/work/runs/run-1773739762740/wi/FV-1-373/prompts/qa_fix.md`
- `.broins/work/runs/run-1773739762740/wi/FV-1-373/prompts/self_critique.md`
- `.broins/work/runs/run-1773739762740/wi/FV-1-373/prompts/verify.md`
- `.broins/work/runs/run-1773739762740/wi/FV-1-373/results/implement.json`
- `.broins/work/runs/run-1773739762740/wi/FV-1-373/results/verify.json`
- `.broins/work/runs/run-1773739762740/wi/FV-1-373/results/verify_raw_0.txt`
- `.broins/work/runs/run-1773739762740/wi/FV-1-373/task_packet.json`
- `lib/obers_ui.dart`
- `lib/src/components/_internal/oi_input_frame.dart`
- `lib/src/components/buttons/oi_button.dart`
- `lib/src/components/buttons/oi_button_group.dart`
- `lib/src/components/buttons/oi_icon_button.dart`
- `lib/src/components/buttons/oi_toggle_button.dart`
- `lib/src/components/display/oi_avatar.dart`
- `lib/src/components/display/oi_badge.dart`
- `lib/src/components/display/oi_card.dart`
- `lib/src/components/display/oi_code_block.dart`
- `lib/src/components/display/oi_diff_view.dart`
- `lib/src/components/display/oi_empty_state.dart`
- `lib/src/components/display/oi_list_tile.dart`
- `lib/src/components/display/oi_markdown.dart`
- `lib/src/components/display/oi_metric.dart`
- `lib/src/components/display/oi_progress.dart`
- `lib/src/components/display/oi_skeleton_group.dart`
- `lib/src/components/display/oi_tooltip.dart`
- `lib/src/components/feedback/oi_reaction_bar.dart`
- `lib/src/components/feedback/oi_scale_rating.dart`
- `lib/src/components/feedback/oi_star_rating.dart`
- `lib/src/components/feedback/oi_thumbs.dart`
- `lib/src/components/inline_edit/oi_editable.dart`
- `lib/src/components/inline_edit/oi_editable_number.dart`
- `lib/src/components/inline_edit/oi_editable_select.dart`
- `lib/src/components/inline_edit/oi_editable_text.dart`
- `lib/src/components/inputs/oi_checkbox.dart`
- `lib/src/components/inputs/oi_color_input.dart`
- `lib/src/components/inputs/oi_date_input.dart`
- `lib/src/components/inputs/oi_file_input.dart`
- `lib/src/components/inputs/oi_number_input.dart`
- `lib/src/components/inputs/oi_radio.dart`
- `lib/src/components/inputs/oi_select.dart`
- `lib/src/components/inputs/oi_slider.dart`
- `lib/src/components/inputs/oi_switch.dart`
- `lib/src/components/inputs/oi_tag_input.dart`
- `lib/src/components/inputs/oi_time_input.dart`
- `lib/src/components/navigation/oi_bottom_bar.dart`
- `lib/src/components/navigation/oi_breadcrumbs.dart`
- `lib/src/components/navigation/oi_date_picker.dart`
- `lib/src/components/navigation/oi_emoji_picker.dart`
- `lib/src/components/navigation/oi_tabs.dart`
- `lib/src/components/navigation/oi_time_picker.dart`
- `lib/src/components/overlays/oi_context_menu.dart`
- `lib/src/components/overlays/oi_dialog.dart`
- `lib/src/components/overlays/oi_sheet.dart`
- `lib/src/components/overlays/oi_toast.dart`
- `lib/src/components/panels/oi_panel.dart`
- `lib/src/components/panels/oi_resizable.dart`
- `lib/src/components/panels/oi_split_pane.dart`
- `lib/src/composites/data/oi_pagination_controller.dart`
- `lib/src/composites/data/oi_table.dart`
- `lib/src/composites/data/oi_table_controller.dart`
- `lib/src/composites/data/oi_tree.dart`
- `lib/src/composites/editors/oi_rich_editor.dart`
- `lib/src/composites/editors/oi_smart_input.dart`
- `lib/src/composites/forms/oi_form.dart`
- `lib/src/composites/forms/oi_stepper.dart`
- `lib/src/composites/forms/oi_wizard.dart`
- `lib/src/composites/media/oi_gallery.dart`
- `lib/src/composites/media/oi_image_annotator.dart`
- `lib/src/composites/media/oi_image_cropper.dart`
- `lib/src/composites/media/oi_lightbox.dart`
- `lib/src/composites/media/oi_video_player.dart`
- `lib/src/composites/navigation/oi_nav_menu.dart`
- `lib/src/composites/navigation/oi_shortcuts.dart`
- `lib/src/composites/navigation/oi_sidebar.dart`
- `lib/src/composites/onboarding/oi_spotlight.dart`
- `lib/src/composites/onboarding/oi_tour.dart`
- `lib/src/composites/onboarding/oi_whats_new.dart`
- `lib/src/composites/scheduling/oi_calendar.dart`
- `lib/src/composites/scheduling/oi_gantt.dart`
- `lib/src/composites/scheduling/oi_scheduler.dart`
- `lib/src/composites/scheduling/oi_timeline.dart`
- `lib/src/composites/search/oi_combo_box.dart`
- `lib/src/composites/search/oi_command_bar.dart`
- `lib/src/composites/search/oi_search.dart`
- `lib/src/composites/social/oi_avatar_stack.dart`
- `lib/src/composites/social/oi_cursor_presence.dart`
- `lib/src/composites/social/oi_live_ring.dart`
- `lib/src/composites/social/oi_selection_presence.dart`
- `lib/src/composites/social/oi_typing_indicator.dart`
- `lib/src/composites/visualization/oi_funnel_chart.dart`
- `lib/src/composites/visualization/oi_heatmap.dart`
- `lib/src/composites/visualization/oi_radar_chart.dart`
- `lib/src/composites/visualization/oi_sankey.dart`
- `lib/src/composites/visualization/oi_treemap.dart`
- `lib/src/composites/workflow/oi_flow_graph.dart`
- `lib/src/composites/workflow/oi_pipeline.dart`
- `lib/src/composites/workflow/oi_state_diagram.dart`
- `lib/src/foundation/oi_accessibility.dart`
- `lib/src/foundation/oi_overlays.dart`
- `lib/src/foundation/oi_platform.dart`
- `lib/src/foundation/oi_responsive.dart`
- `lib/src/foundation/oi_undo_stack.dart`
- `lib/src/foundation/persistence/oi_settings_driver.dart`
- `lib/src/foundation/persistence/oi_settings_provider.dart`
- `lib/src/foundation/theme/oi_animation_config.dart`
- `lib/src/foundation/theme/oi_color_scheme.dart`
- `lib/src/foundation/theme/oi_color_swatch.dart`
- `lib/src/foundation/theme/oi_component_themes.dart`
- `lib/src/foundation/theme/oi_decoration_theme.dart`
- `lib/src/foundation/theme/oi_effects_theme.dart`
- `lib/src/foundation/theme/oi_shadow_scale.dart`
- `lib/src/foundation/theme/oi_spacing_scale.dart`
- `lib/src/foundation/theme/oi_text_theme.dart`
- `lib/src/foundation/theme/oi_theme.dart`
- `lib/src/foundation/theme/oi_theme_data.dart`
- `lib/src/models/settings/oi_dashboard_settings.dart`
- `lib/src/models/settings/oi_file_explorer_settings.dart`
- `lib/src/models/settings/oi_kanban_settings.dart`
- `lib/src/models/settings/oi_list_view_settings.dart`
- `lib/src/models/settings/oi_sidebar_settings.dart`
- `lib/src/models/settings/oi_split_pane_settings.dart`
- `lib/src/models/settings/oi_table_settings.dart`
- `lib/src/modules/oi_activity_feed.dart`
- `lib/src/modules/oi_chat.dart`
- `lib/src/modules/oi_comments.dart`
- `lib/src/modules/oi_file_manager.dart`
- `lib/src/modules/oi_kanban.dart`
- `lib/src/modules/oi_list_view.dart`
- `lib/src/modules/oi_metadata_editor.dart`
- `lib/src/modules/oi_notification_center.dart`
- `lib/src/modules/oi_permissions.dart`
- `lib/src/primitives/animation/oi_animated_list.dart`
- `lib/src/primitives/animation/oi_pulse.dart`
- `lib/src/primitives/animation/oi_spring.dart`
- `lib/src/primitives/animation/oi_stagger.dart`
- `lib/src/primitives/clipboard/oi_copy_button.dart`
- `lib/src/primitives/clipboard/oi_copyable.dart`
- `lib/src/primitives/clipboard/oi_paste_zone.dart`
- `lib/src/primitives/display/oi_divider.dart`
- `lib/src/primitives/display/oi_icon.dart`
- `lib/src/primitives/display/oi_image.dart`
- `lib/src/primitives/display/oi_surface.dart`
- `lib/src/primitives/drag_drop/oi_drag_ghost.dart`
- `lib/src/primitives/drag_drop/oi_draggable.dart`
- `lib/src/primitives/gesture/oi_long_press_menu.dart`
- `lib/src/primitives/gesture/oi_pinch_zoom.dart`
- `lib/src/primitives/gesture/oi_swipeable.dart`
- `lib/src/primitives/interaction/oi_tappable.dart`
- `lib/src/primitives/layout/oi_aspect_ratio.dart`
- `lib/src/primitives/layout/oi_grid.dart`
- `lib/src/primitives/layout/oi_spacer.dart`
- `lib/src/primitives/overlay/oi_floating.dart`
- `lib/src/primitives/overlay/oi_portal.dart`
- `lib/src/primitives/overlay/oi_visibility.dart`
- `lib/src/primitives/scroll/oi_infinite_scroll.dart`
- `lib/src/tools/oi_dynamic_theme.dart`
- `lib/src/tools/oi_playground.dart`
- `lib/src/tools/oi_theme_exporter.dart`
- `lib/src/tools/oi_theme_preview.dart`
- `lib/src/utils/calendar_utils.dart`
- `lib/src/utils/color_utils.dart`
- `lib/src/utils/file_utils.dart`
- `lib/src/utils/formatters.dart`
- `lib/src/utils/spring_physics.dart`
- `test/helpers/golden_helper.dart`
- `test/helpers/platform_helpers.dart`
- `test/helpers/pump_app.dart`
- `test/src/components/buttons/oi_button_group_test.dart`
- `test/src/components/buttons/oi_button_test.dart`
- `test/src/components/buttons/oi_icon_button_test.dart`
- `test/src/components/buttons/oi_toggle_button_test.dart`
- `test/src/components/display/oi_avatar_test.dart`
- `test/src/components/display/oi_badge_test.dart`
- `test/src/components/display/oi_card_test.dart`
- `test/src/components/display/oi_code_block_test.dart`
- `test/src/components/display/oi_diff_view_test.dart`
- `test/src/components/display/oi_empty_state_test.dart`
- `test/src/components/display/oi_list_tile_test.dart`
- `test/src/components/display/oi_markdown_test.dart`
- `test/src/components/display/oi_metric_test.dart`
- `test/src/components/display/oi_popover_test.dart`
- `test/src/components/display/oi_progress_test.dart`
- `test/src/components/display/oi_skeleton_group_test.dart`
- `test/src/components/display/oi_tooltip_test.dart`
- `test/src/components/feedback/oi_reaction_bar_test.dart`
- `test/src/components/feedback/oi_scale_rating_test.dart`
- `test/src/components/feedback/oi_sentiment_test.dart`
- `test/src/components/feedback/oi_star_rating_test.dart`
- `test/src/components/feedback/oi_thumbs_test.dart`
- `test/src/components/inline_edit/oi_editable_date_test.dart`
- `test/src/components/inline_edit/oi_editable_number_test.dart`
- `test/src/components/inline_edit/oi_editable_select_test.dart`
- `test/src/components/inline_edit/oi_editable_test.dart`
- `test/src/components/inline_edit/oi_editable_text_test.dart`
- `test/src/components/inputs/oi_checkbox_test.dart`
- `test/src/components/inputs/oi_color_input_test.dart`
- `test/src/components/inputs/oi_date_input_test.dart`
- `test/src/components/inputs/oi_file_input_test.dart`
- `test/src/components/inputs/oi_radio_test.dart`
- `test/src/components/inputs/oi_select_test.dart`
- `test/src/components/inputs/oi_slider_test.dart`
- `test/src/components/inputs/oi_switch_test.dart`
- `test/src/components/inputs/oi_tag_input_test.dart`
- `test/src/components/inputs/oi_text_input_test.dart`
- `test/src/components/inputs/oi_time_input_test.dart`
- `test/src/components/navigation/oi_accordion_test.dart`
- `test/src/components/navigation/oi_bottom_bar_test.dart`
- `test/src/components/navigation/oi_breadcrumbs_test.dart`
- `test/src/components/navigation/oi_date_picker_test.dart`
- `test/src/components/navigation/oi_drawer_test.dart`
- `test/src/components/navigation/oi_emoji_picker_test.dart`
- `test/src/components/navigation/oi_tabs_test.dart`
- `test/src/components/navigation/oi_time_picker_test.dart`
- `test/src/components/overlays/oi_context_menu_test.dart`
- `test/src/components/overlays/oi_dialog_test.dart`
- `test/src/components/overlays/oi_sheet_test.dart`
- `test/src/components/overlays/oi_toast_test.dart`
- `test/src/components/panels/oi_panel_test.dart`
- `test/src/components/panels/oi_resizable_test.dart`
- `test/src/components/panels/oi_split_pane_test.dart`
- `test/src/composites/data/oi_pagination_controller_test.dart`
- `test/src/composites/data/oi_table_controller_test.dart`
- `test/src/composites/data/oi_table_test.dart`
- `test/src/composites/editors/oi_rich_editor_test.dart`
- `test/src/composites/editors/oi_smart_input_test.dart`
- `test/src/composites/forms/oi_form_test.dart`
- `test/src/composites/forms/oi_stepper_test.dart`
- `test/src/composites/forms/oi_wizard_test.dart`
- `test/src/composites/media/oi_gallery_test.dart`
- `test/src/composites/media/oi_image_annotator_test.dart`
- `test/src/composites/media/oi_image_cropper_test.dart`
- `test/src/composites/media/oi_lightbox_test.dart`
- `test/src/composites/media/oi_video_player_test.dart`
- `test/src/composites/navigation/oi_arrow_nav_test.dart`
- `test/src/composites/navigation/oi_filter_bar_test.dart`
- `test/src/composites/navigation/oi_nav_menu_test.dart`
- `test/src/composites/navigation/oi_shortcuts_test.dart`
- `test/src/composites/navigation/oi_sidebar_test.dart`
- `test/src/composites/onboarding/oi_spotlight_test.dart`
- `test/src/composites/onboarding/oi_tour_test.dart`
- `test/src/composites/onboarding/oi_whats_new_test.dart`
- `test/src/composites/scheduling/oi_calendar_test.dart`
- `test/src/composites/scheduling/oi_gantt_test.dart`
- `test/src/composites/scheduling/oi_scheduler_test.dart`
- `test/src/composites/scheduling/oi_timeline_test.dart`
- `test/src/composites/search/oi_combo_box_test.dart`
- `test/src/composites/search/oi_command_bar_test.dart`
- `test/src/composites/search/oi_search_test.dart`
- `test/src/composites/social/oi_avatar_stack_test.dart`
- `test/src/composites/social/oi_cursor_presence_test.dart`
- `test/src/composites/social/oi_live_ring_test.dart`
- `test/src/composites/social/oi_selection_presence_test.dart`
- `test/src/composites/social/oi_typing_indicator_test.dart`
- `test/src/composites/visualization/oi_funnel_chart_test.dart`
- `test/src/composites/visualization/oi_gauge_test.dart`
- `test/src/composites/visualization/oi_heatmap_test.dart`
- `test/src/composites/visualization/oi_radar_chart_test.dart`
- `test/src/composites/visualization/oi_sankey_test.dart`
- `test/src/composites/visualization/oi_treemap_test.dart`
- `test/src/composites/workflow/oi_flow_graph_test.dart`
- `test/src/composites/workflow/oi_pipeline_test.dart`
- `test/src/composites/workflow/oi_state_diagram_test.dart`
- `test/src/foundation/oi_accessibility_test.dart`
- `test/src/foundation/oi_app_test.dart`
- `test/src/foundation/oi_overlays_test.dart`
- `test/src/foundation/oi_platform_test.dart`
- `test/src/foundation/oi_responsive_test.dart`
- `test/src/foundation/oi_undo_stack_test.dart`
- `test/src/foundation/persistence/drivers/oi_in_memory_driver_test.dart`
- `test/src/foundation/persistence/drivers/oi_local_storage_driver_test.dart`
- `test/src/foundation/persistence/oi_settings_mixin_test.dart`
- `test/src/foundation/theme/oi_decoration_theme_test.dart`
- `test/src/foundation/theme/oi_effects_theme_test.dart`
- `test/src/foundation/theme/oi_radius_scale_test.dart`
- `test/src/foundation/theme/oi_shadow_scale_test.dart`
- `test/src/foundation/theme/oi_text_theme_test.dart`
- `test/src/foundation/theme/oi_theme_data_test.dart`
- `test/src/foundation/theme/oi_theme_test.dart`
- `test/src/models/settings/oi_dashboard_settings_test.dart`
- `test/src/models/settings/oi_file_explorer_settings_test.dart`
- `test/src/models/settings/oi_kanban_settings_test.dart`
- `test/src/models/settings/oi_list_view_settings_test.dart`
- `test/src/models/settings/oi_sidebar_settings_test.dart`
- `test/src/models/settings/oi_split_pane_settings_test.dart`
- `test/src/models/settings/oi_table_settings_test.dart`
- `test/src/modules/oi_activity_feed_test.dart`
- `test/src/modules/oi_chat_test.dart`
- `test/src/modules/oi_comments_test.dart`
- `test/src/modules/oi_dashboard_test.dart`
- `test/src/modules/oi_file_manager_test.dart`
- `test/src/modules/oi_kanban_test.dart`
- `test/src/modules/oi_list_view_test.dart`
- `test/src/modules/oi_metadata_editor_test.dart`
- `test/src/modules/oi_notification_center_test.dart`
- `test/src/modules/oi_permissions_test.dart`
- `test/src/naming_conventions_test.dart`
- `test/src/primitives/animation/oi_morph_test.dart`
- `test/src/primitives/animation/oi_pulse_test.dart`
- `test/src/primitives/animation/oi_shimmer_test.dart`
- `test/src/primitives/animation/oi_spring_test.dart`
- `test/src/primitives/animation/oi_stagger_test.dart`
- `test/src/primitives/clipboard/oi_copy_button_test.dart`
- `test/src/primitives/clipboard/oi_copyable_test.dart`
- `test/src/primitives/clipboard/oi_paste_zone_test.dart`
- `test/src/primitives/display/oi_divider_test.dart`
- `test/src/primitives/display/oi_icon_test.dart`
- `test/src/primitives/display/oi_image_test.dart`
- `test/src/primitives/display/oi_label_test.dart`
- `test/src/primitives/display/oi_surface_test.dart`
- `test/src/primitives/drag_drop/oi_drag_ghost_test.dart`
- `test/src/primitives/drag_drop/oi_draggable_test.dart`
- `test/src/primitives/drag_drop/oi_drop_zone_test.dart`
- `test/src/primitives/drag_drop/oi_reorderable_test.dart`
- `test/src/primitives/gesture/oi_double_tap_test.dart`
- `test/src/primitives/gesture/oi_long_press_menu_test.dart`
- `test/src/primitives/gesture/oi_pinch_zoom_test.dart`
- `test/src/primitives/gesture/oi_swipeable_test.dart`
- `test/src/primitives/input/oi_raw_input_test.dart`
- `test/src/primitives/interaction/oi_focus_trap_test.dart`
- `test/src/primitives/interaction/oi_tappable_test.dart`
- `test/src/primitives/layout/oi_column_test.dart`
- `test/src/primitives/layout/oi_container_test.dart`
- `test/src/primitives/layout/oi_grid_test.dart`
- `test/src/primitives/layout/oi_masonry_test.dart`
- `test/src/primitives/layout/oi_row_test.dart`
- `test/src/primitives/layout/oi_spacer_test.dart`
- `test/src/primitives/layout/oi_wrap_layout_test.dart`
- `test/src/primitives/overlay/oi_floating_test.dart`
- `test/src/primitives/overlay/oi_portal_test.dart`
- `test/src/primitives/overlay/oi_visibility_test.dart`
- `test/src/primitives/scroll/oi_infinite_scroll_test.dart`
- `test/src/primitives/scroll/oi_scrollbar_test.dart`
- `test/src/primitives/scroll/oi_virtual_grid_test.dart`
- `test/src/primitives/scroll/oi_virtual_list_test.dart`
- `test/src/tools/oi_dynamic_theme_test.dart`
- `test/src/tools/oi_playground_test.dart`
- `test/src/tools/oi_theme_exporter_test.dart`
- `test/src/tools/oi_theme_preview_test.dart`
- `test/src/utils/color_utils_test.dart`
- `test/src/utils/file_utils_test.dart`
- `test/src/utils/formatters_test.dart`
- `test/src/utils/spring_physics_test.dart`

## Diff Content

```diff
diff --git a/.broins/tmp/drivers/claude/last_invocation.txt b/.broins/tmp/drivers/claude/last_invocation.txt
index 3fae4a3..ef08901 100644
--- a/.broins/tmp/drivers/claude/last_invocation.txt
+++ b/.broins/tmp/drivers/claude/last_invocation.txt
@@ -1,6 +1,6 @@
-timestamp: 2026-03-17T09:23:08.745844Z
+timestamp: 2026-03-17T09:57:12.079696Z
 executable: claude
-args: --print --output-format stream-json --verbose --dangerously-skip-permissions --allowedTools Read,Edit,Bash --no-session-persistence
-prompt_length: 5398 chars (~1349 tokens)
+args: --max-turns 30 --print --output-format stream-json --verbose --dangerously-skip-permissions --allowedTools Read,Edit,Bash --no-session-persistence
+prompt_length: 3976 chars (~994 tokens)
 timeout: 1800s
 working_directory: /home/simonerich/Flutters/obers_ui
diff --git a/.broins/tmp/drivers/claude/last_pid.txt b/.broins/tmp/drivers/claude/last_pid.txt
index 9b3cfc7..19be28c 100644
--- a/.broins/tmp/drivers/claude/last_pid.txt
+++ b/.broins/tmp/drivers/claude/last_pid.txt
@@ -1 +1 @@
-843510
+920623
diff --git a/.broins/tmp/drivers/claude/last_raw_stream.jsonl b/.broins/tmp/drivers/claude/last_raw_stream.jsonl
index dea1db7..0912cac 100644
--- a/.broins/tmp/drivers/claude/last_raw_stream.jsonl
+++ b/.broins/tmp/drivers/claude/last_raw_stream.jsonl
@@ -1,88 +1,158 @@
-{"type":"system","subtype":"init","cwd":"/home/simonerich/Flutters/obers_ui","session_id":"46c69f4e-82d2-4fc9-8517-493f85f31b6e","tools":["Task","TaskOutput","Bash","Glob","Grep","ExitPlanMode","Read","Edit","Write","NotebookEdit","WebFetch","TodoWrite","WebSearch","TaskStop","AskUserQuestion","Skill","EnterPlanMode","EnterWorktree","ExitWorktree","CronCreate","CronDelete","CronList","ToolSearch"],"mcp_servers":[],"model":"claude-sonnet-4-6","permissionMode":"bypassPermissions","slash_commands":["keybindings-help","debug","simplify","batch","loop","claude-api","compact","context","cost","heapdump","init","pr-comments","release-notes","review","security-review","extra-usage","insights"],"apiKeySource":"none","claude_code_version":"2.1.72","output_style":"default","agents":["general-purpose","statusline-setup","Explore","Plan"],"skills":["keybindings-help","debug","simplify","batch","loop","claude-api"],"plugins":[],"uuid":"ae532583-2a1a-4db5-9102-2a6949e83fad","fast_mode_state":"off"}
-{"type":"assistant","message":{"model":"claude-sonnet-4-6","id":"msg_019EUxKkmqyJzQX1QFMf7LL8","type":"message","role":"assistant","content":[{"type":"thinking","thinking":"Let me read the changed files to assess coverage of each requirement atom. I'll focus on the Dart source files and test files since those are most likely to contain evidence of the naming conventions.","signature":"EvECCkYICxgCKkAe2NhwEvo1QxVR9BC6h9v81PkHIk5TqukdjKhtWYMpBo+uMF3QHJyuRAyO671EDEo8PfeiufD7Hpl6VQ/6kHWBEgzLzqGjdzrnna9jAVIaDEzwtv5n+EMB2JirtCIwKr7GyEkQj1WKjrdx1g9RH2c4/rrQWO/r6+h0n7qk3NcRA2wLDWGsvSc01JYf3dA0KtgB+i1LiCWxQNuvvzLtwb+UYX3rsfec3mtws/zQBAIzvr42GQrp8ulG6tvUs8jPzWiMGyML2OUyi8WmR20LFYtK15SYpV0I5h/82wy6uzMxMialC2EVHPSO2DKyvlpCem124VhTiBZc4sHyQgvSo8qCy2ESEqkLRlXKngRsKd1BnPPOiWRYbOKxusNGi9aa9j9b4S/IBz29Ql21yViwW1gR/YqfInGcSq2aNc/Q63BTw68ED8owmtUSgNI1oazvxTqMJN3V2jmEy5RFG+Ro2tTDkGo7JbvHPFtwGAE="}],"stop_reason":null,"stop_sequence":null,"usage":{"input_tokens":2,"cache_creation_input_tokens":9499,"cache_read_input_tokens":8567,"cache_creation":{"ephemeral_5m_input_tokens":0,"ephemeral_1h_input_tokens":9499},"output_tokens":8,"service_tier":"standard","inference_geo":"not_available"},"context_management":null},"parent_tool_use_id":null,"session_id":"46c69f4e-82d2-4fc9-8517-493f85f31b6e","uuid":"bc66e7c5-47cf-4613-9c55-2744c044a5f5"}
-{"type":"assistant","message":{"model":"claude-sonnet-4-6","id":"msg_019EUxKkmqyJzQX1QFMf7LL8","type":"message","role":"assistant","content":[{"type":"tool_use","id":"toolu_01L9oWRHmYdDJfxC4pgYAVTK","name":"Agent","input":{"description":"Read all changed Dart files for QA review","subagent_type":"Explore","prompt":"Read ALL of the following files completely and return their full contents. Do not summarize - return the actual file contents with line numbers for each file:\n\n1. /home/simonerich/Flutters/obers_ui/lib/src/components/buttons/oi_button_group.dart\n2. /home/simonerich/Flutters/obers_ui/lib/src/components/buttons/oi_icon_button.dart\n3. /home/simonerich/Flutters/obers_ui/lib/src/components/buttons/oi_toggle_button.dart\n4. /home/simonerich/Flutters/obers_ui/lib/src/components/display/oi_diff_view.dart\n5. /home/simonerich/Flutters/obers_ui/lib/src/composites/data/oi_tree.dart\n6. /home/simonerich/Flutters/obers_ui/lib/src/composites/media/oi_gallery.dart\n7. /home/simonerich/Flutters/obers_ui/lib/src/composites/media/oi_lightbox.dart\n8. /home/simonerich/Flutters/obers_ui/lib/src/composites/media/oi_video_player.dart\n9. /home/simonerich/Flutters/obers_ui/lib/src/composites/onboarding/oi_tour.dart\n10. /home/simonerich/Flutters/obers_ui/lib/src/composites/scheduling/oi_timeline.dart\n11. /home/simonerich/Flutters/obers_ui/lib/src/composites/search/oi_combo_box.dart\n12. /home/simonerich/Flutters/obers_ui/lib/src/composites/search/oi_command_bar.dart\n13. /home/simonerich/Flutters/obers_ui/lib/src/composites/search/oi_search.dart\n14. /home/simonerich/Flutters/obers_ui/lib/src/composites/workflow/oi_state_diagram.dart\n15. /home/simonerich/Flutters/obers_ui/test/src/composites/search/oi_combo_box_test.dart\n16. /home/simonerich/Flutters/obers_ui/test/src/composites/search/oi_command_bar_test.dart\n17. /home/simonerich/Flutters/obers_ui/test/src/composites/search/oi_search_test.dart\n18. /home/simonerich/Flutters/obers_ui/test/src/modules/oi_file_manager_test.dart\n\nReturn the full content of each file with line numbers."},"caller":{"type":"direct"}}],"stop_reason":null,"stop_sequence":null,"usage":{"input_tokens":2,"cache_creation_input_tokens":9499,"cache_read_input_tokens":8567,"cache_creation":{"ephemeral_5m_input_tokens":0,"ephemeral_1h_input_tokens":9499},"output_tokens":8,"service_tier":"standard","inference_geo":"not_available"},"context_management":null},"parent_tool_use_id":null,"session_id":"46c69f4e-82d2-4fc9-8517-493f85f31b6e","uuid":"c3625c66-1fbb-4378-89f5-80f28302d94b"}
-{"type":"system","subtype":"task_started","task_id":"a35c1fd28f4f6ef32","tool_use_id":"toolu_01L9oWRHmYdDJfxC4pgYAVTK","description":"Read all changed Dart files for QA review","task_type":"local_agent","prompt":"Read ALL of the following files completely and return their full contents. Do not summarize - return the actual file contents with line numbers for each file:\n\n1. /home/simonerich/Flutters/obers_ui/lib/src/components/buttons/oi_button_group.dart\n2. /home/simonerich/Flutters/obers_ui/lib/src/components/buttons/oi_icon_button.dart\n3. /home/simonerich/Flutters/obers_ui/lib/src/components/buttons/oi_toggle_button.dart\n4. /home/simonerich/Flutters/obers_ui/lib/src/components/display/oi_diff_view.dart\n5. /home/simonerich/Flutters/obers_ui/lib/src/composites/data/oi_tree.dart\n6. /home/simonerich/Flutters/obers_ui/lib/src/composites/media/oi_gallery.dart\n7. /home/simonerich/Flutters/obers_ui/lib/src/composites/media/oi_lightbox.dart\n8. /home/simonerich/Flutters/obers_ui/lib/src/composites/media/oi_video_player.dart\n9. /home/simonerich/Flutters/obers_ui/lib/src/composites/onboarding/oi_tour.dart\n10. /home/simonerich/Flutters/obers_ui/lib/src/composites/scheduling/oi_timeline.dart\n11. /home/simonerich/Flutters/obers_ui/lib/src/composites/search/oi_combo_box.dart\n12. /home/simonerich/Flutters/obers_ui/lib/src/composites/search/oi_command_bar.dart\n13. /home/simonerich/Flutters/obers_ui/lib/src/composites/search/oi_search.dart\n14. /home/simonerich/Flutters/obers_ui/lib/src/composites/workflow/oi_state_diagram.dart\n15. /home/simonerich/Flutters/obers_ui/test/src/composites/search/oi_combo_box_test.dart\n16. /home/simonerich/Flutters/obers_ui/test/src/composites/search/oi_command_bar_test.dart\n17. /home/simonerich/Flutters/obers_ui/test/src/composites/sear
[truncated]
```


## Task Packet (living document)

## Task Packet Summary
Work Item: WI-0066 — verifying
Classification: ux, dx
Specialists: frontend_architect, dx_engineer, ux_researcher, technical_writer, qa_engineer

### Plan (v1)
Let me check the current state of the key modified files to understand what's already done vs. what needs to be planned.Let me check the current state of a few more key files to understand what's already implemented vs. what needs planning.

### Implementation Notes
REQ-0001 (Naming & Conventions): naming_conventions_test.dart already exists and passes — all lib/src files correctly use adjective-style boolean names (enabled, loading, etc.) with no is/has prefixes. REQ-0002 (Package Structure): lib/obers_ui.dart barrel export file is complete with all components organized by category. REQ-0003 (Theming System): OiThemeData, OiDynamicTheme, and OiPlayground are fully implemented and tested. Actions taken: (1) ran dart format to bring all 330 files into compliance, (2) fixed unused_local_variable warning in oi_list_view_test.dart by using the searchedQuery value in an assertion. All 2443 tests pass, no warnings from flutter analyze.

### Test Runner Results
(none yet)

### Previous Iterations (0)
(none)


## Instructions

Verify each requirement atom individually. For each atom:

- **covered**: every sub-requirement is implemented with citable evidence.
- **partial**: some parts exist but others are missing, stubbed, or placeholder.
- **missing**: the requirement is not implemented.

For each atom you MUST provide at least one evidence entry with a file path and line range (e.g. `lib/auth/login.dart:42-58`). If you cannot find evidence, mark as "missing" and explain in missingDetails which specific file should contain the implementation.

Every atom listed above MUST have a corresponding entry in atomResults. If you cannot verify an atom, include it with status "missing" — never omit atoms.

Also write your verification results to `.broins/work/runs/run-1773733505170/wi/WI-0066/results/verify.json`.

## Required JSON Output Format

Respond with EXACTLY this structure (concrete example):

{
  "atomResults": [
    {
      "atomId": "REQ-0001",
      "status": "covered",
      "evidence": ["lib/example.dart:10-20"],
      "missingDetails": null,
      "recommendedFix": null
    }
  ],
  "overallStatus": "pass",
  "notes": "All requirements verified"
}

Use overallStatus "pass" only when ALL atoms have status "covered".

BEGIN JSON OUTPUT:
