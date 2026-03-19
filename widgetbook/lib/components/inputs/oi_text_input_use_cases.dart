import 'package:flutter/material.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:widgetbook/widgetbook.dart';

import '../../helpers/knob_helpers.dart';

final oiTextInputComponent = WidgetbookComponent(
  name: 'OiTextInput',
  useCases: [
    WidgetbookUseCase(
      name: 'Playground',
      builder: (context) {
        final label = context.knobs.string(
          label: 'Label',
          initialValue: 'Full Name',
        );
        final hint = context.knobs.string(
          label: 'Hint',
          initialValue: 'Enter your full name',
        );
        final placeholder = context.knobs.string(
          label: 'Placeholder',
          initialValue: 'John Doe',
        );
        final error = context.knobs.string(
          label: 'Error',
          initialValue: '',
        );
        final enabled = context.knobs.boolean(
          label: 'Enabled',
          initialValue: true,
        );
        final readOnly = context.knobs.boolean(
          label: 'Read Only',
          initialValue: false,
        );
        final obscureText = context.knobs.boolean(
          label: 'Obscure Text',
          initialValue: false,
        );

        return useCaseWrapper(
          SizedBox(
            width: 300,
            child: OiTextInput(
              label: label.isEmpty ? null : label,
              hint: hint.isEmpty ? null : hint,
              placeholder: placeholder.isEmpty ? null : placeholder,
              error: error.isEmpty ? null : error,
              enabled: enabled,
              readOnly: readOnly,
              obscureText: obscureText,
            ),
          ),
        );
      },
    ),
    WidgetbookUseCase(
      name: 'Search',
      builder: (context) {
        final enabled = context.knobs.boolean(
          label: 'Enabled',
          initialValue: true,
        );

        return useCaseWrapper(
          SizedBox(
            width: 300,
            child: OiTextInput.search(enabled: enabled),
          ),
        );
      },
    ),
  ],
);
