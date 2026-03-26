import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';

import 'package:obers_ui_example/data/mock_cms.dart';

/// Article list screen using OiListView with search, category filter, sort
/// options, and layout toggle.
class CmsArticlesScreen extends StatefulWidget {
  const CmsArticlesScreen({required this.onArticleTap, super.key});

  final ValueChanged<MockBlogPost> onArticleTap;

  @override
  State<CmsArticlesScreen> createState() => _CmsArticlesScreenState();
}

class _CmsArticlesScreenState extends State<CmsArticlesScreen> {
  String _searchQuery = '';
  Map<String, OiColumnFilter> _activeFilters = {};
  OiListViewLayout _layout = OiListViewLayout.list;
  OiListSortOption? _activeSort;

  static const _sortOptions = [
    OiListSortOption(id: 'date-desc', label: 'Newest first'),
    OiListSortOption(id: 'date-asc', label: 'Oldest first'),
    OiListSortOption(id: 'title-asc', label: 'Title A\u2013Z'),
    OiListSortOption(id: 'title-desc', label: 'Title Z\u2013A'),
    OiListSortOption(id: 'comments', label: 'Most comments'),
  ];

  List<MockBlogPost> get _filteredPosts {
    var posts = List.of(kBlogPosts);

    // Search filter
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      posts = posts
          .where(
            (p) =>
                p.title.toLowerCase().contains(query) ||
                p.excerpt.toLowerCase().contains(query),
          )
          .toList();
    }

    // Category filter
    final category = _activeFilters['category'];
    if (category != null) {
      final value = category.value;
      if (value != null && value is String && value.isNotEmpty) {
        posts = posts.where((p) => p.category == value).toList();
      }
    }

    // Sorting
    if (_activeSort != null) {
      switch (_activeSort!.id) {
        case 'date-desc':
          posts.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
        case 'date-asc':
          posts.sort((a, b) => a.publishedAt.compareTo(b.publishedAt));
        case 'title-asc':
          posts.sort(
            (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
          );
        case 'title-desc':
          posts.sort(
            (a, b) => b.title.toLowerCase().compareTo(a.title.toLowerCase()),
          );
        case 'comments':
          posts.sort((a, b) => b.commentCount.compareTo(a.commentCount));
      }
    }

    return posts;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return OiListView<MockBlogPost>(
      items: _filteredPosts,
      itemKey: (post) => post.id,
      label: 'Articles',
      searchQuery: _searchQuery,
      onSearch: (q) => setState(() => _searchQuery = q),
      layout: _layout,
      sortOptions: _sortOptions,
      activeSort: _activeSort,
      onSort: (option) => setState(
        () => _activeSort = _activeSort?.id == option.id ? null : option,
      ),
      filters: [
        OiFilterDefinition(
          key: 'category',
          label: 'Category',
          type: OiFilterType.select,
          options: kArticleCategories
              .map((c) => OiSelectOption(value: c, label: c))
              .toList(),
        ),
      ],
      activeFilters: _activeFilters,
      onFilterChange: (f) => setState(() => _activeFilters = f),
      headerActions: OiIconButton(
        icon: _layout == OiListViewLayout.grid
            ? OiIcons.menu
            : OiIcons.layoutGrid,
        semanticLabel: 'Toggle layout',
        onTap: () => setState(
          () => _layout = _layout == OiListViewLayout.list
              ? OiListViewLayout.grid
              : OiListViewLayout.list,
        ),
      ),
      itemBuilder: (post) => OiCard(
        label: 'Open article: ${post.title}',
        onTap: () => widget.onArticleTap(post),
        title: OiLabel.h4(post.title, maxLines: 2, overflow: TextOverflow.ellipsis),
        subtitle: Padding(
          padding: EdgeInsets.only(top: context.spacing.sm),
          child: Row(
            children: [
              Expanded(
                child: OiLabel.small(
                  '${post.author.name}  \u2022  '
                  '${post.publishedAt.year}-'
                  '${post.publishedAt.month.toString().padLeft(2, '0')}-'
                  '${post.publishedAt.day.toString().padLeft(2, '0')}',
                  color: colors.textMuted,
                ),
              ),
              if (post.commentCount > 0) ...[
                Icon(OiIcons.messageSquare, size: 16, color: colors.textMuted),
                const SizedBox(width: 4),
                OiLabel.small('${post.commentCount}', color: colors.textMuted),
                const SizedBox(width: 12),
              ],
              OiBadge.soft(
                label: post.status,
                color: post.status == 'published'
                    ? OiBadgeColor.success
                    : OiBadgeColor.warning,
              ),
            ],
          ),
        ),
        child: Padding(
          padding: EdgeInsets.only(top: context.spacing.md),
          child: OiLabel.body(
            post.excerpt,
            color: colors.textSubtle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}
