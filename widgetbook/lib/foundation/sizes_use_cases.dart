import 'package:flutter/material.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_widgetbook/helpers/knob_helpers.dart';
import 'package:widgetbook/widgetbook.dart';

final sizesComponent = WidgetbookComponent(
  name: 'Sizes & Gaps',
  useCases: [
    WidgetbookUseCase(
      name: 'Size Scale',
      builder: (context) {
        return catalogWrapper(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Size Constants (dp)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              _sizeTile('s4 (xs)', s4),
              _sizeTile('s8 (sm)', s8),
              _sizeTile('s12', s12),
              _sizeTile('s16 (md)', s16),
              _sizeTile('s20', s20),
              _sizeTile('s24 (lg)', s24),
              _sizeTile('s32 (xl)', s32),
              _sizeTile('s48 (xxl)', s48),
              _sizeTile('s64', s64),
              _sizeTile('s96', s96),
              _sizeTile('s128', s128),
            ],
          ),
        );
      },
    ),
    WidgetbookUseCase(
      name: 'Gap Widgets',
      builder: (context) {
        return catalogWrapper(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Vertical Gaps (gapH*)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              ..._gapDemo([
                ('gapH4', gapH4),
                ('gapH8', gapH8),
                ('gapH16', gapH16),
                ('gapH24', gapH24),
                ('gapH32', gapH32),
              ], axis: Axis.vertical),
              const SizedBox(height: 32),
              const Text(
                'Horizontal Gaps (gapW*)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              ..._gapDemo([
                ('gapW4', gapW4),
                ('gapW8', gapW8),
                ('gapW16', gapW16),
                ('gapW24', gapW24),
                ('gapW32', gapW32),
              ], axis: Axis.horizontal),
            ],
          ),
        );
      },
    ),
    WidgetbookUseCase(
      name: 'EdgeInsets Presets',
      builder: (context) {
        return catalogWrapper(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'pad* (all sides)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _padDemo('pad4', pad4),
                  _padDemo('pad8', pad8),
                  _padDemo('pad16', pad16),
                  _padDemo('pad24', pad24),
                  _padDemo('pad32', pad32),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'padX* (horizontal)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _padDemo('padX8', padX8),
                  _padDemo('padX16', padX16),
                  _padDemo('padX24', padX24),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'padY* (vertical)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _padDemo('padY8', padY8),
                  _padDemo('padY16', padY16),
                  _padDemo('padY24', padY24),
                ],
              ),
            ],
          ),
        );
      },
    ),
  ],
);

Widget _sizeTile(String label, double value) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8),
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
          height: 20,
          decoration: BoxDecoration(
            color: const Color(0xFF2563EB),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    ),
  );
}

List<Widget> _gapDemo(List<(String, SizedBox)> gaps, {required Axis axis}) {
  return gaps.map((entry) {
    final (label, gap) = entry;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 12),
          if (axis == Axis.vertical)
            Column(children: [_colorBox(), gap, _colorBox()])
          else
            Row(children: [_colorBox(), gap, _colorBox()]),
        ],
      ),
    );
  }).toList();
}

Widget _colorBox() {
  return Container(
    width: 32,
    height: 32,
    decoration: BoxDecoration(
      color: const Color(0xFF2563EB),
      borderRadius: BorderRadius.circular(4),
    ),
  );
}

Widget _padDemo(String label, EdgeInsets insets) {
  return Column(
    children: [
      Container(
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFCBD5E1)),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Padding(
          padding: insets,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ),
      const SizedBox(height: 4),
      Text(
        label,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
      ),
    ],
  );
}
