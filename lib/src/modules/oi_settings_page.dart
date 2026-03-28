import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/buttons/oi_button.dart';
import 'package:obers_ui/src/components/inputs/oi_select.dart';
import 'package:obers_ui/src/components/inputs/oi_slider.dart';
import 'package:obers_ui/src/components/inputs/oi_switch_tile.dart';
import 'package:obers_ui/src/components/inputs/oi_text_input.dart';
import 'package:obers_ui/src/foundation/oi_icons.dart';
import 'package:obers_ui/src/foundation/oi_responsive.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/display/oi_divider.dart';
import 'package:obers_ui/src/primitives/display/oi_label.dart';
import 'package:obers_ui/src/primitives/interaction/oi_tappable.dart';

// ---------------------------------------------------------------------------
// Data classes
// ---------------------------------------------------------------------------

/// The type of a settings item.
///
/// {@category Modules}
enum OiSettingsItemType {
  /// A boolean toggle switch.
  toggle,

  /// A navigation row that triggers a drill-down.
  navigation,

  /// A dropdown select input.
  select,

  /// A continuous or discrete slider.
  slider,

  /// A custom builder for arbitrary content.
  custom,
}

/// A settings item within a group.
///
/// {@category Modules}
@immutable
class OiSettingsItem {
  /// Creates an [OiSettingsItem].
  const OiSettingsItem({
    required this.key,
    required this.title,
    required this.type,
    this.subtitle,
    this.icon,
    this.value,
    this.options,
    this.min,
    this.max,
    this.customBuilder,
    this.searchKeywords = const [],
  });

  /// Unique identifier for this item within its group.
  final String key;

  /// The display title.
  final String title;

  /// The type of control rendered for this item.
  final OiSettingsItemType type;

  /// Optional secondary text rendered below [title].
  final String? subtitle;

  /// Optional leading icon for the item.
  final IconData? icon;

  /// The current value. Type depends on [type]:
  /// - [OiSettingsItemType.toggle]: `bool`
  /// - [OiSettingsItemType.select]: `String`
  /// - [OiSettingsItemType.slider]: `double`
  final dynamic value;

  /// Options for [OiSettingsItemType.select].
  final List<String>? options;

  /// Minimum value for [OiSettingsItemType.slider].
  final double? min;

  /// Maximum value for [OiSettingsItemType.slider].
  final double? max;

  /// Builder for [OiSettingsItemType.custom].
  final Widget Function(BuildContext)? customBuilder;

  /// Additional keywords that are matched during search.
  final List<String> searchKeywords;
}

/// A group of settings items.
///
/// {@category Modules}
@immutable
class OiSettingsGroup {
  /// Creates an [OiSettingsGroup].
  const OiSettingsGroup({
    required this.key,
    required this.title,
    required this.items,
    this.icon,
    this.description,
  });

  /// Unique identifier for this group.
  final String key;

  /// The display title of the group.
  final String title;

  /// The items in this group.
  final List<OiSettingsItem> items;

  /// Optional icon rendered next to the group title.
  final IconData? icon;

  /// Optional description rendered below the group title.
  final String? description;
}

// ---------------------------------------------------------------------------
// Main widget
// ---------------------------------------------------------------------------

/// A settings screen with grouped sections, searchable items, and
/// toggle/navigation/select/slider tiles.
///
/// Each group can be individually collapsed or expanded. When [searchEnabled]
/// is `true`, a search bar is shown at the top that filters items by title,
/// subtitle, and [OiSettingsItem.searchKeywords]. Groups with matching items
/// are auto-expanded during search.
///
/// {@category Modules}
class OiSettingsPage extends StatefulWidget {
  /// Creates an [OiSettingsPage].
  const OiSettingsPage({
    required this.groups,
    required this.label,
    this.onSettingChanged,
    this.onNavigate,
    this.onResetGroup,
    this.onResetAll,
    this.searchEnabled = true,
    this.showResetButtons = true,
    super.key,
  });

  /// The settings groups to display.
  final List<OiSettingsGroup> groups;

  /// Semantic label for the entire settings page.
  final String label;

  /// Called when a toggle, select, or slider value changes.
  ///
  /// Receives the group key, item key, and new value.
  final void Function(String groupKey, String itemKey, dynamic value)?
  onSettingChanged;

  /// Called when a navigation item is tapped.
  final void Function(OiSettingsItem item)? onNavigate;

