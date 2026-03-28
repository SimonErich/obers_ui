import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/buttons/oi_button.dart';
import 'package:obers_ui/src/foundation/oi_icons.dart';
import 'package:obers_ui/src/foundation/oi_responsive.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/display/oi_label.dart';
import 'package:obers_ui/src/primitives/layout/oi_container.dart';

// ---------------------------------------------------------------------------
// Data classes
// ---------------------------------------------------------------------------

/// A social link displayed on an [OiMaintenancePage].
///
/// {@category Modules}
@immutable
class OiSocialLink {
  /// Creates an [OiSocialLink].
  const OiSocialLink({required this.label, required this.onTap, this.icon});

  /// The accessible label for this link.
  final String label;

  /// Called when the link is tapped.
  final VoidCallback onTap;

  /// An optional icon displayed next to the label.
  final IconData? icon;
}

// ---------------------------------------------------------------------------
// Main widget
// ---------------------------------------------------------------------------

/// A full-page maintenance, downtime, or error display.
///
/// Shows an illustration, title, description, optional countdown timer,
/// retry button, status page link, and social links.
///
/// Use factory constructors for common scenarios:
/// - [OiMaintenancePage.maintenance] -- scheduled maintenance
/// - [OiMaintenancePage.notFound] -- 404 page
/// - [OiMaintenancePage.serverError] -- 500 server error
/// - [OiMaintenancePage.offline] -- no connectivity
///
/// {@category Modules}
class OiMaintenancePage extends StatefulWidget {
  /// Creates an [OiMaintenancePage].
  const OiMaintenancePage({
    required this.title,
    required this.label,
    this.description,
    this.illustration,
    this.icon,
    this.estimatedReturn,
    this.showCountdown = true,
    this.statusPageUrl,
    this.statusPageLabel = 'Status Page',
    this.onStatusPageTap,
    this.onRetry,
    this.retryLabel = 'Try Again',
    this.socialLinks = const [],
    this.maxWidth = 480,
    super.key,
  });

  /// Creates a scheduled-maintenance page.
  factory OiMaintenancePage.maintenance({
    String? title,
    String? label,
    String? description,
    DateTime? estimatedReturn,
    bool showCountdown = true,
    String? statusPageUrl,
    String statusPageLabel = 'Status Page',
    VoidCallback? onStatusPageTap,
    VoidCallback? onRetry,
    String retryLabel = 'Try Again',
    List<OiSocialLink> socialLinks = const [],
    double maxWidth = 480,
    Key? key,
  }) {
    return OiMaintenancePage(
      key: key,
      title: title ?? "We'll be back soon",
      label: label ?? 'Scheduled maintenance',
      description: description ?? "We're performing scheduled maintenance.",
      icon: OiIcons.construction,
      estimatedReturn: estimatedReturn,
      showCountdown: showCountdown,
      statusPageUrl: statusPageUrl,
      statusPageLabel: statusPageLabel,
      onStatusPageTap: onStatusPageTap,
      onRetry: onRetry,
      retryLabel: retryLabel,
      socialLinks: socialLinks,
      maxWidth: maxWidth,
    );
  }

  /// Creates a 404 not-found page.
  factory OiMaintenancePage.notFound({
    String? title,
    String? label,
    String? description,
    VoidCallback? onRetry,
    String retryLabel = 'Try Again',
    List<OiSocialLink> socialLinks = const [],
    double maxWidth = 480,
    Key? key,
  }) {
    return OiMaintenancePage(
      key: key,
      title: title ?? 'Page not found',
      label: label ?? 'Page not found',
      description:
          description ?? 'The page you are looking for does not exist.',
      icon: OiIcons.search,
      onRetry: onRetry,
      retryLabel: retryLabel,
      socialLinks: socialLinks,
      maxWidth: maxWidth,
    );
  }

  /// Creates a 500 server-error page.
  factory OiMaintenancePage.serverError({
    String? title,
    String? label,
    String? description,
    VoidCallback? onRetry,
    String retryLabel = 'Try Again',
    String? statusPageUrl,
    String statusPageLabel = 'Status Page',
    VoidCallback? onStatusPageTap,
    List<OiSocialLink> socialLinks = const [],
    double maxWidth = 480,
    Key? key,
  }) {
    return OiMaintenancePage(
      key: key,
      title: title ?? 'Something went wrong',
      label: label ?? 'Server error',
      description: description ?? 'An unexpected error occurred.',
      icon: OiIcons.serverCrash,
      statusPageUrl: statusPageUrl,
      statusPageLabel: statusPageLabel,
      onStatusPageTap: onStatusPageTap,
      onRetry: onRetry,
      retryLabel: retryLabel,
      socialLinks: socialLinks,
      maxWidth: maxWidth,
    );
  }

  /// Creates an offline / no-connectivity page.
  factory OiMaintenancePage.offline({
    String? title,
    String? label,
    String? description,
    VoidCallback? onRetry,
    String retryLabel = 'Try Again',
    List<OiSocialLink> socialLinks = const [],
    double maxWidth = 480,
    Key? key,
  }) {
    return OiMaintenancePage(
      key: key,
      title: title ?? "You're offline",
      label: label ?? 'No internet connection',
      description:
          description ?? 'Check your internet connection and try again.',
      icon: OiIcons.wifiOff,
      onRetry: onRetry,
      retryLabel: retryLabel,
      socialLinks: socialLinks,
      maxWidth: maxWidth,
    );
  }

  /// The primary title text.
  final String title;

  /// Accessibility label for the page.
  final String label;

  /// Optional descriptive text rendered below the title.
  final String? description;

