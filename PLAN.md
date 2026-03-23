# WI-0003: Architecture & Chart Taxonomy (Part 1/2) — Implementation Plan

## Concept

Restructure `packages/obers_ui_charts/` from its flat `core/` + `charts/` layout into a 5-tier composition hierarchy (Foundation → Primitives → Components → Composites → Modules) that mirrors `obers_ui`, add `obers_ui` as a dependency so charts use OiSurface/OiLabel/OiOverlays instead of Material/Cupertino widgets, and create five chart-family base classes (Cartesian, Polar, Matrix, Hierarchical, Flow) with shared coordinate systems, data contracts, interactions, and theming.

---

## Sub-tasks

**ST1: Update package configuration**
Add `obers_ui` path dependency to `pubspec.yaml`. Verify `analysis_options.yaml` is aligned.

**ST2: Create Foundation tier — data models**
Move `OiDataPoint`, `OiChartSeries`, `OiChartBounds`, `OiChartData` from `core/chart_data.dart` to `foundation/data/chart_data.dart`. Move `OiChartPadding` from `core/chart_padding.dart` to `foundation/data/chart_padding.dart`.

**ST3: Create Foundation tier — theme bridge**
Create `OiChartThemeData` (renamed from `OiChartTheme`) in `foundation/theme/chart_theme_data.dart` with a `fromContext(BuildContext)` factory that derives colors from `context.colors.chart`, text styles from `context.textTheme`, spacing from `context.spacing`. Move and refactor `OiChartColors` and `OiChartTextStyles` to `foundation/theme/`.

**ST4: Create Foundation tier — scales**
Create `OiLinearScale` (double→double mapping with ticks) and `OiBandScale` (categorical→double mapping with bandwidth). These power the coordinate systems in family base classes.

**ST5: Create Foundation tier — behavior & accessibility**
Create `OiChartBehavior` config (animation, interaction mode) and `OiChartA11y` static helpers (semantic descriptions for charts and data points).

**ST6: Create Primitives tier**
Move `OiChartPainter` to `primitives/painters/`, `OiChartHitResult` and `OiChartGestureHandler` to `primitives/hit_testing/`. Create `OiMarkerShape` enum + `OiChartMarkerPainter` in `primitives/markers/`. Create `OiChartLayer` in `primitives/layers/`.

**ST7: Create Components tier**
Create `OiChartAxisConfig` (axis configuration), `OiChartLegend` widget (uses `OiLabel`), `OiChartTooltip` + `OiChartTooltipController` (moved from core, enhanced to use `OiOverlays`), `OiChartCrosshair` config, `OiChartAnnotation` config, `OiChartThresholdBand` config.

**ST8: Create Cartesian family base**
Create `OiCartesianChart` (abstract StatefulWidget), `OiCartesianChartState` (handles theme resolution, scale computation, grid/axis layout via OiSurface wrapper), and `OiCartesianPainter` (paints grid + axes, delegates series painting to subclass).

**ST9: Create Polar family base**
Create `OiPolarChart` (abstract StatefulWidget), `OiPolarData` / `OiPolarSegment` data contract, and `OiPolarPainter` (paints radial background, delegates segment painting).

**ST10: Create Matrix, Hierarchical, Flow family bases**
Create data contracts (`OiMatrixData`/`OiMatrixCell`, `OiHierarchicalData`/`OiHierarchicalNode`, `OiFlowData`/`OiFlowNode`/`OiFlowLink`) and abstract base widgets for each. These are structural placeholders for future chart implementations.

**ST11: Migrate line + bar charts to Cartesian family**
Move `line/` and `bar/` to `composites/cartesian/`. Refactor `OiLineChart` and `OiBarChart` to extend `OiCartesianChart`. Refactor painters to extend `OiCartesianPainter`. Wrap chart rendering in `OiSurface`. Use `OiChartThemeData.fromContext()` as default theme resolution.

**ST12: Migrate pie chart to Polar family**
Move `pie/` to `composites/polar/`. Refactor `OiPieChart` to extend `OiPolarChart`. Convert data from `OiChartData` to `OiPolarData`. Wrap in `OiSurface`.

**ST13: Create Modules tier placeholder + update barrel file**
Create `modules/.gitkeep`. Rewrite `obers_ui_charts.dart` barrel file with new export paths organized by tier.

**ST14: Remove old directories**
Delete `lib/src/core/` and `lib/src/charts/` (all code now in tiered directories).

**ST15: Create and migrate tests**
Move existing test files to match new source structure. Create new tests for scales, theme bridge, markers, legend, family base classes, and tier import rules.

**ST16: Run checks and fix issues**
Run `dart format .`, `dart analyze`, `flutter test`. Fix any issues.

---

## Method signatures

### Foundation (Tier 0)

