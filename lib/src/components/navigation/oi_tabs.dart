import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/persistence/oi_settings_driver.dart';
import 'package:obers_ui/src/foundation/persistence/oi_settings_mixin.dart';
import 'package:obers_ui/src/foundation/persistence/oi_settings_provider.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/models/settings/oi_tabs_settings.dart';
import 'package:obers_ui/src/primitives/interaction/oi_tappable.dart';

/// A single tab entry in an [OiTabs] bar.
///
/// {@category Components}
@immutable
class OiTabItem {
  /// Creates an [OiTabItem].
  const OiTabItem({required this.label, this.icon, this.badge});

  /// The text label shown for this tab.
  final String label;

  /// An optional icon shown alongside the label.
  final IconData? icon;

  /// An optional badge count shown over the icon.
  final int? badge;
}

/// How the active-tab indicator is drawn.
///
/// {@category Components}
enum OiTabIndicatorStyle {
  /// A line drawn along the bottom of the selected tab.
  underline,

  /// The selected tab is given a filled background.
  filled,

  /// A rounded rectangle that slides to the selected tab.
  pill,
}

/// A horizontal tab bar with animated selection indicators.
///
/// Displays a row of [OiTabItem]s. The currently active tab is identified by
/// [selectedIndex]; tapping any tab fires [onSelected] with that index.
///
/// Three visual variants are available via [indicatorStyle]:
/// - [OiTabIndicatorStyle.underline]: an animated bottom border line.
/// - [OiTabIndicatorStyle.filled]: the tab background transitions to primary.
/// - [OiTabIndicatorStyle.pill]: a rounded-rect highlight slides between tabs.
///
/// When [scrollable] is `true` the tabs overflow horizontally instead of
/// stretching to fill the bar. An optional [content] widget is placed below
/// the tab row to host page-level content.
///
/// Keyboard users can press the left/right arrow keys to cycle selection while
/// any tab has focus.
///
/// {@category Components}
class OiTabs extends StatefulWidget {
  /// Creates an [OiTabs] widget.
  const OiTabs({
    required this.tabs,
    required this.selectedIndex,
    required this.onSelected,
    this.indicatorStyle = OiTabIndicatorStyle.underline,
    this.scrollable = false,
    this.content,
    this.settingsDriver,
    this.settingsKey,
    this.settingsNamespace = 'oi_tabs',
    this.settingsSaveDebounce = const Duration(milliseconds: 500),
    super.key,
  });

  /// The list of tab items to display.
  final List<OiTabItem> tabs;

  /// The index of the currently active tab.
  final int selectedIndex;

  /// Called with the new index when the user selects a tab.
  final ValueChanged<int> onSelected;

  /// The visual style used to highlight the selected tab.
  final OiTabIndicatorStyle indicatorStyle;

  /// Whether the tab row scrolls horizontally when it overflows.
  final bool scrollable;

  /// Optional content widget rendered below the tab bar.
  final Widget? content;

  // ── Settings persistence ──────────────────────────────────────────────────

  /// Driver used to persist settings. When `null` settings are not persisted.
  final OiSettingsDriver? settingsDriver;

  /// Sub-key scoping this tabs' settings within [settingsNamespace].
  final String? settingsKey;

  /// Top-level namespace for settings storage.
  final String settingsNamespace;

  /// Debounce duration for auto-saving settings after changes.
  final Duration settingsSaveDebounce;

  @override
  State<OiTabs> createState() => _OiTabsState();
}

