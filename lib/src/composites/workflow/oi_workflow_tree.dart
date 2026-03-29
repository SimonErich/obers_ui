import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/display/oi_badge.dart';
import 'package:obers_ui/src/components/display/oi_status_dot.dart';
import 'package:obers_ui/src/composites/workflow/oi_pipeline.dart';
import 'package:obers_ui/src/foundation/oi_icons.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/display/oi_label.dart';
import 'package:obers_ui/src/primitives/interaction/oi_tappable.dart';

// ── Data models ─────────────────────────────────────────────────────────────

/// A single item inside an [OiWorkflowGroup].
///
/// {@category Composites}
@immutable
class OiWorkflowItem<T> {
  /// Creates an [OiWorkflowItem].
  const OiWorkflowItem({
    required this.id,
    required this.label,
    required this.status,
    this.data,
    this.role,
    this.duration,
    this.trailingWidget,
    this.highlighted = false,
  });

  /// Unique identifier for this item.
  final String id;

  /// Display label.
  final String label;

  /// Current pipeline status.
  final OiPipelineStatus status;

  /// Optional payload attached to this item.
  final T? data;

  /// Optional role label shown as a soft badge.
  final String? role;

  /// Optional duration indicator.
  final Duration? duration;

  /// Optional trailing widget (e.g. action icons).
  final Widget? trailingWidget;

  /// Whether this item should be visually highlighted.
  final bool highlighted;
}

/// A group of [OiWorkflowItem]s displayed as an expandable section.
///
/// {@category Composites}
@immutable
class OiWorkflowGroup<T> {
  /// Creates an [OiWorkflowGroup].
  const OiWorkflowGroup({
    required this.id,
    required this.label,
    required this.items,
    this.icon,
  });

  /// Unique identifier for this group.
  final String id;

  /// Display label for the group header.
  final String label;

  /// The items belonging to this group.
  final List<OiWorkflowItem<T>> items;

  /// Optional leading icon for the group header.
  final IconData? icon;
}

// ── Controller ──────────────────────────────────────────────────────────────

/// Controls expand/collapse state of [OiWorkflowTree] groups.
///
/// {@category Composites}
class OiWorkflowTreeController extends ChangeNotifier {
  final Set<String> _expanded = {};

  /// Whether the group with [id] is currently expanded.
  bool isExpanded(String id) => _expanded.contains(id);

  /// Expands a single group.
  void expandGroup(String id) {
    if (_expanded.add(id)) notifyListeners();
  }

  /// Collapses a single group.
  void collapseGroup(String id) {
    if (_expanded.remove(id)) notifyListeners();
  }

  /// Toggles the expand state of a single group.
  void toggleGroup(String id) {
    if (_expanded.contains(id)) {
      _expanded.remove(id);
    } else {
      _expanded.add(id);
    }
    notifyListeners();
  }

  /// Expands every group in [ids].
  void expandAll(Iterable<String> ids) {
    _expanded.addAll(ids);
    notifyListeners();
  }

  /// Collapses all groups.
  void collapseAll() {
    _expanded.clear();
    notifyListeners();
  }
}

// ── Widget ──────────────────────────────────────────────────────────────────

/// An expandable group-to-item tree with inline progress indicators.
///
/// Bridges the gap between [OiPipeline] (flat stage list) and [OiTree]
/// (generic hierarchy) by adding workflow-specific semantics: aggregate
/// status, progress counts, role badges, and auto-expansion of active
/// groups.
///
/// {@category Composites}
class OiWorkflowTree<T> extends StatefulWidget {
  /// Creates an [OiWorkflowTree].
  const OiWorkflowTree({
    required this.label,
    required this.groups,
    this.controller,
    this.showProgress = true,
    this.autoExpandActive = true,
    this.onItemTap,
    this.onGroupTap,
    super.key,
  });

  /// Semantic label for the entire tree.
  final String label;

  /// The groups displayed in the tree.
  final List<OiWorkflowGroup<T>> groups;

  /// External controller. When null an internal controller is created.
  final OiWorkflowTreeController? controller;

  /// Whether to show inline progress counts (e.g. "3 / 7") in group
  /// headers.
  final bool showProgress;

  /// Whether to auto-expand groups containing a running item on first
  /// build.
  final bool autoExpandActive;

  /// Called when an item row is tapped.
  final void Function(OiWorkflowItem<T> item)? onItemTap;

  /// Called when a group header is tapped.
  final void Function(OiWorkflowGroup<T> group)? onGroupTap;

  @override
  State<OiWorkflowTree<T>> createState() => _OiWorkflowTreeState<T>();
}

