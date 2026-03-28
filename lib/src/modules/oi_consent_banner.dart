import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/buttons/oi_button.dart';
import 'package:obers_ui/src/components/display/oi_badge.dart';
import 'package:obers_ui/src/components/inputs/oi_switch_tile.dart';
import 'package:obers_ui/src/components/overlays/oi_dialog.dart';
import 'package:obers_ui/src/foundation/oi_icons.dart';
import 'package:obers_ui/src/foundation/oi_overlays.dart';
import 'package:obers_ui/src/foundation/oi_responsive.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/display/oi_divider.dart';
import 'package:obers_ui/src/primitives/display/oi_label.dart';
import 'package:obers_ui/src/primitives/display/oi_surface.dart';

// ---------------------------------------------------------------------------
// Data classes
// ---------------------------------------------------------------------------

/// A consent category in an [OiConsentBanner].
///
/// Each category represents a group of cookies or tracking mechanisms the
/// user can opt in or out of (e.g. "Analytics", "Marketing").
///
/// {@category Modules}
@immutable
class OiConsentCategory {
  /// Creates an [OiConsentCategory].
  const OiConsentCategory({
    required this.key,
    required this.name,
    required this.description,
    this.required = false,
    this.defaultValue = false,
  });

  /// Unique identifier for this category (e.g. `'analytics'`).
  final String key;

  /// Display name shown to the user (e.g. "Analytics").
  final String name;

  /// Description of what this category covers.
  final String description;

  /// Whether this category is required and cannot be toggled off.
  ///
  /// Required categories are always enabled and the switch is locked.
  final bool required;

  /// Default consent value for this category when no prior preference exists.
  final bool defaultValue;
}

/// Position of the consent banner on screen.
///
/// {@category Modules}
enum OiConsentPosition {
  /// Banner slides in from the top.
  top,

  /// Banner slides in from the bottom.
  bottom,
}

// ---------------------------------------------------------------------------
// OiConsentBanner
// ---------------------------------------------------------------------------

/// A GDPR / cookie consent banner with an optional preferences dialog.
///
/// Displays a dismissible banner at the [position] edge of the screen with
/// accept-all, reject-all, and manage-preferences actions. The preferences
/// dialog lists each [OiConsentCategory] with an [OiSwitchTile] toggle.
/// Required categories are locked on and cannot be toggled off.
///
/// Use [OiConsentBanner.minimal] for a simplified two-button variant without
/// the manage-preferences action.
///
/// {@category Modules}
class OiConsentBanner extends StatefulWidget {
  /// Creates an [OiConsentBanner].
  const OiConsentBanner({
    required this.categories,
    required this.label,
    this.title = 'We use cookies',
    this.description,
    this.privacyPolicyLabel = 'Privacy Policy',
    this.onAcceptAll,
    this.onRejectAll,
    this.onSavePreferences,
    this.onPrivacyPolicyTap,
    this.acceptAllLabel = 'Accept All',
    this.rejectAllLabel = 'Reject All',
    this.manageLabel = 'Manage Preferences',
    this.visible = true,
    this.position = OiConsentPosition.bottom,
    this.maxWidth = 960,
    super.key,
  }) : _showManage = true;

  /// Creates a minimal consent banner without the manage-preferences button.
  ///
  /// Only shows accept-all and reject-all actions.
  const OiConsentBanner.minimal({
    required this.categories,
    required this.label,
    this.title = 'We use cookies',
    this.description,
    this.onAcceptAll,
    this.onRejectAll,
    this.onPrivacyPolicyTap,
    this.position = OiConsentPosition.bottom,
    this.maxWidth = 960,
    this.visible = true,
    super.key,
  }) : privacyPolicyLabel = 'Privacy Policy',
       onSavePreferences = null,
       acceptAllLabel = 'Accept All',
       rejectAllLabel = 'Reject All',
       manageLabel = 'Manage Preferences',
       _showManage = false;

  /// The consent categories the user can opt in or out of.
  final List<OiConsentCategory> categories;

  /// Accessibility label announced by screen readers.
  final String label;

  /// Banner heading text.
  final String title;

  /// Optional description shown below the title.
  final String? description;

  /// Label for the privacy policy link.
  final String privacyPolicyLabel;

