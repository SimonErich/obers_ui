# Data Scales

A scale maps your data to the screen. You give it an input domain (numbers,
dates, or category names) and an output range (pixel positions). It hands back
the pixel for any value, and often the value for any pixel. These classes are
the building blocks for custom charts. ObersUI uses them internally, and you use
them directly when you paint your own visualizations.

Every scale lives under `foundation/scales`. They are plain immutable data
classes. They do not need a `BuildContext` and they do not draw anything. You do
the drawing, usually inside a `CustomPainter`.

| Class | Domain | Use it for |
| --- | --- | --- |
| `OiLinearScale` | Numbers | Value axes, bar heights, most continuous data. |
| `OiLogarithmicScale` | Positive numbers | Data that spans many orders of magnitude. |
| `OiTimeScale` | `DateTime` | Time axes on line and area charts. |
| `OiBandScale` | Category names | Bar positions, one band per category. |
| `OiPointScale` | Category names | Line and scatter x-positions, one point per category. |
| `OiCategoryScale` | Category names | Category centers in equal-width slots. |
| `OiQuantileScale` | Numbers | Bucketing a dataset into equal-count groups. |
| `OiThresholdScale` | Numbers | Bucketing by explicit cut points. |

## The shared idea

Two things describe every scale. The domain is the range of your data. The range
is the pixel span you draw into. Screen y-axes usually run top to bottom, so you
often pass a larger `rangeMin` than `rangeMax` to flip the direction. Every scale
exposes `toPixel(...)` to go from data to pixels. The continuous and ordinal
scales also expose `fromPixel(...)` to go back, which is how you turn a tap
position into a data value.

Two shared helpers live in `oi_chart_scale.dart`:

- `OiScaleType` is an enum that names each mapping strategy. Every scale returns
  its own value from a `type` getter, for example `OiScaleType.linear`.
- `OiScaleTick<T>` is one tick mark on an axis. It holds a `value` and an
  optional `label`. Every scale builds these with `buildTicks(...)`.

!!! note
    There is no `OiChartScale` base class. The scales do not share a common
    supertype. They share the same shape (`domain`, `range`, `toPixel`,
    `buildTicks`), but each is its own class. Pick the one that matches your data.

## OiLinearScale

The scale you reach for first. It maps a numeric domain to a pixel range in a
straight line. Use it for bar heights, value axes, and any continuous number.

```dart
// Map values 0..100 to a 200px tall column, top at y=0.
const scale = OiLinearScale(
  domainMin: 0,
  domainMax: 100,
  rangeMin: 200, // bottom of the column
  rangeMax: 0,   // top of the column
);

final y = scale.toPixel(75); // pixel for the value 75
```

If you do not know the extent up front, build it from your data. `fromData`
computes the domain for you and, by default, rounds it out to nice round numbers.

```dart
final scale = OiLinearScale.fromData(
  values: [12, 48, 33, 91, 7],
  rangeMin: 200,
  rangeMax: 0,
);

final ticks = scale.buildTicks(count: 5); // five evenly spaced ticks
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `domainMin` | `double` | **required** | Smallest data value. |
| `domainMax` | `double` | **required** | Largest data value. |
| `rangeMin` | `double` | **required** | Pixel for `domainMin`. |
| `rangeMax` | `double` | **required** | Pixel for `domainMax`. |
| `clamp` | `bool` | `false` | Keep output inside the range for out-of-domain values. |

The `fromData` factory adds `values` (required), `nice` (default `true`), and
`clamp`. An empty `values` list falls back to a `[0, 1]` domain. A single value
expands by ten percent so the chart still has extent.

## OiLogarithmicScale

A continuous scale for data that spans many orders of magnitude, like network
latency or file sizes. Small values get more room than a linear scale would give
them. The domain must be positive.

```dart
const scale = OiLogarithmicScale(
  domainMin: 1,
  domainMax: 100000,
  rangeMin: 0,
  rangeMax: 300,
);

