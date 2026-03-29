import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/display/oi_tooltip.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/display/oi_label.dart';

/// A single row in an [OiPropertyGrid].
///
/// {@category Composites}
@immutable
class OiPropertyRow {
  /// Creates an [OiPropertyRow].
  const OiPropertyRow({
    required this.label,
    required this.editor,
    this.tooltip,
  });

  /// The property name shown in the label column.
  final String label;

  /// The inline editor widget (e.g. [OiSwitch], [OiEditableText]).
  final Widget editor;

  /// Optional tooltip displayed when hovering the label.
  final String? tooltip;
}

/// A dense, two-column grid for displaying and editing properties
/// or settings.
///
/// The label and editor columns are separated by a draggable divider.
/// Drag the divider to adjust the ratio between columns.
///
/// {@category Composites}
class OiPropertyGrid extends StatefulWidget {
  /// Creates an [OiPropertyGrid].
  const OiPropertyGrid({
    required this.properties,
    this.dividerPosition = 0.4,
    this.onDividerDragged,
    super.key,
  });

  /// The property rows to display.
  final List<OiPropertyRow> properties;

  /// Initial split ratio between label and editor columns (0.0–1.0).
  /// Defaults to 0.4 (40 % labels, 60 % editors).
  final double dividerPosition;

  /// Called when the user drags the divider, with the new ratio.
  final ValueChanged<double>? onDividerDragged;

  @override
  State<OiPropertyGrid> createState() => _OiPropertyGridState();
}

class _OiPropertyGridState extends State<OiPropertyGrid> {
  late double _ratio;

  @override
  void initState() {
    super.initState();
    _ratio = widget.dividerPosition.clamp(0.2, 0.8);
  }

  @override
  void didUpdateWidget(OiPropertyGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.dividerPosition != widget.dividerPosition) {
      _ratio = widget.dividerPosition.clamp(0.2, 0.8);
    }
  }

  static const double _kDividerWidth = 4;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;
        final labelWidth = totalWidth * _ratio - _kDividerWidth / 2;
        final dividerColor = colors.borderSubtle;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < widget.properties.length; i++) ...[
              if (i > 0) Container(height: 1, color: dividerColor),
              _buildRow(
                context,
                widget.properties[i],
                labelWidth,
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildRow(
    BuildContext context,
    OiPropertyRow row,
    double labelWidth,
  ) {
    final colors = context.colors;
    final spacing = context.spacing;

    Widget labelWidget = Padding(
      padding: EdgeInsets.symmetric(horizontal: spacing.sm),
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: OiLabel.small(row.label, color: colors.textSubtle),
      ),
    );

    if (row.tooltip != null) {
      labelWidget = OiTooltip(
        label: row.label,
        message: row.tooltip!,
        child: labelWidget,
      );
    }

    return MergeSemantics(
      child: Row(
        children: [
          SizedBox(
            width: labelWidth,
            child: labelWidget,
          ),
          MouseRegion(
            cursor: SystemMouseCursors.resizeColumn,
            child: GestureDetector(
              onHorizontalDragUpdate: (details) {
                setState(() {
                  final box = context.findRenderObject()! as RenderBox;
                  final totalWidth = box.size.width;
                  _ratio =
                      ((_ratio * totalWidth + details.delta.dx) / totalWidth)
                          .clamp(0.2, 0.8);
                  widget.onDividerDragged?.call(_ratio);
                });
              },
              child: SizedBox(
                width: _kDividerWidth,
                height: spacing.xxl,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: spacing.sm,
                vertical: spacing.xs,
              ),
              child: row.editor,
            ),
          ),
        ],
      ),
    );
  }
}