  /// Called when the user accepts all categories.
  final VoidCallback? onAcceptAll;

  /// Called when the user rejects all non-required categories.
  final VoidCallback? onRejectAll;

  /// Called when the user saves individual preferences from the dialog.
  ///
  /// Receives a map of category key to consent boolean.
  final void Function(Map<String, bool>)? onSavePreferences;

  /// Called when the privacy policy link is tapped.
  final VoidCallback? onPrivacyPolicyTap;

  /// Label for the accept-all button.
  final String acceptAllLabel;

  /// Label for the reject-all button.
  final String rejectAllLabel;

  /// Label for the manage-preferences button.
  final String manageLabel;

  /// Whether the banner is visible.
  ///
  /// When `false` the banner is hidden with an exit animation.
  final bool visible;

  /// Where the banner is positioned on screen.
  final OiConsentPosition position;

  /// Maximum width of the banner content area.
  final double maxWidth;

  /// Whether the manage-preferences button is shown.
  final bool _showManage;

  @override
  State<OiConsentBanner> createState() => _OiConsentBannerState();
}

class _OiConsentBannerState extends State<OiConsentBanner> {
  late Map<String, bool> _preferences;
  OiOverlayHandle? _dialogHandle;

  @override
  void initState() {
    super.initState();
    _initPreferences();
  }

