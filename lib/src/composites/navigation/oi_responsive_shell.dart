import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/navigation/oi_bottom_bar.dart';
import 'package:obers_ui/src/components/navigation/oi_navigation_rail.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/models/oi_navigation_item.dart';

/// Configurable width breakpoints for [OiResponsiveShell] layout switching.
///
/// The shell uses two thresholds to transition between three navigation modes:
///
/// 1. Below [rail]: bottom bar (`OiBottomBar`)
/// 2. From [rail] to [expanded]: compact navigation rail (`OiNavigationRail`)
/// 3. At or above [expanded]: expanded navigation rail with labels
///
/// {@category Composites}
@immutable
class OiResponsiveShellBreakpoints {
  /// Creates breakpoint thresholds for [OiResponsiveShell].
  ///
  /// Both [rail] and [expanded] must be positive, and [expanded] must be
  /// greater than [rail].
  const OiResponsiveShellBreakpoints({
    this.rail = 600.0,
    this.expanded = 1200.0,
  })  : assert(rail > 0, 'rail must be positive'),
        assert(expanded > rail, 'expanded must be greater than rail');

  /// Viewport width at which the shell switches from a bottom bar to a
  /// navigation rail.
  final double rail;

  /// Viewport width at which the navigation rail switches to its expanded
  /// (labeled) variant.
  final double expanded;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OiResponsiveShellBreakpoints &&
        other.rail == rail &&
        other.expanded == expanded;
  }

  @override
  int get hashCode => Object.hash(rail, expanded);
}

/// The currently active navigation mode resolved by [OiResponsiveShell].
///
/// Exposed via [OiResponsiveShell.resolveMode] for testing and conditional
/// logic outside the shell itself.
///
/// {@category Composites}
enum OiResponsiveShellMode {
  /// A bottom bar is displayed (compact / mobile layout).
  bottomBar,

  /// A narrow navigation rail is displayed (medium / tablet layout).
  rail,

  /// An expanded navigation rail with visible labels is displayed
  /// (large / desktop layout).
  expandedRail,
}

/// A responsive navigation shell that automatically switches between
/// [OiBottomBar], [OiNavigationRail] (compact), and [OiNavigationRail]
/// (expanded with labels) based on the viewport width.
///
/// This widget unifies the three navigation components behind a single API
/// driven by [OiNavigationItem], so the consumer only needs to manage one
/// list of items.
///
/// ## Layout modes
///
/// | Viewport width         | Navigation widget                          |
/// |------------------------|--------------------------------------------|
/// | < rail threshold       | `OiBottomBar` at the bottom                |
/// | rail .. expanded       | `OiNavigationRail` (icon only)             |
/// | >= expanded threshold  | `OiNavigationRail` (icon + label)          |
///
/// ## Example
///
/// ```dart
/// OiResponsiveShell(
///   items: const [
///     OiNavigationItem(icon: OiIcons.house, label: 'Home'),
///     OiNavigationItem(icon: OiIcons.search, label: 'Search'),
///     OiNavigationItem(icon: OiIcons.user, label: 'Profile'),
///   ],
///   currentIndex: _selectedIndex,
///   onTap: (index) => setState(() => _selectedIndex = index),
///   body: _pages[_selectedIndex],
/// )
/// ```
///
/// {@category Composites}
class OiResponsiveShell extends StatelessWidget {
  /// Creates an [OiResponsiveShell].
  const OiResponsiveShell({
    required this.items,
    required this.currentIndex,
    required this.onTap,
    required this.body,
    this.railLeading,
    this.railTrailing,
    this.floatingAction,
    this.breakpoints = const OiResponsiveShellBreakpoints(),
    this.railWidth = 72,
    this.expandedRailWidth = 200,
    this.railBackgroundColor,
    this.railBorderColor,
    this.railIndicatorColor,
    this.railLabelBehavior,
    this.railGroupAlignment = -1.0,
    this.bottomBarStyle = OiBottomBarStyle.fixed,
    this.bottomBarShowLabels = true,
    this.bottomBarHaptic = false,
    this.semanticLabel,
    super.key,
  });

  /// The navigation items displayed across all layout modes.
  final List<OiNavigationItem> items;

  /// The index of the currently active item.
  final int currentIndex;

  /// Called when a navigation item is tapped.
  final ValueChanged<int> onTap;

  /// The main content area displayed beside or above the navigation.
  final Widget body;

  /// An optional widget displayed above the rail items (e.g. a logo).
  ///
  /// Only visible in the [OiNavigationRail] layouts (medium and expanded).
  final Widget? railLeading;

  /// An optional widget displayed below the rail items (e.g. a settings icon).
  ///
  /// Only visible in the [OiNavigationRail] layouts (medium and expanded).
  final Widget? railTrailing;

