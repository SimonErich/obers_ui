import 'package:flutter/material.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_widgetbook/helpers/knob_helpers.dart';
import 'package:widgetbook/widgetbook.dart';

final colorSchemeComponent = WidgetbookComponent(
  name: 'OiColorScheme',
  useCases: [
    WidgetbookUseCase(
      name: 'All Tokens',
      builder: (context) {
        final theme = OiTheme.of(context);
        final colors = theme.colors;

        return catalogWrapper(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle('Semantic Swatches'),
              const SizedBox(height: 8),
              _swatchRow('primary', colors.primary),
              _swatchRow('accent', colors.accent),
              _swatchRow('success', colors.success),
              _swatchRow('warning', colors.warning),
              _swatchRow('error', colors.error),
              _swatchRow('info', colors.info),
              const SizedBox(height: 24),
              _sectionTitle('Surface Colors'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _colorTile('background', colors.background),
                  _colorTile('surface', colors.surface),
                  _colorTile('surfaceHover', colors.surfaceHover),
                  _colorTile('surfaceActive', colors.surfaceActive),
                  _colorTile('surfaceSubtle', colors.surfaceSubtle),
                  _colorTile('overlay', colors.overlay),
                ],
              ),
              const SizedBox(height: 24),
              _sectionTitle('Text Colors'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _colorTile('text', colors.text),
                  _colorTile('textSubtle', colors.textSubtle),
                  _colorTile('textMuted', colors.textMuted),
                  _colorTile('textInverse', colors.textInverse),
                  _colorTile('textOnPrimary', colors.textOnPrimary),
                ],
              ),
              const SizedBox(height: 24),
              _sectionTitle('Border Colors'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _colorTile('border', colors.border),
                  _colorTile('borderSubtle', colors.borderSubtle),
                  _colorTile('borderFocus', colors.borderFocus),
                  _colorTile('borderError', colors.borderError),
                ],
              ),
              const SizedBox(height: 24),
              _sectionTitle('Glass Colors'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _colorTile('glassBackground', colors.glassBackground),
                  _colorTile('glassBorder', colors.glassBorder),
                ],
              ),
              const SizedBox(height: 24),
              _sectionTitle('Chart Palette'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  for (var i = 0; i < colors.chart.length; i++)
                    _colorTile('chart[$i]', colors.chart[i]),
                ],
              ),
            ],
          ),
        );
      },
    ),
  ],
);

Widget _sectionTitle(String title) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
    ),
  );
}

Widget _swatchRow(String name, OiColorSwatch swatch) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _colorTile('base', swatch.base, compact: true),
            _colorTile('light', swatch.light, compact: true),
            _colorTile('dark', swatch.dark, compact: true),
            _colorTile('muted', swatch.muted, compact: true),
            _colorTile('foreground', swatch.foreground, compact: true),
          ],
        ),
      ],
    ),
  );
}

Widget _colorTile(String label, Color color, {bool compact = false}) {
  final size = compact ? 48.0 : 64.0;
  final hexString =
      '#${color.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase()}';

  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color(0x33000000)),
        ),
      ),
      const SizedBox(height: 4),
      SizedBox(
        width: size + 16,
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      SizedBox(
        width: size + 16,
        child: Text(
          hexString,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 9),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ],
  );
}
