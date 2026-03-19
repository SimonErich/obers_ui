import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_widgetbook/helpers/knob_helpers.dart';
import 'package:widgetbook/widgetbook.dart';

final oiIconComponent = WidgetbookComponent(
  name: 'OiIcon',
  useCases: [
    WidgetbookUseCase(
      name: 'Semantic',
      builder: (context) {
        final icon = context.knobs.iconKnob();
        final size = context.knobs.double.slider(
          label: 'Size',
          initialValue: 24,
          min: 12,
          max: 64,
        );
        final label = context.knobs.string(
          label: 'Label',
          initialValue: 'Home icon',
        );

        return useCaseWrapper(OiIcon(icon: icon, label: label, size: size));
      },
    ),
    WidgetbookUseCase(
      name: 'Decorative',
      builder: (context) {
        final icon = context.knobs.iconKnob();
        final size = context.knobs.double.slider(
          label: 'Size',
          initialValue: 24,
          min: 12,
          max: 64,
        );

        return useCaseWrapper(OiIcon.decorative(icon: icon, size: size));
      },
    ),
  ],
);
