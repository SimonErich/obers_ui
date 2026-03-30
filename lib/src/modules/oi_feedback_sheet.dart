import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/buttons/oi_button.dart';
import 'package:obers_ui/src/components/feedback/oi_sentiment.dart';
import 'package:obers_ui/src/components/feedback/oi_star_rating.dart';
import 'package:obers_ui/src/components/inputs/oi_text_input.dart';
import 'package:obers_ui/src/foundation/oi_icons.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/display/oi_label.dart';
import 'package:obers_ui/src/primitives/interaction/oi_tappable.dart';

// ---------------------------------------------------------------------------
// Data models
// ---------------------------------------------------------------------------

/// Category of feedback.
///
/// {@category Modules}
enum OiFeedbackCategory {
  /// A bug report.
  bug,

  /// A feature request.
  featureRequest,

  /// General feedback.
  general,

  /// Other / uncategorised feedback.
  other,
}

/// Rating input type for feedback.
///
/// {@category Modules}
enum OiFeedbackRatingType {
  /// Star-based rating (1-5).
  stars,

  /// Emoji-based sentiment picker.
  sentiment,
}

/// Data collected from a feedback submission.
///
/// {@category Modules}
@immutable
class OiFeedbackData {
  /// Creates an [OiFeedbackData].
  const OiFeedbackData({
    required this.category,
    this.rating,
    this.message,
    this.email,
    this.metadata = const {},
  });

  /// The selected feedback category.
  final OiFeedbackCategory category;

  /// The rating value (1-5), or null if not provided.
  final int? rating;

  /// The user's feedback message, or null if not provided.
  final String? message;

  /// The user's email address, or null if not provided.
  final String? email;

  /// Additional metadata attached to the feedback submission.
  final Map<String, String> metadata;
}

// ---------------------------------------------------------------------------
// Default emoji-to-rating mapping
// ---------------------------------------------------------------------------

const List<String> _kSentimentEmojis = ['😡', '😕', '😐', '🙂', '😄'];

int? _sentimentToRating(String? emoji) {
  if (emoji == null) return null;
  final index = _kSentimentEmojis.indexOf(emoji);
  return index >= 0 ? index + 1 : null;
}

// ---------------------------------------------------------------------------
// Main widget
// ---------------------------------------------------------------------------

/// An in-app feedback form with rating, category, and message.
///
/// Displays a compact feedback form with a sentiment or star rating selector,
/// category picker, message input, and optional email field. After submission,
/// transitions to a thank-you state that auto-dismisses.
///
/// {@category Modules}
class OiFeedbackSheet extends StatefulWidget {
  /// Creates an [OiFeedbackSheet].
  const OiFeedbackSheet({
    required this.label,
    this.onSubmit,
    this.ratingType = OiFeedbackRatingType.sentiment,
    this.categories = OiFeedbackCategory.values,
    this.showEmail = true,
    this.metadata = const {},
    this.thankYouTitle = 'Thank you!',
    this.thankYouDescription = 'Your feedback helps us improve.',
    super.key,
  });

  /// Accessible label for the feedback sheet.
  final String label;

  /// Called when the user submits feedback. Return `true` to show the
  /// thank-you state, `false` to remain on the form (e.g. on error).
  final Future<bool> Function(OiFeedbackData)? onSubmit;

  /// Whether to display star ratings or emoji-based sentiment.
  final OiFeedbackRatingType ratingType;

  /// The categories available for selection.
  final List<OiFeedbackCategory> categories;

  /// Whether to show the optional email field.
  final bool showEmail;

  /// Additional metadata attached to every submission.
  final Map<String, String> metadata;

  /// Title shown after a successful submission.
  final String thankYouTitle;

  /// Description shown after a successful submission.
  final String thankYouDescription;

  @override
  State<OiFeedbackSheet> createState() => _OiFeedbackSheetState();
}

class _OiFeedbackSheetState extends State<OiFeedbackSheet> {
  OiFeedbackCategory? _selectedCategory;
  int? _rating;
  String? _sentimentValue;
  final _messageController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isSubmitting = false;
  bool _isSubmitted = false;

  @override
  void dispose() {
    _messageController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_selectedCategory == null || _isSubmitting) return;

    setState(() => _isSubmitting = true);

