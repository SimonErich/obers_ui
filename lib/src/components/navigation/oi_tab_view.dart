import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/navigation/oi_tabs.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';

/// A single tab entry in an [OiTabView].
///
/// Each item describes the tab header (label, icon, badge) and provides a
/// [builder] that lazily constructs the tab's content when it becomes visible.
///
/// {@category Components}
@immutable
class OiTabViewItem {
  /// Creates an [OiTabViewItem].
  const OiTabViewItem({
    required this.label,
    required this.builder,
    this.icon,
    this.badge,
    this.enabled = true,
  });

  /// The text label shown in the tab bar.
  final String label;

  /// A builder that creates the content widget for this tab.
  ///
  /// Called lazily when the tab is first selected. When [OiTabView.keepAlive]
  /// is `true`, the widget is built once and retained in an [IndexedStack].
  final WidgetBuilder builder;

  /// An optional icon shown alongside [label] in the tab bar.
  final IconData? icon;

  /// An optional badge string shown over the tab icon.
  ///
  /// Typically a count (e.g. `"3"`). Parsed as an integer for [OiTabItem].
  final String? badge;

  /// Whether this tab is selectable.
  ///
  /// Disabled tabs are shown but cannot be selected by the user.
  final bool enabled;
}

/// A tab bar with integrated content switching and transition animations.
///
/// [OiTabView] combines [OiTabs] (the tab bar) with a content area that
/// displays the widget built by the selected [OiTabViewItem.builder].
///
/// Two modes are available:
///
/// - **Uncontrolled** (default constructor): the widget manages its own
///   `_selectedIndex` in internal state, starting at [initialIndex].
/// - **Controlled** ([OiTabView.controlled]): the parent supplies the
///   `selectedIndex` and must update it in response to [onTabChanged].
///
/// Content transitions use either [AnimatedSwitcher] (when [keepAlive] is
/// `false`, the default) or [IndexedStack] (when [keepAlive] is `true`).
///
/// When [swipeable] is `true`, the user can swipe horizontally in the content
/// area to switch between adjacent tabs.
///
/// ```dart
/// OiTabView(
///   tabs: [
///     OiTabViewItem(label: 'Overview', builder: (_) => OverviewPage()),
///     OiTabViewItem(label: 'Details', builder: (_) => DetailsPage()),
///     OiTabViewItem(label: 'Activity', builder: (_) => ActivityPage()),
///   ],
///   onTabChanged: (index) => debugPrint('Tab $index selected'),
/// )
/// ```
///
/// {@category Components}
class OiTabView extends StatefulWidget {
  /// Creates an uncontrolled [OiTabView] that manages its own selection state.
  const OiTabView({
    required this.tabs,
    this.initialIndex = 0,
    this.onTabChanged,
    this.indicatorStyle = OiTabIndicatorStyle.underline,
    this.scrollable = false,
    this.tabBarPadding,
    this.keepAlive = false,
    this.swipeable = true,
    this.animationDuration,
    this.semanticLabel,
    super.key,
  }) : _selectedIndex = null,
       _isControlled = false;

  /// Creates a controlled [OiTabView] where the parent manages selection.
  ///
  /// The parent must provide [selectedIndex] and update it when [onTabChanged]
  /// fires. Failing to do so will result in the tab bar appearing unresponsive.
  const OiTabView.controlled({
    required this.tabs,
    required int selectedIndex,
    required this.onTabChanged,
    this.indicatorStyle = OiTabIndicatorStyle.underline,
    this.scrollable = false,
    this.tabBarPadding,
    this.keepAlive = false,
    this.swipeable = true,
    this.animationDuration,
    this.semanticLabel,
    super.key,
  }) : _selectedIndex = selectedIndex,
       _isControlled = true,
       initialIndex = selectedIndex;

  /// The list of tab items to display.
  ///
  /// Each item describes the tab header and provides a content builder.
  final List<OiTabViewItem> tabs;

  /// The initial tab index for uncontrolled mode.
  ///
  /// Ignored in controlled mode.
  final int initialIndex;

  /// Called with the new index when the user selects a different tab.
  final ValueChanged<int>? onTabChanged;

  /// The visual style used to highlight the selected tab.
  final OiTabIndicatorStyle indicatorStyle;

  /// Whether the tab bar scrolls horizontally when it overflows.
  final bool scrollable;

  /// Optional padding around the tab bar.
  final EdgeInsetsGeometry? tabBarPadding;

  /// Whether all tab contents are kept alive in the widget tree.
  ///
  /// When `true`, an [IndexedStack] is used so that all tabs remain built
  /// and retain their scroll position and state. When `false` (default), only
  /// the active tab is built using an [AnimatedSwitcher] with a fade
  /// transition.
  final bool keepAlive;

  /// Whether horizontal swipe gestures switch between tabs.
  ///
  /// Defaults to `true`.
  final bool swipeable;

