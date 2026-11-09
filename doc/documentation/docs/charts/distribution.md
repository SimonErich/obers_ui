# Distribution & Financial Charts

These charts show how data spreads out and how financial series move over time.
Reach for them when you care about the shape of a distribution, the spread of a
sample, or the open/high/low/close of a price series.

Charts live in a separate package. Add one import to every file that uses them:

```dart
import 'package:obers_ui_charts/obers_ui_charts.dart';
```

Every chart takes a `label` for accessibility. Pass a short, human description of
what the chart shows.

| Chart | What it does |
| --- | --- |
| `OiHistogram` | Groups numbers into bins and shows how often each range occurs. |
| `OiBoxPlotChart` | Shows the five-number summary (min, Q1, median, Q3, max) per category. |
| `OiCandlestickChart` | Plots open, high, low, and close for financial time series. |
| `OiWaterfallChart` | Shows how positive and negative steps build to a running total. |
| `OiBubbleChart` | Plots points by x, y, and a size dimension. |
| `OiSparkline` | A tiny inline line for a table cell, tile, or metric. |

## OiHistogram

A histogram groups continuous numbers into equal-width bins and draws one bar per
bin. Use it to see the shape of a distribution: where values cluster and how they
spread. For a single list of numbers, `OiHistogram.fromValues` is the shortest
path. It builds the series for you.

```dart
OiHistogram.fromValues(
  label: 'Age distribution',
  values: [23, 25, 31, 34, 34, 40, 42, 45, 51, 52, 58, 63],
  binCount: 6,
)
```

For multiple series, or to map values out of your own objects, pass `series`
directly with `OiHistogramSeries`:

```dart
OiHistogram<Person>(
  label: 'Age distribution',
  series: [
    OiHistogramSeries<Person>(
      id: 'ages',
      label: 'Ages',
      data: people,
      valueMapper: (p) => p.age,
      binCount: 6,
    ),
  ],
)
```

`OiHistogram.fromValues` parameters:

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `label` | `String` | **required** | Accessibility label and default series label. |
| `values` | `List<double>` | **required** | The numbers to bin. |
| `binCount` | `int?` | `null` | Number of bins. When null, chosen with the Sturges formula. |
| `binWidth` | `double?` | `null` | Fixed bin width. Overrides `binCount`. |
| `showGrid` | `bool` | `true` | Draw background grid lines. |
| `cumulative` | `bool` | `false` | Overlay a cumulative frequency line. |
| `normalized` | `bool` | `false` | Show relative frequency (0 to 1) instead of raw counts. |
| `semanticLabel` | `String?` | `null` | Overrides the auto-generated screen-reader label. |

Each `OiHistogramSeries` takes `id`, `label`, `data`, and a `valueMapper`, plus
optional `binCount`, `binWidth`, `binRange`, and `color`.

## OiBoxPlotChart

A box plot shows the spread of a sample per category: the box spans Q1 to Q3, a
line marks the median, and the whiskers reach the extremes. Use it to compare
distributions side by side. The simplest setup gives it raw measurements through
`valuesMapper` and lets the chart compute the statistics.

```dart
OiBoxPlotChart<Department>(
  label: 'Salary by department',
  series: [
    OiBoxPlotSeries<Department>(
      id: 'salaries',
      label: 'Salaries',
      data: departments,
      categoryMapper: (d) => d.name,
      valuesMapper: (d) => d.salaries,
    ),
  ],
  showMean: true,
  whiskerMode: OiWhiskerMode.iqr1_5,
)
```

If your model already stores the summary, use the pre-computed mappers
(`minMapper`, `q1Mapper`, `medianMapper`, `q3Mapper`, `maxMapper`) instead of
`valuesMapper`. You must supply one API or the other.

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `label` | `String` | **required** | Accessibility label. |
| `series` | `List<OiBoxPlotSeries<T>>` | **required** | The boxes to draw. |
| `showMean` | `bool` | `false` | Draw a dot at the mean inside each box. |
| `showNotch` | `bool` | `false` | Draw a confidence-interval notch at the median. |
| `whiskerMode` | `OiWhiskerMode` | `minMax` | `minMax`, `iqr1_5`, or `percentile5_95`. |
| `horizontal` | `bool` | `false` | Run categories along the y-axis instead. |
| `showGrid` | `bool` | `true` | Draw background grid lines. |
| `yAxis` | `OiChartAxis<num>?` | `null` | Value-axis configuration. |
| `semanticLabel` | `String?` | `null` | Overrides the auto-generated screen-reader label. |

`OiWhiskerMode.iqr1_5` and `OiWhiskerMode.percentile5_95` also plot values past
the whiskers as individual outlier dots.

## OiCandlestickChart

A candlestick chart plots four prices per period: open, high, low, and close.
Each candle draws a wick from low to high and a body from open to close. Bullish
candles (close at or above open) use the theme's positive color, bearish candles
use the negative color. Map the four price fields out of your own records.

