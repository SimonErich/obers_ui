import 'package:flutter/material.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:widgetbook/widgetbook.dart';

import 'package:obers_ui_widgetbook/helpers/knob_helpers.dart';

final spacingComponent = WidgetbookComponent(
  name: 'OiSpacingScale',
  useCases: [
    WidgetbookUseCase(
      name: 'All Tokens',
      builder: (context) {
        final spacing = OiTheme.of(context).spacing;

        return catalogWrapper(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Spacing Scale',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              _spacingTile('xs', spacing.xs),
              _spacingTile('sm', spacing.sm),
              _spacingTile('md', spacing.md),
              _spacingTile('lg', spacing.lg),
              _spacingTile('xl', spacing.xl),
              _spacingTile('xxl', spacing.xxl),
              const SizedBox(height: 24),
              const Text(
                'Page Gutters',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              _spacingTile('compact', spacing.pageGutterCompact),
              _spacingTile('medium', spacing.pageGutterMedium),
              _spacingTile('expanded', spacing.pageGutterExpanded),
              _spacingTile('large', spacing.pageGutterLarge),
              _spacingTile('extraLarge', spacing.pageGutterExtraLarge),
            ],
          ),
        );
      },
    ),
  ],
);

Widget _spacingTile(String label, double value) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(
            '$label (${value.toInt()}dp)',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: value,
          height: 24,
          decoration: BoxDecoration(
            color: const Color(0xFF2563EB),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    ),
  );
}
