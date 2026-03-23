import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/oi_icons.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/display/oi_label.dart';

/// A sticky sliver header with support for collapsing, flexible space,
/// and snap-to-position behaviour.
///
/// [OiSliverHeader] wraps a [SliverPersistentHeader] and its delegate,
/// providing a convenient API for common app-bar patterns inside a
/// [CustomScrollView].
///
/// ```dart
/// CustomScrollView(
///   slivers: [
///     OiSliverHeader.simple(title: 'Messages'),
///     SliverList.builder(
///       delegate: SliverChildBuilderDelegate(
///         (context, index) => MessageTile(messages[index]),
///         childCount: messages.length,
///       ),
///     ),
///   ],
/// )
/// ```
///
/// Convenience constructors cover the most common layouts:
/// - [OiSliverHeader.simple]: pinned header with a title and optional back
///   button.
/// - [OiSliverHeader.large]: pinned header with an expanded title area.
/// - [OiSliverHeader.hero]: pinned header with a flexible-space background.
///
/// {@category Components}
class OiSliverHeader extends StatelessWidget {
  /// Creates an [OiSliverHeader] with full control over all parameters.
  const OiSliverHeader({
    this.leading,
    this.title,
    this.subtitle,
    this.trailing,
    this.actions = const [],
    this.pinned = true,
    this.floating = false,
    this.snap = false,
    this.expandedHeight,
    this.collapsedHeight,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.border,
    this.flexibleSpace,
    this.centerTitle = false,
    this.titleSpacing = 16,
    this.toolbarHeight = 56,
    this.semanticLabel,
    super.key,
  });

  /// Creates a simple pinned header with a [title] string and optional back
  /// button.
  ///
  /// When [onBack] is provided a chevron-left icon is placed in [leading].
  OiSliverHeader.simple({
    required String title,
    VoidCallback? onBack,
    List<Widget> actions = const [],
    String? semanticLabel,
    Key? key,
  }) : this(
         leading: onBack != null ? _buildBackButton(onBack) : null,
         title: OiLabel.body(title),
         actions: actions,
         pinned: true,
         semanticLabel: semanticLabel,
         key: key,
       );

  /// Creates a pinned header with an expanded title area that collapses on
  /// scroll.
  ///
  /// When [onBack] is provided a chevron-left icon is placed in [leading].
  OiSliverHeader.large({
    required String title,
    String? subtitle,
    VoidCallback? onBack,
    List<Widget> actions = const [],
    double expandedHeight = 120,
    String? semanticLabel,
    Key? key,
  }) : this(
         leading: onBack != null ? _buildBackButton(onBack) : null,
         title: OiLabel.h3(title),
         subtitle: subtitle != null ? OiLabel.small(subtitle) : null,
         actions: actions,
         pinned: true,
         expandedHeight: expandedHeight,
         semanticLabel: semanticLabel,
         key: key,
       );

  /// Creates a pinned header with a [flexibleSpace] background that fades out
  /// as the user scrolls.
  ///
  /// When [onBack] is provided a chevron-left icon is placed in [leading].
  OiSliverHeader.hero({
    required Widget flexibleSpace,
    Widget? title,
    VoidCallback? onBack,
    List<Widget> actions = const [],
    double expandedHeight = 200,
    String? semanticLabel,
    Key? key,
  }) : this(
         leading: onBack != null ? _buildBackButton(onBack) : null,
         title: title,
         flexibleSpace: flexibleSpace,
         actions: actions,
         pinned: true,
         expandedHeight: expandedHeight,
         semanticLabel: semanticLabel,
         key: key,
       );

  /// A widget placed before the title (typically a back button).
  final Widget? leading;

  /// The primary title widget.
  final Widget? title;

  /// An optional subtitle widget displayed below the [title].
  final Widget? subtitle;

  /// A widget placed after the title (typically a single action).
  final Widget? trailing;

  /// Additional action widgets displayed after [trailing].
  final List<Widget> actions;

  /// Whether the header remains visible at the top of the scroll view.
  final bool pinned;

  /// Whether the header becomes visible as soon as the user scrolls up.
  final bool floating;

  /// Whether the header snaps fully open/closed when the user stops scrolling.
  ///
  /// Only effective when [floating] is `true`.
  final bool snap;

  /// The height of the header when fully expanded.
  ///
  /// Defaults to [toolbarHeight] when not specified.
  final double? expandedHeight;

  /// The height of the header when fully collapsed.
  ///
  /// Defaults to [toolbarHeight] when not specified.
  final double? collapsedHeight;

  /// The background color of the header.
  ///
  /// Defaults to the theme's surface color.
  final Color? backgroundColor;

  /// The foreground color used for icons and text.
  ///
  /// Defaults to the theme's text color.
  final Color? foregroundColor;

  /// An optional elevation applied as a shadow.
  final double? elevation;

  /// An optional bottom border.
  final Border? border;

  /// A widget rendered behind the toolbar content that fades out as the
  /// header collapses.
  final Widget? flexibleSpace;

  /// Whether to center the title horizontally.
  final bool centerTitle;

  /// Horizontal spacing between the leading widget and the title.
  final double titleSpacing;

  /// The height of the collapsed toolbar area.
  final double toolbarHeight;

