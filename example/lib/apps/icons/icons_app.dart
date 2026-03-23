import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';

import 'package:obers_ui_example/apps/icons/icon_entries.dart';
import 'package:obers_ui_example/shell/showcase_shell.dart';
import 'package:obers_ui_example/theme/theme_state.dart';

/// Showcase screen for browsing, searching, and filtering all 1,951 Lucide icons.
class IconsApp extends StatefulWidget {
  const IconsApp({required this.themeState, super.key});

  final ThemeState themeState;

  @override
  State<IconsApp> createState() => _IconsAppState();
}

class _IconsAppState extends State<IconsApp> {
  String _search = '';
  String _category = 'all';

  List<IconEntry> get _filtered {
    var icons = allIcons;
    if (_category != 'all') {
      icons = icons.where((e) => e.category == _category).toList();
    }
    if (_search.isNotEmpty) {
      icons = icons.where((e) => e.matches(_search)).toList();
    }
    return icons;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final filtered = _filtered;

    return ShowcaseShell(
      title: 'Icons',
      themeState: widget.themeState,
      child: Column(
        children: [
          // ── Search + Filter bar ──────────────────────────────────────
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: spacing.lg,
              vertical: spacing.md,
            ),
            decoration: BoxDecoration(
              color: colors.surface,
              border: Border(
                bottom: BorderSide(color: colors.borderSubtle),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                OiTextInput.search(
                  onChanged: (v) => setState(() => _search = v),
                ),
                SizedBox(height: spacing.sm),
                SizedBox(
                  height: 36,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _CategoryChip(
                        label: 'All',
                        selected: _category == 'all',
                        onTap: () => setState(() => _category = 'all'),
                      ),
                      SizedBox(width: spacing.xs),
                      for (final cat in allCategories) ...[
                        _CategoryChip(
                          label: _formatCategory(cat),
                          selected: _category == cat,
                          onTap: () => setState(() => _category = cat),
                        ),
                        SizedBox(width: spacing.xs),
                      ],
                    ],
                  ),
                ),
                SizedBox(height: spacing.xs),
                OiLabel.caption(
                  '${filtered.length} icon${filtered.length == 1 ? '' : 's'}',
                  color: colors.textSubtle,
                ),
              ],
            ),
          ),

          // ── Icon grid ───────────────────────────────────────────────
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: OiLabel.body(
                      'No icons match your search.',
                      color: colors.textSubtle,
                    ),
                  )
                : GridView.builder(
                    padding: EdgeInsets.all(spacing.lg),
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 120,
                      mainAxisSpacing: spacing.sm,
                      crossAxisSpacing: spacing.sm,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: filtered.length,
                    itemBuilder: (context, i) => _IconTile(
                      entry: filtered[i],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  String _formatCategory(String cat) {
    return cat
        .split('-')
        .map((w) => '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }
}

// ── Icon tile ─────────────────────────────────────────────────────────────────

class _IconTile extends StatelessWidget {
  const _IconTile({required this.entry});

  final IconEntry entry;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final radius = context.radius;

    return OiTappable(
      semanticLabel: '${entry.name} icon — tap to copy name',
      onTap: () {
        Clipboard.setData(ClipboardData(text: 'OiIcons.${entry.name}'));
        OiToast.show(
          context,
          message: 'Copied OiIcons.${entry.name}',
        );
      },
      child: Container(
        padding: EdgeInsets.all(spacing.sm),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: radius.sm,
          border: Border.all(color: colors.borderSubtle),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(entry.icon, size: 28, color: colors.text),
            SizedBox(height: spacing.xs),
            OiLabel.caption(
              entry.name,
              color: colors.textSubtle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Category chip ─────────────────────────────────────────────────────────────

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final radius = context.radius;

    return OiTappable(
      semanticLabel: '$label category filter',
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? colors.primary.base : colors.surfaceHover,
          borderRadius: radius.full,
          border: Border.all(
            color: selected ? colors.primary.base : colors.borderSubtle,
          ),
        ),
        child: OiLabel.caption(
          label,
          color: selected ? colors.primary.foreground : colors.textSubtle,
        ),
      ),
    );
  }
}
