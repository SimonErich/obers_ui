import 'package:flutter/material.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_widgetbook/helpers/knob_helpers.dart';
import 'package:widgetbook/widgetbook.dart';

final responsiveComponent = WidgetbookComponent(
  name: 'OiBreakpoint / OiResponsive',
  useCases: [
    WidgetbookUseCase(
      name: 'Breakpoint Info',
      builder: (context) {
        final scale = OiTheme.of(context).breakpoints;
        final currentBp = context.breakpoint;
        final width = context.viewportWidth;

        return catalogWrapper(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Responsive Breakpoints',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                'Current viewport: ${width.toInt()}dp',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'Active breakpoint: ${currentBp.name} (>=${currentBp.minWidth.toInt()}dp)',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'Page gutter: ${context.pageGutter.toInt()}dp',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'Content max width: ${context.contentMaxWidth == double.infinity ? "unlimited" : "${context.contentMaxWidth.toInt()}dp"}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'Height breakpoint: ${context.heightBreakpoint.name}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'Orientation: ${context.orientation.name}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'All Breakpoints',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              for (final bp in scale.values)
                _breakpointRow(bp, bp == currentBp),
              const SizedBox(height: 24),
              const Text(
                'Context Checks',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              _checkRow('isCompact', context.isCompact),
              _checkRow('isMedium', context.isMedium),
              _checkRow('isExpanded', context.isExpanded),
              _checkRow('isLarge', context.isLarge),
              _checkRow('isExtraLarge', context.isExtraLarge),
              const Divider(height: 16),
              _checkRow('isMediumOrWider', context.isMediumOrWider),
              _checkRow('isExpandedOrWider', context.isExpandedOrWider),
              _checkRow('isLargeOrWider', context.isLargeOrWider),
            ],
          ),
        );
      },
    ),
  ],
);

Widget _breakpointRow(OiBreakpoint bp, bool isActive) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? const Color(0xFF16A34A) : const Color(0xFFD1D5DB),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 100,
          child: Text(
            bp.name,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
        ),
        Text(
          '>=${bp.minWidth.toInt()}dp',
          style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
        ),
      ],
    ),
  );
}

Widget _checkRow(String label, bool value) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Row(
      children: [
        Icon(
          value ? Icons.check_circle : Icons.cancel,
          size: 16,
          color: value ? const Color(0xFF16A34A) : const Color(0xFFD1D5DB),
        ),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 13)),
      ],
    ),
  );
}
