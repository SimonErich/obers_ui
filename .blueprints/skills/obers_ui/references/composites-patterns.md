# Composites — patterns (forms, shell, media, time, workflow)

Overview: multi-step flows, rich text, files, media viewers, search/command UI, calendars, collaboration, and app shell layout. [← Skill](../SKILL.md)

Paths: `lib/src/composites/<area>/...`.

## Forms and steps

| Name | Path | Role |
|------|------|------|
| `OiFormSection` | `forms/oi_form_section.dart` | Grouped fields; **`OiFormLayout`** enum |
| `OiFormDialog` | `forms/oi_form_dialog.dart` | Dialog with **`OiFormDialogController`** |
| `OiWizard` | `forms/oi_wizard.dart` | Multi-step wizard; **`OiWizardStep`**, **`OiWizardContext`** |
| `OiStepper` | `forms/oi_stepper.dart` | Horizontal step indicator |
| `OiNameDialog` | `dialogs/oi_name_dialog.dart` | Prompt for a single name |

## Editors

| Name | Path | Role |
|------|------|------|
| `OiSmartInput` | `editors/oi_smart_input.dart` | Mentions/autocomplete patterns |
| `OiRichEditor` | `editors/oi_rich_editor.dart` | Rich text editor widget |
| `OiRichEditorController` | `editors/oi_rich_editor_controller.dart` | Document controller |
| `OiRichContent` | `editors/oi_rich_content.dart` | Block-based rich content; **`OiContentBlock`**, **`OiMention`**, **`OiSlashCommand`** |

## Files

| Name | Path | Role |
|------|------|------|
| `OiFileSidebar` | `files/oi_file_sidebar.dart` | Drive/sidebar; **`OiQuickAccessItem`**, **`OiStorageData`** |
| `OiFileListView` | `files/oi_file_list_view.dart` | Table-style file list; **`OiFileColumnDef`** |
| `OiFileGridView` | `files/oi_file_grid_view.dart` | Icon grid of files |
| `OiFileDropTarget` | `files/oi_file_drop_target.dart` | Drag-and-drop upload target |

## Media

| Name | Path | Role |
|------|------|------|
| `OiGallery` | `media/oi_gallery.dart` | Image gallery; **`OiGalleryItem`** |
| `OiLightbox` | `media/oi_lightbox.dart` | Fullscreen media lightbox; **`OiLightboxItem`** |
| `OiVideoPlayer` | `media/oi_video_player.dart` | Video playback |
| `OiImageCropper` | `media/oi_image_cropper.dart` | Crop UI; **`OiCropResult`** |
| `OiImageAnnotator` | `media/oi_image_annotator.dart` | Draw regions; **`OiAnnotation`** |

## Search and commands

| Name | Path | Role |
|------|------|------|
| `OiSearch` | `search/oi_search.dart` | Search UI; **`OiSearchResult`**, **`OiSearchSource`**, **`OiSearchFilter`** |
| `OiCommandBar` | `search/oi_command_bar.dart` | Command palette; **`OiCommand`** |
| `OiComboBox` | `search/oi_combo_box.dart` | Searchable dropdown |

## Navigation and shell

| Name | Path | Role |
|------|------|------|
| `OiResponsiveShell` | `navigation/oi_responsive_shell.dart` | App shell; **`OiResponsiveShellBreakpoints`** |
| `OiPageHeader` | `navigation/oi_page_header.dart` | Page title region |
| `OiSidebar` | `navigation/oi_sidebar.dart` | Collapsible sidebar; **`OiSidebarSection`**, **`OiSidebarItem`** |
| `OiThreeColumnLayout` | `navigation/oi_three_column_layout.dart` | Master-detail + context |
| `OiNavMenu` | `navigation/oi_nav_menu.dart` | Nested nav; **`OiNavMenuItem`** |
| `OiFilterableNavList` | `navigation/oi_filterable_nav_list.dart` | Filtered nav groups; **`OiNavGroup`**, **`OiChipFilter`** |
| `OiFilterBar` | `navigation/oi_filter_bar.dart` | Column filters; **`OiFilterDefinition`**, **`OiColumnFilter`** |
| `OiFileToolbar` | `navigation/oi_file_toolbar.dart` | File manager toolbar |
| `OiArrowNav` | `navigation/oi_arrow_nav.dart` | Prev/next arrows |
| `OiShortcuts` | `navigation/oi_shortcuts.dart` | Shortcut registry; **`OiShortcutBinding`**, **`OiShortcutActivator`** |
| `OiErrorPage` | `navigation/oi_error_page.dart` | HTTP-style error page |

## Scheduling

| Name | Path | Role |
|------|------|------|
| `OiCalendar` | `scheduling/oi_calendar.dart` | Month/week grid; **`OiCalendarEvent`** |
| `OiScheduler` | `scheduling/oi_scheduler.dart` | Day/resource schedule; **`OiScheduleSlot`** |
| `OiGantt` | `scheduling/oi_gantt.dart` | Gantt chart; **`OiGanttTask`** |
| `OiTimeline` | `scheduling/oi_timeline.dart` | Event timeline; **`OiTimelineEvent`** |
| `OiDateRangePicker` | `scheduling/oi_date_range_picker.dart` | Range picker widget |
| `OiDateRangeInput` | `scheduling/oi_date_range_input.dart` | Compact range display/input |
| `OiCalendarEventDialog` | `scheduling/oi_calendar_event_dialog.dart` | Create/edit event; **`OiCalendarEventResult`** |

## Workflow

| Name | Path | Role |
|------|------|------|
| `OiPipeline` | `workflow/oi_pipeline.dart` | Linear stages; **`OiPipelineStage`** |
| `OiWorkflowStepper` | `workflow/oi_workflow_stepper.dart` | Phased steps; **`OiWorkflowPhase`**, **`OiWorkflowStep`** |
| `OiWorkflowTree` | `workflow/oi_workflow_tree.dart` | Grouped checklist; **`OiWorkflowTreeController`**, **`OiWorkflowGroup`**, **`OiWorkflowItem`** |
| `OiFlowGraph` | `workflow/oi_flow_graph.dart` | Node graph; **`OiFlowNode`**, **`OiFlowEdge`** |
| `OiStateDiagram` | `workflow/oi_state_diagram.dart` | State machine diagram; **`OiStateNode`**, **`OiStateTransition`** |

## Social presence

| Name | Path | Role |
|------|------|------|
| `OiCursorPresence` | `social/oi_cursor_presence.dart` | Remote cursors; **`OiRemoteCursor`** |
| `OiSelectionPresence` | `social/oi_selection_presence.dart` | Remote selections; **`OiRemoteSelection`** |
| `OiLiveRing` | `social/oi_live_ring.dart` | Live activity ring |
| `OiAvatarStack` | `social/oi_avatar_stack.dart` | Stacked avatars; **`OiAvatarStackItem`** |
| `OiTypingIndicator` | `social/oi_typing_indicator.dart` | Chat typing dots |

## Onboarding

| Name | Path | Role |
|------|------|------|
| `OiTour` | `onboarding/oi_tour.dart` | Step overlay tour; **`OiTourStep`** |
| `OiSpotlight` | `onboarding/oi_spotlight.dart` | Highlight target |
| `OiWhatsNew` | `onboarding/oi_whats_new.dart` | What’s new sheet; **`OiWhatsNewItem`** |
