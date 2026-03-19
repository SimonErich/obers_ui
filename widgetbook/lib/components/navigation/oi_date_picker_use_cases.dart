import 'package:flutter/material.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_widgetbook/helpers/knob_helpers.dart';
import 'package:widgetbook/widgetbook.dart';

final oiDatePickerComponent = WidgetbookComponent(
  name: 'OiDatePicker',
  useCases: [
    WidgetbookUseCase(
      name: 'Playground',
      builder: (context) {
        final rangeMode = context.knobs.boolean(label: 'Range Mode');

        return useCaseWrapper(
          SizedBox(
            width: 320,
            child: StatefulBuilder(
              builder: (context, setState) {
                DateTime? value;
                DateTime? rangeStart;
                DateTime? rangeEnd;
                return OiDatePicker(
                  value: value,
                  rangeMode: rangeMode,
                  rangeStart: rangeStart,
                  rangeEnd: rangeEnd,
                  onChanged: (d) => setState(() => value = d),
                  onRangeChanged: (s, e) => setState(() {
                    rangeStart = s;
                    rangeEnd = e;
                  }),
                );
              },
            ),
          ),
        );
      },
    ),
  ],
);