**`foundation/theme/chart_theme_data.dart`**
- `OiChartThemeData({required OiChartColors colors, required OiChartTextStyles textStyles, double gridLineWidth, double axisLineWidth, OiChartPadding padding})`
- `OiChartThemeData.fromContext(BuildContext context)` — derives from `context.colors.chart`, `context.textTheme`, `context.colors.border`
- `OiChartThemeData.light()` — standalone light preset
- `OiChartThemeData.dark()` — standalone dark preset
- `OiChartThemeData.copyWith({OiChartColors? colors, OiChartTextStyles? textStyles, double? gridLineWidth, double? axisLineWidth, OiChartPadding? padding})`

**`foundation/theme/chart_colors.dart`** (moved + enhanced)
- `OiChartColors({required List<Color> seriesColors, required Color gridColor, required Color axisColor, required Color backgroundColor})`
- `OiChartColors.fromColorScheme(OiColorScheme scheme)` — new factory
- `OiChartColors.colorForSeries(int index) → Color`

**`foundation/theme/chart_text_styles.dart`** (moved + enhanced)
- `OiChartTextStyles({required TextStyle axisLabel, required TextStyle tooltipLabel, required TextStyle legendLabel})`
- `OiChartTextStyles.fromTextTheme(OiTextTheme textTheme)` — new factory

**`foundation/data/chart_data.dart`** (moved, unchanged API)
- `OiDataPoint({required double x, required double y, String? label})`
- `OiChartSeries({required String name, required List<OiDataPoint> dataPoints, Color? color})`
- `OiChartBounds({required double minX, required double maxX, required double minY, required double maxY})`
- `OiChartData({required List<OiChartSeries> series})`
- `OiChartData.single({required String name, required List<OiDataPoint> dataPoints})`

**`foundation/data/chart_padding.dart`** (moved, unchanged API)
- `OiChartPadding({double left, double top, double right, double bottom})`

**`foundation/scales/oi_linear_scale.dart`**
- `OiLinearScale({required double domainMin, required double domainMax, required double rangeMin, required double rangeMax, bool clamp})`
- `OiLinearScale.scale(double value) → double`
- `OiLinearScale.invert(double value) → double`
- `OiLinearScale.ticks([int count = 5]) → List<double>`
- `OiLinearScale.copyWith({double? domainMin, double? domainMax, double? rangeMin, double? rangeMax})`

**`foundation/scales/oi_band_scale.dart`**
- `OiBandScale({required List<String> domain, required double rangeMin, required double rangeMax, double paddingInner, double paddingOuter})`
- `OiBandScale.scale(String value) → double` — returns start position of band
- `OiBandScale.bandwidth → double`
- `OiBandScale.invert(double value) → String` — returns nearest band label
- `OiBandScale.ticks → List<String>` — returns all domain values

**`foundation/chart_behavior.dart`**
- `OiChartBehavior({bool animateOnLoad, Duration animationDuration, Curve animationCurve, OiChartInteractionMode interactionMode})`
- `enum OiChartInteractionMode { touch, pointer, auto }`

**`foundation/chart_accessibility.dart`**
- `OiChartA11y.describeChart(String chartType, int seriesCount, int totalPoints) → String`
- `OiChartA11y.describeDataPoint(String seriesName, double x, double y, {String? label}) → String`
- `OiChartA11y.announceSelection(BuildContext context, String message)`

### Primitives (Tier 1)

**`primitives/painters/chart_painter.dart`** (moved, unchanged API)
- `abstract class OiChartPainter extends CustomPainter`
- `OiChartPainter({required OiChartData data, required OiChartThemeData theme, required OiChartPadding padding})`
- `OiChartPainter.chartArea(Size size) → Rect`
- `OiChartPainter.mapDataToPixel(OiDataPoint point, Size size, OiChartBounds bounds) → Offset`
- `OiChartPainter.paintGrid(Canvas canvas, Size size)`
- `OiChartPainter.paintAxes(Canvas canvas, Size size)`

**`primitives/markers/chart_marker.dart`**
- `enum OiMarkerShape { circle, square, diamond, triangle, cross, none }`
- `OiChartMarkerPainter.paint(Canvas canvas, Offset center, {required OiMarkerShape shape, required Color color, double size})`

**`primitives/layers/chart_layer.dart`**
- `OiChartLayer({required void Function(Canvas, Size) painter, double opacity, bool visible})`
- `OiChartLayer.paint(Canvas canvas, Size size)`

**`primitives/hit_testing/chart_hit_result.dart`** (moved, unchanged API)
- `OiChartHitResult({required int seriesIndex, required int pointIndex, required OiDataPoint dataPoint})`

**`primitives/hit_testing/chart_gesture_handler.dart`** (moved, unchanged API)
- `OiChartGestureHandler({required OiChartData data, required OiChartBounds bounds, double hitTolerance, OiChartPadding padding})`
- `OiChartGestureHandler.hitTest(Offset localPosition, Size size) → OiChartHitResult?`

### Components (Tier 2)

**`components/axes/chart_axis_config.dart`**
- `OiChartAxisConfig({String? label, List<String>? tickLabels, String Function(double)? formatValue, int divisions, double? min, double? max})`
- `OiChartAxisConfig.formatValue(double value) → String`