final x = scale.toPixel(1000);
final ticks = scale.buildTicks(); // ticks at powers of the base: 1, 10, 100, ...
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `domainMin` | `double` | **required** | Smallest value. Must be positive. |
| `domainMax` | `double` | **required** | Largest value. |
| `rangeMin` | `double` | **required** | Pixel for `domainMin`. |
| `rangeMax` | `double` | **required** | Pixel for `domainMax`. |
| `base` | `double` | `10` | The logarithm base. |
| `clamp` | `bool` | `false` | Keep output inside the range. |

Non-positive values map to `rangeMin`. `fromData` skips them when it computes the
domain, and falls back to `[1, 10]` when nothing positive is left.

## OiTimeScale

A continuous scale for `DateTime` values. Use it for the time axis of a line or
area chart. It works in milliseconds internally, so it handles any resolution
from seconds to years.

```dart
final scale = OiTimeScale.fromData(
  values: dataPoints.map((p) => p.timestamp).toList(),
  rangeMin: 0,
  rangeMax: 600, // chart width in pixels
);

final x = scale.toPixel(DateTime(2026, 7, 1));
final when = scale.fromPixel(tapX); // DateTime under a tap
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `domainMin` | `DateTime` | **required** | Earliest date. |
| `domainMax` | `DateTime` | **required** | Latest date. |
| `rangeMin` | `double` | **required** | Pixel for `domainMin`. |
| `rangeMax` | `double` | **required** | Pixel for `domainMax`. |
| `clamp` | `bool` | `false` | Keep output inside the range. |

An empty `fromData` list falls back to a domain of yesterday to tomorrow. A
single date expands by one day on each side.

## OiBandScale

An ordinal scale for bar charts. It splits the range into one band per category
and leaves gaps between them. `toPixel` returns the left edge of a band.
`bandwidth` gives you the bar width to draw.

```dart
const scale = OiBandScale(
  domain: ['Q1', 'Q2', 'Q3', 'Q4'],
  rangeMin: 0,
  rangeMax: 400,
);

final left = scale.toPixel('Q2');   // left edge of the Q2 bar
final width = scale.bandwidth;      // width of every bar
final center = scale.bandCenter('Q2'); // center, for a label
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `domain` | `List<String>` | **required** | Ordered category labels. |
| `rangeMin` | `double` | **required** | Start pixel of the range. |
| `rangeMax` | `double` | **required** | End pixel of the range. |
| `paddingInner` | `double` | `0.1` | Gap between bands, as a fraction of the step. |
| `paddingOuter` | `double` | `0.1` | Margin before the first and after the last band. |

Use `bandAt(index)` to get an `OiBandInfo` with the `start` and `width` of a
band by position. Unknown categories map to `rangeMin`.

## OiPointScale

An ordinal scale for line and scatter charts. Like a band scale, but each
category is a single point with no width. Use it to place the x-position of each
data point.

```dart
const scale = OiPointScale(
  domain: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'],
  rangeMin: 0,
  rangeMax: 500,
);

final x = scale.toPixel('Wed'); // x-position of the Wednesday point
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `domain` | `List<String>` | **required** | Ordered category labels. |
| `rangeMin` | `double` | **required** | Start pixel of the range. |
| `rangeMax` | `double` | **required** | End pixel of the range. |
| `padding` | `double` | `0.5` | Outer margin as a fraction of the step. |

A single-category domain places the point at the range center. `fromPixel`
returns the nearest category, which is handy for snapping a hover to a point.

## OiCategoryScale

An ordinal scale that maps each category to the center of an equal-width slot. It
has no padding, so slots sit edge to edge. Reach for it when you want simple,
evenly divided categories and do not need band gaps.

```dart
const scale = OiCategoryScale(
  domain: ['Low', 'Medium', 'High'],
  rangeMin: 0,
  rangeMax: 300,
);

final x = scale.toPixel('Medium'); // center of the middle slot
final width = scale.step;          // width of each slot
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `domain` | `List<String>` | **required** | Ordered category labels. |
| `rangeMin` | `double` | **required** | Start pixel of the range. |
| `rangeMax` | `double` | **required** | End pixel of the range. |

