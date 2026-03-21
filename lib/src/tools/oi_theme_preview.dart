import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/components/buttons/oi_button.dart';
import 'package:obers_ui/src/components/display/oi_badge.dart';
import 'package:obers_ui/src/components/display/oi_card.dart';
import 'package:obers_ui/src/components/display/oi_progress.dart';
import 'package:obers_ui/src/components/inputs/oi_number_input.dart';
import 'package:obers_ui/src/components/inputs/oi_text_input.dart';
import 'package:obers_ui/src/foundation/theme/oi_color_swatch.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme_data.dart';

/// A theme preview widget showing sample components in the current theme.
///
/// Renders a grid/column of representative component samples for visually
/// auditing theme changes. Useful for design systems and theme builders.
///
/// The widget wraps its content in an [OiTheme] provider so that all child
/// components resolve tokens from the supplied [theme].
class OiThemePreview extends StatelessWidget {
  /// Creates an [OiThemePreview].
  const OiThemePreview({
    required this.theme,
    this.showColors = true,
    this.showTypography = true,
    this.showSpacing = true,
    this.showButtons = true,
    this.showInputs = true,
    this.showCards = true,
    this.showBadges = true,
    this.showProgress = true,
    super.key,
  });

  /// The theme to preview.
  final OiThemeData theme;

  /// Whether to show the color palette section.
  final bool showColors;

  /// Whether to show the typography samples section.
  final bool showTypography;

  /// Whether to show the spacing scale section.
  final bool showSpacing;

  /// Whether to show button variant samples.
  final bool showButtons;

  /// Whether to show input samples.
  final bool showInputs;

  /// Whether to show card variants.
  final bool showCards;

  /// Whether to show badge variants.
  final bool showBadges;

  /// Whether to show progress indicators.
  final bool showProgress;

