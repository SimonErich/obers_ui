import 'package:flutter/material.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_widgetbook/helpers/knob_helpers.dart';
import 'package:widgetbook/widgetbook.dart';

final oiFloatingComponent = WidgetbookComponent(
  name: 'OiFloating',
  useCases: [
    WidgetbookUseCase(
      name: 'Default',
      builder: (context) {
        final alignment = context.knobs.enumKnob(
          label: 'Alignment',
          values: OiFloatingAlignment.values,
          initialValue: OiFloatingAlignment.bottomStart,
        );
        final gap = context.knobs.double.slider(
          label: 'Gap',
          initialValue: 4,
          max: 24,
        );

        return useCaseWrapper(_FloatingDemo(alignment: alignment, gap: gap));
      },
    ),
  ],
);

class _FloatingDemo extends StatefulWidget {
  const _FloatingDemo({required this.alignment, required this.gap});
  final OiFloatingAlignment alignment;
  final double gap;

  @override
  State<_FloatingDemo> createState() => _FloatingDemoState();
}

class _FloatingDemoState extends State<_FloatingDemo> {
  bool _visible = false;

  @override
  Widget build(BuildContext context) {
    return OiFloating(
      visible: _visible,
      alignment: widget.alignment,
      gap: widget.gap,
      anchor: GestureDetector(
        onTap: () => setState(() => _visible = !_visible),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: const Color(0xFF2196F3),
          child: Text(
            _visible ? 'Hide floating' : 'Show floating',
            style: const TextStyle(color: Color(0xFFFFFFFF)),
          ),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        color: const Color(0xFFFFF9C4),
        child: const Text('Floating content'),
      ),
    );
  }
}

final oiPortalComponent = WidgetbookComponent(
  name: 'OiPortal',
  useCases: [
    WidgetbookUseCase(
      name: 'Default',
      builder: (context) {
        return useCaseWrapper(const _PortalDemo());
      },
    ),
  ],
);

class _PortalDemo extends StatefulWidget {
  const _PortalDemo();

  @override
  State<_PortalDemo> createState() => _PortalDemoState();
}

class _PortalDemoState extends State<_PortalDemo> {
  bool _active = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () => setState(() => _active = !_active),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: const Color(0xFF4CAF50),
            child: Text(
              _active ? 'Close portal' : 'Open portal',
              style: const TextStyle(color: Color(0xFFFFFFFF)),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text('Portal is ${_active ? "active" : "inactive"}'),
        OiPortal(
          active: _active,
          child: Positioned(
            top: 100,
            left: 100,
            child: Container(
              padding: const EdgeInsets.all(16),
              color: const Color(0xFFFFF9C4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Portal overlay content'),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => setState(() => _active = false),
                    child: const Text('Close'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

final oiVisibilityComponent = WidgetbookComponent(
  name: 'OiVisibility',
  useCases: [
    WidgetbookUseCase(
      name: 'Default',
      builder: (context) {
        final transition = context.knobs.enumKnob(
          label: 'Transition',
          values: OiTransition.values,
          initialValue: OiTransition.fade,
        );
        final maintainState = context.knobs.boolean(
          label: 'Maintain State',
          initialValue: true,
        );

        return useCaseWrapper(
          _VisibilityDemo(transition: transition, maintainState: maintainState),
        );
      },
    ),
  ],
);

class _VisibilityDemo extends StatefulWidget {
  const _VisibilityDemo({
    required this.transition,
    required this.maintainState,
  });
  final OiTransition transition;
  final bool maintainState;

  @override
  State<_VisibilityDemo> createState() => _VisibilityDemoState();
}

class _VisibilityDemoState extends State<_VisibilityDemo> {
  bool _visible = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () => setState(() => _visible = !_visible),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: const Color(0xFF2196F3),
            child: Text(
              _visible ? 'Hide' : 'Show',
              style: const TextStyle(color: Color(0xFFFFFFFF)),
            ),
          ),
        ),
        const SizedBox(height: 24),
        OiVisibility(
          visible: _visible,
          transition: widget.transition,
          maintainState: widget.maintainState,
          child: Container(
            width: 150,
            height: 80,
            color: const Color(0xFFC8E6C9),
            child: const Center(child: Text('Visible content')),
          ),
        ),
      ],
    );
  }
}
