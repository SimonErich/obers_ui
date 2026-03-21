import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/theme/oi_decoration_theme.dart';
import 'package:obers_ui/src/foundation/theme/oi_effects_theme.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/display/oi_surface.dart';
import 'package:obers_ui/src/primitives/interaction/oi_tappable.dart';

// Chevron icon codepoint from Material Icons (expand_more).
const _kChevronIcon = IconData(0xe5cf, fontFamily: 'MaterialIcons');

// Key for the horizontal separator between body and footer.
const _kCardDividerKey = Key('_oi_card_divider');

/// Internal discriminator for [OiCard] factory constructors.
enum _OiCardKind { elevated, flat, outlined, interactive, compact }

/// A themed card container with optional header, footer, collapsible body,
/// and tap interaction.
///
/// [OiCard] composes [OiSurface] and optionally [OiTappable] to produce a
/// styled card that supports title/subtitle/leading/trailing header slots, a
/// footer separated by a horizontal line, and an animated collapsible body.
///
/// Use the named factory constructors for common visual presets:
/// - [OiCard.flat] — no shadow.
/// - [OiCard.outlined] — border only, no shadow.
/// - [OiCard.interactive] — always shows hover/focus effects via [OiTappable].
/// - [OiCard.compact] — reduced internal padding (`EdgeInsets.all(8)`).
///
/// {@category Components}
class OiCard extends StatefulWidget {
  /// Creates an elevated [OiCard] with optional header, footer, and tap support.
  ///
  /// [label] is required when [onTap] is provided.
  const OiCard({
    required this.child,
    this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.footer,
    this.onTap,
    this.label,
    this.collapsible = false,
    this.defaultCollapsed = false,
    this.padding,
    this.border,
    this.gradient,
    this.halo,
    super.key,
  }) : assert(
         onTap == null || label != null,
         'label is required when onTap is provided',
       ),
       _kind = _OiCardKind.elevated;

  // Private constructor used by factory constructors to set the kind.
  const OiCard._({
    required this.child,
    required _OiCardKind kind,
    this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.footer,
    this.onTap,
    this.label,
    this.collapsible = false,
    this.defaultCollapsed = false,
    this.padding,
    this.border,
    this.gradient,
    this.halo,
    super.key,
  }) : assert(
         onTap == null || label != null,
         'label is required when onTap is provided',
       ),
       _kind = kind;

  /// Creates a flat [OiCard] with no shadow.
  factory OiCard.flat({
    required Widget child,
    Widget? title,
    Widget? subtitle,
    Widget? leading,
    Widget? trailing,
    Widget? footer,
    VoidCallback? onTap,
    String? label,
    bool collapsible = false,
    bool defaultCollapsed = false,
    EdgeInsetsGeometry? padding,
    OiBorderStyle? border,
    OiGradientStyle? gradient,
    OiHaloStyle? halo,
    Key? key,
  }) {
    return OiCard._(
      kind: _OiCardKind.flat,
      title: title,
      subtitle: subtitle,
      leading: leading,
      trailing: trailing,
      footer: footer,
      onTap: onTap,
      label: label,
      collapsible: collapsible,
      defaultCollapsed: defaultCollapsed,
      padding: padding,
      border: border,
      gradient: gradient,
      halo: halo,
      key: key,
      child: child,
    );
  }

  /// Creates an outlined [OiCard] with a border and no shadow.
  ///
  /// When [border] is null, uses [OiDecorationTheme.defaultBorder].
  factory OiCard.outlined({
    required Widget child,
    Widget? title,
    Widget? subtitle,
    Widget? leading,
    Widget? trailing,
    Widget? footer,
    VoidCallback? onTap,
    String? label,
    bool collapsible = false,
    bool defaultCollapsed = false,
    EdgeInsetsGeometry? padding,
    OiBorderStyle? border,
    OiGradientStyle? gradient,
    OiHaloStyle? halo,
    Key? key,
  }) {
    return OiCard._(
      kind: _OiCardKind.outlined,
      title: title,
      subtitle: subtitle,
      leading: leading,
      trailing: trailing,
      footer: footer,
      onTap: onTap,
      label: label,
      collapsible: collapsible,
      defaultCollapsed: defaultCollapsed,
      padding: padding,
      border: border,
      gradient: gradient,
      halo: halo,
      key: key,
      child: child,
    );
  }

