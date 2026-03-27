import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/display/oi_label.dart';
import 'package:obers_ui/src/primitives/interaction/oi_tappable.dart';

/// The size variant for an [OiIndexBar].
///
/// {@category Components}
enum OiIndexBarSize {
  /// Small index bar with compact label sizing.
  small,

  /// Medium (default) index bar.
  medium,

  /// Large index bar with larger label sizing.
  large,
}

/// A vertical alphabet/index sidebar for fast jumping in grouped lists.
///
/// Renders a vertical column of small text labels that can be tapped or
/// scrubbed via drag to quickly navigate to a section. Commonly paired
/// with [ListView] or grouped-list widgets for contact-style scrolling.
///
/// Use the [OiIndexBar.alphabet] factory to create a standard A-Z bar.
///
/// ```dart
/// OiIndexBar.alphabet(
///   onLabelSelected: (letter) => scrollToSection(letter),
///   semanticLabel: 'Alphabet index',
/// )
/// ```
///
/// {@category Components}
class OiIndexBar extends StatelessWidget {
  /// Creates an [OiIndexBar] with custom labels.
  const OiIndexBar({
    required this.labels,
    required this.onLabelSelected,
    required this.semanticLabel,
    this.activeLabel,
    this.availableLabels,
    this.size = OiIndexBarSize.medium,
    this.showTooltip = true,
    this.hapticFeedback = true,
    this.alignment = Alignment.centerRight,
    this.padding,
    super.key,
  });

  /// Creates an [OiIndexBar] with A-Z labels and an optional `#` hash entry.
  factory OiIndexBar.alphabet({
    required ValueChanged<String> onLabelSelected,
    required String semanticLabel,
    String? activeLabel,
    Set<String>? availableLabels,
    bool includeHash = true,
    Key? key,
  }) {
    final letters = List<String>.generate(
      26,
      (i) => String.fromCharCode(0x41 + i),
    );
    if (includeHash) letters.add('#');
    return OiIndexBar(
      labels: letters,
      onLabelSelected: onLabelSelected,
      semanticLabel: semanticLabel,
      activeLabel: activeLabel,
      availableLabels: availableLabels,
      key: key,
    );
  }

  /// The ordered list of index labels to display.
  final List<String> labels;

  /// Called when a label is tapped or scrubbed to via drag.
  final ValueChanged<String> onLabelSelected;

  /// Accessibility label for the index bar.
  final String semanticLabel;

  /// The currently active label, highlighted with the primary color.
  final String? activeLabel;

  /// Labels that have content. Labels not in this set are dimmed.
  ///
  /// When `null`, all labels are treated as available.
  final Set<String>? availableLabels;

  /// The size variant of the index bar.
  final OiIndexBarSize size;

  /// Whether to show a tooltip when scrubbing.
  final bool showTooltip;

  /// Whether to trigger haptic feedback when crossing label boundaries.
  final bool hapticFeedback;

  /// The alignment of the index bar within its parent.
  final Alignment alignment;

  /// Optional padding around the index bar.
  final EdgeInsetsGeometry? padding;

