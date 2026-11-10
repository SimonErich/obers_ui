import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/buttons/oi_button/oi_button_size.dart';
import 'package:obers_ui/src/components/buttons/oi_button/oi_button_variant.dart';
import 'package:obers_ui/src/components/buttons/oi_button/oi_icon_position.dart';
import 'package:obers_ui/src/components/display/oi_tooltip.dart';
import 'package:obers_ui/src/foundation/oi_app.dart';
import 'package:obers_ui/src/foundation/oi_icons.dart';
import 'package:obers_ui/src/foundation/oi_responsive.dart';
import 'package:obers_ui/src/foundation/theme/component_themes/oi_button_theme_data.dart';
import 'package:obers_ui/src/foundation/theme/oi_component_themes.dart'
    show OiButtonThemeScope;
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/animation/oi_pulse.dart';
import 'package:obers_ui/src/primitives/display/oi_icon.dart';
import 'package:obers_ui/src/primitives/display/oi_label.dart';
import 'package:obers_ui/src/primitives/interaction/oi_tappable.dart';
import 'package:obers_ui/src/primitives/layout/oi_row.dart';
import 'package:obers_ui/src/primitives/overlay/oi_floating.dart';

export 'oi_button/oi_button_size.dart';
export 'oi_button/oi_button_variant.dart';
export 'oi_button/oi_icon_position.dart';
part 'oi_button/oi_button_base.part.dart';
part 'oi_button/oi_button_state.part.dart';
part 'oi_button/oi_button_content.part.dart';
part 'oi_button/oi_button_label.part.dart';
part 'oi_button/oi_button_standard.part.dart';
part 'oi_button/oi_button_ghost.part.dart';
part 'oi_button/oi_button_icon.part.dart';
part 'oi_button/oi_button_split.part.dart';
part 'oi_button/oi_button_countdown.part.dart';
part 'oi_button/oi_button_confirm.part.dart';
part 'oi_button/oi_button_geometry.part.dart';
part 'oi_button/oi_button_colors.part.dart';
part 'oi_button/oi_button_frame.part.dart';

/// A fully-featured button component for the Obers UI design system.
///
/// Supports six visual variants, three density-aware sizes, loading and
/// disabled states, leading/trailing icons, full-width layout, and four
/// specialized constructors:
///
/// - [OiButton.icon] — an icon-only square button.
/// - [OiButton.split] — a main action paired with a dropdown trigger.
/// - [OiButton.countdown] — auto-enables after a timer expires.
/// - [OiButton.confirm] — requires a second tap to confirm a destructive action.
///
/// **Accessibility (REQ-0019):** Every named constructor requires a `label`.
/// For [OiButton.icon], the label maps to `Semantics.label` so icon-only
/// buttons remain accessible to screen readers.
///
/// Uses [OiTappable] as the interaction layer, respects [OiDensityScope], and
/// reads colors, spacing, and radii from the nearest [OiTheme]. Existing
/// generative const constructors remain subclass-callable.
///
/// {@category Components}
class OiButton extends _OiButtonBase {
  /// Creates a primary-variant button.
  const OiButton.primary({
    required String super.label,
    super.labelMaxLines,
    super.onTap,
    super.size,
    super.enabled,
    super.loading,
    super.fullWidth,
    super.icon,
    super.iconPosition,
    super.semanticLabel,
    super.tooltip,
    super.key,
  }) : super(_OiButtonKind.standard, variant: OiButtonVariant.primary);

  /// Creates a secondary-variant button.
  const OiButton.secondary({
    required String super.label,
    super.labelMaxLines,
    super.onTap,
    super.size,
    super.enabled,
    super.loading,
    super.fullWidth,
    super.icon,
    super.iconPosition,
    super.semanticLabel,
    super.tooltip,
    super.key,
  }) : super(_OiButtonKind.standard, variant: OiButtonVariant.secondary);

  /// Creates an outline-variant button.
  const OiButton.outline({
    required String super.label,
    super.labelMaxLines,
    super.onTap,
    super.size,
    super.enabled,
    super.loading,
    super.fullWidth,
    super.icon,
    super.iconPosition,
    super.semanticLabel,
    super.tooltip,
    super.key,
  }) : super(_OiButtonKind.standard, variant: OiButtonVariant.outline);

  /// Creates a ghost-variant button.
  const OiButton.ghost({
    required String super.label,
    super.labelMaxLines,
    super.onTap,
    super.size,
    super.enabled,
    super.loading,
    super.fullWidth,
    super.icon,
    super.iconPosition,
    super.semanticLabel,
    super.borderRadius,
    super.key,
  }) : super(_OiButtonKind.standard, variant: OiButtonVariant.ghost);

  /// Creates a destructive-variant button.
  const OiButton.destructive({
    required String super.label,
    super.labelMaxLines,
    super.onTap,
    super.size,
    super.enabled,
    super.loading,
    super.fullWidth,
    super.icon,
    super.iconPosition,
    super.semanticLabel,
    super.key,
  }) : super(
         _OiButtonKind.standard,
         variant: OiButtonVariant.destructive,
       );

  /// Creates a soft-variant button.
  const OiButton.soft({
    required String super.label,
    super.labelMaxLines,
    super.onTap,
    super.size,
    super.enabled,
    super.loading,
    super.fullWidth,
    super.icon,
    super.iconPosition,
    super.semanticLabel,
    super.borderRadius,
    super.key,
  }) : super(_OiButtonKind.standard, variant: OiButtonVariant.soft);

  /// Creates an accessible square icon action.
  const OiButton.icon({
    required IconData super.icon,
    required String label,
    super.onTap,
    super.size,
    super.enabled,
    super.variant = OiButtonVariant.ghost,
    super.key,
  }) : super(_OiButtonKind.icon, semanticLabel: label);

  /// Creates a main action and a separate dropdown trigger.
  const OiButton.split({
    required String super.label,
    required VoidCallback super.onTap,
    required Widget super.dropdown,
    super.labelMaxLines,
    super.variant,
    super.size,
    super.enabled,
    super.key,
  }) : super(_OiButtonKind.split);

  /// Enables the action after the specified countdown.
  const OiButton.countdown({
    required String super.label,
    required VoidCallback super.onTap,
    required int seconds,
    super.labelMaxLines,
    super.variant,
    super.size,
    super.key,
  }) : super(_OiButtonKind.countdown, countdownSeconds: seconds);

  /// Requires a second tap to invoke the confirmation callback.
  const OiButton.confirm({
    required String super.label,
    required String super.confirmLabel,
    required VoidCallback super.onConfirm,
    super.labelMaxLines,
    super.variant = OiButtonVariant.destructive,
    super.size,
    super.key,
  }) : super(_OiButtonKind.confirm);

  @override
  State<OiButton> createState() => _OiButtonState();
}

OiButtonThemeData? _buttonTheme(BuildContext context) =>
    OiButtonThemeScope.resolve(context);