  /// Creates an interactive [OiCard] that always shows hover/focus effects.
  ///
  /// [label] is required for accessibility.
  factory OiCard.interactive({
    required Widget child,
    required String label,
    Widget? title,
    Widget? subtitle,
    Widget? leading,
    Widget? trailing,
    Widget? footer,
    VoidCallback? onTap,
    bool collapsible = false,
    bool defaultCollapsed = false,
    EdgeInsetsGeometry? padding,
    OiBorderStyle? border,
    OiGradientStyle? gradient,
    OiHaloStyle? halo,
    Key? key,
  }) {
    return OiCard._(
      kind: _OiCardKind.interactive,
      label: label,
      title: title,
      subtitle: subtitle,
      leading: leading,
      trailing: trailing,
      footer: footer,
      onTap: onTap,
      collapsible: collapsible,
      defaultCollapsed: defaultCollapsed,
      padding: padding,
      border: border,
      gradient: gradient,
      halo: halo,
      key: key,
      child: child,
    );
  }

  /// Creates a compact [OiCard] with reduced padding (`EdgeInsets.all(8)`).
  factory OiCard.compact({
    required Widget child,
    Widget? title,
    Widget? subtitle,
    Widget? leading,
    Widget? trailing,
    Widget? footer,
    VoidCallback? onTap,
    String? label,
    bool collapsible = false,
    bool defaultCollapsed = false,
    EdgeInsetsGeometry? padding,
    OiBorderStyle? border,
    OiGradientStyle? gradient,
    OiHaloStyle? halo,
    Key? key,
  }) {
    return OiCard._(
      kind: _OiCardKind.compact,
      title: title,
      subtitle: subtitle,
      leading: leading,
      trailing: trailing,
      footer: footer,
      onTap: onTap,
      label: label,
      collapsible: collapsible,
      defaultCollapsed: defaultCollapsed,
      padding: padding,
      border: border,
      gradient: gradient,
      halo: halo,
      key: key,
      child: child,
    );
  }

  /// The primary content rendered inside the card body.
  final Widget child;

  /// Optional title rendered in the card header.
  final Widget? title;

  /// Optional subtitle rendered below [title] in the card header.
  final Widget? subtitle;

  /// Optional widget rendered to the left of [title] in the header.
  final Widget? leading;

  /// Optional widget rendered to the right of [title] in the header.
  final Widget? trailing;

  /// Optional widget rendered below the body, separated by a horizontal line.
  final Widget? footer;

  /// Callback fired when the card is tapped. Requires [label].
  final VoidCallback? onTap;

  /// Accessibility label announced by screen readers. Required when [onTap]
  /// is provided.
  final String? label;

  /// When true, the card body and footer can be collapsed/expanded via a
  /// chevron in the header.
  final bool collapsible;

  /// When true and [collapsible] is true, the card starts collapsed.
  final bool defaultCollapsed;

  /// Padding inside the card surface. Defaults to `EdgeInsets.all(16)` for
  /// most variants and `EdgeInsets.all(8)` for [OiCard.compact].
  final EdgeInsetsGeometry? padding;

  /// Explicit border override. When null, [OiCard.outlined] and
  /// [OiCard.interactive] fall back to [OiDecorationTheme.defaultBorder].
  final OiBorderStyle? border;

  /// Optional background gradient. Overrides the surface fill colour.
  final OiGradientStyle? gradient;

  /// Optional halo/glow effect rendered around the card.
  final OiHaloStyle? halo;

  final _OiCardKind _kind;

  @override
  State<OiCard> createState() => _OiCardState();
}

