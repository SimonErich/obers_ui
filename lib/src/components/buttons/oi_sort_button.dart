import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/buttons/oi_button.dart';
import 'package:obers_ui/src/components/buttons/oi_toggle_button.dart';
import 'package:obers_ui/src/components/display/oi_popover.dart';
import 'package:obers_ui/src/components/inputs/oi_radio.dart';
import 'package:obers_ui/src/foundation/oi_icons.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/display/oi_label.dart';

/// Sort direction for [OiSortOption].
///
/// {@category Components}
enum OiSortDirection {
  /// Ascending order (A→Z, 0→9, oldest→newest).
  asc,

  /// Descending order (Z→A, 9→0, newest→oldest).
  desc,
}

/// A single sort option for [OiSortButton].
///
/// {@category Components}
@immutable
class OiSortOption {
  /// Creates an [OiSortOption].
  const OiSortOption({
    required this.field,
    required this.label,
    this.direction = OiSortDirection.asc,
  });

  /// The field identifier used for sorting.
  final String field;

  /// The display label for this sort option.
  final String label;

  /// The sort direction.
  final OiSortDirection direction;

  /// Returns a copy with the direction flipped.
  OiSortOption toggleDirection() => OiSortOption(
    field: field,
    label: label,
    direction: direction == OiSortDirection.asc
        ? OiSortDirection.desc
        : OiSortDirection.asc,
  );

  /// Returns a copy with the given [direction].
  OiSortOption withDirection(OiSortDirection direction) =>
      OiSortOption(field: field, label: label, direction: direction);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OiSortOption &&
          other.field == field &&
          other.label == label &&
          other.direction == direction;

  @override
  int get hashCode => Object.hash(field, label, direction);
}

/// A dropdown button for sorting non-table lists (card grids, activity feeds).
///
/// Displays the current sort field and direction. Opens a popover with radio
/// options for sort field and a toggle for ascending/descending.
///
/// ```dart
/// OiSortButton(
///   label: 'Sort by',
///   options: [
///     OiSortOption(field: 'name', label: 'Name'),
///     OiSortOption(field: 'date', label: 'Date'),
///   ],
///   currentSort: OiSortOption(field: 'name', label: 'Name'),
///   onSortChange: (option) => setState(() => _sort = option),
/// )
/// ```
///
/// {@category Components}
class OiSortButton extends StatefulWidget {
  /// Creates an [OiSortButton].
  const OiSortButton({
    required this.options,
    required this.currentSort,
    required this.label,
    required this.onSortChange,
    super.key,
  }) : assert(options.length > 0, 'options must not be empty');

  /// The available sort options.
  final List<OiSortOption> options;

  /// The currently active sort option.
  final OiSortOption currentSort;

  /// The accessible label describing this control.
  final String label;

  /// Called when the user selects a new sort field or toggles direction.
  final ValueChanged<OiSortOption> onSortChange;

  @override
  State<OiSortButton> createState() => _OiSortButtonState();
}

class _OiSortButtonState extends State<OiSortButton> {
  bool _isOpen = false;

  void _togglePopover() {
    setState(() => _isOpen = !_isOpen);
  }

  void _closePopover() {
    setState(() => _isOpen = false);
  }

  void _selectField(OiSortOption option) {
    final newOption = option.withDirection(widget.currentSort.direction);
    widget.onSortChange(newOption);
    _closePopover();
  }

  void _toggleDirection() {
    widget.onSortChange(widget.currentSort.toggleDirection());
  }

  IconData get _directionIcon =>
      widget.currentSort.direction == OiSortDirection.asc
      ? OiIcons.arrowUp // arrow_upward
      : OiIcons.arrowDown; // arrow_downward

  Widget _buildPopoverContent(BuildContext context) {
    final spacing = context.spacing;
    final colors = context.colors;

    return UnconstrainedBox(
      alignment: Alignment.topLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 180),
        child: Padding(
          padding: EdgeInsets.all(spacing.sm),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(bottom: spacing.xs),
                child: OiLabel.smallStrong(widget.label),
              ),
              OiRadio<String>(
                options: [
                  for (final option in widget.options)
                    OiRadioOption<String>(
                      value: option.field,
                      label: option.label,
                    ),
                ],
                value: widget.currentSort.field,
                onChanged: (field) {
                  final option = widget.options.firstWhere(
                    (o) => o.field == field,
                  );
                  _selectField(option);
                },
              ),
              Padding(
                padding: EdgeInsets.only(top: spacing.xs),
                child: Container(height: 1, color: colors.borderSubtle),
              ),
              Padding(
                padding: EdgeInsets.only(top: spacing.xs),
                child: OiToggleButton(
                  label: widget.currentSort.direction == OiSortDirection.asc
                      ? 'Ascending'
                      : 'Descending',
                  icon: _directionIcon,
                  selected:
                      widget.currentSort.direction == OiSortDirection.desc,
                  onChanged: (_) => _toggleDirection(),
                  semanticLabel: 'Toggle sort direction',
                  size: OiButtonSize.small,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return OiPopover(
      label: widget.label,
      open: _isOpen,
      onClose: _closePopover,
      initialFocus: false,
      anchor: OiButton.outline(
        label: widget.currentSort.label,
        icon: _directionIcon,
        iconPosition: OiIconPosition.trailing,
        onTap: _togglePopover,
        semanticLabel: widget.label,
      ),
      content: _buildPopoverContent(context),
    );
  }
}
