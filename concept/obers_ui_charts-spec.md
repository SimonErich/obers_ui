<goal>
Build the shared chart foundation substrate for `packages/obers_ui_charts` — the core
infrastructure layer that every chart type (line, bar, pie, heatmap, sankey, etc.) will
build upon. This package provides: theme integration, scale system, viewport geometry,
composable behavior objects, accessibility contracts, persistence, chart synchronization,
streaming data support, and typed data/series contracts.

Additionally, migrate all existing visualization composites from the main obers_ui package
(OiRadarChart, OiHeatmap, OiBarChart, OiGauge, OiSankey, OiFunnelChart, OiTreemap,
OiBubbleChart, OiLineChart) into this package so charts live in one cohesive subsystem.

**Who benefits:** Developers using obers_ui who need data visualization. The foundation
enables future chart specs to focus purely on rendering and interaction logic, not
reinventing infrastructure. The migration consolidates all chart code into one package
with a shared engine.
</goal>

<background>
**Tech stack:** Flutter >=3.41.0, Dart >=3.11.0
**Parent package:** obers_ui (zero Material dependency, 4-tier architecture, Oi prefix convention)
**Package location:** `packages/obers_ui_charts`
**Dependency:** obers_ui_charts depends on obers_ui (reuses OiSurface, OiLabel, OiOverlays, OiSettingsMixin, theme context extensions, persistence drivers)
**Linting:** very_good_analysis ^7.0.0, require_trailing_commas, no lines_longer_than_80_chars rule

**Key conventions from obers_ui (must be followed exactly):**
- All public classes use `Oi` prefix
- All colors from theme (`context.colors`), never hardcoded
- All text via `OiLabel`, never raw `Text()`
- All layouts via `OiRow`/`OiColumn`/`OiGrid`, never raw `Row`/`Column`
- Required `label` or `semanticLabel` on every interactive widget
- Factory constructors for variants
- Props read like English (no abbreviations: `series` not `ds`, `label` not `lbl`)
- Callbacks are verbs (`onPointTap`, `onSeriesVisibilityChange`)

**Files to examine for patterns:**
- @lib/src/foundation/theme/oi_theme_data.dart — theme structure
- @lib/src/foundation/theme/component_themes/ — component theme registration
- @lib/src/foundation/persistence/oi_settings_mixin.dart — persistence pattern
- @lib/src/foundation/persistence/oi_settings_driver.dart — driver contract
- @lib/src/foundation/oi_responsive.dart — responsive breakpoints
- @lib/src/composites/visualization/oi_bar_chart/ — complex chart file structure
- @lib/src/composites/visualization/oi_radar_chart.dart — simple chart pattern
- @lib/obers_ui.dart — barrel file pattern
- @analysis_options.yaml — linting rules
- @test/helpers/pump_app.dart — test helper pattern
</background>

<requirements>

## Package Setup

1. Create `packages/obers_ui_charts/pubspec.yaml` with:
   - name: `obers_ui_charts`
   - description matching obers_ui style
   - same SDK constraints (sdk >=3.11.0, flutter >=3.41.0)
   - dependency on `obers_ui` via path (`../..`)
   - dev_dependencies: flutter_test, golden_toolkit, mocktail, very_good_analysis
   - publish_to: 'none'

2. Create `packages/obers_ui_charts/analysis_options.yaml` matching obers_ui's rules (extend very_good_analysis, same custom rules).

3. Create barrel file `packages/obers_ui_charts/lib/obers_ui_charts.dart` following obers_ui's sectioned export pattern with comment headers.

4. Internal package structure must mirror obers_ui's tier hierarchy:
   ```
   lib/
     obers_ui_charts.dart           ← barrel export
     src/
       foundation/                  ← Tier 0: chart-specific foundation
       primitives/                  ← Tier 1: low-level painters/canvas
       components/                  ← Tier 2: reusable chart UI elements
       composites/                  ← Tier 3: family base widgets + chart widgets
       models/                      ← data classes, settings structures
       utils/                       ← chart-specific helpers
   ```

## Foundation Layer (Tier 0)

### Theme System

5. `OiChartThemeData` — immutable theme container for all chart visual tokens:
   - `palette` (OiChartPalette): categorical colors list, positive/negative/neutral/highlight colors, sequential/diverging gradients
   - `axis` (OiChartAxisTheme): label text style, title text style, line color/width, tick color/width/length
   - `grid` (OiChartGridTheme): line color, line width, dash pattern, major/minor distinction
   - `legend` (OiChartLegendTheme): text style, marker size/shape, spacing, active/inactive opacity
   - `tooltip` (OiChartTooltipTheme): surface decoration, text style, padding, max width
   - `crosshair` (OiChartCrosshairTheme): line color, line width, dash pattern, label style
   - `annotation` (OiChartAnnotationTheme): line/fill/label defaults
   - `selection` (OiChartSelectionTheme): halo color/radius, selected/unselected opacity
   - `motion` (OiChartMotionTheme): default duration, curve, enter/update/exit animation configs
   - `density` (OiChartDensityTheme): compact/standard/detailed complexity thresholds
   - All nullable fields; null means derive from obers_ui's `context.colors`, `context.spacing`, etc.
   - Factory: `OiChartThemeData.fromContext(BuildContext)` to auto-derive from obers_ui theme

6. `OiChartPalette` — color palette contract:
   - `categorical`: `List<Color>` (8-12 distinguishable colors derived from theme)
   - `positive`, `negative`, `neutral`, `highlight`: semantic colors
   - `sequentialGradient`, `divergingGradient`: optional `Gradient`
   - Factory: `OiChartPalette.fromColorScheme(OiColorScheme)` to auto-derive