  /// Custom duration for content transition animations.
  ///
  /// When `null`, the theme's normal animation duration is used.
  final Duration? animationDuration;

  /// An optional accessibility label for the tab view.
  final String? semanticLabel;

  /// The externally-controlled selected index, or `null` for uncontrolled mode.
  final int? _selectedIndex;

  /// Whether this is a controlled instance.
  final bool _isControlled;

  @override
  State<OiTabView> createState() => _OiTabViewState();
}

class _OiTabViewState extends State<OiTabView> {
  late int _currentIndex;

  /// Tracks horizontal swipe start position.
  double? _swipeStartX;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget._isControlled
        ? widget._selectedIndex!
        : widget.initialIndex;
  }

  @override
  void didUpdateWidget(OiTabView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Sync controlled index.
    if (widget._isControlled && widget._selectedIndex != _currentIndex) {
      setState(() => _currentIndex = widget._selectedIndex!);
    }
  }

  /// The effective selected index.
  int get _effectiveIndex => widget._isControlled
      ? widget._selectedIndex!
      : _currentIndex;

  void _handleTabSelected(int index) {
    // Skip disabled tabs.
    if (index < 0 || index >= widget.tabs.length) return;
    if (!widget.tabs[index].enabled) return;

    if (!widget._isControlled) {
      setState(() => _currentIndex = index);
    }
    widget.onTabChanged?.call(index);
  }

  /// Finds the next enabled tab in the given direction.
  int? _findNextEnabledTab(int from, int direction) {
    var candidate = from + direction;
    while (candidate >= 0 && candidate < widget.tabs.length) {
      if (widget.tabs[candidate].enabled) return candidate;
      candidate += direction;
    }
    return null;
  }

  // ── Swipe handling ────────────────────────────────────────────────────────

  void _handleHorizontalDragStart(DragStartDetails details) {
    _swipeStartX = details.globalPosition.dx;
  }

  void _handleHorizontalDragEnd(DragEndDetails details) {
    if (_swipeStartX == null) return;

    final velocity = details.primaryVelocity ?? 0;
    // Minimum velocity threshold to trigger a swipe.
    const threshold = 200.0;

    if (velocity < -threshold) {
      // Swipe left → next tab.
      final next = _findNextEnabledTab(_effectiveIndex, 1);
      if (next != null) _handleTabSelected(next);
    } else if (velocity > threshold) {
      // Swipe right → previous tab.
      final prev = _findNextEnabledTab(_effectiveIndex, -1);
      if (prev != null) _handleTabSelected(prev);
    }

    _swipeStartX = null;
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final animations = context.animations;
    final reducedMotion =
        animations.reducedMotion || MediaQuery.disableAnimationsOf(context);
    final effectiveDuration = reducedMotion
        ? Duration.zero
        : (widget.animationDuration ?? animations.normal);

    final index = _effectiveIndex;

    // Convert OiTabViewItem list to OiTabItem list for the tab bar.
    final tabItems = widget.tabs.map((item) {
      final badgeValue = item.badge != null ? int.tryParse(item.badge!) : null;
      return OiTabItem(
        label: item.label,
        icon: item.icon,
        badge: badgeValue,
      );
    }).toList();

    // Build content area.
    Widget content;
    if (widget.keepAlive) {
      // IndexedStack keeps all tabs alive — only the selected one is visible.
      content = IndexedStack(
        index: index,
        children: [
          for (var i = 0; i < widget.tabs.length; i++)
            widget.tabs[i].builder(context),
        ],
      );
    } else {
      // AnimatedSwitcher rebuilds only the active tab with a fade transition.
      content = AnimatedSwitcher(
        duration: effectiveDuration,
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        child: KeyedSubtree(
          key: ValueKey<int>(index),
          child: widget.tabs[index].builder(context),
        ),
      );
    }

    // Wrap content in swipe detector if enabled.
    if (widget.swipeable) {
      content = GestureDetector(
        onHorizontalDragStart: _handleHorizontalDragStart,
        onHorizontalDragEnd: _handleHorizontalDragEnd,
        behavior: HitTestBehavior.translucent,
        child: content,
      );
    }

    // Build the tab bar.
    Widget tabBar = OiTabs(
      tabs: tabItems,
      selectedIndex: index,
      onSelected: _handleTabSelected,
      indicatorStyle: widget.indicatorStyle,
      scrollable: widget.scrollable,
    );

    if (widget.tabBarPadding != null) {
      tabBar = Padding(padding: widget.tabBarPadding!, child: tabBar);
    }

    Widget view = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        tabBar,
        Expanded(child: content),
      ],
    );

    // Group-level semantics.
    if (widget.semanticLabel != null) {
      view = Semantics(
        container: true,
        label: widget.semanticLabel,
        child: view,
      );
    }

    return view;
  }
}
