import 'package:flutter/material.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:widgetbook/widgetbook.dart';

import '../../helpers/knob_helpers.dart';

final oiCheckboxComponent = WidgetbookComponent(
  name: 'OiCheckbox',
  useCases: [
    WidgetbookUseCase(
      name: 'Playground',
      builder: (context) {
        final label = context.knobs.string(
          label: 'Label',
          initialValue: 'Accept terms',
        );
        final enabled = context.knobs.boolean(
          label: 'Enabled',
          initialValue: true,
        );

        return useCaseWrapper(
          _CheckboxDemo(label: label, enabled: enabled),
        );
      },
    ),
    WidgetbookUseCase(
      name: 'Tri-State',
      builder: (context) {
        final enabled = context.knobs.boolean(
          label: 'Enabled',
          initialValue: true,
        );

        return useCaseWrapper(
          _TriStateCheckboxDemo(enabled: enabled),
        );
      },
    ),
  ],
);

class _CheckboxDemo extends StatefulWidget {
  const _CheckboxDemo({required this.label, required this.enabled});

  final String label;
  final bool enabled;

  @override
  State<_CheckboxDemo> createState() => _CheckboxDemoState();
}

class _CheckboxDemoState extends State<_CheckboxDemo> {
  bool _checked = false;

  @override
  Widget build(BuildContext context) {
    return OiCheckbox(
      value: _checked,
      label: widget.label.isEmpty ? null : widget.label,
      enabled: widget.enabled,
      onChanged: (v) => setState(() => _checked = v),
    );
  }
}

class _TriStateCheckboxDemo extends StatefulWidget {
  const _TriStateCheckboxDemo({required this.enabled});

  final bool enabled;

  @override
  State<_TriStateCheckboxDemo> createState() => _TriStateCheckboxDemoState();
}

class _TriStateCheckboxDemoState extends State<_TriStateCheckboxDemo> {
  // Cycles: unchecked -> checked -> indeterminate -> unchecked
  bool? _value = false;

  void _cycle(bool v) {
    setState(() {
      if (_value == false) {
        _value = true;
      } else if (_value == true) {
        _value = null; // indeterminate
      } else {
        _value = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OiCheckbox(
          value: _value,
          label: 'Tri-state checkbox',
          enabled: widget.enabled,
          onChanged: _cycle,
        ),
        const SizedBox(height: 8),
        Text(
          'State: ${_value == null ? "indeterminate" : _value == true ? "checked" : "unchecked"}',
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}
