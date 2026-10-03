import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/display/oi_badge.dart';
import 'package:obers_ui/src/components/display/oi_tooltip.dart';
import 'package:obers_ui/src/foundation/oi_icons.dart';
import 'package:obers_ui/src/foundation/persistence/oi_settings_driver.dart';
import 'package:obers_ui/src/foundation/persistence/oi_settings_mixin.dart';
import 'package:obers_ui/src/foundation/persistence/oi_settings_provider.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/models/settings/oi_sidebar_settings.dart'
    hide OiSidebarMode;
import 'package:obers_ui/src/primitives/display/oi_icon.dart';
import 'package:obers_ui/src/primitives/interaction/oi_tappable.dart';

// ── Data models ──────────────────────────────────────────────────────────────

/// A section within the sidebar.
///
/// Sections group related [items] under an optional [title]. When
/// [collapsible] is `true` the section can be expanded and collapsed by
/// tapping its header.
@immutable
class OiSidebarSection {
  /// Creates an [OiSidebarSection].
  const OiSidebarSection({
    required this.items,
    this.title,
    this.collapsible = true,
  });

  /// The optional header title for this section.
  ///
  /// When `null` no header is rendered and the items appear without a
  /// visual grouping label.
  final String? title;

  /// The navigation items displayed in this section.
  final List<OiSidebarItem> items;

  /// Whether the section can be collapsed by the user.
  ///
  /// When `true` (the default) a tap on the section header toggles
  /// visibility of its [items].
  final bool collapsible;
}

/// An item in the sidebar.
///
/// Each item has a unique [id], a display [label], and an [icon]. Items may
/// optionally carry a [badgeCount], nested [children], or be [disabled].
@immutable
class OiSidebarItem {
  /// Creates an [OiSidebarItem].
  const OiSidebarItem({
    required this.id,
    required this.label,
    required this.icon,
    this.badgeCount,
    this.children,
    this.disabled = false,
    this.contextChild = false,
    this.monospace = false,
  });

  /// A unique identifier used to track selection.
  final String id;

  /// The display label shown next to the icon in full mode.
  final String label;

  /// The icon displayed for this item.
  final IconData icon;

  /// An optional badge count displayed to the right of the label.
  ///
  /// When `null` no badge is shown.
  final int? badgeCount;

  /// Optional nested child items.
  ///
  /// When non-null the item acts as a parent that can be expanded to reveal
  /// its children.
  final List<OiSidebarItem>? children;

  /// Shows a contextual branch instead of a repeated destination icon.
  /// Ordinary expandable groups retain their icon and indentation by default.
  final bool contextChild;

  /// Uses the semantic code role for record identifiers.
  final bool monospace;

  /// Whether this item is non-interactive.
  final bool disabled;
}

// ── Display mode ─────────────────────────────────────────────────────────────

/// The display mode of the sidebar.
///
/// {@category Composites}
enum OiSidebarMode {
  /// Shows icons and labels (default ~260px wide).
  full,

  /// Shows only icons with tooltips (~64px wide).
  compact,

  /// Not visible.
  hidden,
}

// ── OiSidebar ────────────────────────────────────────────────────────────────

/// The main application sidebar with collapsible sections and nested items.
///
/// Supports three modes:
/// - [OiSidebarMode.full]: Shows icons and labels (default ~260px wide)
/// - [OiSidebarMode.compact]: Shows only icons with tooltips (~64px wide)
/// - [OiSidebarMode.hidden]: Not visible
///
/// The sidebar supports:
/// - Collapsible sections with optional titles
/// - Nested items with indentation
/// - Badge counts on items
/// - Keyboard navigation with arrow keys and Enter
/// - Accessible semantics with a navigation role
/// - Optional header and footer widgets
/// - Optional resizable width
///
/// {@category Composites}
class OiSidebar extends StatefulWidget {
  /// Creates an [OiSidebar].
  const OiSidebar({
    required this.sections,
    required this.selectedId,
    required this.onSelect,
    required this.label,
    this.mode = OiSidebarMode.full,
    this.width,
    this.compactWidth,
    this.resizable = false,
    this.header,
    this.footer,
    this.settingsDriver,
    this.settingsKey,
    this.settingsNamespace = 'oi_sidebar',
    super.key,
  });