7. Register chart theme in obers_ui's `OiComponentThemes`:
   - Add nullable `OiChartThemeData? chart` field to `OiComponentThemes` in main obers_ui package
   - Accessible via `context.components.chart`

### Scale System

8. `OiAxisScaleType` enum: `linear`, `logarithmic`, `time`, `category`, `band`, `point`

9. `OiChartScale<TDomain>` — abstract scale contract:
   - `double toPixel(TDomain value, double axisLength)` — domain → pixel
   - `TDomain fromPixel(double pixel, double axisLength)` — pixel → domain
   - `List<TDomain> buildTicks(OiAxisTickStrategy strategy, double axisLength)` — generate tick values
   - `OiChartScale<TDomain> withDomain(TDomain min, TDomain max)` — create constrained copy

10. Concrete scale implementations:
    - `OiLinearScale` — numeric linear mapping
    - `OiLogarithmicScale` — log-based mapping
    - `OiTimeScale` — DateTime mapping with intelligent tick intervals (seconds → years)
    - `OiCategoryScale` — discrete categorical labels
    - `OiBandScale` — discrete with width (for bars)

11. `OiAxisTickStrategy` — tick generation configuration:
    - `maxCount`: max ticks to generate
    - `minSpacingPx`: minimum pixel spacing between ticks
    - `includeEndpoints`: bool
    - `niceValues`: bool (round to "nice" numbers)

### Viewport

12. `OiChartViewport` — normalized geometry contract:
    - `plotBounds`: `Rect` (the actual drawable plot area in local coordinates)
    - `padding`: `EdgeInsets`
    - `axisInsets`: `EdgeInsets` (space consumed by axis labels/titles)
    - `devicePixelRatio`: `double`
    - `toLocal(Offset global)` / `toGlobal(Offset local)` — coordinate conversion
    - `visibleDomainX` / `visibleDomainY` — current visible domain ranges

13. `OiChartViewportState` — mutable viewport state for zoom/pan:
    - `xMin`, `xMax`, `yMin`, `yMax` — current visible domain window
    - `zoomLevel`: `double`
    - `panOffset`: `Offset`
    - `isZoomed`: `bool` getter
    - `reset()` method

### Behavior System

14. `OiChartBehavior` — abstract base for composable interaction behaviors:
    - `void attach(OiChartBehaviorContext context)`
    - `void detach(OiChartBehaviorContext context)`
    - `void onPointerEvent(PointerEvent event, OiChartBehaviorContext context)`
    - `void onKeyEvent(KeyEvent event, OiChartBehaviorContext context)`
    - `void onSelectionChanged(OiChartSelectionState selection, OiChartBehaviorContext context)`
    - `void onViewportChanged(OiChartViewportState viewport, OiChartBehaviorContext context)`
    - `List<Widget> buildOverlays(OiChartBehaviorContext context)` — for tooltip/crosshair overlays

15. `OiChartBehaviorContext` — shared context passed to behaviors:
    - `BuildContext buildContext`
    - `OiChartController controller`
    - `OiChartViewport viewport`
    - `OiChartHitTester hitTester`
    - `OiChartThemeData theme`
    - `OiChartSyncCoordinator? sync`
    - `OiChartAccessibilityBridge accessibility`

16. Built-in behavior implementations:
    - `OiTooltipBehavior` — hover/tap tooltip with configurable trigger, anchor, delay, builder
    - `OiCrosshairBehavior` — vertical/horizontal/both crosshair lines following pointer
    - `OiZoomPanBehavior` — wheel zoom, pinch zoom, drag pan with configurable constraints
    - `OiSelectionBehavior` — point/series/domain-group/brush selection modes
    - `OiBrushBehavior` — drag-to-select domain range
    - `OiKeyboardExploreBehavior` — arrow key point navigation, series switching, value announcement
    - `OiHoverSyncBehavior` — broadcast hover position to syncGroup siblings
    - `OiSeriesToggleBehavior` — legend-driven series show/hide

### Controller

17. `OiChartController` extends `ChangeNotifier`:
    - `OiChartSelectionState selection`
    - `OiChartViewportState viewport`
    - `OiChartHoverState hover`
    - `OiChartLegendState legend`
    - `OiChartFocusState focus`
    - Methods: `clearSelection()`, `resetZoom()`, `focusSeries(String)`, `toggleSeries(String)`, `setVisibleDomain(...)`, `dispose()`

### Accessibility

18. `OiChartAccessibilityConfig`:
    - `enabled`: bool (default true)
    - `generateSummary`: bool (default true)
    - `exposeDataTable`: bool (default false)
    - `enableKeyboardExploration`: bool (default true)
    - `verbosity`: `OiChartSemanticVerbosity` (minimal/standard/detailed)
    - `summaryBuilder`: optional custom `String Function(OiChartAccessibilitySummary)`

19. `OiChartAccessibilitySummary` — auto-generated from chart config:
    - `chartType`, `seriesLabels`, `xAxisLabel`, `yAxisLabel`
    - `minX`, `maxX`, `minY`, `maxY`
    - `insights`: `List<OiDetectedChartInsight>` (trend direction, notable extrema)

20. `OiChartAccessibilityBridge` — internal bridge for behaviors to announce:
    - `announcePoint(String seriesLabel, String xFormatted, String yFormatted)`
    - `announceSummary(String summary)`
    - `announceNavigation(String direction, String targetDescription)`

### Animation

21. `OiChartAnimationConfig`:
    - `enabled`: bool
    - `duration`: Duration
    - `curve`: Curve
    - `enter`: `OiChartEnterAnimation` (grow/fade/slide/none)
    - `update`: `OiChartUpdateAnimation` (morph/crossfade/none)
    - `exit`: `OiChartExitAnimation` (shrink/fade/none)
    - `respectReducedMotion`: bool (default true, reads from OiApp)

