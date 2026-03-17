import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

/// Theme data for button components.
///
/// All fields are nullable; a `null` value instructs the component to use
/// its built-in defaults.
///
/// {@category Foundation}
@immutable
class OiButtonThemeData {
  /// Creates an [OiButtonThemeData].
  const OiButtonThemeData({
    this.borderRadius,
    this.padding,
    this.textStyle,
  });

  /// The corner radius applied to button shapes.
  final BorderRadius? borderRadius;

  /// The internal padding of the button.
  final EdgeInsets? padding;

  /// The text style for button labels.
  final TextStyle? textStyle;

  /// Creates a copy with optionally overridden values.
  OiButtonThemeData copyWith({
    BorderRadius? borderRadius,
    EdgeInsets? padding,
    TextStyle? textStyle,
  }) {
    return OiButtonThemeData(
      borderRadius: borderRadius ?? this.borderRadius,
      padding: padding ?? this.padding,
      textStyle: textStyle ?? this.textStyle,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OiButtonThemeData &&
        other.borderRadius == borderRadius &&
        other.padding == padding &&
        other.textStyle == textStyle;
  }

  @override
  int get hashCode => Object.hash(borderRadius, padding, textStyle);
}

/// Theme data for text-input components.
///
/// All fields are nullable; a `null` value instructs the component to use
/// its built-in defaults.
///
/// {@category Foundation}
@immutable
class OiTextInputThemeData {
  /// Creates an [OiTextInputThemeData].
  const OiTextInputThemeData({
    this.borderRadius,
    this.contentPadding,
    this.borderColor,
    this.focusBorderColor,
  });

  /// The corner radius applied to the input field border.
  final BorderRadius? borderRadius;

  /// The padding between the border and the input text.
  final EdgeInsets? contentPadding;

  /// The color of the input border in its default (unfocused) state.
  final Color? borderColor;

  /// The color of the input border when the field has keyboard focus.
  final Color? focusBorderColor;

  /// Creates a copy with optionally overridden values.
  OiTextInputThemeData copyWith({
    BorderRadius? borderRadius,
    EdgeInsets? contentPadding,
    Color? borderColor,
    Color? focusBorderColor,
  }) {
    return OiTextInputThemeData(
      borderRadius: borderRadius ?? this.borderRadius,
      contentPadding: contentPadding ?? this.contentPadding,
      borderColor: borderColor ?? this.borderColor,
      focusBorderColor: focusBorderColor ?? this.focusBorderColor,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OiTextInputThemeData &&
        other.borderRadius == borderRadius &&
        other.contentPadding == contentPadding &&
        other.borderColor == borderColor &&
        other.focusBorderColor == focusBorderColor;
  }

  @override
  int get hashCode =>
      Object.hash(borderRadius, contentPadding, borderColor, focusBorderColor);
}

/// Theme data for select / dropdown components.
///
/// All fields are nullable; a `null` value instructs the component to use
/// its built-in defaults.
///
/// {@category Foundation}
@immutable
class OiSelectThemeData {
  /// Creates an [OiSelectThemeData].
  const OiSelectThemeData({
    this.borderRadius,
    this.itemHeight,
  });

  /// The corner radius applied to the select control border.
  final BorderRadius? borderRadius;

  /// The height of each option item in the dropdown list.
  final double? itemHeight;

  /// Creates a copy with optionally overridden values.
  OiSelectThemeData copyWith({
    BorderRadius? borderRadius,
    double? itemHeight,
  }) {
    return OiSelectThemeData(
      borderRadius: borderRadius ?? this.borderRadius,
      itemHeight: itemHeight ?? this.itemHeight,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OiSelectThemeData &&
        other.borderRadius == borderRadius &&
        other.itemHeight == itemHeight;
  }

  @override
  int get hashCode => Object.hash(borderRadius, itemHeight);
}

/// Theme data for card components.
///
/// All fields are nullable; a `null` value instructs the component to use
/// its built-in defaults.
///
/// {@category Foundation}
@immutable
class OiCardThemeData {
  /// Creates an [OiCardThemeData].
  const OiCardThemeData({
    this.borderRadius,
    this.elevation,
    this.padding,
  });