**`components/legend/chart_legend.dart`**
- `OiChartLegend({required List<OiChartLegendItem> items, Axis direction, ValueChanged<int>? onItemTap})`
- `OiChartLegendItem({required String label, required Color color, bool dashed, OiMarkerShape shape})`

**`components/tooltip/chart_tooltip.dart`**
- `OiChartTooltipController({ValueNotifier<OiChartHitResult?>? activeResult})`
- `OiChartTooltipController.active → OiChartHitResult?`
- `set OiChartTooltipController.active(OiChartHitResult?)`
- `OiChartTooltipController.hide()`
- `OiChartTooltipController.dispose()`

**`components/crosshair/chart_crosshair.dart`**
- `OiChartCrosshair({Color? color, double strokeWidth, OiChartCrosshairStyle style})`
- `enum OiChartCrosshairStyle { both, horizontal, vertical }`

**`components/annotations/chart_annotation.dart`**
- `OiChartAnnotation({required double value, OiChartAnnotationAxis axis, Color? color, String? label, double strokeWidth})`
- `enum OiChartAnnotationAxis { x, y }`

**`components/threshold/chart_threshold.dart`**
- `OiChartThresholdBand({required double min, required double max, Color? color, String? label})`

### Composites (Tier 3) — Family Bases

**`composites/cartesian/oi_cartesian_chart.dart`**
- `abstract class OiCartesianChart extends StatefulWidget`
- `OiCartesianChart({required OiChartData data, required String label, OiChartThemeData? theme, OiChartPadding? padding, OiChartAxisConfig? xAxis, OiChartAxisConfig? yAxis, bool showGrid, bool showLegend, List<OiChartAnnotation> annotations, List<OiChartThresholdBand> thresholds, ValueChanged<OiChartHitResult>? onDataPointTap})`
- `abstract class OiCartesianChartState<T extends OiCartesianChart> extends State<T>`
- `OiCartesianChartState.resolveTheme(BuildContext context) → OiChartThemeData`
- `OiCartesianChartState.createSeriesPainter(OiChartThemeData theme, OiChartPadding padding) → CustomPainter` — abstract, subclass implements

**`composites/cartesian/oi_cartesian_painter.dart`**
- `abstract class OiCartesianPainter extends OiChartPainter`
- `OiCartesianPainter({required OiChartData data, required OiChartThemeData theme, required OiChartPadding padding, bool showGrid, OiChartAxisConfig? xAxis, OiChartAxisConfig? yAxis})`
- `OiCartesianPainter.paintSeries(Canvas canvas, Size size)` — abstract, subclass implements
- `@override OiCartesianPainter.paint(Canvas, Size)` — paints grid → series → axes

**`composites/polar/oi_polar_chart.dart`**
- `abstract class OiPolarChart extends StatefulWidget`
- `OiPolarChart({required OiPolarData data, required String label, OiChartThemeData? theme, bool showLegend, ValueChanged<int>? onSegmentTap})`
- `abstract class OiPolarChartState<T extends OiPolarChart> extends State<T>`
- `OiPolarChartState.resolveTheme(BuildContext context) → OiChartThemeData`
- `OiPolarChartState.createSegmentPainter(OiChartThemeData theme) → CustomPainter` — abstract

**`composites/polar/oi_polar_data.dart`**
- `OiPolarSegment({required String label, required double value, Color? color})`
- `OiPolarData({required List<OiPolarSegment> segments})`
- `OiPolarData.isEmpty → bool`
- `OiPolarData.total → double`

**`composites/polar/oi_polar_painter.dart`**
- `abstract class OiPolarPainter extends CustomPainter`
- `OiPolarPainter({required OiPolarData data, required OiChartThemeData theme})`
- `OiPolarPainter.paintBackground(Canvas canvas, Size size)` — draws radial background
- `OiPolarPainter.paintSegments(Canvas canvas, Size size)` — abstract

**`composites/matrix/oi_matrix_data.dart`**
- `OiMatrixCell({required int row, required int column, required double value})`
- `OiMatrixData({required List<OiMatrixCell> cells, List<String>? rowLabels, List<String>? columnLabels})`
- `OiMatrixData.isEmpty → bool`
- `OiMatrixData.valueRange → (double min, double max)`

**`composites/matrix/oi_matrix_chart.dart`**
- `abstract class OiMatrixChart extends StatefulWidget`
- `OiMatrixChart({required OiMatrixData data, required String label, OiChartThemeData? theme})`

**`composites/hierarchical/oi_hierarchical_data.dart`**
- `OiHierarchicalNode({required String key, required String label, required double value, Color? color, List<OiHierarchicalNode> children})`
- `OiHierarchicalData({required List<OiHierarchicalNode> roots})`
- `OiHierarchicalData.isEmpty → bool`
- `OiHierarchicalData.totalValue → double`

**`composites/hierarchical/oi_hierarchical_chart.dart`**
- `abstract class OiHierarchicalChart extends StatefulWidget`
- `OiHierarchicalChart({required OiHierarchicalData data, required String label, OiChartThemeData? theme})`