class _OiTabsState extends State<OiTabs>
    with OiSettingsMixin<OiTabs, OiTabsSettings> {
  // Track each tab's key so we can measure positions for the pill indicator.
  late List<GlobalKey> _tabKeys;

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
  OiTabsSettings get defaultSettings =>
      OiTabsSettings(selectedIndex: widget.selectedIndex);

  @override
  OiTabsSettings deserializeSettings(Map<String, dynamic> json) =>
      OiTabsSettings.fromJson(json);

  @override
  OiTabsSettings mergeSettings(OiTabsSettings saved, OiTabsSettings defaults) =>
      saved.mergeWith(defaults);

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void initState() {
    _resolvedDriver = widget.settingsDriver;
    super.initState();
    _tabKeys = List.generate(widget.tabs.length, (_) => GlobalKey());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newDriver = widget.settingsDriver ?? OiSettingsProvider.of(context);
    if (newDriver != _resolvedDriver) {
      _resolvedDriver = newDriver;
      if (settingsLoaded) {
        reloadSettings();
      }
    }
  }

  @override
  void didUpdateWidget(OiTabs oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tabs.length != widget.tabs.length) {
      _tabKeys = List.generate(widget.tabs.length, (_) => GlobalKey());
    }
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      updateSettings(
        OiTabsSettings(selectedIndex: widget.selectedIndex),
        debounce: widget.settingsSaveDebounce,
      );
    }
  }

  void _handleKey(int index, KeyEvent event) {
    if (event is! KeyDownEvent) return;
    if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      final next = (index + 1) % widget.tabs.length;
      widget.onSelected(next);
    } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      final prev = (index - 1 + widget.tabs.length) % widget.tabs.length;
      widget.onSelected(prev);
    }
  }

  Widget _buildTab(BuildContext context, int index) {
    final colors = context.colors;
    final tab = widget.tabs[index];
    final isSelected = index == widget.selectedIndex;

    final tt = context.components.tabs;
    final activeColor = tt?.activeLabelColor ?? colors.primary.base;
    final inactiveColor = tt?.inactiveLabelColor ?? colors.textMuted;
    final indicatorColor = tt?.indicatorColor ?? activeColor;

    final textColor = switch (widget.indicatorStyle) {
      OiTabIndicatorStyle.filled when isSelected => colors.textOnPrimary,
      _ when isSelected => activeColor,
      _ => inactiveColor,
    };

    final bgColor = switch (widget.indicatorStyle) {
      OiTabIndicatorStyle.filled when isSelected => indicatorColor,
      OiTabIndicatorStyle.pill => const Color(0x00000000),
      _ => const Color(0x00000000),
    };

    final baseLabelStyle = tt?.labelStyle ?? const TextStyle(fontSize: 14);
    Widget label = Text(
      tab.label,
      style: baseLabelStyle.copyWith(
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
        color: textColor,
      ),
    );

    if (tab.icon != null) {
      Widget iconWidget = Icon(tab.icon, size: 18, color: textColor);
      if (tab.badge != null && tab.badge! > 0) {
        iconWidget = Stack(
          clipBehavior: Clip.none,
          children: [
            iconWidget,
            Positioned(
              top: -4,
              right: -6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                decoration: BoxDecoration(
                  color: colors.error.base,
                  borderRadius: BorderRadius.circular(9999),
                ),
                child: Text(
                  '${tab.badge}',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: colors.error.foreground,
                    height: 1,
                  ),
                ),
              ),
            ),
          ],
        );
      }
      label = Row(
        mainAxisSize: MainAxisSize.min,
        children: [iconWidget, const SizedBox(width: 6), label],
      );
    }

    final animDuration =
        context.animations.reducedMotion ||
            MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 200);

    Widget tabContent = AnimatedContainer(
      key: _tabKeys[index],
      duration: animDuration,
      padding:
          tt?.tabPadding ??
          const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: widget.indicatorStyle == OiTabIndicatorStyle.filled
            ? BorderRadius.circular(6)
            : null,
      ),
      child: Center(child: label),
    );

    if (widget.indicatorStyle == OiTabIndicatorStyle.underline) {
      tabContent = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          tabContent,
          AnimatedContainer(
            duration: animDuration,
            height: tt?.indicatorThickness ?? 2,
            decoration: BoxDecoration(
              color: isSelected ? indicatorColor : const Color(0x00000000),
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        ],
      );
    }

    return KeyboardListener(
      focusNode: FocusNode(skipTraversal: true),
      onKeyEvent: (e) => _handleKey(index, e),
      child: OiTappable(
        onTap: () => widget.onSelected(index),
        child: tabContent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    // ignore: omit_local_variable_types — reassigned below, type needed
    Widget tabRow = widget.indicatorStyle == OiTabIndicatorStyle.pill
        ? _PillTabRow(
            tabs: widget.tabs,
            selectedIndex: widget.selectedIndex,
            onSelected: widget.onSelected,
            onKeyEvent: _handleKey,
          )
        : Row(
            mainAxisSize: widget.scrollable
                ? MainAxisSize.min
                : MainAxisSize.max,
            children: [
              for (var i = 0; i < widget.tabs.length; i++)
                widget.scrollable
                    ? _buildTab(context, i)
                    : Expanded(child: _buildTab(context, i)),
            ],
          );

    if (widget.scrollable) {
      tabRow = SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: tabRow,
      );
    }

    final bar = DecoratedBox(
      decoration: BoxDecoration(
        border: widget.indicatorStyle == OiTabIndicatorStyle.underline
            ? Border(bottom: BorderSide(color: colors.borderSubtle))
            : null,
      ),
      child: tabRow,
    );

    if (widget.content != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [bar, widget.content!],
      );
    }
    return bar;
  }
}

