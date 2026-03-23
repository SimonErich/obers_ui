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
    // ── Thread 1: Graukäse debate (1 top-level + 5 replies = 6) ──────────
    OiComment(
      key: 'c1',
      authorId: kMaximilian.id,
      authorName: kMaximilian.name,
      content:
          'Finally someone says it! Graukäse is the unsung hero of Austrian '
          'cuisine. Every Kaffeehaus should serve it alongside the Melange.',
      timestamp: DateTime(2026, 3, 1, 10, 30),
      reactions: [
        const chat.OiReactionData(emoji: '🧀', count: 8, reacted: false),
        const chat.OiReactionData(emoji: '💯', count: 3, reacted: false),
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
          replies: [
            OiComment(
              key: 'c1-1-1',
              authorId: kStefan.id,
              authorName: kStefan.name,
              content:
                  'That was not an evacuation, that was self-preservation.',
              timestamp: DateTime(2026, 3, 1, 11, 45),
              edited: true,
            ),
            OiComment(
              key: 'c1-1-2',
              authorId: kKlara.id,
              authorName: kKlara.name,
              content:
                  'The smell lingered in the kitchen for three days. HR '
                  'sent a company-wide email about "aromatic workplace '
                  'boundaries."',
              timestamp: DateTime(2026, 3, 1, 12, 10),
              reactions: [
                const chat.OiReactionData(
                  emoji: '💀',
                  count: 6,
                  reacted: false,
                ),
              ],
            ),
          ],
        ),
        OiComment(
          key: 'c1-2',
          authorId: kGertrud.id,
          authorName: kGertrud.name,
          content:
              'Graukäse with Essig and Zwiebel is the true test of '
              'whether someone deserves Austrian citizenship.',
          timestamp: DateTime(2026, 3, 1, 14, 30),
          reactions: [
            const chat.OiReactionData(emoji: '🇦🇹', count: 9, reacted: true),
          ],
        ),
        OiComment(
          key: 'c1-3',
          authorId: kHans.id,
          authorName: kHans.name,
          content:
              'My grandmother in Tyrol makes the best Graukäse. She would '
              'be offended by anyone calling it "smelly cheese."',
          timestamp: DateTime(2026, 3, 1, 16),
        ),
      ],
    ),

    // ── Thread 2: Kaffeehaus ordering etiquette (1 + 4 = 5) ─────────────
    OiComment(
      key: 'c2',
      authorId: kMaria.id,
      authorName: kMaria.name,
      content:
          'The part about ordering "a coffee" without specifying which '
          'of the 27 types is painfully accurate. I once saw a tourist '
          'ask for a "regular coffee" at Café Central. The waiter sighed '
          'so loudly it echoed.',
      timestamp: DateTime(2026, 3, 2, 9),
      reactions: [
        const chat.OiReactionData(emoji: '☕', count: 14, reacted: false),
      ],
      replies: [
        OiComment(
          key: 'c2-1',
          authorId: kLiesl.id,
          authorName: kLiesl.name,
          content:
              'Ordering a "Latte" in Vienna is the quickest way to '
              'receive a glass of warm milk and a look of pity.',
          timestamp: DateTime(2026, 3, 2, 9, 30),
          reactions: [
            const chat.OiReactionData(emoji: '😂', count: 7, reacted: true),
          ],
        ),
        OiComment(
          key: 'c2-2',
          authorId: kFriederike.id,
          authorName: kFriederike.name,
          content:
              'Pro tip: always order a Melange if unsure. It is the '
              'universal safe choice and the waiter will nod approvingly.',
          timestamp: DateTime(2026, 3, 2, 10, 15),
          reactions: [
            const chat.OiReactionData(emoji: '👍', count: 5, reacted: false),
          ],
        ),
        OiComment(
          key: 'c2-3',
          authorId: kPeter.id,
          authorName: kPeter.name,
          content:
              'I once ordered an Einspänner and the waiter actually '
              'smiled. I think I peaked that day.',
          timestamp: DateTime(2026, 3, 2, 11),
        ),
        OiComment(
          key: 'c2-4',
          authorId: kTheresa.id,
          authorName: kTheresa.name,
          content:
              'Do NOT order a Cappuccino after 11:00. The Italians will '
              'forgive you, but the Viennese waiter will not.',
          timestamp: DateTime(2026, 3, 2, 14, 20),
          reactions: [
            const chat.OiReactionData(emoji: '⏰', count: 3, reacted: false),
          ],
        ),
      ],
    ),

    // ── Thread 3: Article feedback (1 + 3 = 4) ──────────────────────────
    OiComment(
      key: 'c3',
      authorId: kAnna.id,
      authorName: kAnna.name,
      content:
          'The breading thickness chart is genius. Forwarding this to our '
          'product team immediately. We should add this to the Schnitzel Kit '
          'packaging.',
      timestamp: DateTime(2026, 3, 3, 14, 20),
      reactions: [
        const chat.OiReactionData(emoji: '👏', count: 5, reacted: true),
      ],
      replies: [
        OiComment(
          key: 'c3-1',
          authorId: kFranz.id,
          authorName: kFranz.name,
          content:
              'Already on it! The marketing team is designing an '
              'infographic version for social media.',
          timestamp: DateTime(2026, 3, 3, 15),
        ),
        OiComment(
          key: 'c3-2',
          authorId: kElisabeth.id,
          authorName: kElisabeth.name,
          content:
              'Could we also add a QR code linking to the full article? '
              'That way people can reference it while cooking.',
          timestamp: DateTime(2026, 3, 3, 15, 30),
          reactions: [
            const chat.OiReactionData(emoji: '💡', count: 4, reacted: false),
          ],
        ),
        OiComment(
          key: 'c3-3',
          authorId: kAnna.id,
          authorName: kAnna.name,
          content: 'Love that idea! Let me create a ticket for it.',
          timestamp: DateTime(2026, 3, 3, 16),
        ),
      ],
    ),

    // ── Thread 4: Graukäse controversy continues (1 + 5 = 6) ────────────
    OiComment(
      key: 'c4',
      authorId: kWolfgang.id,
      authorName: kWolfgang.name,
      content:
          'Hot take: Graukäse on a warm Bauernbrot with butter is superior '
          'to any French cheese board. Fight me.',
      timestamp: DateTime(2026, 3, 4, 8, 45),
      reactions: [
        const chat.OiReactionData(emoji: '🔥', count: 11, reacted: false),
        const chat.OiReactionData(emoji: '🧀', count: 4, reacted: true),
      ],
      replies: [
        OiComment(
          key: 'c4-1',
          authorId: kKaspar.id,
          authorName: kKaspar.name,
          content:
              'As someone from Innsbruck, I approve this message. '
              'Graukäse is the hill I am willing to die on.',
          timestamp: DateTime(2026, 3, 4, 9, 15),
        ),
        OiComment(
          key: 'c4-2',
          authorId: kIgnaz.id,
          authorName: kIgnaz.name,
          content:
              'The numbers support this. Our Graukäse sales have '
              'increased 340% since we started the blog series.',
          timestamp: DateTime(2026, 3, 4, 10),
          reactions: [
            const chat.OiReactionData(emoji: '📈', count: 7, reacted: false),
          ],
        ),
        OiComment(
          key: 'c4-3',
          authorId: kFerdinand.id,
          authorName: kFerdinand.name,
          content:
              'I deployed the Graukäse landing page last night. '
              'Traffic is already through the roof.',
          timestamp: DateTime(2026, 3, 4, 11, 30),
        ),
        OiComment(
          key: 'c4-4',
          authorId: kRosalinde.id,
          authorName: kRosalinde.name,
          content:
              'Can we please stop calling it "smelly cheese" in the '
              'Slack channel? HR has received complaints.',
          timestamp: DateTime(2026, 3, 4, 13),
          edited: true,
        ),
        OiComment(
          key: 'c4-5',
          authorId: kMaximilian.id,
          authorName: kMaximilian.name,
          content:
              'Rosalinde is right. From now on, we refer to it as '
              '"aromatic heritage dairy product."',
          timestamp: DateTime(2026, 3, 4, 13, 30),
          reactions: [
            const chat.OiReactionData(emoji: '😂', count: 15, reacted: true),
          ],
        ),
      ],
    ),

    // ── Thread 5: Waiter anecdote (1 + 4 = 5) ──────────────────────────
    OiComment(
      key: 'c5',
      authorId: kOtto.id,
      authorName: kOtto.name,
      content:
          'My favourite Kaffeehaus rule: never rush the waiter. '
          'They will come to you when they are emotionally ready.',
      timestamp: DateTime(2026, 3, 5, 10),
      reactions: [
        const chat.OiReactionData(emoji: '😌', count: 8, reacted: false),
      ],
      replies: [
        OiComment(
          key: 'c5-1',
          authorId: kRupert.id,
          authorName: kRupert.name,
          content:
              'I once waited 45 minutes at Café Hawelka. The waiter '
              'brought the Buchteln and a newspaper. Worth every second.',
          timestamp: DateTime(2026, 3, 5, 10, 30),
        ),
        OiComment(
          key: 'c5-2',
          authorId: kHedwig.id,
          authorName: kHedwig.name,
          content:
              'The article should mention the unwritten rule about '
              'reading newspapers: you may stay as long as you like, '
              'but you must order at least one Melange per hour.',
          timestamp: DateTime(2026, 3, 5, 11, 15),
          reactions: [
            const chat.OiReactionData(emoji: '📰', count: 3, reacted: false),
          ],
        ),
        OiComment(
          key: 'c5-3',
          authorId: kBrigitte.id,
          authorName: kBrigitte.name,
          content:
              'As an accountant I can confirm: the economics of sitting '
              'in a Kaffeehaus for four hours on one Melange are '
              'surprisingly viable.',
          timestamp: DateTime(2026, 3, 5, 12),
        ),
        OiComment(
          key: 'c5-4',
          authorId: kVinzenz.id,
          authorName: kVinzenz.name,
          content:
              'Security reminder: please do not use Kaffeehaus WiFi '
              'for accessing production servers. Yes, this happened.',
          timestamp: DateTime(2026, 3, 5, 14),
          reactions: [
            const chat.OiReactionData(emoji: '🔒', count: 2, reacted: false),
            const chat.OiReactionData(emoji: '😱', count: 4, reacted: true),
          ],
        ),
      ],
    ),

    // ── Thread 6: Standalone comments (no replies) ──────────────────────
    OiComment(
      key: 'c6',
      authorId: kAugustine.id,
      authorName: kAugustine.name,
      content:
          'The illustrations in this article are beautiful. Could we '
          'commission a full series for the other Kaffeehaus traditions?',
      timestamp: DateTime(2026, 3, 6, 9, 30),
      reactions: [
        const chat.OiReactionData(emoji: '🎨', count: 6, reacted: false),
      ],
    ),
    OiComment(
      key: 'c7',
      authorId: kStefan.id,
      authorName: kStefan.name,
      content:
          'This is the content strategy we need. Authentic, funny, and '
          'genuinely useful. More articles like this, please!',
      timestamp: DateTime(2026, 3, 7, 16, 45),
      reactions: [
        const chat.OiReactionData(emoji: '❤️', count: 10, reacted: true),
      ],
    ),

    // ── Thread 7: Bergkäse tangent (1 + 3 = 4) ─────────────────────────
    OiComment(
      key: 'c8',
      authorId: kMaria.id,
      authorName: kMaria.name,
      content:
          'Could we perhaps expand with a chapter on Bergkäse? '
          'Asking for a friend who is definitely not me.',
      timestamp: DateTime(2026, 3, 8, 9),
      replies: [
        OiComment(
          key: 'c8-1',
          authorId: kHans.id,
          authorName: kHans.name,
          content:
              'Bergkäse deserves its own article. The aging process '
              'alone is worth 2,000 words.',
          timestamp: DateTime(2026, 3, 8, 10),
        ),
        OiComment(
          key: 'c8-2',
          authorId: kGertrud.id,
          authorName: kGertrud.name,
          content:
              'I am already drafting it! Working title: "Bergkäse — '
              'The Cheese That Moves Mountains (of Bread)."',
          timestamp: DateTime(2026, 3, 8, 11, 30),
          reactions: [
            const chat.OiReactionData(emoji: '🏔️', count: 5, reacted: false),
          ],
        ),
        OiComment(
          key: 'c8-3',
          authorId: kCurrentUser.id,
          authorName: kCurrentUser.name,
          content:
              'Approved. Let us make it a three-part series: Graukäse, '
              'Bergkäse, and the ultimate Käseplatte ranking.',
          timestamp: DateTime(2026, 3, 8, 14),
          reactions: [
            const chat.OiReactionData(emoji: '👍', count: 8, reacted: false),
          ],
        ),
      ],
    ),

    // ── Standalone comments (10 more to approach 42 total) ────────────────
    OiComment(
      key: 'c9',
      authorId: kElisabeth.id,
      authorName: kElisabeth.name,
      content:
          'Can confirm: the Oberkellner at Café Sperl once corrected '
          'my pronunciation of "Verlängerter." I have not recovered.',
      timestamp: DateTime(2026, 3, 9, 8, 30),
    ),
    OiComment(
      key: 'c10',
      authorId: kFerdinand.id,
      authorName: kFerdinand.name,
      content:
          'Suggestion: add a glossary of all 27 coffee types at the end '
          'of the article. Could be a nice downloadable PDF too.',
      timestamp: DateTime(2026, 3, 9, 11),
      reactions: [
        const chat.OiReactionData(emoji: '📋', count: 3, reacted: false),
      ],
    ),
    OiComment(
      key: 'c11',
      authorId: kRosalinde.id,
      authorName: kRosalinde.name,
      content:
          'HR approved the Kaffeehaus-Knigge as mandatory reading for '
          'all new hires. Welcome package updated.',
      timestamp: DateTime(2026, 3, 10, 9, 15),
      reactions: [
        const chat.OiReactionData(emoji: '🎉', count: 6, reacted: true),
      ],
    ),
    OiComment(
      key: 'c12',
      authorId: kKaspar.id,
      authorName: kKaspar.name,
      content:
          'Shared this with our Innsbruck sales team. They want a '
          'Tyrolean version covering Graukäse-Jause etiquette.',
      timestamp: DateTime(2026, 3, 10, 14, 45),
    ),
    OiComment(
      key: 'c13',
      authorId: kOtto.id,
      authorName: kOtto.name,
      content:
          'Fun fact: the warehouse team in Linz has a weekly '
          'Kaffeepause where we practice ordering in proper Viennese.',
      timestamp: DateTime(2026, 3, 11, 10, 30),
      reactions: [
        const chat.OiReactionData(emoji: '☕', count: 4, reacted: false),
      ],
    ),
    OiComment(
      key: 'c14',
      authorId: kRupert.id,
      authorName: kRupert.name,
      content:
          'Excellent article. The tone is exactly right — informative '
          'but never taking itself too seriously.',
      timestamp: DateTime(2026, 3, 12, 9),
    ),
    OiComment(
      key: 'c15',
      authorId: kHedwig.id,
      authorName: kHedwig.name,
      content:
          'Three customers this week mentioned this article in support '
          'tickets. They loved the Graukäse anecdote.',
      timestamp: DateTime(2026, 3, 12, 16, 30),
      reactions: [
        const chat.OiReactionData(emoji: '💬', count: 2, reacted: false),
      ],
    ),
    OiComment(
      key: 'c16',
      authorId: kTheresa.id,
      authorName: kTheresa.name,
      content:
          'UX research insight: our readers spend an average of 6.2 '
          'minutes on this article — highest engagement in the blog.',
      timestamp: DateTime(2026, 3, 13, 11),
      reactions: [
        const chat.OiReactionData(emoji: '📊', count: 5, reacted: false),
      ],
    ),
    OiComment(
      key: 'c17',
      authorId: kPeter.id,
      authorName: kPeter.name,
      content:
          'The data backs it up: search traffic for "Kaffeehaus Knigge" '
          'is up 280% since publication. Organic gold.',
      timestamp: DateTime(2026, 3, 14, 15),
    ),
    OiComment(
      key: 'c18',
      authorId: kBrigitte.id,
      authorName: kBrigitte.name,
      content:
          'From a finance perspective: the content marketing ROI on '
          'this article alone justifies the entire Q1 blog budget.',
      timestamp: DateTime(2026, 3, 15, 10),
      reactions: [
        const chat.OiReactionData(emoji: '💰', count: 3, reacted: false),
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
  const OiFormField(key: 'slug', label: 'URL Slug', type: OiFieldType.text),
  const OiFormField(
    key: 'category',
    label: 'Category',
    type: OiFieldType.select,
    config: {
      'options': ['Culinary', 'Outdoor', 'Culture', 'Tech', 'Company'],
    },
  ),
  const OiFormField(key: 'tags', label: 'Tags', type: OiFieldType.tag),
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

// ── Category tree ────────────────────────────────────────────────────────────

/// Builds the category tree for the CMS categories screen.
List<OiTreeNode<String>> buildCategoryTree() {
  return [
    const OiTreeNode<String>(
      id: 'cat-kulinarik',
      label: 'Kulinarik',
      data: 'Kulinarik',
      children: [
        OiTreeNode<String>(
          id: 'cat-rezepte',
          label: 'Rezepte',
          data: 'Rezepte',
        ),
        OiTreeNode<String>(
          id: 'cat-restaurants',
          label: 'Restaurants',
          data: 'Restaurants',
        ),
        OiTreeNode<String>(
          id: 'cat-produkte',
          label: 'Produkte',
          data: 'Produkte',
        ),
      ],
    ),
    const OiTreeNode<String>(
      id: 'cat-reisen',
      label: 'Reisen',
      data: 'Reisen',
      children: [
        OiTreeNode<String>(
          id: 'cat-wanderwege',
          label: 'Wanderwege',
          data: 'Wanderwege',
        ),
        OiTreeNode<String>(
          id: 'cat-skigebiete',
          label: 'Skigebiete',
          data: 'Skigebiete',
        ),
      ],
    ),
    const OiTreeNode<String>(
      id: 'cat-kultur',
      label: 'Kultur',
      data: 'Kultur',
      children: [
        OiTreeNode<String>(id: 'cat-musik', label: 'Musik', data: 'Musik'),
        OiTreeNode<String>(
          id: 'cat-theater',
          label: 'Theater',
          data: 'Theater',
        ),
      ],
    ),
    const OiTreeNode<String>(
      id: 'cat-tech',
      label: 'Tech',
      data: 'Tech',
      children: [
        OiTreeNode<String>(
          id: 'cat-flutter',
          label: 'Flutter',
          data: 'Flutter',
        ),
        OiTreeNode<String>(
          id: 'cat-backend',
          label: 'Backend',
          data: 'Backend',
        ),
      ],
    ),
  ];
}

// ── Media items ──────────────────────────────────────────────────────────────

/// Mock media library items for the CMS media screen.
const kMediaItems = <Map<String, String>>[
  {
    'name': 'schnitzel-hero.jpg',
    'type': 'image',
    'size': '2.4 MB',
    'date': '2026-03-18',
  },
  {
    'name': 'alpine-panorama.jpg',
    'type': 'image',
    'size': '3.1 MB',
    'date': '2026-03-12',
  },
  {
    'name': 'coffee-house.jpg',
    'type': 'image',
    'size': '1.8 MB',
    'date': '2026-03-05',
  },
  {
    'name': 'graukaese-closeup.png',
    'type': 'image',
    'size': '4.2 MB',
    'date': '2026-02-28',
  },
  {
    'name': 'team-interview.mp4',
    'type': 'video',
    'size': '48.5 MB',
    'date': '2026-02-20',
  },
  {
    'name': 'brand-guidelines.pdf',
    'type': 'document',
    'size': '1.1 MB',
    'date': '2026-02-14',
  },
  {
    'name': 'recipe-card-template.png',
    'type': 'image',
    'size': '0.8 MB',
    'date': '2026-02-10',
  },
  {
    'name': 'hiking-route-map.jpg',
    'type': 'image',
    'size': '2.9 MB',
    'date': '2026-01-28',
  },
];