  /// The sections containing navigation items.
  final List<OiSidebarSection> sections;

  /// The [OiSidebarItem.id] of the currently selected item.
  ///
  /// When `null` no item is highlighted as selected.
  final String? selectedId;

  /// Called when the user selects an item.
  final ValueChanged<String> onSelect;

  /// The accessibility label for the sidebar navigation landmark.
  final String label;

  /// The display mode controlling visibility and width.
  final OiSidebarMode mode;

  /// The width in logical pixels when [mode] is [OiSidebarMode.full].
  final double? width;

  /// The width in logical pixels when [mode] is [OiSidebarMode.compact].
  final double? compactWidth;

  /// Whether the sidebar edge can be dragged to resize.
  final bool resizable;

  /// An optional widget rendered above the navigation items.
  final Widget? header;

  /// An optional widget rendered below the navigation items.
  final Widget? footer;

  // ── Settings persistence ──────────────────────────────────────────────────

  /// Driver used to persist settings. When `null` settings are not persisted.
  final OiSettingsDriver? settingsDriver;

  /// Sub-key scoping this sidebar's settings within [settingsNamespace].
  final String? settingsKey;

  /// Top-level namespace for settings storage.
  final String settingsNamespace;

  @override
  State<OiSidebar> createState() => _OiSidebarState();
}