class _OiWorkflowTreeState<T> extends State<OiWorkflowTree<T>>
    with TickerProviderStateMixin {
  late OiWorkflowTreeController _controller;
  bool _ownsController = false;
  final Map<String, AnimationController> _animations = {};

  @override
  void initState() {
    super.initState();
    _initController();
    if (widget.autoExpandActive) _autoExpand();
    _controller.addListener(_onControllerChanged);
  }

  @override
  void didUpdateWidget(OiWorkflowTree<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      _controller.removeListener(_onControllerChanged);
      if (_ownsController) _controller.dispose();
      _initController();
      _controller.addListener(_onControllerChanged);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    if (_ownsController) _controller.dispose();
    for (final ac in _animations.values) {
      ac.dispose();
    }
    super.dispose();
  }

  void _initController() {
    if (widget.controller != null) {
      _controller = widget.controller!;
      _ownsController = false;
    } else {
      _controller = OiWorkflowTreeController();
      _ownsController = true;
    }
  }

  void _autoExpand() {
    for (final group in widget.groups) {
      final hasActive = group.items.any(
        (i) => i.status == OiPipelineStatus.running,
      );
      if (hasActive) _controller.expandGroup(group.id);
    }
  }

  void _onControllerChanged() => setState(() {});

  AnimationController _animationFor(String groupId) {
    return _animations.putIfAbsent(groupId, () {
      final ac = AnimationController(
        vsync: this,
        duration: context.animations.reducedMotion
            ? Duration.zero
            : const Duration(milliseconds: 200),
        value: _controller.isExpanded(groupId) ? 1.0 : 0.0,
      );
      return ac;
    });
  }

  // ── Status helpers ──────────────────────────────────────────────────────

  static OiPipelineStatus _aggregateStatus(
    List<OiWorkflowItem<dynamic>> items,
  ) {
    if (items.any((i) => i.status == OiPipelineStatus.running)) {
      return OiPipelineStatus.running;
    }
    if (items.any((i) => i.status == OiPipelineStatus.failed)) {
      return OiPipelineStatus.failed;
    }
    if (items.every((i) => i.status == OiPipelineStatus.completed)) {
      return OiPipelineStatus.completed;
    }
    return OiPipelineStatus.pending;
  }

  static OiStatusVariant _statusToVariant(OiPipelineStatus status) {
    return switch (status) {
      OiPipelineStatus.running => OiStatusVariant.info,
      OiPipelineStatus.completed => OiStatusVariant.success,
      OiPipelineStatus.failed => OiStatusVariant.error,
      OiPipelineStatus.skipped => OiStatusVariant.muted,
      OiPipelineStatus.pending => OiStatusVariant.neutral,
    };
  }

  static String _formatDuration(Duration d) {
    if (d.inHours > 0) return '${d.inHours}h ${d.inMinutes.remainder(60)}m';
    if (d.inMinutes > 0) return '${d.inMinutes}m ${d.inSeconds.remainder(60)}s';
    return '${d.inSeconds}s';
  }

  // ── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: widget.label,
      explicitChildNodes: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final group in widget.groups) _buildGroup(context, group),
        ],
      ),
    );
  }

  Widget _buildGroup(BuildContext context, OiWorkflowGroup<T> group) {
    final colors = context.colors;
    final spacing = context.spacing;
    final expanded = _controller.isExpanded(group.id);
    final ac = _animationFor(group.id);

    // Drive the animation to match the controller.
    if (expanded && ac.status != AnimationStatus.forward && ac.value != 1) {
      unawaited(ac.forward());
    } else if (!expanded &&
        ac.status != AnimationStatus.reverse &&
        ac.value != 0) {
      unawaited(ac.reverse());
    }

    final aggStatus = _aggregateStatus(group.items);
    final doneCount = group.items
        .where((i) => i.status == OiPipelineStatus.completed)
        .length;

    return Column(
      key: ValueKey('wft_group_${group.id}'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Group header.
        OiTappable(
          onTap: () {
            _controller.toggleGroup(group.id);
            widget.onGroupTap?.call(group);
          },
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: spacing.sm,
              vertical: spacing.xs,
            ),
            child: Row(
              children: [
                AnimatedRotation(
                  turns: expanded ? 0.25 : 0,
                  duration: context.animations.reducedMotion
                      ? Duration.zero
                      : const Duration(milliseconds: 200),
                  child: Icon(
                    OiIcons.chevronRight,
                    size: 14,
                    color: colors.textSubtle,
                  ),
                ),
                SizedBox(width: spacing.xs),
                if (group.icon != null) ...[
                  Icon(group.icon, size: 14, color: colors.textSubtle),
                  SizedBox(width: spacing.xs),
                ],
                OiStatusDot(
                  label: '${group.label} status: ${aggStatus.name}',
                  variant: _statusToVariant(aggStatus),
                  pulsing: aggStatus == OiPipelineStatus.running,
                  size: 6,
                ),
                SizedBox(width: spacing.xs),
                Expanded(
                  child: OiLabel.small(group.label),
                ),
                if (widget.showProgress)
                  OiLabel.caption(
                    '$doneCount / ${group.items.length}',
                    color: colors.textMuted,
                  ),
              ],
            ),
          ),
        ),
        // Animated children.
        SizeTransition(
          sizeFactor: ac,
          axisAlignment: -1,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final item in group.items) _buildItem(context, item),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildItem(BuildContext context, OiWorkflowItem<T> item) {
    final colors = context.colors;
    final spacing = context.spacing;

    return OiTappable(
      key: ValueKey('wft_item_${item.id}'),
      onTap: widget.onItemTap != null ? () => widget.onItemTap!(item) : null,
      child: Container(
        color: item.highlighted
            ? colors.primary.muted.withValues(alpha: 0.12)
            : null,
        padding: EdgeInsets.only(
          left: spacing.lg,
          right: spacing.sm,
          top: spacing.xs,
          bottom: spacing.xs,
        ),
        child: Row(
          children: [
            OiStatusDot(
              label: '${item.label}: ${item.status.name}',
              variant: _statusToVariant(item.status),
              pulsing: item.status == OiPipelineStatus.running,
              size: 6,
            ),
            SizedBox(width: spacing.sm),
            Expanded(child: OiLabel.small(item.label)),
            if (item.role != null) ...[
              SizedBox(width: spacing.xs),
              OiBadge.soft(label: item.role!, size: OiBadgeSize.small),
            ],
            if (item.duration != null) ...[
              SizedBox(width: spacing.xs),
              OiLabel.caption(
                _formatDuration(item.duration!),
                color: colors.textMuted,
              ),
            ],
            if (item.trailingWidget != null) ...[
              SizedBox(width: spacing.xs),
              item.trailingWidget!,
            ],
          ],
        ),
      ),
    );
  }
}
