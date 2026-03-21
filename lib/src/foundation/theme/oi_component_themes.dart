import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/theme/component_themes/oi_avatar_theme_data.dart';
import 'package:obers_ui/src/foundation/theme/component_themes/oi_badge_theme_data.dart';
import 'package:obers_ui/src/foundation/theme/component_themes/oi_button_theme_data.dart';
import 'package:obers_ui/src/foundation/theme/component_themes/oi_card_theme_data.dart';
import 'package:obers_ui/src/foundation/theme/component_themes/oi_checkbox_theme_data.dart';
import 'package:obers_ui/src/foundation/theme/component_themes/oi_dialog_theme_data.dart';
import 'package:obers_ui/src/foundation/theme/component_themes/oi_field_display_theme.dart';
import 'package:obers_ui/src/foundation/theme/component_themes/oi_file_explorer_theme_data.dart';
import 'package:obers_ui/src/foundation/theme/component_themes/oi_progress_theme_data.dart';
import 'package:obers_ui/src/foundation/theme/component_themes/oi_select_theme_data.dart';
import 'package:obers_ui/src/foundation/theme/component_themes/oi_sheet_theme_data.dart';
import 'package:obers_ui/src/foundation/theme/component_themes/oi_sidebar_theme_data.dart';
import 'package:obers_ui/src/foundation/theme/component_themes/oi_switch_theme_data.dart';
import 'package:obers_ui/src/foundation/theme/component_themes/oi_table_theme_data.dart';
import 'package:obers_ui/src/foundation/theme/component_themes/oi_tabs_theme_data.dart';
import 'package:obers_ui/src/foundation/theme/component_themes/oi_text_input_theme_data.dart';
import 'package:obers_ui/src/foundation/theme/component_themes/oi_toast_theme_data.dart';
import 'package:obers_ui/src/foundation/theme/component_themes/oi_pagination_theme_data.dart';
import 'package:obers_ui/src/foundation/theme/component_themes/oi_tooltip_theme_data.dart';

export 'component_themes/oi_avatar_theme_data.dart';
export 'component_themes/oi_badge_theme_data.dart';
export 'component_themes/oi_button_theme_data.dart';
export 'component_themes/oi_card_theme_data.dart';
export 'component_themes/oi_checkbox_theme_data.dart';
export 'component_themes/oi_dialog_theme_data.dart';
export 'component_themes/oi_field_display_theme.dart';
export 'component_themes/oi_file_explorer_theme_data.dart';
export 'component_themes/oi_progress_theme_data.dart';
export 'component_themes/oi_select_theme_data.dart';
export 'component_themes/oi_sheet_theme_data.dart';
export 'component_themes/oi_sidebar_theme_data.dart';
export 'component_themes/oi_switch_theme_data.dart';
export 'component_themes/oi_table_theme_data.dart';
export 'component_themes/oi_tabs_theme_data.dart';
export 'component_themes/oi_text_input_theme_data.dart';
export 'component_themes/oi_toast_theme_data.dart';
export 'component_themes/oi_pagination_theme_data.dart';
export 'component_themes/oi_tooltip_theme_data.dart';

/// Aggregates per-component theme overrides for the design system.
///
/// Each field corresponds to one component family. A `null` value means
/// "use the component's built-in defaults". Use [OiComponentThemes.empty]
/// to start with all defaults, then apply [copyWith] for specific overrides.
///
/// {@category Foundation}
@immutable
class OiComponentThemes {
  /// Creates an [OiComponentThemes] with all override fields specified.
  const OiComponentThemes({
    this.button,
    this.textInput,
    this.select,
    this.card,
    this.dialog,
    this.toast,
    this.tooltip,
    this.table,
    this.tabs,
    this.badge,
    this.checkbox,
    this.switchTheme,
    this.sheet,
    this.avatar,
    this.progress,
    this.sidebar,
    this.fileExplorer,
    this.fieldDisplay,
    this.pagination,
  });

  /// Creates an [OiComponentThemes] with all fields set to `null`.
  ///
  /// Components will fall back to their built-in defaults.
  const OiComponentThemes.empty()
    : button = null,
      textInput = null,
      select = null,
      card = null,
      dialog = null,
      toast = null,
      tooltip = null,
      table = null,
      tabs = null,
      badge = null,
      checkbox = null,
      switchTheme = null,
      sheet = null,
      avatar = null,
      progress = null,
      sidebar = null,
      fileExplorer = null,
      fieldDisplay = null,
      pagination = null;

  /// Theme overrides for button components.
  final OiButtonThemeData? button;

  /// Theme overrides for text-input components.
  final OiTextInputThemeData? textInput;

  /// Theme overrides for select / dropdown components.
  final OiSelectThemeData? select;

  /// Theme overrides for card components.
  final OiCardThemeData? card;

  /// Theme overrides for dialog components.
  final OiDialogThemeData? dialog;

  /// Theme overrides for toast / snackbar components.
  final OiToastThemeData? toast;

  /// Theme overrides for tooltip components.
  final OiTooltipThemeData? tooltip;

