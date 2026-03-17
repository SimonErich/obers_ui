import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/interaction/oi_tappable.dart';
import 'package:obers_ui/src/primitives/overlay/oi_floating.dart'
    show OiFloating;

/// A single crumb in an [OiBreadcrumbs] trail.
///
/// {@category Components}
@immutable
class OiBreadcrumbItem {
  /// Creates an [OiBreadcrumbItem].
  const OiBreadcrumbItem({required this.label, this.onTap});

  /// The text shown for this breadcrumb.
  final String label;

  /// Called when the crumb is tapped.
  ///
  /// The last item in the trail is always non-tappable regardless of this
  /// value.
  final VoidCallback? onTap;
}

/// A horizontal breadcrumb trail with optional item collapsing.
///
/// Renders [items] separated by [separator] (default `/`). The last item is
/// always non-interactive — it represents the current page.
///
/// When [maxVisible] is set and [items.length] exceeds it, the middle items
/// are collapsed into a `…` button that shows the hidden crumbs in an
/// overlay popover when tapped.
///
/// {@category Components}
class OiBreadcrumbs extends StatefulWidget {
  /// Creates an [OiBreadcrumbs].
  const OiBreadcrumbs({
    required this.items,
    this.separator = '/',
    this.maxVisible,
    super.key,
  });

  /// The ordered list of breadcrumb items, last being the current page.
  final List<OiBreadcrumbItem> items;

  /// The separator string rendered between items. Defaults to `'/'`.
  final String separator;

  /// When set, collapses middle items into `…` when [items.length] exceeds
  /// this value.
  final int? maxVisible;

  @override
  State<OiBreadcrumbs> createState() => _OiBreadcrumbsState();
}

class _OiBreadcrumbsState extends State<OiBreadcrumbs> {
  bool _overflowOpen = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final items = widget.items;
    final max = widget.maxVisible;

    // Determine which items to show and which to collapse.
    List<OiBreadcrumbItem> visible;
    List<OiBreadcrumbItem> hidden;

    if (max != null && items.length > max) {
      // Always show first and last; collapse the middle.
      visible = [items.first, items.last];
      hidden = items.sublist(1, items.length - 1);
    } else {
      visible = items;
      hidden = const [];
    }

    final sep = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Text(
        widget.separator,
        style: TextStyle(fontSize: 14, color: colors.textMuted),
      ),
    );

    final rowChildren = <Widget>[];
    for (var i = 0; i < visible.length; i++) {
      final item = visible[i];
      final isCurrent = item == items.last;

      if (i == 1 && hidden.isNotEmpty) {
        // Insert the collapsed ellipsis button between first and last.
        rowChildren
          ..add(sep)
          ..add(
            _EllipsisButton(
              hidden: hidden,
              open: _overflowOpen,
              onToggle: () => setState(() => _overflowOpen = !_overflowOpen),
              onClose: () => setState(() => _overflowOpen = false),
            ),
          )
          ..add(sep);
      } else if (i > 0) {
        rowChildren.add(sep);
      }

      if (isCurrent) {
        rowChildren.add(
          Text(
            item.label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: colors.text,
            ),
          ),
        );
      } else {
        rowChildren.add(
          OiTappable(
            onTap: item.onTap,
            child: Text(
              item.label,
              style: TextStyle(
                fontSize: 14,
                color: colors.primary.base,
                decoration: TextDecoration.underline,
                decorationColor: colors.primary.base,
              ),
            ),
          ),
        );
      }
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: rowChildren,
    );
  }
}

// ── Ellipsis button with popover ───────────────────────────────────────────

class _EllipsisButton extends StatelessWidget {
  const _EllipsisButton({
    required this.hidden,
    required this.open,
    required this.onToggle,
    required this.onClose,
  });

  final List<OiBreadcrumbItem> hidden;
  final bool open;
  final VoidCallback onToggle;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final button = OiTappable(
      onTap: onToggle,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Text(
          '…',
          style: TextStyle(
            fontSize: 14,
            color: colors.primary.base,
          ),
        ),
      ),
    );

    final popover = IntrinsicWidth(
      child: Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: colors.overlay.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: colors.borderSubtle),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: hidden.map((item) {
          return OiTappable(
            onTap: item.onTap != null
                ? () {
                    onClose();
                    item.onTap!();
                  }
                : null,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                item.label,
                style: TextStyle(fontSize: 14, color: colors.text),
              ),
            ),
          );
        }).toList(),
      ),
    ),
    );

    return OiFloating(
      visible: open,
      anchor: button,
      child: UnconstrainedBox(
        alignment: Alignment.topLeft,
        child: popover,
      ),
    );
  }
}