class _OiSidebarState extends State<OiSidebar>
    with
        TickerProviderStateMixin,
        OiSettingsMixin<OiSidebar, OiSidebarSettings> {
  final Set<String> _collapsedSections = {};
  final Set<String> _expandedParents = {};
  final Map<String, AnimationController> _expandControllers = {};
  int _focusedIndex = -1;
  late FocusNode _focusNode;

  /// Flattened list of all visible item ids for keyboard navigation.
  List<_FlatItem> _flatItems = [];

  /// Resolved driver: explicit widget prop → OiSettingsProvider → null.
  OiSettingsDriver? _resolvedDriver;

  // ── OiSettingsMixin contract ───────────────────────────────────────────────

  @override
  String get settingsNamespace => widget.settingsNamespace;

  @override
  String? get settingsKey => widget.settingsKey;

  @override
  OiSettingsDriver? get settingsDriver => _resolvedDriver;

  @override
  OiSidebarSettings get defaultSettings => const OiSidebarSettings();

  @override
  OiSidebarSettings deserializeSettings(Map<String, dynamic> json) =>
      OiSidebarSettings.fromJson(json);

  @override
  OiSidebarSettings mergeSettings(
    OiSidebarSettings saved,
    OiSidebarSettings defaults,
  ) => saved.mergeWith(defaults);

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void initState() {
    _resolvedDriver = widget.settingsDriver;
    super.initState();
    _focusNode = FocusNode();
    _revealSelectedParents();
    _rebuildFlatItems();
  }

  @override
  void didUpdateWidget(OiSidebar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedId != widget.selectedId) {
      _revealSelectedParents();
    }
    _rebuildFlatItems();
  }

  void _revealSelectedParents() {
    bool visit(OiSidebarItem item) {
      final containsSelection =
          item.children?.map(visit).fold(false, (a, b) => a || b) ?? false;
      if (containsSelection) {
        _expandedParents.add(item.id);
        _expandControllers[item.id]?.value = 1;
      }
      return item.id == widget.selectedId || containsSelection;
    }

    for (final section in widget.sections) {
      section.items.forEach(visit);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newDriver = widget.settingsDriver ?? OiSettingsProvider.of(context);
    if (newDriver != _resolvedDriver) {
      _resolvedDriver = newDriver;
      if (settingsLoaded) {
        unawaited(reloadSettings());
      }
    }
    if (settingsLoaded && settingsDriver != null) {
      _applySettings(currentSettings);
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    for (final c in _expandControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  AnimationController _controllerFor(String parentId) {
    return _expandControllers.putIfAbsent(parentId, () {
      final controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 200),
        value: _expandedParents.contains(parentId) ? 1.0 : 0.0,
      );
      return controller;
    });
  }

  void _applySettings(OiSidebarSettings settings) {
    _collapsedSections
      ..clear()
      ..addAll(settings.collapsedSectionIds);
    _rebuildFlatItems();
  }

  OiSidebarSettings _toSettings() {
    return OiSidebarSettings(
      collapsedSectionIds: Set<String>.from(_collapsedSections),
    );
  }

  bool _contextOnly(OiSidebarItem item) =>
      item.children?.isNotEmpty == true &&
      item.children!.every((child) => child.contextChild);

  void _rebuildFlatItems() {
    final items = <_FlatItem>[];
    for (var si = 0; si < widget.sections.length; si++) {
      final section = widget.sections[si];
      final sectionKey = section.title ?? 'section_$si';
      if (_collapsedSections.contains(sectionKey)) continue;
      for (final item in section.items) {
        items.add(_FlatItem(item: item, depth: 0));
        if (item.children != null &&
            (_contextOnly(item) || _expandedParents.contains(item.id))) {
          for (final child in item.children!) {
            items.add(_FlatItem(item: child, depth: 1));
          }
        }
      }
    }
    _flatItems = items;
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }

    final key = event.logicalKey;

    if (key == LogicalKeyboardKey.arrowDown) {
      _moveFocus(1);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowUp) {
      _moveFocus(-1);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.numpadEnter) {
      if (_focusedIndex >= 0 && _focusedIndex < _flatItems.length) {
        final fi = _flatItems[_focusedIndex];
        if (!fi.item.disabled) {
          widget.onSelect(fi.item.id);
        }
      }
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  void _moveFocus(int delta) {
    if (_flatItems.isEmpty) return;
    var next = _focusedIndex + delta;
    // Skip disabled items.
    while (next >= 0 &&
        next < _flatItems.length &&
        _flatItems[next].item.disabled) {
      next += delta;
    }
    if (next >= 0 && next < _flatItems.length) {
      setState(() => _focusedIndex = next);
    }
  }

  void _toggleSection(String sectionKey) {
    setState(() {
      if (_collapsedSections.contains(sectionKey)) {
        _collapsedSections.remove(sectionKey);
      } else {
        _collapsedSections.add(sectionKey);
      }
      _rebuildFlatItems();
    });
    updateSettings(_toSettings());
  }

  void _toggleParent(String parentId) {
    final controller = _controllerFor(parentId);
    setState(() {
      if (_expandedParents.contains(parentId)) {
        _expandedParents.remove(parentId);
        controller.reverse();
      } else {
        _expandedParents.add(parentId);
        controller.forward();
      }
      _rebuildFlatItems();
    });
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (widget.mode == OiSidebarMode.hidden) {
      return const SizedBox.shrink();
    }

    final compact = widget.mode == OiSidebarMode.compact;

    return SizedBox(
      width: compact
          ? widget.compactWidth ??
                context.components.sidebar?.compactWidth ??
                64
          : widget.width ?? context.components.sidebar?.width ?? 260,
      child: ColoredBox(
        color:
            context.components.sidebar?.backgroundColor ??
            context.colors.surface,
        child: Semantics(
          label: widget.label,
          explicitChildNodes: true,
          child: Focus(
            focusNode: _focusNode,
            onKeyEvent: _handleKeyEvent,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (widget.header != null) widget.header!,
                Expanded(
                  child: SingleChildScrollView(
                    padding: context.components.sidebar?.padding,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: _buildSections(context, compact),
                    ),
                  ),
                ),
                if (widget.footer != null) widget.footer!,
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildSections(BuildContext context, bool compact) {
    final widgets = <Widget>[];
    for (var si = 0; si < widget.sections.length; si++) {
      final section = widget.sections[si];
      final sectionKey = section.title ?? 'section_$si';
      final collapsed = _collapsedSections.contains(sectionKey);

      // Section header.
      if (section.title != null) {
        widgets.add(
          _buildSectionHeader(context, section, sectionKey, collapsed),
        );
      }

      // Items.
      if (!collapsed) {
        for (final item in section.items) {
          if (widgets.isNotEmpty &&
              context.components.sidebar?.itemSpacing != null) {
            widgets.add(
              SizedBox(height: context.components.sidebar!.itemSpacing),
            );
          }
          widgets.add(_buildItem(context, item, 0, compact));
          if (item.children != null && item.children!.isNotEmpty) {
            final controller = _controllerFor(item.id);
            final childColumn = Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final child in item.children!)
                  _buildItem(context, child, 1, compact),
              ],
            );
            if (_contextOnly(item)) {
              widgets.add(
                Padding(
                  padding: EdgeInsets.only(
                    top: context.components.sidebar?.itemSpacing ?? 0,
                  ),
                  child: childColumn,
                ),
              );
            } else {
              widgets.add(
                AnimatedBuilder(
                  animation: controller,
                  builder: (context, child) {
                    if (controller.isDismissed) return const SizedBox.shrink();
                    return SizeTransition(
                      sizeFactor: CurvedAnimation(
                        parent: controller,
                        curve: Curves.easeInOut,
                      ),
                      alignment: AlignmentDirectional.topStart,
                      child: child,
                    );
                  },
                  child: childColumn,
                ),
              );
            }
          }
        }
      }
    }
    return widgets;
  }

  Widget _buildSectionHeader(
    BuildContext context,
    OiSidebarSection section,
    String sectionKey,
    bool collapsed,
  ) {
    final colors = context.colors;
    Widget header = Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        section.title!,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.5,
          color: colors.textMuted,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );

    if (section.collapsible) {
      header = GestureDetector(
        onTap: () => _toggleSection(sectionKey),
        behavior: HitTestBehavior.opaque,
        child: header,
      );
    }

    return header;
  }

  Widget _buildItem(
    BuildContext context,
    OiSidebarItem item,
    int depth,
    bool compact,
  ) {
    final colors = context.colors;
    final sidebarTheme = context.components.sidebar;
    final selected = item.id == widget.selectedId;
    final hasKids =
        item.children != null &&
        item.children!.isNotEmpty &&
        !_contextOnly(item);
    final kidsExpanded = _expandedParents.contains(item.id);

    // Determine the flat index for keyboard focus styling.
    final flatIndex = _flatItems.indexWhere((fi) => fi.item.id == item.id);
    final isFocused = flatIndex == _focusedIndex;

    Color bg;
    if (selected) {
      bg =
          sidebarTheme?.selectedBackground ??
          colors.primary.base.withValues(alpha: 0.1);
    } else if (isFocused) {
      bg = colors.surfaceHover;
    } else {
      bg = const Color(0x00000000);
    }

    final textColor = selected
        ? sidebarTheme?.selectedForeground ?? colors.primary.base
        : item.disabled
        ? colors.textMuted
        : sidebarTheme?.foreground ?? colors.text;

    final iconColor = selected
        ? sidebarTheme?.selectedIconColor ??
              sidebarTheme?.selectedForeground ??
              colors.primary.base
        : item.disabled
        ? colors.textMuted
        : sidebarTheme?.iconColor ?? colors.textSubtle;

    // Unified layout so icons hold position during the animated width
    // transition. The icon sits in a fixed-width leading area that matches
    // the collapsed sidebar width. Labels and trailing widgets are clipped
    // by the parent AnimatedContainer as it shrinks.
    final indent = depth * 24.0;

    final content = item.contextChild && !compact
        ? Row(
            children: [
              SizedBox(
                width: (sidebarTheme?.iconWidth ?? 24) + 12,
                height: sidebarTheme?.itemHeight ?? 40,
                child: CustomPaint(
                  key: const Key('oi_sidebar_context_branch'),
                  painter: _ContextBranchPainter(
                    sidebarTheme?.contextBranchColor ?? colors.borderSubtle,
                    Directionality.of(context),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  constraints: BoxConstraints(
                    minHeight: sidebarTheme?.itemHeight ?? 40,
                  ),
                  alignment: AlignmentDirectional.centerStart,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: sidebarTheme?.itemRadius,
                    border:
                        selected && sidebarTheme?.selectedBorderColor != null
                        ? Border.all(color: sidebarTheme!.selectedBorderColor!)
                        : null,
                  ),
                  child: Text(
                    item.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style:
                        (item.monospace
                                ? context.textTheme.code
                                : context.textTheme.body)
                            .copyWith(
                              color: textColor,
                              fontWeight: selected ? FontWeight.w500 : null,
                            ),
                  ),
                ),
              ),
            ],
          )
        : Container(
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: sidebarTheme?.itemRadius,
            ),
            foregroundDecoration: BoxDecoration(
              borderRadius: sidebarTheme?.itemRadius,
              border: selected && sidebarTheme?.selectedBorderColor != null
                  ? Border.all(color: sidebarTheme!.selectedBorderColor!)
                  : null,
            ),
            constraints: BoxConstraints(
              minHeight: sidebarTheme?.itemHeight ?? 40,
            ),
            padding:
                sidebarTheme?.itemPadding ??
                const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                SizedBox(
                  width:
                      sidebarTheme?.iconWidth ??
                      widget.compactWidth ??
                      sidebarTheme?.compactWidth ??
                      64,
                  child: Center(
                    child: OiIcon.raw(
                      item.icon,
                      size: sidebarTheme?.iconSize ?? 20,
                      color: iconColor,
                    ),
                  ),
                ),
                if (indent > 0) SizedBox(width: indent),
                if (!compact) ...[
                  SizedBox(width: sidebarTheme?.labelGap ?? 0),
                  Expanded(
                    child: Text(
                      item.label,
                      style:
                          (item.monospace
                                  ? context.textTheme.code
                                  : context.textTheme.body)
                              .copyWith(
                                fontSize: 14,
                                fontWeight: selected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              )
                              .merge(
                                selected
                                    ? sidebarTheme?.selectedTextStyle ??
                                          sidebarTheme?.textStyle
                                    : sidebarTheme?.textStyle,
                              )
                              .copyWith(color: textColor),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (item.badgeCount != null && item.badgeCount! > 0)
                    if (sidebarTheme?.plainBadges ?? false)
                      Text(
                        item.badgeCount.toString(),
                        style: context.textTheme.small
                            .copyWith(color: colors.textMuted)
                            .merge(sidebarTheme?.badgeTextStyle),
                      )
                    else
                      OiBadge.filled(
                        label: item.badgeCount.toString(),
                        size: OiBadgeSize.small,
                      ),
                  if (hasKids)
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: AnimatedRotation(
                        turns: kidsExpanded ? 0.25 : 0.0,
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                        child: OiIcon.raw(
                          OiIcons.chevronRight,
                          size: 14,
                          color: colors.textMuted,
                        ),
                      ),
                    ),
                  if (sidebarTheme?.itemPadding == null)
                    const SizedBox(width: 12),
                ],
              ],
            ),
          );

    Widget result = OiTappable(
      enabled: !item.disabled,
      semanticLabel: item.label,
      onTap: () {
        if (hasKids && !compact) {
          _toggleParent(item.id);
        }
        widget.onSelect(item.id);
      },
      child: content,
    );

    if (compact) {
      result = OiTooltip(
        label: item.label,
        message: item.label,
        child: result,
      );
    }

    return result;
  }
}

/// A flattened sidebar item with its nesting depth for keyboard navigation.
class _FlatItem {
  const _FlatItem({required this.item, required this.depth});

  /// The sidebar item.
  final OiSidebarItem item;

  /// The nesting depth (0 for top-level, 1 for children).
  final int depth;
}

// The branch is decorative; the containing OiTappable owns semantics and focus.
class _ContextBranchPainter extends CustomPainter {
  const _ContextBranchPainter(this.color, this.direction);
  final Color color;
  final TextDirection direction;

  @override
  void paint(Canvas canvas, Size size) {
    if (direction == TextDirection.rtl) {
      canvas
        ..translate(size.width, 0)
        ..scale(-1, 1);
    }
    final x = size.width - 15 + .5;
    final y = size.height / 2 - .5;
    canvas.drawPath(
      Path()
        ..moveTo(x, 0)
        ..lineTo(x, y - 8)
        ..arcToPoint(
          Offset(x + 8, y),
          radius: const Radius.circular(8),
          clockwise: false,
        )
        ..lineTo(x + 11, y),
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(_ContextBranchPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.direction != direction;
}