**`composites/flow/oi_flow_data.dart`**
- `OiFlowNode({required String key, required String label, Color? color})`
- `OiFlowLink({required String sourceKey, required String targetKey, required double value, Color? color})`
- `OiFlowData({required List<OiFlowNode> nodes, required List<OiFlowLink> links})`
- `OiFlowData.isEmpty → bool`

**`composites/flow/oi_flow_chart.dart`**
- `abstract class OiFlowChart extends StatefulWidget`
- `OiFlowChart({required OiFlowData data, required String label, OiChartThemeData? theme})`

---

## Edge cases and fallbacks

| Edge Case | Fallback |
|-----------|----------|
| Missing `OiTheme` in context when using `fromContext()` | Assert with helpful error message; charts used outside `OiApp` must pass explicit `theme` parameter |
| Empty data (zero series or zero points) | Family base classes detect empty data, render `SizedBox.shrink()` with semantics label |
| Single data point in Cartesian chart | Expand bounds ±0.5 to avoid zero range (existing behavior preserved) |
| All-zero values in Polar segments | Distribute angles equally across segments (existing behavior preserved) |
| Negative values in Polar segments | Clamp to zero |
| Chart rendered below minimum size | Render nothing but keep semantics label for accessibility |
| `OiBandScale` with empty domain | Return 0 for all scale calls, bandwidth = 0 |
| `OiLinearScale` with zero range (domainMin == domainMax) | Expand by ±0.5 automatically |
| Cross-tier imports | Enforced by convention and verified by architecture test that scans import statements |
| Theme parameter is null and no OiTheme ancestor | Fall back to `OiChartThemeData.light()` |

---

## UX / requirement matching

**REQ-0006 — 5-tier composition hierarchy:**
- Directory structure: `foundation/` → `primitives/` → `components/` → `composites/` → `modules/`
- Foundation contains: theme bridge (`OiChartThemeData`), scales (`OiLinearScale`, `OiBandScale`), data models, behavior config, accessibility helpers
- Primitives contain: `OiChartPainter` base, markers, hit regions
- Components contain: axis config, legend (with `OiLabel`), tooltip, crosshair, annotation, threshold
- Composites contain: 5 family base classes + actual chart widgets
- Modules: placeholder for dashboard experiences
- Tier import rule enforced by architecture test

**REQ-0007 — Zero Material/Cupertino + use obers_ui primitives:**
- `pubspec.yaml` adds `obers_ui` as path dependency (no Material/Cupertino dependency)
- `OiSurface` used as chart container widget in all family base classes
- `OiLabel` used in `OiChartLegend` for legend text
- `OiChartThemeData.fromContext()` derives theme from `OiThemeData` via context extensions
- `dart analyze` confirms zero Material/Cupertino imports

**REQ-0008 — 5 architectural families:**
- **Cartesian**: `OiCartesianChart` + `OiCartesianPainter` with shared X/Y coordinate system, `OiLinearScale`/`OiBandScale`, grid/axis painting. Line and bar charts extend this.
- **Polar**: `OiPolarChart` + `OiPolarPainter` with shared angle/radius system, `OiPolarData`/`OiPolarSegment` data contract. Pie chart extends this.
- **Matrix**: `OiMatrixChart` with `OiMatrixData`/`OiMatrixCell` data contract for 2D cell grids.
- **Hierarchical**: `OiHierarchicalChart` with `OiHierarchicalData`/`OiHierarchicalNode` for parent-child nesting.
- **Flow**: `OiFlowChart` with `OiFlowData`/`OiFlowNode`/`OiFlowLink` for weighted node-link graphs.

---

## Test cases

### Foundation tests
- `OiChartThemeData.light()` creates theme with 6+ series colors, non-null text styles
- `OiChartThemeData.dark()` creates dark variant with different background color
- `OiChartThemeData.fromContext()` maps `context.colors.chart` to series colors
- `OiChartThemeData.fromContext()` maps `context.colors.border` to grid color
- `OiChartThemeData.copyWith()` replaces only specified fields
- `OiLinearScale` maps domain midpoint to range midpoint
- `OiLinearScale` maps domainMin to rangeMin, domainMax to rangeMax
- `OiLinearScale.invert()` is the inverse of `scale()`
- `OiLinearScale.ticks(5)` returns 5 evenly spaced values including endpoints
- `OiLinearScale` with clamp restricts output to range
- `OiBandScale` maps first domain item to rangeMin + paddingOuter
- `OiBandScale.bandwidth` equals (range - padding) / domain.length
- `OiBandScale.invert()` returns nearest band label
- `OiChartData` bounds computation handles empty, single-point, multi-series (existing tests, moved)
- `OiChartA11y.describeChart()` returns meaningful string
- `OiChartBehavior` defaults: animateOnLoad true, interactionMode auto

### Primitives tests
- `OiChartPainter.chartArea()` returns rect inset by padding (existing, moved)
- `OiChartPainter.mapDataToPixel()` maps correctly (existing, moved)
- `OiChartMarkerPainter.paint()` does not throw for each `OiMarkerShape`
- `OiChartGestureHandler.hitTest()` returns nearest point within tolerance (existing, moved)
- `OiChartGestureHandler.hitTest()` returns null beyond tolerance (existing, moved)
- `OiChartLayer.paint()` calls painter function when visible is true
- `OiChartLayer.paint()` skips when visible is false

