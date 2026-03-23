import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/scales/oi_chart_controller.dart';
import 'package:obers_ui/src/foundation/scales/oi_chart_sync_coordinator.dart';
import 'package:obers_ui/src/foundation/scales/oi_chart_viewport.dart';

/// Configuration flags for what interactions are synchronized.
///
/// {@category Foundation}
@immutable
class OiChartSyncOptions {
  /// Creates sync options. All channels default to `true`.
  const OiChartSyncOptions({
    this.syncCrosshair = true,
    this.syncSelection = true,
    this.syncViewport = false,
    this.syncKeyboardFocus = true,
  });

  /// Whether crosshair / hover position is broadcast to peers.
  final bool syncCrosshair;

  /// Whether data-point selection is broadcast to peers.
  final bool syncSelection;

  /// Whether zoom / brush / pan viewport changes are broadcast.
  ///
  /// Defaults to `false` because viewport sync can be disorienting
  /// on charts with different axis ranges.
  final bool syncViewport;

  /// Whether keyboard-driven focus point navigation is broadcast.
  final bool syncKeyboardFocus;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OiChartSyncOptions &&
          other.syncCrosshair == syncCrosshair &&
          other.syncSelection == syncSelection &&
          other.syncViewport == syncViewport &&
          other.syncKeyboardFocus == syncKeyboardFocus;

  @override
  int get hashCode =>
      Object.hash(syncCrosshair, syncSelection, syncViewport, syncKeyboardFocus);
}

/// Concrete implementation of [OiChartSyncCoordinator] that manages a
/// named sync group.
///
/// Charts that share the same `syncGroup` string participate in
/// synchronized interactions: hover on one chart updates the
/// tooltip/crosshair on siblings, zoom/brush optionally syncs, and
/// keyboard exploration can sync focus points.
///
/// Use [OiChartSyncGroupRegistry] to obtain a coordinator for a given
/// group name. The registry manages the lifecycle and ensures all
/// charts in the same group share the same coordinator instance.
///
/// ```dart
/// final coordinator = OiChartSyncGroupRegistry.instance.get('dashboard-1');
/// // Pass to chart behaviors via OiChartBehaviorContext.syncCoordinator
/// ```
///
/// {@category Foundation}
class OiChartSyncGroup extends OiChartSyncCoordinator {
  /// Creates a sync group with the given [groupId] and optional
  /// [options].
  OiChartSyncGroup({
    required String groupId,
    this.options = const OiChartSyncOptions(),
  }) : _groupId = groupId;

  final String _groupId;

  /// The sync configuration for this group.
  final OiChartSyncOptions options;

  final List<ValueChanged<OiChartViewport>> _viewportListeners = [];
  final List<ValueChanged<Set<OiChartDataRef>>> _selectionListeners = [];
  final List<ValueChanged<double?>> _crosshairListeners = [];
  final List<ValueChanged<double?>> _keyboardFocusListeners = [];

  OiChartViewport? _lastViewport;
  Set<OiChartDataRef>? _lastSelection;
  double? _lastCrosshairX;
  double? _lastKeyboardFocusX;

  int _participantCount = 0;

  @override
  String get groupId => _groupId;

  /// The most recently broadcast viewport.
  OiChartViewport? get lastViewport => _lastViewport;

  /// The most recently broadcast selection.
  Set<OiChartDataRef>? get lastSelection => _lastSelection;

  /// The most recently broadcast crosshair X position (0–1).
  double? get lastCrosshairX => _lastCrosshairX;

  /// The most recently broadcast keyboard focus X position (0–1).
  double? get lastKeyboardFocusX => _lastKeyboardFocusX;

  /// The number of charts currently registered with this group.
  int get participantCount => _participantCount;

  /// Registers a chart as a participant. Call when a chart mounts.
  void registerParticipant() {
    _participantCount++;
  }

  /// Unregisters a chart as a participant. Call when a chart disposes.
  void unregisterParticipant() {
    _participantCount = (_participantCount - 1).clamp(0, _participantCount);
  }

  // ── Sync broadcasts ──────────────────────────────────────────────────

  @override
  void syncViewport(OiChartViewport viewport) {
    if (!options.syncViewport) return;
    _lastViewport = viewport;
    for (final listener in List.of(_viewportListeners)) {
      listener(viewport);
    }
    notifyListeners();
  }

  @override
  void syncSelection(Set<OiChartDataRef> selection) {
    if (!options.syncSelection) return;
    _lastSelection = selection;
    for (final listener in List.of(_selectionListeners)) {
      listener(selection);
    }
    notifyListeners();
  }

  @override
  void syncCrosshair(double? normalizedX) {
    if (!options.syncCrosshair) return;
    _lastCrosshairX = normalizedX;
    for (final listener in List.of(_crosshairListeners)) {
      listener(normalizedX);
    }
    notifyListeners();
  }

  /// Broadcasts a keyboard focus point to all participants.
  ///
  /// The [normalizedX] value is in the 0–1 range relative to the plot
  /// area width, matching the crosshair convention.
  void syncKeyboardFocus(double? normalizedX) {
    if (!options.syncKeyboardFocus) return;
    _lastKeyboardFocusX = normalizedX;
    for (final listener in List.of(_keyboardFocusListeners)) {
      listener(normalizedX);
    }
    notifyListeners();
  }

  // ── Viewport listeners ───────────────────────────────────────────────

