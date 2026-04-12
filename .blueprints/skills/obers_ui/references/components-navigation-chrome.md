# Components — navigation, overlays, panels

Overview: persistent navigation, transient overlays (dialogs, sheets, menus), and resizable panels. [← Skill](../SKILL.md)

Paths: `lib/src/components/<area>/...`.

## Navigation

| Name | Path | Role |
|------|------|------|
| `OiAccountSwitcher` | `navigation/oi_account_switcher.dart` | Account/workspace switcher |
| `OiActionBar` | `navigation/oi_action_bar.dart` | Top action strip |
| `OiAccordion` | `navigation/oi_accordion.dart` | Expandable sections |
| `OiBottomBar` | `navigation/oi_bottom_bar.dart` | Bottom navigation |
| `OiBreadcrumbs` | `navigation/oi_breadcrumbs.dart` | Hierarchy trail |
| `OiDatePicker` | `navigation/oi_date_picker.dart` | Calendar date picker surface |
| `OiDrawer` | `navigation/oi_drawer.dart` | Side drawer |
| `OiEmojiPicker` | `navigation/oi_emoji_picker.dart` | Emoji grid |
| `OiIndexBar` | `navigation/oi_index_bar.dart` | Alphabet index for lists |
| `OiLocaleSwitcher` | `navigation/oi_locale_switcher.dart` | Language/locale; **`OiLocaleOption`** |
| `OiMenuBar` | `navigation/oi_menu_bar.dart` | Desktop-style menu bar |
| `OiMonthPicker` | `navigation/oi_month_picker.dart` | Month grid; **`OiMonth`** |
| `OiNavigationRail` | `navigation/oi_navigation_rail.dart` | Side rail nav |
| `OiStatusBar` | `navigation/oi_status_bar.dart` | Status strip; **`OiStatusBarItem`** |
| `OiTabView` | `navigation/oi_tab_view.dart` | Tab content; **`OiTabViewItem`** |
| `OiTabs` | `navigation/oi_tabs.dart` | Tab bar; **`OiTabItem`** |
| `OiThemeToggle` | `navigation/oi_theme_toggle.dart` | Light/dark toggle |
| `OiTimePicker` | `navigation/oi_time_picker.dart` | Clock time picker |
| `OiUserMenu` | `navigation/oi_user_menu.dart` | User avatar menu |
| `OiWeekStrip` | `navigation/oi_week_strip.dart` | Week calendar strip |

## Overlays

| Name | Path | Role |
|------|------|------|
| `OiContextMenu` | `overlays/oi_context_menu.dart` | Right-click / long-press menu |
| `OiDialog` | `overlays/oi_dialog.dart` | Modal dialog |
| `OiDialogShell` | `overlays/oi_dialog_shell.dart` | Dialog frame chrome |
| `OiMenuItem` | `overlays/oi_menu_item.dart` | Menu row; **`OiMenuDivider`** |
| `OiSheet` | `overlays/oi_sheet.dart` | Bottom/side sheet |
| `OiSnackBar` | `overlays/oi_snack_bar.dart` | Transient snack |
| `OiToast` | `overlays/oi_toast.dart` | Toast notification |

## Panels

| Name | Path | Role |
|------|------|------|
| `OiPanel` | `panels/oi_panel.dart` | Panel container |
| `OiPanelHeader` | `panels/oi_panel_header.dart` | Panel title/actions |
| `OiResizable` | `panels/oi_resizable.dart` | Drag-to-resize wrapper |
| `OiSplitPane` | `panels/oi_split_pane.dart` | Split layout with drag handle |