22. `OiSeriesAnimationConfig` — per-series override:
    - `duration`, `delay`, `curve` — all optional, override chart-level

### Performance

23. `OiChartPerformanceConfig`:
    - `renderMode`: `OiChartRenderMode` (auto/quality/balanced/performance)
    - `decimation`: `OiChartDecimationStrategy` (none/minMax/lttb/adaptive)
    - `progressiveChunkSize`: int (default 5000)
    - `maxInteractivePoints`: int (default 10000)
    - `cacheTextLayout`: bool (default true)
    - `cachePaths`: bool (default true)
    - `simplifyOffscreenGeometry`: bool (default true)

24. `OiChartDecimationStrategy` enum: `none`, `minMax`, `lttb`, `adaptive`
    - `minMax`: keep min/max per pixel bucket
    - `lttb`: Largest-Triangle-Three-Buckets algorithm
    - `adaptive`: auto-select based on data volume and viewport width

25. Decimation utility functions (pure, testable):
    - `List<T> decimateMinMax<T>(List<T> data, num Function(T) y, int targetPoints)`
    - `List<T> decimateLttb<T>(List<T> data, num Function(T) x, num Function(T) y, int targetPoints)`

### Streaming Data Support

26. `OiStreamingDataSource<T>` — abstract contract for real-time data:
    - `Stream<List<T>> get dataStream` — emits batches of new data points
    - `int? get maxRetainedPoints` — optional ring-buffer size limit
    - `Duration? get updateInterval` — throttle/debounce interval

27. `OiRingBuffer<T>` — fixed-capacity circular buffer:
    - `void addAll(List<T> items)` — append, evict oldest if over capacity
    - `void add(T item)`
    - `List<T> get items` — current buffer contents (ordered)
    - `int get length`, `int get capacity`
    - `void clear()`

28. `OiStreamingSeriesAdapter<T>` — bridges streaming source to series contract:
    - Wraps `OiStreamingDataSource<T>`
    - Maintains internal `OiRingBuffer<T>`
    - Exposes `List<T> get currentData` for series consumption
    - Handles subscription lifecycle (attach/detach with chart widget)
    - Configurable: `appendMode` (append/replace), `windowDuration` (time-based windowing)

29. Series contracts must support streaming: `OiChartSeries<T>` accepts either static `List<T> data` or `OiStreamingDataSource<T> streamingData` (mutually exclusive).

### Persistence

30. `OiChartSettings` implementing `OiSettingsData`:
    - `hiddenSeriesIds`: `Set<String>`
    - `viewport`: `OiPersistedViewport?` (xMin, xMax, yMin, yMax)
    - `selection`: `OiPersistedSelection?`
    - `expandedLegendGroups`: `Map<String, bool>`
    - `activeComparisonMode`: `String?`
    - `schemaVersion`: int
    - `toJson()` / `fromJson()` / `merge()`

31. Charts use obers_ui's `OiSettingsMixin` pattern directly. No chart-specific persistence system.

### Sync

32. `OiChartSyncCoordinator` — singleton registry for linked charts:
    - `register(String syncGroup, OiChartController controller)`
    - `unregister(String syncGroup, OiChartController controller)`
    - `broadcastHover(String syncGroup, Object? xDomainValue, String sourceChartId)`
    - `broadcastViewport(String syncGroup, OiChartViewportState viewport, String sourceChartId)`
    - Provided via `InheritedWidget` from `OiApp` or a wrapping `OiChartSyncProvider`

### Formatters

33. Formatter typedefs (aligned with obers_ui utility patterns):
    - `typedef OiAxisFormatter<T> = String Function(T value, OiAxisFormatContext context)`
    - `typedef OiTooltipValueFormatter = String Function(Object? value, OiTooltipFormatContext context)`
    - `typedef OiSeriesLabelFormatter<T> = String Function(T item, OiSeriesLabelContext context)`

34. `OiAxisFormatContext`: provides `axisPosition`, `isFirstTick`, `isLastTick`, `availableWidth`
35. `OiTooltipFormatContext`: provides `seriesId`, `seriesLabel`, `pointIndex`

### Extension/Plugin

36. `OiChartExtension` — lifecycle hooks for custom rendering:
    - `beforeLayout`, `afterLayout`
    - `beforePaint`, `afterPaint` (receive `Canvas`)
    - `beforeHitTest`, `afterHitTest`
    - `onEvent` (receive `PointerEvent`)

## Data Contracts (Models)

### Series

37. `OiChartSeries<T>` — abstract base for all series:
    - `id`: String (required, unique within chart)
    - `label`: String (required, used in legend and accessibility)
    - `data`: `List<T>?` (static data)
    - `streamingData`: `OiStreamingDataSource<T>?` (streaming data, mutually exclusive with `data`)
    - `visible`: bool (default true)
    - `style`: `OiSeriesStyle?`
    - `animation`: `OiSeriesAnimationConfig?`
    - `legend`: `OiSeriesLegendConfig?`
    - `semanticLabel`: String?

38. Cartesian series base: `OiCartesianSeries<T>` extends `OiChartSeries<T>`:
    - `x`: `Object? Function(T item)` (mapper)
    - `y`: `num? Function(T item)` (mapper)
    - `pointLabel`: `String? Function(T item)?`
    - `isMissing`: `bool Function(T item)?`
    - `semanticValue`: `String? Function(T item)?`
    - `yAxisId`: `String?` (for multi-axis charts)

39. Polar series base: `OiPolarSeries<T>` extends `OiChartSeries<T>`:
    - `value`: `num Function(T item)` (mapper)
    - `label`: `String Function(T item)?` (category/slice mapper)

