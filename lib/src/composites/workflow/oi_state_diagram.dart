import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/theme/oi_color_scheme.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';

/// A state in a state diagram.
///
/// Represents a single node rendered as a rounded rectangle at a given
/// [position] inside the [OiStateDiagram].
class OiStateNode {
  /// Creates an [OiStateNode].
  const OiStateNode({
    required this.key,
    required this.label,
    this.position = Offset.zero,
    this.color,
    this.initial = false,
    this.terminal = false,
  });

  /// A unique key used to identify this state when connecting transitions.
  final Object key;

  /// The display label for this state.
  final String label;

  /// The position of this state node inside the diagram canvas.
  final Offset position;

  /// An optional color override for the node background.
  final Color? color;

  /// Whether this is the initial state (drawn with an incoming arrow).
  final bool initial;

  /// Whether this is a final/accepting state (drawn with a double border).
  final bool terminal;
}

/// A transition between states.
///
/// Represents a directed edge from [from] to [to] with an optional [label].
class OiStateTransition {
  /// Creates an [OiStateTransition].
  const OiStateTransition({
    required this.from,
    required this.to,
    this.label,
    this.color,
  });

  /// The key of the source [OiStateNode].
  final Object from;

  /// The key of the target [OiStateNode].
  final Object to;

  /// An optional label displayed alongside the transition arrow.
  final String? label;

  /// An optional color override for the transition arrow.
  final Color? color;
}

/// A visual state machine diagram showing states as nodes and transitions
/// as edges.
///
/// States are rendered as rounded rectangles with labels. Transitions are
/// drawn as arrows between states with optional labels. The [currentState]
/// is highlighted with a distinct border.
///
/// {@category Composites}
class OiStateDiagram extends StatelessWidget {
  /// Creates an [OiStateDiagram].
  const OiStateDiagram({
    required this.states,
    required this.transitions,
    required this.label,
    this.currentState,
    this.editable = false,
    this.onStateSelect,
    this.width,
    this.height,
    super.key,
  });

  /// The list of state nodes to render.
  final List<OiStateNode> states;

  /// The list of transitions connecting states.
  final List<OiStateTransition> transitions;

  /// Accessibility label for the diagram.
  final String label;

  /// The key of the currently active state, highlighted visually.
  final Object? currentState;

  /// Whether the diagram supports interactive editing.
  final bool editable;

  /// Called when a state node is tapped.
  final ValueChanged<Object>? onStateSelect;

  /// The width of the diagram canvas.
  final double? width;

  /// The height of the diagram canvas.
  final double? height;

  // ---------------------------------------------------------------------------
  // Constants
  // ---------------------------------------------------------------------------

  static const double _nodeWidth = 120;
  static const double _nodeHeight = 48;
  static const double _nodeRadius = 8;
  static const double _initialMarkerSize = 8;

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final resolvedWidth = width ?? 400;
    final resolvedHeight = height ?? 300;

    // Map state keys to nodes for quick lookup.
    final nodeMap = <Object, OiStateNode>{};
    for (final state in states) {
      nodeMap[state.key] = state;
    }

