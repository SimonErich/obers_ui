import 'package:flutter/material.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_widgetbook/helpers/knob_helpers.dart';
import 'package:widgetbook/widgetbook.dart';

final oiDoubleTapComponent = WidgetbookComponent(
  name: 'OiDoubleTap',
  useCases: [
    WidgetbookUseCase(
      name: 'Default',
      builder: (context) {
        final enabled = context.knobs.boolean(
          label: 'Enabled',
          initialValue: true,
        );

        return useCaseWrapper(_DoubleTapDemo(enabled: enabled));
      },
    ),
  ],
);

class _DoubleTapDemo extends StatefulWidget {
  const _DoubleTapDemo({required this.enabled});
  final bool enabled;

  @override
  State<_DoubleTapDemo> createState() => _DoubleTapDemoState();
}

class _DoubleTapDemoState extends State<_DoubleTapDemo> {
  String _lastAction = 'None';

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        OiDoubleTap(
          enabled: widget.enabled,
          onDoubleTap: () => setState(() => _lastAction = 'Double tap'),
          onTap: () => setState(() => _lastAction = 'Single tap'),
          child: Container(
            width: 150,
            height: 80,
            color: const Color(0xFF2196F3),
            child: const Center(
              child: Text(
                'Tap / Double tap',
                style: TextStyle(color: Color(0xFFFFFFFF)),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text('Last action: $_lastAction'),
      ],
    );
  }
}

final oiLongPressMenuComponent = WidgetbookComponent(
  name: 'OiLongPressMenu',
  useCases: [
    WidgetbookUseCase(
      name: 'Default',
      builder: (context) {
        return useCaseWrapper(const _LongPressMenuDemo());
      },
    ),
  ],
);

class _LongPressMenuDemo extends StatefulWidget {
  const _LongPressMenuDemo();

  @override
  State<_LongPressMenuDemo> createState() => _LongPressMenuDemoState();
}

class _LongPressMenuDemoState extends State<_LongPressMenuDemo> {
  String _lastAction = 'None';

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        OiLongPressMenu(
          items: [
            OiLongPressMenuItem(
              label: 'Copy',
              onTap: () => setState(() => _lastAction = 'Copy'),
            ),
            OiLongPressMenuItem(
              label: 'Share',
              onTap: () => setState(() => _lastAction = 'Share'),
            ),
            OiLongPressMenuItem(
              label: 'Delete',
              onTap: () => setState(() => _lastAction = 'Delete'),
            ),
          ],
          child: Container(
            width: 150,
            height: 80,
            color: const Color(0xFF9C27B0),
            child: const Center(
              child: Text(
                'Long press me',
                style: TextStyle(color: Color(0xFFFFFFFF)),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text('Last action: $_lastAction'),
      ],
    );
  }
}

final oiSwipeableComponent = WidgetbookComponent(
  name: 'OiSwipeable',
  useCases: [
    WidgetbookUseCase(
      name: 'Default',
      builder: (context) {
        final dismissible = context.knobs.boolean(label: 'Dismissible');

        return useCaseWrapper(
          SizedBox(
            width: 300,
            child: OiSwipeable(
              dismissible: dismissible,
              leadingActions: [
                OiSwipeAction(
                  label: 'Archive',
                  color: const Color(0xFF4CAF50),
                  onTap: () {},
                ),
              ],
              trailingActions: [
                OiSwipeAction(
                  label: 'Delete',
                  color: const Color(0xFFF44336),
                  onTap: () {},
                ),
              ],
              child: Container(
                height: 60,
                color: const Color(0xFFE3F2FD),
                child: const Center(child: Text('Swipe left or right')),
              ),
            ),
          ),
        );
      },
    ),
  ],
);

final oiPinchZoomComponent = WidgetbookComponent(
  name: 'OiPinchZoom',
  useCases: [
    WidgetbookUseCase(
      name: 'Default',
      builder: (context) {
        final minScale = context.knobs.double.slider(
          label: 'Min Scale',
          initialValue: 0.5,
          min: 0.1,
          max: 1,
        );
        final maxScale = context.knobs.double.slider(
          label: 'Max Scale',
          initialValue: 4,
          min: 1,
          max: 10,
        );
        final panEnabled = context.knobs.boolean(
          label: 'Pan Enabled',
          initialValue: true,
        );

        return useCaseWrapper(
          SizedBox(
            width: 200,
            height: 200,
            child: OiPinchZoom(
              minScale: minScale,
              maxScale: maxScale,
              panEnabled: panEnabled,
              child: const ColoredBox(
                color: Color(0xFFFF9800),
                child: Center(
                  child: Text(
                    'Pinch to zoom',
                    style: TextStyle(color: Color(0xFFFFFFFF)),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    ),
  ],
);