40. Matrix series base: `OiMatrixSeries<T>` extends `OiChartSeries<T>`:
    - `row`: `Object Function(T item)` (mapper)
    - `column`: `Object Function(T item)` (mapper)
    - `value`: `num Function(T item)` (mapper)

41. Hierarchical series base: `OiHierarchicalSeries<TNode>` extends `OiChartSeries<TNode>`:
    - `nodeId`: `String Function(TNode node)`
    - `parentId`: `String? Function(TNode node)`
    - `value`: `num Function(TNode node)`
    - `nodeLabel`: `String Function(TNode node)`

42. Flow series base: `OiFlowSeries<TNode, TLink>`:
    - `nodes`: `List<TNode>`
    - `links`: `List<TLink>`
    - `nodeId`: `String Function(TNode node)`
    - `sourceId`: `String Function(TLink link)`
    - `targetId`: `String Function(TLink link)`
    - `linkValue`: `num Function(TLink link)`

### Normalized Internal Model

43. `OiChartDatum` — internal normalized point (not public API):
    - `seriesId`, `index`, `rawItem` (original domain object)
    - `xRaw`, `yRaw` (original domain values)
    - `xScaled`, `yScaled` (pixel positions after scale transform)
    - `colorRaw`, `label`, `isMissing`
    - `extra`: `Map<String, Object?>` (extensible metadata)

### Axis

44. `OiChartAxis<TDomain>`:
    - `label`: String?
    - `scaleType`: `OiAxisScaleType` (auto-inferred if not provided)
    - `position`: `OiAxisPosition` (top/bottom/left/right)
    - `formatter`: `OiAxisFormatter<TDomain>?`
    - `ticks`: `OiAxisTickStrategy?`
    - `maxVisibleTicks`: `OiResponsive<int>?`
    - `showGrid`: bool
    - `showAxisLine`: bool
    - `showTickMarks`: bool
    - `domain`: `OiAxisRange<TDomain>?` (explicit min/max override)
    - `overflowBehavior`: `OiAxisLabelOverflowBehavior` (rotate/truncate/skip/wrap)
    - `titleAlignment`: `OiAxisTitleAlignment`

### Legend

45. `OiChartLegendConfig`:
    - `show`: bool
    - `position`: `OiResponsive<OiLegendPosition>?` (top/bottom/left/right)
    - `wrapBehavior`: `OiLegendWrapBehavior` (wrap/scroll/collapse)
    - `allowSeriesToggle`: bool
    - `allowExclusiveFocus`: bool
    - `itemBuilder`: `Widget Function(BuildContext, OiLegendItem)?`

46. `OiLegendItem`:
    - `seriesId`, `label`, `color`, `markerShape`, `visible`, `emphasized`

### Tooltip

47. `OiChartTooltipConfig`:
    - `enabled`: bool
    - `triggerMode`: `OiTooltipTriggerMode` (hover/tap/longPress)
    - `anchorMode`: `OiTooltipAnchorMode` (nearestPoint/cursor/fixed)
    - `showDelay`, `hideDelay`: Duration
    - `builder`: `Widget Function(BuildContext, OiChartTooltipModel)?`
    - Renders through OiOverlays when floating

48. `OiChartTooltipModel`:
    - `globalPosition`: Offset
    - `entries`: `List<OiTooltipEntry>` (seriesLabel, formattedX, formattedY, color)
    - `title`, `footer`: String?

### Annotation & Threshold

49. `OiChartAnnotation`:
    - `type`: `OiAnnotationType` (horizontalLine/verticalLine/region/point/label)
    - `value` / `range`: domain value(s)
    - `label`: String?
    - `style`: `OiAnnotationStyle?`
    - `semanticLabel`: String?

50. `OiChartThreshold`:
    - `value`: num
    - `label`: String?
    - `color`: Color? (derived from theme if null)
    - `dashPattern`: `List<double>?`
    - `showLabel`: bool
    - `position`: `OiThresholdLabelPosition`

### State Models

51. `OiChartSelectionState`: `selectedPointIndices`, `selectedSeriesIds`, `selectedDomainRange`
52. `OiChartHoverState`: `hoveredSeriesId`, `hoveredPointIndex`, `hoverPosition`
53. `OiChartLegendState`: `hiddenSeriesIds`, `emphasizedSeriesId`
54. `OiChartFocusState`: `focusedSeriesId`, `focusedPointIndex` (keyboard navigation)

### Style

55. `OiSeriesStyle`:
    - `strokeColor`, `strokeWidth`, `strokeCap`, `strokeJoin`
    - `dashPattern`: `List<double>?`
    - `fill`: `OiSeriesFill?` (solid/gradient)
    - `marker`: `OiMarkerStyle?`
    - `dataLabel`: `OiDataLabelStyle?`
    - `hoverStyle`, `selectedStyle`, `inactiveStyle`: self-type overrides

56. `OiMarkerStyle`: `shape` (circle/square/diamond/triangle/cross/custom), `size`, `fill`, `stroke`, `strokeWidth`, `visible`

## Primitives Layer (Tier 1)

57. `OiChartCanvas` — wrapper around CustomPainter providing:
    - Clip-to-plot-area enforcement
    - Layer ordering (background → grid → data → annotations → overlays)
    - Device pixel ratio awareness
    - Retained geometry caching hooks

58. `OiChartLayer` — abstract layer contract for ordered painting:
    - `void paint(Canvas canvas, OiChartViewport viewport)`
    - `int get zOrder`

59. `OiChartHitTester` — spatial lookup for interaction:
    - `OiHitTestResult? hitTest(Offset localPosition, {double tolerance})`
    - `List<OiHitTestResult> hitTestAll(Offset localPosition, {double tolerance})`
    - `OiHitTestResult? nearestPoint(Offset localPosition, {String? preferSeriesId})`
    - Must use binary search / bucket indexing for ordered domains, not linear scan

