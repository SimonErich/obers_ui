import 'package:flutter/material.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:widgetbook/widgetbook.dart';

import '../../helpers/knob_helpers.dart';

Widget _coloredBox(Color color, String label, {double size = 60}) {
  return Container(
    width: size,
    height: size,
    color: color,
    child: Center(child: Text(label, style: const TextStyle(color: Color(0xFFFFFFFF)))),
  );
}

final oiSpringComponent = WidgetbookComponent(
  name: 'OiSpring',
  useCases: [
    WidgetbookUseCase(
      name: 'Default',
      builder: (context) {
        final stiffness = context.knobs.double.slider(
          label: 'Stiffness',
          initialValue: 300,
          min: 50,
          max: 1000,
        );
        final damping = context.knobs.double.slider(
          label: 'Damping',
          initialValue: 30,
          min: 1,
          max: 100,
        );

        return useCaseWrapper(
          _SpringDemo(stiffness: stiffness, damping: damping),
        );
      },
    ),
  ],
);

class _SpringDemo extends StatefulWidget {
  const _SpringDemo({required this.stiffness, required this.damping});
  final double stiffness;
  final double damping;

  @override
  State<_SpringDemo> createState() => _SpringDemoState();
}

class _SpringDemoState extends State<_SpringDemo> {
  double _value = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () => setState(() => _value = _value == 0 ? 1 : 0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: const Color(0xFF2196F3),
            child: const Text('Toggle', style: TextStyle(color: Color(0xFFFFFFFF))),
          ),
        ),
        const SizedBox(height: 24),
        OiSpring(
          value: _value,
          stiffness: widget.stiffness,
          damping: widget.damping,
          builder: (context, v, child) => Opacity(
            opacity: v.clamp(0.0, 1.0),
            child: Transform.scale(scale: 0.5 + v * 0.5, child: child),
          ),
          child: _coloredBox(const Color(0xFF4CAF50), 'Spring', size: 80),
        ),
      ],
    );
  }
}

final oiShimmerComponent = WidgetbookComponent(
  name: 'OiShimmer',
  useCases: [
    WidgetbookUseCase(
      name: 'Default',
      builder: (context) {
        final active = context.knobs.boolean(
          label: 'Active',
          initialValue: true,
        );

        return useCaseWrapper(
          OiShimmer(
            active: active,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 200, height: 20, color: const Color(0xFFFFFFFF)),
                const SizedBox(height: 8),
                Container(width: 200, height: 20, color: const Color(0xFFFFFFFF)),
                const SizedBox(height: 8),
                Container(width: 140, height: 20, color: const Color(0xFFFFFFFF)),
              ],
            ),
          ),
        );
      },
    ),
  ],
);

final oiPulseComponent = WidgetbookComponent(
  name: 'OiPulse',
  useCases: [
    WidgetbookUseCase(
      name: 'Default',
      builder: (context) {
        final active = context.knobs.boolean(
          label: 'Active',
          initialValue: true,
        );
        final minOpacity = context.knobs.double.slider(
          label: 'Min Opacity',
          initialValue: 0.4,
          min: 0,
          max: 1,
        );

        return useCaseWrapper(
          OiPulse(
            active: active,
            minOpacity: minOpacity,
            child: _coloredBox(const Color(0xFFF44336), 'Pulse', size: 80),
          ),
        );
      },
    ),
  ],
);

final oiStaggerComponent = WidgetbookComponent(
  name: 'OiStagger',
  useCases: [
    WidgetbookUseCase(
      name: 'Default',
      builder: (context) {
        final transition = context.knobs.enumKnob(
          label: 'Transition',
          values: OiTransition.values,
          initialValue: OiTransition.fade,
        );

        return useCaseWrapper(
          OiStagger(
            transition: transition,
            staggerDelay: const Duration(milliseconds: 80),
            children: List.generate(
              5,
              (i) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _coloredBox(
                  Color(0xFF2196F3).withValues(alpha: 0.4 + i * 0.12),
                  'Item ${i + 1}',
                  size: 40,
                ),
              ),
            ),
          ),
        );
      },
    ),
  ],
);

final oiMorphComponent = WidgetbookComponent(
  name: 'OiMorph',
  useCases: [
    WidgetbookUseCase(
      name: 'Default',
      builder: (context) {
        final transition = context.knobs.enumKnob(
          label: 'Transition',
          values: OiTransition.values,
          initialValue: OiTransition.fade,
        );

        return useCaseWrapper(
          _MorphDemo(transition: transition),
        );
      },
    ),
  ],
);

class _MorphDemo extends StatefulWidget {
  const _MorphDemo({required this.transition});
  final OiTransition transition;

  @override
  State<_MorphDemo> createState() => _MorphDemoState();
}

class _MorphDemoState extends State<_MorphDemo> {
  bool _toggle = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () => setState(() => _toggle = !_toggle),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: const Color(0xFF2196F3),
            child: const Text('Toggle', style: TextStyle(color: Color(0xFFFFFFFF))),
          ),
        ),
        const SizedBox(height: 24),
        OiMorph(
          transition: widget.transition,
          child: _toggle
              ? _coloredBox(const Color(0xFF4CAF50), 'A', size: 80)
              : _coloredBox(const Color(0xFFF44336), 'B', size: 80),
        ),
      ],
    );
  }
}

final oiAnimatedListComponent = WidgetbookComponent(
  name: 'OiAnimatedList',
  useCases: [
    WidgetbookUseCase(
      name: 'Default',
      builder: (context) {
        return useCaseWrapper(
          const _AnimatedListDemo(),
        );
      },
    ),
  ],
);

class _AnimatedListDemo extends StatefulWidget {
  const _AnimatedListDemo();

  @override
  State<_AnimatedListDemo> createState() => _AnimatedListDemoState();
}

class _AnimatedListDemoState extends State<_AnimatedListDemo> {
  final _controller = OiAnimatedListController<String>();
  int _counter = 3;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () {
                _controller.insert(_counter - 1, 'Item $_counter');
                setState(() => _counter++);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                color: const Color(0xFF4CAF50),
                child: const Text('Add', style: TextStyle(color: Color(0xFFFFFFFF))),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                if (_counter > 1) {
                  _controller.remove(0);
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                color: const Color(0xFFF44336),
                child: const Text('Remove', style: TextStyle(color: Color(0xFFFFFFFF))),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          width: 200,
          child: OiAnimatedList<String>(
            items: const ['Item 1', 'Item 2', 'Item 3'],
            controller: _controller,
            shrinkWrap: true,
            itemBuilder: (context, item, animation, index) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Container(
                height: 36,
                color: const Color(0xFFBBDEFB),
                child: Center(child: Text(item)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
