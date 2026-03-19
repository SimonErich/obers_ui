import 'package:flutter/material.dart';
import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_widgetbook/helpers/knob_helpers.dart';
import 'package:widgetbook/widgetbook.dart';

final oiPageComponent = WidgetbookComponent(
  name: 'OiPage',
  useCases: [
    WidgetbookUseCase(
      name: 'Default',
      builder: (context) {
        final gap = context.knobs.double.slider(
          label: 'Gap',
          initialValue: 16,
          max: 64,
        );

        return useCaseWrapper(
          SizedBox(
            width: 300,
            height: 300,
            child: OiPage(
              breakpoint: OiBreakpoint.expanded,
              gap: OiResponsive<double>(gap),
              children: [
                Container(
                  height: 40,
                  color: const Color(0xFFBBDEFB),
                  child: const Center(child: Text('Header')),
                ),
                Container(
                  height: 80,
                  color: const Color(0xFFC8E6C9),
                  child: const Center(child: Text('Content')),
                ),
                Container(
                  height: 40,
                  color: const Color(0xFFFFCDD2),
                  child: const Center(child: Text('Footer')),
                ),
              ],
            ),
          ),
        );
      },
    ),
  ],
);

final oiSectionComponent = WidgetbookComponent(
  name: 'OiSection',
  useCases: [
    WidgetbookUseCase(
      name: 'Default',
      builder: (context) {
        final gap = context.knobs.double.slider(
          label: 'Gap',
          initialValue: 8,
          max: 32,
        );
        final semanticLabel = context.knobs.string(
          label: 'Semantic Label',
          initialValue: 'Main Section',
        );

        return useCaseWrapper(
          SizedBox(
            width: 300,
            child: OiSection(
              breakpoint: OiBreakpoint.expanded,
              gap: OiResponsive<double>(gap),
              semanticLabel: semanticLabel,
              children: [
                Container(
                  height: 30,
                  color: const Color(0xFFBBDEFB),
                  child: const Center(child: Text('Item 1')),
                ),
                Container(
                  height: 30,
                  color: const Color(0xFFC8E6C9),
                  child: const Center(child: Text('Item 2')),
                ),
                Container(
                  height: 30,
                  color: const Color(0xFFFFCDD2),
                  child: const Center(child: Text('Item 3')),
                ),
              ],
            ),
          ),
        );
      },
    ),
  ],
);

final oiMasonryComponent = WidgetbookComponent(
  name: 'OiMasonry',
  useCases: [
    WidgetbookUseCase(
      name: 'Default',
      builder: (context) {
        final columns = context.knobs.int.slider(
          label: 'Columns',
          initialValue: 3,
          min: 1,
          max: 5,
        );
        final gap = context.knobs.double.slider(
          label: 'Gap',
          initialValue: 8,
          max: 32,
        );

        final heights = [80.0, 120.0, 60.0, 100.0, 90.0, 70.0, 110.0, 50.0];

        return useCaseWrapper(
          SizedBox(
            width: 400,
            child: OiMasonry(
              breakpoint: OiBreakpoint.expanded,
              columns: OiResponsive<int>(columns),
              gap: OiResponsive<double>(gap),
              children: List.generate(
                8,
                (i) => Container(
                  height: heights[i],
                  color: const Color(
                    0xFF4CAF50,
                  ).withValues(alpha: 0.3 + (i * 0.08)),
                  child: Center(child: Text('${i + 1}')),
                ),
              ),
            ),
          ),
        );
      },
    ),
  ],
);

final oiWrapLayoutComponent = WidgetbookComponent(
  name: 'OiWrapLayout',
  useCases: [
    WidgetbookUseCase(
      name: 'Default',
      builder: (context) {
        final spacing = context.knobs.double.slider(
          label: 'Spacing',
          initialValue: 8,
          max: 32,
        );
        final runSpacing = context.knobs.double.slider(
          label: 'Run Spacing',
          initialValue: 8,
          max: 32,
        );

        return useCaseWrapper(
          SizedBox(
            width: 300,
            child: OiWrapLayout(
              breakpoint: OiBreakpoint.expanded,
              spacing: OiResponsive<double>(spacing),
              runSpacing: OiResponsive<double>(runSpacing),
              children: List.generate(
                10,
                (i) => Container(
                  width: 60 + (i % 3) * 20.0,
                  height: 32,
                  color: const Color(0xFF9C27B0).withValues(alpha: 0.3),
                  child: Center(child: Text('${i + 1}')),
                ),
              ),
            ),
          ),
        );
      },
    ),
  ],
);

final oiAspectRatioComponent = WidgetbookComponent(
  name: 'OiAspectRatio',
  useCases: [
    WidgetbookUseCase(
      name: 'Default',
      builder: (context) {
        final ratio = context.knobs.double.slider(
          label: 'Ratio',
          initialValue: 1.78,
          min: 0.5,
          max: 3,
        );

        return useCaseWrapper(
          SizedBox(
            width: 200,
            child: OiAspectRatio(
              breakpoint: OiBreakpoint.expanded,
              ratio: OiResponsive<double>(ratio),
              child: ColoredBox(
                color: const Color(0xFFFF9800).withValues(alpha: 0.3),
                child: Center(
                  child: Text('Ratio: ${ratio.toStringAsFixed(2)}'),
                ),
              ),
            ),
          ),
        );
      },
    ),
  ],
);

final oiSpacerComponent = WidgetbookComponent(
  name: 'OiSpacer',
  useCases: [
    WidgetbookUseCase(
      name: 'Fixed Size',
      builder: (context) {
        final size = context.knobs.double.slider(
          label: 'Size',
          initialValue: 24,
          max: 100,
        );

        return useCaseWrapper(
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 100,
                height: 40,
                color: const Color(0xFFBBDEFB),
                child: const Center(child: Text('Above')),
              ),
              OiSpacer(
                breakpoint: OiBreakpoint.expanded,
                size: OiResponsive<double>(size),
              ),
              Container(
                width: 100,
                height: 40,
                color: const Color(0xFFC8E6C9),
                child: const Center(child: Text('Below')),
              ),
            ],
          ),
        );
      },
    ),
    WidgetbookUseCase(
      name: 'Flex',
      builder: (context) {
        return useCaseWrapper(
          SizedBox(
            height: 200,
            child: Column(
              children: [
                Container(
                  width: 100,
                  height: 40,
                  color: const Color(0xFFBBDEFB),
                  child: const Center(child: Text('Top')),
                ),
                const OiSpacer.flex(),
                Container(
                  width: 100,
                  height: 40,
                  color: const Color(0xFFC8E6C9),
                  child: const Center(child: Text('Bottom')),
                ),
              ],
            ),
          ),
        );
      },
    ),
  ],
);
