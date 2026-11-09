import 'dart:ui' as ui;

import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/obers_ui.dart';

import 'oi_button_evidence_fixture.dart';

const _label = 'Action Hg';
const _stateColor = Color(0xff128546);
const _consumers = ['normal', 'split', 'countdown', 'confirm'];

OiButton _button(String consumer, OiButtonSize size) => switch (consumer) {
  'normal' => OiButton.primary(
    key: buttonEvidenceKey,
    label: _label,
    onTap: () {},
    size: size,
  ),
  'split' => OiButton.split(
    key: buttonEvidenceKey,
    label: _label,
    onTap: () {},
    dropdown: const SizedBox(),
    size: size,
  ),
  'countdown' => OiButton.countdown(
    key: buttonEvidenceKey,
    label: _label,
    onTap: () {},
    seconds: 0,
    size: size,
  ),
  _ => OiButton.confirm(
    key: buttonEvidenceKey,
    label: _label,
    confirmLabel: 'Confirm Hg',
    onConfirm: () {},
    variant: OiButtonVariant.primary,
    size: size,
  ),
};

OiThemeData _theme(
  TextStyle? selected, {
  OiButtonSize size = OiButtonSize.medium,
  TextStyle? legacy,
  OiButtonVariantStyle? variant,
}) {
  final base = OiThemeData.light();
  return base.copyWith(
    components: base.components.copyWith(
      button: OiButtonThemeData(
        textStyle: legacy ?? const TextStyle(fontFamily: 'Ahem'),
        primaryStyle:
            variant ?? const OiButtonVariantStyle(foreground: _stateColor),
        sizeStyles: OiButtonSizeStyles(
          small: size == OiButtonSize.small
              ? OiButtonSizeStyle(textStyle: selected)
              : null,
          medium: size == OiButtonSize.medium
              ? OiButtonSizeStyle(textStyle: selected)
              : null,
          large: size == OiButtonSize.large
              ? OiButtonSizeStyle(textStyle: selected)
              : null,
        ),
      ),
    ),
  );
}

