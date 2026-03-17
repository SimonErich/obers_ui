import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';

/// An item in the "What's New" dialog.
///
/// Each item represents a single feature or change to display in the
/// [OiWhatsNew] changelog.
///
/// {@category Composites}
class OiWhatsNewItem {
  /// Creates an [OiWhatsNewItem].
  const OiWhatsNewItem({
    required this.title,
    required this.description,
    this.icon,
    this.imageUrl,
    this.version,
  });

  /// The headline for this changelog entry.
  final String title;

  /// A brief description of the feature or change.
  final String description;

  /// An optional icon displayed alongside the item.
  final IconData? icon;

  /// An optional image URL displayed alongside the item.
  ///
  /// Not rendered by default — provided as metadata for custom builders.
  final String? imageUrl;

  /// An optional version badge (e.g. "v2.1.0") shown next to the title.
  final String? version;
}

/// A "What's New" changelog dialog showing recent feature updates.
///
/// Renders a list of [OiWhatsNewItem]s in a dialog-style card with optional
/// version badges and icons. Includes a dismiss button at the bottom.
///
/// {@category Composites}
class OiWhatsNew extends StatelessWidget {
  /// Creates an [OiWhatsNew] dialog.
  const OiWhatsNew({
    required this.items,
    this.onDismiss,
    this.title = "What's New",
    super.key,
  });

  /// The list of changelog items to display.
  final List<OiWhatsNewItem> items;

  /// Called when the user taps the dismiss button.
  final VoidCallback? onDismiss;

  /// The heading displayed at the top of the dialog.
  final String title;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = context.textTheme;

    return Center(
      child: Container(
        key: const Key('oi_whats_new'),
        constraints: const BoxConstraints(maxWidth: 480, minWidth: 280),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: colors.overlay.withValues(alpha: 0.2),
              blurRadius: 32,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header.
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
              child: Text(
                title,
                style: textTheme.h3.copyWith(color: colors.text),
              ),
            ),

            // Items list.
            if (items.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: Text(
                  'No updates at this time.',
                  key: const Key('oi_whats_new_empty'),
                  style: textTheme.body.copyWith(color: colors.textMuted),
                ),
              )
            else
              Flexible(
                child: ListView.separated(
                  key: const Key('oi_whats_new_list'),
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return _OiWhatsNewItemTile(item: item);
                  },
                ),
              ),

            // Dismiss button.
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: onDismiss,
                    child: Container(
                      key: const Key('oi_whats_new_dismiss'),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: colors.primary.base,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Got it',
                        style: textTheme.small.copyWith(
                          color: colors.textOnPrimary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A single item tile within the [OiWhatsNew] list.
class _OiWhatsNewItemTile extends StatelessWidget {
  const _OiWhatsNewItemTile({required this.item});

  final OiWhatsNewItem item;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = context.textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icon.
        if (item.icon != null)
          Padding(
            padding: const EdgeInsets.only(right: 12, top: 2),
            child: Icon(
              item.icon,
              size: 24,
              color: colors.primary.base,
            ),
          ),

        // Text content.
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title row with optional version badge.
              Row(
                children: [
                  Flexible(
                    child: Text(
                      item.title,
                      style: textTheme.bodyStrong.copyWith(
                        color: colors.text,
                      ),
                    ),
                  ),
                  if (item.version != null) ...[
                    const SizedBox(width: 8),
                    Container(
                      key: const Key('oi_whats_new_version'),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: colors.surfaceActive,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        item.version!,
                        style: textTheme.tiny.copyWith(
                          color: colors.textMuted,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 4),
              // Description.
              Text(
                item.description,
                style: textTheme.small.copyWith(color: colors.textSubtle),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