  @override
  Widget build(BuildContext context) {
    return OiTheme(
      data: theme,
      child: ColoredBox(
        color: theme.colors.background,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(theme.spacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showColors) _buildColorSection(),
              if (showTypography) _buildTypographySection(),
              if (showSpacing) _buildSpacingSection(),
              if (showButtons) _buildButtonSection(),
              if (showInputs) _buildInputSection(),
              if (showCards) _buildCardSection(),
              if (showBadges) _buildBadgeSection(),
              if (showProgress) _buildProgressSection(),
            ],
          ),
        ),
      ),
    );
  }

  // ── Sections ─────────────────────────────────────────────────────────────

  Widget _buildColorSection() {
    final colors = theme.colors;
    return _Section(
      title: 'Colors',
      theme: theme,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSwatchRow('Primary', colors.primary),
          SizedBox(height: theme.spacing.sm),
          _buildSwatchRow('Accent', colors.accent),
          SizedBox(height: theme.spacing.sm),
          _buildSwatchRow('Success', colors.success),
          SizedBox(height: theme.spacing.sm),
          _buildSwatchRow('Warning', colors.warning),
          SizedBox(height: theme.spacing.sm),
          _buildSwatchRow('Error', colors.error),
          SizedBox(height: theme.spacing.sm),
          _buildSwatchRow('Info', colors.info),
          SizedBox(height: theme.spacing.md),
          Wrap(
            spacing: theme.spacing.sm,
            runSpacing: theme.spacing.sm,
            children: [
              _ColorChip(color: colors.background, label: 'background'),
              _ColorChip(color: colors.surface, label: 'surface'),
              _ColorChip(color: colors.surfaceHover, label: 'surfaceHover'),
              _ColorChip(color: colors.surfaceActive, label: 'surfaceActive'),
              _ColorChip(color: colors.overlay, label: 'overlay'),
              _ColorChip(color: colors.text, label: 'text'),
              _ColorChip(color: colors.textSubtle, label: 'textSubtle'),
              _ColorChip(color: colors.textMuted, label: 'textMuted'),
              _ColorChip(color: colors.border, label: 'border'),
              _ColorChip(color: colors.borderFocus, label: 'borderFocus'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSwatchRow(String label, OiColorSwatch swatch) {
    return Row(
      children: [
        SizedBox(
          width: 72,
          child: Text(
            label,
            style: theme.textTheme.small.copyWith(color: theme.colors.text),
          ),
        ),
        _ColorChip(color: swatch.base, label: 'base'),
        SizedBox(width: theme.spacing.xs),
        _ColorChip(color: swatch.light, label: 'light'),
        SizedBox(width: theme.spacing.xs),
        _ColorChip(color: swatch.dark, label: 'dark'),
        SizedBox(width: theme.spacing.xs),
        _ColorChip(color: swatch.muted, label: 'muted'),
      ],
    );
  }

  Widget _buildTypographySection() {
    final tt = theme.textTheme;
    final textColor = theme.colors.text;
    return _Section(
      title: 'Typography',
      theme: theme,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final entry in <String, TextStyle>{
            'display': tt.display,
            'h1': tt.h1,
            'h2': tt.h2,
            'h3': tt.h3,
            'h4': tt.h4,
            'body': tt.body,
            'bodyStrong': tt.bodyStrong,
            'small': tt.small,
            'smallStrong': tt.smallStrong,
            'tiny': tt.tiny,
            'caption': tt.caption,
            'code': tt.code,
            'overline': tt.overline,
            'link': tt.link,
          }.entries)
            Padding(
              padding: EdgeInsets.only(bottom: theme.spacing.xs),
              child: Text(
                '${entry.key}: The quick brown fox',
                style: entry.value.copyWith(color: textColor),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSpacingSection() {
    final sp = theme.spacing;
    return _Section(
      title: 'Spacing',
      theme: theme,
      child: Wrap(
        spacing: theme.spacing.sm,
        runSpacing: theme.spacing.sm,
        children: [
          for (final entry in <String, double>{
            'xs': sp.xs,
            'sm': sp.sm,
            'md': sp.md,
            'lg': sp.lg,
            'xl': sp.xl,
            'xxl': sp.xxl,
          }.entries)
            _SpacingBlock(
              label: '${entry.key} (${entry.value.toInt()})',
              size: entry.value,
              color: theme.colors.primary.base,
            ),
        ],
      ),
    );
  }

  Widget _buildButtonSection() {
    return _Section(
      title: 'Buttons',
      theme: theme,
      child: Wrap(
        spacing: theme.spacing.sm,
        runSpacing: theme.spacing.sm,
        children: [
          OiButton.primary(label: 'primary', onTap: () {}),
          OiButton.secondary(label: 'secondary', onTap: () {}),
          OiButton.outline(label: 'outline', onTap: () {}),
          OiButton.ghost(label: 'ghost', onTap: () {}),
          OiButton.destructive(label: 'destructive', onTap: () {}),
          OiButton.soft(label: 'soft', onTap: () {}),
        ],
      ),
    );
  }

  Widget _buildInputSection() {
    return _Section(
      title: 'Inputs',
      theme: theme,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            width: 300,
            child: OiTextInput(
              label: 'Text Input',
              placeholder: 'Type here...',
            ),
          ),
          SizedBox(height: theme.spacing.sm),
          const SizedBox(
            width: 300,
            child: OiTextInput(
              label: 'Error Input',
              placeholder: 'Invalid value',
              error: 'This field is required',
            ),
          ),
          SizedBox(height: theme.spacing.sm),
          const SizedBox(
            width: 200,
            child: OiNumberInput(label: 'Number', value: 42),
          ),
        ],
      ),
    );
  }

  Widget _buildCardSection() {
    return _Section(
      title: 'Cards',
      theme: theme,
      child: Wrap(
        spacing: theme.spacing.md,
        runSpacing: theme.spacing.md,
        children: [
          for (final entry in const [
            ('elevated', false, false),
            ('flat', true, false),
            ('outlined', false, true),
          ])
            SizedBox(
              width: 180,
              child: entry.$2
                  ? OiCard.flat(
                      child: Text(
                        entry.$1,
                        style: theme.textTheme.body.copyWith(
                          color: theme.colors.text,
                        ),
                      ),
                    )
                  : entry.$3
                  ? OiCard.outlined(
                      child: Text(
                        entry.$1,
                        style: theme.textTheme.body.copyWith(
                          color: theme.colors.text,
                        ),
                      ),
                    )
                  : OiCard(
                      child: Text(
                        entry.$1,
                        style: theme.textTheme.body.copyWith(
                          color: theme.colors.text,
                        ),
                      ),
                    ),
            ),
        ],
      ),
    );
  }

  Widget _buildBadgeSection() {
    return _Section(
      title: 'Badges',
      theme: theme,
      child: Wrap(
        spacing: theme.spacing.sm,
        runSpacing: theme.spacing.sm,
        children: [
          for (final color in OiBadgeColor.values)
            for (final style in OiBadgeStyle.values)
              switch (style) {
                OiBadgeStyle.filled => OiBadge.filled(
                  label: '${color.name} ${style.name}',
                  color: color,
                ),
                OiBadgeStyle.soft => OiBadge.soft(
                  label: '${color.name} ${style.name}',
                  color: color,
                ),
                OiBadgeStyle.outline => OiBadge.outline(
                  label: '${color.name} ${style.name}',
                  color: color,
                ),
              },
        ],
      ),
    );
  }

  Widget _buildProgressSection() {
    return _Section(
      title: 'Progress',
      theme: theme,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(width: 300, child: OiProgress.linear(value: 0.6)),
          SizedBox(height: theme.spacing.md),
          const SizedBox(
            width: 60,
            height: 60,
            child: OiProgress.circular(value: 0.7),
          ),
        ],
      ),
    );
  }
}

// ── Private helper widgets ─────────────────────────────────────────────────

/// A titled section wrapper used within [OiThemePreview].
class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.theme,
    required this.child,
  });

  /// The section heading text.
  final String title;

  /// The theme for styling.
  final OiThemeData theme;

  /// The section body.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: theme.spacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.h3.copyWith(color: theme.colors.text),
          ),
          SizedBox(height: theme.spacing.md),
          child,
        ],
      ),
    );
  }
}

/// A small square chip that displays a [Color] with its [label].
class _ColorChip extends StatelessWidget {
  const _ColorChip({required this.color, required this.label});

  /// The color to display.
  final Color color;

  /// A short descriptive label.
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: const Color(0x33000000)),
          ),
        ),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 9)),
      ],
    );
  }
}

/// A visual block representing a spacing value.
class _SpacingBlock extends StatelessWidget {
  const _SpacingBlock({
    required this.label,
    required this.size,
    required this.color,
  });

  /// Display text.
  final String label;

  /// The spacing value in logical pixels.
  final double size;

  /// The fill color.
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 9)),
      ],
    );
  }
}