void main() {
  for (final size in OiButtonSize.values) {
    for (final consumer in _consumers) {
      testWidgets('${size.name} $consumer uses selected typography last', (
        tester,
      ) async {
        final font = size == OiButtonSize.large ? 15.0 : 14.0;
        final line = size == OiButtonSize.large ? 22.0 : 20.0;
        final selected = buttonEvidenceStyle('Ahem', font, line).copyWith(
          color: const Color(0xffff0000),
        );
        await captureButtonEvidence(
          tester,
          _button(consumer, size),
          theme: _theme(
            selected,
            size: size,
            legacy: buttonEvidenceStyle('Ahem', 10, 30).copyWith(
              fontWeight: FontWeight.w800,
              fontVariations: const [FontVariation('wght', 800)],
            ),
          ),
        );
        final paragraph = buttonEvidenceParagraph(tester, _label);
        final style = paragraph.text.style!;
        expect(paragraph.size.height, line);
        expect(style.fontSize, font);
        expect(style.fontFamily, 'Ahem');
        expect(style.fontWeight, FontWeight.w500);
        expect(style.fontVariations, selected.fontVariations);
        expect(style.leadingDistribution, TextLeadingDistribution.even);
        expect(style.letterSpacing, selected.letterSpacing);
        expect(style.color, _stateColor);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
      });
    }
  }

  testWidgets('null selected style preserves legacy leading, axes and Paint', (
    tester,
  ) async {
    for (final paint in [null, Paint()..color = const Color(0xffab1234)]) {
      final legacy = buttonEvidenceStyle('Ahem', 13, 26).copyWith(
        foreground: paint,
        fontVariations: const [FontVariation('wght', 725)],
      );
      final configured = _theme(null, legacy: legacy);
      final control = configured.copyWith(
        components: configured.components.copyWith(
          button: OiButtonThemeData(
            textStyle: legacy,
            primaryStyle: const OiButtonVariantStyle(foreground: _stateColor),
          ),
        ),
      );
      for (final size in OiButtonSize.values) {
        for (final consumer in _consumers) {
          final button = _button(consumer, size);
          final before = await captureButtonEvidence(
            tester,
            button,
            theme: control,
          );
          final after = await captureButtonEvidence(
            tester,
            button,
            theme: configured,
          );
          expect(after.bytes, orderedEquals(before.bytes));
          final style = buttonEvidenceParagraph(tester, _label).text.style!;
          expect(style.height, 1);
          expect(style.fontSize, 13);
          expect(style.fontVariations, legacy.fontVariations);
          expect(style.foreground, same(paint));
          expect(tester.takeException(), isNull);
        }
      }
    }
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets(
    'opt-in foreground Paint cannot replace state-owned glyph color',
    (
      tester,
    ) async {
      final style = buttonEvidenceStyle('Ahem', 14, 20);
      final paints = [
        Paint()..color = const Color(0xffff0000),
        Paint()
          ..shader = ui.Gradient.linear(
            Offset.zero,
            const Offset(320, 0),
            const [Color(0xffff0000), Color(0xff0000ff)],
          ),
      ];
      for (final paint in paints) {
        for (final consumer in _consumers) {
          final shader = paint.shader;
          final color = paint.color;
          final control = await captureButtonEvidence(
            tester,
            _button(consumer, OiButtonSize.medium),
            theme: _theme(style),
          );
          final actual = await captureButtonEvidence(
            tester,
            _button(consumer, OiButtonSize.medium),
            theme: _theme(style.copyWith(foreground: paint)),
          );
          var changed = 0;
          for (var i = 0; i < actual.bytes.length; i++) {
            if (actual.bytes[i] != control.bytes[i]) changed++;
          }
          expect(
            changed,
            0,
            reason: 'State color must own rendered glyph pixels',
          );
          final resolved = buttonEvidenceParagraph(tester, _label).text.style!;
          // Paint reads float32 channels; whole glyph raster equality is above.
          expect(
            (resolved.foreground?.color ?? resolved.color)?.toARGB32(),
            _stateColor.toARGB32(),
          );
          expect(resolved.foreground?.shader, isNull);
          expect(
            paint.color,
            color,
            reason: 'Authored Paint must not be mutated',
          );
          expect(paint.shader, same(shader));
          expect(tester.takeException(), isNull);
        }
      }
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'opt-in foreground yields to hover, pressed and disabled states',
    (
      tester,
    ) async {
      const hover = Color(0xff1428c5);
      const pressed = Color(0xff986212);
      const disabled = Color(0xff7c1791);
      final theme = _theme(
        buttonEvidenceStyle('Ahem', 14, 20).copyWith(
          foreground: Paint()..color = const Color(0xffff0000),
        ),
        variant: const OiButtonVariantStyle(
          foreground: _stateColor,
          foregroundHover: hover,
          foregroundPressed: pressed,
          foregroundDisabled: disabled,
        ),
      );
      void expectColor(Color color) => expect(
        buttonEvidenceParagraph(
          tester,
          _label,
        ).text.style!.foreground!.color.toARGB32(),
        color.toARGB32(),
      );
      await captureButtonEvidence(
        tester,
        _button('normal', OiButtonSize.medium),
        theme: theme,
      );
      expectColor(_stateColor);
      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: Offset.zero);
      await mouse.moveTo(tester.getCenter(find.byKey(buttonEvidenceKey)));
      await tester.pump();
      expectColor(hover);
      await mouse.down(tester.getCenter(find.byKey(buttonEvidenceKey)));
      await tester.pump();
      expectColor(pressed);
      await mouse.up();
      await mouse.removePointer();
      await captureButtonEvidence(
        tester,
        const OiButton.primary(
          key: buttonEvidenceKey,
          label: _label,
          enabled: false,
        ),
        theme: theme,
      );
      expectColor(disabled);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );
}