### Components tests
- `OiChartLegend` renders correct number of items
- `OiChartLegend` uses `OiLabel` for text (find OiLabel in widget tree)
- `OiChartLegend` calls onItemTap with correct index
- `OiChartAxisConfig.formatValue()` formats integers without decimals
- `OiChartAxisConfig.formatValue()` formats floats to 1 decimal
- `OiChartTooltipController` show/hide cycle updates active result

### Composites tests
- `OiCartesianChart` concrete subclass renders without error
- `OiCartesianChart` wraps content in `OiSurface`
- `OiCartesianChart` resolves theme from context when no explicit theme
- `OiCartesianChart` uses explicit theme over context theme
- `OiPolarChart` concrete subclass renders without error
- `OiPolarChart` wraps content in `OiSurface`
- `OiPolarData` computes total correctly
- `OiPolarSegment` clamps negative values to zero
- `OiMatrixData.valueRange` returns correct min/max
- `OiHierarchicalData.totalValue` sums root values
- `OiHierarchicalNode` supports nested children
- `OiFlowData` validates nodes and links
- Existing `OiLineChart` renders correctly after migration (existing tests, moved)
- Existing `OiBarChart` renders correctly after migration (existing tests, moved)
- Existing `OiPieChart` renders correctly with `OiPolarData` (migrated)

### Architecture tests
- No file in `foundation/` imports from `primitives/`, `components/`, `composites/`, or `modules/`
- No file in `primitives/` imports from `components/`, `composites/`, or `modules/`
- No file in `components/` imports from `composites/` or `modules/`
- No file in `composites/` imports from `modules/`
- No file imports `package:flutter/material.dart` or `package:flutter/cupertino.dart`

---

## Definition of done checklist

- [ ] REQ-0006: 5-tier directory structure exists (`foundation/`, `primitives/`, `components/`, `composites/`, `modules/`)
- [ ] REQ-0006: Foundation contains theme bridge, scales, data models, behavior, accessibility
- [ ] REQ-0006: Primitives contain painter base, markers, hit regions
- [ ] REQ-0006: Components contain axis, legend, tooltip, crosshair, annotation, threshold
- [ ] REQ-0006: Composites contain family bases and chart widgets
- [ ] REQ-0006: Modules tier exists (placeholder)
- [ ] REQ-0006: Each tier only imports from the tier below (verified by architecture test)
- [ ] REQ-0007: `pubspec.yaml` depends on `obers_ui` via path, NOT on Material/Cupertino
- [ ] REQ-0007: All chart family base classes use `OiSurface` as container
- [ ] REQ-0007: `OiChartLegend` uses `OiLabel` for text rendering
- [ ] REQ-0007: `OiChartThemeData.fromContext()` derives theme from `OiThemeData`
- [ ] REQ-0007: `dart analyze` confirms zero `material.dart`/`cupertino.dart` imports
- [ ] REQ-0008: Cartesian family base exists with shared coordinate system and grid/axis painting
- [ ] REQ-0008: Polar family base exists with shared radial coordinate system
- [ ] REQ-0008: Matrix family base exists with 2D cell grid data contract
- [ ] REQ-0008: Hierarchical family base exists with tree data contract
- [ ] REQ-0008: Flow family base exists with node-link data contract
- [ ] REQ-0008: `OiLineChart` and `OiBarChart` extend `OiCartesianChart`
- [ ] REQ-0008: `OiPieChart` extends `OiPolarChart`
- [ ] All checks pass: `dart format`, `dart analyze`, `flutter test`
- [ ] Coverage ledger updated for REQ-0006, REQ-0007, REQ-0008
- [ ] No placeholders or TODO comments in source code

---

## Files to create or modify (MANDATORY)

All paths relative to `packages/obers_ui_charts/`.

### Configuration
1. [ ] `pubspec.yaml` — Add `obers_ui` path dependency (`path: ../../`)
2. [ ] `analysis_options.yaml` — Verify alignment (no changes expected)

### Barrel file
3. [ ] `lib/obers_ui_charts.dart` — Complete rewrite with exports organized by tier

### Foundation (Tier 0) — 9 files
4. [ ] `lib/src/foundation/data/chart_data.dart` — Move from `core/chart_data.dart` (unchanged API)
5. [ ] `lib/src/foundation/data/chart_padding.dart` — Move from `core/chart_padding.dart` (unchanged API)
6. [ ] `lib/src/foundation/theme/chart_theme_data.dart` — New: `OiChartThemeData` with `fromContext()` factory (replaces `core/chart_theme.dart`)
7. [ ] `lib/src/foundation/theme/chart_colors.dart` — Move from `core/chart_colors.dart`, add `fromColorScheme()` factory
8. [ ] `lib/src/foundation/theme/chart_text_styles.dart` — Move from `core/chart_text_styles.dart`, add `fromTextTheme()` factory
9. [ ] `lib/src/foundation/scales/oi_linear_scale.dart` — New: `OiLinearScale`
10. [ ] `lib/src/foundation/scales/oi_band_scale.dart` — New: `OiBandScale`
11. [ ] `lib/src/foundation/chart_behavior.dart` — New: `OiChartBehavior`, `OiChartInteractionMode`
12. [ ] `lib/src/foundation/chart_accessibility.dart` — New: `OiChartA11y`

