import 'package:obers_ui/obers_ui.dart';
// OiComment.reactions expects the chat-module OiReactionData (with `reacted`).
// ignore: implementation_imports
import 'package:obers_ui/src/modules/oi_chat.dart' as chat;

import 'package:obers_ui_example/data/mock_users.dart';

/// Mock CMS data — blog posts, comments, and form definitions.

// ── Blog posts ────────────────────────────────────────────────────────────────

class MockBlogPost {
  const MockBlogPost({
    required this.id,
    required this.title,
    required this.excerpt,
    required this.author,
    required this.publishedAt,
    required this.category,
    this.tags = const [],
    this.status = 'published',
    this.commentCount = 0,
  });

  final String id;
  final String title;
  final String excerpt;
  final MockUser author;
  final DateTime publishedAt;
  final String category;
  final List<String> tags;
  final String status;
  final int commentCount;
}

final kBlogPosts = [
  MockBlogPost(
    id: 'post-1',
    title: 'The Art of the Perfect Schnitzel: A Scientific Approach',
    excerpt:
        'We tested 47 different breading methods, destroyed 3 frying pans, '
        'and set off a smoke detector. Here are our findings.',
    author: kFranz,
    publishedAt: DateTime(2026, 3, 18),
    category: 'Culinary',
    tags: ['schnitzel', 'cooking', 'science'],
    commentCount: 23,
  ),
  MockBlogPost(
    id: 'post-2',
    title: '5 Hiking Trails Your Lederhosen Deserve',
    excerpt:
        'From the Rax to the Grossglockner: the best routes for beginners, '
        'experts, and those who just want a good Instagram photo.',
    author: kHans,
    publishedAt: DateTime(2026, 3, 12),
    category: 'Outdoor',
    tags: ['hiking', 'alps', 'nature'],
    commentCount: 15,
  ),
  MockBlogPost(
    id: 'post-3',
    title: 'Viennese Coffee House Etiquette: What You Should Never Order',
    excerpt:
        'Spoiler: If you order "a coffee" without specifying which of the 27 '
        'types, the waiter will give you the look of a disappointed grandmother.',
    author: kLiesl,
    publishedAt: DateTime(2026, 3, 5),
    category: 'Culture',
    tags: ['coffee', 'vienna', 'etiquette'],
    commentCount: 42,
  ),
  MockBlogPost(
    id: 'post-4',
    title: "Why Graukäse Is Austria's Most Underrated Food",
    excerpt:
        'A passionate plea for the cheese that even many Austrians mistake '
        'for a laboratory accident.',
    author: kStefan,
    publishedAt: DateTime(2026, 2, 28),
    category: 'Culinary',
    tags: ['cheese', 'tyrol', 'controversial'],
    status: 'draft',
  ),
  MockBlogPost(
    id: 'post-5',
    title: 'How We Built Our Dashboard with Zero Material Widgets',
    excerpt:
        'A deep dive into building a full admin panel using nothing but '
        'obers_ui components. No Material, no Cupertino, no compromises.',
    author: kLiesl,
    publishedAt: DateTime(2026, 2, 14),
    category: 'Tech',
    tags: ['flutter', 'obers_ui', 'engineering'],
    commentCount: 31,
  ),
];

// ── Article content (Markdown) ──────────────────────────────────────────────

const kArticleContent = '''
## Introduction

The Wiener Schnitzel is not merely a dish — it is a philosophical statement
about the relationship between bread, meat, and the human condition.

In this article, we explore the **science** behind the perfect Schnitzel,
including:

- Optimal breading thickness (spoiler: thinner than you think)
- The correct oil temperature (hint: if it smokes, you have failed)
- Why you must **never** press the Schnitzel flat after breading

## The Breading Technique

The traditional three-step coating process — flour, egg, breadcrumbs — has
remained unchanged since the 19th century. Our tests confirm that deviation
from this sacred trinity results in suboptimal crunch.

> "A Schnitzel without proper breading is just a sad piece of meat in denial."
> — Franz Knödel, Marketing Manager and self-appointed Schnitzel expert

## Results

After 47 trials, we can definitively state:

1. **Breadcrumb size matters** — medium grind produces the best texture
2. **Butter + oil blend** wins over pure oil for flavor
3. **Lemon must be served on the side**, never squeezed in advance

## Conclusion

The perfect Schnitzel is achievable in any home kitchen, provided you follow
the rules, respect the ingredients, and resist the urge to use chicken
(unless absolutely necessary).
''';

// ── Comments ────────────────────────────────────────────────────────────────

List<OiComment> buildBlogComments() {
  return [
    OiComment(
      key: 'c1',
      authorId: kMaximilian.id,
      authorName: kMaximilian.name,
      content:
          'Finally someone says it! Graukäse is the unsung hero of Austrian '
          'cuisine.',
      timestamp: DateTime(2026, 3, 1, 10, 30),
      reactions: [
        const chat.OiReactionData(emoji: '🧀', count: 8, reacted: false),
      ],
      replies: [
        OiComment(
          key: 'c1-1',
          authorId: kFranz.id,
          authorName: kFranz.name,
          content:
              'I once tried to bring Graukäse to the office. The colleagues '
              'evacuated the building.',
          timestamp: DateTime(2026, 3, 1, 11, 15),
          reactions: [
            const chat.OiReactionData(emoji: '😂', count: 12, reacted: true),
          ],
        ),
        OiComment(
          key: 'c1-2',
          authorId: kStefan.id,
          authorName: kStefan.name,
          content: 'That was not an evacuation, that was self-preservation.',
          timestamp: DateTime(2026, 3, 1, 11, 45),
          edited: true,
        ),
      ],
    ),
    OiComment(
      key: 'c2',
      authorId: kMaria.id,
      authorName: kMaria.name,
      content:
          'Could we perhaps expand the article with a chapter on Bergkäse? '
          'Asking for a friend.',
      timestamp: DateTime(2026, 3, 2, 9),
    ),
    OiComment(
      key: 'c3',
      authorId: kAnna.id,
      authorName: kAnna.name,
      content:
          'The breading thickness chart is genius. Forwarding this to our '
          'product team immediately.',
      timestamp: DateTime(2026, 3, 3, 14, 20),
      reactions: [
        const chat.OiReactionData(emoji: '👏', count: 5, reacted: true),
      ],
    ),
  ];
}

// ── CMS form fields ─────────────────────────────────────────────────────────

final kCmsFormFields = [
  const OiFormField(
    key: 'title',
    label: 'Title',
    type: OiFieldType.text,
    required: true,
  ),
  const OiFormField(
    key: 'slug',
    label: 'URL Slug',
    type: OiFieldType.text,
  ),
  const OiFormField(
    key: 'category',
    label: 'Category',
    type: OiFieldType.select,
    config: {
      'options': ['Culinary', 'Outdoor', 'Culture', 'Tech', 'Company'],
    },
  ),
  const OiFormField(
    key: 'tags',
    label: 'Tags',
    type: OiFieldType.tag,
  ),
  const OiFormField(
    key: 'publishDate',
    label: 'Publish Date',
    type: OiFieldType.dateTime,
  ),
  const OiFormField(
    key: 'featured',
    label: 'Featured',
    type: OiFieldType.checkbox,
    defaultValue: false,
  ),
  const OiFormField(
    key: 'excerpt',
    label: 'Excerpt',
    type: OiFieldType.text,
    config: {'multiline': true, 'maxLines': 3},
  ),
];

/// Available article categories for filtering.
const kArticleCategories = [
  'Culinary',
  'Outdoor',
  'Culture',
  'Tech',
  'Company',
];
