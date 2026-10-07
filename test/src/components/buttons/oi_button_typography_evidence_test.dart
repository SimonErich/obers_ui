import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:obers_ui/obers_ui.dart';

import 'oi_button_evidence_fixture.dart';

void main() {
  testWidgets('normal and confirm labels honor opt-in source line boxes', (
    tester,
  ) async {
    const family = 'Ahem';
    final heights = <String, double>{};
    for (final size in [OiButtonSize.medium, OiButtonSize.large]) {
      final fontSize = size == OiButtonSize.large ? 15.0 : 14.0;
      final line = size == OiButtonSize.large ? 22.0 : 20.0;
      final base = OiThemeData.light();
      final theme = base.copyWith(
        components: base.components.copyWith(
          button: OiButtonThemeData(
            textStyle: buttonEvidenceStyle(family, fontSize, line),
            sizeStyles: OiButtonSizeStyles(
              medium: OiButtonSizeStyle(
                textStyle: buttonEvidenceStyle(family, 14, 20),
              ),
              large: OiButtonSizeStyle(
                textStyle: buttonEvidenceStyle(family, 15, 22),
              ),
            ),
          ),
        ),
      );
      for (final confirm in [false, true]) {
        const label = 'Action Hg';
        final button = confirm
            ? OiButton.confirm(
                key: buttonEvidenceKey,
                label: label,
                confirmLabel: 'Confirm Hg',
                onConfirm: () {},
                size: size,
              )
            : OiButton.primary(
                key: buttonEvidenceKey,
                label: label,
                onTap: () {},
                size: size,
              );
        await captureButtonEvidence(tester, button, theme: theme);
        final paragraph = buttonEvidenceParagraph(tester, label);
        final style = paragraph.text.style!;
        final id = '${confirm ? 'confirm' : 'normal'}-${size.name}';
        heights[id] = paragraph.size.height;
        expect(style.fontSize, fontSize);
        expect(style.fontVariations, const [
          FontVariation('wght', 500),
          FontVariation('wdth', 100),
        ]);
        debugPrint(
          jsonEncode({
            'specimen': id,
            'font': family,
            'paragraph': [paragraph.size.width, paragraph.size.height],
            'styleHeight': style.height,
            'requestedLine': line,
          }),
        );
        expect(tester.takeException(), isNull);
      }
    }
    expect(heights, {
      'normal-medium': 20.0,
      'confirm-medium': 20.0,
      'normal-large': 22.0,
      'confirm-large': 22.0,
    });
  });
}
