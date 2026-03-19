import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_widgetbook/helpers/knob_helpers.dart';
import 'package:widgetbook/widgetbook.dart';

final oiTimePickerComponent = WidgetbookComponent(
  name: 'OiTimePicker',
  useCases: [
    WidgetbookUseCase(
      name: 'Playground',
      builder: (context) {
        final use24Hour = context.knobs.boolean(
          label: 'Use 24 Hour',
          initialValue: true,
        );

        return useCaseWrapper(
          OiTimePicker(use24Hour: use24Hour, onChanged: (_) {}),
        );
      },
    ),
  ],
);
