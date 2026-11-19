# obers_ui_charts

Chart foundation and visualization composites for the [obers_ui](../../README.md) design system. Charts read their colours, typography and spacing from the `obers_ui` theme, so they follow the app's light and dark themes without extra setup.

## Installation

The package lives in the `obers_ui` repository and depends on `obers_ui` by path:

```yaml
dependencies:
  obers_ui:
    git:
      url: https://github.com/simonerich/obers_ui.git
  obers_ui_charts:
    git:
      url: https://github.com/simonerich/obers_ui.git
      path: packages/obers_ui_charts
```

## Usage

Charts need an `OiApp` (or another source of the `obers_ui` theme) above them.

```dart
import 'package:flutter/widgets.dart';
import 'package:obers_ui_charts/obers_ui_charts.dart';

class MarketShareChart extends StatelessWidget {
  const MarketShareChart({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 240,
      child: OiPieChart(
        label: 'Market share',
        segments: [
          OiPieSegment(label: 'Chrome', value: 65),
          OiPieSegment(label: 'Safari', value: 19),
          OiPieSegment(label: 'Firefox', value: 10),
          OiPieSegment(label: 'Other', value: 6),
        ],
      ),
    );
  }
}
```

## What is in the package

| Area | Examples |
| ---- | -------- |
| **Cartesian charts** | `OiLineChart`, `OiBarChart`, `OiAreaChart`, `OiScatterPlot`, `OiBubbleChart`, `OiComboChart`, `OiCandlestickChart`, `OiWaterfallChart` |
| **Part-to-whole and polar** | `OiPieChart`, `OiDonutChart`, `OiRadarChart`, `OiPolarAreaChart`, `OiRadialBarChart`, `OiFunnelChart` |
| **Hierarchy and flow** | `OiTreemap`, `OiSunburstChart`, `OiSankey` |
| **Compact indicators** | `OiSparkline`, `OiGauge`, `OiHeatmap`, `OiCalendarHeatmap` |
| **Maps** | `OiVectorMap`, `OiTileMap` |
| **Modules** | `OiAnalyticsDashboard`, `OiChartExplorer`, `OiKpiBoard` |

Shared pieces such as `OiChartLegend`, the chart behaviors (zoom and pan, selection, series toggle) and the scales are exported from the same barrel file.

## Development

```bash
flutter pub get
dart analyze --fatal-infos
flutter test
```
