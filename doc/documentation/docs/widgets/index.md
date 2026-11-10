# Widgets

This is the full widget catalog. Everything is grouped by what it does, so you can
find a widget by the job you have in front of you. Each page opens with a short
"at a glance" table, then covers every widget with an example, its attributes, and
its theme hook.

New to the library? Read [Core Ideas](../getting-started/core-ideas.md) first. It
explains the handful of conventions (the `Oi` prefix, named-constructor variants,
`OiLabel` instead of `Text`) that every page below assumes.

## Input and forms

Everything a user types, picks, or toggles.

| Page | Widgets |
| --- | --- |
| [Buttons & Actions](buttons.md) | `OiButton`, `OiIconButton`, `OiToggleButton`, `OiButtonGroup`, `OiActionBar`, `OiBulkBar`, `OiSortButton`, `OiExportButton`, `OiBackButton` |
| [Text & Number Inputs](text-inputs.md) | `OiTextInput`, `OiNumberInput`, `OiTagInput`, `OiArrayInput`, `OiColorInput`, `OiColorPalettePicker` |
| [Selection Controls](selection-controls.md) | `OiCheckbox`, `OiRadio`, `OiSwitch`, `OiSwitchTile`, `OiSlider`, `OiSegmentedControl`, `OiSelect`, `OiFormSelect`, `OiComboBox` |
| [Date & Time Pickers](date-time.md) | `OiDateInput`, `OiTimeInput`, `OiDatePicker`, `OiDateRangePicker`, `OiMonthPicker`, `OiWeekStrip`, and more |
| [Forms & Wizards](forms.md) | `OiFormSection`, `OiFormDialog`, `OiStepper`, `OiWizard`, `OiNameDialog` |
| [Inline Editing](inline-edit.md) | `OiEditable`, `OiEditableText`, `OiEditableNumber`, `OiEditableDate`, `OiEditableSelect`, `OiRenameField` |
| [Search & Command](search-command.md) | `OiSearch`, `OiCommandBar`, `OiFilterBar`, `OiShortcuts` |

## Content and feedback

Showing information, status, and progress.

| Page | Widgets |
| --- | --- |
| [Display & Content](display.md) | `OiCard`, `OiBadge`, `OiAvatar`, `OiKeyValue`, `OiListTile`, `OiMetric`, `OiFieldDisplay`, `OiEmptyState`, `OiTooltip`, `OiPopover`, `OiImage`, and more |
| [Feedback & Status](feedback.md) | `OiBanner`, `OiProgress`, `OiPipelineProgress`, `OiSkeletonGroup`, `OiRefreshIndicator`, `OiStarRating`, `OiSentiment`, `OiThumbs`, `OiReactionBar` |
| [Overlays & Menus](overlays.md) | `OiDialog`, `OiSheet`, `OiContextMenu`, `OiMenuItem`, `OiToast`, `OiSnackBar`, and the `OiOverlays` service |
| [Editors, Code & Markdown](editors.md) | `OiRichEditor`, `OiRichContent`, `OiSmartInput`, `OiCodeBlock`, `OiMarkdown`, `OiDiffView`, `OiKbd` |

## Data and navigation

Moving through data and around the app.

| Page | Widgets |
| --- | --- |
| [Data & Tables](data-tables.md) | `OiTable`, `OiDataGrid`, `OiPropertyGrid`, `OiGroupedList`, `OiReorderableList`, `OiTree`, `OiDetailView` |
| [Navigation](navigation.md) | `OiTabs`, `OiAccordion`, `OiBreadcrumbs`, `OiNavigationRail`, `OiDrawer`, `OiBottomBar`, `OiMenuBar`, `OiUserMenu`, and more |
| [Scrolling & Virtualization](scroll.md) | `OiScrollbar`, `OiInfiniteScroll`, `OiVirtualList`, `OiVirtualGrid`, `OiSliverList`, `OiSliverGrid`, `OiSliverHeader`, `OiAnimatedList` |

## Rich features

Bigger building blocks for media, scheduling, files, and more.

| Page | Widgets |
| --- | --- |
| [Media](media.md) | `OiGallery`, `OiLightbox`, `OiVideoPlayer`, `OiImageCropper`, `OiImageAnnotator`, `OiImagePreviewCard`, `OiFilePreview` |
| [Scheduling & Calendars](scheduling.md) | `OiCalendar`, `OiGantt`, `OiScheduler`, `OiTimeline` |
| [Files & File Management](files.md) | `OiFileInput`, `OiFileDropTarget`, file views, file and folder tiles, and the file operation dialogs |
| [Commerce & Shop](commerce.md) | `OiProductCard`, `OiPriceTag`, `OiQuantitySelector`, `OiCartPanel`, `OiAddressForm`, `OiOrderTracker`, and more |
| [Social & Presence](social.md) | `OiAvatarStack`, `OiTypingIndicator`, `OiReplyPreview`, `OiLiveRing`, `OiCursorPresence`, `OiSelectionPresence` |
| [Workflow & Diagrams](workflow-diagrams.md) | `OiPipeline`, `OiWorkflowStepper`, `OiWorkflowTree`, `OiFlowGraph`, `OiStateDiagram` |
| [Onboarding & Tours](onboarding.md) | `OiSpotlight`, `OiTour`, `OiWhatsNew`, `OiOnboardingFlow`, `OiChangelogView` |

## Interaction and motion

Low-level primitives for gestures, drag and drop, and animation.

| Page | Widgets |
| --- | --- |
| [Gestures & Interaction](gestures.md) | `OiTappable`, `OiTouchTarget`, `OiFocusTrap`, `OiSwipeable`, `OiDraggable`, `OiDropZone`, `OiReorderable`, `OiCopyable`, `OiCopyButton`, and more |
| [Animation & Motion](animation.md) | `OiMorph`, `OiPulse`, `OiShimmer`, `OiSpring`, `OiStagger`, `OiVisibility`, `OiFloating`, `OiPortal` |

## Related

- [Layout](../layout/index.md) for the primitives that arrange widgets on screen.
- [Modules](../modules/index.md) for whole features (dashboards, chat, file explorers) that wrap these widgets.
- [Charts](../charts/index.md) for the 30+ chart types in the companion package.
- [Theming](../theming/index.md) to restyle any of these with tokens and component themes.
