import 'package:flutter/material.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:widgetbook/widgetbook.dart';

import '../../helpers/knob_helpers.dart';

final oiDraggableComponent = WidgetbookComponent(
  name: 'OiDraggable',
  useCases: [
    WidgetbookUseCase(
      name: 'Default',
      builder: (context) {
        return useCaseWrapper(
          const _DragDropDemo(),
        );
      },
    ),
  ],
);

class _DragDropDemo extends StatefulWidget {
  const _DragDropDemo();

  @override
  State<_DragDropDemo> createState() => _DragDropDemoState();
}

class _DragDropDemoState extends State<_DragDropDemo> {
  String _dropResult = 'Drop here';

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        OiDraggable<String>(
          data: 'Hello from drag!',
          child: Container(
            width: 120,
            height: 50,
            color: const Color(0xFF2196F3),
            child: const Center(
              child: Text('Drag me', style: TextStyle(color: Color(0xFFFFFFFF))),
            ),
          ),
        ),
        const SizedBox(height: 32),
        OiDropZone<String>(
          onAccept: (data) => setState(() => _dropResult = data),
          builder: (context, state) {
            final color = switch (state) {
              OiDropState.idle => const Color(0xFFE0E0E0),
              OiDropState.hovering => const Color(0xFFC8E6C9),
              OiDropState.accepted => const Color(0xFFA5D6A7),
              OiDropState.rejected => const Color(0xFFFFCDD2),
            };
            return Container(
              width: 150,
              height: 80,
              color: color,
              child: Center(child: Text(_dropResult)),
            );
          },
        ),
      ],
    );
  }
}

final oiDropZoneComponent = WidgetbookComponent(
  name: 'OiDropZone',
  useCases: [
    WidgetbookUseCase(
      name: 'Default',
      builder: (context) {
        return useCaseWrapper(
          OiDropZone<String>(
            onAccept: (_) {},
            builder: (context, state) {
              return Container(
                width: 150,
                height: 80,
                color: const Color(0xFFE0E0E0),
                child: Center(child: Text('State: ${state.name}')),
              );
            },
          ),
        );
      },
    ),
  ],
);

final oiReorderableComponent = WidgetbookComponent(
  name: 'OiReorderable',
  useCases: [
    WidgetbookUseCase(
      name: 'Default',
      builder: (context) {
        return const SizedBox(
          height: 300,
          width: 300,
          child: _ReorderableDemo(),
        );
      },
    ),
  ],
);

class _ReorderableDemo extends StatefulWidget {
  const _ReorderableDemo();

  @override
  State<_ReorderableDemo> createState() => _ReorderableDemoState();
}

class _ReorderableDemoState extends State<_ReorderableDemo> {
  final _items = List.generate(5, (i) => 'Reorder item ${i + 1}');

  @override
  Widget build(BuildContext context) {
    return OiReorderable(
      onReorder: (oldIndex, newIndex) {
        setState(() {
          if (newIndex > oldIndex) newIndex--;
          final item = _items.removeAt(oldIndex);
          _items.insert(newIndex, item);
        });
      },
      children: _items
          .map(
            (item) => Container(
              key: ValueKey(item),
              height: 48,
              margin: const EdgeInsets.symmetric(vertical: 2),
              color: const Color(0xFFBBDEFB),
              child: Center(child: Text(item)),
            ),
          )
          .toList(),
    );
  }
}

final oiDragGhostComponent = WidgetbookComponent(
  name: 'OiDragGhost',
  useCases: [
    WidgetbookUseCase(
      name: 'Default',
      builder: (context) {
        final opacity = context.knobs.double.slider(
          label: 'Opacity',
          initialValue: 0.85,
          min: 0.1,
          max: 1,
        );

        return useCaseWrapper(
          OiDragGhost(
            opacity: opacity,
            child: Container(
              width: 100,
              height: 60,
              color: const Color(0xFF2196F3),
              child: const Center(
                child: Text('Ghost', style: TextStyle(color: Color(0xFFFFFFFF))),
              ),
            ),
          ),
        );
      },
    ),
  ],
);