  /// The accessibility label for the header.
  final String? semanticLabel;

  // ── Helpers ───────────────────────────────────────────────────────────────

  static Widget _buildBackButton(VoidCallback onBack) {
    return GestureDetector(
      onTap: onBack,
      behavior: HitTestBehavior.opaque,
      child: Semantics(
        label: 'Go back',
        button: true,
        child: const Padding(
          padding: EdgeInsets.all(8),
          child: Icon(OiIcons.chevronLeft, size: 20),
        ),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      pinned: pinned,
      floating: floating,
      delegate: _OiSliverHeaderDelegate(
        leading: leading,
        title: title,
        subtitle: subtitle,
        trailing: trailing,
        actions: actions,
        snap: snap,
        floating: floating,
        expandedHeight: expandedHeight,
        collapsedHeight: collapsedHeight,
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        elevation: elevation,
        border: border,
        flexibleSpace: flexibleSpace,
        centerTitle: centerTitle,
        titleSpacing: titleSpacing,
        toolbarHeight: toolbarHeight,
        semanticLabel: semanticLabel,
        theme: context.theme,
        colors: context.colors,
        shadows: context.shadows,
      ),
    );
  }
}

// ── Delegate ──────────────────────────────────────────────────────────────────

class _OiSliverHeaderDelegate extends SliverPersistentHeaderDelegate {
  _OiSliverHeaderDelegate({
    required this.leading,
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.actions,
    required this.snap,
    required this.floating,
    required this.expandedHeight,
    required this.collapsedHeight,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.elevation,
    required this.border,
    required this.flexibleSpace,
    required this.centerTitle,
    required this.titleSpacing,
    required this.toolbarHeight,
    required this.semanticLabel,
    required this.theme,
    required this.colors,
    required this.shadows,
  });

  final Widget? leading;
  final Widget? title;
  final Widget? subtitle;
  final Widget? trailing;
  final List<Widget> actions;
  final bool snap;
  final bool floating;
  final double? expandedHeight;
  final double? collapsedHeight;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;
  final Border? border;
  final Widget? flexibleSpace;
  final bool centerTitle;
  final double titleSpacing;
  final double toolbarHeight;
  final String? semanticLabel;
  final dynamic theme;
  final dynamic colors;
  final dynamic shadows;

  @override
  double get minExtent => collapsedHeight ?? toolbarHeight;

  @override
  double get maxExtent => expandedHeight ?? toolbarHeight;

  @override
  FloatingHeaderSnapConfiguration? get snapConfiguration {
    if (snap && floating) {
      return FloatingHeaderSnapConfiguration();
    }
    return null;
  }

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final contextColors = context.colors;
    final contextShadows = context.shadows;

    final collapseProgress =
        maxExtent == minExtent
            ? 0.0
            : (shrinkOffset / (maxExtent - minExtent)).clamp(0.0, 1.0);

    final effectiveBg = backgroundColor ?? contextColors.surface;
    final effectiveFg = foregroundColor ?? contextColors.text;
    final isScrolledUnder = overlapsContent || shrinkOffset > 0;

    // ── Title area ──────────────────────────────────────────────────────

    var titleWidget = title;
    if (titleWidget != null && foregroundColor != null) {
      titleWidget = IconTheme(
        data: IconThemeData(color: effectiveFg),
        child: titleWidget,
      );
    }

    final titleArea = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment:
          centerTitle ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        if (titleWidget != null) Flexible(child: titleWidget),
        if (subtitle != null) ...[
          const SizedBox(height: 2),
          Flexible(
            child: Opacity(
              opacity: (1.0 - collapseProgress).clamp(0.0, 1.0),
              child: subtitle,
            ),
          ),
        ],
      ],
    );

    // ── Toolbar row ─────────────────────────────────────────────────────

    final toolbar = SizedBox(
      height: toolbarHeight,
      child: Row(
        children: [
          if (leading != null) ...[
            leading!,
            SizedBox(width: titleSpacing),
          ],
          Expanded(
            child: centerTitle ? Center(child: titleArea) : titleArea,
          ),
          if (trailing != null) trailing!,
          for (final action in actions) action,
        ],
      ),
    );

    // ── Decoration ──────────────────────────────────────────────────────

    final boxShadow = isScrolledUnder && elevation != null && elevation! > 0
        ? contextShadows.sm
        : contextShadows.none;

    final bottomBorder =
        isScrolledUnder
            ? (border ??
                Border(
                  bottom: BorderSide(color: contextColors.borderSubtle),
                ))
            : null;

    final decoration = BoxDecoration(
      color: effectiveBg,
      border: bottomBorder,
      boxShadow: boxShadow,
    );

    // ── Compose content ─────────────────────────────────────────────────

    Widget content;

    if (flexibleSpace != null) {
      content = Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: (1.0 - collapseProgress).clamp(0.0, 1.0),
              child: flexibleSpace,
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: toolbar,
          ),
        ],
      );
    } else {
      content = Align(
        alignment: Alignment.bottomCenter,
        child: toolbar,
      );
    }

    return Semantics(
      header: true,
      label: semanticLabel,
      child: DecoratedBox(
        decoration: decoration,
        child: content,
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _OiSliverHeaderDelegate oldDelegate) => true;
}