## OiQuantileScale

A statistical scale. It sorts your values and splits them into buckets that each
hold the same number of points. Every value maps to the center pixel of its
bucket. Use it for choropleth maps and heat maps where you want even group sizes,
not even value ranges.

```dart
final scale = OiQuantileScale(
  values: [3, 8, 8, 12, 20, 45, 60, 90],
  rangeMin: 0,
  rangeMax: 200,
  quantileCount: 4, // quartiles
);

final pixel = scale.toPixel(20);
final cuts = scale.thresholds; // the values that separate the buckets
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `values` | `List<num>` | **required** | The dataset. Sorted internally. |
| `rangeMin` | `double` | **required** | Start pixel of the range. |
| `rangeMax` | `double` | **required** | End pixel of the range. |
| `quantileCount` | `int` | `4` | Number of equal-count buckets. |
| `clamp` | `bool` | `false` | Keep output inside the range. |

## OiThresholdScale

A bucketing scale where you set the cut points yourself. Pass ascending
thresholds and it draws one segment for each gap between them, plus one below the
first and one above the last. Use it when the boundaries carry meaning, like
grading bands or alert levels.

```dart
const scale = OiThresholdScale(
  thresholds: [50, 80, 95], // four segments: <50, 50-80, 80-95, >=95
  rangeMin: 0,
  rangeMax: 200,
);

final pixel = scale.toPixel(72); // center of the 50-80 segment
final segments = scale.segmentCount; // 4
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `thresholds` | `List<double>` | **required** | Cut points, in ascending order. |
| `rangeMin` | `double` | **required** | Start pixel of the range. |
| `rangeMax` | `double` | **required** | End pixel of the range. |
| `clamp` | `bool` | `false` | Keep output inside the range. |

The segment count is always `thresholds.length + 1`.

## Chart colors

Scales handle position. Two theme classes handle color.

### OiChartPalette

An ordered set of colors for a chart. `categorical` gives one color per series,
cycling with the index operator when you have more series than colors. Four
semantic colors cover meaning: `positive`, `negative`, `neutral`, and
`highlight`. Two optional gradients, `sequential` and `diverging`, map continuous
data such as heat maps.

Build one from the active color scheme so the palette matches the rest of your
app.

```dart
final palette = OiChartPalette.colors(context.colors);

final firstSeries = palette[0]; // categorical color, cycles past the end
final gain = palette.positive;  // semantic color for an upward value
```

For a single-series chart, `OiChartPalette.atom` takes one color and reuses it
for the semantic slots.

```dart
final palette = OiChartPalette.atom(color: context.colors.primary.base);
```

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `categorical` | `List<Color>` | **required** | One color per series. Cycles with `[]`. |
| `positive` | `Color` | **required** | Upward or gain color. |
| `negative` | `Color` | **required** | Downward or loss color. |
| `neutral` | `Color` | **required** | Baseline color. |
| `highlight` | `Color` | **required** | Color for a called-out point. |
| `sequential` | `List<Color>?` | `null` | Gradient for continuous data. |
| `diverging` | `List<Color>?` | `null` | Gradient with a meaningful midpoint. |

### OiChartThemeData

The full set of chart visual tokens in one object. It holds the `palette` plus
sub-themes for `axis`, `grid`, `legend`, `tooltip`, `crosshair`, `annotation`,
`selection`, `state`, `motion`, and `density`. Every field is optional, so you
set only what you want to change. Read the resolved theme from
`context.components.chart`.

```dart
const theme = OiChartThemeData(
  grid: OiChartGridTheme(dashPattern: [4, 2]),
);
```

**Theme:** `context.components.chart` → `OiChartThemeData`

!!! tip
    Pull axis and grid colors from the theme, not from hardcoded values. A chart
    that reads `context.components.chart` and `context.colors` stays in step with
    light and dark modes for free.

## Related

- [Extending Themes](../theming/extending-themes.md) for building and applying theme data.
- [Custom Modules](custom-modules.md) for wiring your own widgets into ObersUI.
- [Performance](performance.md) for painting large datasets efficiently.
