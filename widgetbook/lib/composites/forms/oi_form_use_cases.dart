import 'package:flutter/material.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_widgetbook/helpers/knob_helpers.dart';
import 'package:widgetbook/widgetbook.dart';

const _sampleSections = [
  OiFormSection(
    title: 'Personal Info',
    description: 'Enter your basic details',
    fields: [
      OiFormField(key: 'name', label: 'Full Name', type: OiFieldType.text),
      OiFormField(
        key: 'age',
        label: 'Age',
        type: OiFieldType.number,
        config: {'min': 0.0, 'max': 120.0},
      ),
      OiFormField(
        key: 'subscribe',
        label: 'Subscribe to newsletter',
        type: OiFieldType.checkbox,
      ),
    ],
  ),
  OiFormSection(
    title: 'Preferences',
    fields: [
      OiFormField(
        key: 'notifications',
        label: 'Enable Notifications',
        type: OiFieldType.switchField,
      ),
    ],
  ),
];

final oiFormComponent = WidgetbookComponent(
  name: 'OiForm',
  useCases: [
    WidgetbookUseCase(
      name: 'Playground',
      builder: (context) {
        final layout = context.knobs.enumKnob<OiFormLayout>(
          label: 'Layout',
          values: OiFormLayout.values,
        );
        final autoValidate = context.knobs.boolean(label: 'Auto Validate');

        final controller = OiFormController();

        return useCaseWrapper(
          SizedBox(
            width: 400,
            child: OiForm(
              sections: _sampleSections,
              controller: controller,
              layout: layout,
              autoValidate: autoValidate,
              onSubmit: (values) {},
              onCancel: () {},
            ),
          ),
        );
      },
    ),
  ],
);
