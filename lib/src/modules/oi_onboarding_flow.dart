import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/buttons/oi_button.dart';
import 'package:obers_ui/src/components/display/oi_page_indicator.dart';
import 'package:obers_ui/src/foundation/oi_responsive.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/display/oi_label.dart';
import 'package:obers_ui/src/primitives/layout/oi_column.dart';
import 'package:obers_ui/src/primitives/layout/oi_row.dart';

// ── Data model ──────────────────────────────────────────────────────────────

/// A single page in an onboarding flow.
///
/// Each page has a required [title] and [description], an optional
/// [illustration] widget (rendered above the text), and an optional per-page
/// action button via [actionLabel] / [onAction].
///
/// {@category Modules}
@immutable
class OiOnboardingPage {
  /// Creates an [OiOnboardingPage].
  const OiOnboardingPage({
    required this.title,
    required this.description,
    this.illustration,
    this.actionLabel,
    this.onAction,
  });

  /// The heading displayed prominently on the page.
  final String title;

  /// A short explanatory paragraph shown below the title.
  final String description;

  /// An optional widget rendered above the text content (e.g. an image,
  /// icon, or Lottie animation).
  final Widget? illustration;

  /// Label for an optional call-to-action button shown below the description.
  final String? actionLabel;

  /// Callback for the optional per-page action button.
  final VoidCallback? onAction;
}

// ── Main widget ─────────────────────────────────────────────────────────────

/// A multi-page onboarding flow with illustrations, progress dots, and
/// skip/next/done navigation.
///
/// Pages are defined as a list of [OiOnboardingPage] objects. The widget
/// manages its own page state via a [PageController] and exposes callbacks
/// for [onComplete], [onSkip], and [onPageChange].
///
/// ```dart
/// OiOnboardingFlow(
///   label: 'Welcome onboarding',
///   pages: [
///     OiOnboardingPage(title: 'Welcome', description: 'Get started'),
///     OiOnboardingPage(title: 'Features', description: 'Explore'),
///     OiOnboardingPage(title: 'Ready', description: 'Let us go!'),
///   ],
///   onComplete: () => Navigator.of(context).pushReplacementNamed('/home'),
/// )
/// ```
///
/// {@category Modules}
class OiOnboardingFlow extends StatefulWidget {
  /// Creates an [OiOnboardingFlow].
  const OiOnboardingFlow({
    required this.pages,
    required this.label,
    this.onComplete,
    this.onSkip,
    this.onPageChange,
    this.skipLabel = 'Skip',
    this.nextLabel = 'Next',
    this.doneLabel = 'Get Started',
    this.showSkip = true,
    this.showPageIndicator = true,
    this.maxWidth = 600,
    super.key,
  });

  /// The onboarding pages to display.
  final List<OiOnboardingPage> pages;

  /// Accessibility label announced by screen readers.
  final String label;

  /// Called when the user completes the flow (taps the done button on the
  /// last page).
  final VoidCallback? onComplete;

  /// Called when the user taps the skip button.
  final VoidCallback? onSkip;

  /// Called when the active page changes, with the new page index.
  final ValueChanged<int>? onPageChange;

  /// Text for the skip button. Defaults to `'Skip'`.
  final String skipLabel;

  /// Text for the next button. Defaults to `'Next'`.
  final String nextLabel;

  /// Text for the done button on the last page. Defaults to
  /// `'Get Started'`.
  final String doneLabel;

  /// Whether to show the skip button on non-final pages. Defaults to `true`.
  final bool showSkip;

  /// Whether to show the page indicator dots. Defaults to `true`.
  final bool showPageIndicator;

  /// Maximum width of the onboarding content. Defaults to `600`.
  final double maxWidth;

  @override
  State<OiOnboardingFlow> createState() => _OiOnboardingFlowState();
}

class _OiOnboardingFlowState extends State<OiOnboardingFlow> {
  late final PageController _pageController;
  int _currentPage = 0;

  bool get _isLastPage => _currentPage == widget.pages.length - 1;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Navigation
  // ---------------------------------------------------------------------------

  void _nextPage() {
    if (_isLastPage) return;
    final next = _currentPage + 1;
    unawaited(
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      ),
    );
    // onPageChanged from the PageView will update _currentPage and fire
    // the callback, but we also set it eagerly so the UI is responsive.
    setState(() => _currentPage = next);
    widget.onPageChange?.call(next);
  }

  void _skip() {
    widget.onSkip?.call();
  }

  void _done() {
    widget.onComplete?.call();
  }

  void _onPageChanged(int index) {
    setState(() => _currentPage = index);
    widget.onPageChange?.call(index);
  }

  // ---------------------------------------------------------------------------
  // Build helpers
  // ---------------------------------------------------------------------------

  Widget _buildPage(BuildContext context, OiOnboardingPage page) {
    final sp = context.spacing;
    final colors = context.colors;
    final breakpoint = context.breakpoint;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: sp.md),
      child: OiColumn(
        breakpoint: breakpoint,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (page.illustration != null)
            Expanded(child: Center(child: page.illustration))
          else
            const Spacer(),
          SizedBox(height: sp.lg),
          OiLabel.h2(page.title, textAlign: TextAlign.center),
          SizedBox(height: sp.sm),
          OiLabel.body(
            page.description,
            textAlign: TextAlign.center,
            color: colors.textMuted,
          ),
          if (page.actionLabel != null && page.onAction != null) ...[
            SizedBox(height: sp.md),
            OiButton.ghost(label: page.actionLabel!, onTap: page.onAction),
          ],
          SizedBox(height: sp.lg),
        ],
      ),
    );
  }

  Widget _buildPageView(BuildContext context) {
    return PageView.builder(
      controller: _pageController,
      itemCount: widget.pages.length,
      onPageChanged: _onPageChanged,
      itemBuilder: (context, index) => _buildPage(context, widget.pages[index]),
    );
  }

  Widget _buildControls(BuildContext context) {
    final sp = context.spacing;
    final breakpoint = context.breakpoint;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: sp.md, vertical: sp.sm),
      child: OiRow(
        breakpoint: breakpoint,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: skip button (only on non-last pages if enabled).
          SizedBox(
            width: 80,
            child: (widget.showSkip && !_isLastPage)
                ? OiButton.ghost(label: widget.skipLabel, onTap: _skip)
                : const SizedBox.shrink(),
          ),

          // Center: page indicator dots.
          if (widget.showPageIndicator)
            OiPageIndicator(
              count: widget.pages.length,
              current: _currentPage,
              semanticLabel:
                  'Page ${_currentPage + 1} of ${widget.pages.length}',
            )
          else
            const SizedBox.shrink(),

          // Right: next or done button.
          SizedBox(
            width: 120,
            child: _isLastPage
                ? OiButton.primary(label: widget.doneLabel, onTap: _done)
                : OiButton.primary(label: widget.nextLabel, onTap: _nextPage),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: widget.label,
      container: true,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: widget.maxWidth),
          child: Column(
            children: [
              Expanded(child: _buildPageView(context)),
              _buildControls(context),
            ],
          ),
        ),
      ),
    );
  }
}
