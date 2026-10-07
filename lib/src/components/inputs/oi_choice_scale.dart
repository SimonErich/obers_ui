import 'dart:ui' show SemanticsRole;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/theme/oi_component_themes.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/display/oi_label.dart';
import 'package:obers_ui/src/primitives/interaction/oi_tappable.dart';

/// One labelled choice in a discrete scale.
@immutable
class OiChoiceScaleOption<T> {
  /// Creates a choice with a stable identity.
  const OiChoiceScaleOption({
    required this.value,
    required this.label,
    this.enabled = true,
  });

  /// Stable identity, also used to preserve focus across reorderings.
  final T value;

  /// Visible and accessible label.
  final String label;

  /// Whether this choice accepts interaction.
  final bool enabled;
}

/// A discrete labelled scale with radio semantics and roving keyboard focus.
///
/// Arrows follow reading direction, Home/End select the first/last enabled
/// option, and disabled choices are skipped. Large text and narrow layouts
/// reflow into a grid. All styling comes from the component theme.
class OiChoiceScale<T> extends StatefulWidget {
  /// Creates a scale; a null callback disables interaction.
  const OiChoiceScale({
    required this.options,
    required this.value,
    required this.label,
    required this.onChanged,
    super.key,
  });

  /// Available choices, each with a unique stable value.
  final List<OiChoiceScaleOption<T>> options;

  /// Current value; an absent value leaves the group unselected.
  final T value;

  /// Accessible group label.
  final String label;

  /// Selection callback; the caller owns the value.
  final ValueChanged<T>? onChanged;
  @override
  State<OiChoiceScale<T>> createState() => _OiChoiceScaleState<T>();
}

class _OiChoiceScaleState<T> extends State<OiChoiceScale<T>> {
  final Map<T, FocusNode> _nodes = {};
  @override
  void initState() {
    super.initState();
    _syncNodes();
  }

  @override
  void didUpdateWidget(OiChoiceScale<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncNodes();
  }

  void _syncNodes() {
    final values = widget.options.map((o) => o.value).toSet();
    if (values.length != widget.options.length) {
      throw ArgumentError('Choice values must be unique.');
    }
    for (final value in _nodes.keys.toList()) {
      if (!values.contains(value)) _nodes.remove(value)!.dispose();
    }
    final enabled = widget.options.where(
      (o) => o.enabled && widget.onChanged != null,
    );
    final tabValue =
        enabled.where((o) => o.value == widget.value).firstOrNull?.value ??
        enabled.firstOrNull?.value;
    for (final option in widget.options) {
      _nodes.putIfAbsent(option.value, FocusNode.new)
        ..canRequestFocus = option.enabled && widget.onChanged != null
        ..skipTraversal = option.value != tabValue;
    }
  }

  @override
  void dispose() {
    for (final node in _nodes.values) {
      node.dispose();
    }
    super.dispose();
  }

  void _select(int index) {
    final option = widget.options[index];
    if (!option.enabled || widget.onChanged == null) return;
    _nodes[option.value]!.requestFocus();
    if (option.value != widget.value) widget.onChanged!(option.value);
  }

  KeyEventResult _key(KeyEvent event, int index) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final enabled = [
      for (var i = 0; i < widget.options.length; i++)
        if (widget.options[i].enabled && widget.onChanged != null) i,
    ];
    if (enabled.isEmpty) return KeyEventResult.ignored;
    final key = event.logicalKey;
    int? target;
    if (key == LogicalKeyboardKey.home) target = enabled.first;
    if (key == LogicalKeyboardKey.end) target = enabled.last;
    if (key == LogicalKeyboardKey.arrowLeft ||
        key == LogicalKeyboardKey.arrowRight ||
        key == LogicalKeyboardKey.arrowUp ||
        key == LogicalKeyboardKey.arrowDown) {
      final forward =
          key == LogicalKeyboardKey.arrowDown ||
          (key != LogicalKeyboardKey.arrowUp &&
              (key == LogicalKeyboardKey.arrowRight) ==
                  (Directionality.of(context) == TextDirection.ltr));
      target =
          enabled[(enabled.indexOf(index) + (forward ? 1 : -1)) %
              enabled.length];
    }
    if (target == null) return KeyEventResult.ignored;
    _select(target);
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final theme =
        context.components.choiceScale ?? const OiChoiceScaleThemeData();
    final ordinary = context.textTheme.small.merge(theme.labelStyle);
    final selected = ordinary.merge(theme.selectedLabelStyle);
    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: widget.label,
      role: SemanticsRole.radioGroup,
      child: LayoutBuilder(
        builder: (context, bounds) {
          if (widget.options.isEmpty) return const SizedBox.shrink();
          final largeText =
              MediaQuery.textScalerOf(context).scale(ordinary.fontSize ?? 14) /
                  (ordinary.fontSize ?? 14) >
              1.3;
          final wrap =
              largeText ||
              (bounds.hasBoundedWidth &&
                  bounds.maxWidth < widget.options.length * theme.itemWidth);
          final width = wrap && bounds.hasBoundedWidth
              ? (bounds.maxWidth - context.spacing.sm) / 2
              : theme.itemWidth;
          final items = <Widget>[
            for (var i = 0; i < widget.options.length; i++)
              Semantics(
                key: ValueKey(widget.options[i].value),
                container: true,
                label: widget.options[i].label,
                checked: widget.options[i].value == widget.value,
                inMutuallyExclusiveGroup: true,
                enabled: widget.options[i].enabled && widget.onChanged != null,
                child: Focus(
                  canRequestFocus: false,
                  skipTraversal: true,
                  onKeyEvent: (_, event) => _key(event, i),
                  child: OiTappable(
                    focusNode: _nodes[widget.options[i].value],
                    enabled:
                        widget.options[i].enabled && widget.onChanged != null,
                    onTap: () => _select(i),
                    child: ExcludeSemantics(
                      child: SizedBox(
                        width: width,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              height: theme.markerExtent,
                              child: Center(
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color:
                                        widget.options[i].value == widget.value
                                        ? theme.selectedMarkerColor ??
                                              context.colors.primary.base
                                        : theme.markerColor ??
                                              context.colors.textMuted,
                                    boxShadow: [
                                      BoxShadow(
                                        color: context.colors.background,
                                        spreadRadius: context.spacing.xs,
                                      ),
                                    ],
                                  ),
                                  child: SizedBox.square(
                                    dimension:
                                        widget.options[i].value == widget.value
                                        ? theme.selectedMarkerSize
                                        : theme.markerSize,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: theme.labelGap),
                            OiLabel.body(
                              widget.options[i].label,
                              textAlign: TextAlign.center,
                              style: widget.options[i].value == widget.value
                                  ? selected
                                  : ordinary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ];
          if (wrap) {
            return Wrap(
              spacing: context.spacing.sm,
              runSpacing: context.spacing.sm,
              children: items,
            );
          }
          return Stack(
            children: [
              Positioned(
                left: width / 2,
                right: width / 2,
                top:
                    theme.lineOffset ??
                    (theme.markerExtent - theme.lineWidth) / 2,
                child: SizedBox(
                  height: theme.lineWidth,
                  child: ColoredBox(
                    color: theme.lineColor ?? context.colors.border,
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: items,
              ),
            ],
          );
        },
      ),
    );
  }
}
