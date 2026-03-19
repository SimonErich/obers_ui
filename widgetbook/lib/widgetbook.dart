import 'package:flutter/material.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_widgetbook/components/buttons/oi_button_group_use_cases.dart';
import 'package:obers_ui_widgetbook/components/buttons/oi_button_use_cases.dart';
import 'package:obers_ui_widgetbook/components/buttons/oi_icon_button_use_cases.dart';
import 'package:obers_ui_widgetbook/components/buttons/oi_toggle_button_use_cases.dart';
import 'package:obers_ui_widgetbook/components/dialogs/oi_component_dialogs_use_cases.dart';
import 'package:obers_ui_widgetbook/components/display/oi_avatar_use_cases.dart';
import 'package:obers_ui_widgetbook/components/display/oi_badge_use_cases.dart';
import 'package:obers_ui_widgetbook/components/display/oi_card_use_cases.dart';
import 'package:obers_ui_widgetbook/components/display/oi_code_block_use_cases.dart';
import 'package:obers_ui_widgetbook/components/display/oi_diff_view_use_cases.dart';
import 'package:obers_ui_widgetbook/components/display/oi_empty_state_use_cases.dart';
import 'package:obers_ui_widgetbook/components/display/oi_file_display_use_cases.dart';
import 'package:obers_ui_widgetbook/components/display/oi_list_tile_use_cases.dart';
import 'package:obers_ui_widgetbook/components/display/oi_markdown_use_cases.dart';
import 'package:obers_ui_widgetbook/components/display/oi_metric_use_cases.dart';
import 'package:obers_ui_widgetbook/components/display/oi_popover_use_cases.dart';
import 'package:obers_ui_widgetbook/components/display/oi_progress_use_cases.dart';
import 'package:obers_ui_widgetbook/components/display/oi_relative_time_use_cases.dart';
import 'package:obers_ui_widgetbook/components/display/oi_reply_preview_use_cases.dart';
import 'package:obers_ui_widgetbook/components/display/oi_skeleton_group_use_cases.dart';
import 'package:obers_ui_widgetbook/components/display/oi_tooltip_use_cases.dart';
import 'package:obers_ui_widgetbook/components/feedback/oi_feedback_use_cases.dart';
import 'package:obers_ui_widgetbook/components/inline_edit/oi_editable_use_cases.dart';
import 'package:obers_ui_widgetbook/components/inputs/oi_checkbox_use_cases.dart';
import 'package:obers_ui_widgetbook/components/inputs/oi_color_input_use_cases.dart';
import 'package:obers_ui_widgetbook/components/inputs/oi_date_input_use_cases.dart';
import 'package:obers_ui_widgetbook/components/inputs/oi_file_input_use_cases.dart';
import 'package:obers_ui_widgetbook/components/inputs/oi_number_input_use_cases.dart';
import 'package:obers_ui_widgetbook/components/inputs/oi_radio_use_cases.dart';
import 'package:obers_ui_widgetbook/components/inputs/oi_select_use_cases.dart';
import 'package:obers_ui_widgetbook/components/inputs/oi_slider_use_cases.dart';
import 'package:obers_ui_widgetbook/components/inputs/oi_switch_use_cases.dart';
import 'package:obers_ui_widgetbook/components/inputs/oi_tag_input_use_cases.dart';
import 'package:obers_ui_widgetbook/components/inputs/oi_text_input_use_cases.dart';
import 'package:obers_ui_widgetbook/components/inputs/oi_time_input_use_cases.dart';
import 'package:obers_ui_widgetbook/components/navigation/oi_accordion_use_cases.dart';
import 'package:obers_ui_widgetbook/components/navigation/oi_bottom_bar_use_cases.dart';
import 'package:obers_ui_widgetbook/components/navigation/oi_breadcrumbs_use_cases.dart';
import 'package:obers_ui_widgetbook/components/navigation/oi_date_picker_use_cases.dart';
import 'package:obers_ui_widgetbook/components/navigation/oi_drawer_use_cases.dart';
import 'package:obers_ui_widgetbook/components/navigation/oi_emoji_picker_use_cases.dart';
import 'package:obers_ui_widgetbook/components/navigation/oi_tabs_use_cases.dart';
import 'package:obers_ui_widgetbook/components/navigation/oi_time_picker_use_cases.dart';
import 'package:obers_ui_widgetbook/components/overlays/oi_context_menu_use_cases.dart';
import 'package:obers_ui_widgetbook/components/overlays/oi_dialog_use_cases.dart';
import 'package:obers_ui_widgetbook/components/overlays/oi_sheet_use_cases.dart';
import 'package:obers_ui_widgetbook/components/overlays/oi_toast_use_cases.dart';
import 'package:obers_ui_widgetbook/components/panels/oi_panel_use_cases.dart';
import 'package:obers_ui_widgetbook/components/panels/oi_resizable_use_cases.dart';
import 'package:obers_ui_widgetbook/components/panels/oi_split_pane_use_cases.dart';
import 'package:obers_ui_widgetbook/composites/data/oi_table_use_cases.dart';
import 'package:obers_ui_widgetbook/composites/data/oi_tree_use_cases.dart';
import 'package:obers_ui_widgetbook/composites/dialogs/oi_name_dialog_use_cases.dart';
import 'package:obers_ui_widgetbook/composites/editors/oi_rich_editor_use_cases.dart';
import 'package:obers_ui_widgetbook/composites/editors/oi_smart_input_use_cases.dart';
import 'package:obers_ui_widgetbook/composites/files/oi_file_views_use_cases.dart';
import 'package:obers_ui_widgetbook/composites/forms/oi_form_use_cases.dart';
import 'package:obers_ui_widgetbook/composites/forms/oi_stepper_use_cases.dart';
import 'package:obers_ui_widgetbook/composites/forms/oi_wizard_use_cases.dart';
import 'package:obers_ui_widgetbook/composites/media/oi_gallery_use_cases.dart';
import 'package:obers_ui_widgetbook/composites/media/oi_media_use_cases.dart';
import 'package:obers_ui_widgetbook/composites/navigation/oi_file_toolbar_use_cases.dart';
import 'package:obers_ui_widgetbook/composites/navigation/oi_filter_bar_use_cases.dart';
import 'package:obers_ui_widgetbook/composites/navigation/oi_nav_menu_use_cases.dart';
import 'package:obers_ui_widgetbook/composites/navigation/oi_shortcuts_use_cases.dart';
import 'package:obers_ui_widgetbook/composites/navigation/oi_sidebar_use_cases.dart';
import 'package:obers_ui_widgetbook/composites/onboarding/oi_onboarding_use_cases.dart';
import 'package:obers_ui_widgetbook/composites/scheduling/oi_calendar_use_cases.dart';
import 'package:obers_ui_widgetbook/composites/scheduling/oi_gantt_use_cases.dart';
import 'package:obers_ui_widgetbook/composites/scheduling/oi_scheduler_use_cases.dart';
import 'package:obers_ui_widgetbook/composites/scheduling/oi_timeline_use_cases.dart';
import 'package:obers_ui_widgetbook/composites/search/oi_combo_box_use_cases.dart';
import 'package:obers_ui_widgetbook/composites/search/oi_command_bar_use_cases.dart';
import 'package:obers_ui_widgetbook/composites/search/oi_search_use_cases.dart';
import 'package:obers_ui_widgetbook/composites/social/oi_social_use_cases.dart';
import 'package:obers_ui_widgetbook/composites/visualization/oi_visualization_use_cases.dart';
import 'package:obers_ui_widgetbook/composites/workflow/oi_workflow_use_cases.dart';
import 'package:obers_ui_widgetbook/foundation/animation_use_cases.dart';
import 'package:obers_ui_widgetbook/foundation/color_scheme_use_cases.dart';
import 'package:obers_ui_widgetbook/foundation/radius_use_cases.dart';
import 'package:obers_ui_widgetbook/foundation/responsive_use_cases.dart';
import 'package:obers_ui_widgetbook/foundation/shadow_use_cases.dart';
import 'package:obers_ui_widgetbook/foundation/spacing_use_cases.dart';
import 'package:obers_ui_widgetbook/foundation/typography_use_cases.dart';
import 'package:obers_ui_widgetbook/modules/oi_activity_feed_use_cases.dart';
import 'package:obers_ui_widgetbook/modules/oi_chat_use_cases.dart';
import 'package:obers_ui_widgetbook/modules/oi_comments_use_cases.dart';
import 'package:obers_ui_widgetbook/modules/oi_dashboard_use_cases.dart';
import 'package:obers_ui_widgetbook/modules/oi_file_explorer_use_cases.dart';
import 'package:obers_ui_widgetbook/modules/oi_file_manager_use_cases.dart';
import 'package:obers_ui_widgetbook/modules/oi_kanban_use_cases.dart';
import 'package:obers_ui_widgetbook/modules/oi_list_view_use_cases.dart';
import 'package:obers_ui_widgetbook/modules/oi_metadata_editor_use_cases.dart';
import 'package:obers_ui_widgetbook/modules/oi_notification_center_use_cases.dart';
import 'package:obers_ui_widgetbook/modules/oi_permissions_use_cases.dart';
import 'package:obers_ui_widgetbook/primitives/animation/oi_animation_use_cases.dart';
import 'package:obers_ui_widgetbook/primitives/clipboard/oi_clipboard_use_cases.dart';
import 'package:obers_ui_widgetbook/primitives/display/oi_divider_use_cases.dart';
import 'package:obers_ui_widgetbook/primitives/display/oi_icon_use_cases.dart';
import 'package:obers_ui_widgetbook/primitives/display/oi_label_use_cases.dart';
import 'package:obers_ui_widgetbook/primitives/display/oi_surface_use_cases.dart';
import 'package:obers_ui_widgetbook/primitives/drag_drop/oi_drag_drop_use_cases.dart';
import 'package:obers_ui_widgetbook/primitives/gesture/oi_gesture_use_cases.dart';
import 'package:obers_ui_widgetbook/primitives/input/oi_raw_input_use_cases.dart';
import 'package:obers_ui_widgetbook/primitives/interaction/oi_interaction_use_cases.dart';
import 'package:obers_ui_widgetbook/primitives/layout/oi_column_use_cases.dart';
import 'package:obers_ui_widgetbook/primitives/layout/oi_container_use_cases.dart';
import 'package:obers_ui_widgetbook/primitives/layout/oi_grid_use_cases.dart';
import 'package:obers_ui_widgetbook/primitives/layout/oi_layout_misc_use_cases.dart';
import 'package:obers_ui_widgetbook/primitives/layout/oi_row_use_cases.dart';
import 'package:obers_ui_widgetbook/primitives/overlay/oi_overlay_use_cases.dart';
import 'package:obers_ui_widgetbook/primitives/scroll/oi_scroll_use_cases.dart';
import 'package:widgetbook/widgetbook.dart';

