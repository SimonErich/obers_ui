import 'package:flutter/widgets.dart';
import 'package:obers_ui/obers_ui.dart';

import 'package:obers_ui_example/apps/component_library/shared/component_showcase_section.dart';

/// Showcase screen for feedback and rating widgets.
class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  double _starRating = 3;
  int _scaleRating = 7;
  String _sentiment = '\u{1f642}'; // default to slightly smiling face
  OiThumbsValue _thumbs = OiThumbsValue.up;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;

    return SingleChildScrollView(
      padding: EdgeInsets.all(spacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const OiLabel.h2('Feedback & Rating'),
          SizedBox(height: spacing.lg),

          // ── Star Rating ────────────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Star Rating',
            widgetName: 'OiStarRating',
            description:
                'A star-based rating widget with hover preview and half-star support.',
            examples: [
              ComponentExample(
                title: 'Interactive (5 stars)',
                child: OiStarRating(
                  label: 'Rating',
                  value: _starRating,
                  onChanged: (v) => setState(() => _starRating = v),
                ),
              ),
              const ComponentExample(
                title: 'Read-only',
                child: OiStarRating(
                  label: 'Read-only rating',
                  value: 4,
                  readOnly: true,
                ),
              ),
            ],
          ),

          // ── Scale Rating ───────────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Scale Rating',
            widgetName: 'OiScaleRating',
            description:
                'A numeric scale rating (e.g. NPS 1-10) rendered as a connected button group.',
            examples: [
              ComponentExample(
                title: 'Interactive (1-10)',
                child: OiScaleRating(
                  label: 'Scale rating',
                  value: _scaleRating,
                  minLabel: 'Not likely',
                  maxLabel: 'Very likely',
                  onChanged: (v) => setState(() => _scaleRating = v),
                ),
              ),
            ],
          ),

          // ── Sentiment ──────────────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Sentiment',
            widgetName: 'OiSentiment',
            description:
                'An emoji-based sentiment picker for quick feedback collection.',
            examples: [
              ComponentExample(
                title: 'Interactive',
                child: OiSentiment(
                  value: _sentiment,
                  onChanged: (v) => setState(() => _sentiment = v),
                ),
              ),
            ],
          ),

          // ── Thumbs ─────────────────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Thumbs',
            widgetName: 'OiThumbs',
            description: 'A thumbs-up / thumbs-down binary feedback widget.',
            examples: [
              ComponentExample(
                title: 'Interactive',
                child: OiThumbs(
                  label: 'Was this helpful?',
                  value: _thumbs,
                  onChanged: (v) => setState(() => _thumbs = v),
                ),
              ),
              ComponentExample(
                title: 'With counts',
                child: OiThumbs(
                  label: 'Vote',
                  value: _thumbs,
                  showCount: true,
                  upCount: 12,
                  downCount: 3,
                  onChanged: (v) => setState(() => _thumbs = v),
                ),
              ),
            ],
          ),

          // ── Reaction Bar ───────────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Reaction Bar',
            widgetName: 'OiReactionBar',
            description:
                'A row of emoji reaction chips with counts and an add-reaction button.',
            examples: [
              ComponentExample(
                title: 'Reactions',
                child: OiReactionBar(
                  reactions: const [
                    OiReactionData(
                      emoji: '\u{1f44d}',
                      count: 5,
                      selected: true,
                    ),
                    OiReactionData(emoji: '\u{2764}\u{fe0f}', count: 3),
                    OiReactionData(emoji: '\u{1f389}', count: 1),
                  ],
                  onReact: (_) {},
                ),
              ),
            ],
          ),

          // ── Bulk Bar ───────────────────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Bulk Bar',
            widgetName: 'OiBulkBar',
            description:
                'A floating toolbar that appears when items are selected, showing selection count and bulk actions.',
            examples: [
              ComponentExample(
                title: 'Bulk actions',
                child: OiBulkBar(
                  selectedCount: 3,
                  totalCount: 10,
                  label: 'items',
                  actions: [
                    OiBulkAction(
                      label: 'Delete',
                      icon: OiIcons.trash2,
                      onTap: () {},
                      variant: OiBulkActionVariant.destructive,
                    ),
                    OiBulkAction(
                      label: 'Move',
                      icon: OiIcons.folderInput,
                      onTap: () {},
                    ),
                  ],
                  onSelectAll: () {},
                  onDeselectAll: () {},
                ),
              ),
            ],
          ),

          // ── OiPipelineProgress ──────────────────────────────────────
          ComponentShowcaseSection(
            title: 'Pipeline Progress',
            widgetName: 'OiPipelineProgress',
            description:
                'A multi-step pipeline progress indicator. Shows '
                'completed, active, and pending steps with optional '
                'sub-progress, error states, and collapse for '
                'completed steps.',
            examples: [
              const ComponentExample(
                title: 'Deployment pipeline',
                child: OiPipelineProgress(
                  label: 'Deployment',
                  currentStepIndex: 2,
                  steps: [
                    OiPipelineProgressStep(label: 'Build'),
                    OiPipelineProgressStep(label: 'Test'),
                    OiPipelineProgressStep(
                      label: 'Deploy',
                      detail: 'Deploying to production...',
                      subProgress: OiProgress.linear(
                        value: 0.65,
                        label: 'Deploy progress',
                      ),
                    ),
                    OiPipelineProgressStep(label: 'Verify'),
                  ],
                ),
              ),
              ComponentExample(
                title: 'With error',
                child: OiPipelineProgress(
                  label: 'CI Pipeline',
                  currentStepIndex: 1,
                  error: 'Test suite failed: 3 failures',
                  onRetry: () {},
                  steps: const [
                    OiPipelineProgressStep(label: 'Lint'),
                    OiPipelineProgressStep(label: 'Unit Tests'),
                    OiPipelineProgressStep(label: 'Integration'),
                    OiPipelineProgressStep(label: 'Publish'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
