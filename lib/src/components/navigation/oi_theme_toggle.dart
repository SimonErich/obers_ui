import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/buttons/oi_icon_button.dart';
import 'package:obers_ui/src/components/display/oi_list_tile.dart';
import 'package:obers_ui/src/components/display/oi_popover.dart';
import 'package:obers_ui/src/components/display/oi_tooltip.dart';
import 'package:obers_ui/src/foundation/oi_app.dart';
import 'package:obers_ui/src/foundation/oi_icons.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/display/oi_icon.dart';

/// A toggle button that switches between light, dark, and system theme modes.
///
/// Displays sun (light), moon (dark), or monitor (system) icons.
///
/// When [showSystemOption] is `true` (the default), tapping opens a popover
/// with three options (light, dark, system). When `false`, tapping cycles
/// between light and dark only.
///
/// Includes a tooltip showing the current mode label.
///
/// Composes [OiIconButton], [OiIcon], [OiPopover], and [OiTooltip].
///
/// {@category Navigation}
class OiThemeToggle extends StatefulWidget {
  /// Creates an [OiThemeToggle].
  const OiThemeToggle({
    required this.currentMode,
    required this.onModeChange,
    this.label = 'Toggle theme',
    this.showSystemOption = true,
    super.key,
  });

  /// The currently active theme mode.
  final OiThemeMode currentMode;

  /// Called when the user selects a new theme mode.
  final ValueChanged<OiThemeMode>? onModeChange;

  /// Accessible label for screen readers.
  final String label;

  /// When `true`, shows a popover with light / dark / system options.
  /// When `false`, tapping cycles between light and dark.
  final bool showSystemOption;

  @override
  State<OiThemeToggle> createState() => _OiThemeToggleState();
}

class _OiThemeToggleState extends State<OiThemeToggle> {
  bool _isOpen = false;

  static IconData _iconForMode(OiThemeMode mode) => switch (mode) {
    OiThemeMode.light => OiIcons.lightMode,
    OiThemeMode.dark => OiIcons.darkMode,
    OiThemeMode.system => OiIcons.monitor,
  };

  static String _labelForMode(OiThemeMode mode) => switch (mode) {
    OiThemeMode.light => 'Light mode',
    OiThemeMode.dark => 'Dark mode',
    OiThemeMode.system => 'System mode',
  };

  static OiThemeMode _nextMode(OiThemeMode current) => switch (current) {
    OiThemeMode.light => OiThemeMode.dark,
    OiThemeMode.dark => OiThemeMode.light,
    OiThemeMode.system => OiThemeMode.light,
  };

  void _handleCycle() {
    widget.onModeChange?.call(_nextMode(widget.currentMode));
  }

  void _handleSelect(OiThemeMode mode) {
    setState(() => _isOpen = false);
    widget.onModeChange?.call(mode);
  }

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final currentLabel = _labelForMode(widget.currentMode);

    final iconButton = OiIconButton(
      icon: _iconForMode(widget.currentMode),
      semanticLabel: widget.label,
      onTap: widget.onModeChange == null
          ? null
          : widget.showSystemOption
          ? () => setState(() => _isOpen = !_isOpen)
          : _handleCycle,
      enabled: widget.onModeChange != null,
    );

    if (!widget.showSystemOption) {
      return OiTooltip(
        label: widget.label,
        message: currentLabel,
        child: iconButton,
      );
    }

    return OiTooltip(
      label: widget.label,
      message: currentLabel,
      child: OiPopover(
        label: widget.label,
        open: _isOpen,
        onClose: () => setState(() => _isOpen = false),
        anchor: iconButton,
        content: UnconstrainedBox(
          alignment: Alignment.topLeft,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 160, maxWidth: 260),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: spacing.xs),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final mode in OiThemeMode.values)
                    OiListTile(
                      title: _labelForMode(mode),
                      leading: OiIcon.decorative(icon: _iconForMode(mode)),
                      selected: mode == widget.currentMode,
                      onTap: () => _handleSelect(mode),
                      dense: true,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
