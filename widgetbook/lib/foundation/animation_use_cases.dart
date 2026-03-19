import 'package:flutter/material.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:widgetbook/widgetbook.dart';

import 'package:obers_ui_widgetbook/helpers/knob_helpers.dart';

final animationComponent = WidgetbookComponent(
  name: 'OiAnimationConfig',
  useCases: [
    WidgetbookUseCase(
      name: 'Duration Tokens',
      builder: (context) {
        final animations = OiTheme.of(context).animations;

        return catalogWrapper(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Animation Config',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                'Reduced motion: ${animations.reducedMotion}',
                style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
              ),
              const SizedBox(height: 16),
              _durationRow('fast', animations.fast),
              _durationRow('normal', animations.normal),
              _durationRow('slow', animations.slow),
              const SizedBox(height: 32),
              const Text(
                'Tap boxes to animate',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              _AnimatedDemo(
                label: 'fast (${animations.fast.inMilliseconds}ms)',
                duration: animations.fast,
              ),
              const SizedBox(height: 12),
              _AnimatedDemo(
                label: 'normal (${animations.normal.inMilliseconds}ms)',
                duration: animations.normal,
              ),
              const SizedBox(height: 12),
              _AnimatedDemo(
                label: 'slow (${animations.slow.inMilliseconds}ms)',
                duration: animations.slow,
              ),
            ],
          ),
        );
      },
    ),
  ],
);

Widget _durationRow(String label, Duration duration) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${duration.inMilliseconds}ms',
          style: const TextStyle(fontSize: 13),
        ),
        const SizedBox(width: 12),
        Container(
          width: (duration.inMilliseconds * 0.5).clamp(4, 200),
          height: 16,
          decoration: BoxDecoration(
            color: const Color(0xFF2563EB),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    ),
  );
}

class _AnimatedDemo extends StatefulWidget {
  const _AnimatedDemo({required this.label, required this.duration});

  final String label;
  final Duration duration;

  @override
  State<_AnimatedDemo> createState() => _AnimatedDemoState();
}

class _AnimatedDemoState extends State<_AnimatedDemo> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          AnimatedContainer(
            duration: widget.duration,
            curve: Curves.easeInOut,
            width: _expanded ? 240 : 80,
            height: 40,
            decoration: BoxDecoration(
              color: _expanded
                  ? const Color(0xFF0D9488)
                  : const Color(0xFF2563EB),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text(
              _expanded ? 'Expanded' : 'Tap',
              style: const TextStyle(
                color: Color(0xFFFFFFFF),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
