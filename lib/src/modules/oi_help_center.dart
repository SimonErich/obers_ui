import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/buttons/oi_button.dart';
import 'package:obers_ui/src/components/display/oi_empty_state.dart';
import 'package:obers_ui/src/components/display/oi_markdown.dart';
import 'package:obers_ui/src/components/feedback/oi_star_rating.dart';
import 'package:obers_ui/src/components/inputs/oi_text_input.dart';
import 'package:obers_ui/src/foundation/oi_icons.dart';
import 'package:obers_ui/src/foundation/oi_responsive.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/display/oi_divider.dart';
import 'package:obers_ui/src/primitives/display/oi_label.dart';
import 'package:obers_ui/src/primitives/interaction/oi_tappable.dart';

// ---------------------------------------------------------------------------
// Data models
// ---------------------------------------------------------------------------

/// A frequently asked question.
///
/// {@category Modules}
@immutable
class OiFaqItem {
  /// Creates an [OiFaqItem].
  const OiFaqItem({
    required this.question,
    required this.answer,
    this.category,
    this.keywords = const [],
  });

  /// The question text.
  final String question;

  /// The answer text, supports Markdown.
  final String answer;

  /// An optional category for grouping.
  final String? category;

  /// Additional keywords used for search matching.
  final List<String> keywords;
}

/// A knowledge base article.
///
/// {@category Modules}
@immutable
class OiKnowledgeArticle {
  /// Creates an [OiKnowledgeArticle].
  const OiKnowledgeArticle({
    required this.key,
    required this.title,
    required this.content,
    this.category,
    this.tags = const [],
    this.lastUpdated,
  });

  /// A unique key for this article.
  final Object key;

  /// The article title.
  final String title;

  /// The article content in Markdown.
  final String content;

  /// An optional category for grouping.
  final String? category;

  /// Tags for filtering and search.
  final List<String> tags;

  /// When this article was last updated.
  final DateTime? lastUpdated;
}

// ---------------------------------------------------------------------------
// Tab descriptor
// ---------------------------------------------------------------------------

enum _HelpTab {
  faq('FAQ', OiIcons.helpCircle),
  contact('Contact', OiIcons.messageCircle),
  articles('Articles', OiIcons.bookOpen),
  feedback('Feedback', OiIcons.star);

  const _HelpTab(this.label, this.icon);
  final String label;
  final IconData icon;
}

// ---------------------------------------------------------------------------
// Widget
// ---------------------------------------------------------------------------

/// A help center module with FAQ, contact form, knowledge base, and feedback.
///
/// Combines four optional sections into a tabbed interface. Each section can
/// be individually enabled or disabled via the `showFaq`, `showContact`,
/// `showKnowledgeBase`, and `showFeedback` flags.
///
/// {@category Modules}
class OiHelpCenter extends StatefulWidget {
  /// Creates an [OiHelpCenter].
  const OiHelpCenter({
    required this.label,
    this.faq = const [],
    this.articles = const [],
    this.onContactSubmit,
    this.onFeedbackSubmit,
    this.showFaq = true,
    this.showContact = true,
    this.showKnowledgeBase = true,
    this.showFeedback = true,
    this.searchEnabled = true,
    super.key,
  });

  /// Accessible label for the help center.
  final String label;

  /// The list of frequently asked questions.
  final List<OiFaqItem> faq;

  /// The list of knowledge base articles.
  final List<OiKnowledgeArticle> articles;

  /// Callback invoked when the contact form is submitted. Return `true` for
  /// success, `false` for failure.
  final Future<bool> Function({
    required String subject,
    required String message,
    String? email,
  })?
  onContactSubmit;

  /// Callback invoked when feedback is submitted. Return `true` for success.
  final Future<bool> Function({required int rating, String? comment})?
  onFeedbackSubmit;

  /// Whether to show the FAQ tab.
  final bool showFaq;

  /// Whether to show the Contact tab.
  final bool showContact;

  /// Whether to show the Knowledge Base tab.
  final bool showKnowledgeBase;

  /// Whether to show the Feedback tab.
  final bool showFeedback;

  /// Whether the search bar is visible.
  final bool searchEnabled;

  @override
  State<OiHelpCenter> createState() => _OiHelpCenterState();
}

class _OiHelpCenterState extends State<OiHelpCenter> {
  int _activeTab = 0;
  String _searchQuery = '';
  final _searchController = TextEditingController();

  // FAQ state
  final Set<int> _expandedFaqIndices = {};

