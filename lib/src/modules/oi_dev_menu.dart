import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/buttons/oi_button.dart';
import 'package:obers_ui/src/components/inputs/oi_switch_tile.dart';
import 'package:obers_ui/src/components/inputs/oi_text_input.dart';
import 'package:obers_ui/src/foundation/oi_icons.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/display/oi_divider.dart';
import 'package:obers_ui/src/primitives/display/oi_label.dart';
import 'package:obers_ui/src/primitives/interaction/oi_tappable.dart';

// ---------------------------------------------------------------------------
// Data models
// ---------------------------------------------------------------------------

/// An environment option in an [OiDevMenu].
///
/// {@category Modules}
@immutable
class OiDevEnvironment {
  /// Creates an [OiDevEnvironment].
  const OiDevEnvironment({required this.key, required this.label, this.url});

  /// A unique key identifying this environment (e.g. `'staging'`).
  final String key;

  /// Human-readable name displayed in the environment list.
  final String label;

  /// Optional base URL for this environment.
  final String? url;
}

/// A feature flag in an [OiDevMenu].
///
/// {@category Modules}
@immutable
class OiFeatureFlag {
  /// Creates an [OiFeatureFlag].
  const OiFeatureFlag({
    required this.key,
    required this.label,
    this.description,
    this.defaultValue = false,
  });

  /// A unique key identifying this feature flag.
  final String key;

  /// Human-readable name displayed in the flags list.
  final String label;

  /// Optional description shown below the flag toggle.
  final String? description;

  /// The default on/off state for this flag.
  final bool defaultValue;
}

/// A custom action button in an [OiDevMenu].
///
/// {@category Modules}
@immutable
class OiDevAction {
  /// Creates an [OiDevAction].
  const OiDevAction({
    required this.label,
    required this.onTap,
    this.icon,
    this.destructive = false,
  });

  /// Human-readable name displayed on the action button.
  final String label;

  /// Called when the action button is tapped.
  final VoidCallback onTap;

  /// Optional leading icon for the action.
  final IconData? icon;

  /// Whether this is a destructive action (renders in error color).
  final bool destructive;
}

/// Log severity level.
///
/// {@category Modules}
enum OiLogLevel {
  /// Verbose debug information.
  debug,

  /// General informational messages.
  info,

  /// Non-critical warnings.
  warning,

  /// Errors requiring attention.
  error,
}

/// A log entry displayed in an [OiDevMenu].
///
/// {@category Modules}
@immutable
class OiLogEntry {
  /// Creates an [OiLogEntry].
  const OiLogEntry({
    required this.message,
    required this.level,
    required this.timestamp,
    this.source,
  });

  /// The log message content.
  final String message;

  /// The severity level of this entry.
  final OiLogLevel level;

  /// When this entry was recorded.
  final DateTime timestamp;

  /// Optional source tag (e.g. `'AuthService'`, `'HttpClient'`).
  final String? source;
}

// ---------------------------------------------------------------------------
// Widget
// ---------------------------------------------------------------------------

enum _MenuMode { standalone, trigger }

/// A developer/debug menu with environment switcher, feature flags,
/// custom actions, and a log viewer.
///
/// Use the default constructor for a standalone panel, or
/// [OiDevMenu.trigger] to wrap a child widget and activate via triple-tap.
///
/// {@category Modules}
class OiDevMenu extends StatefulWidget {
  /// Creates a standalone [OiDevMenu] panel.
  const OiDevMenu({
    required this.label,
    this.environments = const [],
    this.currentEnvironment,
    this.onEnvironmentChange,
    this.featureFlags = const [],
    this.featureFlagValues = const {},
    this.onFeatureFlagChange,
    this.actions = const [],
    this.logs = const [],
    this.onCopyLogs,
    super.key,
  }) : child = null,
       tapCount = 3,
       _mode = _MenuMode.standalone;

  /// Wraps [child]; a triple-tap (or [tapCount]-tap) opens the dev menu as
  /// an overlay on top of the child.
  const OiDevMenu.trigger({
    required this.child,
    required this.label,
    this.tapCount = 3,
    this.environments = const [],
    this.currentEnvironment,
    this.onEnvironmentChange,
    this.featureFlags = const [],
    this.featureFlagValues = const {},
    this.onFeatureFlagChange,
    this.actions = const [],
    this.logs = const [],
    this.onCopyLogs,
    super.key,
  }) : _mode = _MenuMode.trigger;

  /// The child widget shown underneath the menu trigger (trigger mode only).
  final Widget? child;

