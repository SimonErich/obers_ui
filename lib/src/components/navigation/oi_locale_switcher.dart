import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/buttons/oi_button.dart';
import 'package:obers_ui/src/components/display/oi_list_tile.dart';
import 'package:obers_ui/src/components/display/oi_popover.dart';
import 'package:obers_ui/src/foundation/oi_icons.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/display/oi_icon.dart';

/// A locale option for the [OiLocaleSwitcher].
///
/// {@category Components}
@immutable
class OiLocaleOption {
  /// Creates an [OiLocaleOption].
  const OiLocaleOption({
    required this.locale,
    required this.name,
    this.flagEmoji,
  });

  /// The locale represented by this option.
  final Locale locale;

  /// The display name of this locale (typically in its own language).
  final String name;

  /// An optional flag emoji (e.g. '🇺🇸').
  final String? flagEmoji;
}

/// A dropdown for switching the application locale.
///
/// The trigger button shows the flag and/or code for the current locale.
/// The dropdown displays all available locales with the active locale
/// highlighted by a check icon.
///
/// Composes [OiButton.ghost], [OiPopover], [OiListTile], [OiLabel],
/// and [OiIcon].
///
/// {@category Navigation}
class OiLocaleSwitcher extends StatefulWidget {
  /// Creates an [OiLocaleSwitcher].
  const OiLocaleSwitcher({
    required this.currentLocale,
    required this.locales,
    required this.onLocaleChange,
    this.label = 'Language',
    this.showFlag = true,
    this.showCode = false,
    this.showName = true,
    super.key,
  });

  /// The currently active locale.
  final Locale currentLocale;

  /// The list of available locale options.
  final List<OiLocaleOption> locales;

  /// Called when the user selects a new locale.
  final ValueChanged<Locale>? onLocaleChange;

  /// Accessible label for screen readers.
  final String label;

  /// Whether to show the flag emoji in the trigger and dropdown.
  final bool showFlag;

  /// Whether to show the locale code (e.g. 'EN') in the trigger and dropdown.
  final bool showCode;

  /// Whether to show the locale display name (e.g. 'English') in the dropdown.
  final bool showName;

  @override
  State<OiLocaleSwitcher> createState() => _OiLocaleSwitcherState();
}

class _OiLocaleSwitcherState extends State<OiLocaleSwitcher> {
  bool _isOpen = false;

  OiLocaleOption _currentOption() {
    final index = widget.locales.indexWhere(
      (o) => o.locale == widget.currentLocale,
    );
    if (index >= 0) return widget.locales[index];
    if (widget.locales.isNotEmpty) return widget.locales.first;
    return OiLocaleOption(
      locale: widget.currentLocale,
      name: widget.currentLocale.languageCode.toUpperCase(),
    );
  }

  String _triggerLabel(OiLocaleOption option) {
    final parts = <String>[];
    if (widget.showFlag && option.flagEmoji != null) {
      parts.add(option.flagEmoji!);
    }
    if (widget.showCode) {
      parts.add(option.locale.languageCode.toUpperCase());
    }
    // If nothing visible, show the locale code as minimum.
    if (parts.isEmpty) {
      parts.add(option.locale.languageCode.toUpperCase());
    }
    return parts.join(' ');
  }

  String _itemLabel(OiLocaleOption option) {
    final parts = <String>[];
    if (widget.showFlag && option.flagEmoji != null) {
      parts.add(option.flagEmoji!);
    }
    if (widget.showCode) {
      parts.add(option.locale.languageCode.toUpperCase());
    }
    if (widget.showName) {
      parts.add(option.name);
    }
    if (parts.isEmpty) {
      parts.add(option.locale.languageCode.toUpperCase());
    }
    return parts.join(' ');
  }

  void _handleSelect(OiLocaleOption option) {
    setState(() => _isOpen = false);
    widget.onLocaleChange?.call(option.locale);
  }

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final current = _currentOption();
    final isDisabled = widget.locales.isEmpty || widget.onLocaleChange == null;

    final trigger = OiButton.ghost(
      label: _triggerLabel(current),
      icon: OiIcons.language,
      semanticLabel: widget.label,
      onTap: isDisabled ? null : () => setState(() => _isOpen = !_isOpen),
      enabled: !isDisabled,
    );

    if (isDisabled) return trigger;

    return OiPopover(
      label: widget.label,
      open: _isOpen,
      onClose: () => setState(() => _isOpen = false),
      anchor: trigger,
      content: UnconstrainedBox(
        alignment: Alignment.topLeft,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 160, maxWidth: 260),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: spacing.xs),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final option in widget.locales)
                  OiListTile(
                    title: _itemLabel(option),
                    selected: option.locale == widget.currentLocale,
                    trailing: option.locale == widget.currentLocale
                        ? const OiIcon.decorative(icon: OiIcons.check)
                        : null,
                    onTap: () => _handleSelect(option),
                    dense: true,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