// ── Pill indicator implementation ──────────────────────────────────────────

/// Internal row widget that renders the sliding pill indicator.
class _PillTabRow extends StatefulWidget {
  const _PillTabRow({
    required this.tabs,
    required this.selectedIndex,
    required this.onSelected,
    required this.onKeyEvent,
  });

  final List<OiTabItem> tabs;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final void Function(int, KeyEvent) onKeyEvent;

  @override
  State<_PillTabRow> createState() => _PillTabRowState();
}

class _PillTabRowState extends State<_PillTabRow> {
  final List<GlobalKey> _keys = [];
  final Set<int> _hoveredIndices = {};

  @override
  void initState() {
    super.initState();
    _keys.addAll(List.generate(widget.tabs.length, (_) => GlobalKey()));
  }

  @override
  void didUpdateWidget(_PillTabRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tabs.length != widget.tabs.length) {
      _keys
        ..clear()
        ..addAll(List.generate(widget.tabs.length, (_) => GlobalKey()));
      _hoveredIndices.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final reducedMotion =
        context.animations.reducedMotion ||
        MediaQuery.disableAnimationsOf(context);
    final animDuration = reducedMotion
        ? Duration.zero
        : const Duration(milliseconds: 200);

    final children = <Widget>[];
    for (var i = 0; i < widget.tabs.length; i++) {
      final isSelected = i == widget.selectedIndex;
      final isHovered = _hoveredIndices.contains(i);
      final tab = widget.tabs[i];
      final textColor = isSelected ? colors.primary.base : colors.textMuted;

      // ignore: omit_local_variable_types — reassigned when icon present
      Widget label = Text(
        tab.label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          color: textColor,
        ),
      );

      if (tab.icon != null) {
        label = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(tab.icon, size: 18, color: textColor),
            const SizedBox(width: 6),
            label,
          ],
        );
      }

      Color bgColor;
      if (isSelected) {
        bgColor = colors.primary.base.withValues(alpha: 0.12);
      } else if (isHovered) {
        bgColor = colors.primary.base.withValues(alpha: 0.06);
      } else {
        bgColor = const Color(0x00000000);
      }

      final index = i;
      children.add(
        KeyboardListener(
          focusNode: FocusNode(skipTraversal: true),
          onKeyEvent: (e) => widget.onKeyEvent(index, e),
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            onEnter: (_) => setState(() => _hoveredIndices.add(index)),
            onExit: (_) => setState(() => _hoveredIndices.remove(index)),
            child: GestureDetector(
              key: _keys[index],
              onTap: () => widget.onSelected(index),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: animDuration,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: label,
              ),
            ),
          ),
        ),
      );
    }
    return Row(mainAxisSize: MainAxisSize.min, children: children);
  }
}
