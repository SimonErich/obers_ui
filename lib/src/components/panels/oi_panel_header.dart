import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/display/oi_label.dart';
import 'package:obers_ui/src/primitives/interaction/oi_tappable.dart';

/// The size preset for [OiPanelHeader].
///
/// {@category Components}
enum OiPanelHeaderSize {
  /// 32 logical pixels tall.
  compact,

  /// 48 logical pixels tall (default).
  medium,

  /// 64 logical pixels tall.
  large,
}

/// The border style applied to [OiPanelHeader].
///
/// {@category Components}
enum OiPanelHeaderBorder {
  /// No border.
  none,

  /// A single bottom border (default).
  bottom,

  /// Borders on all four edges.
  all,
}

/// A titled header bar for use inside [OiSplitPane], [OiPanel],
/// [OiResizable], or any panel-like container.
///
/// Shows a [label] with optional [subtitle], [leading] / [trailing]
/// slots, and an optional tap callback that triggers hover/focus
/// states via [OiTappable].
///
/// {@category Components}
class OiPanelHeader extends StatelessWidget {
  /// Creates an [OiPanelHeader].
  const OiPanelHeader({
    required this.label,
    this.leading,
    this.trailing,
    this.subtitle,
    this.size = OiPanelHeaderSize.medium,
    this.border = OiPanelHeaderBorder.bottom,
    this.backgroundColor,
    this.onTap,
    this.semanticLabel,
    super.key,
  });

  /// The primary title text.
  final String label;

  /// An optional widget placed before the title (e.g. an icon or toggle).
  final Widget? leading;

  /// An optional widget placed after the title (e.g. action icons).
  final Widget? trailing;

  /// An optional subtitle shown below [label].
  final String? subtitle;

  /// Controls the overall height. Defaults to [OiPanelHeaderSize.medium].
  final OiPanelHeaderSize size;

  /// Controls which edges receive a border.
  final OiPanelHeaderBorder border;

  /// Overrides the default surface background colour.
  final Color? backgroundColor;

  /// When non-null, the header is wrapped in [OiTappable] with hover/focus
  /// states.
  final VoidCallback? onTap;

  /// Accessibility label. Falls back to [label] when null.
  final String? semanticLabel;

  double _resolveHeight(double sm, double xl, double xxl) {
    return switch (size) {
      OiPanelHeaderSize.compact => xl,
      OiPanelHeaderSize.medium => xxl,
      OiPanelHeaderSize.large => 64,
    };
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final height = _resolveHeight(spacing.sm, spacing.xl, spacing.xxl);

    final borderColor = colors.borderSubtle;
    final BoxBorder? resolvedBorder = switch (border) {
      OiPanelHeaderBorder.none => null,
      OiPanelHeaderBorder.bottom => Border(
        bottom: BorderSide(color: borderColor),
      ),
      OiPanelHeaderBorder.all => Border.all(color: borderColor),
    };

    // Title column — label + optional subtitle.
    Widget titleWidget = OiLabel.small(label);
    if (subtitle != null) {
      titleWidget = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          titleWidget,
          OiLabel.caption(subtitle!, color: colors.textSubtle),
        ],
      );
    }

    // Row layout: leading | title (expanded) | trailing.
    Widget content = Row(
      children: [
        if (leading != null) ...[
          leading!,
          SizedBox(width: spacing.sm),
        ],
        Expanded(child: titleWidget),
        if (trailing != null) ...[
          SizedBox(width: spacing.sm),
          trailing!,
        ],
      ],
    );

    // Optional tappable wrapper.
    if (onTap != null) {
      content = OiTappable(onTap: onTap, child: content);
    }

    return Semantics(
      header: true,
      label: semanticLabel ?? label,
      child: Container(
        height: height,
        padding: EdgeInsets.symmetric(horizontal: spacing.sm),
        decoration: BoxDecoration(
          color: backgroundColor ?? colors.surface,
          border: resolvedBorder,
        ),
        child: content,
      ),
    );
  }
}