  /// Accessibility label for the dev menu.
  final String label;

  /// Number of consecutive taps within 500 ms to open the menu (trigger mode).
  final int tapCount;

  /// Available environment options to display.
  final List<OiDevEnvironment> environments;

  /// The currently selected environment key.
  final String? currentEnvironment;

  /// Called when the user selects a different environment.
  final ValueChanged<String>? onEnvironmentChange;

  /// Feature flags to display as toggles.
  final List<OiFeatureFlag> featureFlags;

  /// Current on/off state for each feature flag, keyed by [OiFeatureFlag.key].
  final Map<String, bool> featureFlagValues;

  /// Called when the user toggles a feature flag.
  final void Function(String key, {required bool value})? onFeatureFlagChange;

  /// Custom action buttons to display.
  final List<OiDevAction> actions;

  /// Log entries to display in the log viewer tab.
  final List<OiLogEntry> logs;

  /// Called when the user taps the "Copy all logs" button.
  final VoidCallback? onCopyLogs;

  final _MenuMode _mode;

  @override
  State<OiDevMenu> createState() => _OiDevMenuState();
}

class _OiDevMenuState extends State<OiDevMenu> {
  int _activeTab = 0;
  OiLogLevel? _logFilter;
  String _logSearchQuery = '';
  late final TextEditingController _logSearchController;

  // Environment selection – managed internally so that tapping an environment
  // always provides visual feedback, even when the parent does not update
  // [currentEnvironment].
  String? _selectedEnvironment;

  // Trigger mode state.
  bool _isOpen = false;
  int _tapCount = 0;
  DateTime? _lastTapTime;

  @override
  void initState() {
    super.initState();
    _logSearchController = TextEditingController();
    _selectedEnvironment = widget.currentEnvironment;
  }

