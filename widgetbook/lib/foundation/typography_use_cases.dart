import 'package:flutter/material.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:widgetbook/widgetbook.dart';

import 'package:obers_ui_widgetbook/helpers/knob_helpers.dart';

final typographyComponent = WidgetbookComponent(
  name: 'OiTextTheme / OiLabel',
  useCases: [
    WidgetbookUseCase(
      name: 'All Variants',
      builder: (context) {
        return catalogWrapper(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final variant in OiLabelVariant.values)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0x1A2563EB),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          variant.name,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2563EB),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      _VariantLabel(
                        variant: variant,
                        text: _sampleText(variant),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    ),
  ],
);

class _VariantLabel extends StatelessWidget {
  const _VariantLabel({required this.variant, required this.text});

  final OiLabelVariant variant;
  final String text;

  @override
  Widget build(BuildContext context) {
    switch (variant) {
      case OiLabelVariant.display:
        return OiLabel.display(text);
      case OiLabelVariant.h1:
        return OiLabel.h1(text);
      case OiLabelVariant.h2:
        return OiLabel.h2(text);
      case OiLabelVariant.h3:
        return OiLabel.h3(text);
      case OiLabelVariant.h4:
        return OiLabel.h4(text);
      case OiLabelVariant.body:
        return OiLabel.body(text);
      case OiLabelVariant.bodyStrong:
        return OiLabel.bodyStrong(text);
      case OiLabelVariant.small:
        return OiLabel.small(text);
      case OiLabelVariant.smallStrong:
        return OiLabel.smallStrong(text);
      case OiLabelVariant.tiny:
        return OiLabel.tiny(text);
      case OiLabelVariant.caption:
        return OiLabel.caption(text);
      case OiLabelVariant.code:
        return OiLabel.code(text);
      case OiLabelVariant.overline:
        return OiLabel.overline(text);
      case OiLabelVariant.link:
        return OiLabel.link(text);
    }
  }
}

String _sampleText(OiLabelVariant variant) {
  switch (variant) {
    case OiLabelVariant.display:
      return 'Display heading';
    case OiLabelVariant.h1:
      return 'Heading level 1';
    case OiLabelVariant.h2:
      return 'Heading level 2';
    case OiLabelVariant.h3:
      return 'Heading level 3';
    case OiLabelVariant.h4:
      return 'Heading level 4';
    case OiLabelVariant.body:
      return 'Body text for standard paragraphs and content.';
    case OiLabelVariant.bodyStrong:
      return 'Bold body text for emphasis.';
    case OiLabelVariant.small:
      return 'Small text for secondary information.';
    case OiLabelVariant.smallStrong:
      return 'Bold small text for labels.';
    case OiLabelVariant.tiny:
      return 'Tiny text for dense UI.';
    case OiLabelVariant.caption:
      return 'Caption text below images.';
    case OiLabelVariant.code:
      return 'const greeting = "Hello, world!";';
    case OiLabelVariant.overline:
      return 'Overline section label';
    case OiLabelVariant.link:
      return 'Tap here to learn more';
  }
}