class _OiCardState extends State<OiCard> with SingleTickerProviderStateMixin {
  late bool _collapsed;
  late AnimationController _controller;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _collapsed = widget.collapsible && widget.defaultCollapsed;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
      value: _collapsed ? 0.0 : 1.0,
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void didUpdateWidget(OiCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.collapsible && !widget.collapsible) {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleCollapsed() {
    final reducedMotion =
        context.animations.reducedMotion ||
        MediaQuery.disableAnimationsOf(context);
    setState(() => _collapsed = !_collapsed);
    if (reducedMotion) {
      _controller.value = _collapsed ? 0.0 : 1.0;
    } else if (_collapsed) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    OiBorderStyle? effectiveBorder;
    List<BoxShadow>? shadow;

    switch (widget._kind) {
      case _OiCardKind.elevated:
        shadow = [
          BoxShadow(
            color: colors.overlay.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
          BoxShadow(
            color: colors.overlay.withValues(alpha: 0.04),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ];
        effectiveBorder = widget.border;
      case _OiCardKind.flat:
        effectiveBorder = widget.border;
      case _OiCardKind.outlined:
        effectiveBorder = widget.border ?? context.decoration.defaultBorder;
      case _OiCardKind.interactive:
        effectiveBorder = widget.border ?? context.decoration.defaultBorder;
      case _OiCardKind.compact:
        shadow = [
          BoxShadow(
            color: colors.overlay.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
          BoxShadow(
            color: colors.overlay.withValues(alpha: 0.04),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ];
        effectiveBorder = widget.border;
    }

    final effectivePadding =
        widget.padding ??
        (widget._kind == _OiCardKind.compact
            ? const EdgeInsets.all(8)
            : const EdgeInsets.all(16));

    final hasHeader =
        widget.title != null ||
        widget.subtitle != null ||
        widget.leading != null ||
        widget.trailing != null ||
        widget.collapsible;

    final bodyAndFooter = _buildBodyAndFooter(context);

    Widget collapsibleContent;
    if (widget.collapsible) {
      collapsibleContent = SizeTransition(
        sizeFactor: _expandAnimation,
        axisAlignment: -1,
        child: FadeTransition(opacity: _expandAnimation, child: bodyAndFooter),
      );
    } else {
      collapsibleContent = bodyAndFooter;
    }

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [if (hasHeader) _buildHeader(context), collapsibleContent],
    );

    final surface = OiSurface(
      border: effectiveBorder,
      shadow: shadow,
      borderRadius: BorderRadius.circular(8),
      padding: effectivePadding,
      gradient: widget.gradient,
      halo: widget.halo,
      child: content,
    );

    final needsTappable =
        widget.onTap != null || widget._kind == _OiCardKind.interactive;
    if (needsTappable) {
      return OiTappable(
        onTap: widget.onTap,
        semanticLabel: widget.label,
        child: surface,
      );
    }

    return surface;
  }

  Widget _buildHeader(BuildContext context) {
    final reducedMotion =
        context.animations.reducedMotion ||
        MediaQuery.disableAnimationsOf(context);
    final animationDuration = reducedMotion
        ? Duration.zero
        : context.animations.normal;
    return Row(
      children: [
        if (widget.leading != null) widget.leading!,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.title != null) widget.title!,
              if (widget.subtitle != null) widget.subtitle!,
            ],
          ),
        ),
        if (widget.trailing != null) widget.trailing!,
        if (widget.collapsible)
          GestureDetector(
            onTap: _toggleCollapsed,
            child: AnimatedRotation(
              turns: _collapsed ? 0.0 : 0.5,
              duration: animationDuration,
              child: const Icon(_kChevronIcon),
            ),
          ),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    return widget.child;
  }

  Widget _buildFooter(BuildContext context) {
    return widget.footer!;
  }

  Widget _buildBodyAndFooter(BuildContext context) {
    if (widget.footer == null) {
      return _buildBody(context);
    }
    final separatorColor = context.colors.border;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildBody(context),
        SizedBox(
          key: _kCardDividerKey,
          height: 1,
          child: ColoredBox(color: separatorColor),
        ),
        _buildFooter(context),
      ],
    );
  }
}
