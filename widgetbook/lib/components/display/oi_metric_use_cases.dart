import 'package:obers_ui/obers_ui.dart';
import 'package:obers_ui_widgetbook/helpers/knob_helpers.dart';
import 'package:widgetbook/widgetbook.dart';

final oiMetricComponent = WidgetbookComponent(
  name: 'OiMetric',
  useCases: [
    WidgetbookUseCase(
      name: 'Playground',
      builder: (context) {
        final label = context.knobs.string(
          label: 'Label',
          initialValue: 'Total Revenue',
        );
        final value = context.knobs.string(
          label: 'Value',
          initialValue: r'$12,340',
        );
        final trend = context.knobs.enumKnob<OiMetricTrend>(
          label: 'Trend',
          values: OiMetricTrend.values,
          initialValue: OiMetricTrend.up,
        );
        final trendPercent = context.knobs.double.slider(
          label: 'Trend Percent',
          initialValue: 12.5,
          max: 100,
        );

        return useCaseWrapper(
          OiMetric(
            label: label,
            value: value,
            trend: trend,
            trendPercent: trendPercent,
          ),
        );
      },
    ),
  ],
);