  /// Theme overrides for data-table components.
  final OiTableThemeData? table;

  /// Theme overrides for tab-bar components.
  final OiTabsThemeData? tabs;

  /// Theme overrides for badge components.
  final OiBadgeThemeData? badge;

  /// Theme overrides for checkbox components.
  final OiCheckboxThemeData? checkbox;

  /// Theme overrides for toggle-switch components.
  final OiSwitchThemeData? switchTheme;

  /// Theme overrides for bottom-sheet / side-sheet components.
  final OiSheetThemeData? sheet;

  /// Theme overrides for avatar components.
  final OiAvatarThemeData? avatar;

  /// Theme overrides for progress components.
  final OiProgressThemeData? progress;

  /// Theme overrides for sidebar / navigation-rail components.
  final OiSidebarThemeData? sidebar;

  /// Theme overrides for file explorer components.
  final OiFileExplorerThemeData? fileExplorer;

  /// Theme overrides for field display components.
  final OiFieldDisplayThemeData? fieldDisplay;

  /// Theme overrides for pagination components.
  final OiPaginationThemeData? pagination;

  /// Creates a copy with optionally overridden component theme fields.
  OiComponentThemes copyWith({
    OiButtonThemeData? button,
    OiTextInputThemeData? textInput,
    OiSelectThemeData? select,
    OiCardThemeData? card,
    OiDialogThemeData? dialog,
    OiToastThemeData? toast,
    OiTooltipThemeData? tooltip,
    OiTableThemeData? table,
    OiTabsThemeData? tabs,
    OiBadgeThemeData? badge,
    OiCheckboxThemeData? checkbox,
    OiSwitchThemeData? switchTheme,
    OiSheetThemeData? sheet,
    OiAvatarThemeData? avatar,
    OiProgressThemeData? progress,
    OiSidebarThemeData? sidebar,
    OiFileExplorerThemeData? fileExplorer,
    OiFieldDisplayThemeData? fieldDisplay,
    OiPaginationThemeData? pagination,
  }) {
    return OiComponentThemes(
      button: button ?? this.button,
      textInput: textInput ?? this.textInput,
      select: select ?? this.select,
      card: card ?? this.card,
      dialog: dialog ?? this.dialog,
      toast: toast ?? this.toast,
      tooltip: tooltip ?? this.tooltip,
      table: table ?? this.table,
      tabs: tabs ?? this.tabs,
      badge: badge ?? this.badge,
      checkbox: checkbox ?? this.checkbox,
      switchTheme: switchTheme ?? this.switchTheme,
      sheet: sheet ?? this.sheet,
      avatar: avatar ?? this.avatar,
      progress: progress ?? this.progress,
      sidebar: sidebar ?? this.sidebar,
      fileExplorer: fileExplorer ?? this.fileExplorer,
      fieldDisplay: fieldDisplay ?? this.fieldDisplay,
      pagination: pagination ?? this.pagination,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OiComponentThemes &&
        other.button == button &&
        other.textInput == textInput &&
        other.select == select &&
        other.card == card &&
        other.dialog == dialog &&
        other.toast == toast &&
        other.tooltip == tooltip &&
        other.table == table &&
        other.tabs == tabs &&
        other.badge == badge &&
        other.checkbox == checkbox &&
        other.switchTheme == switchTheme &&
        other.sheet == sheet &&
        other.avatar == avatar &&
        other.progress == progress &&
        other.sidebar == sidebar &&
        other.fileExplorer == fileExplorer &&
        other.fieldDisplay == fieldDisplay &&
        other.pagination == pagination;
  }

  @override
  int get hashCode => Object.hash(
    button,
    textInput,
    select,
    card,
    dialog,
    toast,
    tooltip,
    table,
    tabs,
    badge,
    checkbox,
    switchTheme,
    sheet,
    avatar,
    progress,
    Object.hash(sidebar, fileExplorer, fieldDisplay, pagination),
  );
}

/// An [InheritedWidget] that scopes an [OiButtonThemeData] override to a
/// subtree.
///
/// Place this widget above any button widgets that should share the same
/// theme override. Buttons look up their theme with [OiButtonThemeScope.of];
/// if no scope is found they fall back to [OiComponentThemes.button].
///
/// ```dart
/// OiButtonThemeScope(
///   theme: OiButtonThemeData(height: 48),
///   child: MyButtonArea(),
/// )
/// ```
///
/// {@category Foundation}
class OiButtonThemeScope extends InheritedWidget {
  /// Creates an [OiButtonThemeScope] that provides [theme] to [child].
  const OiButtonThemeScope({
    required this.theme,
    required super.child,
    super.key,
  });

  /// The button theme data to inject into the subtree.
  final OiButtonThemeData theme;

  /// Returns the nearest [OiButtonThemeData] from the widget tree, or `null`
  /// if no [OiButtonThemeScope] ancestor is found.
  static OiButtonThemeData? of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<OiButtonThemeScope>()
        ?.theme;
  }

  @override
  bool updateShouldNotify(OiButtonThemeScope oldWidget) =>
      theme != oldWidget.theme;
}