  @override
  void addViewportListener(ValueChanged<OiChartViewport> listener) {
    _viewportListeners.add(listener);
  }

  @override
  void removeViewportListener(ValueChanged<OiChartViewport> listener) {
    _viewportListeners.remove(listener);
  }

  // ── Selection listeners ──────────────────────────────────────────────

  @override
  void addSelectionListener(ValueChanged<Set<OiChartDataRef>> listener) {
    _selectionListeners.add(listener);
  }

  @override
  void removeSelectionListener(ValueChanged<Set<OiChartDataRef>> listener) {
    _selectionListeners.remove(listener);
  }

  // ── Crosshair listeners ──────────────────────────────────────────────

  @override
  void addCrosshairListener(ValueChanged<double?> listener) {
    _crosshairListeners.add(listener);
  }

  @override
  void removeCrosshairListener(ValueChanged<double?> listener) {
    _crosshairListeners.remove(listener);
  }

  // ── Keyboard focus listeners ─────────────────────────────────────────

  /// Registers a listener for keyboard focus point changes.
  void addKeyboardFocusListener(ValueChanged<double?> listener) {
    _keyboardFocusListeners.add(listener);
  }

  /// Removes a previously registered keyboard focus listener.
  void removeKeyboardFocusListener(ValueChanged<double?> listener) {
    _keyboardFocusListeners.remove(listener);
  }

  @override
  void dispose() {
    _viewportListeners.clear();
    _selectionListeners.clear();
    _crosshairListeners.clear();
    _keyboardFocusListeners.clear();
    super.dispose();
  }
}

/// A global registry that manages [OiChartSyncGroup] instances by their
/// `syncGroup` string identifier.
///
/// Charts call [get] to obtain the coordinator for their group. When the
/// last participant unregisters, the group is automatically cleaned up
/// on the next [get] or explicit [remove] call.
///
/// ```dart
/// // In a chart widget's initState:
/// final coordinator = OiChartSyncGroupRegistry.instance.get('my-dashboard');
/// coordinator.registerParticipant();
///
/// // In dispose:
/// coordinator.unregisterParticipant();
/// OiChartSyncGroupRegistry.instance.remove('my-dashboard');
/// ```
///
/// {@category Foundation}
class OiChartSyncGroupRegistry {
  OiChartSyncGroupRegistry._();

  /// The singleton instance.
  static final OiChartSyncGroupRegistry instance =
      OiChartSyncGroupRegistry._();

  final Map<String, OiChartSyncGroup> _groups = {};

  /// Returns the [OiChartSyncGroup] for the given [syncGroup] name.
  ///
  /// If no group exists yet, one is created with the given [options].
  /// Subsequent calls with the same [syncGroup] return the same
  /// instance (options are ignored after creation).
  OiChartSyncGroup get(
    String syncGroup, {
    OiChartSyncOptions options = const OiChartSyncOptions(),
  }) {
    return _groups.putIfAbsent(
      syncGroup,
      () => OiChartSyncGroup(groupId: syncGroup, options: options),
    );
  }

  /// Returns the group for [syncGroup] if it exists, or `null`.
  OiChartSyncGroup? find(String syncGroup) => _groups[syncGroup];

  /// Removes and disposes the group for [syncGroup] if it has no
  /// remaining participants.
  ///
  /// Returns `true` if the group was removed.
  bool remove(String syncGroup) {
    final group = _groups[syncGroup];
    if (group == null) return false;
    if (group.participantCount <= 0) {
      _groups.remove(syncGroup);
      group.dispose();
      return true;
    }
    return false;
  }

  /// Whether a group with the given [syncGroup] name exists.
  bool contains(String syncGroup) => _groups.containsKey(syncGroup);

  /// The number of active sync groups.
  int get groupCount => _groups.length;

  /// Removes and disposes all groups. Intended for testing only.
  @visibleForTesting
  void reset() {
    for (final group in _groups.values) {
      group.dispose();
    }
    _groups.clear();
  }
}

/// An [InheritedWidget] that provides an [OiChartSyncGroup] to
/// descendant chart widgets.
///
/// ```dart
/// OiChartSyncProvider(
///   syncGroup: 'dashboard-1',
///   child: Row(children: [OiLineChart(...), OiBarChart(...)]),
/// )
/// ```
///
/// {@category Foundation}
class OiChartSyncProvider extends InheritedWidget {
  /// Creates a sync provider.
  ///
  /// The [syncGroup] string is used to look up the shared coordinator
  /// from [OiChartSyncGroupRegistry].
  OiChartSyncProvider({
    required String syncGroup,
    required super.child, OiChartSyncOptions options = const OiChartSyncOptions(),
    super.key,
  }) : coordinator = OiChartSyncGroupRegistry.instance.get(
         syncGroup,
         options: options,
       );

  /// Creates a sync provider with an explicit coordinator instance.
  const OiChartSyncProvider.withCoordinator({
    required this.coordinator,
    required super.child,
    super.key,
  });

  /// The sync coordinator shared by all charts under this provider.
  final OiChartSyncGroup coordinator;

  /// Returns the nearest [OiChartSyncGroup] from the widget tree, or
  /// `null` if none is found.
  static OiChartSyncGroup? of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<OiChartSyncProvider>()
        ?.coordinator;
  }

  @override
  bool updateShouldNotify(OiChartSyncProvider oldWidget) =>
      coordinator != oldWidget.coordinator;
}