60. `OiHitTestResult`: `seriesId`, `pointIndex`, `datum` (OiChartDatum), `distance`, `screenPosition`

61. Painters (internal, used by chart layers):
    - `OiGridPainter` — paints major/minor grid lines
    - `OiAxisPainter` — paints axis line, ticks, labels, title
    - `OiMarkerPainter` — paints data point markers
    - `OiChartLabelPainter` — paints data labels with collision avoidance

## Components Layer (Tier 2)

62. `OiChartAxisWidget` — widget wrapper for axis rendering with:
    - responsive tick density
    - label overflow handling (rotate/truncate/skip)
    - title rendering
    - interactive axis zoom later

63. `OiChartLegendWidget` — shared legend component using obers_ui primitives:
    - OiRow/OiColumn layout
    - OiLabel for text
    - Tappable items for toggle
    - Keyboard navigable
    - Responsive position via OiResponsive

64. `OiChartTooltipWidget` — tooltip rendered via OiOverlays:
    - Multi-entry layout
    - Theme-derived surface styling
    - Touch/pointer adaptive trigger

65. `OiChartCrosshairWidget` — overlay crosshair lines

66. `OiChartBrushWidget` — visual brush/selection rectangle overlay

67. `OiChartZoomControlsWidget` — optional visible zoom/reset buttons for touch

68. `OiChartAnnotationLayer` — paints annotations and thresholds

69. `OiChartEmptyState` — shown when no data, uses obers_ui patterns
70. `OiChartLoadingState` — shown during data load
71. `OiChartErrorState` — shown on data error

72. `OiChartSeriesToggle` — legend-integrated series visibility toggle

## Composites Layer (Tier 3) — Family Base Widgets

73. `OiCartesianChart<T>` — base widget for all x/y charts:
    - `xAxis`: `OiChartAxis`
    - `yAxes`: `List<OiChartAxis>` (multi-axis support)
    - `series`: `List<OiCartesianSeries<T>>`
    - Plus all shared props from `OiChartWidget` base (label, semanticLabel, theme, legend, behaviors, annotations, thresholds, performance, animation, accessibility, settings, controller, syncGroup, loading/empty/error states)
    - Orchestrates: viewport calculation, scale resolution, data normalization, behavior dispatch, overlay rendering, accessibility tree

74. `OiPolarChart<T>` — base widget for radial charts:
    - `angleAxis`: `OiPolarAngleAxis`
    - `radiusAxis`: `OiPolarRadiusAxis`
    - `series`: `List<OiPolarSeries<T>>`
    - Handles arc layout, radial label placement, center content, angular hit testing

75. `OiMatrixChart<T>` — base widget for cell-grid charts:
    - `xAxis`, `yAxis`: `OiChartAxis`
    - `colorScale`: `OiColorScale`
    - `series`: `List<OiMatrixSeries<T>>`

76. `OiHierarchicalChart<TNode>` — base widget for tree charts:
    - `data`: `List<TNode>`
    - `nodeId`, `parentId`, `value`, `label`: mappers
    - Handles tree parsing, value aggregation, depth calculation, drill navigation

77. `OiFlowChart<TNode, TLink>` — base widget for flow/network charts:
    - `nodes`, `links`: data lists
    - `nodeId`, `sourceId`, `targetId`, `linkValue`: mappers
    - Handles node/link layout, flow width scaling, path routing

## Migration from obers_ui

78. Move these files/directories from `lib/src/composites/visualization/` in obers_ui to `packages/obers_ui_charts/lib/src/composites/`:
    - `oi_bar_chart/` (entire directory)
    - `oi_radar_chart.dart`
    - `oi_heatmap.dart`
    - `oi_gauge.dart`
    - `oi_sankey.dart`
    - `oi_funnel_chart.dart`
    - `oi_treemap.dart`
    - `oi_bubble_chart.dart` / `oi_bubble_chart/`
    - `oi_line_chart.dart` / `oi_line_chart/`
    - Any associated data model files

79. Remove migrated exports from `lib/obers_ui.dart` barrel file in main package.

80. Update migrated charts to use the new foundation contracts where applicable (may be incremental — initial migration can preserve existing internal logic, with refactoring to shared substrate as a follow-up task).

81. Preserve or improve existing test coverage for all migrated charts. Move corresponding test files to `packages/obers_ui_charts/test/`.

82. Add `obers_ui_charts` as a dependency in the example app's pubspec.yaml so existing examples continue to work.

## obers_ui Main Package Changes

83. Add `OiChartThemeData? chart` to `OiComponentThemes` in obers_ui.

84. Add `OiChartSyncCoordinator` provisioning in `OiApp` (lazy, only created when charts with syncGroup are used).

85. Export `OiChartThemeData` from obers_ui_charts barrel, not from obers_ui (obers_ui only holds the nullable field slot).

## Error Handling

86. `OiChartSeries` must validate: either `data` or `streamingData` provided, not both. Throw `ArgumentError` at construction if violated.

87. Scale auto-resolution must handle: empty data gracefully (show empty state), single-point data (use reasonable default domain padding), mixed-type x-values (throw descriptive error at normalization time).

88. Streaming data source errors: `OiStreamingSeriesAdapter` catches stream errors, exposes `OiChartErrorState`, and calls `onError` callback. Chart does not crash — shows error state widget.

89. Hit test with no data returns null, not exception.

90. Theme resolution fallback chain: series style → chart-local theme → `context.components.chart` → auto-derived from `context.colors`.

## Edge Cases

