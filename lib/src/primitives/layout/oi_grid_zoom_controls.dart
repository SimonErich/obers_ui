import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/buttons/oi_button.dart';
import 'package:obers_ui/src/components/buttons/oi_icon_button.dart';
import 'package:obers_ui/src/foundation/oi_icons.dart';
import 'package:obers_ui/src/foundation/oi_responsive.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/display/oi_label.dart';
import 'package:obers_ui/src/primitives/layout/oi_grid.dart';

/// A wrapper around [OiGrid] that adds +/- zoom controls to change the
/// column count interactively.
///
/// ```dart
/// OiGridZoomControls(
///   breakpoint: context.breakpoint,
///   initialColumns: 3,
///   minColumns: 1,
///   maxColumns: 6,
///   onColumnsChanged: (cols) => print('Now $cols columns'),
///   gap: OiResponsive<double>(16),
///   children: [...],
/// )
/// ```
///
/// {@category Primitives}
class OiGridZoomControls extends StatefulWidget {
  /// Creates an [OiGridZoomControls].
  const OiGridZoomControls({
    required this.breakpoint,
    required this.children,
    this.initialColumns = 3,
    this.minColumns = 1,
    this.maxColumns = 12,
    this.onColumnsChanged,
    this.gap = const OiResponsive<double>(0),
    this.rowGap,
    this.scale = OiBreakpointScale.defaultScale,
    super.key,
  });

  /// The active breakpoint passed through to the inner [OiGrid].
  final OiBreakpoint breakpoint;

  /// The child widgets placed in the grid.
  final List<Widget> children;

  /// Starting column count. Defaults to 3.
  final int initialColumns;

  /// Minimum allowed columns when zooming out. Defaults to 1.
  final int minColumns;

  /// Maximum allowed columns when zooming in. Defaults to 12.
  final int maxColumns;

  /// Called when the user changes the column count via +/- buttons.
  final ValueChanged<int>? onColumnsChanged;

  /// Horizontal (and vertical when [rowGap] is null) gap.
  final OiResponsive<double> gap;

  /// Vertical gap override.
  final OiResponsive<double>? rowGap;

  /// Breakpoint scale for responsive value resolution.
  final OiBreakpointScale scale;

  @override
  State<OiGridZoomControls> createState() => _OiGridZoomControlsState();
}

class _OiGridZoomControlsState extends State<OiGridZoomControls> {
  late int _currentColumns;

  @override
  void initState() {
    super.initState();
    _currentColumns = widget.initialColumns.clamp(
      widget.minColumns,
      widget.maxColumns,
    );
  }

  void _increment() {
    if (_currentColumns >= widget.maxColumns) return;
    setState(() => _currentColumns++);
    widget.onColumnsChanged?.call(_currentColumns);
  }

  void _decrement() {
    if (_currentColumns <= widget.minColumns) return;
    setState(() => _currentColumns--);
    widget.onColumnsChanged?.call(_currentColumns);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final shadows = context.shadows;
    final radius = context.radius;
    final spacing = context.spacing;

    return Stack(
      children: [
        Positioned.fill(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(bottom: spacing.xl),
            child: OiGrid(
              breakpoint: widget.breakpoint,
              columns: OiResponsive<int>(_currentColumns),
              gap: widget.gap,
              rowGap: widget.rowGap,
              scale: widget.scale,
              children: widget.children,
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Center(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: spacing.md,
                vertical: spacing.xs,
              ),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: radius.full,
                boxShadow: shadows.sm,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  OiIconButton(
                    icon: OiIcons.minus,
                    semanticLabel: 'Decrease columns',
                    onTap: _currentColumns > widget.minColumns
                        ? _decrement
                        : null,
                    size: OiButtonSize.small,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: spacing.sm),
                    child: OiLabel.small(
                      '$_currentColumns',
                      color: colors.textMuted,
                    ),
                  ),
                  OiIconButton(
                    icon: OiIcons.plus,
                    semanticLabel: 'Increase columns',
                    onTap: _currentColumns < widget.maxColumns
                        ? _increment
                        : null,
                    size: OiButtonSize.small,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
