import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/persistence/oi_settings_data.dart';
import 'package:obers_ui/src/foundation/persistence/oi_settings_driver.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';

/// A two-pane layout with a draggable divider.
///
/// Renders [leading] and [trailing] side-by-side (when
/// [direction] is [Axis.horizontal]) or stacked (when vertical),
/// separated by a thin draggable divider strip. The split position is
/// expressed as a ratio (0.0–1.0) of the total available space given to the
/// leading pane; it starts at [initialRatio] and is clamped to
/// [minRatio]–[maxRatio] during drags.
///
/// [onDividerDragStart] is called once when the user begins dragging.
/// [onRatioChanged] is called continuously during the drag.
///
/// Pass an [OiSettingsDriver] and [settingsKey] to persist the ratio across
/// sessions. The key is used as a sub-key under the `oi_split_pane` namespace.
///
/// {@category Components}
class OiSplitPane extends StatefulWidget {
  /// Creates an [OiSplitPane].
  const OiSplitPane({
    required this.leading,
    required this.trailing,
    this.direction = Axis.horizontal,
    this.initialRatio = 0.5,
    this.minRatio = 0.1,
    this.maxRatio = 0.9,
    this.dividerSize = 4,
    this.onDividerDragStart,
    this.onRatioChanged,
    this.settingsDriver,
    this.settingsKey,
    super.key,
  });

  /// The leading (left or top) pane content.
  final Widget leading;

  /// The trailing (right or bottom) pane content.
  final Widget trailing;

  /// The split axis. [Axis.horizontal] places panes side-by-side.
  final Axis direction;

  /// The initial fraction of space given to [leading]. Defaults to `0.5`.
  final double initialRatio;

  /// The minimum allowed ratio. Defaults to `0.1`.
  final double minRatio;

  /// The maximum allowed ratio. Defaults to `0.9`.
  final double maxRatio;

  /// Thickness of the draggable divider strip in logical pixels. Defaults to 4.
  final double dividerSize;

  /// Called once when the user starts dragging the divider.
  final VoidCallback? onDividerDragStart;

  /// Called continuously with the updated ratio as the divider is dragged.
  final void Function(double ratio)? onRatioChanged;

  /// Optional driver for persisting the ratio.
  final OiSettingsDriver? settingsDriver;

  /// Sub-key used with [settingsDriver] to disambiguate multiple split panes.
  final String? settingsKey;

  @override
  State<OiSplitPane> createState() => _OiSplitPaneState();
}

// ── Settings data ──────────────────────────────────────────────────────────

class _SplitSettings with OiSettingsData {
  const _SplitSettings(this.ratio);

  factory _SplitSettings.fromJson(Map<String, dynamic> json) =>
      _SplitSettings((json['ratio'] as num).toDouble());

  final double ratio;

  @override
  int get schemaVersion => 1;

  @override
  Map<String, dynamic> toJson() => {
    'ratio': ratio,
    'schemaVersion': schemaVersion,
  };
}

// ── State ──────────────────────────────────────────────────────────────────

class _OiSplitPaneState extends State<OiSplitPane> {
  late double _ratio;

  @override
  void initState() {
    super.initState();
    _ratio = widget.initialRatio.clamp(widget.minRatio, widget.maxRatio);
    unawaited(_loadRatio());
  }

  Future<void> _loadRatio() async {
    final driver = widget.settingsDriver;
    if (driver == null) return;
    final saved = await driver.load<_SplitSettings>(
      namespace: 'oi_split_pane',
      key: widget.settingsKey,
      deserialize: _SplitSettings.fromJson,
    );
    if (saved != null && mounted) {
      setState(
        () => _ratio = saved.ratio.clamp(widget.minRatio, widget.maxRatio),
      );
    }
  }

  Future<void> _saveRatio(double ratio) async {
    final driver = widget.settingsDriver;
    if (driver == null) return;
    await driver.save<_SplitSettings>(
      namespace: 'oi_split_pane',
      key: widget.settingsKey,
      data: _SplitSettings(ratio),
      serialize: (d) => d.toJson(),
    );
  }

  void _handleDragStart(DragStartDetails _) {
    widget.onDividerDragStart?.call();
  }

  void _handleDragUpdate(DragUpdateDetails details, double totalSize) {
    final delta = widget.direction == Axis.horizontal
        ? details.delta.dx
        : details.delta.dy;
    setState(() {
      _ratio = (_ratio + delta / totalSize).clamp(
        widget.minRatio,
        widget.maxRatio,
      );
    });
    widget.onRatioChanged?.call(_ratio);
    unawaited(_saveRatio(_ratio));
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalSize = widget.direction == Axis.horizontal
            ? constraints.maxWidth
            : constraints.maxHeight;

        final leadingSize = totalSize * _ratio - widget.dividerSize / 2;

        final leadingPane = SizedBox(
          width: widget.direction == Axis.horizontal ? leadingSize : null,
          height: widget.direction == Axis.vertical ? leadingSize : null,
          child: widget.leading,
        );

        final divider = MouseRegion(
          cursor: widget.direction == Axis.horizontal
              ? SystemMouseCursors.resizeColumn
              : SystemMouseCursors.resizeRow,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onHorizontalDragStart: widget.direction == Axis.horizontal
                ? _handleDragStart
                : null,
            onHorizontalDragUpdate: widget.direction == Axis.horizontal
                ? (d) => _handleDragUpdate(d, totalSize)
                : null,
            onVerticalDragStart: widget.direction == Axis.vertical
                ? _handleDragStart
                : null,
            onVerticalDragUpdate: widget.direction == Axis.vertical
                ? (d) => _handleDragUpdate(d, totalSize)
                : null,
            child: SizedBox(
              width: widget.direction == Axis.horizontal
                  ? widget.dividerSize
                  : null,
              height: widget.direction == Axis.vertical
                  ? widget.dividerSize
                  : null,
              child: DecoratedBox(
                decoration: BoxDecoration(color: colors.borderSubtle),
              ),
            ),
          ),
        );

        final children = [
          leadingPane,
          divider,
          Expanded(child: widget.trailing),
        ];

        return widget.direction == Axis.horizontal
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: children,
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: children,
              );
      },
    );
  }
}