  /// Called when the reset button for a specific group is tapped.
  final void Function(String groupKey)? onResetGroup;

  /// Called when the "Reset All Settings" button is tapped.
  final VoidCallback? onResetAll;

  /// Whether to show the search bar at the top.
  final bool searchEnabled;

  /// Whether to show per-group and global reset buttons.
  final bool showResetButtons;

  @override
  State<OiSettingsPage> createState() => _OiSettingsPageState();
}

class _OiSettingsPageState extends State<OiSettingsPage> {
  String _searchQuery = '';
  late TextEditingController _searchController;
  late Set<String> _expandedGroups;

  // Desktop sidebar state.
  int _selectedGroupIndex = 0;
  late ScrollController _contentScrollController;
  late Map<String, GlobalKey> _groupKeys;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _expandedGroups = {for (final group in widget.groups) group.key};
    _contentScrollController = ScrollController();
    _groupKeys = {for (final group in widget.groups) group.key: GlobalKey()};
  }

  @override
  void didUpdateWidget(OiSettingsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Add any new groups to the expanded set and create keys for them.
    for (final group in widget.groups) {
      if (!oldWidget.groups.any((g) => g.key == group.key)) {
        _expandedGroups.add(group.key);
        _groupKeys[group.key] = GlobalKey();
      }
    }
    // Clamp selected index if groups were removed.
    if (_selectedGroupIndex >= widget.groups.length) {
      _selectedGroupIndex = widget.groups.isEmpty
          ? 0
          : widget.groups.length - 1;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _contentScrollController.dispose();
    super.dispose();
  }

  bool _matchesSearch(OiSettingsItem item) {
    if (_searchQuery.isEmpty) return true;
    final query = _searchQuery.toLowerCase();
    if (item.title.toLowerCase().contains(query)) return true;
    if (item.subtitle != null && item.subtitle!.toLowerCase().contains(query)) {
      return true;
    }
    for (final keyword in item.searchKeywords) {
      if (keyword.toLowerCase().contains(query)) return true;
    }
    return false;
  }

  List<OiSettingsItem> _filteredItems(OiSettingsGroup group) {
    if (_searchQuery.isEmpty) return group.items;
    return group.items.where(_matchesSearch).toList();
  }

  bool _groupHasMatches(OiSettingsGroup group) {
    return _filteredItems(group).isNotEmpty;
  }

  // ── Build helpers ──────────────────────────────────────────────────

  Widget _buildSearch(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: context.spacing.md),
      child: OiTextInput.search(
        controller: _searchController,
        onChanged: (value) => setState(() => _searchQuery = value),
      ),
    );
  }

  Widget _buildResetAll(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: context.spacing.md),
      child: Align(
        alignment: Alignment.centerRight,
        child: OiButton.ghost(
          label: 'Reset All Settings',
          icon: OiIcons.rotateCcw,
          onTap: widget.onResetAll,
          semanticLabel: 'Reset all settings to defaults',
        ),
      ),
    );
  }

  Widget _buildGroupHeader(
    BuildContext context,
    OiSettingsGroup group,
    bool isExpanded,
  ) {
    final colors = context.colors;
    final spacing = context.spacing;

    return OiTappable(
      semanticLabel:
          '${group.title} settings group, ${isExpanded ? 'expanded' : 'collapsed'}',
      onTap: () {
        setState(() {
          if (isExpanded) {
            _expandedGroups.remove(group.key);
          } else {
            _expandedGroups.add(group.key);
          }
        });
      },
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: spacing.sm,
          horizontal: spacing.xs,
        ),
        child: Row(
          children: [
            if (group.icon != null) ...[
              Icon(group.icon, size: 20, color: colors.text),
              SizedBox(width: spacing.sm),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  OiLabel.h3(group.title),
                  if (group.description != null)
                    Padding(
                      padding: EdgeInsets.only(top: spacing.xs),
                      child: OiLabel.small(
                        group.description!,
                        color: colors.textMuted,
                      ),
                    ),
                ],
              ),
            ),
            if (widget.showResetButtons && widget.onResetGroup != null)
              Padding(
                padding: EdgeInsets.only(right: spacing.sm),
                child: OiButton.ghost(
                  label: 'Reset',
                  icon: OiIcons.rotateCcw,
                  onTap: () => widget.onResetGroup?.call(group.key),
                  semanticLabel: 'Reset ${group.title} settings',
                ),
              ),
            Icon(
              isExpanded ? OiIcons.chevronUp : OiIcons.chevronDown,
              size: 18,
              color: colors.textMuted,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleItem(
    BuildContext context,
    OiSettingsGroup group,
    OiSettingsItem item,
  ) {
    return OiSwitchTile(
      title: item.title,
      subtitle: item.subtitle,
      value: item.value as bool? ?? false,
      leading: item.icon != null
          ? Icon(item.icon, size: 20, color: context.colors.textMuted)
          : null,
      onChanged: (value) {
        widget.onSettingChanged?.call(group.key, item.key, value);
      },
      semanticLabel: item.title,
    );
  }

  Widget _buildNavigationItem(
    BuildContext context,
    OiSettingsGroup group,
    OiSettingsItem item,
  ) {
    final colors = context.colors;
    final spacing = context.spacing;

    return OiTappable(
      semanticLabel: item.title,
      onTap: () => widget.onNavigate?.call(item),
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: spacing.sm,
          horizontal: spacing.md,
        ),
        child: Row(
          children: [
            if (item.icon != null) ...[
              Icon(item.icon, size: 20, color: colors.textMuted),
              SizedBox(width: spacing.sm),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  OiLabel.body(item.title),
                  if (item.subtitle != null)
                    Padding(
                      padding: EdgeInsets.only(top: spacing.xs),
                      child: OiLabel.small(
                        item.subtitle!,
                        color: colors.textMuted,
                      ),
                    ),
                ],
              ),
            ),
            Icon(OiIcons.chevronRight, size: 18, color: colors.textMuted),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectItem(
    BuildContext context,
    OiSettingsGroup group,
    OiSettingsItem item,
  ) {
    final spacing = context.spacing;
    final options = item.options ?? const <String>[];

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: spacing.sm,
        horizontal: spacing.md,
      ),
      child: Row(
        children: [
          if (item.icon != null) ...[
            Icon(item.icon, size: 20, color: context.colors.textMuted),
            SizedBox(width: spacing.sm),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                OiLabel.body(item.title),
                if (item.subtitle != null)
                  Padding(
                    padding: EdgeInsets.only(top: spacing.xs),
                    child: OiLabel.small(
                      item.subtitle!,
                      color: context.colors.textMuted,
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(width: spacing.sm),
          SizedBox(
            width: 160,
            child: OiSelect<String>(
              options: [
                for (final opt in options)
                  OiSelectOption(value: opt, label: opt),
              ],
              value: item.value as String?,
              onChanged: (value) {
                widget.onSettingChanged?.call(group.key, item.key, value);
              },
              placeholder: 'Select...',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliderItem(
    BuildContext context,
    OiSettingsGroup group,
    OiSettingsItem item,
  ) {
    final spacing = context.spacing;
    final min = item.min ?? 0;
    final max = item.max ?? 100;
    final value = (item.value as double?) ?? min;

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: spacing.sm,
        horizontal: spacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (item.icon != null)
            Padding(
              padding: EdgeInsets.only(bottom: spacing.xs),
              child: Row(
                children: [
                  Icon(item.icon, size: 20, color: context.colors.textMuted),
                  SizedBox(width: spacing.sm),
                  OiLabel.body(item.title),
                ],
              ),
            )
          else
            OiLabel.body(item.title),
          if (item.subtitle != null)
            Padding(
              padding: EdgeInsets.only(top: spacing.xs),
              child: OiLabel.small(
                item.subtitle!,
                color: context.colors.textMuted,
              ),
            ),
          SizedBox(height: spacing.sm),
          OiSlider(
            value: value,
            min: min,
            max: max,
            onChanged: (v) {
              widget.onSettingChanged?.call(group.key, item.key, v);
            },
            label: item.title,
            showLabels: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem(
    BuildContext context,
    OiSettingsGroup group,
    OiSettingsItem item,
  ) {
    switch (item.type) {
      case OiSettingsItemType.toggle:
        return _buildToggleItem(context, group, item);
      case OiSettingsItemType.navigation:
        return _buildNavigationItem(context, group, item);
      case OiSettingsItemType.select:
        return _buildSelectItem(context, group, item);
      case OiSettingsItemType.slider:
        return _buildSliderItem(context, group, item);
      case OiSettingsItemType.custom:
        if (item.customBuilder != null) {
          return item.customBuilder!(context);
        }
        return const SizedBox.shrink();
    }
  }

  Widget _buildGroup(
    BuildContext context,
    OiSettingsGroup group, {
    bool useKey = false,
  }) {
    final isSearching = _searchQuery.isNotEmpty;
    final filteredItems = _filteredItems(group);

    // During search, auto-expand groups with matches.
    final isExpanded = isSearching
        ? filteredItems.isNotEmpty
        : _expandedGroups.contains(group.key);

    final items = isSearching ? filteredItems : group.items;

    return Column(
      key: useKey ? _groupKeys[group.key] : null,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildGroupHeader(context, group, isExpanded),
        if (isExpanded) ...[
          for (var i = 0; i < items.length; i++) ...[
            _buildSettingsItem(context, group, items[i]),
            if (i < items.length - 1) const OiDivider(),
          ],
        ],
        SizedBox(height: context.spacing.sm),
      ],
    );
  }

  // ── Desktop sidebar ────────────────────────────────────────────────

  void _scrollToGroup(int index) {
    if (index < 0 || index >= widget.groups.length) return;

    setState(() => _selectedGroupIndex = index);

    final groupKey = _groupKeys[widget.groups[index].key];
    if (groupKey?.currentContext == null) return;

    Scrollable.ensureVisible(
      groupKey!.currentContext!,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Widget _buildSidebarItem(
    BuildContext context,
    int index,
    OiSettingsGroup group,
  ) {
    final colors = context.colors;
    final spacing = context.spacing;
    final isSelected = index == _selectedGroupIndex;

    return OiTappable(
      semanticLabel: '${group.title} settings section',
      onTap: () => _scrollToGroup(index),
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: spacing.sm,
          horizontal: spacing.md,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? colors.primary.base.withValues(alpha: 0.08)
              : null,
          borderRadius: context.radius.md,
        ),
        child: Row(
          children: [
            if (group.icon != null) ...[
              Icon(
                group.icon,
                size: 18,
                color: isSelected ? colors.primary.base : colors.textMuted,
              ),
              SizedBox(width: spacing.sm),
            ],
            Expanded(
              child: OiLabel.body(
                group.title,
                color: isSelected ? colors.primary.base : colors.text,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopSidebar(
    BuildContext context,
    List<OiSettingsGroup> visibleGroups,
  ) {
    final spacing = context.spacing;
    final colors = context.colors;

    return SizedBox(
      width: 240,
      child: SingleChildScrollView(
        padding: EdgeInsets.only(top: spacing.md, right: spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.only(left: spacing.md, bottom: spacing.sm),
              child: OiLabel.small('SECTIONS', color: colors.textMuted),
            ),
            for (var i = 0; i < visibleGroups.length; i++)
              _buildSidebarItem(context, i, visibleGroups[i]),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(
    BuildContext context,
    List<OiSettingsGroup> visibleGroups,
  ) {
    final spacing = context.spacing;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDesktopSidebar(context, visibleGroups),
        Expanded(
          child: SingleChildScrollView(
            controller: _contentScrollController,
            padding: EdgeInsets.all(spacing.md),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 960),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (widget.searchEnabled) _buildSearch(context),
                    if (widget.showResetButtons && widget.onResetAll != null)
                      _buildResetAll(context),
                    for (final group in visibleGroups)
                      _buildGroup(context, group, useKey: true),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Mobile layout (unchanged) ──────────────────────────────────────

  Widget _buildMobileLayout(
    BuildContext context,
    List<OiSettingsGroup> visibleGroups,
  ) {
    final spacing = context.spacing;

    return SingleChildScrollView(
      padding: EdgeInsets.all(spacing.md),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.searchEnabled) _buildSearch(context),
              if (widget.showResetButtons && widget.onResetAll != null)
                _buildResetAll(context),
              for (final group in visibleGroups) _buildGroup(context, group),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final breakpoint = context.breakpoint;
    final isDesktop = breakpoint.compareTo(OiBreakpoint.expanded) >= 0;

    // When searching, only show groups that have matching items.
    final visibleGroups = _searchQuery.isEmpty
        ? widget.groups
        : widget.groups.where(_groupHasMatches).toList();

    return Semantics(
      label: widget.label,
      container: true,
      child: isDesktop
          ? _buildDesktopLayout(context, visibleGroups)
          : _buildMobileLayout(context, visibleGroups),
    );
  }
}