91. Zero data points → show `emptyState` widget
92. Single data point → render with default domain padding, no interpolation
93. All series hidden → show empty state with "all series hidden" message
94. Negative values in log scale → clamp to minimum positive threshold, log warning
95. NaN/Infinity in data → treat as missing, apply `missingValueBehavior`
96. Rapid streaming updates → throttle to `updateInterval`, batch pending items
97. SyncGroup with single chart → no-op, no error
98. Controller disposed while behaviors attached → behaviors auto-detach
99. Theme change mid-animation → restart animation with new theme values, don't glitch
100. Viewport zoom to zero range → clamp to minimum domain extent

</requirements>

<boundaries>

**Edge cases:**
- Empty data lists → empty state, not crash
- Single data point → rendered with padding, tooltip works
- Extremely large datasets (100k+) → decimation kicks in automatically in `adaptive` mode
- Rapid data appends via streaming → throttled, ring buffer evicts oldest
- All series toggled hidden → empty state shown
- Mixed numeric and DateTime x-values across series → descriptive ArgumentError
- NaN/Infinity values → treated as missing data

**Error scenarios:**
- Streaming source emits error → chart shows error state, recoverable on next emit
- Invalid scale type for data (e.g., log scale with negatives) → warning + clamp
- Theme not available in context → auto-derive from defaults
- Controller used after dispose → no-op, logged warning in debug mode
- Persistence driver fails → chart works without persistence, logs warning

**Limits:**
- Decimation target: configurable, default ~2x viewport pixel width
- Max tooltip entries: configurable via `OiTooltipBehavior.maxEntries`
- Ring buffer capacity: configurable per streaming source, default 10000
- Max concurrent sync groups: unlimited but each has overhead
- Animation duration capped at 2000ms to prevent stuck states

</boundaries>

<implementation>

**Files to create (key foundation files):**

```
packages/obers_ui_charts/
  pubspec.yaml
  analysis_options.yaml
  lib/
    obers_ui_charts.dart
    src/
      foundation/
        oi_chart_theme_data.dart
        oi_chart_palette.dart
        oi_chart_defaults.dart
        oi_chart_scale.dart
        oi_chart_scales/
          oi_linear_scale.dart
          oi_logarithmic_scale.dart
          oi_time_scale.dart
          oi_category_scale.dart
          oi_band_scale.dart
        oi_chart_viewport.dart
        oi_chart_viewport_state.dart
        oi_chart_behavior.dart
        oi_chart_behavior_context.dart
        oi_chart_controller.dart
        oi_chart_interaction.dart
        oi_chart_animation.dart
        oi_chart_accessibility.dart
        oi_chart_formatters.dart
        oi_chart_settings.dart
        oi_chart_sync.dart
        oi_chart_extension.dart
        oi_chart_performance.dart
        oi_chart_decimation.dart
        oi_chart_streaming.dart
        oi_ring_buffer.dart
      primitives/
        oi_chart_canvas.dart
        oi_chart_layer.dart
        oi_chart_hit_test.dart
        oi_chart_marker.dart
        oi_chart_label_painter.dart
        oi_grid_painter.dart
        oi_axis_painter.dart
      components/
        oi_chart_axis_widget.dart
        oi_chart_legend_widget.dart
        oi_chart_tooltip_widget.dart
        oi_chart_crosshair_widget.dart
        oi_chart_brush_widget.dart
        oi_chart_zoom_controls.dart
        oi_chart_annotation_layer.dart
        oi_chart_empty_state.dart
        oi_chart_loading_state.dart
        oi_chart_error_state.dart
        oi_chart_series_toggle.dart
      composites/
        oi_cartesian_chart.dart
        oi_polar_chart.dart
        oi_matrix_chart.dart
        oi_hierarchical_chart.dart
        oi_flow_chart.dart
      models/
        oi_chart_series.dart
        oi_cartesian_series.dart
        oi_polar_series.dart
        oi_matrix_series.dart
        oi_hierarchical_series.dart
        oi_flow_series.dart
        oi_chart_datum.dart
        oi_chart_axis.dart
        oi_chart_legend_config.dart
        oi_chart_tooltip_config.dart
        oi_chart_annotation.dart
        oi_chart_threshold.dart
        oi_chart_state_models.dart
        oi_series_style.dart
        oi_marker_style.dart
      behaviors/
        oi_tooltip_behavior.dart
        oi_crosshair_behavior.dart
        oi_zoom_pan_behavior.dart
        oi_selection_behavior.dart
        oi_brush_behavior.dart
        oi_keyboard_explore_behavior.dart
        oi_hover_sync_behavior.dart
        oi_series_toggle_behavior.dart
      utils/
        chart_math.dart
        path_utils.dart
        label_collision.dart
```

**Files to modify in obers_ui:**
- `lib/src/foundation/theme/component_themes/oi_component_themes.dart` — add `chart` field
- `lib/src/foundation/oi_app.dart` — add lazy `OiChartSyncCoordinator` provider
- `lib/obers_ui.dart` — remove migrated visualization exports
- `example/pubspec.yaml` — add obers_ui_charts dependency

**Patterns to follow:**
- obers_ui's `OiComponentThemes` pattern for theme registration
- obers_ui's `OiSettingsMixin` pattern for persistence
- obers_ui's barrel file export pattern with sectioned comments
- `very_good_analysis` linting with `require_trailing_commas`
- Test helper pattern from `test/helpers/pump_app.dart`

**What to avoid:**
- Material/Cupertino widgets — use obers_ui primitives
- Hardcoded colors — derive from theme
- Raw `Text()` — use `OiLabel`
- Raw `Row`/`Column` — use `OiRow`/`OiColumn`
- Abbreviated prop names — use full English words
- Giant monolithic config objects — use composable behaviors
- Library-specific forced data models — use mapper-first binding
- Separate persistence system — reuse obers_ui's drivers
- Linear scan hit testing — use indexed/binary search

</implementation>

<stages>

