import 'package:flutter/widgets.dart';

/// Theme data for file explorer components.
///
/// All fields are nullable; a `null` value instructs the component to use
/// its built-in defaults.
///
/// {@category Foundation}
@immutable
class OiFileExplorerThemeData {
  /// Creates an [OiFileExplorerThemeData].
  const OiFileExplorerThemeData({
    this.sidebarWidth,
    this.sidebarBackground,
    this.contentBackground,
    this.fileTileHeight,
    this.fileTileHoverColor,
    this.fileTileSelectedColor,
    this.fileGridCardBorderRadius,
    this.fileGridCardHoverElevation,
    this.dropHighlightColor,
    this.dropHighlightBorderColor,
    this.pathBarBackground,
    this.toolbarBackground,
    this.toolbarHeight,
    this.selectionToolbarColor,
    this.iconCategoryColors,
    this.folderIconColor,
    this.renamingFieldBackground,
  });

  /// The width of the sidebar in logical pixels.
  final double? sidebarWidth;

  /// The background color of the sidebar.
  final Color? sidebarBackground;

  /// The background color of the content area.
  final Color? contentBackground;

  /// The height of each file tile row in the list view.
  final double? fileTileHeight;

  /// The color of a file tile row on hover.
  final Color? fileTileHoverColor;

  /// The color of a file tile row when selected.
  final Color? fileTileSelectedColor;

  /// The border radius of file grid cards.
  final BorderRadius? fileGridCardBorderRadius;

  /// The elevation of file grid cards on hover.
  final double? fileGridCardHoverElevation;

  /// The color of the drop highlight overlay.
  final Color? dropHighlightColor;

  /// The border color of the drop highlight.
  final Color? dropHighlightBorderColor;

  /// The background color of the path bar.
  final Color? pathBarBackground;

  /// The background color of the toolbar.
  final Color? toolbarBackground;

  /// The height of the toolbar.
  final double? toolbarHeight;

  /// The color of the selection toolbar.
  final Color? selectionToolbarColor;

  /// Override colors for specific file type categories.
  final Map<String, Color>? iconCategoryColors;

  /// Override the default folder icon color.
  final Color? folderIconColor;

  /// The background color of the rename field.
  final Color? renamingFieldBackground;

  /// Creates a copy with optionally overridden values.
  OiFileExplorerThemeData copyWith({
    double? sidebarWidth,
    Color? sidebarBackground,
    Color? contentBackground,
    double? fileTileHeight,
    Color? fileTileHoverColor,
    Color? fileTileSelectedColor,
    BorderRadius? fileGridCardBorderRadius,
    double? fileGridCardHoverElevation,
    Color? dropHighlightColor,
    Color? dropHighlightBorderColor,
    Color? pathBarBackground,
    Color? toolbarBackground,
    double? toolbarHeight,
    Color? selectionToolbarColor,
    Map<String, Color>? iconCategoryColors,
    Color? folderIconColor,
    Color? renamingFieldBackground,
  }) {
    return OiFileExplorerThemeData(
      sidebarWidth: sidebarWidth ?? this.sidebarWidth,
      sidebarBackground: sidebarBackground ?? this.sidebarBackground,
      contentBackground: contentBackground ?? this.contentBackground,
      fileTileHeight: fileTileHeight ?? this.fileTileHeight,
      fileTileHoverColor: fileTileHoverColor ?? this.fileTileHoverColor,
      fileTileSelectedColor:
          fileTileSelectedColor ?? this.fileTileSelectedColor,
      fileGridCardBorderRadius:
          fileGridCardBorderRadius ?? this.fileGridCardBorderRadius,
      fileGridCardHoverElevation:
          fileGridCardHoverElevation ?? this.fileGridCardHoverElevation,
      dropHighlightColor: dropHighlightColor ?? this.dropHighlightColor,
      dropHighlightBorderColor:
          dropHighlightBorderColor ?? this.dropHighlightBorderColor,
      pathBarBackground: pathBarBackground ?? this.pathBarBackground,
      toolbarBackground: toolbarBackground ?? this.toolbarBackground,
      toolbarHeight: toolbarHeight ?? this.toolbarHeight,
      selectionToolbarColor:
          selectionToolbarColor ?? this.selectionToolbarColor,
      iconCategoryColors: iconCategoryColors ?? this.iconCategoryColors,
      folderIconColor: folderIconColor ?? this.folderIconColor,
      renamingFieldBackground:
          renamingFieldBackground ?? this.renamingFieldBackground,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OiFileExplorerThemeData &&
        other.sidebarWidth == sidebarWidth &&
        other.sidebarBackground == sidebarBackground &&
        other.contentBackground == contentBackground &&
        other.fileTileHeight == fileTileHeight &&
        other.folderIconColor == folderIconColor;
  }

  @override
  int get hashCode => Object.hash(
    sidebarWidth,
    sidebarBackground,
    contentBackground,
    fileTileHeight,
    folderIconColor,
  );
}