  double _fontSize(double baseSize) {
    return switch (size) {
      OiIndexBarSize.small => baseSize * 0.8,
      OiIndexBarSize.medium => baseSize,
      OiIndexBarSize.large => baseSize * 1.25,
    };
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final themeData = context.components.indexBar;

    final baseFontSize = themeData?.labelSize ?? 10.0;
    final fontSize = _fontSize(baseFontSize);
    final activeColor = themeData?.activeColor ?? colors.primary.base;

    return Semantics(
      label: semanticLabel,
      child: Align(
        alignment: alignment,
        child: Padding(
          padding: padding ?? EdgeInsets.zero,
          child: _IndexBarGesture(
            labels: labels,
            onLabelSelected: onLabelSelected,
            hapticFeedback: hapticFeedback,
            showTooltip: showTooltip,
            tooltipColor: activeColor,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final label in labels)
                  _IndexLabel(
                    label: label,
                    fontSize: fontSize,
                    active: label == activeLabel,
                    available: availableLabels?.contains(label) ?? true,
                    activeColor: activeColor,
                    mutedColor: colors.textMuted,
                    defaultColor: colors.textSubtle,
                    onTap: () => onLabelSelected(label),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Internal gesture handler that enables vertical drag scrubbing across labels.
class _IndexBarGesture extends StatefulWidget {
  const _IndexBarGesture({
    required this.labels,
    required this.onLabelSelected,
    required this.hapticFeedback,
    required this.showTooltip,
    required this.tooltipColor,
    required this.child,
  });

  final List<String> labels;
  final ValueChanged<String> onLabelSelected;
  final bool hapticFeedback;
  final bool showTooltip;
  final Color tooltipColor;
  final Widget child;

  @override
  State<_IndexBarGesture> createState() => _IndexBarGestureState();
}

class _IndexBarGestureState extends State<_IndexBarGesture> {
  String? _lastReportedLabel;
  OverlayEntry? _tooltipEntry;
  String _tooltipLabel = '';
  double _tooltipDy = 0;
  final LayerLink _layerLink = LayerLink();

  String? _resolveLabel(Offset globalPosition) {
    final box = context.findRenderObject()! as RenderBox;
    final localPosition = box.globalToLocal(globalPosition);
    final height = box.size.height;
    final labelCount = widget.labels.length;

    if (labelCount == 0 || height == 0) return null;

    final fraction = (localPosition.dy / height).clamp(0.0, 1.0);
    final index = (fraction * (labelCount - 1)).round();
    return widget.labels[index];
  }

  void _showTooltipOverlay() {
    if (!widget.showTooltip) return;
    _tooltipEntry = OverlayEntry(
      builder: (context) {
        return CompositedTransformFollower(
          link: _layerLink,
          targetAnchor: Alignment.centerLeft,
          followerAnchor: Alignment.centerRight,
          offset: const Offset(-12, 0),
          child: Align(
            alignment: Alignment.centerRight,
            child: _TooltipBubble(
              label: _tooltipLabel,
              color: widget.tooltipColor,
              offsetY: _tooltipDy,
            ),
          ),
        );
      },
    );
    Overlay.of(context).insert(_tooltipEntry!);
  }

  void _updateTooltip(String label, double offsetY) {
    _tooltipLabel = label;
    _tooltipDy = offsetY;
    _tooltipEntry?.markNeedsBuild();
  }

  void _removeTooltip() {
    _tooltipEntry?.remove();
    _tooltipEntry = null;
  }

  void _handleDragStart(DragStartDetails details) {
    final label = _resolveLabel(details.globalPosition);
    if (label == null) return;
    _lastReportedLabel = label;
    widget.onLabelSelected(label);
    if (widget.hapticFeedback) {
      HapticFeedback.selectionClick();
    }

    if (widget.showTooltip) {
      final box = context.findRenderObject()! as RenderBox;
      final local = box.globalToLocal(details.globalPosition);
      _tooltipLabel = label;
      _tooltipDy = local.dy;
      _showTooltipOverlay();
    }
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    final label = _resolveLabel(details.globalPosition);
    if (label == null) return;

    if (label != _lastReportedLabel) {
      _lastReportedLabel = label;
      widget.onLabelSelected(label);
      if (widget.hapticFeedback) {
        HapticFeedback.selectionClick();
      }
    }

    if (widget.showTooltip) {
      final box = context.findRenderObject()! as RenderBox;
      final local = box.globalToLocal(details.globalPosition);
      _updateTooltip(label, local.dy);
    }
  }

  void _handleDragEnd(DragEndDetails details) {
    _lastReportedLabel = null;
    _removeTooltip();
  }

  @override
  void dispose() {
    _removeTooltip();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onVerticalDragStart: _handleDragStart,
        onVerticalDragUpdate: _handleDragUpdate,
        onVerticalDragEnd: _handleDragEnd,
        behavior: HitTestBehavior.opaque,
        child: widget.child,
      ),
    );
  }
}

/// Floating tooltip bubble shown during index bar drag.
class _TooltipBubble extends StatelessWidget {
  const _TooltipBubble({
    required this.label,
    required this.color,
    required this.offsetY,
  });

  final String label;
  final Color color;
  final double offsetY;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(0, offsetY - 20),
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: OiLabel.h3(label, color: const Color(0xFFFFFFFF)),
      ),
    );
  }
}

/// A single label entry in the index bar.
class _IndexLabel extends StatelessWidget {
  const _IndexLabel({
    required this.label,
    required this.fontSize,
    required this.active,
    required this.available,
    required this.activeColor,
    required this.mutedColor,
    required this.defaultColor,
    required this.onTap,
  });

  final String label;
  final double fontSize;
  final bool active;
  final bool available;
  final Color activeColor;
  final Color mutedColor;
  final Color defaultColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color color;
    if (active) {
      color = activeColor;
    } else if (!available) {
      color = mutedColor;
    } else {
      color = defaultColor;
    }

    return OiTappable(
      onTap: onTap,
      semanticLabel: label,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
        child: OiLabel.tiny(label, color: color),
      ),
    );
  }
}
