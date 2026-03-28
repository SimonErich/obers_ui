import 'package:flutter/material.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_widgetbook/helpers/knob_helpers.dart';
import 'package:widgetbook/widgetbook.dart';

final oiColorPalettePickerComponent = WidgetbookComponent(
  name: 'OiColorPalettePicker',
  useCases: [
    WidgetbookUseCase(
      name: 'Playground',
      builder: (context) {
        final compact = context.knobs.boolean(
          label: 'Compact',
          initialValue: true,
        );
        final showPresets = context.knobs.boolean(
          label: 'Show Presets',
          initialValue: true,
        );

        return useCaseWrapper(
          SizedBox(
            width: 360,
            child: OiColorPalettePicker(
              label: 'Brand colors',
              compact: compact,
              showPresets: showPresets,
              slots: const [
                OiColorSlot(
                  id: 'primary',
                  label: 'Primary',
                  value: Color(0xFF3B82F6),
                ),
                OiColorSlot(
                  id: 'secondary',
                  label: 'Secondary',
                  value: Color(0xFF8B5CF6),
                ),
                OiColorSlot(id: 'accent', label: 'Accent'),
                OiColorSlot(
                  id: 'neutral',
                  label: 'Neutral',
                  value: Color(0xFF6B7280),
                ),
              ],
              presets: const [
                OiColorPalette(
                  id: 'ocean',
                  name: 'Ocean Breeze',
                  category: 'cool',
                  colors: {
                    'primary': Color(0xFF0EA5E9),
                    'secondary': Color(0xFF06B6D4),
                    'accent': Color(0xFF14B8A6),
                    'neutral': Color(0xFF64748B),
                  },
                ),
                OiColorPalette(
                  id: 'sunset',
                  name: 'Sunset Warm',
                  category: 'warm',
                  colors: {
                    'primary': Color(0xFFF59E0B),
                    'secondary': Color(0xFFF97316),
                    'accent': Color(0xFFEF4444),
                    'neutral': Color(0xFF78716C),
                  },
                ),
                OiColorPalette(
                  id: 'forest',
                  name: 'Forest Green',
                  category: 'natural',
                  colors: {
                    'primary': Color(0xFF22C55E),
                    'secondary': Color(0xFF16A34A),
                    'accent': Color(0xFF84CC16),
                    'neutral': Color(0xFF57534E),
                  },
                ),
              ],
              onSlotChanged: (slotId, color) {},
              onPresetSelected: (palette) {},
            ),
          ),
        );
      },
    ),
  ],
);