  /// The corner radius of the card surface.
  final BorderRadius? borderRadius;

  /// The elevation (shadow depth) of the card.
  final double? elevation;

  /// The internal padding of the card content area.
  final EdgeInsets? padding;

  /// Creates a copy with optionally overridden values.
  OiCardThemeData copyWith({
    BorderRadius? borderRadius,
    double? elevation,
    EdgeInsets? padding,
  }) {
    return OiCardThemeData(
      borderRadius: borderRadius ?? this.borderRadius,
      elevation: elevation ?? this.elevation,
      padding: padding ?? this.padding,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OiCardThemeData &&
        other.borderRadius == borderRadius &&
        other.elevation == elevation &&
        other.padding == padding;
  }

  @override
  int get hashCode => Object.hash(borderRadius, elevation, padding);
}

/// Theme data for dialog components.
///
/// All fields are nullable; a `null` value instructs the component to use
/// its built-in defaults.
///
/// {@category Foundation}
@immutable
class OiDialogThemeData {
  /// Creates an [OiDialogThemeData].
  const OiDialogThemeData({
    this.borderRadius,
    this.maxWidth,
  });

  /// The corner radius of the dialog surface.
  final BorderRadius? borderRadius;

  /// The maximum width of the dialog in logical pixels.
  final double? maxWidth;

  /// Creates a copy with optionally overridden values.
  OiDialogThemeData copyWith({
    BorderRadius? borderRadius,
    double? maxWidth,
  }) {
    return OiDialogThemeData(
      borderRadius: borderRadius ?? this.borderRadius,
      maxWidth: maxWidth ?? this.maxWidth,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OiDialogThemeData &&
        other.borderRadius == borderRadius &&
        other.maxWidth == maxWidth;
  }

  @override
  int get hashCode => Object.hash(borderRadius, maxWidth);
}

/// Theme data for toast / snackbar components.
///
/// All fields are nullable; a `null` value instructs the component to use
/// its built-in defaults.
///
/// {@category Foundation}
@immutable
class OiToastThemeData {
  /// Creates an [OiToastThemeData].
  const OiToastThemeData({
    this.borderRadius,
    this.elevation,
  });

  /// The corner radius of the toast surface.
  final BorderRadius? borderRadius;

  /// The elevation (shadow depth) of the toast.
  final double? elevation;

  /// Creates a copy with optionally overridden values.
  OiToastThemeData copyWith({
    BorderRadius? borderRadius,
    double? elevation,
  }) {
    return OiToastThemeData(
      borderRadius: borderRadius ?? this.borderRadius,
      elevation: elevation ?? this.elevation,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OiToastThemeData &&
        other.borderRadius == borderRadius &&
        other.elevation == elevation;
  }

  @override
  int get hashCode => Object.hash(borderRadius, elevation);
}

/// Theme data for tooltip components.
///
/// All fields are nullable; a `null` value instructs the component to use
/// its built-in defaults.
///
/// {@category Foundation}
@immutable
class OiTooltipThemeData {
  /// Creates an [OiTooltipThemeData].
  const OiTooltipThemeData({
    this.borderRadius,
    this.padding,
  });

  /// The corner radius of the tooltip surface.
  final BorderRadius? borderRadius;

  /// The internal padding of the tooltip content.
  final EdgeInsets? padding;

  /// Creates a copy with optionally overridden values.
  OiTooltipThemeData copyWith({
    BorderRadius? borderRadius,
    EdgeInsets? padding,
  }) {
    return OiTooltipThemeData(
      borderRadius: borderRadius ?? this.borderRadius,
      padding: padding ?? this.padding,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OiTooltipThemeData &&
        other.borderRadius == borderRadius &&
        other.padding == padding;
  }

  @override
  int get hashCode => Object.hash(borderRadius, padding);
}

/// Theme data for data-table components.
///
/// All fields are nullable; a `null` value instructs the component to use
/// its built-in defaults.
///
/// {@category Foundation}
@immutable
class OiTableThemeData {
  /// Creates an [OiTableThemeData].
  const OiTableThemeData({
    this.headerHeight,
    this.rowHeight,
    this.borderColor,
  });

