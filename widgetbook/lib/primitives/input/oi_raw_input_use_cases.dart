import 'package:flutter/material.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_widgetbook/helpers/knob_helpers.dart';
import 'package:widgetbook/widgetbook.dart';

final oiRawInputComponent = WidgetbookComponent(
  name: 'OiRawInput',
  useCases: [
    WidgetbookUseCase(
      name: 'Default',
      builder: (context) {
        final placeholder = context.knobs.string(
          label: 'Placeholder',
          initialValue: 'Enter text...',
        );
        final enabled = context.knobs.boolean(
          label: 'Enabled',
          initialValue: true,
        );
        final readOnly = context.knobs.boolean(label: 'Read Only');
        final obscureText = context.knobs.boolean(label: 'Obscure Text');

        return useCaseWrapper(
          _RawInputDemo(
            placeholder: placeholder,
            enabled: enabled,
            readOnly: readOnly,
            obscureText: obscureText,
          ),
        );
      },
    ),
  ],
);

class _RawInputDemo extends StatefulWidget {
  const _RawInputDemo({
    required this.placeholder,
    required this.enabled,
    required this.readOnly,
    required this.obscureText,
  });

  final String placeholder;
  final bool enabled;
  final bool readOnly;
  final bool obscureText;

  @override
  State<_RawInputDemo> createState() => _RawInputDemoState();
}

class _RawInputDemoState extends State<_RawInputDemo> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFBDBDBD)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: OiRawInput(
        controller: _controller,
        focusNode: _focusNode,
        placeholder: widget.placeholder,
        enabled: widget.enabled,
        readOnly: widget.readOnly,
        obscureText: widget.obscureText,
      ),
    );
  }
}
