import 'package:flutter/material.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_widgetbook/helpers/knob_helpers.dart';
import 'package:widgetbook/widgetbook.dart';

final oiTappableComponent = WidgetbookComponent(
  name: 'OiTappable',
  useCases: [
    WidgetbookUseCase(
      name: 'Default',
      builder: (context) {
        final enabled = context.knobs.boolean(
          label: 'Enabled',
          initialValue: true,
        );
        final semanticLabel = context.knobs.string(
          label: 'Semantic Label',
          initialValue: 'Tap me',
        );

        return useCaseWrapper(
          _TappableDemo(enabled: enabled, semanticLabel: semanticLabel),
        );
      },
    ),
  ],
);

class _TappableDemo extends StatefulWidget {
  const _TappableDemo({required this.enabled, required this.semanticLabel});
  final bool enabled;
  final String semanticLabel;

  @override
  State<_TappableDemo> createState() => _TappableDemoState();
}

class _TappableDemoState extends State<_TappableDemo> {
  int _tapCount = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        OiTappable(
          onTap: () => setState(() => _tapCount++),
          enabled: widget.enabled,
          semanticLabel: widget.semanticLabel,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            color: const Color(0xFF2196F3),
            child: const Text(
              'Tap me',
              style: TextStyle(color: Color(0xFFFFFFFF)),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text('Tapped $_tapCount times'),
      ],
    );
  }
}

final oiFocusTrapComponent = WidgetbookComponent(
  name: 'OiFocusTrap',
  useCases: [
    WidgetbookUseCase(
      name: 'Default',
      builder: (context) {
        return useCaseWrapper(const _FocusTrapDemo());
      },
    ),
  ],
);

class _FocusTrapDemo extends StatefulWidget {
  const _FocusTrapDemo();

  @override
  State<_FocusTrapDemo> createState() => _FocusTrapDemoState();
}

class _FocusTrapDemoState extends State<_FocusTrapDemo> {
  bool _trapped = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Focus trap is ${_trapped ? "active" : "inactive"}'),
        const SizedBox(height: 16),
        if (_trapped)
          OiFocusTrap(
            onEscape: () => setState(() => _trapped = false),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFF2196F3)),
                  ),
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Tab to cycle focus, Escape to exit'),
                      SizedBox(height: 8),
                      SizedBox(
                        width: 200,
                        child: TextField(
                          decoration: InputDecoration(hintText: 'Field 1'),
                        ),
                      ),
                      SizedBox(height: 8),
                      SizedBox(
                        width: 200,
                        child: TextField(
                          decoration: InputDecoration(hintText: 'Field 2'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        else
          GestureDetector(
            onTap: () => setState(() => _trapped = true),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: const Color(0xFF4CAF50),
              child: const Text(
                'Re-enable trap',
                style: TextStyle(color: Color(0xFFFFFFFF)),
              ),
            ),
          ),
      ],
    );
  }
}