### Primitives (Tier 1) — 5 files
13. [ ] `lib/src/primitives/painters/chart_painter.dart` — Move from `core/chart_painter.dart`, update imports to reference foundation types (`OiChartThemeData` instead of `OiChartTheme`)
14. [ ] `lib/src/primitives/layers/chart_layer.dart` — New: `OiChartLayer`
15. [ ] `lib/src/primitives/markers/chart_marker.dart` — New: `OiMarkerShape`, `OiChartMarkerPainter`
16. [ ] `lib/src/primitives/hit_testing/chart_hit_result.dart` — Move from `core/chart_hit_result.dart`
17. [ ] `lib/src/primitives/hit_testing/chart_gesture_handler.dart` — Move from `core/chart_gesture_handler.dart`

### Components (Tier 2) — 6 files
18. [ ] `lib/src/components/axes/chart_axis_config.dart` — New: `OiChartAxisConfig`
19. [ ] `lib/src/components/legend/chart_legend.dart` — New: `OiChartLegend`, `OiChartLegendItem` (uses `OiLabel` + `OiRow`)
20. [ ] `lib/src/components/tooltip/chart_tooltip.dart` — Move + refactor from `core/chart_tooltip_controller.dart`: `OiChartTooltipController`
21. [ ] `lib/src/components/crosshair/chart_crosshair.dart` — New: `OiChartCrosshair`, `OiChartCrosshairStyle`
22. [ ] `lib/src/components/annotations/chart_annotation.dart` — New: `OiChartAnnotation`, `OiChartAnnotationAxis`
23. [ ] `lib/src/components/threshold/chart_threshold.dart` — New: `OiChartThresholdBand`

### Composites (Tier 3) — Family bases — 12 files
24. [ ] `lib/src/composites/cartesian/oi_cartesian_chart.dart` — New: `OiCartesianChart`, `OiCartesianChartState`
25. [ ] `lib/src/composites/cartesian/oi_cartesian_painter.dart` — New: `OiCartesianPainter` (abstract, paints grid/axes, delegates series)
26. [ ] `lib/src/composites/polar/oi_polar_chart.dart` — New: `OiPolarChart`, `OiPolarChartState`
27. [ ] `lib/src/composites/polar/oi_polar_data.dart` — New: `OiPolarData`, `OiPolarSegment`
28. [ ] `lib/src/composites/polar/oi_polar_painter.dart` — New: `OiPolarPainter`
29. [ ] `lib/src/composites/matrix/oi_matrix_chart.dart` — New: abstract `OiMatrixChart`
30. [ ] `lib/src/composites/matrix/oi_matrix_data.dart` — New: `OiMatrixData`, `OiMatrixCell`
31. [ ] `lib/src/composites/hierarchical/oi_hierarchical_chart.dart` — New: abstract `OiHierarchicalChart`
32. [ ] `lib/src/composites/hierarchical/oi_hierarchical_data.dart` — New: `OiHierarchicalData`, `OiHierarchicalNode`
33. [ ] `lib/src/composites/flow/oi_flow_chart.dart` — New: abstract `OiFlowChart`
34. [ ] `lib/src/composites/flow/oi_flow_data.dart` — New: `OiFlowData`, `OiFlowNode`, `OiFlowLink`

### Composites (Tier 3) — Migrated charts — 11 files
35. [ ] `lib/src/composites/cartesian/line/line_chart.dart` — Move from `charts/line/`, refactor to extend `OiCartesianChart`
36. [ ] `lib/src/composites/cartesian/line/line_chart_painter.dart` — Move, refactor to extend `OiCartesianPainter`
37. [ ] `lib/src/composites/cartesian/line/line_chart_data_processor.dart` — Move (unchanged)
38. [ ] `lib/src/composites/cartesian/bar/bar_chart.dart` — Move from `charts/bar/`, refactor to extend `OiCartesianChart`
39. [ ] `lib/src/composites/cartesian/bar/bar_chart_painter.dart` — Move, refactor to extend `OiCartesianPainter`
40. [ ] `lib/src/composites/cartesian/bar/bar_chart_data_processor.dart` — Move (unchanged)
41. [ ] `lib/src/composites/cartesian/bar/bar_chart_orientation.dart` — Move (unchanged)
42. [ ] `lib/src/composites/polar/pie/pie_chart.dart` — Move from `charts/pie/`, refactor to extend `OiPolarChart`, accept `OiPolarData`
43. [ ] `lib/src/composites/polar/pie/pie_chart_painter.dart` — Move, refactor to extend `OiPolarPainter`
44. [ ] `lib/src/composites/polar/pie/pie_chart_data_processor.dart` — Move, update to use `OiPolarData`
45. [ ] `lib/src/composites/polar/pie/pie_slice.dart` — Move (unchanged)

