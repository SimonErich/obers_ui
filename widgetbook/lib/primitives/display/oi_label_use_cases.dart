import 'package:flutter/material.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_widgetbook/helpers/knob_helpers.dart';
import 'package:widgetbook/widgetbook.dart';

final oiLabelComponent = WidgetbookComponent(
  name: 'OiLabel',
  useCases: [
    WidgetbookUseCase(
      name: 'Default',
      builder: (context) {
        final text = context.knobs.string(
          label: 'Text',
          initialValue: 'The quick brown fox jumps over the lazy dog',
        );
        final variant = context.knobs.enumKnob(
          label: 'Variant',
          values: OiLabelVariant.values,
          initialValue: OiLabelVariant.body,
        );
        final copyable = context.knobs.boolean(label: 'Copyable');
        final selectable = context.knobs.boolean(label: 'Selectable');

        Widget label;
        switch (variant) {
          case OiLabelVariant.display:
            label = OiLabel.display(
              text,
              copyable: copyable,
              selectable: selectable,
            );
          case OiLabelVariant.h1:
            label = OiLabel.h1(
              text,
              copyable: copyable,
              selectable: selectable,
            );
          case OiLabelVariant.h2:
            label = OiLabel.h2(
              text,
              copyable: copyable,
              selectable: selectable,
            );
          case OiLabelVariant.h3:
            label = OiLabel.h3(
              text,
              copyable: copyable,
              selectable: selectable,
            );
          case OiLabelVariant.h4:
            label = OiLabel.h4(
              text,
              copyable: copyable,
              selectable: selectable,
            );
          case OiLabelVariant.body:
            label = OiLabel.body(
              text,
              copyable: copyable,
              selectable: selectable,
            );
          case OiLabelVariant.bodyStrong:
            label = OiLabel.bodyStrong(
              text,
              copyable: copyable,
              selectable: selectable,
            );
          case OiLabelVariant.small:
            label = OiLabel.small(
              text,
              copyable: copyable,
              selectable: selectable,
            );
          case OiLabelVariant.smallStrong:
            label = OiLabel.smallStrong(
              text,
              copyable: copyable,
              selectable: selectable,
            );
          case OiLabelVariant.tiny:
            label = OiLabel.tiny(
              text,
              copyable: copyable,
              selectable: selectable,
            );
          case OiLabelVariant.caption:
            label = OiLabel.caption(
              text,
              copyable: copyable,
              selectable: selectable,
            );
          case OiLabelVariant.code:
            label = OiLabel.code(
              text,
              copyable: copyable,
              selectable: selectable,
            );
          case OiLabelVariant.overline:
            label = OiLabel.overline(
              text,
              copyable: copyable,
              selectable: selectable,
            );
          case OiLabelVariant.link:
            label = OiLabel.link(
              text,
              copyable: copyable,
              selectable: selectable,
            );
        }

        return useCaseWrapper(label);
      },
    ),
  ],
);