  /// The height of the table header row in logical pixels.
  final double? headerHeight;

  /// The height of each data row in logical pixels.
  final double? rowHeight;

  /// The color of the table border and row dividers.
  final Color? borderColor;

  /// Creates a copy with optionally overridden values.
  OiTableThemeData copyWith({
    double? headerHeight,
    double? rowHeight,
    Color? borderColor,
  }) {
    return OiTableThemeData(
      headerHeight: headerHeight ?? this.headerHeight,
      rowHeight: rowHeight ?? this.rowHeight,
      borderColor: borderColor ?? this.borderColor,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OiTableThemeData &&
        other.headerHeight == headerHeight &&
        other.rowHeight == rowHeight &&
        other.borderColor == borderColor;
  }

  @override
  int get hashCode => Object.hash(headerHeight, rowHeight, borderColor);
}

/// Theme data for tab-bar components.
///
/// All fields are nullable; a `null` value instructs the component to use
/// its built-in defaults.
///
/// {@category Foundation}
@immutable
class OiTabsThemeData {
  /// Creates an [OiTabsThemeData].
  const OiTabsThemeData({
    this.indicatorColor,
    this.height,
  });

  /// The color of the active-tab indicator bar or highlight.
  final Color? indicatorColor;

  /// The height of the tab bar in logical pixels.
  final double? height;

  /// Creates a copy with optionally overridden values.
  OiTabsThemeData copyWith({
    Color? indicatorColor,
    double? height,
  }) {
    return OiTabsThemeData(
      indicatorColor: indicatorColor ?? this.indicatorColor,
      height: height ?? this.height,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OiTabsThemeData &&
        other.indicatorColor == indicatorColor &&
        other.height == height;
  }

  @override
  int get hashCode => Object.hash(indicatorColor, height);
}

/// Theme data for badge components.
///
/// All fields are nullable; a `null` value instructs the component to use
/// its built-in defaults.
///
/// {@category Foundation}
@immutable
class OiBadgeThemeData {
  /// Creates an [OiBadgeThemeData].
  const OiBadgeThemeData({
    this.borderRadius,
  });

  /// The corner radius of the badge pill shape.
  final BorderRadius? borderRadius;

  /// Creates a copy with optionally overridden values.
  OiBadgeThemeData copyWith({
    BorderRadius? borderRadius,
  }) {
    return OiBadgeThemeData(
      borderRadius: borderRadius ?? this.borderRadius,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OiBadgeThemeData && other.borderRadius == borderRadius;
  }

  @override
  int get hashCode => borderRadius.hashCode;
}

/// Theme data for checkbox components.
///
/// All fields are nullable; a `null` value instructs the component to use
/// its built-in defaults.
///
/// {@category Foundation}
@immutable
class OiCheckboxThemeData {
  /// Creates an [OiCheckboxThemeData].
  const OiCheckboxThemeData({
    this.size,
    this.borderRadius,
  });

  /// The width and height of the checkbox in logical pixels.
  final double? size;

  /// The corner radius of the checkbox border.
  final BorderRadius? borderRadius;

  /// Creates a copy with optionally overridden values.
  OiCheckboxThemeData copyWith({
    double? size,
    BorderRadius? borderRadius,
  }) {
    return OiCheckboxThemeData(
      size: size ?? this.size,
      borderRadius: borderRadius ?? this.borderRadius,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OiCheckboxThemeData &&
        other.size == size &&
        other.borderRadius == borderRadius;
  }

  @override
  int get hashCode => Object.hash(size, borderRadius);
}

/// Theme data for toggle-switch components.
///
/// All fields are nullable; a `null` value instructs the component to use
/// its built-in defaults.
///
/// {@category Foundation}
@immutable
class OiSwitchThemeData {
  /// Creates an [OiSwitchThemeData].
  const OiSwitchThemeData({
    this.width,
    this.height,
  });

  /// The total width of the switch track in logical pixels.
  final double? width;

  /// The total height of the switch track in logical pixels.
  final double? height;

