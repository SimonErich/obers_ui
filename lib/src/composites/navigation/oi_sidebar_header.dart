import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/theme/oi_text_theme.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/display/oi_label.dart';

/// A themed workspace heading with an optional trailing action.
class OiSidebarHeader extends StatelessWidget {
  /// Builds a contextual heading above a sidebar's destinations.
  const OiSidebarHeader({required this.title, this.trailing, super.key});

  /// Current workspace or navigation section.
  final String title;

  /// Optional creation, switcher or overflow action.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = context.components.sidebar;
    return Container(
      constraints: BoxConstraints(minHeight: theme?.headerHeight ?? 64),
      padding:
          theme?.headerPadding ??
          const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: OiLabel.variant(
              title,
              variant: OiLabelVariant.h4,
              style: theme?.headerTextStyle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}