**Phase 1: Package scaffold and foundation contracts**
- Create package structure (pubspec, analysis_options, barrel file, directory tree)
- Implement all foundation types (theme, scales, viewport, behavior base, controller, animation, performance, accessibility, formatters, settings, sync, streaming contracts)
- Implement OiRingBuffer and decimation utilities
- Add `chart` field to OiComponentThemes in main obers_ui
- **Verify:** `dart analyze` passes, all foundation types compile, unit tests for scales, decimation, ring buffer pass

**Phase 2: Data contracts and models**
- Implement all series base classes (OiChartSeries, OiCartesianSeries, OiPolarSeries, OiMatrixSeries, OiHierarchicalSeries, OiFlowSeries)
- Implement OiChartDatum, axis, legend, tooltip, annotation, threshold, state, and style models
- Implement OiStreamingSeriesAdapter
- **Verify:** all model types compile, serialization round-trips pass for OiChartSettings, streaming adapter unit tests pass

**Phase 3: Primitives and painters**
- Implement OiChartCanvas, OiChartLayer, OiChartHitTester
- Implement painters: grid, axis, marker, label (with collision avoidance)
- **Verify:** golden tests for grid/axis/marker rendering pass

**Phase 4: Component widgets**
- Implement chart axis widget, legend widget, tooltip widget, crosshair, brush, zoom controls, annotation layer, empty/loading/error states, series toggle
- **Verify:** widget tests for each component pass, responsive legend position test passes

**Phase 5: Behaviors**
- Implement all 8 built-in behaviors (tooltip, crosshair, zoom/pan, selection, brush, keyboard explore, hover sync, series toggle)
- **Verify:** behavior unit tests pass, keyboard exploration announces values, sync broadcasts correctly

**Phase 6: Family base composites**
- Implement OiCartesianChart, OiPolarChart, OiMatrixChart, OiHierarchicalChart, OiFlowChart
- Wire up: viewport calculation, scale resolution, data normalization, behavior dispatch, overlay rendering, accessibility tree, persistence integration, sync registration
- **Verify:** OiCartesianChart renders with mock series data, accessibility summary generates correctly, zoom/pan modifies viewport, sync between two charts works

**Phase 7: Migration**
- Move existing visualization composites from obers_ui to obers_ui_charts
- Update imports and barrel files in both packages
- Move and update corresponding tests
- Update example app dependency
- **Verify:** `dart analyze` passes in both packages, all migrated tests pass, example app builds

</stages>

<validation>

## Automated Test Coverage Requirements

### Unit Tests (logic, data contracts, utilities)

**Scales:**
- OiLinearScale maps domain values to pixels correctly
- OiLinearScale inverse mapping (pixel → domain) is accurate
- OiTimeScale generates sensible ticks for various ranges (hours, days, months, years)
- OiCategoryScale maps discrete labels to equal band positions
- OiBandScale computes correct band width for given axis length and item count
- OiLogarithmicScale handles edge cases (values near zero, large ranges)
- Scale `withDomain` creates correctly constrained copy
- `buildTicks` respects maxCount and minSpacingPx

**Decimation:**
- `decimateMinMax` preserves global min and max
- `decimateMinMax` reduces point count to target
- `decimateLttb` preserves visually significant points
- `decimateLttb` with fewer points than target returns all points
- Adaptive strategy selects correct algorithm based on data volume
- Decimation with empty data returns empty list
- Decimation with single point returns that point

**Ring Buffer:**
- Add items within capacity retains all
- Add items beyond capacity evicts oldest
- Clear resets to empty
- Items returned in insertion order
- Capacity of 0 is handled gracefully
- addAll with batch larger than capacity keeps only last N items

**Streaming Adapter:**
- Subscribes to stream on attach, unsubscribes on detach
- Maintains ring buffer with correct capacity
- Throttles rapid updates to configured interval
- Exposes currentData matching buffer contents
- Handles stream errors without crashing (exposes error state)
- Multiple attach/detach cycles don't leak subscriptions

**Settings:**
- OiChartSettings serialization round-trip preserves all fields
- OiChartSettings merge combines non-null fields correctly
- Schema version is present and valid

**Controller:**
- Selection state updates notify listeners
- Viewport state updates notify listeners
- resetZoom restores initial viewport
- toggleSeries updates legend state correctly
- clearSelection resets all selection state
- Dispose prevents further notifications

**Hit Testing:**
- Nearest point resolution uses x-distance-first for ordered data
- Hit test with empty data returns null
- Hit test tolerance is respected
- Binary search finds correct bucket in ordered data
- Multi-series hit test returns nearest across all visible series
- Hidden series excluded from hit testing

### Widget Tests (UI behavior)

**Legend Widget:**
- Renders all visible series with correct labels and colors
- Series toggle fires callback with correct seriesId
- Keyboard navigation between legend items works
- Responsive position changes (top → bottom on compact)
- Custom itemBuilder is used when provided

**Tooltip Widget:**
- Appears on hover (pointer mode)
- Appears on tap (touch mode)
- Dismisses correctly on pointer exit / second tap
- Multi-entry tooltip shows all intersected series
- Custom builder is used when provided
- Renders through OiOverlays

**Axis Widget:**
- Renders labels, ticks, and title
- Overflow behavior: rotates labels when they collide
- Responsive tick density reduces on compact
- Formatter is applied to tick labels
- Grid lines render when showGrid is true

**Empty/Loading/Error States:**
- Empty state shown when data is empty
- Loading state shown when loading config provided
- Error state shown on streaming error
- States are accessible (semantic labels)

**Chart Axis rendering:**
- Time axis shows correct date format labels
- Numeric axis shows nice rounded tick values
- Category axis shows all category labels
- Multi-axis (left + right) renders correctly

### Integration Tests (family base widgets)

