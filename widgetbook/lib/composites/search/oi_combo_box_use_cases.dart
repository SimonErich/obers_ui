import 'package:flutter/material.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_widgetbook/helpers/knob_helpers.dart';
import 'package:widgetbook/widgetbook.dart';

const _fruits = ['Apple', 'Banana', 'Cherry', 'Date', 'Elderberry'];

final oiComboBoxComponent = WidgetbookComponent(
  name: 'OiComboBox',
  useCases: [
    WidgetbookUseCase(
      name: 'Playground',
      builder: (context) {
        final clearable = context.knobs.boolean(
          label: 'Clearable',
          initialValue: true,
        );
        final multiSelect = context.knobs.boolean(label: 'Multi Select');
        final enabled = context.knobs.boolean(
          label: 'Enabled',
          initialValue: true,
        );
        final placeholder = context.knobs.string(
          label: 'Placeholder',
          initialValue: 'Select a fruit...',
        );

        return StatefulBuilder(
          builder: (context, setState) {
            String? selectedValue;
            var selectedValues = <String>[];
            return useCaseWrapper(
              SizedBox(
                width: 300,
                child: OiComboBox<String>(
                  label: 'Fruit picker',
                  labelOf: (item) => item,
                  items: _fruits,
                  value: multiSelect ? null : selectedValue,
                  onSelect: multiSelect
                      ? null
                      : (v) => setState(() => selectedValue = v),
                  clearable: clearable,
                  multiSelect: multiSelect,
                  selectedValues: selectedValues,
                  onMultiSelect: multiSelect
                      ? (v) => setState(() => selectedValues = v)
                      : null,
                  enabled: enabled,
                  placeholder: placeholder,
                ),
              ),
            );
          },
        );
      },
    ),
  ],
);
