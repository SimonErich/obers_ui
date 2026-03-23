import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/buttons/oi_button.dart';
import 'package:obers_ui/src/foundation/oi_icons.dart';
import 'package:obers_ui/src/foundation/oi_responsive.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/display/oi_label.dart';
import 'package:obers_ui/src/primitives/layout/oi_container.dart';

/// A full-page error display for 404, 403, 500, and custom errors.
///
/// Shows an optional illustration area, a large [errorCode], a [title],
/// an optional [description], and an optional action button.
///
/// Use the factory constructors for common HTTP error pages:
/// - [OiErrorPage.notFound] — 404
/// - [OiErrorPage.forbidden] — 403
/// - [OiErrorPage.serverError] — 500
///
/// {@category Composites}
///
/// Coverage: REQ-0016
class OiErrorPage extends StatelessWidget {
  /// Creates an [OiErrorPage].
  const OiErrorPage({
    required this.title,
    required this.label,
    this.description,
    this.errorCode,
    this.illustration,
    this.icon,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  /// Creates a "Page not found" error page (404).
  factory OiErrorPage.notFound({
    String? title,
    String? label,
    String? description,
    String? actionLabel,
    VoidCallback? onAction,
    Key? key,
  }) {
    return OiErrorPage(
      key: key,
      title: title ?? 'Page not found',
      label: label ?? 'Page not found',
      description:
          description ?? 'The page you are looking for does not exist.',
      errorCode: '404',
      icon: OiIcons.search, // search_off
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  /// Creates an "Access denied" error page (403).
  factory OiErrorPage.forbidden({
    String? title,
    String? label,
    String? description,
    String? actionLabel,
    VoidCallback? onAction,
    Key? key,
  }) {
    return OiErrorPage(
      key: key,
      title: title ?? 'Access denied',
      label: label ?? 'Access denied',
      description:
          description ?? 'You do not have permission to view this page.',
      errorCode: '403',
      icon: OiIcons.lock, // lock
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  /// Creates a "Something went wrong" error page (500).
  factory OiErrorPage.serverError({
    String? title,
    String? label,
    String? description,
    String? actionLabel,
    VoidCallback? onAction,
    Key? key,
  }) {
    return OiErrorPage(
      key: key,
      title: title ?? 'Something went wrong',
      label: label ?? 'Something went wrong',
      description: description ?? 'An unexpected error occurred on the server.',
      errorCode: '500',
      icon: OiIcons.circleAlert, // error
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  /// The primary title text displayed below the error code.
  final String title;

  /// Accessibility label for the error page.
  final String label;

  /// Optional descriptive text rendered below the title.
  final String? description;

  /// An optional large error code displayed prominently (e.g. '404').
  final String? errorCode;

  /// An optional custom illustration widget shown above the error code.
  ///
  /// Takes priority over [icon].
  final Widget? illustration;

  /// An optional icon shown when no [illustration] is provided.
  final IconData? icon;

  /// The label for the action button. When `null` no button is shown.
  final String? actionLabel;

  /// Called when the action button is tapped.
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final bp = context.breakpoint;

    return Semantics(
      label: label,
      container: true,
      child: OiContainer(
        breakpoint: bp,
        maxWidth: const OiResponsive<double>(480),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildIllustration(context),
                _buildErrorCode(context),
                _buildContent(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIllustration(BuildContext context) {
    final colors = context.colors;

    if (illustration != null) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: illustration,
      );
    }

    if (icon != null) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: Icon(icon, size: 64, color: colors.textMuted),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildErrorCode(BuildContext context) {
    if (errorCode == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: OiLabel.display(errorCode!),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        OiLabel.h4(title, textAlign: TextAlign.center),
        if (description != null) ...[
          const SizedBox(height: 8),
          OiLabel.small(description!, textAlign: TextAlign.center),
        ],
        if (actionLabel != null && onAction != null) ...[
          const SizedBox(height: 24),
          OiButton.primary(
            label: actionLabel!,
            onTap: onAction,
            semanticLabel: actionLabel,
          ),
        ],
      ],
    );
  }
}
