import 'package:flutter/material.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_widgetbook/helpers/knob_helpers.dart';
import 'package:widgetbook/widgetbook.dart';

final oiEditableComponent = WidgetbookComponent(
  name: 'OiEditable',
  useCases: [
    WidgetbookUseCase(
      name: 'Editable Text',
      builder: (context) {
        final enabled = context.knobs.boolean(
          label: 'Enabled',
          initialValue: true,
        );

        return useCaseWrapper(_EditableTextDemo(enabled: enabled));
      },
    ),
    WidgetbookUseCase(
      name: 'Editable Number',
      builder: (context) {
        final enabled = context.knobs.boolean(
          label: 'Enabled',
          initialValue: true,
        );
        final min = context.knobs.double.slider(
          label: 'Min',
          min: -100,
          max: 0,
        );
        final max = context.knobs.double.slider(
          label: 'Max',
          initialValue: 100,
          min: 1,
          max: 1000,
        );
        final step = context.knobs.double.slider(
          label: 'Step',
          initialValue: 1,
          min: 0.1,
          max: 10,
        );

        return useCaseWrapper(
          _EditableNumberDemo(enabled: enabled, min: min, max: max, step: step),
        );
      },
    ),
    WidgetbookUseCase(
      name: 'Editable Date',
      builder: (context) {
        final enabled = context.knobs.boolean(
          label: 'Enabled',
          initialValue: true,
        );

        return useCaseWrapper(_EditableDateDemo(enabled: enabled));
      },
    ),
    WidgetbookUseCase(
      name: 'Editable Select',
      builder: (context) {
        final enabled = context.knobs.boolean(
          label: 'Enabled',
          initialValue: true,
        );

        return useCaseWrapper(_EditableSelectDemo(enabled: enabled));
      },
    ),
  ],
);

// ---------------------------------------------------------------------------
// Editable Text demo
// ---------------------------------------------------------------------------

class _EditableTextDemo extends StatefulWidget {
  const _EditableTextDemo({required this.enabled});

  final bool enabled;

  @override
  State<_EditableTextDemo> createState() => _EditableTextDemoState();
}

class _EditableTextDemoState extends State<_EditableTextDemo> {
  String _value = 'Click to edit this text';

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tap the text below to edit:',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        OiEditableText(
          value: _value,
          enabled: widget.enabled,
          onChanged: (v) => setState(() => _value = v),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Editable Number demo
// ---------------------------------------------------------------------------

class _EditableNumberDemo extends StatefulWidget {
  const _EditableNumberDemo({
    required this.enabled,
    required this.min,
    required this.max,
    required this.step,
  });

  final bool enabled;
  final double min;
  final double max;
  final double step;

  @override
  State<_EditableNumberDemo> createState() => _EditableNumberDemoState();
}

class _EditableNumberDemoState extends State<_EditableNumberDemo> {
  double? _value = 42;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tap the number below to edit:',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 200,
          child: OiEditableNumber(
            value: _value,
            enabled: widget.enabled,
            min: widget.min,
            max: widget.max,
            step: widget.step,
            onChanged: (v) => setState(() => _value = v),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Editable Date demo
// ---------------------------------------------------------------------------

class _EditableDateDemo extends StatefulWidget {
  const _EditableDateDemo({required this.enabled});

  final bool enabled;

  @override
  State<_EditableDateDemo> createState() => _EditableDateDemoState();
}

class _EditableDateDemoState extends State<_EditableDateDemo> {
  DateTime? _value = DateTime(2025, 6, 15);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tap the date below to edit:',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 300,
          child: OiEditableDate(
            value: _value,
            enabled: widget.enabled,
            onChanged: (v) => setState(() => _value = v),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Editable Select demo
// ---------------------------------------------------------------------------

class _EditableSelectDemo extends StatefulWidget {
  const _EditableSelectDemo({required this.enabled});

  final bool enabled;

  @override
  State<_EditableSelectDemo> createState() => _EditableSelectDemoState();
}

class _EditableSelectDemoState extends State<_EditableSelectDemo> {
  String? _value = 'medium';

  static const _options = [
    OiSelectOption(value: 'low', label: 'Low'),
    OiSelectOption(value: 'medium', label: 'Medium'),
    OiSelectOption(value: 'high', label: 'High'),
    OiSelectOption(value: 'critical', label: 'Critical'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tap the value below to edit:',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 300,
          child: OiEditableSelect<String>(
            options: _options,
            value: _value,
            enabled: widget.enabled,
            onChanged: (v) => setState(() => _value = v),
          ),
        ),
      ],
    );
  }
}