  /// Creates a copy with optionally overridden values.
  OiSwitchThemeData copyWith({
    double? width,
    double? height,
  }) {
    return OiSwitchThemeData(
      width: width ?? this.width,
      height: height ?? this.height,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OiSwitchThemeData &&
        other.width == width &&
        other.height == height;
  }

  @override
  int get hashCode => Object.hash(width, height);
}

/// Theme data for bottom-sheet / side-sheet components.
///
/// All fields are nullable; a `null` value instructs the component to use
/// its built-in defaults.
///
/// {@category Foundation}
@immutable
class OiSheetThemeData {
  /// Creates an [OiSheetThemeData].
  const OiSheetThemeData({
    this.borderRadius,
  });

  /// The corner radius applied to the top corners of the sheet surface.
  final BorderRadius? borderRadius;

  /// Creates a copy with optionally overridden values.
  OiSheetThemeData copyWith({
    BorderRadius? borderRadius,
  }) {
    return OiSheetThemeData(
      borderRadius: borderRadius ?? this.borderRadius,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OiSheetThemeData && other.borderRadius == borderRadius;
  }

  @override
  int get hashCode => borderRadius.hashCode;
}

/// Theme data for avatar components.
///
/// All fields are nullable; a `null` value instructs the component to use
/// its built-in defaults.
///
/// {@category Foundation}
@immutable
class OiAvatarThemeData {
  /// Creates an [OiAvatarThemeData].
  const OiAvatarThemeData({
    this.borderRadius,
  });

  /// The corner radius of the avatar shape.
  ///
  /// Use `BorderRadius.circular(999)` for a fully circular avatar.
  final BorderRadius? borderRadius;

  /// Creates a copy with optionally overridden values.
  OiAvatarThemeData copyWith({
    BorderRadius? borderRadius,
  }) {
    return OiAvatarThemeData(
      borderRadius: borderRadius ?? this.borderRadius,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OiAvatarThemeData && other.borderRadius == borderRadius;
  }

  @override
  int get hashCode => borderRadius.hashCode;
}

/// Theme data for linear- and circular-progress components.
///
/// All fields are nullable; a `null` value instructs the component to use
/// its built-in defaults.
///
/// {@category Foundation}
@immutable
class OiProgressThemeData {
  /// Creates an [OiProgressThemeData].
  const OiProgressThemeData({
    this.height,
    this.borderRadius,
  });

  /// The height of the linear progress track in logical pixels.
  final double? height;

  /// The corner radius of the linear progress track.
  final BorderRadius? borderRadius;

  /// Creates a copy with optionally overridden values.
  OiProgressThemeData copyWith({
    double? height,
    BorderRadius? borderRadius,
  }) {
    return OiProgressThemeData(
      height: height ?? this.height,
      borderRadius: borderRadius ?? this.borderRadius,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OiProgressThemeData &&
        other.height == height &&
        other.borderRadius == borderRadius;
  }

  @override
  int get hashCode => Object.hash(height, borderRadius);
}

/// Theme data for sidebar / navigation-rail components.
///
/// All fields are nullable; a `null` value instructs the component to use
/// its built-in defaults.
///
/// {@category Foundation}
@immutable
class OiSidebarThemeData {
  /// Creates an [OiSidebarThemeData].
  const OiSidebarThemeData({
    this.width,
    this.compactWidth,
  });

  /// The width of the expanded sidebar in logical pixels.
  final double? width;

  /// The width of the collapsed / compact sidebar in logical pixels.
  final double? compactWidth;

  /// Creates a copy with optionally overridden values.
  OiSidebarThemeData copyWith({
    double? width,
    double? compactWidth,
  }) {
    return OiSidebarThemeData(
      width: width ?? this.width,
      compactWidth: compactWidth ?? this.compactWidth,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OiSidebarThemeData &&
        other.width == width &&
        other.compactWidth == compactWidth;
  }

  @override
  int get hashCode => Object.hash(width, compactWidth);
}

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
        sidebar = null;

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
        other.sidebar == sidebar;
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
        sidebar,
      );
}
