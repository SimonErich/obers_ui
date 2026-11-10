import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/oi_icons.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/display/oi_icon.dart';
import 'package:obers_ui/src/primitives/display/oi_label.dart';
import 'package:obers_ui/src/primitives/interaction/oi_tappable.dart';

/// A controlled, borderless disclosure for secondary form content.
///
/// Collapsed content retains its widget state, while leaving focus order and
/// accessibility traversal. The parent owns expansion and validation behavior.
class OiDisclosure extends StatelessWidget {
  /// Creates a disclosure with a keyboard-accessible, fully clickable header.
  const OiDisclosure({
    required this.title,
    required this.expanded,
    required this.onChanged,
    required this.child,
    this.description,
    this.headerPadding = const EdgeInsets.symmetric(vertical: 8),
    super.key,
  });

  /// Visible heading and accessible toggle label.
  final String title;

  /// Optional explanation which wraps beside the heading.
  final String? description;

  /// Interior header spacing; touch targets remain enforced by OiTappable.
  final EdgeInsetsGeometry headerPadding;

  /// Whether the content is currently visible.
  final bool expanded;

  /// Reports a requested expansion change.
  final ValueChanged<bool>? onChanged;

  /// Content retained below the header.
  final Widget child;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    mainAxisSize: MainAxisSize.min,
    children: [
      Semantics(
        expanded: expanded,
        hint: description,
        child: OiTappable(
          semanticLabel: '${expanded ? 'Collapse' : 'Expand'} $title',
          enabled: onChanged != null,
          onTap: onChanged == null ? null : () => onChanged!(!expanded),
          child: ExcludeSemantics(
            child: Padding(
              padding: headerPadding,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: OiIcon.decorative(
                      icon: expanded
                          ? OiIcons.chevronDown
                          : OiIcons.chevronRight,
                      size: 14,
                      color: context.colors.textMuted,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 2,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        OiLabel.bodyStrong(title),
                        if (description != null)
                          OiLabel.small(
                            description!,
                            color: context.colors.textMuted,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      AnimatedSize(
        duration:
            context.animations.reducedMotion ||
                MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : context.animations.normal,
        alignment: AlignmentDirectional.topStart,
        child: Offstage(
          offstage: !expanded,
          child: ExcludeFocus(
            excluding: !expanded,
            child: TickerMode(
              enabled: expanded,
              child: Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 8),
                child: child,
              ),
            ),
          ),
        ),
      ),
    ],
  );
}