**OiCartesianChart:**
- Renders with single cartesian series
- Renders with multiple series
- Axes auto-resolve scale type from data (DateTime → time, num → linear)
- Explicit scale override beats auto-inference
- Viewport zoom modifies visible domain
- Selection behavior highlights selected point
- Accessibility summary generates with chart type and series count
- Sync group broadcasts hover to sibling chart
- Persistence saves and restores viewport/hidden series
- Empty data shows empty state
- Performance config enables decimation for large data

**OiPolarChart:**
- Renders radial layout correctly
- Arc hit testing identifies correct slice/segment
- Center content renders in donut mode
- Radial label placement avoids overlaps

**OiMatrixChart:**
- Renders cell grid with correct colors from color scale
- Cell hover highlights correct cell
- Large matrix uses virtualization

**OiHierarchicalChart:**
- Tree parsing correctly builds hierarchy from flat list
- Value aggregation sums leaf values for parent nodes
- Drill navigation updates visible depth

**OiFlowChart:**
- Node/link layout produces valid non-overlapping positioning
- Link width scales proportionally to value
- Node hover highlights connected links

### Accessibility Tests

- Every chart base widget exposes semantic label
- Auto-generated summary includes chart type, series count, axis ranges
- Keyboard left/right navigates between points (OiKeyboardExploreBehavior)
- Keyboard up/down switches series
- Enter selects focused point, escape clears
- Focus announcements use formatted values
- Reduced motion disables enter/exit animations
- Legend items are keyboard operable with semantic roles

### Performance Tests

- 1,000 points renders without jank (sub-16ms frame)
- 10,000 points with decimation enabled renders acceptably
- Ring buffer with 100k append cycles maintains constant memory
- Hidden series excluded from rendering pipeline
- Viewport zoom reduces processed point count

### Theming Tests

- Chart derives default palette from obers_ui theme
- Local chart theme override applies correctly
- Series style override beats chart theme
- Point-level callback override beats series style
- Light and dark theme produce visually distinct output
- Theme change triggers repaint

### Migration Tests

- All migrated chart widgets still render correctly
- All existing tests pass after migration
- No broken imports in main obers_ui package after migration
- Example app builds and runs with obers_ui_charts dependency

## TDD Expectations

- Implement behavior-first: scales → decimation → ring buffer → hit tester → controller → behaviors → component widgets → family bases
- Each slice: write failing test → implement minimum code → refactor
- Testability seams:
  - Scales are pure functions (no widget dependency)
  - Decimation utilities are pure functions
  - Ring buffer is a standalone data structure
  - Hit tester accepts pre-computed datum list (injectable)
  - Controller is a plain ChangeNotifier (testable without widgets)
  - Behaviors receive context via injection (mockable)
  - Theme resolution has fallback chain (testable per layer)
  - Streaming adapter accepts injectable stream (testable with StreamController)

## Test Structure

```
packages/obers_ui_charts/test/
  helpers/
    pump_chart_app.dart          ← PumpChartApp extension (wraps in OiApp + chart theme)
  src/
    foundation/
      oi_linear_scale_test.dart
      oi_time_scale_test.dart
      oi_category_scale_test.dart
      oi_band_scale_test.dart
      oi_logarithmic_scale_test.dart
      oi_chart_decimation_test.dart
      oi_ring_buffer_test.dart
      oi_chart_controller_test.dart
      oi_chart_settings_test.dart
      oi_chart_sync_test.dart
      oi_streaming_series_adapter_test.dart
    primitives/
      oi_chart_hit_test_test.dart
      oi_grid_painter_test.dart
      oi_axis_painter_test.dart
    components/
      oi_chart_legend_widget_test.dart
      oi_chart_tooltip_widget_test.dart
      oi_chart_axis_widget_test.dart
      oi_chart_empty_state_test.dart
    behaviors/
      oi_tooltip_behavior_test.dart
      oi_crosshair_behavior_test.dart
      oi_zoom_pan_behavior_test.dart
      oi_selection_behavior_test.dart
      oi_keyboard_explore_behavior_test.dart
      oi_hover_sync_behavior_test.dart
    composites/
      oi_cartesian_chart_test.dart
      oi_polar_chart_test.dart
      oi_matrix_chart_test.dart
      oi_hierarchical_chart_test.dart
      oi_flow_chart_test.dart
    golden/
      oi_chart_golden_test.dart
```

</validation>

<done_when>
1. `packages/obers_ui_charts` package exists with correct pubspec, analysis_options, and barrel file
2. `dart analyze packages/obers_ui_charts` reports 0 errors, 0 warnings, 0 infos
3. All foundation types (theme, scales, viewport, behaviors, controller, animation, performance, accessibility, formatters, settings, sync, streaming) compile and have passing unit tests
4. All data contracts (series bases, datum, axis, legend, tooltip, annotation, threshold, state models, styles) compile
5. All 5 family base widgets (Cartesian, Polar, Matrix, Hierarchical, Flow) render with test data
6. All 8 built-in behaviors (tooltip, crosshair, zoom/pan, selection, brush, keyboard explore, hover sync, series toggle) pass behavioral tests
7. OiRingBuffer and decimation utilities pass unit tests including edge cases
8. OiStreamingSeriesAdapter handles stream lifecycle, throttling, and errors correctly
9. Accessibility: auto-generated summaries and keyboard exploration work end-to-end
10. Chart sync between two OiCartesianChart instances with shared syncGroup works
11. Persistence: OiChartSettings saves/restores via OiSettingsMixin
12. All existing visualization composites migrated from obers_ui to obers_ui_charts
13. Migrated charts' tests pass in new location
14. Main obers_ui package: `dart analyze` passes, no broken imports
15. Example app builds with obers_ui_charts dependency
16. `flutter test packages/obers_ui_charts` — all tests pass
</done_when>
