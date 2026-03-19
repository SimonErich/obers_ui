import 'package:flutter/material.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:widgetbook/widgetbook.dart';

import 'package:obers_ui_widgetbook/helpers/knob_helpers.dart';

final shadowComponent = WidgetbookComponent(
  name: 'OiShadowScale',
  useCases: [
    WidgetbookUseCase(
      name: 'All Levels',
      builder: (context) {
        final shadows = OiTheme.of(context).shadows;
        final colors = OiTheme.of(context).colors;

        return catalogWrapper(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Shadow Scale',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 24,
                runSpacing: 24,
                children: [
                  _shadowCard('none', shadows.none, colors),
                  _shadowCard('xs', shadows.xs, colors),
                  _shadowCard('sm', shadows.sm, colors),
                  _shadowCard('md', shadows.md, colors),
                  _shadowCard('lg', shadows.lg, colors),
                  _shadowCard('xl', shadows.xl, colors),
                  _shadowCard('glass', shadows.glass, colors),
                ],
              ),
            ],
          ),
        );
      },
    ),
  ],
);

Widget _shadowCard(
  String label,
  List<BoxShadow> shadow,
  OiColorScheme colors,
) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 120,
        height: 80,
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(8),
          boxShadow: shadow,
          border: Border.all(
            color: colors.borderSubtle,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: colors.text,
          ),
        ),
      ),
      const SizedBox(height: 8),
      Text(
        '${shadow.length} shadow${shadow.length == 1 ? '' : 's'}',
        style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
      ),
    ],
  );
}