### Modules (Tier 4) — 1 file
46. [ ] `lib/src/modules/.gitkeep` — Placeholder

### Tests — Foundation — 4 files
47. [ ] `test/src/foundation/theme/chart_theme_data_test.dart` — New: theme bridge tests
48. [ ] `test/src/foundation/scales/oi_linear_scale_test.dart` — New: linear scale tests
49. [ ] `test/src/foundation/scales/oi_band_scale_test.dart` — New: band scale tests
50. [ ] `test/src/foundation/data/chart_data_test.dart` — Move from `test/src/core/chart_data_test.dart`

### Tests — Primitives — 3 files
51. [ ] `test/src/primitives/painters/chart_painter_test.dart` — Move from `test/src/core/chart_painter_test.dart`
52. [ ] `test/src/primitives/markers/chart_marker_test.dart` — New: marker shape tests
53. [ ] `test/src/primitives/hit_testing/chart_gesture_handler_test.dart` — Move from `test/src/core/chart_gesture_handler_test.dart`

### Tests — Components — 2 files
54. [ ] `test/src/components/legend/chart_legend_test.dart` — New: legend widget tests
55. [ ] `test/src/components/tooltip/chart_tooltip_test.dart` — Move from `test/src/core/` (tooltip controller tests)

### Tests — Composites — 13 files
56. [ ] `test/src/composites/cartesian/oi_cartesian_chart_test.dart` — New: Cartesian family tests
57. [ ] `test/src/composites/polar/oi_polar_chart_test.dart` — New: Polar family tests
58. [ ] `test/src/composites/polar/oi_polar_data_test.dart` — New: Polar data contract tests
59. [ ] `test/src/composites/matrix/oi_matrix_data_test.dart` — New: Matrix data contract tests
60. [ ] `test/src/composites/hierarchical/oi_hierarchical_data_test.dart` — New: Hierarchical data tests
61. [ ] `test/src/composites/flow/oi_flow_data_test.dart` — New: Flow data contract tests
62. [ ] `test/src/composites/cartesian/line/line_chart_test.dart` — Move from `test/src/charts/line/`
63. [ ] `test/src/composites/cartesian/line/line_chart_data_processor_test.dart` — Move from `test/src/charts/line/`
64. [ ] `test/src/composites/cartesian/bar/bar_chart_test.dart` — Move from `test/src/charts/bar/`
65. [ ] `test/src/composites/cartesian/bar/bar_chart_painter_test.dart` — Move from `test/src/charts/bar/`
66. [ ] `test/src/composites/cartesian/bar/bar_chart_data_processor_test.dart` — Move from `test/src/charts/bar/`
67. [ ] `test/src/composites/polar/pie/pie_chart_test.dart` — Move from `test/src/charts/pie/`
68. [ ] `test/src/composites/polar/pie/pie_chart_data_processor_test.dart` — Move from `test/src/charts/pie/`

### Tests — Architecture — 1 file
69. [ ] `test/src/architecture/tier_import_test.dart` — New: verify no cross-tier imports, no Material/Cupertino imports

### Tests — Helpers — 1 file
70. [ ] `test/helpers/test_helpers.dart` — Update: add `pumpChart` variant that wraps in `OiApp` (for obers_ui context), update data factories

### Files to DELETE (old structure)
71. [ ] `lib/src/core/` — Delete entire directory (9 files replaced by foundation + primitives)
72. [ ] `lib/src/charts/` — Delete entire directory (10 files replaced by composites)
73. [ ] `test/src/core/` — Delete entire directory (tests moved to foundation + primitives + components)
74. [ ] `test/src/charts/` — Delete entire directory (tests moved to composites)

### Coverage ledger
75. [ ] `COVERAGE_LEDGER.md` (project root) — Add chart-package rows for REQ-0006, REQ-0007, REQ-0008

---

## Commands to run in check phase

```bash
cd packages/obers_ui_charts && dart format --set-exit-if-changed .
cd packages/obers_ui_charts && dart analyze
cd packages/obers_ui_charts && flutter test
```

---

## Key design decisions and rationale

### 1. Rename `OiChartTheme` → `OiChartThemeData`
**Why:** Matches the main `obers_ui` convention where `OiTheme` is the InheritedWidget and `OiThemeData` is the data class. Frees up `OiChartTheme` for a potential future InheritedWidget wrapper.

### 2. `fromContext()` factory instead of InheritedWidget
**Why:** Charts used inside `OiApp` get automatic theme integration via `OiChartThemeData.fromContext(context)`. Charts used standalone (no `OiApp` ancestor) pass an explicit `theme` parameter. This avoids a mandatory `OiChartTheme` ancestor widget, keeping the package flexible.