    return Semantics(
      label: label,
      child: SizedBox(
        width: resolvedWidth,
        height: resolvedHeight,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Paint transitions as a background layer.
            Positioned.fill(
              child: CustomPaint(
                painter: _TransitionPainter(
                  transitions: transitions,
                  nodeMap: nodeMap,
                  nodeWidth: _nodeWidth,
                  nodeHeight: _nodeHeight,
                  defaultColor: colors.border,
                  textColor: colors.textMuted,
                ),
              ),
            ),
            // Render state nodes.
            for (final state in states)
              Positioned(
                left: state.position.dx,
                top: state.position.dy,
                child: _buildNode(context, state, colors),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNode(
    BuildContext context,
    OiStateNode state,
    OiColorScheme colors,
  ) {
    final isCurrent = currentState == state.key;
    final nodeColor = state.color ?? colors.surface;
    final borderColor = isCurrent
        ? colors.primary.base
        : colors.border;
    final borderWidth = isCurrent ? 3.0 : 1.5;

    Widget node = Container(
      key: ValueKey('oi_state_node_${state.key}'),
      width: _nodeWidth,
      height: _nodeHeight,
      decoration: BoxDecoration(
        color: nodeColor,
        borderRadius: BorderRadius.circular(_nodeRadius),
        border: Border.all(color: borderColor, width: borderWidth),
      ),
      child: Center(
        child: Text(
          state.label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: colors.text,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );

    // Final states get a double border via an outer container.
    if (state.terminal) {
      node = Container(
        key: ValueKey('oi_state_final_${state.key}'),
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(_nodeRadius + 3),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: node,
      );
    }

    // Initial states get an incoming marker.
    if (state.initial) {
      node = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            key: const ValueKey('oi_state_initial_marker'),
            width: _initialMarkerSize,
            height: _initialMarkerSize,
            decoration: BoxDecoration(
              color: borderColor,
              shape: BoxShape.circle,
            ),
          ),
          Container(
            width: 12,
            height: 2,
            color: borderColor,
          ),
          node,
        ],
      );
    }

    if (onStateSelect != null) {
      final tappable = GestureDetector(
        onTap: () => onStateSelect!(state.key),
        child: node,
      );
      return tappable;
    }

    return node;
  }
}

// ---------------------------------------------------------------------------
// Transition painter
// ---------------------------------------------------------------------------

/// Paints transition arrows between state nodes.
class _TransitionPainter extends CustomPainter {
  const _TransitionPainter({
    required this.transitions,
    required this.nodeMap,
    required this.nodeWidth,
    required this.nodeHeight,
    required this.defaultColor,
    required this.textColor,
  });

  /// The list of transitions to paint.
  final List<OiStateTransition> transitions;

  /// A map from state key to [OiStateNode] for position lookup.
  final Map<Object, OiStateNode> nodeMap;

  /// The width of each state node.
  final double nodeWidth;

  /// The height of each state node.
  final double nodeHeight;

  /// The default arrow color when [OiStateTransition.color] is null.
  final Color defaultColor;

  /// The color used for transition labels.
  final Color textColor;

  @override
  void paint(Canvas canvas, Size size) {
    for (final transition in transitions) {
      final from = nodeMap[transition.from];
      final to = nodeMap[transition.to];
      if (from == null || to == null) continue;

      final fromCenter = Offset(
        from.position.dx + nodeWidth / 2,
        from.position.dy + nodeHeight / 2,
      );
      final toCenter = Offset(
        to.position.dx + nodeWidth / 2,
        to.position.dy + nodeHeight / 2,
      );

      final arrowColor = transition.color ?? defaultColor;
      final paint = Paint()
        ..color = arrowColor
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;

      // Draw the line.
      canvas.drawLine(fromCenter, toCenter, paint);

      // Draw arrowhead at the target end.
      final dx = toCenter.dx - fromCenter.dx;
      final dy = toCenter.dy - fromCenter.dy;
      final angle = math.atan2(dy, dx);
      const arrowLength = 10.0;
      const arrowAngle = math.pi / 6;

      final arrowTip = toCenter;
      final arrowLeft = Offset(
        arrowTip.dx - arrowLength * math.cos(angle - arrowAngle),
        arrowTip.dy - arrowLength * math.sin(angle - arrowAngle),
      );
      final arrowRight = Offset(
        arrowTip.dx - arrowLength * math.cos(angle + arrowAngle),
        arrowTip.dy - arrowLength * math.sin(angle + arrowAngle),
      );

      final headPaint = Paint()
        ..color = arrowColor
        ..style = PaintingStyle.fill;

      final path = Path()
        ..moveTo(arrowTip.dx, arrowTip.dy)
        ..lineTo(arrowLeft.dx, arrowLeft.dy)
        ..lineTo(arrowRight.dx, arrowRight.dy)
        ..close();
      canvas.drawPath(path, headPaint);

      // Draw transition label at the midpoint if present.
      if (transition.label != null) {
        final midPoint = Offset(
          (fromCenter.dx + toCenter.dx) / 2,
          (fromCenter.dy + toCenter.dy) / 2 - 10,
        );
        final textPainter = TextPainter(
          text: TextSpan(
            text: transition.label,
            style: TextStyle(color: textColor, fontSize: 11),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        textPainter.paint(
          canvas,
          midPoint - Offset(textPainter.width / 2, textPainter.height / 2),
        );
      }
    }
  }

  @override
  bool shouldRepaint(_TransitionPainter oldDelegate) => true;
}