  @override
  void didUpdateWidget(OiDevMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentEnvironment != oldWidget.currentEnvironment) {
      _selectedEnvironment = widget.currentEnvironment;
    }
  }

  @override
  void dispose() {
    _logSearchController.dispose();
    super.dispose();
  }

  // ── Triple-tap detection ──────────────────────────────────────────────────

  void _handleTap() {
    final now = DateTime.now();
    if (_lastTapTime != null &&
        now.difference(_lastTapTime!).inMilliseconds < 500) {
      _tapCount++;
    } else {
      _tapCount = 1;
    }
    _lastTapTime = now;
    if (_tapCount >= widget.tapCount) {
      _tapCount = 0;
      setState(() => _isOpen = true);
    }
  }

  void _close() {
    setState(() => _isOpen = false);
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (widget._mode == _MenuMode.standalone) {
      return Semantics(
        label: widget.label,
        container: true,
        child: _buildMenuPanel(context),
      );
    }

    // Trigger mode.
    return Stack(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: _handleTap,
          child: widget.child,
        ),
        if (_isOpen) ...[
          // Scrim.
          Positioned.fill(
            child: GestureDetector(
              onTap: _close,
              child: ColoredBox(color: context.colors.overlay),
            ),
          ),
          // Menu panel.
          Positioned.fill(
            child: Center(
              child: Semantics(
                label: widget.label,
                container: true,
                child: _buildMenuPanel(context),
              ),
            ),
          ),
        ],
      ],
    );
  }

  // ── Menu panel ────────────────────────────────────────────────────────────

  Widget _buildMenuPanel(BuildContext context) {
    final colors = context.colors;
    final radius = context.radius;
    final shadows = context.shadows;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: radius.lg,
          boxShadow: shadows.lg,
          border: Border.all(color: colors.border),
        ),
        child: ClipRRect(
          borderRadius: radius.lg,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(context),
              const OiDivider(),
              _buildTabs(context),
              const OiDivider(),
              Expanded(child: _buildTabContent(context)),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: spacing.md,
        vertical: spacing.sm,
      ),
      child: Row(
        children: [
          Icon(OiIcons.wrench, size: 18, color: colors.textSubtle),
          SizedBox(width: spacing.sm),
          const Expanded(child: OiLabel.h4('Developer Menu')),
          if (widget._mode == _MenuMode.trigger)
            OiTappable(
              onTap: _close,
              semanticLabel: 'Close developer menu',
              child: Icon(OiIcons.x, size: 18, color: colors.textSubtle),
            ),
        ],
      ),
    );
  }

  // ── Tab row ───────────────────────────────────────────────────────────────

  static const _tabLabels = ['Environment', 'Flags', 'Actions', 'Logs'];
  static const List<IconData> _tabIcons = [
    OiIcons.server,
    OiIcons.flag,
    OiIcons.zap,
    OiIcons.terminal,
  ];

  Widget _buildTabs(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: spacing.sm),
      child: Row(
        children: List.generate(_tabLabels.length, (i) {
          final active = i == _activeTab;
          return Expanded(
            child: OiTappable(
              onTap: () => setState(() => _activeTab = i),
              semanticLabel: _tabLabels[i],
              child: Container(
                padding: EdgeInsets.symmetric(vertical: spacing.sm),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: active
                          ? colors.primary.base
                          : const Color(0x00000000),
                      width: 2,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _tabIcons[i],
                      size: 14,
                      color: active ? colors.primary.base : colors.textMuted,
                    ),
                    SizedBox(width: spacing.xs),
                    Flexible(
                      child: OiLabel.small(
                        _tabLabels[i],
                        color: active ? colors.primary.base : colors.textMuted,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ── Tab content dispatcher ────────────────────────────────────────────────

  Widget _buildTabContent(BuildContext context) {
    switch (_activeTab) {
      case 0:
        return _buildEnvironmentTab(context);
      case 1:
        return _buildFeatureFlagsTab(context);
      case 2:
        return _buildActionsTab(context);
      case 3:
        return _buildLogsTab(context);
      default:
        return const SizedBox.shrink();
    }
  }

  // ── Environment tab ───────────────────────────────────────────────────────

  Widget _buildEnvironmentTab(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;

    if (widget.environments.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(spacing.lg),
          child: OiLabel.body(
            'No environments configured',
            color: colors.textMuted,
          ),
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.all(spacing.sm),
      itemCount: widget.environments.length,
      separatorBuilder: (_, _) => SizedBox(height: spacing.xs),
      itemBuilder: (context, index) {
        final env = widget.environments[index];
        final selected = env.key == _selectedEnvironment;

        return OiTappable(
          onTap: () {
            setState(() => _selectedEnvironment = env.key);
            widget.onEnvironmentChange?.call(env.key);
          },
          semanticLabel: '${env.label} environment',
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: spacing.md,
              vertical: spacing.sm,
            ),
            decoration: BoxDecoration(
              color: selected ? colors.primary.base : null,
              borderRadius: context.radius.sm,
              border: Border.all(
                color: selected ? colors.primary.base : colors.borderSubtle,
              ),
            ),
            child: Row(
              children: [
                // Radio-style dot indicator.
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected
                          ? colors.primary.foreground
                          : colors.textMuted,
                      width: 2,
                    ),
                  ),
                  child: selected
                      ? Center(
                          child: Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: colors.primary.foreground,
                            ),
                          ),
                        )
                      : null,
                ),
                SizedBox(width: spacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      OiLabel.body(
                        env.label,
                        color: selected
                            ? colors.primary.foreground
                            : null,
                      ),
                      if (env.url != null)
                        OiLabel.small(
                          env.url!,
                          color: selected
                              ? colors.primary.foreground
                              : colors.textMuted,
                        ),
                    ],
                  ),
                ),
                if (selected)
                  Icon(
                    OiIcons.check,
                    size: 16,
                    color: colors.primary.foreground,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Feature flags tab ─────────────────────────────────────────────────────

  Widget _buildFeatureFlagsTab(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;

    if (widget.featureFlags.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(spacing.lg),
          child: OiLabel.body(
            'No feature flags configured',
            color: colors.textMuted,
          ),
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.all(spacing.sm),
      itemCount: widget.featureFlags.length,
      separatorBuilder: (_, _) => const OiDivider(),
      itemBuilder: (context, index) {
        final flag = widget.featureFlags[index];
        final value = widget.featureFlagValues[flag.key] ?? flag.defaultValue;

        return OiSwitchTile(
          title: flag.label,
          subtitle: flag.description,
          value: value,
          onChanged: (v) =>
              widget.onFeatureFlagChange?.call(flag.key, value: v),
          semanticLabel: '${flag.label} feature flag',
        );
      },
    );
  }

  // ── Actions tab ───────────────────────────────────────────────────────────

  Widget _buildActionsTab(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;

    if (widget.actions.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(spacing.lg),
          child: OiLabel.body('No actions configured', color: colors.textMuted),
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.all(spacing.md),
      itemCount: widget.actions.length,
      separatorBuilder: (_, _) => SizedBox(height: spacing.sm),
      itemBuilder: (context, index) {
        final action = widget.actions[index];
        if (action.destructive) {
          return OiButton.destructive(
            label: action.label,
            icon: action.icon,
            onTap: action.onTap,
          );
        }
        return OiButton.ghost(
          label: action.label,
          icon: action.icon,
          onTap: action.onTap,
        );
      },
    );
  }

  // ── Logs tab ──────────────────────────────────────────────────────────────

  Widget _buildLogsTab(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;

    final filteredLogs = widget.logs.where((entry) {
      if (_logFilter != null && entry.level != _logFilter) return false;
      if (_logSearchQuery.isNotEmpty) {
        final q = _logSearchQuery.toLowerCase();
        if (!entry.message.toLowerCase().contains(q) &&
            !(entry.source?.toLowerCase().contains(q) ?? false)) {
          return false;
        }
      }
      return true;
    }).toList();

    return Column(
      children: [
        // Search bar.
        Padding(
          padding: EdgeInsets.fromLTRB(spacing.sm, spacing.sm, spacing.sm, 0),
          child: OiTextInput.search(
            controller: _logSearchController,
            onChanged: (v) => setState(() => _logSearchQuery = v),
          ),
        ),

        // Filter chips.
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: spacing.sm,
            vertical: spacing.xs,
          ),
          child: Row(
            children: [
              _buildFilterChip(context, null, 'All'),
              SizedBox(width: spacing.xs),
              _buildFilterChip(context, OiLogLevel.debug, 'Debug'),
              SizedBox(width: spacing.xs),
              _buildFilterChip(context, OiLogLevel.info, 'Info'),
              SizedBox(width: spacing.xs),
              _buildFilterChip(context, OiLogLevel.warning, 'Warning'),
              SizedBox(width: spacing.xs),
              _buildFilterChip(context, OiLogLevel.error, 'Error'),
            ],
          ),
        ),

        const OiDivider(),

        // Log entries.
        Expanded(
          child: filteredLogs.isEmpty
              ? Center(
                  child: OiLabel.body(
                    'No log entries',
                    color: colors.textMuted,
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.all(spacing.sm),
                  itemCount: filteredLogs.length,
                  itemBuilder: (context, index) =>
                      _buildLogEntry(context, filteredLogs[index]),
                ),
        ),

        // Copy logs button.
        if (widget.onCopyLogs != null) ...[
          const OiDivider(),
          Padding(
            padding: EdgeInsets.all(spacing.sm),
            child: OiButton.ghost(
              label: 'Copy all logs',
              icon: OiIcons.copy,
              onTap: widget.onCopyLogs,
              fullWidth: true,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    OiLogLevel? level,
    String label,
  ) {
    final colors = context.colors;
    final spacing = context.spacing;
    final active = _logFilter == level;

    return OiTappable(
      onTap: () => setState(() => _logFilter = level),
      semanticLabel: '$label filter',
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: spacing.sm,
          vertical: spacing.xs,
        ),
        decoration: BoxDecoration(
          color: active ? colors.primary.muted : null,
          borderRadius: context.radius.sm,
          border: Border.all(
            color: active ? colors.primary.base : colors.borderSubtle,
          ),
        ),
        child: OiLabel.small(
          label,
          color: active ? colors.primary.base : colors.textSubtle,
        ),
      ),
    );
  }

  Widget _buildLogEntry(BuildContext context, OiLogEntry entry) {
    final colors = context.colors;
    final spacing = context.spacing;

    final Color levelColor;
    switch (entry.level) {
      case OiLogLevel.debug:
        levelColor = colors.textMuted;
      case OiLogLevel.info:
        levelColor = colors.text;
      case OiLogLevel.warning:
        levelColor = colors.warning.base;
      case OiLogLevel.error:
        levelColor = colors.error.base;
    }

    final timestamp =
        '${entry.timestamp.hour.toString().padLeft(2, '0')}:'
        '${entry.timestamp.minute.toString().padLeft(2, '0')}:'
        '${entry.timestamp.second.toString().padLeft(2, '0')}';

    return Padding(
      padding: EdgeInsets.only(bottom: spacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OiLabel.code(timestamp, color: colors.textMuted),
          SizedBox(width: spacing.sm),
          if (entry.source != null) ...[
            OiLabel.small('[${entry.source}]', color: colors.textSubtle),
            SizedBox(width: spacing.xs),
          ],
          Expanded(child: OiLabel.small(entry.message, color: levelColor)),
        ],
      ),
    );
  }
}
