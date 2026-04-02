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
  OiListSortOption? _activeSort = _sortOptions.first;
  int _currentPage = 0;
  int _perPage = 6;

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
      if (value != null && value is List && value.isNotEmpty) {
        final selected = value.cast<String>();
        posts = posts.where((p) => selected.contains(p.category)).toList();
      } else if (value != null && value is String && value.isNotEmpty) {
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
    final allPosts = _filteredPosts;
    final start = _currentPage * _perPage;
    final pagedPosts = allPosts.skip(start).take(_perPage).toList();

    return OiListView<MockBlogPost>(
      items: pagedPosts,
      itemKey: (post) => post.id,
      label: 'Articles',
      searchQuery: _searchQuery,
      onSearch: (q) => setState(() {
        _searchQuery = q;
        _currentPage = 0;
      }),
      layout: _layout,
      gridColumns: OiResponsive.breakpoints({
        OiBreakpoint.compact: 1,
        OiBreakpoint.medium: 2,
        OiBreakpoint.expanded: 3,
        OiBreakpoint.large: 4,
      }),
      sortOptions: _sortOptions,
      activeSort: _activeSort,
      onSort: (option) => setState(
        () => _activeSort = _activeSort?.id == option.id ? null : option,
      ),
      filters: [
        OiFilterDefinition(
          key: 'category',
          label: 'Category',
          type: OiFilterType.multiSelect,
          options: kArticleCategories
              .map((c) => OiSelectOption(value: c, label: c))
              .toList(),
        ),
      ],
      activeFilters: _activeFilters,
      onFilterChange: (f) => setState(() {
        _activeFilters = f;
        _currentPage = 0;
      }),
      headerActions: OiTooltip(
        label: _layout == OiListViewLayout.grid
            ? 'Switch to list view'
            : 'Switch to grid view',
        message: _layout == OiListViewLayout.grid
            ? 'Switch to list view'
            : 'Switch to grid view',
        child: OiIconButton(
          icon: _layout == OiListViewLayout.grid
              ? OiIcons.layoutList
              : OiIcons.layoutGrid,
          semanticLabel: 'Toggle layout',
          onTap: () => setState(
            () => _layout = _layout == OiListViewLayout.list
                ? OiListViewLayout.grid
                : OiListViewLayout.list,
          ),
        ),
      ),
      footer: OiPagination(
        label: 'articles',
        totalItems: allPosts.length,
        currentPage: _currentPage,
        perPage: _perPage,
        onPageChange: (page) => setState(() => _currentPage = page),
        onPerPageChange: (perPage) => setState(() {
          _perPage = perPage;
          _currentPage = 0;
        }),
      ),
      itemBuilder: (post) => _layout == OiListViewLayout.grid
          ? _ArticleGridCard(
              post: post,
              onTap: () => widget.onArticleTap(post),
            )
          : _ArticleListCard(
              post: post,
              onTap: () => widget.onArticleTap(post),
            ),
    );
  }
}

// ── Grid card ────────────────────────────────────────────────────────────────

class _ArticleGridCard extends StatelessWidget {
  const _ArticleGridCard({required this.post, required this.onTap});

  final MockBlogPost post;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OiCard(
      label: 'Open article: ${post.title}',
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (post.imageUrl != null)
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(8)),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: OiImage(
                  src: post.imageUrl!,
                  alt: post.title,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _ArticleMeta(post: post),
                SizedBox(height: context.spacing.sm),
                OiLabel.h4(
                  post.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: context.spacing.sm),
                OiLabel.body(
                  post.excerpt,
                  color: context.colors.textSubtle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── List card ────────────────────────────────────────────────────────────────

class _ArticleListCard extends StatelessWidget {
  const _ArticleListCard({required this.post, required this.onTap});

  final MockBlogPost post;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return OiCard(
      label: 'Open article: ${post.title}',
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (post.imageUrl != null)
              ClipRRect(
                borderRadius:
                    const BorderRadius.horizontal(left: Radius.circular(8)),
                child: SizedBox(
                  width: 160,
                  child: OiImage(
                    src: post.imageUrl!,
                    alt: post.title,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _ArticleMeta(post: post),
                    SizedBox(height: context.spacing.sm),
                    OiLabel.h4(
                      post.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: context.spacing.sm),
                    OiLabel.body(
                      post.excerpt,
                      color: colors.textSubtle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    _ArticleCommentCount(post: post),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Shared parts ─────────────────────────────────────────────────────────────

class _ArticleMeta extends StatelessWidget {
  const _ArticleMeta({required this.post});

  final MockBlogPost post;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
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
        OiBadge.soft(
          label: post.status,
          color: post.status == 'published'
              ? OiBadgeColor.success
              : OiBadgeColor.warning,
        ),
      ],
    );
  }
}

class _ArticleCommentCount extends StatelessWidget {
  const _ArticleCommentCount({required this.post});

  final MockBlogPost post;

  @override
  Widget build(BuildContext context) {
    if (post.commentCount <= 0) return const SizedBox.shrink();

    final colors = context.colors;

    return Padding(
      padding: EdgeInsets.only(top: context.spacing.sm),
      child: Row(
        children: [
          Icon(OiIcons.messageSquare, size: 16, color: colors.textMuted),
          const SizedBox(width: 4),
          OiLabel.small('${post.commentCount}', color: colors.textMuted),
        ],
      ),
    );
  }
}
