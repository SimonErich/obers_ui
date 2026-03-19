import 'package:flutter/material.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_widgetbook/helpers/knob_helpers.dart';
import 'package:widgetbook/widgetbook.dart';

final radiusComponent = WidgetbookComponent(
  name: 'OiRadiusScale',
  useCases: [
    WidgetbookUseCase(
      name: 'All Levels',
      builder: (context) {
        final preference = context.knobs.enumKnob(
          label: 'Radius Preference',
          values: OiRadiusPreference.values,
          initialValue: OiRadiusPreference.medium,
        );
        final scale = OiRadiusScale.forPreference(preference);

        return catalogWrapper(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Radius Scale',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                'Preference: ${preference.name}',
                style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _radiusTile('none', scale.none),
                  _radiusTile('xs', scale.xs),
                  _radiusTile('sm', scale.sm),
                  _radiusTile('md', scale.md),
                  _radiusTile('lg', scale.lg),
                  _radiusTile('xl', scale.xl),
                  _radiusTile('full', scale.full),
                ],
              ),
            ],
          ),
        );
      },
    ),
  ],
);

Widget _radiusTile(String label, BorderRadius radius) {
  // For display purposes, extract the top-left radius value.
  final r = radius.topLeft.x;
  final displayRadius = r > 100 ? 'pill' : '${r.toInt()}dp';

  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: const Color(0xFF2563EB),
          borderRadius: radius,
        ),
      ),
      const SizedBox(height: 6),
      Text(
        label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
      Text(
        displayRadius,
        style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
      ),
    ],
  );
}