/// The root Widgetbook app for the obers_ui design system.
///
/// Launch with:
///   flutter run -d chrome   (web)
///   flutter run -d linux    (desktop)
class OiWidgetbook extends StatelessWidget {
  const OiWidgetbook({super.key});

  @override
  Widget build(BuildContext context) {
    return Widgetbook(
      addons: [
        ThemeAddon<OiThemeData>(
          themes: [
            WidgetbookTheme(name: 'Light', data: OiThemeData.light()),
            WidgetbookTheme(name: 'Dark', data: OiThemeData.dark()),
          ],
          themeBuilder: (context, theme, child) =>
              OiApp(theme: theme, home: child),
        ),
        ViewportAddon([
          ...IosViewports.phones,
          ...IosViewports.tablets,
          ...AndroidViewports.phones,
          LinuxViewports.desktop,
          MacosViewports.macbookPro,
        ]),
        TextScaleAddon(min: 0.75),
        AlignmentAddon(),
      ],
      directories: [
        // ── Foundation ───────────────────────────────────────────────────
        WidgetbookCategory(
          name: 'Foundation',
          children: [
            WidgetbookFolder(
              name: 'Design Tokens',
              children: [
                colorSchemeComponent,
                typographyComponent,
                spacingComponent,
                radiusComponent,
                shadowComponent,
                animationComponent,
                responsiveComponent,
              ],
            ),
          ],
        ),

        // ── Primitives ──────────────────────────────────────────────────
        WidgetbookCategory(
          name: 'Primitives',
          children: [
            WidgetbookFolder(
              name: 'Layout',
              children: [
                oiContainerComponent,
                oiRowComponent,
                oiColumnComponent,
                oiGridComponent,
                oiPageComponent,
                oiSectionComponent,
                oiMasonryComponent,
                oiWrapLayoutComponent,
                oiAspectRatioComponent,
                oiSpacerComponent,
              ],
            ),
            WidgetbookFolder(
              name: 'Display',
              children: [
                oiIconComponent,
                oiLabelComponent,
                oiDividerComponent,
                oiSurfaceComponent,
              ],
            ),
            WidgetbookFolder(
              name: 'Animation',
              children: [
                oiSpringComponent,
                oiStaggerComponent,
                oiMorphComponent,
                oiPulseComponent,
                oiShimmerComponent,
                oiAnimatedListComponent,
              ],
            ),
            WidgetbookFolder(
              name: 'Scroll',
              children: [
                oiVirtualListComponent,
                oiVirtualGridComponent,
                oiInfiniteScrollComponent,
                oiScrollbarComponent,
              ],
            ),
            WidgetbookFolder(
              name: 'Interaction',
              children: [oiTappableComponent, oiFocusTrapComponent],
            ),
            WidgetbookFolder(
              name: 'Gesture',
              children: [
                oiDoubleTapComponent,
                oiLongPressMenuComponent,
                oiPinchZoomComponent,
                oiSwipeableComponent,
              ],
            ),
            WidgetbookFolder(
              name: 'Drag & Drop',
              children: [
                oiDraggableComponent,
                oiDropZoneComponent,
                oiReorderableComponent,
                oiDragGhostComponent,
              ],
            ),
            WidgetbookFolder(
              name: 'Clipboard',
              children: [
                oiCopyableComponent,
                oiCopyButtonComponent,
                oiPasteZoneComponent,
              ],
            ),
            WidgetbookFolder(
              name: 'Overlay',
              children: [
                oiFloatingComponent,
                oiPortalComponent,
                oiVisibilityComponent,
              ],
            ),
            WidgetbookFolder(name: 'Input', children: [oiRawInputComponent]),
          ],
        ),

        // ── Components ──────────────────────────────────────────────────
        WidgetbookCategory(
          name: 'Components',
          children: [
            WidgetbookFolder(
              name: 'Buttons',
              children: [
                oiButtonComponent,
                oiIconButtonComponent,
                oiToggleButtonComponent,
                oiButtonGroupComponent,
              ],
            ),
            WidgetbookFolder(
              name: 'Inputs',
              children: [
                oiTextInputComponent,
                oiSelectComponent,
                oiCheckboxComponent,
                oiRadioComponent,
                oiSwitchComponent,
                oiSliderComponent,
                oiNumberInputComponent,
                oiDateInputComponent,
                oiTimeInputComponent,
                oiColorInputComponent,
                oiTagInputComponent,
                oiFileInputComponent,
              ],
            ),
            WidgetbookFolder(
              name: 'Inline Edit',
              children: [oiEditableComponent],
            ),
            WidgetbookFolder(
              name: 'Display',
              children: [
                oiAvatarComponent,
                oiBadgeComponent,
                oiCardComponent,
                oiCodeBlockComponent,
                oiDiffViewComponent,
                oiEmptyStateComponent,
                oiListTileComponent,
                oiMarkdownComponent,
                oiMetricComponent,
                oiPopoverComponent,
                oiProgressComponent,
                oiRelativeTimeComponent,
                oiReplyPreviewComponent,
                oiSkeletonGroupComponent,
                oiTooltipComponent,
                oiFileDisplayComponent,
              ],
            ),
            WidgetbookFolder(name: 'Feedback', children: [oiFeedbackComponent]),
            WidgetbookFolder(
              name: 'Overlays',
              children: [
                oiContextMenuComponent,
                oiDialogComponent,
                oiSheetComponent,
                oiToastComponent,
              ],
            ),
            WidgetbookFolder(
              name: 'Navigation',
              children: [
                oiTabsComponent,
                oiAccordionComponent,
                oiBreadcrumbsComponent,
                oiDatePickerComponent,
                oiTimePickerComponent,
                oiEmojiPickerComponent,
                oiDrawerComponent,
                oiBottomBarComponent,
              ],
            ),
            WidgetbookFolder(
              name: 'Panels',
              children: [
                oiPanelComponent,
                oiSplitPaneComponent,
                oiResizableComponent,
              ],
            ),
            WidgetbookFolder(
              name: 'Dialogs',
              children: [oiComponentDialogsComponent],
            ),
          ],
        ),

        // ── Composites ──────────────────────────────────────────────────
        WidgetbookCategory(
          name: 'Composites',
          children: [
            WidgetbookFolder(
              name: 'Data',
              children: [oiTableComponent, oiTreeComponent],
            ),
            WidgetbookFolder(
              name: 'Navigation',
              children: [
                oiSidebarComponent,
                oiNavMenuComponent,
                oiFilterBarComponent,
                oiShortcutsComponent,
                oiFileToolbarComponent,
              ],
            ),
            WidgetbookFolder(
              name: 'Search',
              children: [
                oiComboBoxComponent,
                oiSearchComponent,
                oiCommandBarComponent,
              ],
            ),
            WidgetbookFolder(
              name: 'Forms',
              children: [
                oiFormComponent,
                oiStepperComponent,
                oiWizardComponent,
              ],
            ),
            WidgetbookFolder(
              name: 'Editors',
              children: [oiRichEditorComponent, oiSmartInputComponent],
            ),
            WidgetbookFolder(name: 'Social', children: [oiSocialComponent]),
            WidgetbookFolder(
              name: 'Onboarding',
              children: [oiOnboardingComponent],
            ),
            WidgetbookFolder(
              name: 'Scheduling',
              children: [
                oiCalendarComponent,
                oiGanttComponent,
                oiSchedulerComponent,
                oiTimelineComponent,
              ],
            ),
            WidgetbookFolder(name: 'Workflow', children: [oiWorkflowComponent]),
            WidgetbookFolder(
              name: 'Visualization',
              children: [oiVisualizationComponent],
            ),
            WidgetbookFolder(
              name: 'Media',
              children: [oiGalleryComponent, oiMediaComponent],
            ),
            WidgetbookFolder(
              name: 'Files',
              children: [
                oiFileGridViewComponent,
                oiFileListViewComponent,
                oiFileDropTargetComponent,
                oiFileSidebarComponent,
              ],
            ),
            WidgetbookFolder(
              name: 'Dialogs',
              children: [oiNameDialogComponent],
            ),
          ],
        ),

        // ── Modules ─────────────────────────────────────────────────────
        WidgetbookCategory(
          name: 'Modules',
          children: [
            oiActivityFeedComponent,
            oiChatComponent,
            oiCommentsComponent,
            oiDashboardComponent,
            oiFileManagerComponent,
            oiFileExplorerComponent,
            oiKanbanComponent,
            oiListViewComponent,
            oiMetadataEditorComponent,
            oiNotificationCenterComponent,
            oiPermissionsComponent,
          ],
        ),
      ],
    );
  }
}