```dart
OiCandlestickChart<Ohlc>(
  label: 'ACME daily price',
  series: [
    OiCandlestickSeries<Ohlc>(
      id: 'acme',
      label: 'ACME',
      data: candles,
      xMapper: (c) => c.date.millisecondsSinceEpoch.toDouble(),
      openMapper: (c) => c.open,
      highMapper: (c) => c.high,
      lowMapper: (c) => c.low,
      closeMapper: (c) => c.close,
    ),
  ],
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `label` | `String` | **required** | Accessibility label. |
| `series` | `List<OiCandlestickSeries<T>>` | **required** | The candle series to draw. |
| `xAxis` | `OiChartAxis<dynamic>?` | `null` | Time or numeric x-axis configuration. |
| `yAxis` | `OiChartAxis<num>?` | `null` | Price-axis configuration. |
| `showGrid` | `bool` | `true` | Draw background grid lines. |
| `showLegend` | `bool` | `true` | Show a legend when there are multiple series. |
| `onCandleTap` | `void Function(int, int)?` | `null` | Called with the series and candle index on tap. |
| `theme` | `OiCandlestickChartTheme?` | `null` | Overrides for grid, axis, bull, and bear colors. |
| `semanticLabel` | `String?` | `null` | Overrides the auto-generated screen-reader label. |

Each `OiCandlestickSeries` requires `id`, `label`, `data`, `xMapper`, and the
four price mappers. It also takes optional `bullColor` and `bearColor` overrides.

## OiWaterfallChart

A waterfall chart shows how a starting value grows and shrinks through a sequence
of steps. Each bar floats where the previous one ended, so gains and losses stack
into the running total. Mark summary bars with `isTotal` to reset them to the
baseline.

```dart
OiWaterfallChart<RevenueItem>(
  label: 'Revenue breakdown',
  series: [
    OiWaterfallSeries<RevenueItem>(
      id: 'breakdown',
      label: 'Revenue',
      data: items,
      categoryMapper: (item) => item.name,
      valueMapper: (item) => item.amount,
      isTotal: (item) => item.isTotal,
    ),
  ],
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `label` | `String` | **required** | Accessibility label. |
| `series` | `List<OiWaterfallSeries<T>>` | **required** | The steps to draw. Only the first visible series renders. |
| `showConnectors` | `bool` | `true` | Draw lines between consecutive bar tops. |
| `positiveColor` | `Color?` | `null` | Color for increases. Defaults to the theme positive color. |
| `negativeColor` | `Color?` | `null` | Color for decreases. Defaults to the theme negative color. |
| `totalColor` | `Color?` | `null` | Color for total bars. Defaults to the theme neutral color. |
| `showGrid` | `bool` | `true` | Draw background grid lines. |
| `yAxis` | `OiChartAxis<num>?` | `null` | Value-axis configuration. |
| `semanticLabel` | `String?` | `null` | Overrides the auto-generated screen-reader label. |

Each `OiWaterfallSeries` requires `id`, `label`, `data`, `categoryMapper`, and
`valueMapper`. Positive values step up, negative values step down.

## OiBubbleChart

A bubble chart plots each point by three values: x position, y position, and a
size that maps to the bubble radius. Use it when a scatter plot needs a third
dimension, like revenue by price and market size. Pass an `OiBubbleChartData`
with pre-mapped `OiBubblePoint` values for the simplest setup.

```dart
OiBubbleChart(
  label: 'Products by price and volume',
  data: OiBubbleChartData(
    series: [
      OiBubbleSeries(
        name: 'Products',
        points: [
          OiBubblePoint(x: 12, y: 4, size: 120, label: 'Alpha'),
          OiBubblePoint(x: 28, y: 9, size: 340, label: 'Beta'),
          OiBubblePoint(x: 45, y: 6, size: 80, label: 'Gamma'),
        ],
      ),
    ],
    sizeConfig: OiBubbleSizeConfig(
      minRadius: 6,
      maxRadius: 28,
      sizeLabel: 'Units sold',
    ),
  ),
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `data` | `OiBubbleChartData` | **required** | Series and optional size configuration. |
| `label` | `String?` | `null` | Accessibility label. When null, one is generated from the data. |
| `semanticLabel` | `String?` | `null` | Alias for `label`. |
| `theme` | `OiBubbleChartTheme?` | `null` | Color and opacity overrides. |
| `interactionMode` | `OiChartInteractionMode?` | `null` | Force touch or pointer interaction. |
| `compact` | `bool?` | `null` | Force compact layout. When null, based on width. |

!!! note
    `OiBubbleChart` takes `label` or `semanticLabel` rather than a required
    `label`. Always pass one so screen readers describe the chart.

Each `OiBubblePoint` needs `x`, `y`, and `size`. Add a `label` per point so the
chart can narrate the focused bubble. `OiBubbleSizeConfig` maps the smallest and
largest `size` values to `minRadius` and `maxRadius`.

## OiSparkline

A sparkline is a small line with no axes or labels. It fits inside a table cell,
list tile, or metric card to show a trend at a glance. Give it a flat list of
numbers.

```dart
OiSparkline(
  label: 'Weekly signups trend',
  values: [4, 6, 5, 8, 7, 11, 9, 14],
  showLastPoint: true,
)
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `label` | `String` | **required** | Accessibility label. |
| `values` | `List<double>` | **required** | The numbers to plot. |
| `color` | `Color?` | `null` | Line color. Defaults to the theme primary color. |
| `fill` | `bool` | `false` | Fill the area below the line. |
| `fillOpacity` | `double` | `0.15` | Opacity of the area fill when `fill` is on. |
| `strokeWidth` | `double` | `1.5` | Line thickness. |
| `showLastPoint` | `bool` | `false` | Draw a dot at the last value. |
| `showMinMax` | `bool` | `false` | Draw dots at the lowest and highest values. |
| `height` | `double` | `32` | Height in logical pixels. |
| `width` | `double?` | `null` | Width. When null, fills the available width. |

## Related

- [Charts overview](index.md)
- [Cartesian charts](cartesian.md)
- [Part-to-whole charts](part-to-whole.md)
- [Specialized charts](specialized.md)
