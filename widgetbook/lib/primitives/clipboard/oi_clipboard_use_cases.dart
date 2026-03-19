import 'package:flutter/material.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_widgetbook/helpers/knob_helpers.dart';
import 'package:widgetbook/widgetbook.dart';

final oiCopyableComponent = WidgetbookComponent(
  name: 'OiCopyable',
  useCases: [
    WidgetbookUseCase(
      name: 'Default',
      builder: (context) {
        final value = context.knobs.string(
          label: 'Value to copy',
          initialValue: 'Hello, clipboard!',
        );
        final enabled = context.knobs.boolean(
          label: 'Enabled',
          initialValue: true,
        );

        return useCaseWrapper(_CopyableDemo(value: value, enabled: enabled));
      },
    ),
  ],
);

class _CopyableDemo extends StatefulWidget {
  const _CopyableDemo({required this.value, required this.enabled});
  final String value;
  final bool enabled;

  @override
  State<_CopyableDemo> createState() => _CopyableDemoState();
}

class _CopyableDemoState extends State<_CopyableDemo> {
  bool _copied = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        OiCopyable(
          value: widget.value,
          enabled: widget.enabled,
          onCopied: () => setState(() => _copied = true),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            color: const Color(0xFF2196F3),
            child: Text(
              'Tap to copy: "${widget.value}"',
              style: const TextStyle(color: Color(0xFFFFFFFF)),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(_copied ? 'Copied!' : 'Not yet copied'),
      ],
    );
  }
}

final oiCopyButtonComponent = WidgetbookComponent(
  name: 'OiCopyButton',
  useCases: [
    WidgetbookUseCase(
      name: 'Default',
      builder: (context) {
        final value = context.knobs.string(
          label: 'Value',
          initialValue: 'Copied text',
        );
        final semanticLabel = context.knobs.string(
          label: 'Semantic Label',
          initialValue: 'Copy to clipboard',
        );

        return useCaseWrapper(
          OiCopyButton(value: value, semanticLabel: semanticLabel),
        );
      },
    ),
  ],
);

final oiPasteZoneComponent = WidgetbookComponent(
  name: 'OiPasteZone',
  useCases: [
    WidgetbookUseCase(
      name: 'Default',
      builder: (context) {
        return useCaseWrapper(const _PasteZoneDemo());
      },
    ),
  ],
);

class _PasteZoneDemo extends StatefulWidget {
  const _PasteZoneDemo();

  @override
  State<_PasteZoneDemo> createState() => _PasteZoneDemoState();
}

class _PasteZoneDemoState extends State<_PasteZoneDemo> {
  String _pasted = 'Nothing pasted yet';

  @override
  Widget build(BuildContext context) {
    return OiPasteZone(
      autofocus: true,
      onPaste: (text) => setState(() => _pasted = text),
      child: Container(
        width: 250,
        height: 100,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFBDBDBD)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Focus here, then Ctrl+V'),
            const SizedBox(height: 8),
            Text(
              'Pasted: $_pasted',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