  // Knowledge base state
  OiKnowledgeArticle? _selectedArticle;

  // Contact form state
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  final _emailController = TextEditingController();
  bool _contactSubmitting = false;
  bool _contactSubmitted = false;

  // Feedback state
  double _feedbackRating = 0;
  final _feedbackCommentController = TextEditingController();
  bool _feedbackSubmitting = false;
  bool _feedbackSubmitted = false;

  List<_HelpTab> get _availableTabs {
    return [
      if (widget.showFaq) _HelpTab.faq,
      if (widget.showContact) _HelpTab.contact,
      if (widget.showKnowledgeBase) _HelpTab.articles,
      if (widget.showFeedback) _HelpTab.feedback,
    ];
  }

  @override
  void didUpdateWidget(OiHelpCenter oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Ensure active tab stays in range when tabs are toggled.
    final tabs = _availableTabs;
    if (_activeTab >= tabs.length && tabs.isNotEmpty) {
      _activeTab = 0;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    _emailController.dispose();
    _feedbackCommentController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Search
  // ---------------------------------------------------------------------------

  bool _matchesQuery(String text) {
    if (_searchQuery.isEmpty) return true;
    return text.toLowerCase().contains(_searchQuery.toLowerCase());
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final tabs = _availableTabs;
    if (tabs.isEmpty) {
      return Semantics(
        label: widget.label,
        container: true,
        child: const OiEmptyState(title: 'No help sections available'),
      );
    }

    final isDesktop =
        context.breakpoint.minWidth >= OiBreakpoint.expanded.minWidth;

    if (isDesktop) {
      return Semantics(
        label: widget.label,
        container: true,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 240,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (widget.searchEnabled) _buildSearch(context),
                      Expanded(child: _buildSidebar(context, tabs)),
                    ],
                  ),
                ),
                SizedBox(width: context.spacing.lg),
                Expanded(child: _buildTabContent(tabs)),
              ],
            ),
          ),
        ),
      );
    }

    return Semantics(
      label: widget.label,
      container: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.searchEnabled) _buildSearch(context),
          _buildTabRow(context, tabs),
          const OiDivider(),
          Expanded(child: _buildTabContent(tabs)),
        ],
      ),
    );
  }

  Widget _buildSidebar(BuildContext context, List<_HelpTab> tabs) {
    final colors = context.colors;
    final spacing = context.spacing;
    final radius = context.radius;

    return ListView(
      children: [
        for (var i = 0; i < tabs.length; i++)
          OiTappable(
            semanticLabel: '${tabs[i].label} tab',
            onTap: () => setState(() => _activeTab = i),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: spacing.sm,
                vertical: spacing.sm,
              ),
              decoration: BoxDecoration(
                color: _activeTab == i
                    ? colors.primary.base.withValues(alpha: 0.08)
                    : null,
                borderRadius: radius.sm,
              ),
              child: Row(
                children: [
                  Icon(
                    tabs[i].icon,
                    size: 16,
                    color: _activeTab == i
                        ? colors.primary.base
                        : colors.textMuted,
                  ),
                  SizedBox(width: spacing.sm),
                  Expanded(
                    child: OiLabel.body(
                      tabs[i].label,
                      color: _activeTab == i
                          ? colors.primary.base
                          : colors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSearch(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: context.spacing.sm),
      child: OiTextInput.search(
        controller: _searchController,
        onChanged: (value) => setState(() => _searchQuery = value),
      ),
    );
  }

  Widget _buildTabRow(BuildContext context, List<_HelpTab> tabs) {
    final colors = context.colors;
    final spacing = context.spacing;

    return Padding(
      padding: EdgeInsets.only(bottom: spacing.xs),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (var i = 0; i < tabs.length; i++) ...[
              if (i > 0) SizedBox(width: spacing.sm),
              _buildTab(context, tabs[i], i, colors),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTab(
    BuildContext context,
    _HelpTab tab,
    int index,
    dynamic colors,
  ) {
    final isActive = _activeTab == index;
    return OiTappable(
      semanticLabel: '${tab.label} tab',
      onTap: () => setState(() => _activeTab = index),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: context.spacing.sm,
          vertical: context.spacing.xs,
        ),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isActive
                  ? context.colors.primary.base
                  : const Color(0x00000000),
              width: 2,
            ),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              tab.icon,
              size: 16,
              color: isActive
                  ? context.colors.primary.base
                  : context.colors.textMuted,
            ),
            SizedBox(width: context.spacing.xs),
            OiLabel.small(
              tab.label,
              color: isActive
                  ? context.colors.primary.base
                  : context.colors.textMuted,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent(List<_HelpTab> tabs) {
    if (_activeTab >= tabs.length) return const SizedBox.shrink();
    return switch (tabs[_activeTab]) {
      _HelpTab.faq => _buildFaqTab(),
      _HelpTab.contact => _buildContactTab(),
      _HelpTab.articles => _buildKnowledgeBaseTab(),
      _HelpTab.feedback => _buildFeedbackTab(),
    };
  }

  // ---------------------------------------------------------------------------
  // FAQ tab
  // ---------------------------------------------------------------------------

  Widget _buildFaqTab() {
    final filtered = <int>[];
    for (var i = 0; i < widget.faq.length; i++) {
      final item = widget.faq[i];
      if (_matchesQuery(item.question) ||
          _matchesQuery(item.answer) ||
          item.keywords.any(_matchesQuery)) {
        filtered.add(i);
      }
    }

    if (filtered.isEmpty) {
      return const Center(
        child: OiEmptyState(
          title: 'No matching questions',
          icon: OiIcons.helpCircle,
        ),
      );
    }

    return ListView.builder(
      itemCount: filtered.length,
      itemBuilder: (context, listIndex) {
        final faqIndex = filtered[listIndex];
        final item = widget.faq[faqIndex];
        final expanded = _expandedFaqIndices.contains(faqIndex);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            OiTappable(
              semanticLabel:
                  '${item.question}, ${expanded ? 'expanded' : 'collapsed'}',
              onTap: () {
                setState(() {
                  if (expanded) {
                    _expandedFaqIndices.remove(faqIndex);
                  } else {
                    _expandedFaqIndices.add(faqIndex);
                  }
                });
              },
              child: Padding(
                padding: EdgeInsets.symmetric(
                  vertical: context.spacing.sm,
                  horizontal: context.spacing.xs,
                ),
                child: Row(
                  children: [
                    Expanded(child: OiLabel.bodyStrong(item.question)),
                    Icon(
                      expanded ? OiIcons.chevronUp : OiIcons.chevronDown,
                      size: 16,
                      color: context.colors.textMuted,
                    ),
                  ],
                ),
              ),
            ),
            if (expanded)
              Padding(
                padding: EdgeInsets.only(
                  left: context.spacing.xs,
                  right: context.spacing.xs,
                  bottom: context.spacing.sm,
                ),
                child: OiMarkdown(data: item.answer),
              ),
            const OiDivider(),
          ],
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Contact tab
  // ---------------------------------------------------------------------------

  Widget _buildContactTab() {
    if (_contactSubmitted) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              OiIcons.messageCircle,
              size: 48,
              color: context.colors.success.base,
            ),
            SizedBox(height: context.spacing.sm),
            const OiLabel.h3('Message sent'),
            SizedBox(height: context.spacing.xs),
            OiLabel.body(
              'We will get back to you as soon as possible.',
              color: context.colors.textMuted,
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(vertical: context.spacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OiTextInput(
            controller: _subjectController,
            label: 'Subject',
            placeholder: 'What do you need help with?',
          ),
          SizedBox(height: context.spacing.sm),
          OiTextInput(
            controller: _emailController,
            label: 'Email (optional)',
            placeholder: 'your@email.com',
            keyboardType: TextInputType.emailAddress,
          ),
          SizedBox(height: context.spacing.sm),
          OiTextInput.multiline(
            controller: _messageController,
            label: 'Message',
            placeholder: 'Describe your issue...',
            minLines: 4,
          ),
          SizedBox(height: context.spacing.md),
          OiButton.primary(
            label: 'Send message',
            semanticLabel: 'Send contact message',
            loading: _contactSubmitting,
            enabled: !_contactSubmitting,
            onTap: _handleContactSubmit,
          ),
        ],
      ),
    );
  }

  Future<void> _handleContactSubmit() async {
    final subject = _subjectController.text.trim();
    final message = _messageController.text.trim();
    if (subject.isEmpty || message.isEmpty) return;

    setState(() => _contactSubmitting = true);

    final email = _emailController.text.trim();
    final success =
        await widget.onContactSubmit?.call(
          subject: subject,
          message: message,
          email: email.isNotEmpty ? email : null,
        ) ??
        true;

    if (!mounted) return;

    setState(() {
      _contactSubmitting = false;
      if (success) _contactSubmitted = true;
    });
  }

  // ---------------------------------------------------------------------------
  // Knowledge base tab
  // ---------------------------------------------------------------------------

  Widget _buildKnowledgeBaseTab() {
    if (_selectedArticle != null) {
      return _buildArticleDetail(_selectedArticle!);
    }

    final filtered = widget.articles.where((a) {
      return _matchesQuery(a.title) ||
          _matchesQuery(a.content) ||
          (a.category != null && _matchesQuery(a.category!)) ||
          a.tags.any(_matchesQuery);
    }).toList();

    if (filtered.isEmpty) {
      return const Center(
        child: OiEmptyState(
          title: 'No matching articles',
          icon: OiIcons.bookOpen,
        ),
      );
    }

    return ListView.builder(
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final article = filtered[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            OiTappable(
              semanticLabel: article.title,
              onTap: () => setState(() => _selectedArticle = article),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  vertical: context.spacing.sm,
                  horizontal: context.spacing.xs,
                ),
                child: Row(
                  children: [
                    Icon(
                      OiIcons.bookOpen,
                      size: 16,
                      color: context.colors.textMuted,
                    ),
                    SizedBox(width: context.spacing.xs),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          OiLabel.bodyStrong(article.title),
                          if (article.category != null)
                            OiLabel.caption(
                              article.category!,
                              color: context.colors.textMuted,
                            ),
                        ],
                      ),
                    ),
                    Icon(
                      OiIcons.chevronDown,
                      size: 14,
                      color: context.colors.textMuted,
                    ),
                  ],
                ),
              ),
            ),
            const OiDivider(),
          ],
        );
      },
    );
  }

  Widget _buildArticleDetail(OiKnowledgeArticle article) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: context.spacing.xs),
          child: Row(
            children: [
              OiTappable(
                semanticLabel: 'Back to articles',
                onTap: () => setState(() => _selectedArticle = null),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      OiIcons.arrowLeft,
                      size: 16,
                      color: context.colors.primary.base,
                    ),
                    SizedBox(width: context.spacing.xs),
                    OiLabel.small('Back', color: context.colors.primary.base),
                  ],
                ),
              ),
            ],
          ),
        ),
        const OiDivider(),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(vertical: context.spacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                OiLabel.h3(article.title),
                if (article.lastUpdated != null) ...[
                  SizedBox(height: context.spacing.xs),
                  OiLabel.caption(
                    'Last updated: ${_formatDate(article.lastUpdated!)}',
                    color: context.colors.textMuted,
                  ),
                ],
                SizedBox(height: context.spacing.md),
                OiMarkdown(data: article.content),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  // ---------------------------------------------------------------------------
  // Feedback tab
  // ---------------------------------------------------------------------------

  Widget _buildFeedbackTab() {
    if (_feedbackSubmitted) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(OiIcons.star, size: 48, color: context.colors.warning.base),
            SizedBox(height: context.spacing.sm),
            const OiLabel.h3('Thank you!'),
            SizedBox(height: context.spacing.xs),
            OiLabel.body(
              'Your feedback helps us improve.',
              color: context.colors.textMuted,
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(vertical: context.spacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const OiLabel.bodyStrong('How would you rate your experience?'),
          SizedBox(height: context.spacing.sm),
          OiStarRating(
            label: 'Experience rating',
            value: _feedbackRating,
            size: 32,
            onChanged: (value) => setState(() => _feedbackRating = value),
          ),
          SizedBox(height: context.spacing.md),
          OiTextInput.multiline(
            controller: _feedbackCommentController,
            label: 'Additional comments (optional)',
            placeholder: 'Tell us more about your experience...',
          ),
          SizedBox(height: context.spacing.md),
          OiButton.primary(
            label: 'Submit feedback',
            semanticLabel: 'Submit feedback',
            loading: _feedbackSubmitting,
            enabled: !_feedbackSubmitting && _feedbackRating > 0,
            onTap: _handleFeedbackSubmit,
          ),
        ],
      ),
    );
  }

  Future<void> _handleFeedbackSubmit() async {
    if (_feedbackRating <= 0) return;

    setState(() => _feedbackSubmitting = true);

    final comment = _feedbackCommentController.text.trim();
    final success =
        await widget.onFeedbackSubmit?.call(
          rating: _feedbackRating.round(),
          comment: comment.isNotEmpty ? comment : null,
        ) ??
        true;

    if (!mounted) return;

    setState(() {
      _feedbackSubmitting = false;
      if (success) _feedbackSubmitted = true;
    });
  }
}
