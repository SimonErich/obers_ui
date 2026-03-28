import 'package:flutter/widgets.dart';
import 'package:obers_ui/src/foundation/theme/oi_theme.dart';
import 'package:obers_ui/src/primitives/display/oi_label.dart';

// ── OiFormLayout ─────────────────────────────────────────────────────────────

/// The layout direction of form fields within an [OiFormSection].
///
/// {@category Composites}
enum OiFormLayout {
  /// Fields are stacked vertically (default).
  vertical,

  /// Fields are laid out in a horizontal row.
  horizontal,

  /// Fields are laid out inline, wrapping when needed.
  inline,
}

// ── OiFormSection ─────────────────────────────────────────────────────────────

/// A visual grouping widget for form fields with an optional title and
/// description header.
///
/// Use [OiFormSection] to visually group related inputs inside any form — with
/// your own state management, `OiAfForm`, or a custom controller. It imposes no
/// opinion on how field values are stored or validated.
///
/// ```dart
/// OiFormSection(
///   title: 'Billing Address',
///   description: 'Where should we send the invoice?',
///   layout: OiFormLayout.horizontal,
///   children: [
///     OiAfTextInput(field: Field.firstName, label: 'First Name'),
///     OiAfTextInput(field: Field.lastName, label: 'Last Name'),
///   ],
/// )
/// ```
///
/// {@category Composites}
class OiFormSection extends StatelessWidget {
  /// Creates an [OiFormSection].
  const OiFormSection({
    required this.children,
    super.key,
    this.title,
    this.description,
    this.layout = OiFormLayout.vertical,
    this.gap = 12,
  });

  /// An optional heading rendered above the section's content.
  final String? title;

  /// An optional description rendered below the title.
  final String? description;

  /// The layout direction for [children].
  final OiFormLayout layout;

  /// Spacing between children in pixels.
  final double gap;

  /// The widgets to display inside this section.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (title != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: OiLabel.h4(title!),
          ),
        if (description != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: OiLabel.body(description!, color: colors.textMuted),
          ),
        _buildLayout(),
      ],
    );
  }

  Widget _buildLayout() {
    switch (layout) {
      case OiFormLayout.vertical:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            for (int i = 0; i < children.length; i++) ...[
              children[i],
              if (i < children.length - 1) SizedBox(height: gap),
            ],
          ],
        );

      case OiFormLayout.horizontal:
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (int i = 0; i < children.length; i++) ...[
              Expanded(child: children[i]),
              if (i < children.length - 1) SizedBox(width: gap),
            ],
          ],
        );

      case OiFormLayout.inline:
        return Wrap(spacing: gap, runSpacing: gap, children: children);
    }
  }
}