  @override
  void didUpdateWidget(OiConsentBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.categories != widget.categories) {
      _initPreferences();
    }
  }

  @override
  void dispose() {
    _dialogHandle?.dismiss();
    super.dispose();
  }

  void _initPreferences() {
    _preferences = {
      for (final cat in widget.categories)
        cat.key: cat.required || cat.defaultValue,
    };
  }

  void _handleAcceptAll() {
    setState(() {
      for (final cat in widget.categories) {
        _preferences[cat.key] = true;
      }
    });
    widget.onAcceptAll?.call();
  }

  void _handleRejectAll() {
    setState(() {
      for (final cat in widget.categories) {
        _preferences[cat.key] = cat.required;
      }
    });
    widget.onRejectAll?.call();
  }

  void _handleSavePreferences() {
    _dialogHandle?.dismiss();
    _dialogHandle = null;
    widget.onSavePreferences?.call(Map<String, bool>.from(_preferences));
  }

  void _showPreferencesDialog() {
    _dialogHandle = OiDialog.show(
      context,
      label: 'Consent preferences',
      dialog: _ConsentPreferencesDialog(
        categories: widget.categories,
        preferences: Map<String, bool>.from(_preferences),
        onSave: (prefs) {
          setState(() => _preferences = prefs);
          _handleSavePreferences();
        },
        onCancel: () {
          _dialogHandle?.dismiss();
          _dialogHandle = null;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTop = widget.position == OiConsentPosition.top;
    final slideOffset = isTop ? const Offset(0, -1) : const Offset(0, 1);
    final targetOffset = widget.visible ? Offset.zero : slideOffset;
    final alignment = isTop ? Alignment.topCenter : Alignment.bottomCenter;

    return Semantics(
      label: widget.label,
      container: true,
      child: Align(
        alignment: alignment,
        child: AnimatedSlide(
          offset: targetOffset,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
          child: AnimatedOpacity(
            opacity: widget.visible ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 250),
            child: widget.visible
                ? _buildBanner(context)
                : const SizedBox.shrink(),
          ),
        ),
      ),
    );
  }

  Widget _buildBanner(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final radius = context.radius;
    final shadows = context.shadows;

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: widget.maxWidth),
      child: Padding(
        padding: EdgeInsets.all(spacing.md),
        child: OiSurface(
          color: colors.surface,
          borderRadius: radius.lg,
          shadow: shadows.md,
          padding: EdgeInsets.all(spacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title row with cookie icon
              Row(
                children: [
                  Icon(OiIcons.cookie, size: 20, color: colors.text),
                  SizedBox(width: spacing.sm),
                  Expanded(child: OiLabel.h4(widget.title, color: colors.text)),
                ],
              ),

              // Description
              if (widget.description != null) ...[
                SizedBox(height: spacing.sm),
                OiLabel.body(widget.description!, color: colors.textMuted),
              ],

              // Privacy policy link
              if (widget.onPrivacyPolicyTap != null) ...[
                SizedBox(height: spacing.sm),
                Semantics(
                  button: true,
                  label: widget.privacyPolicyLabel,
                  child: GestureDetector(
                    onTap: widget.onPrivacyPolicyTap,
                    child: OiLabel.link(
                      widget.privacyPolicyLabel,
                      color: colors.primary.base,
                    ),
                  ),
                ),
              ],

              SizedBox(height: spacing.md),

              // Buttons
              _buildButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButtons(BuildContext context) {
    final breakpoint = context.breakpoint;
    final isCompact = breakpoint.minWidth < OiBreakpoint.expanded.minWidth;

    final acceptButton = OiButton.primary(
      label: widget.acceptAllLabel,
      onTap: _handleAcceptAll,
    );

    final rejectButton = OiButton.ghost(
      label: widget.rejectAllLabel,
      onTap: _handleRejectAll,
    );

    final manageButton = widget._showManage
        ? OiButton.ghost(
            label: widget.manageLabel,
            icon: OiIcons.settings,
            onTap: _showPreferencesDialog,
          )
        : null;

    final buttons = [
      acceptButton,
      rejectButton,
      if (manageButton != null) manageButton,
    ];

    if (isCompact) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < buttons.length; i++) ...[
            if (i > 0) SizedBox(height: context.spacing.xs),
            buttons[i],
          ],
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        for (var i = 0; i < buttons.length; i++) ...[
          if (i > 0) SizedBox(width: context.spacing.sm),
          buttons[i],
        ],
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Preferences dialog (private)
// ---------------------------------------------------------------------------

class _ConsentPreferencesDialog extends StatefulWidget {
  const _ConsentPreferencesDialog({
    required this.categories,
    required this.preferences,
    required this.onSave,
    required this.onCancel,
  });

  final List<OiConsentCategory> categories;
  final Map<String, bool> preferences;
  final void Function(Map<String, bool>) onSave;
  final VoidCallback onCancel;

  @override
  State<_ConsentPreferencesDialog> createState() =>
      _ConsentPreferencesDialogState();
}

class _ConsentPreferencesDialogState extends State<_ConsentPreferencesDialog> {
  late Map<String, bool> _localPrefs;

  @override
  void initState() {
    super.initState();
    _localPrefs = Map<String, bool>.from(widget.preferences);
  }

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;

    final categoryWidgets = <Widget>[];
    for (var i = 0; i < widget.categories.length; i++) {
      final cat = widget.categories[i];
      if (i > 0) {
        categoryWidgets.add(OiDivider(spacing: spacing.xs));
      }
      categoryWidgets.add(_buildCategoryTile(context, cat));
    }

    return OiDialog.form(
      label: 'Cookie preferences',
      title: 'Cookie Preferences',
      onClose: widget.onCancel,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          OiLabel.body(
            'Choose which cookies you want to allow. Required cookies '
            'cannot be disabled.',
            color: context.colors.textMuted,
          ),
          SizedBox(height: spacing.md),
          ...categoryWidgets,
        ],
      ),
      actions: [
        OiButton.ghost(label: 'Cancel', onTap: widget.onCancel),
        OiButton.primary(
          label: 'Save Preferences',
          onTap: () => widget.onSave(_localPrefs),
        ),
      ],
    );
  }

  Widget _buildCategoryTile(BuildContext context, OiConsentCategory cat) {
    final isRequired = cat.required;
    final isEnabled = _localPrefs[cat.key] ?? cat.defaultValue;
    final spacing = context.spacing;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: spacing.xs),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: OiSwitchTile(
                  title: cat.name,
                  subtitle: cat.description,
                  value: isRequired || isEnabled,
                  enabled: !isRequired,
                  onChanged: isRequired
                      ? (_) {}
                      : (value) {
                          setState(() => _localPrefs[cat.key] = value);
                        },
                  semanticLabel: '${cat.name} consent toggle',
                ),
              ),
              if (isRequired) ...[
                SizedBox(width: spacing.sm),
                const OiBadge.soft(
                  label: 'Required',
                  color: OiBadgeColor.neutral,
                  size: OiBadgeSize.small,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