  /// An optional custom illustration widget shown above the title.
  ///
  /// Takes priority over [icon].
  final Widget? illustration;

  /// An optional icon shown when no [illustration] is provided.
  final IconData? icon;

  /// An optional estimated return time for the countdown.
  final DateTime? estimatedReturn;

  /// Whether to display the countdown when [estimatedReturn] is set.
  final bool showCountdown;

  /// An optional URL to a status page (stored for consumers).
  final String? statusPageUrl;

  /// The display label for the status-page link button.
  final String statusPageLabel;

  /// Called when the status-page button is tapped.
  final VoidCallback? onStatusPageTap;

  /// Called when the retry button is tapped. When `null` no retry button
  /// is shown.
  final VoidCallback? onRetry;

  /// The label for the retry button.
  final String retryLabel;

  /// Optional social links displayed at the bottom of the page.
  final List<OiSocialLink> socialLinks;

  /// Maximum width of the content area.
  final double maxWidth;

  @override
  State<OiMaintenancePage> createState() => _OiMaintenancePageState();
}

class _OiMaintenancePageState extends State<OiMaintenancePage> {
  Timer? _timer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _startCountdownIfNeeded();
  }

  @override
  void didUpdateWidget(OiMaintenancePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.estimatedReturn != widget.estimatedReturn ||
        oldWidget.showCountdown != widget.showCountdown) {
      _timer?.cancel();
      _timer = null;
      _startCountdownIfNeeded();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startCountdownIfNeeded() {
    if (!widget.showCountdown || widget.estimatedReturn == null) return;

    _updateRemaining();

    if (_remaining > Duration.zero) {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        _updateRemaining();
        if (_remaining <= Duration.zero) {
          _timer?.cancel();
          _timer = null;
        }
      });
    }
  }

  void _updateRemaining() {
    final now = DateTime.now();
    setState(() {
      final diff = widget.estimatedReturn!.difference(now);
      _remaining = diff.isNegative ? Duration.zero : diff;
    });
  }

  // ── Build ──────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final bp = context.breakpoint;
    final sp = context.spacing;

    return Semantics(
      label: widget.label,
      container: true,
      child: OiContainer(
        breakpoint: bp,
        maxWidth: OiResponsive<double>(widget.maxWidth),
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(sp.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildIllustration(context),
                _buildContent(context),
                if (_shouldShowCountdown) ...[
                  SizedBox(height: sp.md),
                  _buildCountdown(context),
                ],
                _buildActions(context),
                if (widget.socialLinks.isNotEmpty) ...[
                  SizedBox(height: sp.lg),
                  _buildSocialLinks(context),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool get _shouldShowCountdown =>
      widget.showCountdown && widget.estimatedReturn != null;

  Widget _buildIllustration(BuildContext context) {
    final colors = context.colors;
    final sp = context.spacing;

    if (widget.illustration != null) {
      return Padding(
        padding: EdgeInsets.only(bottom: sp.lg),
        child: widget.illustration,
      );
    }

    if (widget.icon != null) {
      return Padding(
        padding: EdgeInsets.only(bottom: sp.lg),
        child: Icon(widget.icon, size: 64, color: colors.textMuted),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildContent(BuildContext context) {
    final sp = context.spacing;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        OiLabel.h3(widget.title, textAlign: TextAlign.center),
        if (widget.description != null) ...[
          SizedBox(height: sp.sm),
          OiLabel.small(widget.description!, textAlign: TextAlign.center),
        ],
      ],
    );
  }

  Widget _buildCountdown(BuildContext context) {
    final colors = context.colors;
    final sp = context.spacing;

    final String text;
    if (_remaining <= Duration.zero) {
      text = 'Back any moment now...';
    } else {
      final hours = _remaining.inHours;
      final minutes = _remaining.inMinutes.remainder(60);
      final seconds = _remaining.inSeconds.remainder(60);

      if (hours > 0) {
        text = 'Returning in ${hours}h ${minutes}m';
      } else {
        text = 'Returning in ${minutes}m ${seconds}s';
      }
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(OiIcons.clock, size: 14, color: colors.textMuted),
        SizedBox(width: sp.xs),
        OiLabel.small(text, color: colors.textMuted),
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    final hasRetry = widget.onRetry != null;
    final hasStatusPage = widget.onStatusPageTap != null;
    final sp = context.spacing;

    if (!hasRetry && !hasStatusPage) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.only(top: sp.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasRetry)
            OiButton.primary(
              label: widget.retryLabel,
              onTap: widget.onRetry,
              semanticLabel: widget.retryLabel,
            ),
          if (hasRetry && hasStatusPage) SizedBox(height: sp.sm),
          if (hasStatusPage)
            OiButton.ghost(
              label: widget.statusPageLabel,
              onTap: widget.onStatusPageTap,
              semanticLabel: widget.statusPageLabel,
            ),
        ],
      ),
    );
  }

  Widget _buildSocialLinks(BuildContext context) {
    final colors = context.colors;
    final sp = context.spacing;

    return Wrap(
      spacing: sp.md,
      runSpacing: sp.sm,
      alignment: WrapAlignment.center,
      children: [
        for (final link in widget.socialLinks)
          Semantics(
            label: link.label,
            button: true,
            child: GestureDetector(
              onTap: link.onTap,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: EdgeInsets.all(sp.xs),
                child: link.icon != null
                    ? Icon(link.icon, size: 20, color: colors.textMuted)
                    : OiLabel.small(link.label, color: colors.textMuted),
              ),
            ),
          ),
      ],
    );
  }
}
