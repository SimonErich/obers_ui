import 'package:flutter/material.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:widgetbook/widgetbook.dart';

import '../../helpers/knob_helpers.dart';

final oiSelectComponent = WidgetbookComponent(
  name: 'OiSelect',
  useCases: [
    WidgetbookUseCase(
      name: 'Playground',
      builder: (context) {
        final label = context.knobs.string(
          label: 'Label',
          initialValue: 'Country',
        );
        final hint = context.knobs.string(
          label: 'Hint',
          initialValue: 'Select your country',
        );
        final searchable = context.knobs.boolean(
          label: 'Searchable',
          initialValue: false,
        );
        final enabled = context.knobs.boolean(
          label: 'Enabled',
          initialValue: true,
        );

        return useCaseWrapper(
          SizedBox(
            width: 300,
            child: _SelectDemo(
              label: label,
              hint: hint,
              searchable: searchable,
              enabled: enabled,
            ),
          ),
        );
      },
    ),
  ],
);

class _SelectDemo extends StatefulWidget {
  const _SelectDemo({
    required this.label,
    required this.hint,
    required this.searchable,
    required this.enabled,
  });

  final String label;
  final String hint;
  final bool searchable;
  final bool enabled;

  @override
  State<_SelectDemo> createState() => _SelectDemoState();
}

class _SelectDemoState extends State<_SelectDemo> {
  String? _value;

  static const _options = [
    OiSelectOption(value: 'us', label: 'United States'),
    OiSelectOption(value: 'uk', label: 'United Kingdom'),
    OiSelectOption(value: 'de', label: 'Germany'),
    OiSelectOption(value: 'fr', label: 'France'),
    OiSelectOption(value: 'jp', label: 'Japan'),
    OiSelectOption(value: 'au', label: 'Australia'),
    OiSelectOption(value: 'ca', label: 'Canada'),
    OiSelectOption(value: 'br', label: 'Brazil'),
  ];

  @override
  Widget build(BuildContext context) {
    return OiSelect<String>(
      options: _options,
      value: _value,
      label: widget.label.isEmpty ? null : widget.label,
      hint: widget.hint.isEmpty ? null : widget.hint,
      placeholder: 'Choose...',
      searchable: widget.searchable,
      enabled: widget.enabled,
      onChanged: (v) => setState(() => _value = v),
    );
  }
}