  /// An optional floating action widget.
  ///
  /// On the bottom-bar layout this is forwarded to [OiBottomBar.floatingAction].
  /// On rail layouts it is placed at the bottom of the rail trailing area.
  final Widget? floatingAction;

  /// Breakpoint thresholds that control which layout mode is active.
  final OiResponsiveShellBreakpoints breakpoints;

  /// Width of the navigation rail in compact mode (icon only).
  final double railWidth;

  /// Width of the navigation rail in expanded mode (icon + label).
  final double expandedRailWidth;

  /// Background color for the navigation rail.
  ///
  /// Passed directly to [OiNavigationRail.backgroundColor].
  final Color? railBackgroundColor;

  /// Border color for the navigation rail.
  ///
  /// Passed directly to [OiNavigationRail.borderColor].
  final Color? railBorderColor;

  /// Indicator color for the selected rail item.
  ///
  /// Passed directly to [OiNavigationRail.indicatorColor].
  final Color? railIndicatorColor;

  /// Controls when labels are visible on the navigation rail.
  ///
  /// When `null`, the shell automatically sets [OiRailLabelBehavior.none] for
  /// the compact rail and [OiRailLabelBehavior.all] for the expanded rail.
  final OiRailLabelBehavior? railLabelBehavior;

  /// Vertical alignment of the items group within the rail.
  ///
  /// Ranges from -1.0 (top) through 0.0 (center) to 1.0 (bottom).
  final double railGroupAlignment;

  /// The visual style of the bottom bar.
  final OiBottomBarStyle bottomBarStyle;

  /// Whether to show labels in the bottom bar.
  final bool bottomBarShowLabels;

  /// Whether the bottom bar triggers haptic feedback on tap.
  final bool bottomBarHaptic;

  /// Accessibility label for the shell container.
  final String? semanticLabel;

  /// Resolves the [OiResponsiveShellMode] for the given [width].
  ///
  /// This is a pure function exposed for testing and for consumers that need
  /// to know the active mode without building the widget.
  OiResponsiveShellMode resolveMode(double width) {
    if (width >= breakpoints.expanded) return OiResponsiveShellMode.expandedRail;
    if (width >= breakpoints.rail) return OiResponsiveShellMode.rail;
    return OiResponsiveShellMode.bottomBar;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final mode = resolveMode(width);

    final Widget shell;
    switch (mode) {
      case OiResponsiveShellMode.bottomBar:
        shell = _buildBottomBarLayout(context);
      case OiResponsiveShellMode.rail:
        shell = _buildRailLayout(context, expanded: false);
      case OiResponsiveShellMode.expandedRail:
        shell = _buildRailLayout(context, expanded: true);
    }

    return Semantics(
      container: true,
      label: semanticLabel ?? 'Application shell',
      child: shell,
    );
  }

  // ── Bottom-bar layout (compact / mobile) ─────────────────────────────────

  Widget _buildBottomBarLayout(BuildContext context) {
    return Column(
      children: [
        Expanded(child: body),
        OiBottomBar(
          items: OiBottomBar.fromNavigationItems(items),
          currentIndex: currentIndex,
          onTap: onTap,
          style: bottomBarStyle,
          showLabels: bottomBarShowLabels,
          haptic: bottomBarHaptic,
          floatingAction: floatingAction,
          // Force visibility: the shell manages breakpoints itself, so the
          // bottom bar should always render when we ask it to.
          showOnMedium: true,
        ),
      ],
    );
  }

  // ── Rail layout (medium / expanded) ──────────────────────────────────────

  Widget _buildRailLayout(BuildContext context, {required bool expanded}) {
    final effectiveLabelBehavior = railLabelBehavior ??
        (expanded ? OiRailLabelBehavior.all : OiRailLabelBehavior.none);

    final effectiveWidth = expanded ? expandedRailWidth : railWidth;

    // When a floating action is provided in rail mode, append it to the
    // trailing widget.
    final effectiveTrailing = floatingAction != null
        ? Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (railTrailing != null) railTrailing!,
              if (railTrailing != null) const SizedBox(height: 8),
              floatingAction!,
            ],
          )
        : railTrailing;

    final animations = context.animations;
    final reducedMotion =
        animations.reducedMotion || MediaQuery.disableAnimationsOf(context);
    final animDuration =
        reducedMotion ? Duration.zero : const Duration(milliseconds: 200);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AnimatedContainer(
          duration: animDuration,
          curve: Curves.easeInOut,
          width: effectiveWidth,
          child: OiNavigationRail(
            items: items,
            currentIndex: currentIndex,
            onTap: onTap,
            width: effectiveWidth,
            leading: railLeading,
            trailing: effectiveTrailing,
            labelBehavior: effectiveLabelBehavior,
            groupAlignment: railGroupAlignment,
            backgroundColor: railBackgroundColor,
            borderColor: railBorderColor,
            indicatorColor: railIndicatorColor,
          ),
        ),
        Expanded(child: body),
      ],
    );
  }
}