    final data = OiFeedbackData(
      category: _selectedCategory!,
      rating: _rating,
      message: _messageController.text.isNotEmpty
          ? _messageController.text
          : null,
      email: _emailController.text.isNotEmpty ? _emailController.text : null,
      metadata: widget.metadata,
    );

    final success = await widget.onSubmit?.call(data) ?? true;

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
      if (success) _isSubmitted = true;
    });
  }

  // ── Section builders ───────────────────────────────────────────────────────

  Widget _buildRating(BuildContext context) {
    final spacing = context.spacing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: spacing.sm),
          child: const OiLabel.body('How was your experience?'),
        ),
        if (widget.ratingType == OiFeedbackRatingType.sentiment)
          OiSentiment(
            value: _sentimentValue,
            onChanged: (emoji) => setState(() {
              _sentimentValue = emoji;
              _rating = _sentimentToRating(emoji);
            }),
          )
        else
          OiStarRating(
            label: 'Rating',
            value: (_rating ?? 0).toDouble(),
            size: 28,
            onChanged: (value) => setState(() {
              _rating = value.round();
            }),
          ),
      ],
    );
  }

  Widget _buildCategory(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;
    final radius = context.radius;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: spacing.sm),
          child: const OiLabel.body('Category'),
        ),
        Wrap(
          spacing: spacing.sm,
          runSpacing: spacing.sm,
          children: widget.categories.map((cat) {
            final selected = _selectedCategory == cat;
            final bg = selected ? colors.primary.muted : colors.surface;
            final borderColor = selected ? colors.primary.base : colors.border;
            final textColor = selected ? colors.primary.base : colors.text;

            return Semantics(
              button: true,
              label: _categoryLabel(cat),
              selected: selected,
              child: OiTappable(
                onTap: () => setState(() => _selectedCategory = cat),
                clipBorderRadius: radius.md,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: EdgeInsets.symmetric(
                    horizontal: spacing.md,
                    vertical: spacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: radius.md,
                    border: Border.all(
                      color: borderColor,
                      width: selected ? 2 : 1,
                    ),
                  ),
                  child: OiLabel.small(_categoryLabel(cat), color: textColor),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildMessage() {
    return OiTextInput(
      controller: _messageController,
      label: 'Message',
      placeholder: 'Tell us more...',
      maxLines: 4,
      minLines: 3,
    );
  }

  Widget _buildEmail() {
    return OiTextInput(
      controller: _emailController,
      label: 'Email (optional)',
      placeholder: 'your@email.com',
      keyboardType: TextInputType.emailAddress,
    );
  }

  Widget _buildSubmit() {
    final hasCategory = _selectedCategory != null;

    return OiButton.primary(
      label: 'Submit Feedback',
      onTap: hasCategory ? _handleSubmit : null,
      loading: _isSubmitting,
      enabled: hasCategory && !_isSubmitting,
      fullWidth: true,
      icon: OiIcons.send,
    );
  }

  Widget _buildThankYou(BuildContext context) {
    final colors = context.colors;
    final spacing = context.spacing;

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: spacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(OiIcons.circleCheck, size: 64, color: colors.success.base),
            SizedBox(height: spacing.md),
            OiLabel.h3(widget.thankYouTitle),
            SizedBox(height: spacing.sm),
            OiLabel.body(
              widget.thankYouDescription,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;

    return Semantics(
      label: widget.label,
      container: true,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Padding(
            padding: EdgeInsets.all(spacing.md),
            child: _isSubmitted
                ? _buildThankYou(context)
                : SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildRating(context),
                        SizedBox(height: spacing.lg),
                        _buildCategory(context),
                        SizedBox(height: spacing.lg),
                        _buildMessage(),
                        if (widget.showEmail) ...[
                          SizedBox(height: spacing.md),
                          _buildEmail(),
                        ],
                        SizedBox(height: spacing.lg),
                        _buildSubmit(),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Returns a human-readable label for the given [OiFeedbackCategory].
String _categoryLabel(OiFeedbackCategory cat) => switch (cat) {
  OiFeedbackCategory.bug => 'Bug Report',
  OiFeedbackCategory.featureRequest => 'Feature Request',
  OiFeedbackCategory.general => 'General',
  OiFeedbackCategory.other => 'Other',
};