### 3. Keep `OiChartData`/`OiChartSeries` for Cartesian, new types for other families
**Why:** The existing data model (`OiDataPoint` with x/y, `OiChartSeries` with points) maps naturally to Cartesian charts. Polar, Matrix, Hierarchical, and Flow families have fundamentally different data shapes, so they get purpose-built contracts (e.g., `OiPolarSegment` with label/value, `OiFlowNode`/`OiFlowLink`).

### 4. Template method pattern for family painters
**Why:** `OiCartesianPainter.paint()` calls `paintGrid()` → `paintSeries()` → `paintAxes()`, where `paintSeries()` is abstract. This ensures all Cartesian charts get consistent grid and axis rendering while only implementing their unique series visualization.

### 5. `OiSurface` as container, not `OiApp`
**Why:** Charts should be embeddable in any widget tree. Using `OiSurface` as the outermost wrapper provides themed background/border without requiring `OiApp` as a direct parent (as long as `OiTheme` ancestor exists somewhere above).

### 6. Scale classes instead of inline math
**Why:** `OiLinearScale` and `OiBandScale` encapsulate domain→range mapping, tick generation, and inversion. This replaces the scattered inline calculations in `mapDataToPixel()` and makes coordinate systems reusable across all charts in a family.

### 7. Components as config classes + widgets
**Why:** Tier 2 components like `OiChartCrosshair`, `OiChartAnnotation`, `OiChartThresholdBand` are config classes (not full widgets) because they're rendered as part of the chart canvas. `OiChartLegend` and `OiChartTooltip` are widgets because they exist outside the canvas layer.

### 8. Family base State class handles build()
**Why:** `OiCartesianChartState.build()` constructs the `OiSurface` → `LayoutBuilder` → `GestureDetector` → `CustomPaint` tree, resolves theme, and manages tooltip state. Concrete charts only override `createSeriesPainter()`. This maximizes code sharing within a family.

---

## Potential risks with mitigation

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Pie chart data migration (OiChartData → OiPolarData) breaks tests | Medium | Medium | Create OiPolarData.fromChartData() converter for gradual migration; update tests simultaneously |
| OiSurface requires OiTheme ancestor | Medium | High | Family base `resolveTheme()` uses `OiTheme.maybeOf(context)` — if null, falls back to `OiChartThemeData.light()` and wraps in plain `DecoratedBox` instead of `OiSurface` |
| Import path changes break existing consumers | Low | Low | Package is `publish_to: none`; barrel file re-exports all public types from new locations |
| Architecture test false positives on transitive imports | Low | Low | Test scans direct imports only (first-party `src/` paths), not transitive Flutter SDK imports |
| OiLabel in legend adds unwanted interactivity (copy-on-tap) | Low | Low | Use OiLabel with explicit `copyable: false` or use the appropriate variant |

---

## Cross-atom dependencies

### Shared state between atoms
- **REQ-0006 and REQ-0007** share the theme system: the 5-tier structure (REQ-0006) places `OiChartThemeData` in Tier 0, and `fromContext()` (REQ-0007) bridges to `obers_ui` primitives. Both must be implemented together.
- **REQ-0006 and REQ-0008** share the composites tier: the 5-tier structure (REQ-0006) defines Tier 3, and the family base classes (REQ-0008) live in Tier 3.
- **REQ-0007 and REQ-0008** share the widget wrapping: `OiSurface` usage (REQ-0007) happens in the family base `build()` methods (REQ-0008).

### Ordering constraints
1. **Foundation (REQ-0006) first**: Data models and theme bridge must exist before anything else references them.
2. **obers_ui dependency (REQ-0007) first**: `pubspec.yaml` must add the dependency before any code can import `OiSurface`, `OiLabel`, etc.
3. **Primitives (REQ-0006) second**: Base painter and hit testing move before composites can extend them.
4. **Components (REQ-0006) third**: Legend and tooltip must exist before family bases compose them.
5. **Family bases (REQ-0008) fourth**: Base classes must exist before migrating existing charts.
6. **Chart migration (REQ-0008) fifth**: Existing charts refactored after family bases are ready.
7. **Barrel file + cleanup last**: After all code is in place, update exports and delete old directories.

### Files serving multiple atoms
| File | Atoms | Why |
|------|-------|-----|
| `pubspec.yaml` | REQ-0006, REQ-0007 | Enables both package structure and obers_ui dependency |
| `foundation/theme/chart_theme_data.dart` | REQ-0006, REQ-0007 | Lives in tier 0 (REQ-0006), bridges to OiThemeData (REQ-0007) |
| `composites/cartesian/oi_cartesian_chart.dart` | REQ-0006, REQ-0007, REQ-0008 | Lives in tier 3 (REQ-0006), uses OiSurface (REQ-0007), implements Cartesian family (REQ-0008) |
| `components/legend/chart_legend.dart` | REQ-0006, REQ-0007 | Lives in tier 2 (REQ-0006), uses OiLabel (REQ-0007) |
| `obers_ui_charts.dart` | REQ-0006, REQ-0008 | Export structure reflects tiers (REQ-0006) and family organization (REQ-0008) |
