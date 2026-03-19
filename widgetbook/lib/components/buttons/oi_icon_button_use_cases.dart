import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_widgetbook/helpers/knob_helpers.dart';
import 'package:widgetbook/widgetbook.dart';

final oiIconButtonComponent = WidgetbookComponent(
  name: 'OiIconButton',
  useCases: [
    WidgetbookUseCase(
      name: 'Playground',
      builder: (context) {
        final icon = context.knobs.iconKnob();
        final variant = context.knobs.enumKnob<OiButtonVariant>(
          label: 'Variant',
          values: OiButtonVariant.values,
          initialValue: OiButtonVariant.ghost,
        );
        final size = context.knobs.enumKnob<OiButtonSize>(
          label: 'Size',
          values: OiButtonSize.values,
        );
        final enabled = context.knobs.boolean(
          label: 'Enabled',
          initialValue: true,
        );

        return useCaseWrapper(
          OiIconButton(
            icon: icon,
            semanticLabel: 'Icon button',
            variant: variant,
            size: size,
            enabled: enabled,
            onTap: () {},
          ),
        );
      },
    ),
  ],
);
