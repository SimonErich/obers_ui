We want to extend our obers_ui flutter uikit library with a fully fledged out, extrememly capable, configurable, accessible and performant UI library with great developer experience. What I want you to do now is take the concept attached and check it against our existing concepts @base_concept.md and @AI_README.md (this is our specific implementation of base concept. If there are difference in naming, structures, AI_README.md has precedence as the real implementation) to make sure we really create a unified dev experience following similar patterns, naming conventions and overall have an amazing chart library, that is as configurable as possible, supports a great dev experience and also is really thought out. What I want you to do right now is message by message start by providing details about the overall architecture, concepts and connected structures for this obers_ui module. Then define the structure, contracts/interfaces and types we will need to create this, then I want you to create a summarized list of all charts we are going to build and definitions of what basic chart types they are based on or how they will be architectured. And then I want you to go into detail for every single chart type we have and in one message each explain \* how it looks, features and important infos \* how it is guaranteed, that data input is as easy and logical for developers as possible and ideally as similar to other \* the overall structure, the api/props/callbacks \* how it will be customized (in accordance with our global obers_ui configuration and theming \* then how it can be themed and configured on an element basis \* how each logic works and how exactly it will be implemented, things to consider \* how performance is guaranteed even with huge datasets \* how interactivity works and can be configured/adjusted \* how legend, additional information is implemented \* how accessibility is guaranteed \* Every single extensive test we need to make sure the chart is fully tested and works as expected Always make sure, that we adhere 100% to the same very nice and readable and declarative apis as in our normal concept and that everything feels like one big convention and package. Try to sound similar, be declarative and make sure the developer experience is up to its best with easy to add data and data that is easy to read, to create from different sources and easy to understand. Now please go ahead and start with the first part. Whenever I tell you "continue" or "continue" + something else, go to the next part (ignore the something else and just consider it as "continue") until you are fully done. When you have nothing else to say, just tell me "nothing to add" even if I ask you multiple times to continue.


!! Important: This should not be part of the default obers_ui package, but should be a separate package inside of the same repository but in a packages folder @packages/obers_ui_charts as a separate flutter package. Use the same conventions, code structures, analysis rules, ... as with the main package  !!!

Also make sure to create enough tests, write the code in the cleanest way possible with small, atomic widgets and services and make sure to make sure we have 0 warnings, 0 errors, 0 infos in linting and run all tests successfully after implementing!!

I'm aligning the chart concept against your real obers_ui conventions first, then I'll give you only Part 1: the architecture and connected structures, written to feel like the rest of the package.

I've got the key alignment points now. The main tension is that the chart concept wants a very capable visualization system, while obers_ui's actual implementation strongly prefers clear tiering, typed theme integration, optional persistence, and declarative APIs over giant monolithic configs.

Thought for 15s

Absolutely - I'll start with **Part 1: the overall architecture, concepts, and connected structures for the obers_ui charting module**, aligned to your current real implementation conventions, with **AI_README taking precedence** over base_concept where they differ. That precedence matters here because AI_README defines the actual package language: strict tiering, Oi naming, theme-driven styling, accessibility requirements, and "prefer existing obers_ui patterns over inventing parallel ones."

## **Part 1 - Overall architecture, concepts, and connected structures for the charting module**

### **1\. Core architectural decision**

The chart system should **not** be designed as one giant "chart engine widget" with endless config. That would clash with obers_ui's real package direction, which is explicitly tiered, compositional, declarative, and based on readable props instead of opaque mega-objects. AI_README is very clear that the library is structured into Foundation, Primitives, Components, Composites, and Modules, and that each tier composes from the one below it.

So the chart library should be introduced as a **full visualization subsystem** with the same layered philosophy:

- **Tier 0: chart foundation**
- **Tier 1: chart primitives**
- **Tier 2: chart components**
- **Tier 3: chart composites**
- **Tier 4: chart modules**

This matches how obers_ui already thinks about tables, overlays, responsive systems, file explorer, and other complex features: not as isolated widgets, but as ecosystems with shared contracts, theme hooks, state models, and persistence. The existing architecture already treats persistence and responsive behavior as cross-cutting infrastructure, which is exactly how charts should be handled too.

### **2\. Position of charts inside obers_ui**

Right now AI_README already exposes visualization composites like OiHeatmap, OiRadarChart, OiFunnelChart, OiGauge, OiTreemap, and OiSankey. That means charts are already conceptually a **Tier 3 composite family**, not random primitives.

That has an important implication:

**We should not treat every chart as a standalone bespoke widget with its own unrelated API.  
**Instead, we should build a **shared chart substrate** underneath those composites, so every chart feels like it belongs to the same package in the same way OiTable, OiListView, OiFilterBar, and persistence drivers do.

So the right mental model is:

- **chart foundation** provides tokens, scales, behaviors, theming, accessibility, persistence contracts
- **chart primitives** provide axes, legends, layers, gestures, canvas regions, tooltip anchors, series render contracts
- **chart components** provide reusable building blocks like legends, crosshairs, tooltips, zoom behavior, annotations, thresholds
- **chart composites** provide actual charts: line, area, bar, pie, scatter, heatmap, radar, sankey, treemap, funnel, gauge, etc.
- **chart modules** provide higher-level assembled experiences like dashboards, KPI boards, synced analytic views, explorer-style data workspaces

That keeps the public API clean while still allowing very deep capability.

### **3\. What the external API philosophy should be**

Your attached chart analysis is correct that the best systems converge around three ideas:

- declarative config
- composable interactivity
- decoupling data from presentation

It also explicitly recommends a **Syncfusion-style mapper model** as the primary Flutter pattern, with optional simpler field references and a higher-level encoding layer. It also strongly recommends composable behavior objects instead of monolithic interaction configs, first-class mixed-series support, built-in decimation, extension hooks, and generated accessibility descriptions.

That maps very well to obers_ui.

So the chart API philosophy should be:

#### **A. Data-first, not renderer-first**

Developers should bring their own data models. The chart maps onto them.  
No forced List&lt;Spot&gt;-style data shape as the primary pattern.

#### **B. Series are declarative children or series configs**

Like the strongest UI libraries, the parent chart defines the coordinate system and layout; series declare what they render inside it.

#### **C. Behaviors are independent objects**

Tooltip, zoom, pan, selection, brush, hover sync, crosshair, annotations, and keyboard navigation should be attached independently, not nested into one monster interaction prop. This is directly supported by the attached analysis and aligns with obers_ui's preference for composable structures.

#### **D. Readable English props**

Base concept and AI_README repeatedly favor "props read like English." The chart system must follow that exactly. Not cfg, opts, enc, ctx, plt. Use things like:

- xAxis
- yAxis
- series
- legend
- selectionMode
- showGrid
- syncGroup
- persistViewState
- emptyState
- loadingState

That is core obers_ui language.

### **4\. Recommended subsystem structure**

This is the structure I would recommend for the charting module so it feels native to obers_ui:

src/  
foundation/  
charts/  
oi_chart_theme_data.dart  
oi_chart_tokens.dart  
oi_chart_defaults.dart  
oi_chart_behavior.dart  
oi_chart_scale.dart  
oi_chart_formatters.dart  
oi_chart_accessibility.dart  
oi_chart_settings.dart  
oi_chart_sync_registry.dart  
<br/>primitives/  
charts/  
oi_chart_surface.dart  
oi_chart_viewport.dart  
oi_chart_canvas.dart  
oi_chart_layer.dart  
oi_chart_axis_line.dart  
oi_chart_tick_line.dart  
oi_chart_grid.dart  
oi_chart_plot_band.dart  
oi_chart_marker.dart  
oi_chart_label.dart  
oi_chart_anchor.dart  
oi_chart_hit_region.dart  
<br/>components/  
charts/  
oi_chart_axis.dart  
oi_chart_legend.dart  
oi_chart_tooltip.dart  
oi_chart_crosshair.dart  
oi_chart_brush.dart  
oi_chart_zoom_controls.dart  
oi_chart_annotation.dart  
oi_chart_threshold.dart  
oi_chart_empty_state.dart  
oi_chart_loading_state.dart  
oi_chart_series_toggle.dart  
<br/>composites/  
visualization/  
oi_cartesian_chart.dart  
oi_polar_chart.dart  
oi_hierarchical_chart.dart  
oi_flow_chart.dart  
<br/>oi_line_chart.dart  
oi_area_chart.dart  
oi_bar_chart.dart  
oi_scatter_chart.dart  
oi_bubble_chart.dart  
oi_combo_chart.dart  
<br/>oi_pie_chart.dart  
oi_donut_chart.dart  
oi_radar_chart.dart  
oi_radial_bar_chart.dart  
oi_gauge.dart  
<br/>oi_heatmap.dart  
oi_treemap.dart  
oi_sankey.dart  
oi_funnel_chart.dart  
<br/>modules/  
oi_analytics_dashboard.dart  
oi_chart_explorer.dart  
oi_kpi_board.dart

This keeps current public composites valid while giving them a shared internal engine.

### **5\. Foundational concepts the whole chart system should share**

There are a handful of concepts that should exist once and be reused everywhere.

#### **5.1 OiChartSurface**

Every chart needs the same visual shell philosophy as the rest of obers_ui.  
It should be built on OiSurface, inherit theme tokens, and optionally provide:

- card-like presentation
- compact embedded presentation
- frosted/soft variants if the package uses them elsewhere
- hover/focus/selection visual state where relevant

That preserves visual consistency with OiCard, OiTable, and the rest of the library. AI_README is explicit that colors come from theme and visual containers flow through obers_ui primitives.

#### **5.2 OiChartViewport**

Every serious chart needs a normalized concept of:

- plot bounds
- padding
- axis insets
- transformed visible domain
- device pixel ratio handling
- interaction coordinate conversion

This becomes the shared geometry contract across all charts.

#### **5.3 OiChartBehavior**

This is one of the most important architectural decisions.  
Your attached spec correctly notes that composable behavior objects are better than monolithic interaction config. So every chart should attach reusable behaviors like:

- OiTooltipBehavior
- OiCrosshairBehavior
- OiZoomPanBehavior
- OiSelectionBehavior
- OiBrushBehavior
- OiHoverSyncBehavior
- OiKeyboardExploreBehavior

This gives you extremely deep capability while keeping each chart API readable.

#### **5.4 OiChartSettings + persistence**

Charts should plug into the existing persistence-driver philosophy, not invent a separate storage system. Base concept already defines an opt-in, typed, key-based, mergeable persistence architecture through OiSettingsDriver, OiSettingsData, and OiSettingsMixin.

Charts should reuse this for things like:

- visible series
- selected range
- zoom window
- sort/group mode inside analytic views
- legend collapsed state
- user-pinned thresholds
- comparison mode toggles

That means charts immediately feel like first-class obers_ui citizens.

#### **5.5 OiChartSyncRegistry**

Your attached analysis calls out Recharts syncId-style synchronization as a major strength. obers_ui should support that natively through a typed sync mechanism rather than ad hoc callbacks.

Example concept:

- multiple charts share syncGroup: 'sales-overview'
- hover on one chart updates tooltip/crosshair on siblings
- zoom/brush optionally syncs
- keyboard exploration can sync focus points too

This is especially important for dashboard modules.

### **6\. The chart family taxonomy**

A major mistake would be to make every chart type a completely different architecture.  
Instead, charts should belong to a few structural families:

#### **A. Cartesian charts**

Shared x/y coordinate system:

- line
- area
- bar
- scatter
- bubble
- combo
- histogram
- waterfall
- box plot
- candlestick / OHLC later

These should all build on a common OiCartesianChart.

#### **B. Polar / radial charts**

Shared radial coordinate system:

- pie
- donut
- radar
- radial bar
- gauge

These should build on OiPolarChart.

#### **C. Hierarchical charts**

Shared tree / nesting data model:

- treemap
- sunburst later

These should build on OiHierarchicalChart.

#### **D. Flow charts**

Directed weighted relationships:

- sankey
- funnel partly
- pipeline-style flow derivatives

#### **E. Matrix / density charts**

Cell-based quantitative layouts:

- heatmap
- calendar heatmap later

This family approach gives consistency in data contracts, interactions, and theming.

### **7\. How this should align with existing obers_ui conventions**

There are several very specific alignment rules that matter.

#### **7.1 Naming**

Everything public gets Oi prefix.  
AI_README and base concept are absolute on that.

So:

- OiChartLegend, not ChartLegend
- OiCartesianChart, not CartesianPlot
- OiChartThemeData, not ChartTheme
- OiChartSeries, not Dataset

#### **7.2 Theme access**

No hardcoded colors.  
Charts must read from context.colors, context.spacing, context.radius, context.components, and chart-specific theme extensions. AI_README is explicit on this.

#### **7.3 Accessibility**

Charts must go beyond common chart libraries here. Your attached analysis explicitly says accessibility is weak across the ecosystem and that no library really solves keyboard point exploration well. It recommends auto-generated accessibility descriptions and keyboard navigation. That should become a core obers_ui differentiator.

#### **7.4 Responsive behavior**

Base obers_ui treats responsiveness as first-class, not optional. The chart analysis specifically calls out that most chart libraries do this badly. So the chart subsystem should integrate with:

- existing breakpoints
- density
- reduced motion
- touch vs pointer modality
- container-relative adaptation

That is much more on-brand for obers_ui than "just scale to fit."

#### **7.5 Performance**

obers_ui already values virtualization, bounded rendering, and explicit performance architecture in other systems. Charts should adopt the same seriousness:

- decimation
- progressive rendering
- level-of-detail rendering
- hit-test indexing
- cached text layout
- retained geometry where possible

Your attached chart document explicitly recommends built-in decimation and progressive rendering from day one.

### **8\. The biggest corrections I would make to the chart concept**

From the alignment perspective, these are the most important architecture corrections.

#### **Correction 1: do not make charts "special"**

They should use the same system language as the rest of obers_ui:

- theme scopes
- settings drivers
- OiResponsive
- component themes
- label / semanticLabel
- behavior objects
- factory constructors where useful

#### **Correction 2: do not use library-inspired naming too literally**

The attached chart study is great for capability analysis, but names like trace, dataset, encoding, container, markerContext, axisResolver, plotArea should only be adopted if they fit obers_ui's tone. In many cases:

- series is better than trace
- label is better than titleText
- behavior is better than plugin for public API
- variant is better than arbitrary mode enums

#### **Correction 3: mixed-series support must be foundational**

The attached analysis is right that fl_chart-style single-type widgets are a dead end for a serious library. OiCartesianChart must support multiple series types in one shared coordinate system from the start.

#### **Correction 4: data binding must stay simple**

The analysis strongly favors mapper-based binding plus optional field-reference shorthand. That is the correct choice here. Flutter developers should be able to pass real domain models directly.

#### **Correction 5: chart theming must be native to obers_ui**

The analysis also points out that many chart libs have weak host-theme integration. obers_ui should not repeat that mistake. Chart colors, typography, borders, hover states, halo/focus treatments, and surfaces should all derive from the main theme system.

### **9\. Recommended high-level public architecture**

If I compress the whole direction into one package rule set, it would be this:

#### **Public entry points**

Developers mostly use:

- OiLineChart&lt;T&gt;
- OiAreaChart&lt;T&gt;
- OiBarChart&lt;T&gt;
- OiScatterChart&lt;T&gt;
- OiPieChart&lt;T&gt;
- OiDonutChart&lt;T&gt;
- OiRadarChart&lt;T&gt;
- OiHeatmap&lt;T&gt;
- OiTreemap&lt;T&gt;
- OiSankey&lt;T&gt;
- OiGauge

For more advanced use:

- OiCartesianChart&lt;T&gt;
- OiPolarChart&lt;T&gt;
- OiHierarchicalChart&lt;T&gt;

#### **Shared supporting objects**

- OiChartAxis
- OiChartLegend
- OiChartTooltip
- OiChartAnnotation
- OiChartThreshold
- OiChartBehavior
- OiChartThemeData
- OiChartSettings

#### **Internal engine contracts**

- viewport
- scale
- series renderer
- hit-testing
- label layout
- interaction dispatch
- sync/persistence

That gives a progressive API:  
simple for normal use, deep for expert use.

### **10\. Final architectural recommendation for Part 1**

So the best overall architecture is:

**A charting subsystem that behaves like obers_ui, not like a wrapped third-party chart package.**

It should:

- live inside the same tiered architecture as the rest of the library
- expose charts as Tier 3 composites, backed by shared lower-level chart infrastructure
- use mapper-first data binding with optional higher-level shorthand, as recommended by the chart analysis
- make interactions composable through behavior objects, not giant nested config blobs
- integrate with existing obers_ui theme, responsive, accessibility, and persistence systems
- support mixed-series charts as a first-class foundation, not an afterthought
- treat accessibility and responsive simplification as core differentiators because the broader chart ecosystem is weak there

That is the architecture that will make the chart library feel like **one big convention and package**, instead of an impressive but foreign sub-library bolted onto obers_ui.

When you say **continue**, I'll move to **Part 2: the exact structure, contracts/interfaces, and types we need**.

continue 1

I'm moving into the concrete contract layer now: shared chart types, renderer boundaries, data mapping, behaviors, theming, and the internal interfaces that keep every chart consistent.

Thought for 6s

## **Part 2 - Structure, contracts, interfaces, and types for the obers_ui chart system**

Now we move from architecture to the concrete contract layer.

The goal here is not just to define enough types to make charts work. The goal is to define them in a way that makes every chart in obers_ui feel like it belongs to the same package: typed, declarative, readable, theme-aware, responsive, accessible, and composable. That direction is fully consistent with AI_README's real implementation rules: use the tier hierarchy, keep naming under Oi\*, use theme-derived values, avoid ad hoc patterns, and make accessibility mandatory.

It also needs to reflect the strongest architectural lessons from the chart analysis: mapper-first binding, composable behaviors, chart-type mixing, plugin-style extension hooks, built-in decimation, and generated accessibility support.

### **1\. The contract philosophy**

The chart API should follow five rules everywhere.

#### **1.1 One shared mental model**

A developer should not need to relearn charting for every chart type. Cartesian, polar, matrix, and flow charts will differ, but their contracts should still feel obviously related:

- same naming
- same theming pattern
- same behavior attachment pattern
- same legend model
- same annotation model
- same formatter model
- same accessibility pattern
- same persistence pattern

#### **1.2 Domain-model-friendly data input**

The chart study is very clear that a Flutter chart spec should not force users into a library-owned point model. Mapper functions should be primary, with shorthand where appropriate.

So obers_ui should prefer:

- data: sales
- x: (item) => item.date
- y: (item) => item.revenue

and only internally convert to normalized plotted data.

#### **1.3 Shared renderer boundary**

Charts should expose high-level composites publicly, but internally every series should compile into a normalized renderer contract. This is what allows:

- mixed series in one chart
- shared tooltip systems
- synchronized hit testing
- shared accessibility summaries
- consistent animations
- extensibility

#### **1.4 Behaviors are first-class contracts**

The analysis recommends Syncfusion's behavior-object model as the primary interaction pattern. That should become a core public convention.

#### **1.5 Settings and persistence are opt-in and typed**

This should mirror the existing settings architecture exactly: opt-in, keyed, driver-based, typed, mergeable, and testable.

## **2\. Recommended package structure**

This is the concrete type layout I would recommend.

foundation/charts/  
oi_chart_theme_data.dart  
oi_chart_defaults.dart  
oi_chart_tokens.dart  
oi_chart_scale.dart  
oi_chart_domain.dart  
oi_chart_viewport.dart  
oi_chart_behavior.dart  
oi_chart_interaction.dart  
oi_chart_animation.dart  
oi_chart_accessibility.dart  
oi_chart_formatters.dart  
oi_chart_settings.dart  
oi_chart_sync.dart  
oi_chart_extension.dart  
<br/>primitives/charts/  
oi_chart_canvas.dart  
oi_chart_layer.dart  
oi_chart_hit_test.dart  
oi_chart_marker.dart  
oi_chart_anchor.dart  
oi_chart_label_painter.dart  
oi_chart_grid_painter.dart  
oi_chart_axis_painter.dart  
<br/>components/charts/  
oi_chart_axis.dart  
oi_chart_legend.dart  
oi_chart_tooltip.dart  
oi_chart_crosshair.dart  
oi_chart_brush.dart  
oi_chart_zoom_controls.dart  
oi_chart_annotation.dart  
oi_chart_threshold.dart  
oi_chart_empty_state.dart  
oi_chart_loading_state.dart  
oi_chart_series_toggle.dart  
<br/>composites/charts/  
oi_cartesian_chart.dart  
oi_polar_chart.dart  
oi_hierarchical_chart.dart  
oi_matrix_chart.dart  
oi_flow_chart.dart  
<br/>series/  
oi_chart_series.dart  
oi_line_series.dart  
oi_area_series.dart  
oi_bar_series.dart  
oi_scatter_series.dart  
oi_bubble_series.dart  
oi_candlestick_series.dart  
oi_boxplot_series.dart  
oi_pie_series.dart  
oi_radar_series.dart  
oi_heatmap_series.dart  
oi_sankey_series.dart  
oi_treemap_series.dart

This follows the real obers_ui tier philosophy instead of letting charting become a parallel universe. AI_README explicitly requires using the tier system and not inventing unrelated structures.

## **3\. The root public chart contracts**

### **3.1 OiChartWidget**

This is not necessarily the widget users instantiate directly, but it is the common base contract for all chart composites.

abstract class OiChartWidget extends StatefulWidget {  
final String? label;  
final String? semanticLabel;  
final OiChartThemeData? theme;  
final OiChartLegendConfig? legend;  
final List&lt;OiChartBehavior&gt; behaviors;  
final List&lt;OiChartAnnotation&gt; annotations;  
final List&lt;OiChartThreshold&gt; thresholds;  
final OiChartLoadingStateConfig? loadingState;  
final OiChartEmptyStateConfig? emptyState;  
final OiChartErrorStateConfig? errorState;  
final OiChartSettingsDriverBinding? settings;  
final String? syncGroup;  
final OiChartAnimationConfig? animation;  
}

This gives every chart the same outer language:

- labels
- semantic label
- local theme override
- shared legend
- shared behaviors
- shared annotations
- shared thresholds
- shared states
- optional persistence
- optional synchronization
- shared animation policy

That shared shell matters a lot for developer confidence.

### **3.2 OiChartController**

Serious charts need a controller model, like tables and explorers eventually do elsewhere in obers_ui.

class OiChartController extends ChangeNotifier {  
OiChartSelectionState selection;  
OiChartViewportState viewport;  
OiChartHoverState hover;  
OiChartLegendState legend;  
OiChartFocusState focus;  
<br/>void clearSelection();  
void resetZoom();  
void focusSeries(String seriesId);  
void toggleSeries(String seriesId);  
void setVisibleDomain(OiChartDomainX x, OiChartDomainY y);  
}

This controller should be optional. Charts work without it. But it becomes essential for:

- programmatic zoom reset
- external toolbar integration
- synchronized dashboard controls
- testability
- screen-reader exploration tools

That matches obers_ui's preference for optional but powerful state surfaces.

## **4\. Data contracts**

This is the most important design area.

### **4.1 OiChartSeries&lt;T&gt;**

Every plotted series should share a common base contract.

abstract class OiChartSeries&lt;T&gt; {  
final String id;  
final String label;  
final List&lt;T&gt; data;  
final bool visible;  
final OiSeriesStyle? style;  
final OiSeriesAnimationConfig? animation;  
final OiSeriesLegendConfig? legend;  
final String? semanticLabel;  
<br/>const OiChartSeries({  
required this.id,  
required this.label,  
required this.data,  
this.visible = true,  
this.style,  
this.animation,  
this.legend,  
this.semanticLabel,  
});  
}

This keeps all series:

- identifiable
- legend-compatible
- toggleable
- individually themeable
- animatable
- accessible

### **4.2 Mapper-first series contracts**

Per the chart analysis, mapper functions should be the first-class binding pattern.

For example:

class OiLineSeries&lt;T&gt; extends OiChartSeries&lt;T&gt; {  
final num? Function(T item)? x;  
final num? Function(T item)? y;  
final String? Function(T item)? pointLabel;  
final Object? Function(T item)? group;  
final bool Function(T item)? isMissing;  
final Color? Function(T item, OiSeriesPointContext context)? color;  
}

For time-based charts:

class OiTimeLineSeries&lt;T&gt; extends OiChartSeries&lt;T&gt; {  
final DateTime? Function(T item)? x;  
final num? Function(T item)? y;  
}

For categorical bars:

class OiBarSeries&lt;T&gt; extends OiChartSeries&lt;T&gt; {  
final String Function(T item) x;  
final num? Function(T item) y;  
final num? Function(T item)? y0;  
}

For scatter / bubble:

class OiBubbleSeries&lt;T&gt; extends OiChartSeries&lt;T&gt; {  
final num? Function(T item) x;  
final num? Function(T item) y;  
final num? Function(T item) size;  
}

This is the right balance between strong typing and developer freedom.

### **4.3 Normalized internal data model**

Public APIs should be mapper-based, but internal renderers need normalized point models.

class OiChartDatum {  
final String seriesId;  
final int index;  
final Object rawItem;  
<br/>final Object? xRaw;  
final Object? yRaw;  
final double? xScaled;  
final double? yScaled;  
<br/>final Object? colorRaw;  
final String? label;  
final bool isMissing;  
final Map&lt;String, Object?&gt; extra;  
}

Every series compiles into this kind of internal representation. That is what enables one unified:

- hit test system
- tooltip system
- accessibility narration
- animation diffing
- selection model

## **5\. Axis and domain contracts**

### **5.1 OiChartAxis**

All axis-based charts should use the same axis model.

class OiChartAxis&lt;TDomain&gt; {  
final String? label;  
final OiAxisScaleType scaleType;  
final OiAxisPosition position;  
final OiAxisFormatter&lt;TDomain&gt;? formatter;  
final OiAxisTickStrategy? ticks;  
final OiResponsive&lt;int&gt;? maxVisibleTicks;  
final bool showGrid;  
final bool showAxisLine;  
final bool showTickMarks;  
final OiAxisRange&lt;TDomain&gt;? domain;  
final OiAxisLabelOverflowBehavior overflowBehavior;  
final OiAxisTitleAlignment titleAlignment;  
}

This is important because the analysis specifically calls out the need for stronger scale systems and responsive density reduction.

### **5.2 Scale contracts**

You want a real scale system, not just a couple booleans.

enum OiAxisScaleType {  
linear,  
logarithmic,  
time,  
category,  
band,  
point,  
quantile,  
threshold,  
}

abstract class OiChartScale&lt;TDomain&gt; {  
double toPixel(TDomain value, OiChartViewport viewport);  
TDomain fromPixel(double pixel, OiChartViewport viewport);  
List&lt;TDomain&gt; buildTicks(OiAxisTickStrategy strategy);  
}

This becomes essential for:

- mixed numeric/time/category charts
- zooming
- brushing
- keyboard navigation
- annotations
- thresholds
- responsive relabeling

## **6\. Theme contracts**

AI_README is explicit that all colors should come from theme and that obers_ui uses a typed theme system rather than ad hoc local style bags.

So charts need a real extension theme, not just a few optional colors.

### **6.1 OiChartThemeData**

class OiChartThemeData {  
final OiChartPalette palette;  
final OiChartAxisTheme axis;  
final OiChartGridTheme grid;  
final OiChartLegendTheme legend;  
final OiChartTooltipTheme tooltip;  
final OiChartCrosshairTheme crosshair;  
final OiChartAnnotationTheme annotation;  
final OiChartSelectionTheme selection;  
final OiChartStateTheme states;  
final OiChartMotionTheme motion;  
final OiChartDensityTheme density;  
}

### **6.2 Palette contract**

class OiChartPalette {  
final List&lt;Color&gt; categorical;  
final Color positive;  
final Color negative;  
final Color neutral;  
final Color highlight;  
final Gradient? sequentialGradient;  
final Gradient? divergingGradient;  
}

This should default from context.colors, not from hardcoded constants. That directly follows AI_README's "all colors from theme" rule.

### **6.3 Per-series theme overrides**

Series should still allow element-level overrides, but always in the same layered pattern:

- global theme
- chart-local theme
- series style
- point-level callback override

That layering is cleaner than random ad hoc precedence.

## **7\. Behavior contracts**

This is the area where the chart subsystem can become especially strong.

The chart analysis explicitly recommends behavior objects as the best primary model for Flutter.

### **7.1 Base behavior**

abstract class OiChartBehavior {  
const OiChartBehavior();  
<br/>void attach(OiChartBehaviorContext context);  
void detach(OiChartBehaviorContext context);  
<br/>void onPointerEvent(PointerEvent event, OiChartBehaviorContext context) {}  
void onKeyEvent(KeyEvent event, OiChartBehaviorContext context) {}  
void onSelectionChanged(OiChartSelectionState selection, OiChartBehaviorContext context) {}  
void onViewportChanged(OiChartViewportState viewport, OiChartBehaviorContext context) {}  
}

### **7.2 Behavior context**

class OiChartBehaviorContext {  
final BuildContext buildContext;  
final OiChartController controller;  
final OiChartViewport viewport;  
final OiChartHitTester hitTester;  
final OiChartThemeData theme;  
final OiChartSyncCoordinator? sync;  
final OiChartAccessibilityBridge accessibility;  
}

### **7.3 First built-in behaviors**

These should exist from the beginning:

- OiTooltipBehavior
- OiCrosshairBehavior
- OiZoomPanBehavior
- OiSelectionBehavior
- OiBrushBehavior
- OiKeyboardExploreBehavior
- OiHoverSyncBehavior
- OiSeriesToggleBehavior

These become reusable across almost every chart type.

## **8\. Legend contracts**

Legend APIs are often messy in chart libraries. obers_ui should unify them.

class OiChartLegendConfig {  
final bool show;  
final OiLegendPosition position;  
final OiLegendWrapBehavior wrapBehavior;  
final bool allowSeriesToggle;  
final bool allowExclusiveFocus;  
final Widget Function(BuildContext, OiLegendItem)? itemBuilder;  
}

class OiLegendItem {  
final String seriesId;  
final String label;  
final Color color;  
final OiLegendMarkerShape markerShape;  
final bool visible;  
final bool emphasized;  
}

This makes legends:

- themable
- interactive
- replaceable with builders
- consistent across all chart types

## **9\. Tooltip and overlay contracts**

The base concept shows that obers_ui already prefers a centralized overlay system through OiOverlays, instead of fragmented overlay handling. Charts should integrate with that instead of inventing their own tooltip infrastructure.

### **9.1 Tooltip config**

class OiChartTooltipConfig {  
final bool enabled;  
final OiTooltipTriggerMode triggerMode;  
final OiTooltipAnchorMode anchorMode;  
final Duration showDelay;  
final Duration hideDelay;  
final Widget Function(BuildContext, OiChartTooltipModel)? builder;  
}

### **9.2 Tooltip model**

class OiChartTooltipModel {  
final Offset globalPosition;  
final List&lt;OiTooltipEntry&gt; entries;  
final String? title;  
final String? footer;  
}

Tooltips should render through OiOverlays when floating, or inline in constrained modes.

That keeps charts aligned with the rest of the package.

## **10\. Accessibility contracts**

The chart analysis is blunt here: accessibility is weak across the whole chart ecosystem, and generated descriptions plus keyboard point exploration are key opportunities.

obers_ui should take that seriously.

### **10.1 Base accessibility model**

class OiChartAccessibilityConfig {  
final bool enabled;  
final bool generateSummary;  
final bool exposeDataTable;  
final bool enableKeyboardExploration;  
final OiChartSemanticVerbosity verbosity;  
final String Function(OiChartAccessibilitySummary summary)? summaryBuilder;  
}

### **10.2 Accessibility summary**

class OiChartAccessibilitySummary {  
final String chartType;  
final List&lt;String&gt; seriesLabels;  
final String? xAxisLabel;  
final String? yAxisLabel;  
final Object? minX;  
final Object? maxX;  
final num? minY;  
final num? maxY;  
final List&lt;OiDetectedChartInsight&gt; insights;  
}

### **10.3 Keyboard exploration contract**

Every point-based chart should support:

- arrow keys move nearest logical point
- up/down switch series where applicable
- home/end jump to bounds
- enter/space toggle selection
- escape clear selection
- narrated value announcement

This should be implemented through OiKeyboardExploreBehavior, not chart-specific ad hoc code.

That would be a real differentiator.

## **11\. Animation contracts**

The chart analysis shows that different libraries are strong in different animation dimensions: implicit transitions are elegant, per-series timing is useful, and per-property animation is powerful.

For obers_ui, the right API is a layered compromise.

class OiChartAnimationConfig {  
final bool enabled;  
final Duration duration;  
final Curve curve;  
final OiChartEnterAnimation enter;  
final OiChartUpdateAnimation update;  
final OiChartExitAnimation exit;  
final bool respectReducedMotion;  
}

And then optional series-level override:

class OiSeriesAnimationConfig {  
final Duration? duration;  
final Duration? delay;  
final Curve? curve;  
}

This stays readable while still being expressive.

Also, it must integrate with OiApp's reduced motion and performance config behavior. base_concept already requires reduced-motion propagation and performance-based degradation at the app level.

## **12\. Performance contracts**

This has to be designed into the contracts, not patched later.

The chart analysis explicitly recommends built-in decimation and progressive rendering from day one, and notes that no Flutter library really solves this well.

### **12.1 OiChartPerformanceConfig**

class OiChartPerformanceConfig {  
final OiChartRenderMode renderMode;  
final OiChartDecimationStrategy decimation;  
final int progressiveChunkSize;  
final int maxInteractivePoints;  
final bool cacheTextLayout;  
final bool cachePaths;  
final bool simplifyOffscreenGeometry;  
}

### **12.2 Render mode**

enum OiChartRenderMode {  
auto,  
quality,  
balanced,  
performance,  
}

### **12.3 Decimation strategy**

enum OiChartDecimationStrategy {  
none,  
minMax,  
lttb,  
adaptive,  
}

This should align with the existing obers_ui mindset that performance behavior is a first-class app concern and can adapt by device tier.

## **13\. Settings and persistence contracts**

This should directly follow the existing obers_ui persistence architecture:

- opt-in
- keyed
- typed
- driver-based
- mergeable
- async-friendly

### **13.1 OiChartSettings**

class OiChartSettings {  
final Set&lt;String&gt; hiddenSeriesIds;  
final OiPersistedViewport? viewport;  
final OiPersistedSelection? selection;  
final Map&lt;String, bool&gt; expandedLegendGroups;  
final String? activeComparisonMode;  
<br/>Map&lt;String, dynamic&gt; toJson();  
factory OiChartSettings.fromJson(Map&lt;String, dynamic&gt; json);  
OiChartSettings merge(OiChartSettings? other);  
}

### **13.2 driver binding**

class OiChartSettingsDriverBinding {  
final OiSettingsDriver&lt;OiChartSettings&gt; driver;  
final String? key;  
final bool autoSave;  
final bool restoreOnInit;  
}

Do not invent a chart-only persistence system. Reuse the existing driver contract.

## **14\. Extension and plugin lifecycle contracts**

The chart analysis highlights plugin lifecycle richness as a major differentiator.

obers_ui should not expose a giant unsafe plugin system publicly at first, but it should have a structured extension model.

abstract class OiChartExtension {  
const OiChartExtension();  
<br/>void beforeLayout(OiChartExtensionContext context) {}  
void afterLayout(OiChartExtensionContext context) {}  
void beforePaint(Canvas canvas, OiChartExtensionContext context) {}  
void afterPaint(Canvas canvas, OiChartExtensionContext context) {}  
void beforeHitTest(OiChartExtensionContext context) {}  
void afterHitTest(OiChartExtensionContext context) {}  
void onEvent(PointerEvent event, OiChartExtensionContext context) {}  
}

This is what future-proofs:

- custom overlays
- custom annotations
- debug views
- experimental renderers
- custom statistical guides

## **15\. Shared family-specific base contracts**

To avoid every chart reinventing structure, define family-level bases.

### **15.1 Cartesian**

class OiCartesianChart&lt;T&gt; extends OiChartWidget {  
final OiChartAxis xAxis;  
final List&lt;OiChartAxis&gt; yAxes;  
final List&lt;OiCartesianSeries<T&gt;> series;  
}

### **15.2 Polar**

class OiPolarChart&lt;T&gt; extends OiChartWidget {  
final OiPolarAngleAxis angleAxis;  
final OiPolarRadiusAxis radiusAxis;  
final List&lt;OiPolarSeries<T&gt;> series;  
}

### **15.3 Matrix**

class OiMatrixChart&lt;T&gt; extends OiChartWidget {  
final OiChartAxis xAxis;  
final OiChartAxis yAxis;  
final OiColorScale colorScale;  
final List&lt;OiMatrixSeries<T&gt;> series;  
}

### **15.4 Hierarchical**

class OiHierarchicalChart&lt;TNode&gt; extends OiChartWidget {  
final List&lt;TNode&gt; data;  
final String Function(TNode node) id;  
final String? Function(TNode node) parentId;  
final num Function(TNode node) value;  
final String Function(TNode node) label;  
}

### **15.5 Flow**

class OiFlowChart&lt;TNode, TLink&gt; extends OiChartWidget {  
final List&lt;TNode&gt; nodes;  
final List&lt;TLink&gt; links;  
final String Function(TNode node) nodeId;  
final String Function(TLink link) sourceId;  
final String Function(TLink link) targetId;  
final num Function(TLink link) value;  
}

This gives strong internal consistency.

## **16\. Formatter contracts**

AI_README already references shared formatting utilities. Charts should integrate with that instead of inventing isolated formatter patterns.

typedef OiAxisFormatter&lt;T&gt; = String Function(  
T value,  
OiAxisFormatContext context,  
);  
<br/>typedef OiTooltipValueFormatter = String Function(  
Object? value,  
OiTooltipFormatContext context,  
);  
<br/>typedef OiSeriesLabelFormatter&lt;T&gt; = String Function(  
T item,  
OiSeriesLabelContext context,  
);

This keeps charts aligned with the rest of the package utility layer.

## **17\. Responsive contracts**

Base concept makes responsiveness a first-class prop language across the package, not an afterthought.

Charts should follow that exact same pattern.

So many chart props should support OiResponsive&lt;T&gt;:

- legend position
- max tick count
- label rotation
- marker visibility
- axis label truncation mode
- interaction affordances
- toolbar density
- annotation visibility
- data label visibility
- mini / standard / detailed complexity mode

Example:

final OiResponsive&lt;int&gt;? maxVisibleTicks;  
final OiResponsive&lt;bool&gt;? showDataLabels;  
final OiResponsive&lt;OiLegendPosition&gt;? legendPosition;  
final OiResponsive&lt;OiChartComplexity&gt;? complexity;

This is one of the most important consistency points because the chart analysis specifically criticizes existing libraries for not adapting visual complexity to available space.

## **18\. Concrete naming rules to enforce**

To keep it native to obers_ui, I would enforce these naming conventions everywhere:

Use:

- series
- label
- semanticLabel
- theme
- behavior
- annotation
- threshold
- settings
- controller
- emptyState
- loadingState
- selectionMode
- syncGroup

Avoid as primary public API:

- trace
- dataset
- plugin for normal interactions
- opts
- config for every single object
- abbreviated mapper names
- renderer-specific terms leaking into public surface

This matters because AI_README emphasizes consistent use of existing obers_ui language rather than introducing parallel patterns.

## **19\. The minimum set of core types I would treat as mandatory**

If I reduce everything above to the essential backbone, these are the types that must exist before chart implementation begins:

### **Foundation**

- OiChartThemeData
- OiChartPerformanceConfig
- OiChartAnimationConfig
- OiChartAccessibilityConfig
- OiChartSettings
- OiChartBehavior
- OiChartScale&lt;T&gt;
- OiChartViewport
- OiChartController

### **Shared models**

- OiChartSeries&lt;T&gt;
- OiChartDatum
- OiChartAxis&lt;T&gt;
- OiChartLegendConfig
- OiChartTooltipConfig
- OiChartAnnotation
- OiChartThreshold

### **Family bases**

- OiCartesianChart&lt;T&gt;
- OiPolarChart&lt;T&gt;
- OiMatrixChart&lt;T&gt;
- OiHierarchicalChart&lt;TNode&gt;
- OiFlowChart&lt;TNode, TLink&gt;

### **First concrete series**

- OiLineSeries&lt;T&gt;
- OiAreaSeries&lt;T&gt;
- OiBarSeries&lt;T&gt;
- OiScatterSeries&lt;T&gt;
- OiPieSeries&lt;T&gt;
- OiHeatmapSeries&lt;T&gt;
- OiTreemapSeries&lt;TNode&gt;
- OiSankeySeries&lt;TNode, TLink&gt;

That is the minimum serious substrate.

## **20\. Final recommendation for Part 2**

The contracts should be designed so that charts behave like every other advanced obers_ui system:

- tiered, not monolithic
- typed, not map-driven
- declarative and readable, not config soup
- behavior-based for interactivity
- mapper-first for data input
- theme-native, not manually styled
- responsive in the same language as the rest of obers_ui
- performance-aware from the first interface, not later
- accessibility-first, especially where the chart ecosystem is weak
- persistence-compatible with the existing settings driver system

This is the contract layer that will let every future chart type feel like the same package, not like separate mini-libraries.

When you say **continue**, I'll move to **Part 3: the summarized list of all chart types we should build, grouped by family, and what architectural base each one should use**.

continue 2

I'm at the chart inventory step now: grouping the full library into families, deciding what belongs in the initial serious scope, and making sure each chart inherits from the right shared base instead of becoming a one-off.

Thought for 10s

## **Part 3 - Summarized chart inventory, grouped by family, with the architectural base each one should use**

Now we define the actual chart catalog.

The goal here is not "every chart type imaginable." The goal is a **serious, coherent, product-grade chart library** that covers the real visualization surface teams actually need, while still staying aligned with obers_ui's package conventions and existing inventory. Your current implementation already lists OiFunnelChart, OiGauge, OiHeatmap, OiRadarChart, OiSankey, and OiTreemap as composites, so the chart roadmap needs to absorb those as first-class citizens rather than treating them as side widgets.

At the same time, the chart analysis is very clear on priority: line/area, bar/column, scatter/bubble, pie/donut, and candlestick/OHLC cover roughly 90% of real-world usage, while chart-type mixing, behaviors, accessibility, and performance are more strategically important than having an absurdly broad long tail on day one.

So the right answer is:

- define a **full target family map**
- decide a **v1 serious scope**
- ensure every chart is built on a **shared family base**
- keep names and API style consistent with obers_ui

# **1\. The family map the library should use**

All charts should belong to one of a few architectural families.

### **A. Cartesian charts**

Charts built on an x/y coordinate system.

**Base:** OiCartesianChart&lt;T&gt;

Use for:

- line
- area
- bar / column
- stacked variants
- scatter
- bubble
- combo / composed charts
- histogram
- waterfall
- box plot
- candlestick / OHLC
- range charts
- step / spline variants

This is the most important family and should receive the strongest shared infrastructure because the analysis explicitly shows that mixing chart types inside one coordinate system is a major productivity advantage and one of the biggest weaknesses of weaker libraries.

### **B. Polar / radial charts**

Charts built around angle and radius rather than x/y.

**Base:** OiPolarChart&lt;T&gt;

Use for:

- pie
- donut
- radial bar
- radar
- polar area
- gauge

These should share a radial layout engine, label placement logic, center-content handling, and arc hit testing.

### **C. Matrix / density charts**

Charts built from cells in a 2D grid.

**Base:** OiMatrixChart&lt;T&gt;

Use for:

- heatmap
- calendar heatmap later
- matrix correlation views later

These should share cell layout, color scale handling, density legends, and cell interaction logic.

### **D. Hierarchical charts**

Charts built from nested parent-child structures.

**Base:** OiHierarchicalChart&lt;TNode&gt;

Use for:

- treemap
- sunburst later
- icicle later

These need hierarchy parsing, nesting, aggregation, and drill/navigation patterns.

### **E. Flow charts**

Charts built from nodes and weighted connections.

**Base:** OiFlowChart&lt;TNode, TLink&gt;

Use for:

- sankey
- alluvial later
- funnel in a simplified directional sense, though funnel can also stand alone visually

These need node/link layout, flow width scaling, link hit testing, and path routing.

### **F. Single-value / progress visualization**

Charts that represent one primary value or progress state rather than many plotted points.

**Base:** OiMetricChart or radial specialization of OiPolarChart

Use for:

- gauge
- radial progress
- KPI delta indicator later
- spark win/loss later if you choose

These are often embedded in dashboards and need very strong compact-mode behavior.

# **2\. The recommended scope tiers**

To keep the library coherent, I would split chart delivery into three scope levels.

## **Tier A - Core charts that should absolutely exist first**

These are the essential charts and cover the huge majority of use cases.

### **1\. OiLineChart&lt;T&gt;**

**Family:** Cartesian  
**Base:** OiCartesianChart&lt;T&gt;  
**Role:** Continuous trends over ordered numeric, time, or categorical domains.

### **2\. OiAreaChart&lt;T&gt;**

**Family:** Cartesian  
**Base:** OiCartesianChart&lt;T&gt;  
**Role:** Trend plus magnitude emphasis, including stacked area variants.

### **3\. OiBarChart&lt;T&gt;**

**Family:** Cartesian  
**Base:** OiCartesianChart&lt;T&gt;  
**Role:** Category comparison, grouped and stacked quantitative comparisons.

### **4\. OiScatterChart&lt;T&gt;**

**Family:** Cartesian  
**Base:** OiCartesianChart&lt;T&gt;  
**Role:** Relationship plotting, clustering, correlation, point clouds.

### **5\. OiBubbleChart&lt;T&gt;**

**Family:** Cartesian  
**Base:** OiCartesianChart&lt;T&gt;  
**Role:** Scatter with size as third quantitative dimension.

### **6\. OiComboChart&lt;T&gt;**

**Family:** Cartesian  
**Base:** OiCartesianChart&lt;T&gt;  
**Role:** Mixed line/area/bar/scatter in one coordinate system.

This is strategically critical because the analysis explicitly recommends chart-type mixing as first-class, not as an afterthought.

### **7\. OiPieChart&lt;T&gt;**

**Family:** Polar  
**Base:** OiPolarChart&lt;T&gt;  
**Role:** Simple part-to-whole distribution.

### **8\. OiDonutChart&lt;T&gt;**

**Family:** Polar  
**Base:** OiPolarChart&lt;T&gt;  
**Role:** Part-to-whole with center content and better label flexibility.

### **9\. OiRadarChart&lt;T&gt;**

**Family:** Polar  
**Base:** OiPolarChart&lt;T&gt;  
**Role:** Multi-axis profile comparison. Already exists in current inventory and should be rebuilt on the shared substrate.

### **10\. OiHeatmap&lt;T&gt;**

**Family:** Matrix  
**Base:** OiMatrixChart&lt;T&gt;  
**Role:** 2D quantitative density/correlation/calendar-like matrix views. Already present in inventory.

### **11\. OiTreemap&lt;TNode&gt;**

**Family:** Hierarchical  
**Base:** OiHierarchicalChart&lt;TNode&gt;  
**Role:** Space-filling hierarchy visualization. Already present in inventory.

### **12\. OiSankey&lt;TNode, TLink&gt;**

**Family:** Flow  
**Base:** OiFlowChart&lt;TNode, TLink&gt;  
**Role:** Weighted flow between nodes. Already present in inventory.

### **13\. OiFunnelChart&lt;T&gt;**

**Family:** Flow / specialized  
**Base:** Standalone composite with shared chart foundation  
**Role:** Conversion or stage-drop visualization. Already present in inventory.

### **14\. OiGauge**

**Family:** Metric / radial  
**Base:** OiPolarChart specialization or OiMetricChart  
**Role:** Single-value performance/meter visualization. Already present in inventory.

### **15\. OiCandlestickChart&lt;T&gt;**

**Family:** Cartesian  
**Base:** OiCartesianChart&lt;T&gt;  
**Role:** Financial OHLC/candlestick data.

This should be in the first serious chart scope because the chart analysis explicitly names candlestick/OHLC among the highest-priority families for a practical library.

## **Tier B - Strong second-wave charts that meaningfully extend coverage**

These are highly useful and should be supported once the core substrate is stable.

### **16\. OiHistogram&lt;T&gt;**

**Family:** Cartesian  
**Base:** OiCartesianChart&lt;T&gt;  
**Role:** Distribution via bins.

### **17\. OiWaterfallChart&lt;T&gt;**

**Family:** Cartesian  
**Base:** OiCartesianChart&lt;T&gt;  
**Role:** Stepwise contribution to a final total.

### **18\. OiBoxPlotChart&lt;T&gt;**

**Family:** Cartesian  
**Base:** OiCartesianChart&lt;T&gt;  
**Role:** Distribution summary with quartiles, whiskers, outliers.

### **19\. OiRangeAreaChart&lt;T&gt;**

**Family:** Cartesian  
**Base:** OiCartesianChart&lt;T&gt;  
**Role:** Min-max ranges, confidence bands, temperature bands.

### **20\. OiRangeBarChart&lt;T&gt;**

**Family:** Cartesian  
**Base:** OiCartesianChart&lt;T&gt;  
**Role:** Intervals, schedules, spans.

### **21\. OiRadialBarChart&lt;T&gt;**

**Family:** Polar  
**Base:** OiPolarChart&lt;T&gt;  
**Role:** Circular bar comparison.

### **22\. OiPolarAreaChart&lt;T&gt;**

**Family:** Polar  
**Base:** OiPolarChart&lt;T&gt;  
**Role:** Radial segment magnitude comparison.

### **23\. OiSunburstChart&lt;TNode&gt;**

**Family:** Hierarchical  
**Base:** OiHierarchicalChart&lt;TNode&gt;  
**Role:** Radial hierarchy.

### **24\. OiCalendarHeatmap&lt;T&gt;**

**Family:** Matrix  
**Base:** OiMatrixChart&lt;T&gt;  
**Role:** Time-based contribution grid, especially activity or contribution visuals.

## **Tier C - Long-tail or specialist charts**

These are valuable but should only come once the core chart system is genuinely mature.

### **25\. OiStepLineChart&lt;T&gt;**

**Family:** Cartesian  
**Base:** OiCartesianChart&lt;T&gt;  
**Role:** Discrete change visualization.

### **26\. OiSplineChart&lt;T&gt;**

**Family:** Cartesian  
**Base:** OiCartesianChart&lt;T&gt;  
**Role:** Smoothed trend line.

### **27\. OiStepAreaChart&lt;T&gt;**

**Family:** Cartesian  
**Base:** OiCartesianChart&lt;T&gt;  
**Role:** Discrete cumulative areas.

### **28\. OiAlluvialChart&lt;TNode, TLink&gt;**

**Family:** Flow  
**Base:** OiFlowChart&lt;TNode, TLink&gt;  
**Role:** Flow across sequential grouped stages.

### **29\. OiIcicleChart&lt;TNode&gt;**

**Family:** Hierarchical  
**Base:** OiHierarchicalChart&lt;TNode&gt;  
**Role:** Linear space-filling hierarchy.

### **30\. OiSparkLine&lt;T&gt;**

**Family:** Cartesian / compact  
**Base:** lightweight OiCartesianChart&lt;T&gt; specialization  
**Role:** tiny inline trend visual in tables, KPIs, cards.

### **31\. OiSparkBar&lt;T&gt;**

**Family:** Cartesian / compact  
**Base:** lightweight OiCartesianChart&lt;T&gt; specialization  
**Role:** compact comparison visual.

### **32\. OiWinLossChart&lt;T&gt;**

**Family:** Cartesian / compact categorical  
**Base:** lightweight OiCartesianChart&lt;T&gt; specialization  
**Role:** compact binary/ternary outcome charts.

The analysis specifically highlights sparkline-style compact charts as useful, but I would not let them distort the foundation. They should come after the standard chart substrate is stable.

# **3\. The actual recommended build list for obers_ui**

If I translate the above into what you should truly plan to build as the official obers_ui chart catalog, I would recommend this exact list.

## **v1 essential chart families**

### **Cartesian**

- OiLineChart
- OiAreaChart
- OiBarChart
- OiScatterChart
- OiBubbleChart
- OiComboChart
- OiCandlestickChart

### **Polar**

- OiPieChart
- OiDonutChart
- OiRadarChart
- OiGauge

### **Matrix**

- OiHeatmap

### **Hierarchical**

- OiTreemap

### **Flow**

- OiSankey
- OiFunnelChart

This is the right v1 serious scope because it:

- covers the most common real-world use cases
- includes the visualization composites already promised by the real obers_ui inventory
- keeps architectural breadth without exploding implementation cost
- gives you one representative from each major chart family

# **4\. The base class each chart should inherit from**

Here is the clean inheritance model I would use.

## **Cartesian family → OiCartesianChart&lt;T&gt;**

Build on this:

- OiLineChart&lt;T&gt;
- OiAreaChart&lt;T&gt;
- OiBarChart&lt;T&gt;
- OiScatterChart&lt;T&gt;
- OiBubbleChart&lt;T&gt;
- OiComboChart&lt;T&gt;
- OiHistogram&lt;T&gt;
- OiWaterfallChart&lt;T&gt;
- OiBoxPlotChart&lt;T&gt;
- OiRangeAreaChart&lt;T&gt;
- OiRangeBarChart&lt;T&gt;
- OiCandlestickChart&lt;T&gt;
- OiStepLineChart&lt;T&gt;
- OiSplineChart&lt;T&gt;
- OiStepAreaChart&lt;T&gt;
- compact sparkline derivatives

All of these should share:

- axes
- grid
- viewport
- series renderer registry
- brushing
- zoom/pan
- hit testing
- crosshair
- synchronized tooltips
- shared annotations and thresholds

## **Polar family → OiPolarChart&lt;T&gt;**

Build on this:

- OiPieChart&lt;T&gt;
- OiDonutChart&lt;T&gt;
- OiRadarChart&lt;T&gt;
- OiRadialBarChart&lt;T&gt;
- OiPolarAreaChart&lt;T&gt;
- OiGauge or OiGauge&lt;T&gt; depending on whether you want data-driven or direct-value API

These should share:

- angle/radius scale logic
- arc layout
- radial labels
- center content
- collision handling
- angular hit testing

## **Matrix family → OiMatrixChart&lt;T&gt;**

Build on this:

- OiHeatmap&lt;T&gt;
- OiCalendarHeatmap&lt;T&gt;

These should share:

- cell geometry
- x/y category or time axes
- color scales
- cell legends
- cell hover/selection
- large-grid virtualization strategies

## **Hierarchical family → OiHierarchicalChart&lt;TNode&gt;**

Build on this:

- OiTreemap&lt;TNode&gt;
- OiSunburstChart&lt;TNode&gt;
- OiIcicleChart&lt;TNode&gt;

These should share:

- tree parsing
- value aggregation
- depth calculations
- node focus/drill state
- hierarchical accessibility narration

## **Flow family → OiFlowChart&lt;TNode, TLink&gt;**

Build on this:

- OiSankey&lt;TNode, TLink&gt;
- OiAlluvialChart&lt;TNode, TLink&gt;

These should share:

- node/link models
- flow thickness scaling
- node/link hover interactions
- path hit testing
- node group legends

## **Specialized / standalone but foundation-backed**

These should still use the same chart contracts, theme system, behaviors, accessibility, overlays, and persistence, but they may justify a custom composite implementation:

- OiFunnelChart&lt;T&gt;
- OiGauge if you want a simpler standalone API
- possibly OiSparkLine&lt;T&gt; if optimized for very compact inline use

This avoids overfitting them into family abstractions when a small tailored wrapper gives a much nicer developer experience.

# **5\. The chart-type definitions in one concise catalog**

Below is the condensed catalog in the exact form I would use as the planning source.

### **OiLineChart&lt;T&gt;**

A Cartesian series chart for continuous trends across ordered values or time.

### **OiAreaChart&lt;T&gt;**

A Cartesian trend chart with filled area emphasis, supporting stacked and range variants later.

### **OiBarChart&lt;T&gt;**

A Cartesian comparison chart for grouped, stacked, horizontal, and vertical category-based values.

### **OiScatterChart&lt;T&gt;**

A Cartesian point chart for relationship and correlation analysis.

### **OiBubbleChart&lt;T&gt;**

A scatter-derived Cartesian chart where marker size encodes a third metric.

### **OiComboChart&lt;T&gt;**

A mixed Cartesian chart that can combine line, area, bar, and scatter series in one shared coordinate system.

### **OiCandlestickChart&lt;T&gt;**

A Cartesian financial chart based on open-high-low-close intervals and optional volume overlays later.

### **OiPieChart&lt;T&gt;**

A polar part-to-whole chart using filled angular slices.

### **OiDonutChart&lt;T&gt;**

A pie-derived polar chart with inner radius for center summary content.

### **OiRadarChart&lt;T&gt;**

A polar multi-axis comparison chart across several dimensions.

### **OiGauge**

A radial metric chart for progress, thresholds, status ranges, or single KPI display.

### **OiHeatmap&lt;T&gt;**

A matrix chart representing values through cell color across two dimensions.

### **OiTreemap&lt;TNode&gt;**

A hierarchical chart that visualizes nested proportional values as space-filling rectangles.

### **OiSankey&lt;TNode, TLink&gt;**

A flow chart that visualizes weighted transfers between nodes.

### **OiFunnelChart&lt;T&gt;**

A stage-based proportional drop-off chart for pipeline and conversion analysis.

# **6\. Important catalog decisions I would explicitly enforce**

There are a few decisions that matter a lot for keeping this library clean.

## **Do not split "variants" into too many separate widgets**

Prefer:

- OiBarChart with grouped / stacked / horizontal modes
- OiAreaChart with stacked mode
- OiLineChart with straight / stepped / smoothed interpolation modes

Do not create:

- OiGroupedBarChart
- OiStackedBarChart
- OiHorizontalBarChart
- OiSplineLineChart
- OiSteppedLineChart

unless the behavior becomes fundamentally different.

This is more consistent with obers_ui's readable, variant-driven API style.

## **Keep compact charts as specializations, not a separate ecosystem**

Sparklines and mini charts should use the same conventions, theme language, and data mapping model as normal charts, just in a constrained presentation.

That avoids inventing a second chart API.

## **Let OiComboChart be a first-class chart, not just an advanced mode**

Even if technically OiCartesianChart can already combine series, giving developers a named OiComboChart is good DX. It tells them clearly: "this is the intended API when I want mixed series." The chart analysis makes clear that this capability is strategically important.

## **Keep existing inventory names where reasonable**

Since AI_README already names:

- OiFunnelChart
- OiGauge
- OiHeatmap
- OiRadarChart
- OiSankey
- OiTreemap

those names should stay. The shared chart substrate should be built underneath them rather than renaming them. AI_README has precedence as the real implementation direction.

# **7\. Final recommendation for Part 3**

The cleanest chart catalog for obers_ui is:

- **Cartesian foundation** for the majority of data charts
- **Polar foundation** for radial and part-to-whole charts
- **Matrix foundation** for heatmaps
- **Hierarchical foundation** for treemaps and future hierarchy charts
- **Flow foundation** for sankey and future alluvial charts
- **shared chart foundation** for theme, behavior, sync, persistence, accessibility, overlays, and performance

And the practical initial chart list should be:

OiLineChart, OiAreaChart, OiBarChart, OiScatterChart, OiBubbleChart, OiComboChart, OiCandlestickChart, OiPieChart, OiDonutChart, OiRadarChart, OiGauge, OiHeatmap, OiTreemap, OiSankey, OiFunnelChart.

That gives you:

- excellent real-world coverage
- consistency with the current real obers_ui inventory
- a chart family map that can grow cleanly later
- a strong shared architecture instead of many unrelated widgets

When you say **continue**, I'll move to **Part 4: the first individual chart deep dive**, starting with **OiLineChart** in the exact structure you requested.

continue 3

I'm on the first full chart deep dive now. I'm grounding OiLineChart against the real obers_ui language again so the API, theming, behaviors, and testing all stay aligned instead of drifting into generic chart-library patterns.

Thought for 8s

## **Part 4 - OiLineChart&lt;T&gt;**

This is the first individual deep dive, and it is also the most important one.

If OiLineChart is excellent, the rest of the Cartesian family becomes much easier to design because so many core chart problems are solved here first:

- mapper-based data binding
- axis contracts
- missing data handling
- interpolation
- tooltip and crosshair behavior
- zoom, pan, selection, and synchronization
- large-dataset performance
- accessibility narration
- responsive complexity reduction

That priority is strongly supported by the chart analysis: line charts are among the most essential chart types, mapper-first binding is the strongest Flutter fit, mixed-series support must be foundational, data decimation should exist from the beginning, and accessibility plus responsive adaptation are major weaknesses in the current chart ecosystem that obers_ui can improve on.

It also needs to stay fully aligned with real obers_ui implementation language:

- Oi\* naming
- all colors from theme
- all layouts through obers_ui primitives
- accessibility as a requirement
- responsive behavior as a first-class contract
- composite-tier chart widgets, not one-off special cases

# **1\. What OiLineChart is**

OiLineChart&lt;T&gt; is the standard Cartesian chart for continuous or ordered trends across a numeric, time, or categorical x-domain.

It should be the most ergonomic chart in the whole package for the common case:

- trends over time
- multiple series comparisons
- KPI development
- historical metrics
- forecasting overlays
- benchmark comparisons
- sparkline-style compact reuse later
- real-time or rolling-window charts later

Architecturally, it should be a high-level convenience wrapper around OiCartesianChart&lt;T&gt;, not a separate engine.

So conceptually:

OiLineChart&lt;T&gt; extends OiCartesianChart&lt;T&gt;

but publicly exposed as a dedicated composite because line charts are common enough to deserve their own extremely readable API.

# **2\. How it should look, what it supports, and the most important behavior**

Visually, OiLineChart should support all of the standard shapes teams expect, but under one clean API:

- one or more line series
- straight, stepped, and smoothed interpolation modes
- optional markers
- optional data labels
- optional filled area beneath a line
- optional range band later
- dashed or segmented lines
- thresholds and annotations
- missing-point gaps or connected-null behavior
- shared tooltip and crosshair
- legend-based series toggling
- zooming, brushing, synchronization, and selection

The chart analysis is very clear that line charts need to support missing values, interpolation choices, and large data efficiently. It also highlights fl_chart's explicit gap handling and Chart.js-style decimation as especially important ideas to adopt.

So OiLineChart should treat these as first-class:

- **gap-aware rendering**
- **decimation-aware rendering**
- **interaction-aware nearest-point resolution**
- **responsive simplification**
- **theme-native styling**

In obers_ui language, the chart should also be able to present itself in several display densities:

- **standard analytic chart**
- **compact card chart**
- **embedded section chart**
- **touch-optimized mobile chart**

This is important because base concept already expects visualization widgets to fill their container, adapt with LayoutBuilder, move legends below on compact, use tap tooltips on touch, and degrade detail on small/mobile contexts.

# **3\. How data input stays easy, logical, and consistent**

This is where the developer experience can become genuinely excellent.

The attached chart analysis is very strong on this point: a Flutter chart spec should use a **mapper-based binding model** like Syncfusion, not force people into library-specific point objects.

That means the primary usage should look like this:

OiLineChart&lt;SalesPoint&gt;(  
label: 'Revenue over time',  
data: sales,  
x: (point) => point.date,  
y: (point) => point.revenue,  
)

For multiple series:

OiLineChart&lt;SalesPoint&gt;(  
label: 'Revenue and forecast',  
series: \[  
OiLineSeries&lt;SalesPoint&gt;(  
id: 'actual',  
label: 'Actual',  
data: actual,  
x: (point) => point.date,  
y: (point) => point.revenue,  
),  
OiLineSeries&lt;SalesPoint&gt;(  
id: 'forecast',  
label: 'Forecast',  
data: forecast,  
x: (point) => point.date,  
y: (point) => point.revenue,  
style: OiSeriesStyle.dashed(),  
),  
\],  
)

That is much better than forcing:

- List&lt;FlSpot&gt;
- custom wrapper row classes
- parallel arrays
- giant nested series configs just to map values

### **The consistency rule**

Every other point-based Cartesian chart should feel almost identical:

- OiLineSeries&lt;T&gt;
- OiAreaSeries&lt;T&gt;
- OiScatterSeries&lt;T&gt;
- OiBubbleSeries&lt;T&gt;

All should primarily use:

- data
- x
- y
- optional extra mappers

That is how you make the library feel like one convention.

### **Shorthand for the common case**

For a single-series line chart, the wrapper can expose a shorthand API:

class OiLineChart&lt;T&gt; extends StatelessWidget {  
final List&lt;T&gt;? data;  
final DateTime? Function(T item)? x;  
final num? Function(T item)? y;  
final List&lt;OiLineSeries<T&gt;>? series;  
}

Rule:

- if series is provided, ignore shorthand data/x/y
- if shorthand is provided, internally create one default OiLineSeries

This keeps the common path extremely smooth while preserving full power.

### **Important optional mappers**

For line charts, the series contract should also support:

- pointLabel
- pointColor
- isMissing
- semanticValue
- markerShape
- strokeWidth
- dashPattern
- customData

Example:

class OiLineSeries&lt;T&gt; extends OiChartSeries&lt;T&gt; {  
final Object? Function(T item) x;  
final num? Function(T item) y;  
final String? Function(T item)? pointLabel;  
final bool Function(T item)? isMissing;  
final Color? Function(T item, OiSeriesPointContext context)? pointColor;  
final String? Function(T item)? semanticValue;  
final OiLineInterpolation interpolation;  
final OiLineMissingValueBehavior missingValueBehavior;  
}

That is both readable and consistent.

# **4\. Overall structure, API, props, and callbacks**

## **Public widget shape**

This is the public direction I would recommend:

class OiLineChart&lt;T&gt; extends StatefulWidget {  
final String label;  
final String? semanticLabel;  
<br/>final List&lt;T&gt;? data;  
final Object? Function(T item)? x;  
final num? Function(T item)? y;  
<br/>final List&lt;OiLineSeries<T&gt;>? series;  
<br/>final OiChartAxis? xAxis;  
final List&lt;OiChartAxis&gt;? yAxes;  
<br/>final OiChartLegendConfig? legend;  
final List&lt;OiChartBehavior&gt; behaviors;  
final List&lt;OiChartAnnotation&gt; annotations;  
final List&lt;OiChartThreshold&gt; thresholds;  
<br/>final OiChartThemeData? theme;  
final OiChartPerformanceConfig? performance;  
final OiChartAnimationConfig? animation;  
final OiChartAccessibilityConfig? accessibility;  
final OiChartSettingsDriverBinding? settings;  
final OiChartController? controller;  
final String? syncGroup;  
<br/>final OiChartLoadingStateConfig? loadingState;  
final OiChartEmptyStateConfig? emptyState;  
final OiChartErrorStateConfig? errorState;  
<br/>final ValueChanged&lt;OiLineChartPointSelection&gt;? onPointTap;  
final ValueChanged&lt;OiLineChartSeriesToggle&gt;? onSeriesVisibilityChange;  
final ValueChanged&lt;OiChartViewportState&gt;? onViewportChange;  
}

## **Important line-series props**

class OiLineSeries&lt;T&gt; extends OiChartSeries&lt;T&gt; {  
final Object? Function(T item) x;  
final num? Function(T item) y;  
<br/>final OiLineInterpolation interpolation;  
final OiLineMissingValueBehavior missingValueBehavior;  
<br/>final bool showLine;  
final bool showMarkers;  
final bool showDataLabels;  
final bool fillBelow;  
final double? smoothing;  
final OiSeriesStyle? style;  
<br/>final OiTooltipValueFormatter? valueFormatter;  
final OiAxisFormatter&lt;Object&gt;? xFormatter;  
final String? Function(T item)? pointLabel;  
final String? Function(T item)? semanticValue;  
}

## **Enums**

enum OiLineInterpolation {  
straight,  
stepped,  
monotone,  
smooth,  
}  
<br/>enum OiLineMissingValueBehavior {  
gap,  
connect,  
zero,  
interpolate,  
}

The interpolation options are justified by the chart analysis, which specifically notes the richness of interpolation systems like D3 and the usefulness of different line behaviors across libraries.

## **Callbacks**

Keep callbacks minimal and readable:

- onPointTap
- onPointDoubleTap
- onPointLongPress
- onSeriesVisibilityChange
- onViewportChange
- onSelectionChange

Do not leak internal renderer events into public API unless truly needed.

# **5\. How it should be customized through global obers_ui theming**

AI_README is explicit: all colors come from theme, use obers_ui primitives, and never hardcode visual styling.

So OiLineChart must participate in a chart theme extension that resolves from the global OiThemeData.

## **Global theme integration**

OiChartThemeData should provide:

- default palette
- axis typography
- grid appearance
- legend spacing and marker style
- tooltip surface style
- crosshair style
- selection halo style
- annotation appearance
- default motion behavior
- compact-mode complexity defaults

Example:

OiThemeData(  
components: OiComponentThemes(  
chart: OiChartThemeData(  
palette: ...,  
axis: ...,  
grid: ...,  
tooltip: ...,  
legend: ...,  
motion: ...,  
),  
),  
)

## **What OiLineChart resolves from theme by default**

Without local overrides, a line chart should derive:

- series stroke colors from chart palette
- axis label and title text styles from theme typography
- plot grid color from neutral border/subtle theme colors
- marker fill/stroke from chart palette + surface contrast rules
- tooltip surface from standard overlay/popover surface tokens
- annotation and threshold styles from chart theme defaults
- hover and focus rings from interactive state tokens

This matches obers_ui's broader requirement that theme tokens cascade naturally rather than requiring per-widget manual styling.

# **6\. How it can be themed and configured on an element basis**

The layering should be very clear and stable:

### **Layer 1 - global app theme**

Applies to all charts by default.

### **Layer 2 - local chart theme override**

Applies to one chart instance.

theme: OiChartThemeData(  
legend: ...,  
tooltip: ...,  
)

### **Layer 3 - series style**

Applies to one series.

OiLineSeries(  
id: 'forecast',  
label: 'Forecast',  
style: OiSeriesStyle(  
strokeWidth: 2,  
dashPattern: \[6, 4\],  
marker: OiMarkerStyle.hidden(),  
),  
)

### **Layer 4 - point-level dynamic overrides**

Applies per data item.

pointColor: (item, context) => item.isOutlier  
? context.theme.palette.negative  
: null,

This is the correct precedence model because it is readable and predictable.

## **Series style object**

OiSeriesStyle for line series should support:

- strokeColor
- strokeWidth
- strokeCap
- strokeJoin
- dashPattern
- marker
- dataLabel
- fill
- hoverStyle
- selectedStyle
- inactiveStyle

That gives deep flexibility without cluttering the top-level series API.

# **7\. How the logic works and how it should be implemented**

This is where OiLineChart should become the reference architecture for all Cartesian charts.

## **7.1 Data normalization**

Each series should compile from domain models into normalized chart data:

- map x and y
- tag missing values
- sort if the x-domain requires sorting
- convert domain values through scales
- store both raw and scaled values
- build segment lists separated by gaps where needed

This normalized internal structure is essential for consistent rendering and interaction.

## **7.2 Scale resolution**

The x-axis should auto-resolve when possible:

- DateTime → time scale
- num → linear scale
- String or enum-like labels → category/point scale

But developers should still be able to override scale type through xAxis.

This aligns with the chart analysis recommendation that charts should infer sensible scale behavior while still allowing explicit control.

## **7.3 Path generation**

For each visible line series:

- build visible point list within current viewport
- split into continuous segments based on missing-value policy
- generate path based on interpolation mode
- optionally generate fill path if fillBelow
- optionally generate marker positions for visible points only

Important implementation detail:

- **markers must not be laid out for every point in huge datasets if they are not visible or are density-suppressed**
- line paths should be cached per normalized viewport window where possible

## **7.4 Missing-value behavior**

This should be explicit and predictable.

### **gap**

Break the line visually. Best default for honest time-series communication.

### **connect**

Skip null and connect neighboring valid points.

### **zero**

Render missing y-values at zero.

### **interpolate**

Linearly interpolate between neighbors. Useful for specific analytic scenarios but should be opt-in.

The chart analysis highlights that gap handling is one of the practical details libraries often expose badly, and fl_chart's explicit null-spot handling is one useful precedent.

## **7.5 Hit testing**

Hit testing should not naively search every point on every hover.

Use:

- viewport-filtered points
- x-bucket indexing or binary search for ordered domains
- nearest-point resolution with threshold tolerance
- series-aware preference rules

For time-series charts, nearest-point lookup should usually use x-distance first, then y-distance.

## **7.6 Interaction model**

Behaviors should handle interaction, not line chart core logic directly.

Typical defaults:

- hover or tap tooltip behavior
- crosshair behavior
- series selection behavior
- optional zoom/pan behavior

The chart should expose good default behaviors out of the box but let developers override them. This follows the behavior-object pattern recommended in the chart analysis.

## **7.7 Sync logic**

If syncGroup is set:

- hover position broadcasts shared x-domain focus
- linked charts resolve nearest point locally
- optional shared viewport sync
- optional shared brush selection

This follows the same dashboard value that the analysis calls out in Recharts' syncId model.

# **8\. How performance is guaranteed, even with huge datasets**

This is one of the most important parts.

The chart analysis is explicit that built-in data decimation and progressive rendering should be baseline, not afterthoughts, and that Flutter charting is especially weak here today.

So OiLineChart should be designed around the assumption that users may plot:

- 5,000 points
- 50,000 points
- 250,000 points
- rolling real-time windows later

## **8.1 Automatic decimation**

For line charts, provide:

- none
- minMax
- lttb
- adaptive

Recommended default:

- adaptive

Behavior:

- if visible points are low, draw full fidelity
- if visible points exceed a threshold relative to pixel width, decimate before path construction
- preserve extrema so trend and spikes remain visible

## **8.2 Viewport-based rendering**

Only normalize and paint points in or near the visible x-domain window.

This is essential for zoomed charts and rolling windows.

## **8.3 Marker suppression**

Markers are expensive visually and interaction-wise.  
Rules:

- automatically hide markers beyond a visible-density threshold
- optionally show markers only on hover, selection, or focused series
- on compact layouts, default to fewer markers

## **8.4 Label suppression**

Data labels should be responsive and density-aware:

- hide when they would collide excessively
- show only selected points
- or show summary labels only

This directly fits base concept's broader responsive philosophy that complexity should reduce on compact/mobile layouts.

## **8.5 Path caching**

Cache:

- normalized scaled points
- decimated visible series result
- generated path segments
- text layout for repeated axis/tooltip labels

Invalidate only when:

- data changes
- viewport changes
- theme changes
- density mode changes
- axis formatter changes

## **8.6 Progressive rendering mode**

For truly large datasets, allow chunked refinement:

- immediate coarse decimated render
- refine visible path in subsequent frame(s) if budget allows
- degrade back under load

## **8.7 Interaction budget protection**

If data volume is extreme:

- reduce hover hit-test radius calculations
- disable expensive nearest-neighbor across all hidden series
- limit simultaneous tooltip entries
- avoid per-point semantics nodes

## **8.8 Streaming readiness**

Even if real-time streaming is not first-wave API, line chart architecture should already allow:

- ring-buffer data sources
- append-only updates
- windowed domains
- efficient left-shifted viewport updates

The chart analysis specifically calls out streaming support as weak across libraries, especially in Flutter. Designing for it now prevents future rewrites.

# **9\. How interactivity works and how it can be configured**

Base concept already expects visualization widgets to be touch-friendly, with tap tooltips on touch and hover tooltips on pointer.

OiLineChart should implement exactly that behavior.

## **Default interaction rules**

### **Pointer devices**

- hover shows tooltip
- hover may show crosshair
- wheel or trackpad may zoom if enabled
- drag may pan or brush depending on active behavior
- click selects point/series if configured

### **Touch devices**

- tap shows tooltip
- second tap elsewhere dismisses
- long press can lock tooltip/crosshair
- pinch zoom if OiZoomPanBehavior allows it
- on compact, visible zoom controls can appear for precise control if needed, following broader obers_ui touch ergonomics for large diagrams and graphs.

## **Interactivity configuration**

This should primarily happen through behaviors:

behaviors: \[  
OiTooltipBehavior(),  
OiCrosshairBehavior(),  
OiZoomPanBehavior(  
allowPan: true,  
allowPinchZoom: true,  
),  
OiSelectionBehavior(  
selectionMode: OiChartSelectionMode.point,  
),  
\]

## **Selection models**

Support:

- none
- point
- series
- x-domain group
- brush range

## **Keyboard interaction**

Because accessibility is mandatory in obers_ui, line charts should also support:

- left/right arrows move between logical points
- up/down switches series
- home/end jump to first/last visible point
- enter toggles selection
- escape clears selection
- focused point announces formatted x/y value

The chart analysis explicitly notes that keyboard exploration is a missing feature across existing libraries. This should be an obers_ui differentiator.

# **10\. How legend and additional information should be implemented**

## **Legend**

The legend should use the shared chart legend component and present:

- series color
- series label
- visible/hidden state
- optional emphasis state
- optional summary value

It should support:

- toggle visibility
- isolate one series
- keyboard access
- compact wrapping
- custom item builders

Base concept already defines that on compact, chart legends should move below the chart. OiLineChart must follow that as a default responsive behavior.

## **Tooltip content**

Tooltip entries should support:

- series label
- formatted x value
- formatted y value
- point label
- delta vs previous point optionally later
- custom metadata rows

For multi-series shared tooltips, order should be configurable:

- legend order
- y-value descending
- focused series first

## **Additional information blocks**

Line charts should support:

- threshold labels
- range bands
- event markers
- release markers
- forecast boundary markers
- annotation labels with anchor positioning

These should not be hacked into series data. They should use shared OiChartAnnotation and OiChartThreshold contracts.

# **11\. How accessibility is guaranteed**

AI_README makes accessibility mandatory, and the chart analysis clearly identifies accessibility as a major weakness in current chart libraries.

So OiLineChart should go much further than typical chart widgets.

## **11.1 Required semantics inputs**

At minimum:

- label required
- semanticLabel optional override
- each series has a label
- each interactive legend item has a semanticLabel
- point-level semantic narration can be generated automatically

## **11.2 Auto-generated chart summary**

If no custom summary is provided, generate one like:

- chart type
- number of series
- x-axis domain range
- y-axis range
- notable min/max
- general trend direction where inferable

This directly follows the ECharts-inspired recommendation in the chart analysis to auto-generate accessibility descriptions from chart configuration.

## **11.3 Keyboard exploration mode**

A focused line chart should allow exploration of actual data points by keyboard, with announcements such as:

- "Revenue, March 2026, 42,300 euros, selected"
- "Forecast, April 2026, 45,100 euros"

## **11.4 Reduced motion**

If app-level reduced motion is active:

- disable animated path drawing
- reduce hover/focus motion
- keep selection and tooltip transitions minimal

## **11.5 High contrast and theme compatibility**

Since all colors come from theme:

- ensure line and grid contrast thresholds are validated
- markers use contrast-aware outline/fill logic
- focused point has a non-color-only indicator
- dashed vs solid can help distinguish series when colors are insufficient

## **11.6 Optional accessible data table**

For large analytic contexts, expose a semantic or expandable data-table fallback:

- either a screen-reader-friendly summary view
- or a linked OiTable/OiDetailView representation when exposeDataTable is enabled

That is especially useful for enterprise contexts.

# **12\. Every extensive test needed for OiLineChart**

This part should be very serious. obers_ui already expects strong behavioral and responsive testing in its concepts, including performance tests, golden tests, compact behavior checks, and input-mode differences.

So OiLineChart should have a very broad test matrix.

## **A. Rendering and layout tests**

- renders single series with numeric x-axis
- renders single series with time x-axis
- renders multiple visible series
- hides series when visible: false
- respects container constraints
- fills available container space
- legend moves below chart on compact
- minimum viable size fallback appears below threshold
- axis titles render correctly
- chart padding resolves correctly with and without legend
- line path clips to plot area correctly

## **B. Data mapping tests**

- mapper-based x/y extraction works with domain models
- shorthand single-series API internally produces correct default series
- category, numeric, and time x-domains resolve correctly
- explicit axis scale override beats auto inference
- sorted and unsorted source data behave correctly according to documented policy
- null y values are handled correctly
- custom point labels and semantic values map correctly

## **C. Missing-value tests**

- gap creates separate path segments
- connect skips missing points
- zero maps missing values to zero
- interpolate creates expected intermediate line behavior
- first/last point missing values do not produce broken geometry
- multiple sequential missing values are handled correctly

## **D. Interpolation tests**

- straight generates direct segments
- stepped generates horizontal/vertical step layout
- monotone preserves monotonicity where applicable
- smooth produces expected curve constraints
- interpolation does not overshoot invalidly in monotone mode
- interpolation behaves correctly around missing-value boundaries

## **E. Interaction tests**

- hover tooltip appears on pointer
- tap tooltip appears on touch
- tooltip dismisses correctly
- crosshair follows hover position
- nearest point resolution is correct with dense series
- point tap callback fires with correct payload
- series visibility toggle callback fires
- selection state updates controller correctly
- zoom and pan behavior modify viewport correctly
- brush selection returns correct domain range
- sync group propagates hover state to sibling charts

## **F. Keyboard and accessibility tests**

- chart exposes semantic label
- auto-generated summary includes chart type and series count
- keyboard left/right navigates points
- keyboard up/down switches series
- enter selects focused point
- escape clears selection
- focus announcements use formatted values
- legend items are keyboard operable
- reduced motion disables nonessential animation
- high contrast theme still differentiates visible states

## **G. Theming tests**

- chart derives default palette from theme
- local theme override applies without affecting siblings
- series style override beats chart theme
- point-level override beats series style
- tooltip surface and legend styles resolve from chart theme
- light and dark theme goldens are stable
- density changes affect spacing and marker behavior correctly

## **H. Responsive tests**

- compact breakpoint reduces tick density
- compact breakpoint moves legend below
- compact breakpoint reduces marker/data-label complexity
- touch mode uses tap instead of hover
- medium/expanded layouts preserve intended axis labels
- container-relative width changes trigger correct adaptation
- no overflow or clipped labels in narrow layout
- "view full screen" fallback appears below minimum viable size

This is especially important because base concept explicitly expects responsive visualization behavior and a first-class responsive prop language through OiResponsive&lt;T&gt;.

## **I. Performance tests**

- 1,000 points renders without jank
- 10,000 points uses decimation when enabled
- 100,000 points remains interactive under performance mode
- viewport zoom reduces processed points correctly
- hidden series are excluded from expensive hit testing
- marker suppression triggers at configured density threshold
- cached path invalidation happens only when necessary
- repeated hover does not allocate excessively
- repeated zoom/pan does not leak memory
- progressive refinement converges correctly under load

Base concept uses explicit numeric performance expectations elsewhere, such as sub-16ms frame budgets and large-data tests for file and layout systems. The line chart test suite should be written in the same spirit.

## **J. Golden tests**

- default single-series line chart
- multi-series line chart with legend
- compact chart with legend below
- chart with dashed forecast line
- chart with area fill enabled
- chart with threshold and annotation markers
- chart with selected point and tooltip
- dark theme chart
- high contrast chart
- dense dataset chart in simplified rendering mode

# **13\. Final recommendation for OiLineChart**

OiLineChart should become the canonical example of how charts work in obers_ui:

- mapper-first data input, because that gives the best Flutter DX for real data models
- composable behaviors for tooltip, crosshair, zoom, selection, and keyboard exploration
- full theme integration through obers_ui tokens and chart theme extensions, never manual styling by default
- responsive adaptation as a first-class behavior, not a later add-on, matching the rest of obers_ui's responsive contract
- deep performance architecture from the first version, including decimation, viewport rendering, path caching, and density-aware simplification
- stronger accessibility than typical chart libraries, especially through generated summaries and keyboard point exploration

If done this way, OiLineChart does not just become one chart. It becomes the reference pattern for the whole Cartesian family.

When you say **continue**, I'll move to the next chart deep dive: **OiAreaChart&lt;T&gt;**.

continue 4

I'm moving to OiAreaChart now, keeping it tightly aligned with the same Cartesian contracts so it feels like a natural extension of OiLineChart, not a separate mini-library.

Thought for 5s

## **Part 5 - OiAreaChart&lt;T&gt;**

OiAreaChart should feel like a **direct sibling of OiLineChart**, not like a separate subsystem.

That matters a lot for obers_ui. The real implementation direction strongly favors one coherent package language: tiered architecture, Oi\* naming, theme-first styling, layout through obers_ui primitives, and mandatory accessibility. At the same time, the chart concept makes it clear that mapper-first binding, composable behaviors, built-in decimation, chart mixing, and stronger accessibility are the right foundation for a serious Flutter chart library.

Area charts are also explicitly part of the essential chart surface across the libraries analyzed, including stacked and range variants in stronger systems.

So the rule for obers_ui should be:

**OiAreaChart is a Cartesian chart built on exactly the same shared substrate as OiLineChart, but optimized for communicating filled magnitude, cumulative layers, and range emphasis.**

# **1\. What OiAreaChart is**

OiAreaChart&lt;T&gt; is the standard filled Cartesian trend chart for showing quantitative change over an ordered x-domain, with visual emphasis on:

- total magnitude
- accumulation
- stacked contribution
- confidence or range bands
- baseline-relative change
- trend comparison where area improves readability

Architecturally:

OiAreaChart&lt;T&gt; extends OiCartesianChart&lt;T&gt;

Internally, it should reuse nearly all of the OiLineChart substrate:

- same axes
- same domain/scales
- same behaviors
- same tooltip/crosshair system
- same settings/persistence
- same legend model
- same annotations/thresholds
- same accessibility and responsive rules

The only real difference is the renderer and the additional stacking / fill logic.

That is important because the chart concept explicitly argues against separate one-off chart engines and in favor of first-class mixed-series support within a shared coordinate system.

# **2\. How it looks, features, and the most important visual behavior**

Visually, OiAreaChart should support these core forms:

- single filled area to baseline
- multiple independent translucent areas
- stacked area
- 100% stacked area
- step area
- smoothed area
- range area / band area later
- optional outline stroke
- optional markers
- optional data labels
- optional gradient fill
- optional threshold / reference line overlays

That coverage is well supported by the chart comparison in the concept, which explicitly identifies standard area, stacked area, spline area, step area, and range area as important families in stronger libraries.

The essential visual behaviors are:

### **A. Baseline-aware filling**

Area charts always fill against a baseline:

- usually zero
- sometimes an explicit custom baseline
- sometimes another series in range/between modes later

### **B. Order matters more than in line charts**

With multiple areas, especially translucent ones, draw order meaningfully changes readability. So the API needs a clean way to control layering.

### **C. Stacking must be first-class**

Unlike line charts, stacking is core to area charts. The chart system must treat it as a primary mode, not a hack.

### **D. Density simplification matters even more**

Filled geometry creates more visual weight than lines, so on compact screens or dense datasets:

- reduce markers
- reduce labels
- simplify fill opacity or gradients
- possibly collapse to line-only style in extreme compact mini modes

That matches the broader obers_ui responsive visualization requirements: fill container, adapt via LayoutBuilder, move legend below on compact, use tap tooltips on touch, and reduce complexity on smaller/mobile contexts.

# **3\. How data input stays easy, logical, and consistent**

This must stay almost identical to OiLineChart, because that consistency is one of the biggest DX wins.

The chart concept is explicit that Flutter charts should be mapper-first, not force data reshaping into library-specific point models.

So the common case should look like:

OiAreaChart&lt;RevenuePoint&gt;(  
label: 'Revenue over time',  
data: revenue,  
x: (point) => point.date,  
y: (point) => point.value,  
)

And multi-series should look like:

OiAreaChart&lt;RevenuePoint&gt;(  
label: 'Revenue by segment',  
series: \[  
OiAreaSeries&lt;RevenuePoint&gt;(  
id: 'food',  
label: 'Food',  
data: foodRevenue,  
x: (point) => point.date,  
y: (point) => point.value,  
),  
OiAreaSeries&lt;RevenuePoint&gt;(  
id: 'drinks',  
label: 'Drinks',  
data: drinksRevenue,  
x: (point) => point.date,  
y: (point) => point.value,  
),  
\],  
)

That should feel nearly identical to OiLineSeries, with only area-specific options added.

## **The consistency rule**

For point-based Cartesian charts, developers should mostly learn one input mental model:

- data
- x
- y
- optional series list
- optional style and formatting callbacks

That applies across:

- OiLineSeries
- OiAreaSeries
- OiScatterSeries
- OiBubbleSeries

## **Area-specific extra data concepts**

OiAreaSeries&lt;T&gt; should additionally support:

- baseline mapping
- stack group
- stack mode
- fill style
- area order
- optional upper/lower values later for range area

Example:

class OiAreaSeries&lt;T&gt; extends OiChartSeries&lt;T&gt; {  
final Object? Function(T item) x;  
final num? Function(T item) y;  
final num? Function(T item)? baseline;  
final String? stackGroup;  
final OiAreaStackMode stackMode;  
final OiAreaInterpolation interpolation;  
final OiAreaMissingValueBehavior missingValueBehavior;  
}

That keeps it similar to line charts while exposing the genuinely necessary area logic.

# **4\. Overall structure, API, props, and callbacks**

## **Public widget shape**

class OiAreaChart&lt;T&gt; extends StatefulWidget {  
final String label;  
final String? semanticLabel;  
<br/>final List&lt;T&gt;? data;  
final Object? Function(T item)? x;  
final num? Function(T item)? y;  
<br/>final List&lt;OiAreaSeries<T&gt;>? series;  
<br/>final OiChartAxis? xAxis;  
final List&lt;OiChartAxis&gt;? yAxes;  
<br/>final OiChartLegendConfig? legend;  
final List&lt;OiChartBehavior&gt; behaviors;  
final List&lt;OiChartAnnotation&gt; annotations;  
final List&lt;OiChartThreshold&gt; thresholds;  
<br/>final OiChartThemeData? theme;  
final OiChartPerformanceConfig? performance;  
final OiChartAnimationConfig? animation;  
final OiChartAccessibilityConfig? accessibility;  
final OiChartSettingsDriverBinding? settings;  
final OiChartController? controller;  
final String? syncGroup;  
<br/>final OiChartLoadingStateConfig? loadingState;  
final OiChartEmptyStateConfig? emptyState;  
final OiChartErrorStateConfig? errorState;  
<br/>final ValueChanged&lt;OiAreaChartPointSelection&gt;? onPointTap;  
final ValueChanged&lt;OiAreaChartSeriesToggle&gt;? onSeriesVisibilityChange;  
final ValueChanged&lt;OiChartViewportState&gt;? onViewportChange;  
}

## **Area series contract**

class OiAreaSeries&lt;T&gt; extends OiChartSeries&lt;T&gt; {  
final Object? Function(T item) x;  
final num? Function(T item) y;  
final num? Function(T item)? baseline;  
<br/>final OiAreaInterpolation interpolation;  
final OiAreaMissingValueBehavior missingValueBehavior;  
<br/>final String? stackGroup;  
final OiAreaStackMode stackMode;  
final int? zIndex;  
<br/>final bool showOutline;  
final bool showMarkers;  
final bool showDataLabels;  
final bool fillToBaseline;  
final bool fillGradient;  
final double? smoothing;  
<br/>final OiSeriesStyle? style;  
<br/>final OiTooltipValueFormatter? valueFormatter;  
final OiAxisFormatter&lt;Object&gt;? xFormatter;  
final String? Function(T item)? pointLabel;  
final String? Function(T item)? semanticValue;  
}

## **Enums**

enum OiAreaInterpolation {  
straight,  
stepped,  
monotone,  
smooth,  
}  
<br/>enum OiAreaMissingValueBehavior {  
gap,  
connect,  
zero,  
interpolate,  
}  
<br/>enum OiAreaStackMode {  
none,  
stacked,  
stacked100,  
}

## **Important callback philosophy**

Keep top-level callbacks simple:

- onPointTap
- onPointLongPress
- onSeriesVisibilityChange
- onViewportChange
- onSelectionChange

Do not expose renderer internals publicly.

# **5\. How it should be customized through global obers_ui theming**

AI_README is very clear that colors must come from theme, layouts from obers_ui primitives, and accessibility is not optional. It also defines component theme extensions as the preferred visual override mechanism.

So area charts should resolve from OiChartThemeData, just like line charts.

## **Global theme defaults that matter especially for area charts**

OiChartThemeData should include defaults for:

- categorical palette
- sequential/diverging gradients
- area fill opacity by density mode
- outline stroke defaults
- marker defaults
- stacked-area emphasis rules
- selected / inactive series appearance
- tooltip / legend / axis / grid / crosshair styling

## **Area-specific theme defaults**

Because fill behavior is central here, the chart theme should also define:

- default area opacity
- default stacked opacity behavior
- gradient stop defaults
- minimum contrast strategy for overlapped fills
- dense-mode fill simplification behavior

Example direction:

OiThemeData(  
components: OiComponentThemes(  
chart: OiChartThemeData(  
palette: ...,  
density: OiChartDensityTheme(  
defaultAreaOpacity: ...,  
),  
motion: ...,  
),  
),  
)

Even if chart is a new component theme extension, it should follow the same typed theme-extension philosophy already used elsewhere in obers_ui.

# **6\. How it can be themed and configured on an element basis**

The same four-level precedence should apply here too:

### **Layer 1 - global app theme**

Default chart-wide appearance.

### **Layer 2 - local chart theme override**

Per-chart override for one instance.

theme: OiChartThemeData(  
palette: ...,  
legend: ...,  
)

### **Layer 3 - series style**

Per-series fill, outline, marker, hover, inactive style.

OiAreaSeries(  
id: 'forecast',  
label: 'Forecast',  
style: OiSeriesStyle(  
fillGradient: ...,  
strokeWidth: 2,  
opacity: 0.28,  
),  
)

### **Layer 4 - point-level dynamic override**

Per-item color or semantic emphasis where needed.

pointColor: (item, context) =>  
item.isProjected ? context.theme.palette.neutral : null,

## **Area-specific style concerns**

OiSeriesStyle for area charts should support:

- fillColor
- fillGradient
- fillOpacity
- strokeColor
- strokeWidth
- dashPattern
- marker
- dataLabel
- hoverStyle
- selectedStyle
- inactiveStyle

And for stacked areas:

- inactive series should fade cleanly
- hovered series should become more legible without breaking stack meaning
- fill opacity needs to remain readable when multiple areas overlap

That last point is especially important. Area charts can become muddy much faster than line charts if theming is not handled carefully.

# **7\. How each logic works and how exactly it should be implemented**

This is where OiAreaChart becomes more than "a line chart with fill."

## **7.1 Data normalization**

Per series:

- map x
- map y
- resolve baseline if any
- tag missing values
- resolve stack group
- sort if needed for ordered x-domains
- normalize to internal datum list
- compute stacked y0/y1 if stacking is enabled
- compute filled polygon segments per continuous section

The internal normalized area datum should track at least:

- raw x
- raw y
- scaled x
- scaled y
- scaled baseline
- stacked lower bound
- stacked upper bound
- missing/gap flags
- visual segment membership

## **7.2 Baseline logic**

Area charts need an explicit baseline model.

Supported baseline strategies should be:

- zero baseline
- axis minimum baseline
- explicit constant baseline
- per-point baseline mapper
- stacked lower-series baseline

This is important because not all area charts should fill to zero. Range and confidence-band variants later will reuse this concept.

## **7.3 Fill path construction**

For each continuous visible segment:

- generate upper path from ordered points
- generate lower path from baseline/stacked lower bound in reverse order
- close polygon
- fill
- optionally render outline path separately

This should be done after decimation, not before, or fill geometry can become unnecessarily expensive.

## **7.4 Stacking logic**

This is the most important unique implementation area.

### **stacked**

For each x position inside a stack group:

- sum preceding visible series values
- current series upper bound = prior cumulative + current value
- lower bound = prior cumulative

### **stacked100**

Normalize all visible series at each x-position to percentage contribution:

- total = sum of visible positive/eligible series
- current upper = cumulative + value / total
- lower = prior cumulative

Important design rule:  
**stacking must respect hidden legend state.  
**If a user hides one series, the visible stack should recompute. That matches user expectations in good dashboard libraries.

## **7.5 Missing-value logic**

Area charts need even stricter missing-value rules than line charts because bad fill behavior can be visually misleading.

Recommended behavior:

- default = gap
- gap breaks area polygon
- connect bridges missing values
- zero drops to baseline
- interpolate estimates missing values

gap should be the safest default for honesty in time-series communication.

## **7.6 Draw order and z-index**

With translucent areas, order matters a lot.  
Rules:

- explicit zIndex wins
- otherwise later series draw on top by default
- stacked series should usually draw in stack order
- selected series can temporarily gain emphasis via outline/opacity rather than jumping order unless explicitly configured

## **7.7 Outline logic**

Area charts should optionally draw an outline stroke:

- none
- top edge only
- full boundary later if needed
- highlighted on hover or selection

Top-edge outline is usually the most readable default.

# **8\. How performance is guaranteed even with huge datasets**

The chart concept is direct here: built-in decimation and progressive rendering should be baseline, especially for Flutter where the ecosystem is weak.

Area charts need even more care than line charts because filled polygons are heavier than strokes.

## **8.1 Decimation before polygon generation**

This is critical.

For area charts:

- first viewport-filter points
- then decimate
- then build fill polygons

Do not build full polygons first and simplify later.

## **8.2 Adaptive decimation strategy**

Recommended default:

- adaptive

Supported:

- none
- minMax
- lttb
- adaptive

For area charts, min/max preservation is particularly important because peaks and troughs define the shape users care about.

## **8.3 Stacked performance rules**

Stacked areas are more expensive because every visible series depends on the others.  
So:

- cache cumulative stack results per stack group
- invalidate only when data, viewport, or visible-series state changes
- hidden-series legend changes should trigger recomputation only for the affected stack group

## **8.4 Marker and label suppression**

Default rules:

- markers off unless explicitly enabled or hover-focused
- data labels off by default in dense charts
- compact breakpoints reduce fill complexity and labels first

This is consistent with the base visualization guidance to reduce detail on mobile for more complex visualizations.

## **8.5 Gradient simplification**

Gradients are visually nice but more expensive and noisier in dense data.  
In performance mode or compact layout:

- simplify gradients
- possibly fall back to flat fill color
- reduce alpha complexity

## **8.6 Cached paths**

Cache:

- normalized visible segments
- decimated upper/lower point sequences
- final fill paths
- outline paths
- repeated axis label layouts

Invalidate on:

- data change
- theme change
- viewport change
- stack visibility change
- interpolation change
- density mode change

## **8.7 Progressive rendering**

For very large datasets:

- render coarse simplified area immediately
- refine visible segments if budget allows
- reduce interactivity cost under heavy load

## **8.8 Viewport-first rendering**

Only process visible domain windows plus a small overscan.  
This is especially important for zoomed time-series and future streaming/windowed area charts.

# **9\. How interactivity works and can be configured**

The same modality rules from the visualization spec should apply here:

- tooltip on tap for touch
- tooltip on hover for pointer
- legend below on compact
- minimum viable size fallback when too cramped

## **Default interaction behavior**

### **Pointer**

- hover shows tooltip
- optional crosshair
- click selects point or series
- wheel/trackpad zoom if enabled
- drag pan or brush depending on behavior

### **Touch**

- tap shows tooltip
- tap elsewhere dismisses
- long press can lock tooltip
- pinch zoom if enabled
- large enough target regions for touch exploration

Remember that obers_ui's touch-target guidance requires 48x48dp minimum hit areas for interactive elements on touch devices. That should influence marker hit regions, legend toggles, and any overlay controls.

## **Behavior-based configuration**

behaviors: \[  
OiTooltipBehavior(),  
OiCrosshairBehavior(),  
OiZoomPanBehavior(  
allowPan: true,  
allowPinchZoom: true,  
),  
OiSelectionBehavior(  
selectionMode: OiChartSelectionMode.point,  
),  
\]

## **Area-specific interaction detail**

In an area chart, hit testing should support both:

- nearest point interaction
- optionally inside-area hit interaction

This matters because users often perceive the filled region as the interactive object, not only the line points.

So the chart should support configurable hover model:

- point
- segment
- area
- sharedX

Recommended default:

- shared x-domain point resolution for multi-series analytic charts
- area-region tapping for simple single-series cards if enabled

## **Sync behavior**

If syncGroup is set:

- hover position syncs across sibling charts
- x-domain focus syncs
- brush selection optionally syncs
- viewport can optionally sync

This matches the strong cross-chart synchronization idea highlighted in the concept.

# **10\. How legend and additional information are implemented**

## **Legend**

Use the shared chart legend component.  
Each item should show:

- series marker/color
- series label
- visible/hidden state
- optional summary

Legend interactions:

- toggle visibility
- isolate one series
- keyboard focus and toggle
- compact wrapping
- custom builders

On compact, legend moves below chart by default, exactly as the visualization spec requires.

## **Tooltip**

Tooltip entries for area charts should support:

- series label
- formatted x value
- formatted y value
- stacked contribution
- percentage contribution in stacked100
- point label
- optional metadata rows

That percentage-contribution row is particularly valuable for stacked area charts.

## **Additional information layers**

Area charts should support:

- threshold lines
- highlighted ranges
- event markers
- forecast boundaries
- annotation labels
- uncertainty bands later

These should all use shared annotation / threshold contracts, not bespoke area-only APIs.

# **11\. How accessibility is guaranteed**

The chart concept identifies accessibility as one of the weakest areas across charting libraries, especially keyboard point exploration and generated semantic summaries. obers_ui's implementation rules also make accessibility mandatory for interactive UI.

So OiAreaChart should be unusually strong here.

## **11.1 Required semantics**

At minimum:

- label required
- semanticLabel optional override
- every series has a label
- legend items have semantic labels
- interactive overlays are keyboard reachable

## **11.2 Auto-generated summary**

If the developer does not override it, generate a summary that includes:

- chart type
- series count
- x-range
- y-range
- whether chart is stacked
- notable peak/trough
- dominant contributors if stacked and inferable

Example kind of narration:  
"Stacked area chart showing revenue by category from January to June. Three series. Food contributes the largest share across most of the range."

## **11.3 Keyboard exploration**

Keyboard exploration should work like line charts:

- left/right moves through logical x positions
- up/down moves series where relevant
- enter selects
- escape clears

But for stacked charts, announcements should also be able to include:

- absolute value
- cumulative value
- percentage share when meaningful

## **11.4 Non-color-only differentiation**

Because areas can overlap and translucency alone is not enough:

- hover/selection should add outline or pattern difference
- focus should add a clear ring/halo or emphasized outline
- legend markers should not rely on color alone where possible

## **11.5 Reduced motion**

If reduced motion is active:

- disable animated area reveals
- avoid sweeping fill transitions
- keep focus and tooltip transitions minimal

## **11.6 Optional data-table fallback**

For complex stacked charts, an accessible data table or linked summary view is especially valuable. This should integrate with the same fallback strategy used across the rest of the chart system.

# **12\. Every extensive test needed for OiAreaChart**

This should be a large suite, in the same spirit as obers_ui's broader responsive, modality, and performance testing expectations.

## **A. Rendering and layout tests**

- renders single area with numeric x-axis
- renders single area with time x-axis
- renders multiple unstacked areas
- renders stacked areas correctly
- renders stacked100 correctly
- respects container constraints
- fills available container
- legend moves below on compact
- below minimum useful size renders "View full screen"
- outline renders correctly when enabled
- gradient fill renders correctly when enabled
- plot clips correctly to plot area

## **B. Data mapping tests**

- mapper-based x/y extraction works with domain models
- shorthand single-series API builds default series correctly
- numeric, time, and category x-domain inference works
- explicit axis override beats inferred scale
- custom baseline mapping is respected
- series order and zIndex behave correctly
- custom semantic values map correctly

## **C. Stacking tests**

- stacked accumulates series in correct order
- stacked100 normalizes to 100%
- hidden legend series triggers recomputation of visible stack
- multiple stack groups stay independent
- negative-value policy behaves according to spec
- zero-only rows do not break normalization
- stacked tooltip values reflect current visible stack state

## **D. Missing-value tests**

- gap breaks area polygons correctly
- connect bridges missing values
- zero drops to baseline correctly
- interpolate estimates segments correctly
- missing first/last points do not create invalid polygons
- multiple consecutive missing values split geometry safely

## **E. Interpolation tests**

- straight area path matches direct segments
- stepped area creates correct step geometry
- monotone avoids invalid overshoot where applicable
- smooth produces expected curves
- fill path and outline path remain aligned after interpolation
- interpolation respects stacked lower/upper bounds

## **F. Interaction tests**

- hover tooltip appears on pointer
- tap tooltip appears on touch
- tooltip dismisses correctly
- crosshair tracks logical x position
- point tap callback fires correctly
- inside-area tap/hover works when enabled
- series visibility toggle callback fires
- brush/zoom update viewport correctly
- sync group shares hover/viewport when enabled
- selected series emphasis renders correctly

## **G. Accessibility tests**

- chart exposes semantic label
- generated summary includes chart type and stacked mode when relevant
- keyboard navigation across x positions works
- keyboard series switching works
- focused stacked point announces absolute and percentage value where relevant
- legend items are keyboard operable
- reduced motion disables nonessential fill animation
- non-color-only selected/focused state remains perceivable

## **H. Theming tests**

- fill colors derive from theme palette
- local chart theme override applies correctly
- series style override beats chart theme
- point-level override beats series style
- gradients and opacity resolve from chart theme
- light and dark goldens are stable
- dense-mode theme reduces visual complexity correctly

## **I. Responsive tests**

- compact moves legend below
- compact reduces marker and label density
- touch uses tap tooltip, pointer uses hover tooltip
- minimum viable size fallback appears correctly
- narrow layouts do not overflow labels
- larger breakpoints preserve intended detail
- layout adapts correctly across breakpoint helpers

## **J. Performance tests**

- 1,000 points render smoothly
- 10,000 points decimate correctly
- 100,000 points remain usable in performance mode
- stacked recomputation is cached by stack group
- hidden series are excluded from unnecessary processing
- marker suppression triggers at density threshold
- gradient simplification occurs in performance/compact mode
- path cache invalidation is scoped correctly
- repeated hover/zoom does not leak memory
- progressive refinement converges correctly

## **K. Golden tests**

- default single-series area chart
- multi-series translucent area chart
- stacked area chart
- stacked100 area chart
- compact area chart with legend below
- area chart with gradient fill
- area chart with threshold and annotation
- selected point with tooltip
- dark theme area chart
- dense-data simplified area chart

# **13\. Final recommendation for OiAreaChart**

OiAreaChart should be designed as a **first-class extension of the same Cartesian architecture as OiLineChart**, with three core differences:

- fill and baseline logic
- stacking and contribution logic
- stricter density/readability control because filled shapes get noisy faster

Everything else should feel familiar:

- same mapper-first data input
- same behavior-object interactivity
- same theme-native configuration model
- same responsive visualization rules as the rest of obers_ui
- same accessibility ambition, especially generated summaries and keyboard exploration
- same performance seriousness, with decimation and progressive rendering baked in

If done this way, OiAreaChart will feel like exactly what it should be inside obers_ui: not "another chart," but the natural filled counterpart to OiLineChart.

When you say **continue**, I'll move to the next deep dive: **OiBarChart&lt;T&gt;**.

continue 5

I'm on OiBarChart now. This is the first Cartesian chart where category layout, grouping, stacking, orientation, and compact readability become the main architectural challenges, so I'm treating it as the reference for all discrete comparison charts.

Thought for 7s

## **Part 6 - OiBarChart&lt;T&gt;**

OiBarChart is the first chart where **discrete layout rules** become the main architectural challenge.

With OiLineChart and OiAreaChart, the core difficulty is continuous plotting over an ordered domain. With bar charts, the hard problems shift to:

- category band layout
- grouped vs stacked composition
- horizontal vs vertical orientation
- label collision and truncation
- touch target sizing
- compact readability
- zero/baseline and negative-value handling
- large-category performance

So OiBarChart should become the **reference implementation for all discrete comparison charts** in obers_ui.

It still needs to obey the same overall package rules: tiered architecture, Oi\* naming, theme-derived styling, responsive adaptation, and mandatory accessibility, as defined by the actual implementation direction in AI_README and base_concept.

It also needs to absorb the strongest lessons from the chart concept:

- mapper-first data binding
- composable behaviors
- chart-type mixing
- responsive simplification
- built-in performance handling
- accessibility stronger than the current ecosystem
- grouped and stacked bars as first-class patterns, not separate mini-libraries

# **1\. What OiBarChart is**

OiBarChart&lt;T&gt; is the standard Cartesian chart for comparing values across categories or grouped categories.

It should be the default choice in obers_ui for:

- category comparison
- grouped series comparison
- stacked contribution breakdown
- ranked values
- progress toward a target
- positive/negative comparisons
- compact dashboard comparisons
- histograms later through a specialized mode

Architecturally:

OiBarChart&lt;T&gt; extends OiCartesianChart&lt;T&gt;

But publicly it should remain a dedicated composite with a very readable API, because bar charts are among the most frequently used charts in real products.

# **2\. How it looks, features, and important behavior**

Visually, OiBarChart should support these core forms:

- vertical bars
- horizontal bars
- grouped bars
- stacked bars
- 100% stacked bars
- positive/negative bars around a baseline
- target/background/reference bars
- rounded corners
- in-bar or outside labels
- category labels and group labels
- optional value markers / thresholds
- compact mini-bar variants later

The chart concept explicitly highlights grouped and stacked bar support as a fundamental requirement, and notes that some weaker libraries model this awkwardly while stronger systems make composition natural. fl_chart's grouped and stacked structure is one concrete precedent worth learning from, even though obers_ui should not copy its naming or nested-data style directly.

The most important visual behaviors are:

### **A. Orientation is a true mode**

Bar charts must work equally well vertically and horizontally. This should not require a separate widget.

### **B. Grouping and stacking are primary modes**

These should be expressed declaratively through a small number of readable props, not by forcing developers into a deeply nested internal rod model.

### **C. Category readability matters more than decoration**

On real product screens, bar charts often fail because labels overflow or too many categories are shown. obers_ui should aggressively handle this through responsive simplification.

### **D. Minimum touch target matters**

Bar segments must remain selectable and tappable on touch, and this should shape gap, padding, and hit-region rules.

That aligns well with base_concept's broader responsive and touch guidance, including 48dp touch-friendly interactions and adaptive compact behavior.

# **3\. How data input stays easy, logical, and consistent**

This should stay very close to the mapper-first pattern already established.

The chart concept explicitly recommends Syncfusion-style mapper functions as the best Flutter-idiomatic primary input model, while optionally supporting simpler field-reference styles later.

So the simplest case should look like:

OiBarChart&lt;SalesByCategory&gt;(  
label: 'Sales by category',  
data: items,  
x: (item) => item.category,  
y: (item) => item.value,  
)

For grouped comparison:

OiBarChart&lt;SalesByCategory&gt;(  
label: 'Sales by category and region',  
series: \[  
OiBarSeries&lt;SalesByCategory&gt;(  
id: 'north',  
label: 'North',  
data: north,  
x: (item) => item.category,  
y: (item) => item.value,  
),  
OiBarSeries&lt;SalesByCategory&gt;(  
id: 'south',  
label: 'South',  
data: south,  
x: (item) => item.category,  
y: (item) => item.value,  
),  
\],  
)

For stacked comparison:

OiBarChart&lt;SalesByCategory&gt;(  
label: 'Sales mix by category',  
stackMode: OiBarStackMode.stacked,  
series: \[  
...  
\],  
)

## **The consistency rule**

Like the other Cartesian charts, developers should mostly learn one shared data model:

- data
- x
- y
- optional series
- optional formatting / styling / semantics

What changes for bars is not the data-binding philosophy, but the layout semantics.

## **Important bar-specific mapping additions**

OiBarSeries&lt;T&gt; should also support:

- baseline
- groupKey
- stackGroup
- segmentLabel
- semanticValue
- targetValue
- barColor

Example:

class OiBarSeries&lt;T&gt; extends OiChartSeries&lt;T&gt; {  
final Object? Function(T item) x;  
final num? Function(T item) y;  
final num? Function(T item)? baseline;  
final String? Function(T item)? segmentLabel;  
final String? stackGroup;  
final Color? Function(T item, OiSeriesPointContext context)? barColor;  
final String? Function(T item)? semanticValue;  
}

That keeps it strongly aligned with the rest of the family.

# **4\. Overall structure, API, props, and callbacks**

## **Public widget shape**

class OiBarChart&lt;T&gt; extends StatefulWidget {  
final String label;  
final String? semanticLabel;  
<br/>final List&lt;T&gt;? data;  
final Object? Function(T item)? x;  
final num? Function(T item)? y;  
<br/>final List&lt;OiBarSeries<T&gt;>? series;  
<br/>final OiChartAxis? xAxis;  
final List&lt;OiChartAxis&gt;? yAxes;  
<br/>final OiBarOrientation orientation;  
final OiBarLayoutMode layoutMode;  
final OiBarStackMode stackMode;  
<br/>final OiChartLegendConfig? legend;  
final List&lt;OiChartBehavior&gt; behaviors;  
final List&lt;OiChartAnnotation&gt; annotations;  
final List&lt;OiChartThreshold&gt; thresholds;  
<br/>final OiChartThemeData? theme;  
final OiChartPerformanceConfig? performance;  
final OiChartAnimationConfig? animation;  
final OiChartAccessibilityConfig? accessibility;  
final OiChartSettingsDriverBinding? settings;  
final OiChartController? controller;  
final String? syncGroup;  
<br/>final OiChartLoadingStateConfig? loadingState;  
final OiChartEmptyStateConfig? emptyState;  
final OiChartErrorStateConfig? errorState;  
<br/>final ValueChanged&lt;OiBarChartSelection&gt;? onBarTap;  
final ValueChanged&lt;OiBarChartSeriesToggle&gt;? onSeriesVisibilityChange;  
final ValueChanged&lt;OiChartViewportState&gt;? onViewportChange;  
}

## **Bar series contract**

class OiBarSeries&lt;T&gt; extends OiChartSeries&lt;T&gt; {  
final Object? Function(T item) x;  
final num? Function(T item) y;  
final num? Function(T item)? baseline;  
<br/>final String? stackGroup;  
final int? zIndex;  
<br/>final bool showDataLabels;  
final bool showBackgroundTrack;  
final bool showTargetMarker;  
<br/>final OiSeriesStyle? style;  
<br/>final OiTooltipValueFormatter? valueFormatter;  
final OiAxisFormatter&lt;Object&gt;? xFormatter;  
final String? Function(T item)? segmentLabel;  
final String? Function(T item)? semanticValue;  
}

## **Enums**

enum OiBarOrientation {  
vertical,  
horizontal,  
}  
<br/>enum OiBarLayoutMode {  
single,  
grouped,  
stacked,  
stacked100,  
}  
<br/>enum OiBarStackMode {  
none,  
stacked,  
stacked100,  
}

I would likely keep either layoutMode alone or layoutMode + stackMode, but not let both compete. Publicly, a single expressive mode is probably cleaner:

- single
- grouped
- stacked
- stacked100

That reads better in obers_ui language.

## **Callback philosophy**

Keep callbacks compact and human-readable:

- onBarTap
- onBarLongPress
- onSeriesVisibilityChange
- onViewportChange
- onSelectionChange

Do not leak internal band-layout events into the public API.

# **5\. How it is customized through global obers_ui theming**

AI_README's implementation direction is explicit that colors should come from theme, theme access should be typed, and components should align with the package-wide theming model.

So OiBarChart should resolve its defaults through OiChartThemeData, just like line and area charts.

## **Global defaults especially important for bars**

The chart theme should provide defaults for:

- categorical palette
- positive / negative bar colors
- neutral / background track colors
- grouped spacing defaults
- stacked opacity rules
- corner radius defaults
- label placement defaults
- compact mode density rules
- selection / hover / inactive emphasis
- axis / grid / tooltip / legend styling

## **Theme-derived defaults that matter for bars**

Without local overrides, a bar chart should derive:

- bar fill from chart palette
- negative-value styling from chart negative semantic color
- background tracks from subtle theme surfaces/borders
- labels from theme typography
- grid and axes from chart theme axis/grid tokens
- focus and selection from interactive state tokens

This is important because the chart concept explicitly notes that host-platform theming is weak across many chart libraries, and obers_ui should do better by being fully theme-native.

# **6\. How it can be themed and configured on an element basis**

The same clean precedence should apply:

### **Layer 1 - global app theme**

Default chart-wide styling.

### **Layer 2 - local chart theme override**

Per-chart visual customization.

theme: OiChartThemeData(  
palette: ...,  
legend: ...,  
)

### **Layer 3 - series style**

Per-series fill, radius, label, target marker, hover, inactive styling.

OiBarSeries(  
id: 'north',  
label: 'North',  
style: OiSeriesStyle(  
fillColor: ...,  
borderRadius: ...,  
strokeWidth: 0,  
),  
)

### **Layer 4 - per-bar override**

Data-driven styling for individual bars.

barColor: (item, context) =>  
item.isForecast ? context.theme.palette.neutral : null,

## **Bar-specific style concerns**

OiSeriesStyle for bars should support:

- fillColor
- fillGradient
- borderRadius
- strokeColor
- strokeWidth
- backgroundTrackColor
- dataLabel
- targetMarkerStyle
- hoverStyle
- selectedStyle
- inactiveStyle

This gives good flexibility without turning the top-level API into noise.

# **7\. How the logic works and how exactly it should be implemented**

## **7.1 Data normalization**

Each series should normalize to:

- map category/domain x
- map numeric y
- resolve baseline
- resolve orientation
- resolve layout mode
- align categories across all visible series
- compute grouped/stacked band positions
- store final bar rect geometry for paint + hit testing

The normalized datum should track at least:

- raw category
- raw value
- scaled value
- baseline value
- group index
- stack lower bound
- stack upper bound
- final rendered rect
- semantic label/value text
- style overrides

## **7.2 Category alignment**

This is one of the most important bar-chart-specific implementation areas.

When multiple series are present, categories must align across visible series:

- category union is computed
- each series contributes a bar or stack segment for matching categories
- missing category entries are handled explicitly
- alignment rules stay predictable when series visibility changes

This is critical for grouped and stacked bar charts, and should be handled by the shared Cartesian engine rather than by each series ad hoc.

## **7.3 Band layout**

For a vertical chart:

- category axis uses a band scale
- each category gets a band
- each visible series gets a subgroup band if grouped
- stacked mode uses one bar position with segmented y extents

For a horizontal chart:

- same logic, but axes swap semantic roles

This is why bar charts need a proper band/category scale system, not just a reused linear/time axis abstraction.

## **7.4 Grouping logic**

Grouped bars:

- all visible series within a category divide the band width
- inner gap is configurable
- outer category gap is configurable
- hidden series reduce subgroup count automatically

## **7.5 Stacking logic**

Stacked bars:

- for each category, visible series are accumulated
- lower/upper extents are computed per segment
- positive and negative values should stack independently around baseline

This last point matters a lot. Good stacked bar logic should not mix positive and negative accumulation incorrectly.

## **7.6 stacked100**

For stacked100:

- each category's visible total becomes 100%
- each segment is normalized by visible category total
- tooltip and accessibility should still be able to expose raw values as well as percentages

## **7.7 Baseline and negative values**

Bars must handle:

- positive-only charts
- mixed positive/negative charts
- custom baselines
- diverging bar charts later

Rules:

- baseline defaults to zero
- bars extend away from baseline
- negative bars should be visually distinct if theme defines semantic negative styling
- rounded corners must adapt correctly so the "outer" end rounds, not the baseline end, unless configured otherwise

## **7.8 Horizontal orientation**

Horizontal bars are especially important for long labels and ranking views.  
So orientation should not be a hack or a rotated canvas trick. It should be a first-class layout path:

- category axis becomes vertical
- value axis becomes horizontal
- labels reflow appropriately
- interaction regions still behave naturally

This is better than generic rotation tricks and produces more stable semantics and label layout.

## **7.9 Background tracks and targets**

Bar charts are often used to show progress toward a target.  
So bar logic should support:

- background track bars
- target markers/lines
- in-bar vs outside labels
- optional "delta to target" display later

These should come from a clean style/config contract, not special bespoke chart variants.

# **8\. How performance is guaranteed even with huge datasets**

Bar charts usually fail from category explosion, not from millions of continuous points. The major performance problem is:

- too many categories
- too many labels
- too many stacked/grouped rects
- too much text layout

The chart concept still applies here: performance and adaptive complexity must be built in from day one, and current Flutter charting is weak in this area.

## **8.1 Rect-based rendering**

Bars are simpler than paths, which is an advantage.  
Use:

- batched rect drawing where possible
- cached geometry
- avoid rebuilding label layout unnecessarily

## **8.2 Category windowing / viewporting**

If there are very many categories:

- only render visible categories in viewport-based or paged/scrollable contexts
- apply overscan
- suppress labels outside visible range

This becomes especially relevant for horizontal bar charts with long ranked lists.

## **8.3 Label suppression**

This is the most important performance and readability feature for bars.  
Rules:

- hide category labels when density exceeds threshold
- rotate or truncate only when useful
- prefer horizontal orientation for long labels
- data labels should disappear before axis/category labels do
- compact layouts should reduce both category and value label density

This directly addresses the chart concept's criticism that chart libraries almost never reduce complexity automatically based on available space. obers_ui should.

## **8.4 Hidden series optimization**

Grouped and stacked charts should recompute only what changed when legend visibility changes:

- subgroup count
- stack totals
- affected category geometry

## **8.5 Text layout caching**

Cache:

- category labels
- value labels
- tooltip value strings if reused
- legend labels

This matters because large bar charts often become text-layout-bound before paint-bound.

## **8.6 Compact simplification**

In compact/mobile mode:

- fewer ticks
- fewer labels
- legend below
- maybe show only top N labels if extremely constrained
- reduced animation
- larger touch hit regions relative to visual bar width

That aligns with the visualization rules already defined in base_concept.

## **8.7 Progressive refinement where needed**

Bars usually do not need aggressive progressive rendering like giant line charts, but for very large category sets:

- render bars first
- then render labels if budget allows
- further reduce decorative layers when under load

# **9\. How interactivity works and can be configured**

The general obers_ui visualization interaction rules still apply:

- tap tooltip on touch
- hover tooltip on pointer
- legend below on compact
- full-screen fallback below minimum viable size

## **Default interaction behavior**

### **Pointer**

- hover highlights bar or segment
- hover shows tooltip
- click selects bar or series
- wheel/trackpad may scroll/zoom in large category views if enabled

### **Touch**

- tap selects/highlights a bar or segment
- tap shows tooltip
- tap elsewhere dismisses
- long press can lock tooltip
- hit regions must remain touch-friendly even when bars are visually thin

## **Behavior-based configuration**

behaviors: \[  
OiTooltipBehavior(),  
OiSelectionBehavior(  
selectionMode: OiChartSelectionMode.point,  
),  
\]

Bar charts often benefit less from crosshair than line charts, so it should be opt-in rather than a strong default.

## **Bar-specific interaction modes**

Interaction target should be configurable:

- bar
- stackSegment
- categoryGroup
- seriesWithinCategory

Recommended defaults:

- single / grouped → bar
- stacked / stacked100 → stack segment
- analytic comparison dashboards → shared category tooltip can be enabled

## **Sync behavior**

If syncGroup is set:

- category hover can sync across sibling charts
- selection can sync if appropriate
- viewport/category window can sync in advanced dashboard cases

That follows the same cross-chart synchronization idea highlighted in the chart concept.

# **10\. How legend and additional information are implemented**

## **Legend**

Use the shared chart legend component.  
Each item should expose:

- series color
- series label
- visible/hidden state
- optional summary

Legend interactions:

- toggle series visibility
- isolate one series
- keyboard operability
- wrap below on compact

That is fully consistent with the responsive visualization guidance already defined in base_concept.

## **Tooltip**

Tooltip should support:

- category label
- series label
- formatted value
- percentage contribution in stacked100
- raw value plus normalized value when useful
- target comparison if configured
- custom metadata rows

## **Additional information layers**

Bar charts should support:

- threshold lines
- target markers
- reference ranges
- annotation callouts
- background tracks
- goal / delta indicators

These should use shared annotation and threshold contracts wherever possible.

# **11\. How accessibility is guaranteed**

The chart concept is blunt that accessibility across chart libraries is weak, especially keyboard data exploration and automatically generated descriptions. obers_ui should make this a differentiator.

## **11.1 Required semantics**

At minimum:

- label required
- semanticLabel optional override
- each series has a label
- legend items are keyboard reachable and labeled
- bars/segments can be explored with keyboard

## **11.2 Auto-generated summary**

If the developer does not override it, generate a summary including:

- chart type
- category count
- series count
- grouped/stacked mode
- highest and lowest categories
- notable positive/negative values
- dominant contributors if stacked

Example:  
"Grouped bar chart showing sales across six categories for two regions. Electronics is highest overall. Accessories is lowest."

## **11.3 Keyboard exploration**

A focused bar chart should support:

- left/right or up/down move between categories depending on orientation
- secondary axis moves within grouped or stacked series
- enter selects
- escape clears
- announcements include category, series, and value

For stacked mode, keyboard exploration should be able to traverse individual segments, not just the total bar.

## **11.4 Touch target semantics**

On touch, hit regions should respect practical accessibility size even if the visual rect is thin. This matches the broader 48dp touch target philosophy found elsewhere in obers_ui patterns.

## **11.5 Non-color-only differentiation**

For grouped/stacked bars:

- selection/focus should add outline or emphasis beyond color alone
- patterns or border styles can help in high-contrast modes
- negative values should not depend solely on red/green distinction

## **11.6 Reduced motion**

If reduced motion is active:

- disable bouncy grow-in effects
- reduce hover/selection transitions
- keep state transitions minimal and stable

## **11.7 Accessible table fallback**

Especially for large category comparisons, exposing an optional data-table fallback is valuable and consistent with obers_ui's strong data-display patterns like OiTable and OiDetailView.

# **12\. Every extensive test needed for OiBarChart**

This should be a broad suite, in the same spirit as the strong responsive, accessibility, and performance expectations already visible elsewhere in obers_ui specs.

## **A. Rendering and layout tests**

- renders single vertical bar chart
- renders single horizontal bar chart
- renders grouped bars correctly
- renders stacked bars correctly
- renders stacked100 correctly
- respects container constraints
- fills available container
- legend moves below on compact
- minimum useful size fallback appears when too cramped
- background tracks render correctly
- target markers render correctly
- positive and negative bars render from baseline correctly
- rounded corners behave correctly in positive and negative cases

## **B. Data mapping tests**

- mapper-based x/y extraction works with domain models
- shorthand single-series API builds default series correctly
- category alignment across multiple series is correct
- explicit axis override beats inferred category scale
- missing category entries are handled according to spec
- per-bar semantic values map correctly
- per-bar color overrides map correctly

## **C. Layout mode tests**

- single mode renders one bar per category
- grouped mode subdivides category bands correctly
- stacked mode accumulates correctly
- stacked100 normalizes correctly
- hidden series recompute grouped widths correctly
- hidden series recompute stack totals correctly
- mixed positive/negative stacked values respect separate accumulations

## **D. Orientation tests**

- vertical orientation uses horizontal category axis + vertical value axis
- horizontal orientation swaps axes correctly
- labels adapt correctly in horizontal mode
- keyboard navigation direction adapts correctly by orientation
- tooltips anchor correctly in both orientations

## **E. Interaction tests**

- hover tooltip appears on pointer
- tap tooltip appears on touch
- tap selects correct bar
- stacked segment selection hits correct segment
- grouped bar selection hits correct subgroup
- tooltip dismisses correctly
- legend toggle callback fires
- category-group hover works when configured
- selection updates controller correctly
- sync group shares category focus when enabled

## **F. Accessibility tests**

- chart exposes semantic label
- generated summary includes layout mode and category count
- keyboard navigation moves through categories correctly
- grouped-mode keyboard navigation enters/exits subgroup positions correctly
- stacked-mode keyboard navigation traverses segments correctly
- focused item announces category, series, and value
- legend items are keyboard operable
- reduced motion disables nonessential animation
- high-contrast mode still differentiates visible states

## **G. Theming tests**

- bar colors derive from theme palette
- negative values can derive from semantic negative color
- local chart theme override applies correctly
- series style override beats chart theme
- per-bar override beats series style
- light and dark goldens are stable
- compact density settings affect gap/radius/label behavior correctly

## **H. Responsive tests**

- compact moves legend below
- compact reduces label density
- compact keeps tap interactions usable
- narrow layouts avoid overflowing category labels
- horizontal mode handles long labels better than vertical mode
- below minimum viable size shows "View full screen"
- pointer uses hover tooltip, touch uses tap tooltip

## **I. Performance tests**

- 500 categories render smoothly in balanced mode
- 1,000 grouped categories remain usable with label suppression
- hidden series avoid unnecessary recomputation
- text layout caching reduces repeat work
- viewport/category windowing renders only visible categories when enabled
- compact simplification triggers under density pressure
- repeated hover over many bars does not leak memory
- large stacked charts remain stable after rapid legend toggling

## **J. Golden tests**

- default single vertical bar chart
- default horizontal bar chart
- grouped bar chart
- stacked bar chart
- stacked100 bar chart
- bar chart with negative values
- chart with background tracks and target markers
- compact chart with legend below
- dark theme chart
- dense category chart with simplified labels

# **13\. Final recommendation for OiBarChart**

OiBarChart should become the canonical obers_ui chart for **discrete comparison**:

- mapper-first, domain-model-friendly input
- grouped, stacked, and horizontal behavior as first-class modes, not separate widgets
- fully theme-native styling rather than manual visual config by default
- stronger responsive adaptation than typical chart libraries, especially around label density and compact legibility
- accessibility that includes generated summaries, keyboard traversal, and usable touch hit regions
- performance focused on category explosion, text layout, and layout recomputation rather than only paint speed

If done well, OiBarChart will define how all discrete charts in obers_ui should feel: clear, readable, adaptive, and extremely predictable for developers.

When you say **continue**, I'll move to the next deep dive: **OiScatterChart&lt;T&gt;**.

continue 6

I'm moving into OiScatterChart next. This is the first chart where point density, correlation reading, marker encoding, and proximity-based interaction become the defining architectural concerns rather than series continuity or category layout.

Thought for 8s

## **Part 7 - OiScatterChart&lt;T&gt;**

OiScatterChart is the first chart where **point density, correlation reading, visual encoding, and proximity-based interaction** become the central architectural concerns.

A line chart assumes continuity. A bar chart assumes discrete category comparison. A scatter chart assumes neither. Its job is to let developers plot many independent observations in a shared Cartesian space and help users see:

- correlation
- clustering
- outliers
- spread
- gaps
- patterns over time or categories when encoded visually
- relationships between multiple measures

That makes OiScatterChart the reference chart in obers_ui for **point-cloud visualization** and the architectural base for later derivatives like OiBubbleChart. It still has to follow the same package rules as everything else: use the tiered hierarchy, Oi\* naming, typed theme integration, obers_ui layout primitives, and mandatory accessibility. The chart concept also strongly supports the design choices that matter most here: mapper-first binding, composable behaviors, built-in decimation and progressive rendering, chart mixing inside a shared Cartesian engine, and accessibility stronger than the current chart ecosystem.

# **1\. What OiScatterChart is**

OiScatterChart&lt;T&gt; is the standard Cartesian chart for plotting independent x/y observations without implying continuity between them.

It should be the default chart in obers_ui for:

- correlation analysis
- outlier detection
- quality-control point clouds
- trend inspection without connecting lines
- benchmark comparisons
- feature-space visualization
- dense observational datasets
- later overlays like regression lines, contours, or cluster hulls

Architecturally:

OiScatterChart&lt;T&gt; extends OiCartesianChart&lt;T&gt;

It should not be a separate engine. It should reuse the same Cartesian substrate as line, area, and bar charts:

- axes
- domains and scales
- viewport
- behaviors
- legend
- annotations
- thresholds
- controller
- sync
- persistence
- theme

That shared Cartesian base is important because the concept explicitly identifies chart-type mixing as a first-class requirement and criticizes architectures where a chart type lives in its own isolated world.

# **2\. How it looks, features, and important behavior**

Visually, OiScatterChart should support these core forms:

- single scatter series
- multiple scatter series
- variable marker size later through OiBubbleChart
- variable marker color per point
- variable marker shape by series or point class
- selected and hovered points
- jitter for overlapping categorical scatter later
- optional regression overlays later
- optional convex hull / cluster outlines later
- optional point labels
- optional density simplification for very large clouds
- optional brushing/selection regions

The chart matrix in the concept explicitly includes scatter as a core chart type across all compared libraries, which reinforces that this is one of the foundational chart forms you need to get right.

The most important visual behaviors are:

### **A. Points must remain independent**

A scatter chart should never imply continuity by default. No connecting line, no filled area, no "trend" suggestion unless the developer explicitly adds a regression or overlay annotation later.

### **B. Overlap handling matters**

The main readability problem is not axis continuity or category overflow. It is point overlap and density.  
So the chart has to think about:

- marker opacity
- marker size
- hover emphasis
- clustering or density simplification later
- brush selection
- performance-aware hit testing

### **C. Marker encoding is central**

Unlike bars or lines, the marker itself carries much of the semantics:

- position
- size later
- shape
- fill
- stroke
- highlight state

### **D. Proximity interaction matters more than exact contact**

With dense scatter plots, exact tapping of a single pixel-perfect point is unrealistic, especially on touch. Proximity-based nearest-point logic is essential.

That fits well with obers_ui's broader touch and adaptive interaction philosophy: compact layouts, pointer vs touch distinctions, and accessibility-forward interaction zones.

# **3\. How data input stays easy, logical, and consistent**

This should remain very close to the same mapper-first pattern already established.

The chart concept explicitly recommends mapper functions as the primary Flutter-friendly binding model and warns against forcing data into chart-library-owned point models.

So the simplest case should look like:

OiScatterChart&lt;Observation&gt;(  
label: 'Height vs weight',  
data: observations,  
x: (item) => item.heightCm,  
y: (item) => item.weightKg,  
)

For multiple series:

OiScatterChart&lt;Observation&gt;(  
label: 'Height vs weight by cohort',  
series: \[  
OiScatterSeries&lt;Observation&gt;(  
id: 'group-a',  
label: 'Group A',  
data: groupA,  
x: (item) => item.heightCm,  
y: (item) => item.weightKg,  
),  
OiScatterSeries&lt;Observation&gt;(  
id: 'group-b',  
label: 'Group B',  
data: groupB,  
x: (item) => item.heightCm,  
y: (item) => item.weightKg,  
),  
\],  
)

## **The consistency rule**

This should feel almost identical to:

- OiLineSeries
- OiAreaSeries
- OiScatterSeries
- later OiBubbleSeries

The developer should mostly learn one family pattern:

- data
- x
- y
- optional series
- optional formatters
- optional style callbacks
- optional semantic mappers

That is how the whole chart package stays like one convention.

## **Scatter-specific mapping additions**

OiScatterSeries&lt;T&gt; should also support:

- pointLabel
- pointColor
- pointShape
- semanticValue
- optional group
- optional opacity
- later size for bubble derivation, though that should live more cleanly on OiBubbleSeries

Example:

class OiScatterSeries&lt;T&gt; extends OiChartSeries&lt;T&gt; {  
final Object? Function(T item) x;  
final num? Function(T item) y;  
final String? Function(T item)? pointLabel;  
final Color? Function(T item, OiSeriesPointContext context)? pointColor;  
final OiMarkerShape? Function(T item)? pointShape;  
final String? Function(T item)? semanticValue;  
}

That is still easy to read and keeps the API highly domain-model-friendly.

# **4\. Overall structure, API, props, and callbacks**

## **Public widget shape**

class OiScatterChart&lt;T&gt; extends StatefulWidget {  
final String label;  
final String? semanticLabel;  
<br/>final List&lt;T&gt;? data;  
final Object? Function(T item)? x;  
final num? Function(T item)? y;  
<br/>final List&lt;OiScatterSeries<T&gt;>? series;  
<br/>final OiChartAxis? xAxis;  
final List&lt;OiChartAxis&gt;? yAxes;  
<br/>final OiChartLegendConfig? legend;  
final List&lt;OiChartBehavior&gt; behaviors;  
final List&lt;OiChartAnnotation&gt; annotations;  
final List&lt;OiChartThreshold&gt; thresholds;  
<br/>final OiChartThemeData? theme;  
final OiChartPerformanceConfig? performance;  
final OiChartAnimationConfig? animation;  
final OiChartAccessibilityConfig? accessibility;  
final OiChartSettingsDriverBinding? settings;  
final OiChartController? controller;  
final String? syncGroup;  
<br/>final OiChartLoadingStateConfig? loadingState;  
final OiChartEmptyStateConfig? emptyState;  
final OiChartErrorStateConfig? errorState;  
<br/>final ValueChanged&lt;OiScatterPointSelection&gt;? onPointTap;  
final ValueChanged&lt;OiScatterSeriesToggle&gt;? onSeriesVisibilityChange;  
final ValueChanged&lt;OiChartViewportState&gt;? onViewportChange;  
}

## **Scatter series contract**

class OiScatterSeries&lt;T&gt; extends OiChartSeries&lt;T&gt; {  
final Object? Function(T item) x;  
final num? Function(T item) y;  
<br/>final bool showMarkers;  
final bool showDataLabels;  
final OiMarkerStyle? marker;  
final OiSeriesStyle? style;  
<br/>final OiTooltipValueFormatter? valueFormatter;  
final OiAxisFormatter&lt;Object&gt;? xFormatter;  
final String? Function(T item)? pointLabel;  
final String? Function(T item)? semanticValue;  
final Color? Function(T item, OiSeriesPointContext context)? pointColor;  
final OiMarkerShape? Function(T item)? pointShape;  
}

## **Important scatter-specific configs**

class OiScatterInteractionConfig {  
final OiScatterHitMode hitMode;  
final double hitRadius;  
final bool preferNearestByX;  
final bool allowBrushSelection;  
}

enum OiScatterHitMode {  
nearestPoint,  
nearestVisiblePoint,  
rectangularBrush,  
lassoLater,  
}

The reason to give hit testing an explicit contract is that scatter interaction is dominated by nearest-point resolution, not simply "did the cursor touch a bar rect." That should be part of the public architecture from the beginning.

## **Callback philosophy**

Keep callbacks clean:

- onPointTap
- onPointLongPress
- onSeriesVisibilityChange
- onViewportChange
- onSelectionChange

No public leakage of raw renderer internals.

# **5\. How it is customized through global obers_ui theming**

AI_README's implementation rules are clear: colors come from theme, text and layouts follow obers_ui conventions, and accessibility is mandatory. So OiScatterChart should resolve through the same OiChartThemeData used by the rest of the chart family.

## **Global theme defaults especially important for scatter**

The chart theme should provide:

- categorical palette
- neutral marker defaults
- hover halo defaults
- selected marker defaults
- marker outline defaults
- crosshair style
- brush overlay style
- axis / grid / tooltip / legend styling
- dense-mode marker simplification rules

## **Theme-derived defaults that matter here**

Without local overrides, OiScatterChart should derive:

- series marker colors from chart palette
- marker outline contrast from surface + palette logic
- selected/focused markers from interactive theme state tokens
- tooltip surface from overlay/popover theme tokens
- brush overlay from selection/focus colors
- axis/grid from chart theme axis/grid tokens

This is especially important because the chart concept explicitly notes that host-theme integration is weak across many chart libraries, and obers_ui should improve on that with a fully theme-native approach.

# **6\. How it can be themed and configured on an element basis**

The same four-level precedence should apply here too.

### **Layer 1 - global app theme**

Default scatter appearance everywhere.

### **Layer 2 - local chart theme override**

Per-chart override.

theme: OiChartThemeData(  
palette: ...,  
selection: ...,  
)

### **Layer 3 - series style**

Per-series marker shape, size, outline, opacity, hover emphasis.

OiScatterSeries(  
id: 'group-a',  
label: 'Group A',  
style: OiSeriesStyle(  
marker: OiMarkerStyle(  
size: 8,  
shape: OiMarkerShape.circle,  
),  
opacity: 0.75,  
),  
)

### **Layer 4 - point-level override**

Per-point dynamic marker styling.

pointColor: (item, context) =>  
item.isOutlier ? context.theme.palette.negative : null,

## **Scatter-specific style concerns**

OiSeriesStyle for scatter should support:

- marker
- fillColor
- strokeColor
- strokeWidth
- opacity
- dataLabel
- hoverStyle
- selectedStyle
- inactiveStyle

And OiMarkerStyle should support:

- size
- shape
- fill
- stroke
- strokeWidth
- hoverSizeDelta
- selectedSizeDelta

That keeps customization deep but still aligned with the same styling language as the other charts.

# **7\. How the logic works and how exactly it should be implemented**

This is where scatter differs most sharply from line and bar.

## **7.1 Data normalization**

Each series should normalize as follows:

- map x
- map y
- resolve style and semantic overrides
- determine axis scale types
- convert to scaled viewport coordinates
- compute marker bounds / hit regions
- build spatial lookup structures for interaction

The normalized point should track:

- raw x
- raw y
- scaled x
- scaled y
- marker size
- marker style
- label text
- semantic text
- visibility/density flags
- hit-test region

## **7.2 Scale resolution**

Scatter charts usually use:

- numeric x + numeric y
- time x + numeric y
- category x + numeric y in jittered or point-placement views
- numeric x + category y in ranked distributions

So the chart should still use the same proper scale system:

- linear
- logarithmic
- time
- point/category where needed

That aligns with the broader chart concept's emphasis on strong scale systems rather than weak boolean toggles.

## **7.3 Marker layout**

Each visible point resolves to a marker center plus marker style.  
Important rule:

- marker geometry should be generated lazily and cheaply
- if a point is density-suppressed, keep only a lightweight interaction representation where appropriate
- if labels are off, do not compute their layout

## **7.4 Spatial indexing for interaction**

This is one of the most important scatter-specific implementation areas.

Nearest-point resolution should not linearly scan every point on every hover if the dataset is large.  
Use one of:

- bucketed grid index
- quadtree-like spatial index
- sorted x buckets for predominantly time/numeric x charts

This matters because the concept explicitly pushes for built-in performance architecture from day one, and scatter is one of the chart types where naive hit testing fails fastest.

## **7.5 Overlap handling**

Scatter plots frequently have overlapping points.  
At minimum the chart should support:

- configurable marker opacity
- hover and selected emphasis
- brush selection
- optional jitter mode later
- optional density overlay later

Do not try to "solve" overlap by default through magical displacement unless the developer opts in.

## **7.6 Brush selection**

Scatter is one of the main chart types where brushing is genuinely useful.  
A rectangular brush should:

- be behavior-driven
- produce a set of selected points
- optionally persist selection via controller/settings
- integrate with sync groups for dashboard workflows later

## **7.7 Regression and analytic overlays later**

Even if first-wave OiScatterChart does not compute regression internally, the architecture should already make overlays easy through:

- annotations
- thresholds
- future extension hooks

That fits the concept's recommendation for a rich extension lifecycle.

# **8\. How performance is guaranteed even with huge datasets**

This is a major concern for scatter charts.

The concept explicitly compares performance approaches across libraries and highlights progressive rendering and built-in decimation as baseline requirements for a serious spec. It also notes that WebGL-backed scatter variants handle huge point sets elsewhere, while Flutter libraries are weak here today.

For obers_ui, OiScatterChart should be architected around the assumption that developers may render:

- 5,000 points
- 25,000 points
- 100,000 points
- more in performance mode later

## **8.1 Viewport-first processing**

Only process visible points plus overscan.  
If zoomed, do not spend work on offscreen points.

## **8.2 Density-aware rendering**

Scatter charts should support adaptive simplification such as:

- reduce marker stroke detail at high density
- reduce marker size in dense views when appropriate
- suppress labels aggressively
- optionally lower alpha or merge style complexity in performance mode

The concept explicitly criticizes existing libraries for failing to adapt visual complexity automatically to space and density. obers_ui should do better here.

## **8.3 Spatial indexing**

This is not optional.  
Large scatter charts need indexed nearest-neighbor lookup and efficient brush-region filtering.

## **8.4 Progressive rendering**

For very large clouds:

- render a coarse visible point pass immediately
- refine marker detail if budget allows
- reduce expensive hover calculations under load

The concept specifically highlights progressive/incremental rendering as one of the most important strategies in stronger chart systems.

## **8.5 Marker batching**

Scatter markers should be painted in batches by shape/style group where possible rather than as one tiny bespoke paint path per point.

## **8.6 Label suppression**

Data labels should default to off for scatter charts except very small datasets.  
Show labels only when:

- explicitly enabled
- selected
- hovered
- filtered to a manageable subset

## **8.7 Hit-test budget protection**

When point count is extreme:

- limit hover candidate search by spatial bucket
- avoid per-point semantics nodes
- avoid rebuilding tooltip entries for hidden/offscreen series
- cap simultaneous hover overlays

## **8.8 Future streaming readiness**

Even if streaming is not first-wave, scatter architecture should not block:

- append-only point updates
- rolling-window domains
- controller-driven viewport windows

The concept explicitly notes that real-time streaming support is weak across chart libraries and worth planning for upfront.

# **9\. How interactivity works and can be configured**

Scatter charts should follow the same modality rules as the rest of the visualization system:

- hover tooltip on pointer
- tap tooltip on touch
- compact adaptation
- accessible keyboard exploration
- optional sync across related charts

## **Default interaction behavior**

### **Pointer**

- hover highlights nearest point
- hover shows tooltip
- drag may brush-select if configured
- click selects point
- wheel/trackpad may zoom if enabled

### **Touch**

- tap resolves nearest point within hit radius
- tap shows tooltip
- long press can lock selection or enter inspect mode
- drag can brush-select if enabled and appropriate
- hit radius should be more forgiving than visual marker size

## **Behavior-based configuration**

behaviors: \[  
OiTooltipBehavior(),  
OiSelectionBehavior(  
selectionMode: OiChartSelectionMode.point,  
),  
OiBrushBehavior(),  
OiZoomPanBehavior(  
allowPan: true,  
allowPinchZoom: true,  
),  
\]

The concept explicitly recommends behavior objects as the right primary interaction model, and scatter benefits from this especially strongly because tooltip, selection, zoom, and brush are all independently valuable.

## **Scatter-specific interaction modes**

The chart should support configurable point targeting:

- nearest visible point
- nearest point in focused series
- shared x-proximity mode for mixed charts later
- rectangular brush selection

Recommended default:

- nearest visible point with a reasonable hit radius

## **Sync behavior**

If syncGroup is set:

- hover focus can sync across related charts
- selection can sync
- viewport can sync where appropriate

This is consistent with the concept's emphasis on cross-chart synchronization as a valuable dashboard feature.

# **10\. How legend and additional information are implemented**

## **Legend**

Use the shared chart legend component.  
Each legend item should represent a scatter series through:

- marker sample
- label
- visible/hidden state
- optional emphasis state

Legend interactions:

- toggle series visibility
- isolate one series
- keyboard operability
- compact wrapping below chart when needed

## **Tooltip**

Scatter tooltips should support:

- series label
- formatted x value
- formatted y value
- point label
- semantic metadata rows
- optional outlier or classification text

Because points are independent, tooltip content is often more item-specific than in line charts. So builder customization matters here.

## **Additional information layers**

Scatter charts should support:

- regression lines later
- threshold zones
- reference bands
- quadrants
- annotated points
- selection hulls later

These should use shared annotations, thresholds, and future extension hooks rather than scatter-only special cases.

# **11\. How accessibility is guaranteed**

The concept explicitly calls out accessibility as weak across current chart libraries and notes that keyboard navigation for exploring points is effectively missing. obers_ui should treat this as a major opportunity.

## **11.1 Required semantics**

At minimum:

- label required
- semanticLabel optional override
- each series labeled
- legend items keyboard reachable and labeled
- focused/selected points narratable

## **11.2 Auto-generated chart summary**

If the developer does not provide a custom one, generate a summary including:

- chart type
- series count
- x and y ranges
- point count or approximate count
- notable outliers where inferable
- general spread or clustering hints where appropriate

Example:  
"Scatter chart showing height on the x-axis and weight on the y-axis for 240 observations across two cohorts. Most points cluster in the midrange, with a small number of high-value outliers."

This directly follows the concept's recommendation to auto-generate chart descriptions from configuration and data ranges.

## **11.3 Keyboard exploration**

A focused scatter chart should support:

- arrow keys move to nearest logical neighboring point
- up/down can switch series if useful
- home/end jump to min/max x within focused series
- enter selects
- escape clears selection

Important implementation note:  
Scatter keyboard traversal should be spatially meaningful, not just index order. For example:

- left/right prefer nearest point in that direction
- up/down prefer nearest point in that vertical direction

That would be a real differentiator compared with the broader chart ecosystem, which the concept says does not currently provide point-by-point keyboard exploration.

## **11.4 Non-color-only differentiation**

Since multiple scatter series may rely on marker appearance:

- shape differences should be available
- selection/focus should add outline or size halo
- high-contrast mode should not depend only on hue differences

## **11.5 Reduced motion**

If reduced motion is active:

- suppress nonessential marker-scale or ripple effects
- reduce hover animation
- keep selection transitions minimal

## **11.6 Accessible table fallback**

For analytic use cases, an optional linked table or detail list of selected/filtered points should be possible and fits well with obers_ui's strong data-display ecosystem like OiTable and OiDetailView.

# **12\. Every extensive test needed for OiScatterChart**

This should be a serious test matrix, especially around density and interaction correctness.

## **A. Rendering and layout tests**

- renders single scatter series with numeric axes
- renders multiple series correctly
- respects container constraints
- fills available container
- legend moves below on compact
- axes and grid render correctly
- selected/hovered marker emphasis renders correctly
- minimum useful size fallback appears when too constrained

## **B. Data mapping tests**

- mapper-based x/y extraction works with domain models
- shorthand single-series API produces correct default series
- numeric, time, and category-compatible axis inference works
- explicit axis override beats inferred scale
- point labels and semantic values map correctly
- per-point color overrides map correctly
- per-point shape overrides map correctly

## **C. Marker style tests**

- default marker style resolves from theme
- series marker override applies correctly
- point-level override beats series style
- hover and selected states apply expected style changes
- hidden series are not painted
- inactive series style fades correctly when focus/isolate is active

## **D. Interaction tests**

- hover selects nearest point on pointer devices
- tap selects nearest point on touch devices
- tooltip appears correctly
- tooltip dismisses correctly
- brush selection returns correct subset
- point tap callback fires with correct payload
- selection updates controller correctly
- zoom/pan updates viewport correctly
- sync group propagates focus/selection when enabled
- hit radius behavior is correct for dense point clouds

## **E. Spatial navigation tests**

- keyboard left moves to nearest logical point on the left
- keyboard right moves to nearest logical point on the right
- keyboard up/down navigation behaves spatially correctly
- home/end jump to expected boundary points
- enter selects focused point
- escape clears selection

## **F. Accessibility tests**

- chart exposes semantic label
- generated summary includes chart type and point count
- focused point narration includes x/y values and series label
- legend items are keyboard operable
- reduced motion disables nonessential animations
- high-contrast theme still differentiates series and states

## **G. Theming tests**

- marker colors derive from theme palette
- local chart theme override applies correctly
- series style override beats chart theme
- point-level override beats series style
- tooltip, legend, and selection visuals resolve from chart theme
- light and dark goldens are stable

## **H. Responsive tests**

- compact layout moves legend below
- compact layout reduces label complexity
- touch uses tap-nearest interaction, pointer uses hover-nearest interaction
- narrow layouts avoid label overflow
- density mode suppresses labels in constrained layouts
- below minimum viable size shows fallback presentation

## **I. Performance tests**

- 5,000 points render smoothly in balanced mode
- 25,000 points remain usable with spatial indexing enabled
- 100,000 points remain inspectable in performance mode
- viewport filtering excludes offscreen points
- brush selection remains performant on large datasets
- nearest-point search uses index rather than full scan
- label suppression avoids excessive text layout
- repeated hover and zoom do not leak memory
- progressive rendering/refinement behaves correctly

## **J. Golden tests**

- default single-series scatter chart
- multi-series scatter chart
- scatter chart with selected point and tooltip
- dense scatter chart in simplified mode
- compact scatter chart with legend below
- dark theme scatter chart
- high-contrast scatter chart
- scatter chart with annotations and thresholds

# **13\. Final recommendation for OiScatterChart**

OiScatterChart should be the canonical obers_ui chart for **independent point observations and relationship analysis**:

- mapper-first data binding so real domain models work naturally in Flutter
- full reuse of the shared Cartesian substrate so it mixes cleanly with other chart types later
- behavior-based interactivity because tooltip, selection, brush, and zoom all need to remain composable
- stronger performance architecture than typical Flutter charting, especially spatial indexing, viewport-first processing, and progressive simplification
- accessibility that actually supports point exploration, generated summaries, and meaningful keyboard navigation, which the concept identifies as broadly missing in current libraries
- theme-native styling and responsive density reduction so the chart still feels like obers_ui rather than a bolted-on chart engine

If done well, OiScatterChart becomes not just a scatter plot, but the architectural foundation for all high-density point-based charts that follow.

When you say **continue**, I'll move to the next deep dive: **OiBubbleChart&lt;T&gt;**.

continue 7

I'm on OiBubbleChart now. This one needs to stay deliberately close to OiScatterChart, because the biggest DX win is making "third dimension via size" feel like a natural extension of the same point-based model, not a new API to learn.

Thought for 5s

## **Part 8 - OiBubbleChart&lt;T&gt;**

OiBubbleChart should be designed as the **natural size-encoding extension of OiScatterChart**, not as a separate charting concept.

That is the most important DX decision here. Developers should feel that they already know how to use it:

- same mapper-first data input
- same Cartesian structure
- same point-based behaviors
- same theming model
- same accessibility contract
- same performance model

The only real conceptual addition is that a point now carries a **third quantitative channel** through marker size.

That direction fits the chart concept well: mapper functions should be primary, interactivity should be behavior-based, chart types should share an engine instead of becoming isolated widgets, built-in performance work is necessary from day one, and accessibility in current chart ecosystems is weak enough that obers_ui can do much better. It also stays aligned with AI_README's real implementation language: Oi\* naming, theme-native behavior, and consistency with the rest of the package.

# **1\. What OiBubbleChart is**

OiBubbleChart&lt;T&gt; is a Cartesian chart for plotting independent x/y observations where marker size represents an additional quantitative value.

It should be the default chart in obers_ui for:

- three-variable comparison
- portfolio / market maps
- priority matrices
- impact vs effort views
- risk likelihood vs severity visualizations
- relationship analysis where magnitude matters
- product and analytics dashboards with encoded weight

Architecturally:

OiBubbleChart&lt;T&gt; extends OiCartesianChart&lt;T&gt;

But more specifically, it should be treated as a **scatter-derived composite** sharing almost all of its substrate with OiScatterChart.

That is the cleanest architecture:

- same axes
- same scales
- same viewport
- same point normalization pipeline
- same tooltip / selection / brush / zoom behaviors
- same sync and persistence
- same accessibility model

Only these parts truly change:

- size mapping
- bubble radius / area normalization
- overlap/readability rules
- legend semantics for size encoding
- accessibility narration for the third metric

# **2\. How it looks, features, and important behavior**

Visually, OiBubbleChart should support these core forms:

- single bubble series
- multiple bubble series
- fixed color by series
- dynamic color by point
- fixed shape by series
- optional shape override by point
- selected and hovered bubbles
- optional labels for highlighted bubbles
- optional bubble outlines
- optional opacity control for overlap
- optional size legend
- optional brushing
- optional annotations, thresholds, quadrants, and guides

The important thing is that the user must immediately read:

- x position
- y position
- size meaning
- series grouping where applicable

The most important visual behaviors are:

### **A. Size must encode area, not just radius**

If developers pass a value like revenue, the chart should make it visually proportional in a sensible way. Humans perceive bubble size by area more than radius, so the size scale must be designed carefully.

### **B. Overlap is a first-class concern**

Bubble charts can become unreadable quickly because size amplifies overlap much more than plain scatter plots. So the library needs strong defaults for:

- max radius
- alpha / opacity
- outlines
- selected/hover emphasis
- label suppression
- brush selection

### **C. Size must never break interaction**

Even a tiny bubble still needs a usable hit target on touch. Even a very large bubble should not dominate hit testing in a way that makes neighboring points impossible to inspect.

### **D. Size legends are part of the chart, not an afterthought**

Unlike normal scatter charts, bubble charts often need a dedicated explanation for size encoding.

# **3\. How data input stays easy, logical, and consistent**

This should feel almost exactly like OiScatterChart, with one extra mapper: size.

That is the strongest possible DX choice and fully matches the chart concept's recommendation to decouple data from presentation via mapper functions rather than forcing a library-owned point model.

So the simplest case should look like:

OiBubbleChart&lt;ProjectScore&gt;(  
label: 'Impact vs effort vs reach',  
data: projects,  
x: (item) => item.effort,  
y: (item) => item.impact,  
size: (item) => item.reach,  
)

For multiple series:

OiBubbleChart&lt;ProjectScore&gt;(  
label: 'Impact vs effort by department',  
series: \[  
OiBubbleSeries&lt;ProjectScore&gt;(  
id: 'marketing',  
label: 'Marketing',  
data: marketingProjects,  
x: (item) => item.effort,  
y: (item) => item.impact,  
size: (item) => item.reach,  
),  
OiBubbleSeries&lt;ProjectScore&gt;(  
id: 'product',  
label: 'Product',  
data: productProjects,  
x: (item) => item.effort,  
y: (item) => item.impact,  
size: (item) => item.reach,  
),  
\],  
)

## **The consistency rule**

Developers should feel that bubble is just:

- OiScatterSeries  
   plus
- size

That is exactly the kind of family consistency that makes obers_ui feel like one package.

## **Bubble-specific mapping additions**

OiBubbleSeries&lt;T&gt; should support:

- size
- pointLabel
- pointColor
- pointShape
- semanticValue
- optional opacity
- optional sizeLabel

Example:

class OiBubbleSeries&lt;T&gt; extends OiChartSeries&lt;T&gt; {  
final Object? Function(T item) x;  
final num? Function(T item) y;  
final num? Function(T item) size;  
<br/>final String? Function(T item)? pointLabel;  
final String? Function(T item)? sizeLabel;  
final Color? Function(T item, OiSeriesPointContext context)? pointColor;  
final OiMarkerShape? Function(T item)? pointShape;  
final String? Function(T item)? semanticValue;  
}

That stays easy to read and keeps the data source completely flexible.

# **4\. Overall structure, API, props, and callbacks**

## **Public widget shape**

class OiBubbleChart&lt;T&gt; extends StatefulWidget {  
final String label;  
final String? semanticLabel;  
<br/>final List&lt;T&gt;? data;  
final Object? Function(T item)? x;  
final num? Function(T item)? y;  
final num? Function(T item)? size;  
<br/>final List&lt;OiBubbleSeries<T&gt;>? series;  
<br/>final OiChartAxis? xAxis;  
final List&lt;OiChartAxis&gt;? yAxes;  
final OiBubbleSizeScale? sizeScale;  
final OiBubbleLegendConfig? sizeLegend;  
<br/>final OiChartLegendConfig? legend;  
final List&lt;OiChartBehavior&gt; behaviors;  
final List&lt;OiChartAnnotation&gt; annotations;  
final List&lt;OiChartThreshold&gt; thresholds;  
<br/>final OiChartThemeData? theme;  
final OiChartPerformanceConfig? performance;  
final OiChartAnimationConfig? animation;  
final OiChartAccessibilityConfig? accessibility;  
final OiChartSettingsDriverBinding? settings;  
final OiChartController? controller;  
final String? syncGroup;  
<br/>final OiChartLoadingStateConfig? loadingState;  
final OiChartEmptyStateConfig? emptyState;  
final OiChartErrorStateConfig? errorState;  
<br/>final ValueChanged&lt;OiBubblePointSelection&gt;? onPointTap;  
final ValueChanged&lt;OiBubbleSeriesToggle&gt;? onSeriesVisibilityChange;  
final ValueChanged&lt;OiChartViewportState&gt;? onViewportChange;  
}

## **Bubble series contract**

class OiBubbleSeries&lt;T&gt; extends OiChartSeries&lt;T&gt; {  
final Object? Function(T item) x;  
final num? Function(T item) y;  
final num? Function(T item) size;  
<br/>final bool showMarkers;  
final bool showDataLabels;  
final OiMarkerStyle? marker;  
final OiSeriesStyle? style;  
<br/>final OiTooltipValueFormatter? valueFormatter;  
final OiTooltipValueFormatter? sizeFormatter;  
final OiAxisFormatter&lt;Object&gt;? xFormatter;  
final String? Function(T item)? pointLabel;  
final String? Function(T item)? sizeLabel;  
final String? Function(T item)? semanticValue;  
final Color? Function(T item, OiSeriesPointContext context)? pointColor;  
final OiMarkerShape? Function(T item)? pointShape;  
}

## **Bubble size scale**

class OiBubbleSizeScale {  
final double minRadius;  
final double maxRadius;  
final OiBubbleSizeMapping mapping;  
final bool clamp;  
}

enum OiBubbleSizeMapping {  
area,  
radius,  
sqrtArea,  
}

Recommended default:

- mapping: OiBubbleSizeMapping.area

That keeps the API explicit and lets advanced teams override the visual semantics only when they really mean to.

## **Callback philosophy**

Keep callbacks minimal and consistent:

- onPointTap
- onPointLongPress
- onSeriesVisibilityChange
- onViewportChange
- onSelectionChange

# **5\. How it is customized through global obers_ui theming**

The same typed theme model should apply here too. AI_README's implementation direction clearly favors theme-native components over manual styling islands.

So OiBubbleChart should resolve through OiChartThemeData.

## **Global defaults especially important for bubble charts**

The chart theme should provide defaults for:

- categorical palette
- default bubble opacity
- outline thickness
- hover halo style
- selected bubble emphasis
- size legend appearance
- dense-mode simplification behavior
- axis / grid / tooltip / legend / brush styling

## **Theme-derived defaults that matter here**

Without local overrides, OiBubbleChart should derive:

- series colors from chart palette
- outlines from contrast-aware surface rules
- selected/focused visuals from interaction state tokens
- tooltip surface from overlay/popover theme
- size legend typography from chart / text theme
- brush overlays from selection theme tokens

Because the chart concept explicitly points out that theming integration is inconsistent across libraries, this is an area where obers_ui should be clearly better.

# **6\. How it can be themed and configured on an element basis**

Use the same four-level precedence as all other charts.

### **Layer 1 - global app theme**

Default bubble styling across the app.

### **Layer 2 - local chart theme override**

Per-chart visual override.

theme: OiChartThemeData(  
palette: ...,  
selection: ...,  
)

### **Layer 3 - series style**

Per-series marker shape, opacity, outline, hover/selected states.

OiBubbleSeries(  
id: 'marketing',  
label: 'Marketing',  
style: OiSeriesStyle(  
marker: OiMarkerStyle(  
shape: OiMarkerShape.circle,  
strokeWidth: 1.5,  
),  
opacity: 0.65,  
),  
)

### **Layer 4 - point-level override**

Per-bubble dynamic color/shape styling.

pointColor: (item, context) =>  
item.isRisky ? context.theme.palette.negative : null,

## **Bubble-specific style concerns**

OiSeriesStyle and OiMarkerStyle should support:

- fillColor
- strokeColor
- strokeWidth
- opacity
- marker.shape
- hoverStyle
- selectedStyle
- inactiveStyle

One important bubble-specific rule:

- opacity defaults matter much more here than in line or bar charts, because overlap can otherwise make the chart unreadable very quickly.

# **7\. How the logic works and how exactly it should be implemented**

## **7.1 Data normalization**

Each series should normalize as follows:

- map x
- map y
- map size
- resolve style and semantic overrides
- infer or resolve scale types
- normalize size into radius
- convert to viewport coordinates
- compute hit regions and bubble bounds
- build spatial lookup structures for interaction

The normalized point should track:

- raw x
- raw y
- raw size
- scaled x
- scaled y
- resolved radius
- marker style
- semantic text
- label text
- hit-test region
- density / visibility flags

## **7.2 Size normalization**

This is the main implementation difference from scatter.

Bubble charts should normalize size using a stable scale:

- determine visible size domain from series or explicit override
- map size value into \[minRadius, maxRadius\]
- use area-aware mapping by default
- clamp invalid or extreme values if configured

Important design rule:

- negative sizes should not be silently rendered as weird geometry
- either reject, clamp, or explicitly document the handling
- recommended default: treat negative or null size as hidden or minimum-visible only if opted in; otherwise exclude and expose in diagnostics

## **7.3 Bubble bounds and clipping**

Large bubbles can extend beyond plot bounds.  
The chart must decide clearly whether:

- clip to plot area
- allow overflow within chart padding
- reserve extra overscan for interaction

Recommended default:

- paint clipped to plot area
- hit testing only within visible plot region
- allow partial bubble visibility at edges

## **7.4 Overlap handling**

Bubble overlap is a core behavior problem.  
At minimum the chart should support:

- opacity
- selected/hover emphasis
- brush selection
- label suppression
- ordering by size

A very important rendering rule:

- draw larger bubbles first, smaller bubbles later, or make this configurable  
   That often improves readability because smaller bubbles remain visible on top.

So provide:

enum OiBubbleDrawOrder {  
seriesOrder,  
smallestOnTop,  
largestOnTop,  
}

Recommended default:

- smallestOnTop

## **7.5 Spatial indexing for interaction**

Like scatter charts, bubble charts need indexed nearest-neighbor lookup.  
But the index should account for radius as well as center position.

Interaction should support:

- nearest center
- nearest visible edge/hit region
- brush selection

Recommended default:

- nearest visible bubble by effective hit distance

## **7.6 Size legend logic**

A bubble chart often needs a size legend that shows 2-4 reference circles with labels.  
This should be a shared subcomponent, not something every chart rebuilds ad hoc.

The size legend should:

- pick representative values
- format them cleanly
- adapt for compact vs expanded layouts
- remain theme-driven

## **7.7 Future analytic overlays**

Even if regression, quadrants, density contours, or cluster hulls are not first-wave, OiBubbleChart should already make them easy through:

- annotations
- thresholds
- extension hooks

That is consistent with the chart concept's recommendation for a rich extension lifecycle.

# **8\. How performance is guaranteed even with huge datasets**

Bubble charts are more expensive than scatter charts because:

- marker size varies
- overlap is heavier
- hit regions are larger
- sorting by size may be needed
- labels become even more expensive

So this must be designed in from the start.

## **8.1 Viewport-first processing**

Only normalize and paint visible points plus overscan.

## **8.2 Spatial indexing**

This is mandatory for large bubble charts.  
Nearest-point lookup and brush selection must use spatial indexing, not full scans.

## **8.3 Density-aware simplification**

In dense/performance modes:

- reduce outline complexity
- suppress labels
- reduce hover candidate count
- simplify style differences
- optionally cap rendered bubble count in extreme cases if explicitly configured

## **8.4 Size-aware batching**

Where possible, batch drawing by compatible styles/shapes, while still respecting draw order.

## **8.5 Progressive rendering**

For very large datasets:

- render a coarse visible bubble pass
- refine detail if frame budget allows
- reduce expensive interactivity under load

This is directly in line with the chart concept's emphasis on progressive rendering and built-in performance architecture.

## **8.6 Label suppression**

Labels should default to off except:

- tiny datasets
- selected bubbles
- hovered bubbles
- explicit opt-in

## **8.7 Touch hit-budget protection**

When bubbles are extremely dense:

- do not try to build per-point heavyweight semantics nodes
- keep hit radius sane
- prefer nearest-bubble logic instead of ambiguous overlapping hover spam

## **8.8 Future scalability note**

The concept highlights that WebGL-backed scatter variants elsewhere can handle 100K-1M points, while typical Flutter charting is far weaker. obers_ui should therefore build OiBubbleChart with a performance mode mindset from the beginning, even if it stays Canvas-based.

# **9\. How interactivity works and can be configured**

OiBubbleChart should follow the same modality rules as the rest of the chart system:

- hover tooltip on pointer
- tap tooltip on touch
- brush and zoom through behaviors
- sync through syncGroup
- keyboard exploration for accessibility

## **Default interaction behavior**

### **Pointer**

- hover highlights nearest bubble
- hover shows tooltip
- click selects bubble
- drag may brush if configured
- wheel/trackpad may zoom if enabled

### **Touch**

- tap resolves nearest bubble within effective hit radius
- tap shows tooltip
- long press can lock selection
- drag can brush if enabled
- visual bubble size and touch target size must not be treated as the same thing

That last point matters. A tiny bubble still needs a usable touch target, consistent with obers_ui's broader touch-target philosophy. OiTouchTarget exists specifically to enforce 48dp minimum touch target size on touch devices.

## **Behavior-based configuration**

behaviors: \[  
OiTooltipBehavior(),  
OiSelectionBehavior(  
selectionMode: OiChartSelectionMode.point,  
),  
OiBrushBehavior(),  
OiZoomPanBehavior(  
allowPan: true,  
allowPinchZoom: true,  
),  
\]

This stays fully aligned with the chart concept's recommendation that interactivity should be composed from reusable behaviors rather than giant monolithic config objects.

## **Bubble-specific interaction modes**

The chart should support:

- nearest visible bubble
- nearest bubble center
- brush selection
- focused series only

Recommended default:

- nearest visible bubble with radius-aware hit logic

## **Sync behavior**

If syncGroup is set:

- hover can sync across sibling charts
- selection can sync
- viewport can sync where appropriate

That aligns with the concept's emphasis on cross-chart synchronization as a valuable dashboard pattern.

# **10\. How legend and additional information are implemented**

## **Legend**

Use the shared chart legend for series identity:

- series color
- label
- visible/hidden state

## **Size legend**

Bubble charts additionally need a dedicated size legend component:

- representative circles
- formatted size labels
- optional title like "Reach" or "Revenue"

This should be configurable through something like:

class OiBubbleLegendConfig {  
final bool show;  
final String? label;  
final int sampleCount;  
final OiLegendPosition position;  
}

Recommended behavior:

- on compact, size legend may move below or merge into secondary legend presentation
- on expanded layouts, it can sit beside the plot if space allows

## **Tooltip**

Bubble tooltips should support:

- series label
- formatted x value
- formatted y value
- formatted size value
- point label
- custom metadata rows

Because bubble charts encode three variables, tooltip clarity matters even more than in scatter charts.

## **Additional information layers**

Bubble charts should support:

- quadrants
- thresholds
- annotations
- reference bands
- risk zones
- highlighted selections

These should use shared contracts, not bubble-only ad hoc features.

# **11\. How accessibility is guaranteed**

The chart concept clearly says accessibility is weak across current chart libraries and that generated descriptions plus keyboard exploration are major opportunities.

OiBubbleChart should take that seriously.

## **11.1 Required semantics**

At minimum:

- label required
- semanticLabel optional override
- each series labeled
- size dimension labeled when meaningful
- legend and size legend keyboard reachable

## **11.2 Auto-generated chart summary**

If the developer does not override it, generate a summary including:

- chart type
- x-axis meaning
- y-axis meaning
- size meaning
- series count
- point count
- notable large bubbles or outliers where inferable

Example:  
"Bubble chart showing effort on the x-axis, impact on the y-axis, and reach as bubble size for 42 projects across two departments."

## **11.3 Keyboard exploration**

A focused bubble chart should support:

- spatial arrow-key navigation similar to scatter
- enter to select
- escape to clear
- narration that includes x, y, and size

For example:  
"Project Atlas. Effort 7. Impact 9. Reach 14,000. Marketing."

## **11.4 Non-color-only differentiation**

Because size already carries meaning, color should not be the only differentiator:

- shape differences available
- selection/focus adds outline or halo
- high-contrast mode should remain readable

## **11.5 Reduced motion**

If reduced motion is active:

- suppress size-pulse or marker-grow effects
- reduce hover animations
- keep transitions minimal

## **11.6 Accessible table fallback**

For analytic contexts, an optional linked table or detail list of filtered / selected bubbles should be possible and consistent with obers_ui's broader data-display ecosystem like OiTable and OiDetailView.

# **12\. Every extensive test needed for OiBubbleChart**

## **A. Rendering and layout tests**

- renders single bubble series correctly
- renders multiple bubble series correctly
- respects container constraints
- fills available container
- legend and size legend render correctly
- compact layout moves legends appropriately
- minimum useful size fallback appears when needed
- selected and hovered bubble emphasis renders correctly

## **B. Data mapping tests**

- mapper-based x/y/size extraction works with domain models
- shorthand single-series API builds default series correctly
- explicit axis override beats inferred scale
- size mapping normalizes correctly across domain
- null and invalid size values are handled according to spec
- point label and semantic value mapping works correctly
- point-level color and shape overrides map correctly

## **C. Size-scaling tests**

- area-based size mapping computes expected radii
- radius-based size mapping computes expected radii
- min/max radius limits are respected
- clamp behavior works correctly
- explicit size-domain override behaves correctly
- size legend samples reflect actual scale correctly

## **D. Overlap and draw-order tests**

- smallestOnTop ordering draws smaller bubbles above larger ones
- largestOnTop ordering behaves correctly
- series-order drawing behaves correctly
- overlap with transparency remains visually stable
- selection emphasis remains visible in overlapping cases

## **E. Interaction tests**

- hover resolves nearest visible bubble on pointer
- tap resolves nearest visible bubble on touch
- tooltip includes x, y, and size values
- tooltip dismisses correctly
- brush selection returns correct subset
- point tap callback fires with correct payload
- selection updates controller correctly
- zoom/pan updates viewport correctly
- sync group propagates hover/selection when enabled

## **F. Spatial navigation tests**

- keyboard left/right/up/down navigate spatially meaningful neighboring bubbles
- home/end jump to expected boundary bubbles
- enter selects focused bubble
- escape clears selection

## **G. Accessibility tests**

- chart exposes semantic label
- generated summary includes size dimension
- focused bubble narration includes x, y, and size
- legend and size legend are keyboard operable
- reduced motion disables nonessential effects
- high-contrast mode still differentiates states and series

## **H. Theming tests**

- bubble colors derive from theme palette
- local chart theme override applies correctly
- series style override beats chart theme
- point-level override beats series style
- size legend styling resolves from chart theme
- light and dark goldens are stable

## **I. Responsive tests**

- compact layout reduces label complexity
- compact layout repositions legends appropriately
- touch uses tap-nearest interaction
- pointer uses hover-nearest interaction
- narrow layouts avoid overflow
- below minimum viable size shows fallback presentation

## **J. Performance tests**

- 5,000 bubbles render smoothly in balanced mode
- 25,000 bubbles remain inspectable with spatial indexing
- viewport filtering excludes offscreen bubbles
- nearest-bubble search uses index rather than full scan
- label suppression avoids excessive layout work
- repeated hover and zoom do not leak memory
- progressive rendering behaves correctly under load
- draw-order sorting is cached/incremental where possible

## **K. Golden tests**

- default single-series bubble chart
- multi-series bubble chart
- bubble chart with size legend
- dense bubble chart in simplified mode
- compact bubble chart with legends below
- dark theme bubble chart
- high-contrast bubble chart
- bubble chart with annotations and thresholds

# **13\. Final recommendation for OiBubbleChart**

OiBubbleChart should be treated as the **scatter-family chart with a third quantitative encoding channel**, not as a separate mental model:

- mapper-first input with x, y, and size keeps DX extremely clear
- full reuse of the Cartesian and scatter substrate keeps the whole chart package coherent
- behavior-based interactivity keeps tooltip, brush, zoom, and selection composable
- performance has to account for overlap, size-aware hit testing, and large point sets from the beginning
- accessibility must narrate the third dimension, which is where many chart libraries would currently fall short
- size legends should be first-class and theme-native, not improvised per screen

If done well, OiBubbleChart will feel like exactly what it should inside obers_ui: a richer scatter chart that developers can pick up instantly because the conventions are already familiar.

When you say **continue**, I'll move to the next deep dive: **OiComboChart&lt;T&gt;**.

continue 8

I'm on OiComboChart now. This is one of the most strategically important charts in the whole library, because it proves whether the shared Cartesian architecture is truly real or whether every chart type secretly still behaves like its own silo.

Thought for 14s

## **Part 9 - OiComboChart&lt;T&gt;**

OiComboChart is one of the most important charts in the entire library.

It is the chart that proves whether the shared Cartesian architecture is actually real. If OiComboChart feels elegant, then the line, area, bar, scatter, and future candlestick families truly belong to one coherent system. If it feels awkward, then the library is still secretly a collection of isolated chart widgets.

That matters because your chart analysis is very clear on one key point: one of the biggest differences between weaker and stronger chart libraries is whether they support **mixed chart types inside one shared coordinate system** in a first-class way. It also clearly recommends declarative APIs, mapper-first binding, and composable interaction behaviors as the strongest foundation for Flutter.

It also has to stay fully aligned with the real obers_ui implementation language:

- strict Oi naming
- props that read like English
- all colors from theme
- layouts through obers_ui primitives
- accessibility as a requirement
- the tiered architecture rather than one giant widget subsystem

# **1\. What OiComboChart is**

OiComboChart&lt;T&gt; is a Cartesian chart that allows multiple series types to coexist in one shared plot area and coordinate system.

It should be the default chart in obers_ui for:

- actual vs forecast comparisons
- bars plus trend line overlays
- area plus line highlight overlays
- column plus target line analytics
- mixed KPI dashboards
- benchmark overlays
- multi-axis analytic visuals later
- advanced reporting where one encoding is not enough

Architecturally:

OiComboChart&lt;T&gt; extends OiCartesianChart&lt;T&gt;

But unlike the single-family wrappers, its public reason to exist is explicit:

- a developer wants to mix OiLineSeries, OiAreaSeries, OiBarSeries, OiScatterSeries, and later OiBubbleSeries in one chart
- the library should make that feel intended, not hacky

So OiComboChart is not a separate engine. It is the **first-class mixed-series façade** over the shared Cartesian renderer registry.

# **2\. How it looks, features, and important behavior**

Visually, OiComboChart should support these combinations cleanly:

- bars + line
- bars + multiple lines
- bars + area + line
- scatter + line
- area + line
- line + forecast dashed line + target threshold
- grouped bars + line overlay
- stacked bars + line overlay
- later candlestick + volume bars
- later bubble + line or threshold overlays where useful

The crucial visual principle is:

### **A. One plot, many series types, one mental model**

A combo chart should not feel like multiple charts layered on top of each other. It should feel like one chart with several valid series renderers inside it.

### **B. Shared axes, explicit secondary axes only when needed**

The default should be one shared x-axis and one shared y-scale family. Secondary y-axes should be opt-in and very explicit.

### **C. Visual hierarchy matters more than in single-type charts**

Because multiple encodings coexist, the chart must help the developer establish emphasis:

- bars often as base layer
- area as soft supporting layer
- line as precise focus layer
- scatter as point-detail overlay
- thresholds and annotations above all

### **D. Interactions must unify the chart, not fragment it**

Tooltip, hover, sync, selection, and keyboard navigation must work across all visible series types as one system.

That combination-focused design follows directly from the chart analysis, which highlights mixed chart support as a major strategic differentiator and favors declarative, composable configuration rather than siloed widgets.

# **3\. How data input stays easy, logical, and consistent**

This is where OiComboChart can either become amazing or become a mess.

The right choice is:

**Do not invent a new data model.  
**Instead, let the chart accept the same familiar series objects developers already know:

- OiLineSeries&lt;T&gt;
- OiAreaSeries&lt;T&gt;
- OiBarSeries&lt;T&gt;
- OiScatterSeries&lt;T&gt;
- later OiBubbleSeries&lt;T&gt;
- later OiCandlestickSeries&lt;T&gt;

That gives you the best possible DX because developers do not need to learn "combo-specific series."

So usage should look like this:

OiComboChart&lt;SalesPoint&gt;(  
label: 'Revenue with forecast',  
series: \[  
OiBarSeries&lt;SalesPoint&gt;(  
id: 'actual-bars',  
label: 'Actual',  
data: actual,  
x: (item) => item.month,  
y: (item) => item.revenue,  
),  
OiLineSeries&lt;SalesPoint&gt;(  
id: 'trend-line',  
label: 'Trend',  
data: trend,  
x: (item) => item.month,  
y: (item) => item.revenue,  
),  
OiLineSeries&lt;SalesPoint&gt;(  
id: 'forecast-line',  
label: 'Forecast',  
data: forecast,  
x: (item) => item.month,  
y: (item) => item.revenue,  
style: OiSeriesStyle.dashed(),  
),  
\],  
)

That is the cleanest possible input model.

## **The consistency rule**

A developer should feel:

- "I already know line, area, bar, and scatter series"
- "Combo just lets me pass several of them together"

That is exactly the kind of unified convention you want in obers_ui.

## **Should all series share one generic base list?**

Yes. Publicly, OiComboChart should accept something like:

final List&lt;OiCartesianSeries<T&gt;> series;

Where:

- OiLineSeries&lt;T&gt; extends OiCartesianSeries&lt;T&gt;
- OiAreaSeries&lt;T&gt; extends OiCartesianSeries&lt;T&gt;
- OiBarSeries&lt;T&gt; extends OiCartesianSeries&lt;T&gt;
- OiScatterSeries&lt;T&gt; extends OiCartesianSeries&lt;T&gt;

That is the right abstraction line.

# **4\. Overall structure, API, props, and callbacks**

## **Public widget shape**

class OiComboChart&lt;T&gt; extends StatefulWidget {  
final String label;  
final String? semanticLabel;  
<br/>final List&lt;OiCartesianSeries<T&gt;> series;  
<br/>final OiChartAxis? xAxis;  
final List&lt;OiChartAxis&gt;? yAxes;  
<br/>final OiComboTooltipMode tooltipMode;  
final OiComboSeriesDrawOrder drawOrder;  
final bool allowMixedSeriesSelection;  
<br/>final OiChartLegendConfig? legend;  
final List&lt;OiChartBehavior&gt; behaviors;  
final List&lt;OiChartAnnotation&gt; annotations;  
final List&lt;OiChartThreshold&gt; thresholds;  
<br/>final OiChartThemeData? theme;  
final OiChartPerformanceConfig? performance;  
final OiChartAnimationConfig? animation;  
final OiChartAccessibilityConfig? accessibility;  
final OiChartSettingsDriverBinding? settings;  
final OiChartController? controller;  
final String? syncGroup;  
<br/>final OiChartLoadingStateConfig? loadingState;  
final OiChartEmptyStateConfig? emptyState;  
final OiChartErrorStateConfig? errorState;  
<br/>final ValueChanged&lt;OiComboPointSelection&gt;? onPointTap;  
final ValueChanged&lt;OiComboSeriesToggle&gt;? onSeriesVisibilityChange;  
final ValueChanged&lt;OiChartViewportState&gt;? onViewportChange;  
}

## **Important combo-specific enums**

enum OiComboTooltipMode {  
nearestItem,  
sharedX,  
sharedCategory,  
focusedSeriesOnly,  
}  
<br/>enum OiComboSeriesDrawOrder {  
automatic,  
barsBelowLines,  
declarationOrder,  
custom,  
}

## **Why these matter**

A combo chart needs explicit rules for:

- how tooltip grouping works
- how different series types stack visually
- how selections are resolved when several series overlap at the same logical x position

Without those, the chart becomes unpredictable fast.

## **Callback philosophy**

Keep callbacks aligned with the rest of the library:

- onPointTap
- onPointLongPress
- onSeriesVisibilityChange
- onViewportChange
- onSelectionChange

Do not expose renderer-specific callback types like onBarTap and onLineTap at the top level. The whole point of combo is unified behavior.

# **5\. How it is customized through global obers_ui theming**

The same rule still applies: all colors and visual defaults should come from theme, not ad hoc widget-local magic. AI_README is explicit about that.

So OiComboChart should resolve from OiChartThemeData, exactly like the other charts.

## **Global defaults especially important for combo**

The chart theme should provide:

- categorical palette
- cross-series contrast defaults
- draw-order defaults
- line/bar/area/scatter compatible state styles
- tooltip styling for mixed entries
- legend marker resolution rules
- dense-mode simplification defaults
- axis / grid / annotation / threshold styling

## **Theme-derived defaults that matter here**

Without local overrides:

- bar series pull colors from chart palette
- line series use the same palette but with renderer-appropriate defaults
- area series use softened or opacity-adjusted palette values
- scatter series use marker defaults compatible with the palette
- selection and hover derive from shared interactive tokens
- tooltip surfaces derive from overlay/popover surfaces
- axes and grids derive from chart theme axis/grid tokens

This is important because mixed charts are one of the easiest places for visual inconsistency to creep in if the theme system is weak.

# **6\. How it can be themed and configured on an element basis**

Use the same layered precedence as all other charts.

### **Layer 1 - global app theme**

Default chart-wide visuals.

### **Layer 2 - local chart theme override**

Per-chart override.

theme: OiChartThemeData(  
palette: ...,  
tooltip: ...,  
)

### **Layer 3 - series style**

Each series still styles itself through its normal renderer-specific series style.

OiBarSeries(  
id: 'actual',  
label: 'Actual',  
style: OiSeriesStyle(  
fillColor: ...,  
),  
),  
<br/>OiLineSeries(  
id: 'forecast',  
label: 'Forecast',  
style: OiSeriesStyle(  
strokeWidth: 2,  
dashPattern: \[6, 4\],  
),  
),

### **Layer 4 - point-level override**

Per-item overrides still work the same way as in the underlying chart family.

That is a major DX benefit: combo does not change how a line series or bar series is customized. It only changes where the series is rendered.

## **Combo-specific visual config**

The chart itself may additionally support:

- renderer draw order
- tooltip grouping mode
- secondary axis assignments
- legend grouping rules

But it should not re-declare every style concern from the child series.

# **7\. How the logic works and how exactly it should be implemented**

This is the most important section for OiComboChart.

## **7.1 Series registry and renderer dispatch**

Internally, OiComboChart should never special-case every chart type directly in the widget.

Instead:

- normalize all incoming OiCartesianSeries&lt;T&gt;
- dispatch each one to a registered renderer
- each renderer returns:
  - geometry
  - hit regions
  - tooltip contributions
  - accessibility descriptors
  - animation diff inputs

This makes mixed charts genuinely scalable.

So conceptually:

abstract class OiCartesianSeriesRenderer&lt;TSeries extends OiCartesianSeries&gt; {  
bool supports(OiCartesianSeries series);  
OiRenderedSeries layout(...);  
void paint(...);  
OiHitTestResult? hitTest(...);  
}

That is the architectural core of combo.

## **7.2 Shared x-domain alignment**

All combo charts need one shared x-domain model.

That means:

- categorical series align to shared categories
- time series align by logical x positions
- numeric x charts share one x scale

This shared domain is what allows:

- shared tooltips
- cross-series crosshair
- synchronized keyboard movement
- aligned annotations and thresholds

## **7.3 Shared y-domain resolution**

For same-axis charts:

- the visible y-domain is the union of all visible series extents

For secondary-axis charts later:

- each series declares which y-axis it belongs to
- legends and tooltips must surface that clearly

Important rule:

- default should remain one y-axis unless there is a strong need otherwise
- multi-axis combo charts are powerful but also easy to misuse

## **7.4 Automatic draw ordering**

Combo charts need sane defaults for what renders above what.

Recommended default:

- background/reference layers
- bars
- areas
- lines
- scatter/bubbles
- crosshair, selections, annotations, tooltips

That usually produces the most readable result.

But it should remain configurable with:

- automatic
- declaration order
- custom z-index style on series

## **7.5 Unified tooltip resolution**

This is one of the hardest combo-specific logic problems.

Tooltip modes should work like this:

### **nearestItem**

Show the nearest data item across all visible series.

### **sharedX**

Show all visible series values aligned to the nearest x position.

### **sharedCategory**

For categorical charts, show all visible series entries for the hovered/tapped category.

### **focusedSeriesOnly**

Only show the series currently hovered, selected, or keyboard-focused.

Recommended defaults:

- time/numeric x combo charts → sharedX
- bar/category combo charts → sharedCategory

That gives the most coherent analytic experience.

## **7.6 Mixed hit testing**

Combo charts need a unified hit-testing coordinator.  
That coordinator should:

- query all visible series renderers
- receive hit candidates
- resolve winner by tooltip mode, proximity, and z-priority
- produce one final interaction model

This is much cleaner than letting each renderer fight for events independently.

## **7.7 Selection logic**

Selections should support:

- point/item selection
- series selection
- x-domain selection
- category selection
- brush selection where relevant

Important rule:  
selection semantics should be based on the configured interaction mode, not hardcoded to the renderer type.

## **7.8 Legend visibility and recomputation**

Since combo charts mix multiple series types, legend visibility changes can have significant layout effects:

- hidden bar series reduce grouped width calculations
- hidden area/line series reduce y-domain unions
- shared tooltip entries recalculate
- stacked variants later recalculate visible totals

That recomputation should be scoped and incremental.

# **8\. How performance is guaranteed even with huge datasets**

This is especially important because combo charts combine the cost of multiple renderers.

The chart analysis explicitly emphasizes built-in decimation, progressive rendering, and performance-aware architecture as a major requirement for a serious Flutter charting system.

## **8.1 Renderer-local optimization**

Each renderer should keep its own performance rules:

- line/area → decimation and path caching
- bar → label suppression and rect batching
- scatter/bubble → spatial indexing and density suppression

Combo should not flatten all performance logic into one generic layer.

## **8.2 Shared viewport-first processing**

The combo container should still enforce:

- only visible-domain work
- overscan bounds
- offscreen label suppression
- visible-series-only calculations

## **8.3 Tooltip and hit-test budget control**

Mixed charts can get expensive if every hover queries everything naively.  
So:

- only visible series participate
- some renderers can downshift under load
- hit testing should use a coordinator with early exits and indexing

## **8.4 Unified density simplification**

In compact/performance modes:

- bars suppress labels
- areas reduce fill complexity
- lines suppress markers
- scatter suppresses labels and style complexity
- tooltip entry counts can be capped if necessary

That keeps the whole chart coherent rather than letting one series type stay "full detail" while everything else degrades.

## **8.5 Progressive rendering**

For large mixed charts:

- render coarse base layers first
- refine higher-detail layers if budget allows
- prioritize focused/selected series for detail under load

That is the right combo-chart interpretation of progressive rendering.

## **8.6 Cached layout phases**

Cache separately:

- domain resolution
- axis ticks
- renderer-normalized visible data
- tooltip-alignment indexes
- label layouts
- geometry by series

Invalidate only the affected stages on:

- data change
- visibility change
- viewport change
- theme change
- density mode change

# **9\. How interactivity works and can be configured**

OiComboChart should follow the same general chart interaction rules already established in obers_ui:

- hover tooltips on pointer
- tap tooltips on touch
- legends below on compact
- minimum viable size fallback
- reduced detail on mobile/compact layouts

## **Default interaction behavior**

### **Pointer**

- hover resolves shared interaction target
- tooltip shows grouped or nearest entries
- crosshair optional but valuable
- click selects point/item/series depending on config
- wheel/trackpad may zoom if enabled

### **Touch**

- tap resolves nearest logical interaction group
- tooltip appears on tap
- second tap elsewhere dismisses
- long press can lock focus/crosshair
- pinch zoom if enabled

## **Behavior-based configuration**

behaviors: \[  
OiTooltipBehavior(),  
OiCrosshairBehavior(),  
OiZoomPanBehavior(  
allowPan: true,  
allowPinchZoom: true,  
),  
OiSelectionBehavior(  
selectionMode: OiChartSelectionMode.point,  
),  
\]

This is especially important in combo charts because the alternative would be a giant monolithic interaction config blob, which is exactly what your chart analysis argues against.

## **Combo-specific interaction detail**

The chart should support:

- nearest item mode
- shared x/category tooltip mode
- series-isolation interaction
- keyboard focus traversal across mixed series
- synchronized hover/selection with other charts

Recommended defaults:

- categorical combo → shared category
- time-series combo → shared x

## **Sync behavior**

If syncGroup is set:

- hover focus syncs across sibling charts
- viewport optionally syncs
- brush/selection can sync
- sibling charts resolve their own nearest local series entries from the shared x/category focus

That follows the same dashboard value highlighted in the chart analysis around synchronized multi-chart experiences.

# **10\. How legend and additional information are implemented**

## **Legend**

The shared chart legend should already support mixed-series entries.  
Each item should show:

- series marker appropriate to renderer type
- label
- visible/hidden state
- optional emphasis state

Examples:

- bar series → small filled rect marker
- line series → short line stroke marker
- area series → fill + outline sample
- scatter series → marker sample

That lets the legend reflect the mixed chart honestly.

## **Tooltip**

The tooltip model for combo charts must support multiple heterogeneous entries:

- line value
- bar value
- area contribution
- scatter point details
- later bubble size values

Entry formatting should still be delegated to each series' formatter where possible.

## **Additional information layers**

Combo charts often benefit from:

- thresholds
- event markers
- target lines
- forecast boundaries
- release notes / annotations
- highlighted ranges

These should all come from the shared annotation and threshold system, not from combo-only bespoke features.

# **11\. How accessibility is guaranteed**

The chart analysis is especially valuable here because accessibility is one of the clearest weak points across the chart ecosystem. Generated summaries and keyboard data exploration are major opportunities.

OiComboChart should turn that into a strength.

## **11.1 Required semantics**

At minimum:

- label required
- semanticLabel optional override
- every series labeled
- legend items keyboard reachable and labeled
- interaction group semantics coherent across mixed series

## **11.2 Auto-generated summary**

If the developer does not override it, generate a summary that includes:

- chart type
- series types present
- series count
- x-range or category count
- y-range
- notable maxima/minima
- whether the chart includes bars + line, area + line, etc.

Example:  
"Combo chart showing monthly revenue as bars and forecast as dashed line from January to December. Three visible series."

That is especially useful because combo charts are more semantically complex than single-type charts.

## **11.3 Keyboard exploration**

Keyboard navigation should work across the unified logical domain, not renderer silos.

For example:

- left/right move between logical x or category positions
- up/down cycle series within that position
- enter selects focused entry
- escape clears selection

That is the right accessibility model because it mirrors how shared tooltips work.

## **11.4 Non-color-only differentiation**

Since mixed charts often rely on both renderer type and color:

- bars vs lines vs points already provide structural differentiation
- focus/selection should still add outline/halo/emphasis
- high-contrast modes should remain readable without hue dependence alone

## **11.5 Reduced motion**

If reduced motion is active:

- suppress staged mixed-series enter effects
- reduce hover transitions
- keep selection and tooltip motion minimal

## **11.6 Accessible table fallback**

Because combo charts often appear in business dashboards, an optional linked table or detail view fallback is especially valuable and fits well with obers_ui's broader data-display ecosystem.

# **12\. Every extensive test needed for OiComboChart**

This should be one of the broadest test suites in the whole chart package.

## **A. Rendering and layout tests**

- renders bars + line correctly
- renders area + line correctly
- renders bar + line + scatter correctly
- respects container constraints
- fills available container
- legend moves below on compact
- minimum useful size fallback appears when needed
- automatic draw ordering places bars below lines by default
- declaration-order rendering works when configured

## **B. Data and series composition tests**

- accepts heterogeneous OiCartesianSeries&lt;T&gt; list
- line, area, bar, and scatter series normalize correctly together
- shared x-domain alignment works for mixed series
- shared y-domain union works for visible series
- explicit y-axis assignment works when enabled
- hidden series are excluded from domain calculations

## **C. Tooltip and interaction tests**

- nearestItem mode resolves correctly
- sharedX mode groups correct series entries
- sharedCategory mode groups correct category entries
- focusedSeriesOnly mode restricts tooltip correctly
- hover tooltip appears on pointer
- tap tooltip appears on touch
- tooltip dismisses correctly
- selection updates controller correctly
- mixed-series hit-testing resolves the correct winner
- sync group propagates focus correctly

## **D. Legend tests**

- legend shows mixed renderer markers correctly
- legend toggle hides individual series
- hidden series trigger scoped recomputation
- legend isolate mode emphasizes one series correctly
- keyboard legend interaction works

## **E. Accessibility tests**

- chart exposes semantic label
- generated summary includes renderer types present
- keyboard left/right moves across shared logical domain
- keyboard up/down cycles through entries at a position
- enter selects focused entry
- escape clears selection
- focused narration reflects renderer label + value correctly
- reduced motion disables nonessential mixed-series animations
- high-contrast mode preserves differentiation

## **F. Theming tests**

- all series derive styling from chart theme by default
- local chart theme override applies correctly
- series-level override beats chart theme
- point-level override beats series style
- tooltip and legend visuals remain theme-consistent across renderer types
- light and dark goldens are stable

## **G. Responsive tests**

- compact layout moves legend below
- compact layout suppresses excess labels/markers
- pointer uses hover tooltip, touch uses tap tooltip
- narrow layouts remain readable
- below minimum viable size shows fallback presentation
- mixed-series detail reduces coherently in compact/performance mode

## **H. Performance tests**

- large bar + line combo remains interactive in balanced mode
- large line + scatter combo uses renderer-local optimizations correctly
- hidden series skip expensive work
- viewport filtering excludes offscreen data across all renderers
- hit-testing stays performant with multiple visible renderers
- repeated hover and zoom do not leak memory
- progressive rendering/refinement behaves correctly under mixed load

## **I. Golden tests**

- default bar + line combo
- area + line combo
- bar + line + scatter combo
- compact combo with legend below
- selected point with shared tooltip
- dark theme combo
- dense mixed chart in simplified mode
- combo with thresholds and annotations

# **13\. Final recommendation for OiComboChart**

OiComboChart should be treated as the **proof-of-architecture chart** for obers_ui:

- it should accept the same familiar series objects developers already use elsewhere, rather than inventing combo-only data models
- it should rely on a real renderer registry over a shared Cartesian substrate, so mixed-series support is genuinely foundational
- it should keep interaction behavior composable through behaviors, not one giant nested combo config
- it should stay fully theme-native and consistent with obers_ui naming and prop conventions
- it should unify tooltip, keyboard exploration, accessibility summary, and sync logic across heterogeneous series
- it should let each renderer keep its own performance optimizations while still participating in one coherent chart-level pipeline

If this chart is done well, the whole library immediately feels more serious. It tells developers that obers_ui does not just have several chart widgets - it has a real chart system.

When you say **continue**, I'll move to the next deep dive: **OiPieChart&lt;T&gt;**.

continue 9

I'm on OiPieChart now. This is the first polar chart, so the main job is to translate all the same obers_ui principles into radial layout, slice semantics, center content, and part-to-whole readability without letting the API drift away from the Cartesian family.

Thought for 16s

## **Part 10 - OiPieChart&lt;T&gt;**

OiPieChart is the first chart where the library has to prove it can move from Cartesian into **polar thinking** without losing the same clean obers_ui conventions.

That means the API should still feel like the same package:

- declarative
- mapper-first
- readable props
- behavior-based interactivity
- theme-native
- accessibility-first

But the visual logic changes a lot. Pie charts are not about continuous axes or category bands. They are about:

- part-to-whole
- angular proportion
- slice ordering
- label collision
- center space
- legend clarity
- touch-friendly slice interaction

That direction fits your chart analysis well. The chart inventory explicitly treats pie/donut as a core chart family, and the spec guidance strongly favors mapper-based binding, composable behaviors, and stronger accessibility than existing chart ecosystems usually provide. It also has to stay aligned with the real obers_ui implementation language: Oi naming, tiered composition, all colors from theme, all layouts through Oi primitives, and mandatory accessibility.

# **1\. What OiPieChart is**

OiPieChart&lt;T&gt; is the standard polar chart for showing **part-to-whole composition** through proportional slices.

It should be the default chart in obers_ui for:

- category share
- market share
- conversion split
- status distribution
- composition summaries
- compact dashboard summaries
- simple contribution views where absolute comparison is secondary to share

Architecturally:

OiPieChart&lt;T&gt; extends OiPolarChart&lt;T&gt;

It should not be built as a special standalone one-off. It should be the first high-level chart proving that the shared polar substrate is real:

- shared angle/radius layout
- shared tooltip and legend logic
- shared selection and focus logic
- shared annotations later
- shared accessibility summary model
- shared theming and responsive behavior

That matters because the whole chart library only feels unified if polar charts inherit the same core philosophy as Cartesian charts rather than becoming a separate mini-API.

# **2\. How it looks, features, and important behavior**

Visually, OiPieChart should support these core forms:

- single pie with one series
- optional exploded/offset selected slice
- optional slice labels
- optional percentage labels
- optional value labels
- optional legend
- optional center content later, though that belongs more naturally to donut
- optional thresholds or highlighted slices
- optional grouped "other" segment
- optional sorting modes

The most important visual behaviors are:

### **A. It must privilege readability over cleverness**

Pie charts are easy to misuse. obers_ui should optimize for the readable cases:

- not too many slices
- sensible sorting
- strong legend support
- clear label strategy
- responsive fallback when too cramped

### **B. Slice order matters**

The chart needs a predictable default order:

- declaration order
- descending value
- ascending value
- custom comparator

Recommended default:

- preserve declaration order unless the developer explicitly requests sorting

That keeps data input and visual output easy to reason about.

### **C. Small slices need explicit handling**

Tiny slices cause the worst label and interaction problems. The chart should support:

- hide tiny labels
- move labels to legend only
- group tiny slices into "Other"
- enlarge hit regions beyond exact painted angle

### **D. Part-to-whole semantics must stay honest**

Pie charts should not pretend to be good at everything. They should focus on:

- composition
- share
- simple categorical distribution

Not:

- precise comparison of many tiny categories
- time trend
- dense analytic overlays

That clarity improves DX too, because the widget communicates what it is for.

# **3\. How data input stays easy, logical, and consistent**

The strongest choice here is the same one as elsewhere: **mapper-first binding**.

The chart analysis is very clear that Flutter specs should not force users into a library-specific data shape. Mapper functions are the right primary input model.

So the common case should look like this:

OiPieChart&lt;CategoryShare&gt;(  
label: 'Revenue share by category',  
data: categories,  
value: (item) => item.revenue,  
labelBuilder: (item) => item.name,  
)

For more advanced use:

OiPieChart&lt;CategoryShare&gt;(  
label: 'Revenue share by category',  
slices: \[  
OiPieSlice&lt;CategoryShare&gt;(  
id: 'food',  
label: 'Food',  
data: foodItems,  
value: (item) => item.revenue,  
),  
OiPieSlice&lt;CategoryShare&gt;(  
id: 'drinks',  
label: 'Drinks',  
data: drinkItems,  
value: (item) => item.revenue,  
),  
\],  
)

But unlike combo charts, pie should usually optimize for the **single-series categorical** case. So the best default developer experience is probably:

- data
- value
- labelBuilder

And optionally:

- color
- semanticValue
- sortMode
- minSliceAngle
- groupSmallSlices

## **The consistency rule**

Even though pie is radial rather than Cartesian, it should still feel familiar:

- raw domain models in
- mappers define meaning
- theming overrides remain layered
- behavior objects still attach the same way
- accessibility still follows the same contract

## **Recommended slice-level contract**

class OiPieSlice&lt;T&gt; {  
final String id;  
final String label;  
final List&lt;T&gt; data;  
final num? Function(T item) value;  
final Color? Function(T item, OiSeriesPointContext context)? color;  
final String? Function(T item)? semanticValue;  
}

For the even simpler common path, OiPieChart should internally synthesize those slices from data + value + labelBuilder.

# **4\. Overall structure, API, props, and callbacks**

## **Public widget shape**

class OiPieChart&lt;T&gt; extends StatefulWidget {  
final String label;  
final String? semanticLabel;  
<br/>final List&lt;T&gt;? data;  
final num? Function(T item)? value;  
final String Function(T item)? labelBuilder;  
<br/>final List&lt;OiPieSlice<T&gt;>? slices;  
<br/>final OiPieSortMode sortMode;  
final OiPieLabelMode labelMode;  
final OiPieSelectionMode selectionMode;  
final OiPieSmallSlicePolicy smallSlicePolicy;  
<br/>final OiChartLegendConfig? legend;  
final List&lt;OiChartBehavior&gt; behaviors;  
final List&lt;OiChartAnnotation&gt; annotations;  
<br/>final OiChartThemeData? theme;  
final OiChartPerformanceConfig? performance;  
final OiChartAnimationConfig? animation;  
final OiChartAccessibilityConfig? accessibility;  
final OiChartSettingsDriverBinding? settings;  
final OiChartController? controller;  
final String? syncGroup;  
<br/>final OiChartLoadingStateConfig? loadingState;  
final OiChartEmptyStateConfig? emptyState;  
final OiChartErrorStateConfig? errorState;  
<br/>final ValueChanged&lt;OiPieSliceSelection&gt;? onSliceTap;  
final ValueChanged&lt;OiPieSliceToggle&gt;? onSliceVisibilityChange;  
}

## **Important enums**

enum OiPieSortMode {  
none,  
ascendingValue,  
descendingValue,  
}  
<br/>enum OiPieLabelMode {  
none,  
legendOnly,  
value,  
percentage,  
valueAndPercentage,  
labelAndPercentage,  
}  
<br/>enum OiPieSelectionMode {  
none,  
single,  
toggle,  
}  
<br/>enum OiPieSmallSlicePolicy {  
keep,  
hideLabel,  
groupAsOther,  
}

This stays very readable and matches the obers_ui naming rule that props should read like English.

## **Callback philosophy**

Keep callbacks simple:

- onSliceTap
- onSliceLongPress
- onSliceVisibilityChange
- onSelectionChange

Do not leak renderer internals.

# **5\. How it is customized through global obers_ui theming**

AI_README is explicit that all colors come from theme and that per-component overrides should live in the typed theme system. So OiPieChart should resolve from OiChartThemeData, not from manual per-instance styling by default.

## **Global defaults especially important for pie charts**

The chart theme should provide:

- categorical palette
- slice border defaults
- selection offset defaults
- label text styles
- label line styles
- legend appearance
- tooltip appearance
- compact-mode label simplification rules
- inactive/focused slice appearance

## **Theme-derived defaults that matter here**

Without local overrides:

- slice fills come from context.colors.chart
- text styles come from the text theme
- legend and tooltip surfaces come from chart/overlay theme
- selected/focused slice emphasis comes from effects/interaction tokens
- borders and subtle separators come from border tokens

That is important because pie charts often drift into custom one-off styling in many libraries. obers_ui should keep them visually anchored in the same theme system as everything else.

# **6\. How it can be themed and configured on an element basis**

Use the same clean precedence as the other charts.

### **Layer 1 - global app theme**

Default pie styling.

### **Layer 2 - local chart theme override**

Per-chart override.

theme: OiChartThemeData(  
legend: ...,  
tooltip: ...,  
)

### **Layer 3 - slice-level style**

For one logical slice or category.

OiPieSlice(  
id: 'food',  
label: 'Food',  
data: foodItems,  
value: (item) => item.revenue,  
style: OiSeriesStyle(  
fillColor: ...,  
strokeWidth: 1,  
),  
)

### **Layer 4 - per-item dynamic override**

If needed, individual data items can override color or semantics.

## **Pie-specific style concerns**

OiSeriesStyle for pie charts should support:

- fillColor
- strokeColor
- strokeWidth
- selectionOffset
- labelStyle
- hoverStyle
- selectedStyle
- inactiveStyle

One important rule:

- default borders should stay subtle, because too much stroke contrast makes pies feel noisy quickly

# **7\. How the logic works and how exactly it should be implemented**

## **7.1 Data normalization**

Each pie input should normalize as follows:

- map labels
- map values
- filter invalid/zero/hidden slices according to policy
- compute total
- compute percentage for each slice
- compute start and end angle
- compute label anchor and hit region
- build legend model

The normalized slice should track:

- raw item
- label
- raw value
- percentage
- start angle
- sweep angle
- color
- selected/hidden state
- label visibility mode
- semantic text

## **7.2 Angle computation**

Core formula:

- total = sum of visible valid slice values
- sweep = value / total \* fullAngle

The default full angle should be 2π.

Recommended start angle:

- top-centered (−90°)  
   This is usually the most readable and familiar.

## **7.3 Zero and negative values**

Pie charts should be strict here.  
Recommended rules:

- zero values: optional include in legend, but no visible slice
- negative values: invalid for pie semantics; do not silently render them
- null values: exclude, with predictable behavior

That keeps the chart honest.

## **7.4 Small-slice policy**

This is one of the most important pie-chart-specific behaviors.

### **keep**

Render all slices normally.

### **hideLabel**

Render slice, but suppress inline label if too small.

### **groupAsOther**

Aggregate slices below threshold into one synthetic "Other" slice.

Recommended default:

- keep slices, hide tiny inline labels, rely on legend for detail

This gives the best combination of honesty and readability.

## **7.5 Label placement**

Pie labels are much harder than they look.  
The chart should support two main strategies:

- inline label inside slice for sufficiently large segments
- outside radial label with leader line for smaller but still significant slices

For v1, I would strongly recommend:

- keep inline labeling conservative
- rely heavily on legend + tooltip
- only use outside labels when there is enough room

That is the cleaner DX and avoids a lot of visual chaos.

## **7.6 Selection logic**

Selected slice can be emphasized through:

- slight outward offset
- outline
- opacity/focus treatment
- tooltip pinning

Recommended default:

- mild outward offset + emphasis outline

## **7.7 Legend visibility and ordering**

Legend should reflect the final visible/order state of slices:

- after sorting
- after grouping
- after hidden-state changes

That keeps user-facing information consistent.

# **8\. How performance is guaranteed even with huge datasets**

Pie charts are not the same kind of performance problem as large line or scatter charts. The issue is not usually raw rendering cost. The issue is **category explosion and label chaos**.

So performance/readability rules should focus on:

- too many slices
- label collision
- legend volume
- interaction ambiguity

## **8.1 Arc rendering is cheap, labels are not**

The actual slice drawing is inexpensive.  
The expensive parts are:

- text layout
- collision avoidance
- tooltip content
- semantics explosion

## **8.2 Aggressive readability limits**

In performance/compact modes:

- suppress inline labels
- rely on legend or tooltip
- cap visible "small slice" detail
- prefer grouped "Other" if configured

## **8.3 Minimal recomputation**

Cache:

- totals
- angle spans
- label positions
- legend items

Invalidate only when:

- data changes
- visibility changes
- sort mode changes
- theme changes
- size changes

## **8.4 Compact simplification**

This matters a lot because base_concept explicitly requires all visualization widgets to adapt with LayoutBuilder, move legends below on compact, switch tooltips to tap on touch, and render a "View full screen" fallback below minimum useful size.

For pie charts that means:

- legend below on compact
- inline labels reduced or removed
- larger touch target tolerance
- optional full-screen fallback if too cramped for honest reading

## **8.5 Category explosion guardrails**

A pie chart with 30 slices is usually a design smell.  
The component should not ban it, but it should make sane degradation easy:

- group small slices
- legend scroll or wrap
- hide inline labels
- maybe emit debug diagnostics in development mode

# **9\. How interactivity works and can be configured**

The same general obers_ui visualization interaction rules still apply:

- hover tooltip on pointer
- tap tooltip on touch
- compact legend below
- minimum viable size fallback

## **Default interaction behavior**

### **Pointer**

- hover highlights slice
- hover shows tooltip
- click selects slice if enabled

### **Touch**

- tap highlights slice
- tap shows tooltip
- tap elsewhere dismisses
- hit region should be forgiving for small slices

## **Behavior-based configuration**

behaviors: \[  
OiTooltipBehavior(),  
OiSelectionBehavior(  
selectionMode: OiChartSelectionMode.point,  
),  
\]

Even for pie charts, the same behavior-object philosophy should remain intact because that is one of the strongest architectural recommendations in your chart analysis.

## **Pie-specific interaction detail**

The chart should support:

- slice hover/tap
- legend toggle/hide
- exclusive focus mode
- pinned selection
- keyboard slice traversal

Recommended default:

- hover/tap selects logical slice
- legend can toggle visibility if enabled

# **10\. How legend and additional information are implemented**

## **Legend**

Pie charts depend heavily on legend quality.  
Each legend item should show:

- slice color
- label
- optional formatted value
- optional percentage
- visible/hidden state

Legend interactions:

- toggle visibility
- isolate one slice if desired
- keyboard operability
- wrap or move below on compact

That fits base_concept's responsive visualization rules directly.

## **Tooltip**

Tooltip should support:

- label
- formatted raw value
- formatted percentage
- optional additional metadata rows

For pies, tooltip clarity is especially important because the slice itself often has limited space for text.

## **Additional information layers**

For v1 pie, keep this conservative:

- annotations on slices
- highlighted categories
- center summary later better handled by donut
- no overloaded analytic overlays

That helps keep the chart honest and readable.

# **11\. How accessibility is guaranteed**

This is one of the areas where obers_ui can be clearly better than many chart libraries. Your chart analysis explicitly recommends auto-generated accessibility descriptions and keyboard point exploration. AI_README also makes accessibility mandatory across the package.

## **11.1 Required semantics**

At minimum:

- label required
- semanticLabel optional override
- each slice has a semantic label
- legend items are keyboard reachable and labeled

## **11.2 Auto-generated summary**

If the developer does not provide one, generate something like:

- chart type
- number of visible categories
- largest category
- smallest visible category
- whether some categories are grouped as "Other"

Example:  
"Pie chart showing revenue share across five categories. Food is the largest segment at 42 percent."

That is exactly the kind of generated narration your chart analysis points toward.

## **11.3 Keyboard exploration**

A focused pie chart should support:

- left/right arrows move between slices
- enter selects slice
- escape clears selection
- narration includes label, value, and percentage

That gives polar charts the same accessibility dignity as Cartesian ones.

## **11.4 Non-color-only differentiation**

Since pies rely heavily on color:

- selected/focused slice must also use offset, outline, or halo
- legend text must remain clear
- high-contrast mode should not depend on hue alone

## **11.5 Reduced motion**

If reduced motion is active:

- avoid spinning or sweeping animations
- reduce hover transitions
- keep selection changes subtle

## **11.6 Accessible table/list fallback**

For enterprise contexts, a linked textual breakdown of slices can be useful and fits well with the larger obers_ui data-display ecosystem.

# **12\. Every extensive test needed for OiPieChart**

## **A. Rendering and layout tests**

- renders basic pie chart correctly
- renders multiple slices with correct proportions
- respects container constraints
- fills available container
- legend moves below on compact
- minimum useful size fallback appears when too cramped
- selection offset renders correctly
- label modes render correctly

## **B. Data mapping tests**

- mapper-based value extraction works with domain models
- shorthand data + value + labelBuilder builds correct normalized slices
- zero values are handled according to spec
- negative values are rejected/ignored according to spec
- sorting modes behave correctly
- grouped "Other" slice is computed correctly

## **C. Angle and normalization tests**

- total and percentages are computed correctly
- start and sweep angles are correct
- declaration-order slices preserve order in none mode
- ascending and descending sort modes work correctly
- hidden slices recompute totals correctly

## **D. Small-slice policy tests**

- keep preserves all slices
- hideLabel suppresses tiny labels only
- groupAsOther aggregates below-threshold slices correctly
- grouped other slice legend entry is correct

## **E. Interaction tests**

- hover tooltip appears on pointer
- tap tooltip appears on touch
- slice tap callback fires with correct payload
- selection state updates correctly
- tooltip dismisses correctly
- legend visibility toggle works
- keyboard slice traversal works

## **F. Accessibility tests**

- chart exposes semantic label
- auto-generated summary includes largest segment
- focused slice narration includes label, value, and percentage
- legend items are keyboard operable
- reduced motion disables nonessential animation
- high-contrast mode preserves perceivable focus and selection

## **G. Theming tests**

- slice colors derive from theme chart palette
- local chart theme override applies correctly
- slice-level style override beats chart theme
- tooltip and legend visuals resolve from theme
- light and dark goldens are stable

## **H. Responsive tests**

- compact legend below chart
- compact suppresses inline labels where necessary
- pointer uses hover tooltip, touch uses tap tooltip
- narrow layouts remain readable
- below minimum viable size shows fallback presentation

## **I. Performance tests**

- many-slice charts suppress labels appropriately
- label layout caching avoids repeated expensive work
- hidden-slice recomputation is scoped
- repeated hover/selection does not leak memory
- compact/performance mode reduces complexity predictably

## **J. Golden tests**

- default pie chart
- pie chart with legend
- pie chart with selected slice
- compact pie chart with legend below
- pie chart with grouped "Other"
- dark theme pie chart
- high-contrast pie chart

# **13\. Final recommendation for OiPieChart**

OiPieChart should be the canonical obers_ui chart for **simple part-to-whole composition**:

- mapper-first data input, not library-owned data models
- the same readable prop language and Oi naming as the rest of the package
- the same theme-native styling rules and typed component theming
- the same responsive visualization behavior defined in base_concept, especially tap tooltips on touch, legend-below on compact, and minimum viable size fallback
- the same accessibility ambition, especially generated summaries and keyboard traversal

The main design discipline is to keep it **clean, readable, and honest**. If OiPieChart tries to become too clever, it will get worse fast. If it stays focused on clear composition with strong legend, tooltip, and accessibility support, it will feel like exactly the right first polar chart in obers_ui.

When you say **continue**, I'll move to the next deep dive: **OiDonutChart&lt;T&gt;**.

continue 11

I'm moving into OiDonutChart now. This is where the polar family starts to diverge meaningfully from pie, because center content, ring thickness, compact KPI use, and layered composition suddenly become major API and accessibility concerns.

Thought for 6s

## **Part 11 - OiDonutChart&lt;T&gt;**

OiDonutChart should be treated as a **first-class sibling of OiPieChart**, not just "pie with a hole."

That sounds subtle, but it matters a lot for product UX and API design. In real interfaces, donut charts are often used differently from pies:

- they frequently carry **center content**
- they work better as compact dashboard summaries
- they support stronger total/summary presentation
- they tolerate labels and legends differently
- they are often more readable when combined with KPI framing

So while OiDonutChart should absolutely share the same polar substrate as OiPieChart, it deserves its own dedicated API surface and recommendations. That matches the chart analysis, which treats pie/donut as a core family and recommends mapper-first binding, composable behaviors, progressive chart architecture, and auto-generated accessibility rather than chart-type silos. It also stays aligned with the actual obers_ui implementation language: typed component theming, density-aware behavior, OiApp-injected accessibility/services, and package-wide naming consistency.

# **1\. What OiDonutChart is**

OiDonutChart&lt;T&gt; is the standard polar chart for **part-to-whole composition with reserved center space**.

It should be the default chart in obers_ui for:

- composition with a total in the middle
- status split with a clear summary
- compact dashboard cards
- KPI summaries with proportional context
- category shares where center content adds value
- filtered composition views where the center explains scope, period, or total

Architecturally:

OiDonutChart&lt;T&gt; extends OiPolarChart&lt;T&gt;

And practically, it should share almost all of the same infrastructure as OiPieChart:

- slice normalization
- angular layout
- tooltip behaviors
- legend model
- selection/focus behavior
- theme integration
- accessibility generation
- compact-mode adaptation

But it should additionally formalize:

- ring thickness
- center content
- inner-radius semantics
- layered radial content behavior

This distinction is also justified by the chart analysis itself, which points out that libraries like fl_chart expose donut behavior as specific pie parameters such as center-space radius, slice gaps, and start-angle offset. That means donut is already a known specialized radial use case worth treating explicitly in a serious specification.

# **2\. How it looks, features, and important behavior**

Visually, OiDonutChart should support these core forms:

- standard donut ring
- thicker KPI-style donut
- thinner analytic ring
- optional selected/exploded slice
- optional inline labels
- optional outside labels
- optional legend
- optional center summary content
- optional subtitle / helper text in center
- optional multi-line center content
- optional grouped "Other" slice
- optional empty-state ring
- optional partial/segmented styling later if needed

The most important visual behaviors are:

### **A. Center content is a first-class feature**

This is the biggest difference from pie. The center is not decorative leftover space. It should be intentionally usable for:

- total
- selected slice details
- label + value
- KPI + subtext
- date range
- filter scope
- empty/loading placeholder state

### **B. Ring thickness must be deliberate and readable**

A donut chart with arbitrary thickness feels inconsistent and quickly becomes hard to label. The API should make thickness a readable, theme-aware concept.

### **C. Label strategy must stay disciplined**

Like pie, donut charts can become cluttered fast. The default strategy should privilege:

- center content
- legend
- tooltip  
   over overly aggressive inline labeling.

### **D. Compact layouts should strongly prefer center summary + legend**

On smaller screens, donut charts often read better than pie charts because the hole provides breathing room. But they still need compact simplification:

- fewer inline labels
- legend below
- tap tooltip on touch
- minimum viable size fallback

Those compact expectations are directly consistent with the base concept's visualization rules: fill container, use LayoutBuilder, show tooltips on tap for touch and hover for pointer, move legends below on compact, and render a "View full screen" fallback below minimum useful size.

# **3\. How data input stays easy, logical, and consistent**

This should stay almost identical to OiPieChart, because that consistency is important.

The chart analysis explicitly recommends mapper-first binding as the primary Flutter-friendly pattern. So the common case should look like:

OiDonutChart&lt;CategoryShare&gt;(  
label: 'Revenue share by category',  
data: categories,  
value: (item) => item.revenue,  
labelBuilder: (item) => item.name,  
centerContent: OiDonutCenterContent.total(  
label: 'Total',  
value: '€142,300',  
),  
)

That is the ideal DX: extremely readable, strongly typed, and close to natural language.

For more advanced usage:

OiDonutChart&lt;CategoryShare&gt;(  
label: 'Revenue share by category',  
slices: \[  
OiDonutSlice&lt;CategoryShare&gt;(  
id: 'food',  
label: 'Food',  
data: foodItems,  
value: (item) => item.revenue,  
),  
OiDonutSlice&lt;CategoryShare&gt;(  
id: 'drinks',  
label: 'Drinks',  
data: drinkItems,  
value: (item) => item.revenue,  
),  
\],  
centerContentBuilder: (context, state) {  
return OiDonutCenter(  
title: state.selectedSlice?.label ?? 'Total',  
value: state.selectedSlice?.formattedValue ?? state.totalFormatted,  
);  
},  
)

## **The consistency rule**

Even though donut introduces center content, the input mental model should still stay familiar:

- data
- value
- labelBuilder
- optional slices
- optional color
- optional semanticValue
- optional smallSlicePolicy

So a developer who learned OiPieChart should feel instantly at home.

## **Recommended slice contract**

This can remain almost identical to pie:

class OiDonutSlice&lt;T&gt; {  
final String id;  
final String label;  
final List&lt;T&gt; data;  
final num? Function(T item) value;  
final Color? Function(T item, OiSeriesPointContext context)? color;  
final String? Function(T item)? semanticValue;  
}

The only meaningful public addition belongs at the chart level: center-content and ring-thickness concerns.

# **4\. Overall structure, API, props, and callbacks**

## **Public widget shape**

class OiDonutChart&lt;T&gt; extends StatefulWidget {  
final String label;  
final String? semanticLabel;  
<br/>final List&lt;T&gt;? data;  
final num? Function(T item)? value;  
final String Function(T item)? labelBuilder;  
<br/>final List&lt;OiDonutSlice<T&gt;>? slices;  
<br/>final OiDonutThickness thickness;  
final OiPieSortMode sortMode;  
final OiPieLabelMode labelMode;  
final OiPieSelectionMode selectionMode;  
final OiPieSmallSlicePolicy smallSlicePolicy;  
<br/>final OiDonutCenterContent? centerContent;  
final Widget Function(BuildContext, OiDonutState)? centerContentBuilder;  
<br/>final OiChartLegendConfig? legend;  
final List&lt;OiChartBehavior&gt; behaviors;  
final List&lt;OiChartAnnotation&gt; annotations;  
<br/>final OiChartThemeData? theme;  
final OiChartPerformanceConfig? performance;  
final OiChartAnimationConfig? animation;  
final OiChartAccessibilityConfig? accessibility;  
final OiChartSettingsDriverBinding? settings;  
final OiChartController? controller;  
final String? syncGroup;  
<br/>final OiChartLoadingStateConfig? loadingState;  
final OiChartEmptyStateConfig? emptyState;  
final OiChartErrorStateConfig? errorState;  
<br/>final ValueChanged&lt;OiDonutSliceSelection&gt;? onSliceTap;  
final ValueChanged&lt;OiDonutSliceToggle&gt;? onSliceVisibilityChange;  
}

## **Thickness enum**

enum OiDonutThickness {  
thin,  
standard,  
thick,  
custom,  
}

And for custom:

final double? ringThickness;

Recommended default:

- standard

That reads much better than forcing everyone to think in raw inner-radius numbers.

## **Center content model**

class OiDonutCenterContent {  
final String? title;  
final String? value;  
final String? subtitle;  
final Widget? leading;  
final Widget? trailing;  
<br/>const OiDonutCenterContent({  
this.title,  
this.value,  
this.subtitle,  
this.leading,  
this.trailing,  
});  
<br/>factory OiDonutCenterContent.total({  
required String label,  
required String value,  
String? subtitle,  
});  
}

## **Donut state for builders**

class OiDonutState {  
final double total;  
final String? totalFormatted;  
final OiNormalizedDonutSlice? selectedSlice;  
final List&lt;OiNormalizedDonutSlice&gt; visibleSlices;  
}

That gives advanced developers control without complicating the common case.

## **Callback philosophy**

Keep callbacks simple:

- onSliceTap
- onSliceLongPress
- onSliceVisibilityChange
- onSelectionChange

No renderer leaks.

# **5\. How it is customized through global obers_ui theming**

The real implementation direction in AI_README is explicit: component visuals should resolve through typed component themes, not through disconnected style islands, and density is globally available through OiDensityScope. So OiDonutChart should derive from OiChartThemeData the same way the rest of the chart family does.

## **Global defaults especially important for donut charts**

The chart theme should provide:

- categorical palette
- ring border defaults
- selected slice offset defaults
- center-content typography defaults
- center-content spacing rules
- compact-mode simplification defaults
- label and leader-line styling
- legend and tooltip styling
- inactive/focused slice styling

## **Theme-derived defaults that matter here**

Without local overrides:

- slice fills come from the chart palette
- center value typography resolves from the text theme plus chart theme emphasis
- center subtitle/title derive from standard semantic text roles
- tooltip surface derives from overlay/component theme
- legend derives from chart theme
- focus and selection derive from interaction tokens

That is especially important because donut charts often get used in dashboard cards, and that is exactly where visual drift hurts package consistency most.

# **6\. How it can be themed and configured on an element basis**

Use the same layered precedence as everywhere else.

### **Layer 1 - global app theme**

Default donut appearance across the app.

### **Layer 2 - local chart theme override**

Per-chart override.

theme: OiChartThemeData(  
legend: ...,  
tooltip: ...,  
)

### **Layer 3 - slice-level style**

For one logical slice/category.

OiDonutSlice(  
id: 'food',  
label: 'Food',  
data: foodItems,  
value: (item) => item.revenue,  
style: OiSeriesStyle(  
fillColor: ...,  
strokeWidth: 1,  
),  
)

### **Layer 4 - per-item dynamic override**

For individual data items if needed.

## **Donut-specific style concerns**

OiSeriesStyle for donut charts should support:

- fillColor
- strokeColor
- strokeWidth
- selectionOffset
- labelStyle
- hoverStyle
- selectedStyle
- inactiveStyle

And the chart theme should additionally support:

- default center-content text styles
- default thickness per density mode
- compact simplification rules for inline labels

That keeps donut-specific concerns where they belong without inventing an unrelated styling system.

# **7\. How the logic works and how exactly it should be implemented**

## **7.1 Data normalization**

This is almost the same as pie:

- map labels
- map values
- filter invalid/hidden slices according to policy
- compute visible total
- compute percentages
- compute start and end angles
- resolve inner and outer radii
- compute label anchors and hit regions
- build center-content state
- build legend model

The normalized slice should track:

- raw item
- label
- raw value
- percentage
- start angle
- sweep angle
- inner radius
- outer radius
- color
- selected/hidden state
- semantic text

## **7.2 Ring thickness resolution**

This is the most important donut-specific layout problem.

Thickness should resolve from:

- explicit ringThickness when custom
- semantic thickness enum
- density mode defaults
- container size constraints

That last point matters. If the chart becomes too small, the ring thickness may need to adapt to preserve center readability.

A good rule is:

- keep a minimum inner hole size for center content legibility
- never let a custom thickness fully collapse the inner hole unless explicitly documented

## **7.3 Center content layout**

Center content should be laid out inside the inner radius bounds with:

- safe internal padding
- text scaling awareness
- overflow handling
- fallback to simpler layout on compact or tiny sizes

Recommended center content rules:

- prioritize value
- title/subtitle may hide or reduce first when space is tight
- allow a builder for advanced custom layouts
- never let center content overlap the ring

## **7.4 Selection logic**

Selected slice emphasis can use:

- slight outward offset
- outline
- opacity emphasis
- center content switching to selected slice details

Recommended default:

- mild outward offset + center content updates to selected slice on interaction if the developer uses the state-driven builder

That makes donut charts feel interactive in a very useful way without requiring complicated public API.

## **7.5 Zero and negative values**

Same honesty rules as pie:

- zero values: optional legend presence, no visible arc
- negative values: invalid for donut semantics, exclude predictably
- null values: exclude predictably

## **7.6 Small-slice policy**

Same overall policies as pie:

- keep
- hide label
- group as "Other"

Recommended default:

- keep slice, suppress tiny inline labels, rely on legend + tooltip

## **7.7 Center content state model**

This is where donut becomes especially strong.  
The chart should expose a clear internal state for:

- total
- visible slices
- currently selected slice
- currently hovered slice
- formatted values

That lets center content do useful things like:

- show total by default
- switch to selected slice details on tap/hover
- revert on dismissal

This can become a very polished signature behavior for obers_ui.

# **8\. How performance is guaranteed even with huge datasets**

Like pie charts, donut charts are not usually paint-bound. They are:

- label-bound
- legend-bound
- semantics-bound
- layout-bound when center content is involved

So performance architecture should focus on those.

## **8.1 Arc rendering is cheap, label/layout work is not**

The expensive parts are:

- text layout
- collision handling
- center-content measurement
- legend generation
- semantic output

## **8.2 Compact simplification**

This should follow the same visualization rules already present in base concept:

- use LayoutBuilder
- legend below on compact
- touch tooltips on tap
- full-screen fallback below minimum useful size

For donut charts that means:

- reduce inline labels first
- keep center content concise
- rely more on tooltip and legend
- simplify subtitle/detail inside the center
- render fallback when both ring and center cannot remain readable

## **8.3 Minimal recomputation**

Cache:

- totals
- angle spans
- radius layout
- center content state inputs
- legend items
- label anchors

Invalidate only on:

- data changes
- visibility changes
- theme changes
- sort mode changes
- container size changes
- selected slice changes if center builder depends on it

## **8.4 Guardrails for category explosion**

Same principle as pie:

- donut charts with too many slices usually degrade badly
- make "group small slices" easy
- suppress inline labels early
- optionally warn in debug builds if readability thresholds are exceeded

# **9\. How interactivity works and can be configured**

The same general visualization rules still apply:

- hover tooltip on pointer
- tap tooltip on touch
- legend below on compact
- minimum viable size fallback

## **Default interaction behavior**

### **Pointer**

- hover highlights slice
- hover shows tooltip
- click selects slice if enabled
- optional center content can update to hovered slice if configured

### **Touch**

- tap highlights slice
- tap shows tooltip
- tap elsewhere dismisses
- hit region should be forgiving for small slices
- center content can update to tapped slice when selected

## **Behavior-based configuration**

behaviors: \[  
OiTooltipBehavior(),  
OiSelectionBehavior(  
selectionMode: OiChartSelectionMode.point,  
),  
\]

That keeps donut aligned with the same composable interaction model recommended by the chart analysis rather than inventing a separate radial-only interaction system.

## **Donut-specific interaction detail**

The chart should support:

- slice hover/tap
- legend toggle/hide
- pinned selection
- keyboard slice traversal
- center-content response to focus/selection

Recommended default:

- interaction targets the logical slice
- center content remains total by default unless selection is enabled or builder chooses otherwise

# **10\. How legend and additional information are implemented**

## **Legend**

Use the shared chart legend component.  
Each legend item should show:

- slice color
- label
- optional value
- optional percentage
- visible/hidden state

Legend interactions:

- toggle visibility
- isolate one slice if desired
- keyboard operability
- wrap or move below on compact

This matches the base concept's visualization rules directly.

## **Tooltip**

Tooltip should support:

- label
- raw formatted value
- percentage
- optional additional metadata rows

For donut charts, tooltip plus center content is often the best pairing:

- center = stable summary
- tooltip = per-slice detail

## **Additional information layers**

Keep this conservative in v1:

- center summary
- highlighted slice
- maybe simple annotations if needed
- avoid overloading donut with heavy analytic overlays

That keeps the chart clean and appropriate to its use cases.

# **11\. How accessibility is guaranteed**

The chart analysis is explicit that accessibility is broadly weak across chart libraries and that generated descriptions plus keyboard exploration are opportunities. AI_README also makes accessibility a first-class concern through OiApp services and package-wide conventions.

## **11.1 Required semantics**

At minimum:

- label required
- semanticLabel optional override
- each slice has a semantic label
- center summary is representable semantically
- legend items are keyboard reachable and labeled

## **11.2 Auto-generated summary**

If not overridden, generate a summary including:

- chart type
- number of visible categories
- largest segment
- total value if known/formatted
- whether small slices are grouped as "Other"

Example:  
"Donut chart showing revenue share across five categories with a total of 142,300 euros. Food is the largest segment at 42 percent."

This is exactly the kind of generated narration your chart analysis points toward.

## **11.3 Keyboard exploration**

A focused donut chart should support:

- left/right arrows move between slices
- enter selects slice
- escape clears selection
- narration includes label, value, and percentage
- center summary changes are also announced when relevant

## **11.4 Non-color-only differentiation**

Since donut charts rely heavily on color:

- selection/focus should also use offset, outline, or halo
- center-content change can reinforce focus
- high-contrast mode should not depend on hue alone

## **11.5 Reduced motion**

If reduced motion is active:

- avoid sweep/spin animations
- reduce hover transitions
- keep selection offset motion subtle or instant

## **11.6 Accessible textual fallback**

For enterprise/data-heavy contexts, an optional textual slice breakdown remains valuable and fits well with obers_ui's broader data-display ecosystem.

# **12\. Every extensive test needed for OiDonutChart**

## **A. Rendering and layout tests**

- renders basic donut chart correctly
- renders multiple slices with correct proportions
- resolves standard thickness correctly
- resolves thick and thin presets correctly
- custom thickness is respected within documented bounds
- center content renders correctly
- respects container constraints
- fills available container
- legend moves below on compact
- minimum useful size fallback appears when too cramped

## **B. Data mapping tests**

- mapper-based value extraction works with domain models
- shorthand data + value + labelBuilder builds correct normalized slices
- zero values are handled according to spec
- negative values are rejected/ignored according to spec
- sorting modes behave correctly
- grouped "Other" slice is computed correctly

## **C. Radius and center-content tests**

- inner and outer radii are computed correctly
- center content stays within inner bounds
- center content simplifies on small sizes according to spec
- selected-slice-driven center builder receives correct state
- total-formatted state is correct

## **D. Small-slice policy tests**

- keep preserves all slices
- hideLabel suppresses tiny labels only
- groupAsOther aggregates below-threshold slices correctly
- grouped other slice legend entry is correct

## **E. Interaction tests**

- hover tooltip appears on pointer
- tap tooltip appears on touch
- slice tap callback fires with correct payload
- selection state updates correctly
- tooltip dismisses correctly
- legend visibility toggle works
- keyboard slice traversal works
- center content updates correctly on selection when builder uses state

## **F. Accessibility tests**

- chart exposes semantic label
- auto-generated summary includes total when available
- focused slice narration includes label, value, and percentage
- center summary has sensible semantics
- legend items are keyboard operable
- reduced motion disables nonessential animation
- high-contrast mode preserves perceivable focus and selection

## **G. Theming tests**

- slice colors derive from chart palette
- local chart theme override applies correctly
- slice-level style override beats chart theme
- center-content typography resolves from theme
- tooltip and legend visuals resolve from theme
- light and dark goldens are stable

## **H. Responsive tests**

- compact legend below chart
- compact suppresses inline labels when necessary
- compact simplifies center content when necessary
- pointer uses hover tooltip, touch uses tap tooltip
- narrow layouts remain readable
- below minimum viable size shows fallback presentation

## **I. Performance tests**

- many-slice donuts suppress labels appropriately
- center-content layout caching avoids repeated expensive work
- hidden-slice recomputation is scoped
- repeated hover/selection does not leak memory
- compact/performance mode reduces complexity predictably

## **J. Golden tests**

- default donut chart
- donut chart with center total
- donut chart with selected slice
- compact donut chart with legend below
- donut chart with grouped "Other"
- dark theme donut chart
- high-contrast donut chart

# **13\. Final recommendation for OiDonutChart**

OiDonutChart should be the canonical obers_ui chart for **part-to-whole composition with summary space**:

- mapper-first input, just like the rest of the library
- shared polar architecture, not a one-off special widget
- center content as a first-class concept, because that is the main reason teams choose donut over pie
- the same responsive visualization behavior already defined in base concept, especially legend-below on compact, touch tooltips on tap, and "View full screen" fallback below minimum useful size
- the same theme-native component behavior expected by AI_README
- stronger accessibility than most chart ecosystems currently offer, especially through generated summaries and keyboard slice traversal

If done well, OiDonutChart becomes more than a variant. It becomes the **dashboard-native composition chart** in obers_ui.

When you say **continue**, I'll move to the next deep dive: **OiRadarChart&lt;T&gt;**.

continue 12

I'm on OiRadarChart now. This is the chart where multi-axis comparison, polygon readability, and radial labeling become the main design challenge, so I'm treating it as the reference for all non-part-to-whole polar comparison charts.

Thought for 6s

## **Part 12 - OiRadarChart&lt;T&gt;**

OiRadarChart is the chart where the polar family stops being about part-to-whole and starts being about **multi-axis profile comparison**.

That makes it a very important chart in obers_ui, because it proves the polar subsystem is not just pie/donut plus a few radial decorations. It also already exists in your real component inventory as OiRadarChart, tagged as a visualization composite for radar/spider multi-axis comparison, so the design should preserve that public identity while rebuilding it on the shared chart substrate.

At the same time, the architecture still needs to follow the same package rules:

- declarative and readable APIs
- mapper-first data binding
- composable behaviors
- theme-native visuals
- accessibility and responsive behavior as first-class concerns
- no parallel charting language that feels foreign to obers_ui

Those choices are also reinforced by the chart analysis, which recommends Syncfusion-style mappers as the best Flutter fit, behavior objects for interaction, and stronger accessibility than the current chart ecosystem typically provides.

# **1\. What OiRadarChart is**

OiRadarChart&lt;T&gt; is the standard polar chart for comparing one or more entities across multiple named dimensions arranged radially.

It should be the default chart in obers_ui for:

- skill profile comparison
- feature/capability comparison
- benchmark scoring across dimensions
- survey or assessment results
- product comparison across attributes
- maturity/spider charts
- compact multi-dimensional scorecards

Architecturally:

OiRadarChart&lt;T&gt; extends OiPolarChart&lt;T&gt;

But unlike OiPieChart and OiDonutChart, radar is not slice-driven. It is **axis-driven**:

- each spoke represents one dimension
- each series becomes a closed polygon
- values are plotted along radial distance from the center
- the chart's readability depends heavily on axis labels, polygon overlap, and fill/outline choices

So OiRadarChart should share the polar foundation while introducing a distinct radial-axis comparison model.

# **2\. How it looks, features, and important behavior**

Visually, OiRadarChart should support these core forms:

- single radar profile
- multiple radar profiles
- outline-only radar
- filled radar
- markers on vertices
- optional data labels
- optional circular or polygonal grid
- optional min/max or normalized scale
- optional highlighted axes
- optional selected series emphasis
- optional annotation bands or thresholds later

The most important visual behaviors are:

### **A. Axis readability is everything**

Radar charts fail when:

- there are too many axes
- labels are too long
- polygons overlap too heavily
- scale meaning is unclear

So obers_ui should optimize for the readable case:

- moderate axis count
- good label truncation/wrapping rules
- legend support
- restrained fill opacity
- strong focus/selection states

### **B. Overlap must remain legible**

Multi-series radar charts can become muddy fast. The defaults should bias toward:

- subtle fill
- clear outlines
- optional markers
- selected/hovered emphasis
- inactive fading

### **C. Scale semantics must stay honest**

Radar charts are especially easy to misuse when dimensions have different ranges or inconsistent meaning. So the API should make normalization or shared scale behavior explicit.

### **D. Compact layouts need strict degradation rules**

Your base concept already defines radar-specific responsive behavior: all visualization widgets fill their container, use LayoutBuilder, move legends below on compact, use tap tooltips on touch, and render a "View full screen" fallback below minimum size - with OiRadarChart specifically called out as having a **200dp minimum useful size**.

That means radar cannot pretend to stay readable when cramped. It must degrade honestly.

# **3\. How data input stays easy, logical, and consistent**

This is one of the most important DX decisions.

The cleanest approach is to keep radar mapper-first and close in spirit to the rest of the chart family, but acknowledge that radar data is shaped differently. Instead of x and y, radar needs:

- a dimension label
- a value on that dimension
- one or more series/entities

So the common case should look like:

OiRadarChart&lt;SkillScore&gt;(  
label: 'Team skill profile',  
data: scores,  
dimension: (item) => item.skill,  
value: (item) => item.score,  
)

For multiple profiles:

OiRadarChart&lt;SkillScore&gt;(  
label: 'Team skill comparison',  
series: \[  
OiRadarSeries&lt;SkillScore&gt;(  
id: 'frontend',  
label: 'Frontend Team',  
data: frontendScores,  
dimension: (item) => item.skill,  
value: (item) => item.score,  
),  
OiRadarSeries&lt;SkillScore&gt;(  
id: 'backend',  
label: 'Backend Team',  
data: backendScores,  
dimension: (item) => item.skill,  
value: (item) => item.score,  
),  
\],  
)

That is the right mental model:

- same data and mapper style as the rest of obers_ui charts
- series remain first-class
- the only real difference is that the coordinate system is radial-axis based

## **The consistency rule**

A developer should still feel the same overall pattern:

- raw domain models in
- mapper functions define meaning
- series are labeled and toggleable
- styles/theme/behaviors work the same way

That matters because OiRadarChart already exists in the real inventory and should feel like part of the same package, not a visualization-specific oddity.

## **Recommended series contract**

class OiRadarSeries&lt;T&gt; extends OiChartSeries&lt;T&gt; {  
final String Function(T item) dimension;  
final num? Function(T item) value;  
<br/>final String? Function(T item)? pointLabel;  
final String? Function(T item)? semanticValue;  
final OiSeriesStyle? style;  
}

That keeps the API compact, readable, and aligned with the rest of the chart family.

# **4\. Overall structure, API, props, and callbacks**

## **Public widget shape**

class OiRadarChart&lt;T&gt; extends StatefulWidget {  
final String label;  
final String? semanticLabel;  
<br/>final List&lt;T&gt;? data;  
final String Function(T item)? dimension;  
final num? Function(T item)? value;  
<br/>final List&lt;OiRadarSeries<T&gt;>? series;  
<br/>final OiRadarGridShape gridShape;  
final OiRadarScaleMode scaleMode;  
final int gridStepCount;  
final bool showMarkers;  
final bool showDataLabels;  
<br/>final OiChartLegendConfig? legend;  
final List&lt;OiChartBehavior&gt; behaviors;  
final List&lt;OiChartAnnotation&gt; annotations;  
final List&lt;OiChartThreshold&gt; thresholds;  
<br/>final OiChartThemeData? theme;  
final OiChartPerformanceConfig? performance;  
final OiChartAnimationConfig? animation;  
final OiChartAccessibilityConfig? accessibility;  
final OiChartSettingsDriverBinding? settings;  
final OiChartController? controller;  
final String? syncGroup;  
<br/>final OiChartLoadingStateConfig? loadingState;  
final OiChartEmptyStateConfig? emptyState;  
final OiChartErrorStateConfig? errorState;  
<br/>final ValueChanged&lt;OiRadarPointSelection&gt;? onPointTap;  
final ValueChanged&lt;OiRadarSeriesToggle&gt;? onSeriesVisibilityChange;  
}

## **Important enums**

enum OiRadarGridShape {  
polygon,  
circle,  
}  
<br/>enum OiRadarScaleMode {  
shared,  
normalized,  
}

### **What these mean**

- polygon grid is the classic radar/spider shape and usually the most semantically consistent.
- circle grid can sometimes feel cleaner visually, but polygon should likely be the default.
- shared means every dimension uses the same shared radial scale.
- normalized means values are normalized to a common scale before rendering.

Recommended defaults:

- gridShape: OiRadarGridShape.polygon
- scaleMode: OiRadarScaleMode.shared

That keeps behavior honest and predictable.

## **Callback philosophy**

Keep callbacks small and familiar:

- onPointTap
- onPointLongPress
- onSeriesVisibilityChange
- onSelectionChange

No renderer leaks into the public API.

# **5\. How it is customized through global obers_ui theming**

The same typed chart theme system should apply here as everywhere else. AI_README's implementation direction strongly favors theme-native configuration rather than isolated widget styling, and radar is already part of the official chart inventory.

So OiRadarChart should resolve through OiChartThemeData.

## **Global defaults especially important for radar charts**

The chart theme should provide:

- categorical palette
- radar grid line styling
- spoke line styling
- axis label styles
- default outline stroke width
- default fill opacity
- marker defaults
- selected/focused/inactive states
- legend and tooltip styling
- compact-mode simplification rules

## **Theme-derived defaults that matter here**

Without local overrides:

- each radar series color derives from the chart palette
- fills use softened opacity-aware palette variants
- grid/spokes derive from subtle border/grid tokens
- labels derive from chart/text theme
- selected and focus states derive from interaction tokens
- legend and tooltip surfaces derive from chart/overlay theme tokens

That theme-native approach is especially important for radar because overlapping polygons can quickly look visually disconnected from the rest of the UI if colors, borders, and emphasis are not harmonized.

# **6\. How it can be themed and configured on an element basis**

Keep the same four-level precedence used across the chart family.

### **Layer 1 - global app theme**

Default radar appearance.

### **Layer 2 - local chart theme override**

Per-chart override.

theme: OiChartThemeData(  
legend: ...,  
tooltip: ...,  
)

### **Layer 3 - series style**

Per-profile polygon fill/outline/marker style.

OiRadarSeries(  
id: 'frontend',  
label: 'Frontend Team',  
style: OiSeriesStyle(  
strokeWidth: 2,  
opacity: 0.22,  
marker: OiMarkerStyle(  
size: 6,  
),  
),  
)

### **Layer 4 - per-point override**

If needed, individual dimensions can override color or semantics.

## **Radar-specific style concerns**

OiSeriesStyle for radar should support:

- fillColor
- strokeColor
- strokeWidth
- opacity
- marker
- dataLabel
- hoverStyle
- selectedStyle
- inactiveStyle

A strong default rule here:

- outline clarity matters more than heavy fill
- fill should usually be subtle
- markers should be opt-in or density-aware for multi-series charts

That is the best readability tradeoff.

# **7\. How the logic works and how exactly it should be implemented**

## **7.1 Data normalization**

Each radar series should normalize as follows:

- map dimension labels
- map values
- compute or align the shared dimension order across visible series
- resolve scale mode
- compute angle for each dimension
- compute radial distance for each value
- compute vertex coordinates
- build polygon paths
- build point hit regions and label anchors

The normalized point should track:

- raw dimension
- raw value
- normalized/shared scaled radius
- angle
- x/y coordinate
- label text
- semantic text
- selected/focused state

## **7.2 Dimension alignment**

This is the most important radar-specific logic problem.

When multiple series are visible, all dimensions must align in one shared order.  
That means:

- build the visible dimension set
- keep order predictable
- handle missing dimensions explicitly
- ensure every visible series is rendered against the same angular axis arrangement

Recommended default:

- preserve first-seen/declaration order
- allow optional explicit dimension order later if needed

## **7.3 Scale resolution**

Radar charts are particularly sensitive to scale semantics.

### **Shared mode**

All values use one common radial domain.  
This is the safest default and best for honest comparison.

### **Normalized mode**

Each dimension can be normalized into a comparable 0-1 style scale before rendering.  
This can be useful, but it changes meaning and should be explicit.

Recommended default:

- shared

## **7.4 Grid and spoke generation**

The chart should support:

- spoke lines for each dimension
- concentric grid levels
- polygonal or circular grid rings
- optional highlighted axes or thresholds later

Recommended default:

- polygon grid for semantic clarity in classic radar charts

## **7.5 Polygon path generation**

For each visible series:

- compute vertices in dimension order
- connect them into a closed polygon
- optionally render fill
- optionally render outline
- optionally render markers at vertices

For missing dimensions:

- either break shape logic or treat as absent point based on documented policy
- recommended default: leave that vertex absent and do not silently fabricate values

## **7.6 Overlap and emphasis logic**

Multi-series radar charts become messy fast.  
So the renderer should support:

- inactive series fading
- selected series outline emphasis
- focused point highlighting
- restrained fill opacity
- series draw ordering

Recommended default draw order:

- grid/spokes
- filled polygons
- polygon outlines
- markers
- selected/focused emphasis
- tooltip/annotations

## **7.7 Label placement**

Axis labels sit around the perimeter, which makes them collision-prone.  
So the chart should:

- place labels just outside the outer radius
- support wrap/truncate rules
- suppress or shorten labels in compact layouts
- rely more on tooltip/legend when space is limited

This is one of the main reasons radar needs a hard minimum viable size, which your base concept already defines as 200dp.

# **8\. How performance is guaranteed even with huge datasets**

Radar charts are usually not about huge point counts. Their real performance/readability problems are:

- too many dimensions
- too many visible series
- too much label layout
- too many overlapping polygons

So performance architecture should focus on:

- layout simplification
- label suppression
- minimal recomputation
- overlap-aware rendering

## **8.1 Geometry is cheap, labels are the expensive part**

The polygon paths themselves are not usually the bottleneck.  
The expensive parts are:

- axis label measurement
- tooltip/legend generation
- semantics
- overlap management

## **8.2 Compact simplification**

Your base concept already requires:

- full-width container fill
- legend below on compact
- tap tooltips on touch
- full-screen fallback below minimum useful size

For radar that means:

- reduce inline point labels first
- maybe hide markers in dense states
- truncate perimeter labels
- rely on tooltip + legend
- render fallback when honest reading is no longer possible

## **8.3 Minimal recomputation**

Cache:

- dimension order
- angle map
- scale/radius map
- polygon paths
- label anchors
- legend items

Invalidate only when:

- data changes
- visible series changes
- size changes
- theme changes
- scale mode changes

## **8.4 Guardrails for dimension explosion**

A radar chart with 20 long dimensions is usually bad UX.  
The component should not prohibit it, but should make degradation easy:

- truncate labels
- reduce marker/detail layers
- optionally suggest full-screen
- perhaps emit debug diagnostics in dev mode

# **9\. How interactivity works and can be configured**

Radar should follow the same overall visualization rules as the rest of obers_ui:

- hover tooltip on pointer
- tap tooltip on touch
- legend below on compact
- minimum viable size fallback

## **Default interaction behavior**

### **Pointer**

- hover highlights nearest point or series region
- hover shows tooltip
- click selects point or series if enabled

### **Touch**

- tap resolves nearest logical point/axis position
- tap shows tooltip
- tap elsewhere dismisses
- hit regions should be forgiving, especially near vertices

## **Behavior-based configuration**

behaviors: \[  
OiTooltipBehavior(),  
OiSelectionBehavior(  
selectionMode: OiChartSelectionMode.point,  
),  
\]

That keeps radar aligned with the same composable behavior-object model recommended by the chart analysis.

## **Radar-specific interaction detail**

The chart should support:

- point selection
- whole-series emphasis
- legend-based visibility toggle
- keyboard traversal by dimension and series

Recommended default:

- point/vertex interaction with optional series emphasis

# **10\. How legend and additional information are implemented**

## **Legend**

Radar charts depend heavily on legend quality when more than one series is visible.  
Each legend item should show:

- series marker/color
- label
- visible/hidden state
- optional focus/isolate controls

Legend interactions:

- toggle visibility
- isolate one series
- keyboard operability
- move below chart on compact

That is fully aligned with the responsive visualization behavior already defined in base concept.

## **Tooltip**

Radar tooltips should support:

- series label
- dimension label
- formatted value
- optional normalized value if scale mode uses normalization
- optional point label / metadata rows

Tooltip clarity matters a lot here because perimeter labels often need to simplify.

## **Additional information layers**

Radar charts should support, conservatively:

- threshold rings
- highlighted axes
- selected-dimension emphasis
- annotations later if useful

But keep v1 disciplined. Radar becomes messy quickly if overloaded.

# **11\. How accessibility is guaranteed**

This is an area where obers_ui can be significantly better than typical chart libraries. The chart analysis explicitly points to generated accessibility summaries and keyboard exploration as major opportunities, and AI_README makes accessibility a first-class package concern.

## **11.1 Required semantics**

At minimum:

- label required
- semanticLabel optional override
- every series has a label
- every dimension can be narrated
- legend items are keyboard reachable and labeled

## **11.2 Auto-generated summary**

If not overridden, generate a summary including:

- chart type
- series count
- dimension count
- dominant strengths/high points where inferable
- overall scale mode

Example:  
"Radar chart comparing two teams across six skill dimensions. Frontend Team scores highest in UX and animation. Backend Team scores highest in infrastructure."

That kind of summary is exactly the accessibility direction your chart analysis points toward.

## **11.3 Keyboard exploration**

A focused radar chart should support:

- left/right move between dimensions
- up/down move between series at the same dimension
- enter selects
- escape clears selection
- narration includes series label, dimension label, and value

This is especially important because spatial keyboard exploration is almost nonexistent in typical chart libraries.

## **11.4 Non-color-only differentiation**

Radar charts often rely too much on fill color.  
So:

- series should be distinguishable by outline emphasis and optional markers
- selection/focus should add outline/halo, not just color change
- high-contrast mode should remain readable without hue dependence alone

## **11.5 Reduced motion**

If reduced motion is active:

- suppress sweeping polygon reveals
- reduce hover transitions
- keep selection changes minimal

## **11.6 Accessible textual fallback**

For enterprise/data-heavy use cases, a linked textual breakdown of series by dimension should be possible and consistent with the rest of obers_ui's data-display ecosystem.

# **12\. Every extensive test needed for OiRadarChart**

## **A. Rendering and layout tests**

- renders single-series radar chart correctly
- renders multiple-series radar chart correctly
- respects container constraints
- fills available container
- legend moves below on compact
- minimum useful size fallback appears below 200dp
- polygon grid renders correctly
- circular grid renders correctly
- markers render correctly when enabled

## **B. Data mapping tests**

- mapper-based dimension/value extraction works with domain models
- shorthand single-series API builds correct default series
- dimension alignment across multiple series is correct
- first-seen/declaration order is preserved by default
- missing dimensions are handled according to spec
- semantic values map correctly

## **C. Scale tests**

- shared scale mode computes correct radial distances
- normalized mode computes correct normalized distances
- visible-series changes recompute scale correctly
- zero/min/max handling behaves as documented

## **D. Path and grid tests**

- polygon paths close correctly
- spoke positions align with dimension order
- polygon grid levels are computed correctly
- circular grid levels are computed correctly
- focused/selected polygon emphasis paints correctly

## **E. Interaction tests**

- hover tooltip appears on pointer
- tap tooltip appears on touch
- nearest-point/vertex selection works correctly
- series visibility toggle callback fires correctly
- selection updates controller correctly
- tooltip dismisses correctly
- legend isolate/focus behavior works when enabled

## **F. Accessibility tests**

- chart exposes semantic label
- auto-generated summary includes series and dimension counts
- keyboard left/right navigates dimensions correctly
- keyboard up/down navigates series at a dimension correctly
- focused narration includes series, dimension, and value
- legend items are keyboard operable
- reduced motion disables nonessential animation
- high-contrast mode preserves perceivable differentiation

## **G. Theming tests**

- radar series colors derive from chart palette
- local chart theme override applies correctly
- series style override beats chart theme
- point-level override beats series style
- grid, spokes, legend, and tooltip visuals resolve from theme
- light and dark goldens are stable

## **H. Responsive tests**

- compact layout moves legend below
- compact truncates/simplifies axis labels appropriately
- touch uses tap tooltip, pointer uses hover tooltip
- narrow layouts remain readable or degrade honestly
- below minimum useful size renders fallback presentation

## **I. Performance tests**

- many-dimension charts suppress detail appropriately
- label layout caching avoids repeated expensive work
- hidden-series recomputation is scoped
- repeated hover/selection does not leak memory
- compact/performance mode reduces complexity predictably

## **J. Golden tests**

- default single-series radar chart
- multi-series filled radar chart
- outline-only radar chart
- compact radar chart with legend below
- selected point with tooltip
- dark theme radar chart
- high-contrast radar chart

# **13\. Final recommendation for OiRadarChart**

OiRadarChart should be the canonical obers_ui chart for **multi-dimensional profile comparison**:

- mapper-first input with dimension and value, consistent with the rest of the chart family
- built on the shared polar architecture, not a one-off spider widget
- aligned with the real obers_ui inventory and naming, where OiRadarChart already exists as a composite visualization primitive
- fully compliant with the responsive visualization rules already defined in base concept, including tap tooltips on touch, legend-below on compact, and the **200dp minimum useful size** for radar
- strongly theme-native and accessibility-forward, especially through generated summaries and keyboard traversal by dimension and series

If done well, OiRadarChart becomes the **profile-comparison chart** in obers_ui: distinctive, powerful, but still completely consistent with the rest of the package.

When you say **continue**, I'll move to the next deep dive: **OiGauge**.

continue 13

I'm on OiGauge now. This one looks simple on the surface, but it's actually where single-value clarity, threshold semantics, compact KPI usage, and accessibility discipline matter most, so I'm treating it as the reference for metric-style charts.

Thought for 9s

## **Part 13 - OiGauge**

OiGauge looks simple, but it is actually one of the most important charts to get disciplined.

It already exists in your real obers_ui inventory as a visualization composite and is explicitly described as a **gauge/speedometer chart with min-max range and colored zones**, which means the public identity is already set and should be preserved. It is also one of the visualization widgets covered by the shared responsive rules in base_concept, including tap-to-tooltip on touch, legend-below on compact, and a **minimum useful size of 120dp**.

So OiGauge should become the reference chart for **single-value metric visualization** in obers_ui:

- clear
- compact
- threshold-aware
- theme-native
- highly accessible
- not overloaded with fake complexity

It should also reflect the chart analysis: gauges are part of the target chart inventory, behavior-object interaction is still the strongest Flutter fit, and strong accessibility / responsive behavior are major opportunities where existing chart ecosystems are weak.

# **1\. What OiGauge is**

OiGauge is the standard metric chart for showing **one primary value inside a bounded range**, optionally with:

- colored zones
- thresholds
- target marker
- qualitative status
- compact KPI framing

It should be the default chart in obers_ui for:

- score / rating displays
- health or status meters
- progress within a bounded scale
- SLA or quality indicators
- utilization meters
- compact dashboard KPIs
- "value vs safe/warn/danger zone" visuals

Architecturally, it should be treated as a **polar metric composite**, not as a pie/donut hack:

OiGauge extends OiPolarChart&lt;double&gt;

or internally as a specialized metric/polar renderer that still shares:

- theme
- tooltip behavior
- animation config
- accessibility model
- responsive rules
- annotations / thresholds
- settings / sync hooks where meaningful

But unlike pie/donut/radar, gauge is not primarily about comparing categories or profiles. It is about **one value and its semantic context**.

# **2\. How it looks, features, and important behavior**

Visually, OiGauge should support these core forms:

- semicircle gauge
- three-quarter gauge
- full radial gauge later if needed
- needle pointer
- progress arc pointer
- marker / target indicator
- colored ranges / zones
- central value label
- optional subtitle / helper label
- optional min/max labels
- optional threshold labels
- optional compact "mini gauge" mode

The most important visual behaviors are:

### **A. The value must dominate**

The user should read the actual value first, then the status context. Decorative complexity should always be secondary.

### **B. Zones must be semantically clear**

Because AI_README already frames OiGauge as a min-max chart with colored zones, zones should be a first-class concept:

- safe
- warning
- danger
- target band
- custom named ranges

### **C. Compact readability matters more here than almost anywhere**

Base concept explicitly gives OiGauge a minimum useful size of **120dp**, which tells us this chart is expected to work in compact KPI contexts. So the component should be intentionally optimized for:

- cards
- dashboards
- side panels
- mobile summaries

### **D. It should not pretend to be a full dashboard inside one widget**

Gauge should remain disciplined. It is a single-metric chart, not a replacement for line/bar/radar analytics.

# **3\. How data input stays easy, logical, and consistent**

This should be one of the cleanest APIs in the whole chart family.

Because gauge is single-value-first, it should **not** force a series list in the common path. The most ergonomic API should look like:

OiGauge(  
label: 'Server health',  
value: 72,  
min: 0,  
max: 100,  
)

That is exactly the right DX for a gauge.

Then richer use stays additive:

OiGauge(  
label: 'Server health',  
value: 72,  
min: 0,  
max: 100,  
zones: \[  
OiGaugeZone(  
from: 0,  
to: 60,  
label: 'Healthy',  
),  
OiGaugeZone(  
from: 60,  
to: 85,  
label: 'Warning',  
),  
OiGaugeZone(  
from: 85,  
to: 100,  
label: 'Critical',  
),  
\],  
target: 75,  
)

## **The consistency rule**

Even though gauge is simpler than other charts, it should still feel like obers_ui:

- required label
- readable prop names
- theme-first defaults
- optional behaviors
- optional custom builders where appropriate
- same accessibility and responsive philosophy

## **Recommended data contracts**

class OiGaugeZone {  
final double from;  
final double to;  
final String? label;  
final Color? color;  
}  
<br/>class OiGaugeThreshold {  
final double value;  
final String? label;  
final Color? color;  
}

This keeps the model extremely understandable.

# **4\. Overall structure, API, props, and callbacks**

## **Public widget shape**

class OiGauge extends StatefulWidget {  
final String label;  
final String? semanticLabel;  
<br/>final double value;  
final double min;  
final double max;  
<br/>final double? target;  
final List&lt;OiGaugeZone&gt; zones;  
final List&lt;OiGaugeThreshold&gt; thresholds;  
<br/>final OiGaugeShape shape;  
final OiGaugePointerStyle pointerStyle;  
final OiGaugeThickness thickness;  
<br/>final String? valueLabel;  
final String? subtitle;  
final String Function(double value)? valueFormatter;  
<br/>final OiChartLegendConfig? legend;  
final List&lt;OiChartBehavior&gt; behaviors;  
<br/>final OiChartThemeData? theme;  
final OiChartAnimationConfig? animation;  
final OiChartAccessibilityConfig? accessibility;  
final OiChartSettingsDriverBinding? settings;  
final OiChartController? controller;  
<br/>final OiChartLoadingStateConfig? loadingState;  
final OiChartEmptyStateConfig? emptyState;  
final OiChartErrorStateConfig? errorState;  
<br/>final ValueChanged&lt;double&gt;? onTapValue;  
}

## **Important enums**

enum OiGaugeShape {  
semicircle,  
threeQuarter,  
fullCircle,  
}  
<br/>enum OiGaugePointerStyle {  
arc,  
needle,  
marker,  
}  
<br/>enum OiGaugeThickness {  
thin,  
standard,  
thick,  
custom,  
}

Recommended defaults:

- shape: OiGaugeShape.semicircle
- pointerStyle: OiGaugePointerStyle.arc
- thickness: OiGaugeThickness.standard

That gives the nicest balance of clarity and dashboard usability.

## **Callback philosophy**

Keep this minimal:

- onTapValue
- onSelectionChange only if selection is even supported
- no noisy renderer internals

Gauge usually does not need a heavy callback surface.

# **5\. How it is customized through global obers_ui theming**

OiGauge should resolve through the same typed chart theme system as the rest of the family, because AI_README is explicit that obers_ui components should derive color and state styling from theme rather than hardcoded local values.

## **Global defaults especially important for gauges**

The chart theme should provide:

- default gauge track color
- default progress/pointer color
- zone palette defaults
- threshold marker style
- center-value typography
- subtitle typography
- compact-mode thickness defaults
- selected/focus state styling

## **Theme-derived defaults that matter here**

Without local overrides:

- track derives from subtle surface/border tokens
- progress arc derives from semantic or chart palette tokens
- zones derive from semantic palette or chart palette variants
- value/subtitle text derive from text theme
- focus/selection derive from interaction tokens

This matters a lot because gauges are common in KPI cards, and those are exactly the places where theme inconsistency feels the most obvious.

# **6\. How it can be themed and configured on an element basis**

Use the same layered precedence as the rest of the chart package.

### **Layer 1 - global app theme**

Default gauge visuals everywhere.

### **Layer 2 - local chart theme override**

Per-gauge override.

theme: OiChartThemeData(  
selection: ...,  
)

### **Layer 3 - gauge-level explicit config**

For this chart instance:

- pointer style
- thickness
- shape
- zone list
- threshold list

### **Layer 4 - per-zone / per-threshold override**

Each zone or threshold can optionally define its own label/color.

## **Gauge-specific style concerns**

The style system should support:

- track color
- progress color
- threshold marker color
- pointer shadow / emphasis if any
- value label style
- subtitle style
- zone separator style

One important discipline:

- keep visual ornament low
- no glossy "speedometer" styling language
- it should feel like modern obers_ui, not skeuomorphic instrumentation

# **7\. How the logic works and how exactly it should be implemented**

## **7.1 Value normalization**

Gauge logic begins by normalizing:

- clamp or validate value
- resolve total span = max - min
- map value into angular progress within the configured shape

Recommended rule:

- by default clamp visible rendering to min/max
- still allow semantic reporting of out-of-range values if needed, but do not draw broken geometry

## **7.2 Angular layout**

For semicircle:

- start at 180°
- end at 0°

For three-quarter:

- use a wider sweep with a visually balanced gap

For full circle:

- mostly optional / second-wave
- still useful for some dashboard cases

Recommended default:

- semicircle, because it is usually the most readable compact gauge

## **7.3 Track, zones, and progress layering**

Recommended paint order:

- background track
- colored zones
- progress arc or pointer
- thresholds / target marker
- center value / labels
- hover/focus emphasis

That keeps the value readable and avoids clutter.

## **7.4 Zones**

Zones should be normalized into angle ranges using the same min/max domain.  
They should support:

- named ranges
- optional custom color
- optional legend participation
- gap/separator rendering if useful

Because OiGauge is explicitly documented as having colored zones, this needs to be a first-class part of the API, not a hack through annotations.

## **7.5 Pointer styles**

### **arc**

A filled progress segment from min to value. Best default.

### **needle**

A needle over a track. More instrument-like, but still useful.

### **marker**

A simple marker on a background track, often very clean for compact dashboards.

Recommended default:

- arc

## **7.6 Center-value layout**

The center content should support:

- main value
- optional subtitle
- optional selected/hovered zone label later

It must scale gracefully with compact sizes and never overlap the ring.

## **7.7 Threshold logic**

Thresholds are distinct from zones.  
A threshold should be:

- a single angular marker
- optionally labeled
- optionally semantic (target, warning, max safe, etc.)

This is important because "zone" and "threshold" communicate different things and should not be collapsed into one concept.

# **8\. How performance is guaranteed even with huge datasets**

Gauge is not a large-data chart. Its performance risk is not dataset scale. It is:

- repeated use in dashboards
- layout churn in compact cards
- text measurement
- animation over many instances

So performance strategy should focus on **many simultaneous gauges**, not one huge gauge.

## **8.1 Paint is cheap, repeated layout is the real concern**

A single gauge is light. Fifty animated gauges in a dashboard are not.

## **8.2 Cache normalized geometry**

Cache:

- track path
- zone arcs
- threshold marker positions
- text layout for stable labels

Invalidate only when:

- size changes
- value changes
- theme changes
- zone/threshold config changes

## **8.3 Compact simplification**

Base concept already says gauges are visualization widgets with responsive adaptation and a 120dp minimum useful size.  
So in compact mode:

- simplify subtitles first
- simplify threshold labels
- keep the value dominant
- rely less on legend
- below minimum size show "View full screen"

## **8.4 Dashboard density behavior**

When many gauges are visible:

- reduce animation
- suppress nonessential labels
- avoid heavy shadows/glows
- keep tooltip/interaction light

That will matter a lot in real KPI boards.

# **9\. How interactivity works and can be configured**

Gauge should follow the same global visualization rules from base_concept:

- tap tooltips on touch
- hover tooltips on pointer
- legend below on compact if present
- full-screen fallback below minimum useful size

## **Default interaction behavior**

### **Pointer**

- hover shows tooltip or value details
- hover may emphasize current zone
- click can select/focus if enabled

### **Touch**

- tap shows tooltip / detail
- tap elsewhere dismisses
- touch target should be forgiving for thin arcs or markers

## **Behavior-based configuration**

behaviors: \[  
OiTooltipBehavior(),  
\]

Gauge usually needs fewer behaviors than Cartesian charts, but it should still use the same behavior-object model recommended in the chart analysis.

## **Gauge-specific interaction detail**

Recommended interaction targets:

- whole gauge
- progress arc
- threshold marker if prominent
- named zone if interactive

By default, keep interaction simple:

- the gauge as a whole is tappable/hoverable
- tooltip explains value and maybe current zone

# **10\. How legend and additional information are implemented**

## **Legend**

Gauge often does not need a legend, but when zones are named it can be useful.

Legend should support:

- zone color
- zone label
- optional range text

On compact, it moves below the chart like all visualization widgets in base_concept.

## **Tooltip**

Tooltip should support:

- current value
- min/max range
- current zone label
- target/threshold info if present

Gauge tooltips should be short and information-dense.

## **Additional information layers**

Gauge should support:

- target marker
- warning threshold
- named zones
- center subtitle

But keep v1 disciplined. Do not overload it with excessive annotation systems unless they clearly improve the single-metric story.

# **11\. How accessibility is guaranteed**

This is a major opportunity, because gauge charts are often used in KPI contexts where clarity matters a lot.

The chart analysis explicitly highlights generated accessibility descriptions and stronger keyboard/screen-reader support as an area where chart libraries are generally weak.

## **11.1 Required semantics**

At minimum:

- label required
- semanticLabel optional override
- current value announced
- min/max announced
- current zone/threshold context announced if configured

## **11.2 Auto-generated summary**

If the developer does not override it, generate something like:

- chart type
- current value
- range
- current zone
- target if present

Example:  
"Gauge showing server health. Current value 72 on a scale from 0 to 100. In warning zone. Target is 75."

That is exactly the kind of generated accessibility help your chart analysis points toward.

## **11.3 Keyboard interaction**

Gauge does not need complex point-by-point traversal like scatter or radar, but it should still support:

- focus on the gauge
- enter/space to reveal details if interactive
- clear narration of value and zone

## **11.4 Non-color-only differentiation**

Because gauges often rely on green/yellow/red semantics:

- current state should not be conveyed by color alone
- text and semantic narration must reinforce it
- marker/threshold shape differences can help
- high-contrast mode should remain readable

## **11.5 Reduced motion**

If reduced motion is active:

- reduce or disable sweep animations
- keep value changes stable and minimal
- avoid flashy needle movement

## **11.6 Accessible textual fallback**

For dashboard contexts, a linked OiMetric or textual KPI line can serve as a fallback or companion view, which fits well with the rest of the package. AI_README already positions OiMetric as the KPI display primitive, so gauge and metric should feel complementary rather than redundant.

# **12\. Every extensive test needed for OiGauge**

## **A. Rendering and layout tests**

- renders semicircle gauge correctly
- renders three-quarter gauge correctly
- renders arc pointer correctly
- renders needle pointer correctly
- renders marker pointer correctly
- respects container constraints
- fills available container
- minimum useful size fallback appears below 120dp
- center value and subtitle layout correctly

## **B. Value and normalization tests**

- value maps correctly within min/max range
- out-of-range values clamp according to spec
- negative ranges behave correctly when allowed
- zone ranges map correctly to angular spans
- threshold markers map correctly to angle positions

## **C. Zone and threshold tests**

- multiple zones render correctly
- custom zone colors override theme defaults correctly
- thresholds render correctly
- target marker renders correctly
- current zone is resolved correctly from current value

## **D. Interaction tests**

- hover tooltip appears on pointer
- tap tooltip appears on touch
- tooltip dismisses correctly
- gauge tap callback fires correctly
- interactive zone emphasis works when enabled

## **E. Accessibility tests**

- chart exposes semantic label
- auto-generated summary includes value and range
- zone/target narration works when configured
- reduced motion disables nonessential sweep animation
- high-contrast mode preserves perceivable state

## **F. Theming tests**

- track derives from theme
- pointer/progress derives from theme
- zone defaults derive from theme palette
- local chart theme override applies correctly
- explicit zone color beats theme default
- light and dark goldens are stable

## **G. Responsive tests**

- chart fills container
- compact layout keeps value dominant
- pointer uses hover tooltip, touch uses tap tooltip
- legend moves below when present on compact
- below minimum useful size renders fallback correctly
- gauge renders correctly at 120dp, which base_concept explicitly requires as a test case

## **H. Performance tests**

- repeated value updates do not leak memory
- many gauges in a dashboard render efficiently
- cached paths invalidate only when needed
- reduced-detail mode engages correctly in dense dashboards

## **I. Golden tests**

- default semicircle gauge
- gauge with colored zones
- gauge with target marker
- compact gauge
- dark theme gauge
- high-contrast gauge

# **13\. Final recommendation for OiGauge**

OiGauge should be the canonical obers_ui chart for **single bounded metrics with semantic status context**:

- it should preserve the real inventory identity already defined in AI_README: gauge/speedometer with min-max range and colored zones
- it should follow the same responsive visualization rules as the rest of the chart family, including tap-on-touch tooltips, legend-below on compact, and the **120dp minimum useful size** from base_concept
- it should stay mapper-free in the common case because its value model is inherently simpler and that produces the best DX
- it should remain theme-native and consistent with obers_ui's no-hardcoded-colors philosophy
- it should be strongly accessible, especially because KPI/status visuals are often business-critical and should never depend on color alone

If done well, OiGauge becomes the **metric-status chart** in obers_ui: compact, clear, modern, and genuinely useful.

When you say **continue**, I'll move to the next deep dive: **OiHeatmap&lt;T&gt;**.

continue 14

I'm moving into OiHeatmap now. This is the first matrix chart, so the main challenge shifts to cell density, color-scale semantics, and readable 2D value scanning rather than lines, bars, or radial geometry.

Thought for 8s

## **Part 14 - OiHeatmap&lt;T&gt;**

OiHeatmap is the first chart where the library has to move beyond lines, bars, and radial geometry into a true **matrix visualization** model.

That shift is important. A heatmap is not primarily about continuity, single-value status, or part-to-whole composition. It is about **scanning a 2D grid of values through position and color intensity**. In your real implementation inventory, OiHeatmap already exists as a visualization composite with the identity "2D heatmap grid visualization," so that public role should stay intact while the internals move onto the shared chart substrate.

The design also needs to follow the same package-wide rules:

- mapper-first, readable APIs
- Oi\* naming
- typed theme integration
- responsive and touch-aware behavior
- accessibility taken seriously
- consistency with the rest of obers_ui rather than a one-off chart DSL

That direction is strongly supported by the chart analysis, which explicitly includes heatmap as a core chart type, highlights declarative configuration and composable behavior models as the strongest modern pattern, and stresses that accessibility and performance are weak in many chart ecosystems.

# **1\. What OiHeatmap is**

OiHeatmap&lt;T&gt; is the standard matrix chart for showing values across two discrete or ordered dimensions using a cell grid and color encoding.

It should be the default chart in obers_ui for:

- day/hour activity maps
- correlation matrices
- category-by-category density
- team workload grids
- weekly usage maps
- availability matrices
- risk/probability matrices
- compact analytical overviews where a table is too literal and a chart should surface patterns faster

Architecturally:

OiHeatmap&lt;T&gt; extends OiMatrixChart&lt;T&gt;

This matters because heatmap should not be implemented as a special case of bar or treemap logic. It belongs to its own matrix family with shared contracts for:

- x/y cell axes
- color scales
- cell geometry
- cell hit-testing
- density-aware labeling
- legend/color-scale explanation
- accessibility narration for cells and ranges

That family distinction also aligns well with the chart analysis, which treats heatmap as a separate category and notes that strong libraries expose it as a first-class visualization rather than as a hacky derived chart.

# **2\. How it looks, features, and important behavior**

Visually, OiHeatmap should support these core forms:

- standard rectangular heatmap grid
- ordered categorical heatmap
- time-based row/column heatmap
- correlation-style square matrix
- optional cell borders
- optional cell value labels
- optional row/column totals later
- optional highlighted ranges or selected cells
- optional grouped missing/empty state styling
- optional diverging color scale for negative/positive values
- optional sequential color scale for low-to-high density

The most important visual behaviors are:

### **A. The grid structure must stay readable**

Heatmaps fail when:

- row/column labels become illegible
- cells get too small
- the color scale is ambiguous
- there is too much per-cell text
- missing values and zero values look the same

### **B. Color semantics are central**

Unlike line or bar charts, the primary encoding is not only geometry - it is color intensity or color polarity.  
So the chart must make these things explicit:

- what low means
- what high means
- whether zero has special meaning
- whether negative/positive values diverge around a midpoint
- how missing data is shown

### **C. Density management matters more than decoration**

In a heatmap, the biggest readability challenge is often:

- too many rows/columns
- too many labels
- cells too small to inspect
- too much value text

So the defaults should bias toward clean scanning and detail-on-demand through tooltip rather than trying to show everything at once.

### **D. Compact degradation must be honest**

base_concept explicitly says that all visualization widgets fill their container, use LayoutBuilder, show tooltips on tap for touch and hover for pointer, move legends below on compact, and render a "View full screen" fallback below minimum useful size. For OiHeatmap, that minimum is explicitly **200x150dp**.

That means heatmap cannot pretend to stay useful when the matrix becomes too cramped.

# **3\. How data input stays easy, logical, and consistent**

This should stay mapper-first and feel as familiar as possible.

The chart analysis explicitly recommends mapper-based data binding as the best primary Flutter pattern. So the simplest common case should look like:

OiHeatmap&lt;ActivityCell&gt;(  
label: 'Usage by day and hour',  
data: cells,  
x: (item) => item.hour,  
y: (item) => item.weekday,  
value: (item) => item.count,  
)

That is exactly the right level of directness.

For more advanced use:

OiHeatmap&lt;ActivityCell&gt;(  
label: 'Usage by day and hour',  
data: cells,  
x: (item) => item.hour,  
y: (item) => item.weekday,  
value: (item) => item.count,  
cellLabel: (item) => '\${item.count}',  
semanticValue: (item) => '\${item.count} sessions',  
)

For matrix-like data from multiple groups later, the core API should still stay one-list-of-cells rather than forcing users into nested array formats unless they want to.

## **The consistency rule**

Even though heatmap uses a matrix coordinate system, the developer should still feel the same obers_ui chart language:

- data
- mapper functions
- optional theming
- behavior objects
- optional legend
- readable props and enums

## **Recommended cell contract**

class OiHeatmapCell&lt;T&gt; {  
final T rawItem;  
final Object x;  
final Object y;  
final num? value;  
final String? label;  
final String? semanticValue;  
}

Publicly, the widget should usually synthesize this normalized form from mapper functions rather than making the user build it.

# **4\. Overall structure, API, props, and callbacks**

## **Public widget shape**

class OiHeatmap&lt;T&gt; extends StatefulWidget {  
final String label;  
final String? semanticLabel;  
<br/>final List&lt;T&gt; data;  
final Object Function(T item) x;  
final Object Function(T item) y;  
final num? Function(T item) value;  
<br/>final String? Function(T item)? cellLabel;  
final String? Function(T item)? semanticValue;  
<br/>final OiHeatmapColorScale colorScale;  
final OiHeatmapCellLabelMode cellLabelMode;  
final bool showCellBorders;  
final bool squareCells;  
<br/>final OiChartLegendConfig? legend;  
final List&lt;OiChartBehavior&gt; behaviors;  
final List&lt;OiChartAnnotation&gt; annotations;  
final List&lt;OiChartThreshold&gt; thresholds;  
<br/>final OiChartThemeData? theme;  
final OiChartPerformanceConfig? performance;  
final OiChartAnimationConfig? animation;  
final OiChartAccessibilityConfig? accessibility;  
final OiChartSettingsDriverBinding? settings;  
final OiChartController? controller;  
final String? syncGroup;  
<br/>final OiChartLoadingStateConfig? loadingState;  
final OiChartEmptyStateConfig? emptyState;  
final OiChartErrorStateConfig? errorState;  
<br/>final ValueChanged&lt;OiHeatmapCellSelection&gt;? onCellTap;  
}

## **Important enums and config types**

enum OiHeatmapCellLabelMode {  
none,  
value,  
customLabel,  
}  
<br/>enum OiHeatmapMissingValueMode {  
hide,  
mutedCell,  
explicitMissingStyle,  
}  
<br/>enum OiHeatmapScaleType {  
sequential,  
diverging,  
categoricalLater,  
}

class OiHeatmapColorScale {  
final OiHeatmapScaleType type;  
final num? min;  
final num? max;  
final num? midpoint;  
final Gradient? gradient;  
final List&lt;Color&gt;? stops;  
final OiHeatmapMissingValueMode missingValueMode;  
}

Recommended defaults:

- type: sequential
- inferred min/max from visible data
- muted missing style, not silent confusion with zero

## **Callback philosophy**

Keep callbacks simple and chart-level:

- onCellTap
- onCellLongPress
- onSelectionChange

No renderer leaks.

# **5\. How it is customized through global obers_ui theming**

AI_README's real implementation direction favors theme-native components and explicitly lists OiHeatmap in the chart inventory, so heatmap should resolve through the same typed chart theme extension as the rest of the family.

## **Global defaults especially important for heatmaps**

The chart theme should provide:

- sequential gradient defaults
- diverging gradient defaults
- missing-value cell styling
- cell border styling
- axis label styles
- color-scale legend styling
- selected/focused cell styling
- compact-mode label suppression rules

## **Theme-derived defaults that matter here**

Without local overrides:

- low/high colors derive from chart palette extensions
- neutral/missing derives from subtle surface/border tokens
- axis and label text derive from text theme
- tooltip surface derives from overlay theme
- selection and focus derive from interaction tokens

One important theme rule:

- heatmap color scales should still harmonize with the broader app palette, but they must prioritize semantic clarity over decorative brand coloration.

# **6\. How it can be themed and configured on an element basis**

Use the same layered precedence as the rest of the chart system.

### **Layer 1 - global app theme**

Default heatmap appearance.

### **Layer 2 - local chart theme override**

Per-chart override.

theme: OiChartThemeData(  
legend: ...,  
tooltip: ...,  
)

### **Layer 3 - chart-level explicit config**

For this instance:

- colorScale
- showCellBorders
- squareCells
- label mode
- missing value behavior

### **Layer 4 - per-cell override**

Only where genuinely needed, for example:

- custom color for flagged values
- custom semantic text
- exceptional emphasis state

## **Heatmap-specific style concerns**

The style system should support:

- cell border color/width
- selected/focused cell outline
- muted missing-cell style
- text-on-cell contrast handling
- legend gradient styling

A key design discipline:

- if value labels are shown, text contrast must automatically adapt to cell background intensity

# **7\. How the logic works and how exactly it should be implemented**

## **7.1 Data normalization**

Each cell should normalize as follows:

- map x
- map y
- map value
- map optional labels/semantics
- compute visible x and y domains
- compute cell positions in the matrix
- resolve color from the value scale
- compute hit region and optional text placement

The normalized cell should track:

- raw x
- raw y
- raw value
- x index
- y index
- cell rect
- resolved fill
- label text
- semantic text
- selected/focused state
- missing/invalid state

## **7.2 Domain resolution**

Heatmaps usually work best with discrete row/column domains:

- categorical x and y
- ordered x and y
- time buckets if the developer already buckets the data

Recommended rule:

- keep domain ordering predictable
- preserve declaration/first-seen order unless an explicit order is provided
- later allow explicit x/y order lists for correlation or calendar-style views

## **7.3 Cell geometry**

The renderer should:

- compute a grid frame
- allocate row/column bands
- apply optional gaps or borders
- optionally preserve square cells if configured and space allows

squareCells: true is especially useful for correlation or calendar-like matrices, but it should remain optional because many real product heatmaps need to stretch into available space.

## **7.4 Color-scale resolution**

This is the most important heatmap-specific logic problem.

### **Sequential scale**

Use when values go from low to high and there is no meaningful midpoint.

### **Diverging scale**

Use when values meaningfully diverge around a midpoint, often zero.

The chart should make midpoint explicit when diverging is used.

Recommended default:

- infer sequential unless a midpoint or negative/positive domain clearly suggests diverging

## **7.5 Missing vs zero values**

This must be very explicit.  
A missing cell is not the same thing as a zero cell.

Recommended rules:

- zero value uses the valid scale at the low end or midpoint as appropriate
- missing value uses a distinct muted style
- tooltip and semantics explicitly say "No data" for missing cells

That preserves honesty and improves readability.

## **7.6 Cell labels**

Cell text should be optional and density-aware.  
Show labels only when:

- cell size is large enough
- label mode allows it
- contrast remains readable
- collision/overflow is not excessive

Recommended default:

- no inline labels, rely on tooltip and legend  
   That is the safest and most scalable default for real product heatmaps.

## **7.7 Color legend**

A heatmap often needs a more explicit legend than many other charts.  
This should be a proper color-scale legend component, not just a standard series legend:

- gradient bar
- min/max labels
- midpoint label if diverging
- missing-data marker if needed

That legend should still use the shared legend slotting/theming conventions.

# **8\. How performance is guaranteed even with huge datasets**

Heatmaps can get large quickly, especially with many rows/columns. The chart analysis emphasizes that performance and progressive rendering matter greatly in chart systems, and heatmap is one of the chart types where cell count can grow fast.

## **8.1 Cell rendering is simple, label rendering is not**

Like gauge and donut, geometry is relatively cheap.  
The expensive parts are:

- many cells
- label layout
- hit testing
- semantics if every cell becomes a separate accessible target

## **8.2 Viewport-first rendering**

For very large matrices or scrollable/future zoomable variants:

- only render visible rows/columns plus overscan
- suppress offscreen labels entirely

This becomes especially important for large correlation-like or operational matrices.

## **8.3 Label suppression**

This is one of the most important performance and readability controls.  
In dense layouts:

- hide cell labels first
- simplify axis labels if needed
- rely on tooltip for exact values

## **8.4 Cached scale and cell geometry**

Cache:

- x/y domain maps
- cell rects
- color-scale stops
- label placements
- legend gradient layout

Invalidate only when:

- data changes
- theme changes
- size changes
- color-scale config changes
- ordering changes

## **8.5 Compact simplification**

base_concept already defines the responsive rules for visualization widgets and the 200x150dp minimum useful size for OiHeatmap.  
So in compact mode:

- move legend below
- suppress cell labels
- keep tooltips tap-based on touch
- below minimum useful size, render "View full screen"

## **8.6 Very large matrix strategy**

For very large matrices:

- avoid per-cell text
- avoid heavy borders
- consider grouping selection semantics
- allow future windowing/virtualization inside the matrix family

That last point is especially aligned with obers_ui's broader comfort with virtualization patterns elsewhere in the package.

# **9\. How interactivity works and can be configured**

The same visualization rules from base_concept still apply:

- hover tooltip on pointer
- tap tooltip on touch
- legend below on compact
- minimum useful size fallback

## **Default interaction behavior**

### **Pointer**

- hover highlights cell
- hover shows tooltip
- click selects cell if enabled

### **Touch**

- tap highlights cell
- tap shows tooltip
- tap elsewhere dismisses
- hit target should favor the full cell rect, which is naturally touch-friendly if the chart is honest about minimum size

## **Behavior-based configuration**

behaviors: \[  
OiTooltipBehavior(),  
OiSelectionBehavior(  
selectionMode: OiChartSelectionMode.point,  
),  
\]

That keeps heatmap aligned with the same behavior-object model recommended by the chart analysis.

## **Heatmap-specific interaction detail**

The chart should support:

- cell selection
- row/column emphasis later
- pinned tooltip
- keyboard cell traversal

Recommended default:

- cell-level interaction with clear row/column labels in the tooltip

# **10\. How legend and additional information are implemented**

## **Legend**

Heatmap needs a color-scale legend more than a series legend.  
That legend should show:

- gradient or stepped scale
- min/max values
- midpoint if diverging
- missing-data style if relevant

The shared OiChartLegendConfig can still control placement and wrapping, but the rendered legend should be heatmap-specific.

## **Tooltip**

Tooltip should support:

- row label
- column label
- formatted value
- missing-data text if applicable
- optional custom metadata rows

This is often the primary exact-value access path.

## **Additional information layers**

Heatmap should support, conservatively:

- highlighted rows/columns
- threshold outlines
- selected cell callouts
- annotations for specific cells or ranges later

But keep v1 focused on cell scanning and value communication.

# **11\. How accessibility is guaranteed**

The chart analysis explicitly identifies accessibility as weak across chart ecosystems and recommends generated summaries and stronger keyboard exploration. OiHeatmap is a great place for obers_ui to do better.

## **11.1 Required semantics**

At minimum:

- label required
- semanticLabel optional override
- row/column context exposed for focused cells
- value or "No data" announced
- legend/color-scale explanation available semantically

## **11.2 Auto-generated summary**

If not overridden, generate a summary including:

- chart type
- row count
- column count
- value range
- whether scale is sequential or diverging
- notable hotspots or high-intensity areas where inferable

Example:  
"Heatmap showing usage by weekday and hour. Seven rows, twenty-four columns. Values range from 0 to 142. Highest activity occurs on weekday afternoons."

That is very much in line with the accessibility direction recommended by the chart analysis.

## **11.3 Keyboard exploration**

A focused heatmap should support:

- arrow keys move cell-by-cell
- home/end jump within a row
- page up/down later could move by row blocks if helpful
- enter selects
- escape clears selection
- narration includes row, column, and value

This could become one of the clearest examples of "chart keyboard exploration done properly" in obers_ui.

## **11.4 Non-color-only differentiation**

Because heatmap relies heavily on color:

- selection/focus must use outline, border, or halo, not color alone
- missing values must have a distinct pattern or muted style
- high-contrast mode should preserve interpretability beyond hue

## **11.5 Reduced motion**

If reduced motion is active:

- suppress animated intensity transitions where not necessary
- keep selection/focus transitions subtle

## **11.6 Accessible textual fallback**

For enterprise use, a linked table or detail list view of selected/visible cells is especially valuable and fits well with obers_ui's strong data-display ecosystem.

# **12\. Every extensive test needed for OiHeatmap**

## **A. Rendering and layout tests**

- renders basic heatmap grid correctly
- respects container constraints
- fills available container
- legend moves below on compact
- minimum useful size fallback appears below 200x150dp
- square cell mode renders correctly
- stretched cell mode renders correctly
- cell borders render correctly

## **B. Data mapping tests**

- mapper-based x/y/value extraction works with domain models
- x/y domain ordering is stable and predictable
- duplicate cell keys are handled according to spec
- cell label and semantic value mapping works correctly
- missing values are normalized correctly

## **C. Color scale tests**

- sequential scale maps low/high values correctly
- diverging scale maps around midpoint correctly
- explicit min/max override inferred domain correctly
- explicit midpoint is respected
- missing cells use distinct styling
- zero values are distinct from missing values

## **D. Interaction tests**

- hover tooltip appears on pointer
- tap tooltip appears on touch
- cell selection works correctly
- tooltip dismisses correctly
- onCellTap callback fires with correct payload
- pinned or selected tooltip state behaves correctly

## **E. Accessibility tests**

- chart exposes semantic label
- auto-generated summary includes row/column counts
- keyboard arrow navigation moves through cells correctly
- focused cell narration includes row, column, and value
- missing cell narration says "No data"
- legend/color-scale explanation is represented semantically
- reduced motion disables nonessential animations
- high-contrast mode preserves selected/focused visibility

## **F. Theming tests**

- color-scale defaults derive from chart theme
- local chart theme override applies correctly
- explicit colorScale config beats chart defaults
- selection/focus styling resolves from theme
- light and dark goldens are stable

## **G. Responsive tests**

- compact layout moves legend below
- compact suppresses inline cell labels
- pointer uses hover tooltip, touch uses tap tooltip
- narrow layouts degrade honestly
- below minimum useful size shows fallback presentation

## **H. Performance tests**

- large matrices suppress labels appropriately
- viewport filtering excludes offscreen cells where applicable
- cached domain/cell geometry invalidates only when necessary
- repeated hover and selection do not leak memory
- dense matrices remain usable in performance mode

## **I. Golden tests**

- default heatmap
- diverging heatmap
- heatmap with selected cell
- compact heatmap with legend below
- dark theme heatmap
- high-contrast heatmap
- heatmap with missing-value styling

# **13\. Final recommendation for OiHeatmap**

OiHeatmap should be the canonical obers_ui chart for **2D value scanning through matrix position and color intensity**:

- it should preserve the real inventory identity already defined in AI_README: a chart composite for heatmap, grid, density, and correlation use cases
- it should follow the same responsive visualization rules already defined in base_concept, especially touch-on-tap tooltips, legend-below on compact, and the explicit **200x150dp minimum useful size**
- it should use mapper-first input with x, y, and value, keeping DX aligned with the rest of the library
- it should treat color-scale semantics, missing-vs-zero handling, and keyboard cell exploration as first-class concerns
- it should remain theme-native and accessibility-forward, because those are exactly the areas where the wider chart ecosystem is still weakest

If done well, OiHeatmap becomes the **matrix analysis chart** in obers_ui: compact, expressive, and fully consistent with the rest of the package.

When you say **continue**, I'll move to the next deep dive: **OiTreemap&lt;TNode&gt;**.

continue 15

I'm on OiTreemap now. This is the first hierarchical chart, so the main challenge shifts to nested structure, area partitioning, drill readability, and label hierarchy rather than axes, angles, or matrix cells.

Thought for 7s

## **Part 15 - OiTreemap&lt;TNode&gt;**

OiTreemap is the first chart where the charting system has to handle **hierarchy as the primary data model**.

That changes the architecture meaningfully. A treemap is not driven by axes, slices, or a simple matrix. It is driven by:

- parent-child structure
- proportional area partitioning
- depth
- aggregation
- drill focus
- nested label readability

In your real implementation inventory, OiTreemap already exists as a composite visualization for **hierarchy**, **proportional values**, and **space-filling layout**, so the public identity should stay exactly that while the internal implementation moves onto a proper hierarchical chart substrate.

It also needs to stay aligned with the rest of obers_ui:

- readable, declarative props
- mapper-first data binding
- theme-native visuals
- accessibility-first behavior
- responsive simplification
- shared chart patterns instead of a totally separate mini-library

That direction is also strongly supported by the chart analysis, which treats treemap as a first-class chart type and recommends composable interactions, progressive performance thinking, and stronger accessibility than the current ecosystem usually offers.

# **1\. What OiTreemap is**

OiTreemap&lt;TNode&gt; is the standard hierarchical chart for showing **nested proportional values as space-filling rectangles**.

It should be the default chart in obers_ui for:

- category/subcategory breakdowns
- storage and file-size maps
- budget allocation hierarchies
- product/category contribution views
- organizational resource maps
- risk/cost decomposition
- dashboards where many hierarchical parts must fit in one compact visual area

Architecturally:

OiTreemap&lt;TNode&gt; extends OiHierarchicalChart&lt;TNode&gt;

That matters a lot. Treemap should not be implemented as a bar-chart variation or a custom one-off painter. It belongs to a hierarchy family with shared concepts like:

- node id / parent id
- aggregation
- depth
- node path
- layout algorithms
- drill state
- breadcrumb/focus context
- hierarchical accessibility narration

That also aligns naturally with existing obers_ui language, because the package already has hierarchy-aware components like OiBreadcrumbs and OiPathBar, which makes breadcrumb/drill navigation feel native rather than bolted on.

# **2\. How it looks, features, and important behavior**

Visually, OiTreemap should support these core forms:

- flat single-root treemap
- multi-depth hierarchical treemap
- optional parent group framing
- optional per-node labels
- optional value labels
- optional breadcrumb/drill navigation
- optional highlighted branch
- optional selected node emphasis
- optional squarified or slice/dice layout strategies
- optional grouped tiny-node behavior
- optional color by branch/category/status
- optional compact drill summary

The most important visual behaviors are:

### **A. Area must communicate value clearly**

The core meaning is proportional area. Everything else is secondary.

### **B. Hierarchy must remain readable**

A treemap fails when:

- deep nodes become too tiny to understand
- labels overlap or become noise
- parent-child structure disappears visually
- color semantics are unclear
- drill focus is missing when there are many nodes

### **C. Small-node handling is critical**

Treemaps naturally produce tiny leaves. The library must handle them deliberately:

- hide labels
- group tiny children
- rely on tooltip
- support drill to branch rather than forcing everything visible at once

### **D. Mobile and compact modes need strict simplification**

base_concept explicitly calls out that complex visualizations like OiTreemap should reduce detail on mobile: fewer data labels, simpler rendering, and reduced animation. It also applies the shared visualization rules: fill container, use LayoutBuilder, touch tooltips on tap, legend below on compact, and fallback below minimum useful size.

So treemap must degrade honestly rather than pretending all hierarchy levels are readable in tiny spaces.

# **3\. How data input stays easy, logical, and consistent**

This is one of the most important DX decisions.

The chart analysis strongly favors mapper-first binding and avoiding library-owned forced data shapes. So the best API should let developers pass real hierarchical domain objects or flat node lists and map them declaratively.

The most flexible common case should look like:

OiTreemap&lt;CategoryNode&gt;(  
label: 'Revenue by category',  
data: nodes,  
id: (node) => node.id,  
parentId: (node) => node.parentId,  
value: (node) => node.revenue,  
nodeLabel: (node) => node.name,  
)

That is extremely readable and fits obers_ui well.

For already nested domain models, a second path can exist later, but the flat-node mapper model should be the main API because it is:

- easy to serialize
- easy to derive from APIs
- easy to transform
- consistent with the chart-family mapping style

## **The consistency rule**

Even though hierarchy is different from Cartesian and polar charts, the developer should still feel the same overall pattern:

- data
- mapper functions
- required label
- optional legend/behaviors/theme/accessibility
- optional custom builders
- predictable naming

## **Recommended mapper contract**

class OiTreemap&lt;TNode&gt; extends StatefulWidget {  
final List&lt;TNode&gt; data;  
final String Function(TNode node) id;  
final String? Function(TNode node) parentId;  
final num Function(TNode node) value;  
final String Function(TNode node) nodeLabel;  
final Color? Function(TNode node, OiTreemapNodeContext context)? color;  
final String? Function(TNode node)? semanticValue;  
}

That is strong, readable, and consistent.

# **4\. Overall structure, API, props, and callbacks**

## **Public widget shape**

class OiTreemap&lt;TNode&gt; extends StatefulWidget {  
final String label;  
final String? semanticLabel;  
<br/>final List&lt;TNode&gt; data;  
final String Function(TNode node) id;  
final String? Function(TNode node) parentId;  
final num Function(TNode node) value;  
final String Function(TNode node) nodeLabel;  
<br/>final Color? Function(TNode node, OiTreemapNodeContext context)? color;  
final String? Function(TNode node)? semanticValue;  
<br/>final OiTreemapLayoutAlgorithm layoutAlgorithm;  
final OiTreemapLabelMode labelMode;  
final OiTreemapDrillMode drillMode;  
final bool showBranchBorders;  
final bool showBreadcrumbs;  
<br/>final OiChartLegendConfig? legend;  
final List&lt;OiChartBehavior&gt; behaviors;  
final List&lt;OiChartAnnotation&gt; annotations;  
<br/>final OiChartThemeData? theme;  
final OiChartPerformanceConfig? performance;  
final OiChartAnimationConfig? animation;  
final OiChartAccessibilityConfig? accessibility;  
final OiChartSettingsDriverBinding? settings;  
final OiChartController? controller;  
final String? syncGroup;  
<br/>final OiChartLoadingStateConfig? loadingState;  
final OiChartEmptyStateConfig? emptyState;  
final OiChartErrorStateConfig? errorState;  
<br/>final ValueChanged&lt;OiTreemapNodeSelection<TNode&gt;>? onNodeTap;  
final ValueChanged&lt;OiTreemapNodeSelection<TNode&gt;>? onNodeLongPress;  
}

## **Important enums**

enum OiTreemapLayoutAlgorithm {  
squarified,  
sliceDice,  
binary,  
}  
<br/>enum OiTreemapLabelMode {  
none,  
nodeLabel,  
value,  
nodeLabelAndValue,  
}  
<br/>enum OiTreemapDrillMode {  
none,  
focusBranch,  
replaceRoot,  
}

Recommended defaults:

- layoutAlgorithm: OiTreemapLayoutAlgorithm.squarified
- labelMode: OiTreemapLabelMode.nodeLabel
- drillMode: OiTreemapDrillMode.focusBranch

That gives the best balance of readability and interaction.

## **Callback philosophy**

Keep callbacks simple and chart-level:

- onNodeTap
- onNodeLongPress
- onSelectionChange

No internal layout-engine events should leak into the public API.

# **5\. How it is customized through global obers_ui theming**

OiTreemap should resolve through OiChartThemeData, just like the rest of the chart system. AI_README is explicit that chart composites are part of the main package and should follow the same theme-native, typed-component philosophy rather than becoming manual-styled islands.

## **Global defaults especially important for treemap**

The chart theme should provide:

- hierarchical palette defaults
- branch border styling
- node gap / padding styling
- label text styles
- inactive/focused/selected node styling
- breadcrumb/drill header styling
- compact-mode label suppression rules
- tooltip styling

## **Theme-derived defaults that matter here**

Without local overrides:

- node fills derive from chart palette or branch-based palette logic
- borders derive from subtle surface/border tokens
- labels derive from chart/text theme
- selection/focus derives from interaction tokens
- breadcrumb/drill UI derives from existing navigation theme language

That last point matters a lot: if treemap supports drill and breadcrumbs, those controls should feel like native obers_ui navigation, not a chart-specific reinvention.

# **6\. How it can be themed and configured on an element basis**

Use the same layered precedence as the rest of the chart family.

### **Layer 1 - global app theme**

Default treemap appearance everywhere.

### **Layer 2 - local chart theme override**

Per-chart override.

theme: OiChartThemeData(  
legend: ...,  
tooltip: ...,  
)

### **Layer 3 - chart-level explicit config**

For this instance:

- layout algorithm
- label mode
- drill mode
- border visibility
- breadcrumb visibility

### **Layer 4 - per-node override**

Nodes can override:

- fill color
- semantic label
- emphasis state
- maybe later corner/branch styling if needed

## **Treemap-specific style concerns**

The style system should support:

- node fill color
- node border color/width
- branch framing color
- selected/focused outline
- label style
- inactive branch fade

A crucial design rule:

- parent/child separation should be visually clear without becoming heavy or noisy

# **7\. How the logic works and how exactly it should be implemented**

## **7.1 Data normalization**

Each node should normalize as follows:

- map id
- map parentId
- map value
- map label and optional semantics
- build hierarchy tree
- validate tree integrity
- aggregate branch totals where needed
- compute depth and ancestry paths
- run layout algorithm
- build visible node rects and hit regions

The normalized node should track:

- raw node
- id
- parentId
- depth
- aggregated value
- label
- semantic text
- path
- rect
- visibility state
- selected/focused/drilled state

## **7.2 Hierarchy validation**

This is one of the most important treemap-specific logic problems.  
The chart must handle:

- missing parents
- duplicate ids
- circular references
- multiple roots
- zero or invalid branch totals

Recommended behavior:

- fail clearly in debug/dev with actionable diagnostics
- handle gracefully in production where possible
- document exactly how orphan nodes are treated

## **7.3 Aggregation logic**

Treemap needs clear aggregation semantics.  
Rules should be:

- leaf values come from value(node)
- branch values are aggregated from descendants unless explicitly overridden later
- hidden nodes are excluded from visible layout totals
- drill/focus modes recompute visible layout from the focused root or branch context

## **7.4 Layout algorithms**

Treemap should support at least:

### **squarified**

Best default for readability because it tries to keep rectangles closer to square.

### **sliceDice**

Useful for predictable hierarchy partitions and certain audit-style views.

### **binary**

Useful as another balanced partitioning strategy later.

Recommended default:

- squarified

That is the most user-friendly default for most dashboards.

## **7.5 Drill behavior**

This is the most important interaction-specific design area.

### **none**

Treemap is static; users inspect with tooltip only.

### **focusBranch**

Selected branch is emphasized while still keeping broader context visible.

### **replaceRoot**

Selecting/drilling a branch re-roots the layout to that branch.

Recommended default:

- focusBranch for general dashboards
- replaceRoot can be excellent in exploration-focused contexts

## **7.6 Label placement**

Treemap labels should be opportunistic, not forced.  
Show labels only when:

- node rect is large enough
- text remains readable
- contrast is sufficient
- depth/context remains understandable

Recommended default:

- show node label only on sufficiently large visible rectangles
- use tooltip for exact detail
- allow drill/breadcrumbs to reveal context instead of cramming every label

## **7.7 Color semantics**

Treemap color can mean:

- branch/category grouping
- intensity/value
- status/risk

The default should stay simple and stable:

- category/branch-based color assignment by default
- allow explicit per-node override
- do not mix area and intensity encoding without explicit developer intent

# **8\. How performance is guaranteed even with huge datasets**

Treemaps can get expensive when there are many nodes and many visible labels. base_concept explicitly calls out OiTreemap as one of the complex visualizations that should reduce detail on mobile.

## **8.1 Layout is more expensive than paint**

The expensive parts are:

- hierarchy building
- aggregation
- layout partitioning
- label measurement
- semantics for many nodes

The actual rectangle painting is comparatively cheap.

## **8.2 Visible-depth simplification**

In compact/performance modes:

- reduce data labels
- reduce branch border complexity
- prefer tooltip over inline text
- simplify drill context visuals
- maybe show only top N visible labels at a level

That directly matches base_concept's requirement that complex visualizations reduce detail on mobile.

## **8.3 Cached hierarchy and layout**

Cache:

- hierarchy tree
- aggregated values
- layout rects
- visible drill branch
- label fit decisions

Invalidate only when:

- data changes
- drill state changes
- visibility changes
- size changes
- theme changes
- layout algorithm changes

## **8.4 Hit-testing optimization**

Treemap nodes already have rects, which is good for hit-testing.  
Use:

- rect-based hit lookup
- visible-node-only hit maps
- avoid building semantics nodes for every tiny hidden/irrelevant node

## **8.5 Compact fallback**

The shared visualization rules still apply:

- touch tooltips on tap
- legend below on compact
- minimum viable size fallback when too cramped

For treemap, even if no explicit size number is given, it should still participate in that fallback policy honestly.

# **9\. How interactivity works and can be configured**

Treemap should follow the same high-level interaction rules as the rest of obers_ui visualizations:

- hover tooltip on pointer
- tap tooltip on touch
- compact legend below
- minimum viable size fallback

## **Default interaction behavior**

### **Pointer**

- hover highlights node
- hover shows tooltip
- click selects node
- second click or breadcrumb can drill if enabled

### **Touch**

- tap highlights node
- tap shows tooltip
- tap or secondary action can drill if configured
- hit targets are naturally rect-based and should be touch-friendly when the chart stays within honest minimum sizes

## **Behavior-based configuration**

behaviors: \[  
OiTooltipBehavior(),  
OiSelectionBehavior(  
selectionMode: OiChartSelectionMode.point,  
),  
\]

Treemap can also benefit from:

- a drill behavior
- keyboard focus behavior
- maybe breadcrumb navigation behavior via chart controller state

That still follows the same behavior-object philosophy recommended by the chart analysis.

## **Treemap-specific interaction detail**

The chart should support:

- node selection
- branch drill/focus
- breadcrumb navigation
- pinned tooltip
- keyboard traversal by visible node order

Recommended default:

- select on tap/click
- drill on second activation or explicit breadcrumb/toolbar action depending on config

# **10\. How legend and additional information are implemented**

## **Legend**

Treemap legends are different from line/bar legends.  
A treemap legend is usually most useful when color represents:

- category/branch
- status
- risk class

If color is purely hierarchical/category-based, the legend should show:

- branch color
- branch label
- optional total

If color is intensity-based later, a color-scale legend may be more appropriate.

## **Tooltip**

Tooltip should support:

- node label
- formatted value
- parent/branch path
- percentage of parent
- percentage of whole
- optional custom metadata rows

This is especially important because many nodes will not have room for full labels.

## **Additional information layers**

Treemap should support, conservatively:

- breadcrumb/drill header
- selected path highlighting
- threshold/status emphasis via color if configured
- annotations for highlighted nodes later

Do not overload v1 with too many overlays.

# **11\. How accessibility is guaranteed**

This is a major opportunity, because hierarchical charts are often weakly supported in current chart libraries. The chart analysis explicitly highlights accessibility as an area where the ecosystem is weak and recommends auto-generated descriptions and keyboard exploration.

## **11.1 Required semantics**

At minimum:

- label required
- semanticLabel optional override
- node label and value available semantically
- parent/branch path available for focused nodes
- drill state explained
- breadcrumb navigation keyboard reachable and labeled if shown

## **11.2 Auto-generated summary**

If not overridden, generate a summary including:

- chart type
- node count or visible node count
- top-level branch count
- largest visible node/branch
- whether chart is currently drilled/focused

Example:  
"Treemap showing storage usage across six top-level folders. Media is the largest branch. Currently focused on Projects."

That is exactly the kind of accessibility help your chart analysis points toward.

## **11.3 Keyboard exploration**

A focused treemap should support:

- arrow keys move between visible neighboring nodes
- enter selects or drills
- backspace/escape moves up one drill level where appropriate
- narration includes label, value, and parent path

This is where treemap can become genuinely strong compared with the broader ecosystem.

## **11.4 Non-color-only differentiation**

Because treemap often uses color for branches:

- selection/focus should also use outline, elevation, or inset/halo
- drill context should not rely on color alone
- high-contrast mode should remain readable through borders and text contrast

## **11.5 Reduced motion**

If reduced motion is active:

- reduce or disable animated relayout on drill
- keep focus transitions subtle
- avoid flashy rectangle morphing

## **11.6 Accessible textual fallback**

A linked hierarchical list or table view is especially valuable here and fits naturally with obers_ui's broader data-display ecosystem.

# **12\. Every extensive test needed for OiTreemap**

## **A. Rendering and layout tests**

- renders basic treemap correctly
- renders multi-depth hierarchy correctly
- respects container constraints
- fills available container
- labels appear only where space allows
- branch borders render correctly
- breadcrumb/drill header renders correctly when enabled
- legend moves below on compact

## **B. Data mapping and hierarchy tests**

- mapper-based id/parentId/value/label extraction works correctly
- duplicate id handling follows spec
- missing parent handling follows spec
- circular hierarchy detection works
- aggregation of branch totals is correct
- multiple roots handling follows spec
- hidden/filtered nodes recompute layout correctly

## **C. Layout algorithm tests**

- squarified layout produces valid non-overlapping rects
- slice-dice layout produces valid non-overlapping rects
- binary layout produces valid non-overlapping rects
- visible area proportions match expected values within tolerance

## **D. Drill and interaction tests**

- hover tooltip appears on pointer
- tap tooltip appears on touch
- node tap callback fires correctly
- selection state updates correctly
- drill mode focusBranch behaves correctly
- drill mode replaceRoot behaves correctly
- breadcrumb navigation restores expected parent context
- tooltip dismisses correctly

## **E. Accessibility tests**

- chart exposes semantic label
- auto-generated summary includes largest branch
- focused node narration includes label, value, and path
- keyboard traversal moves through visible nodes correctly
- enter drills/selects correctly
- escape/backspace exits drill correctly when configured
- breadcrumb controls are keyboard operable
- reduced motion disables nonessential relayout animations
- high-contrast mode preserves focus and branch readability

## **F. Theming tests**

- node colors derive from theme palette by default
- local chart theme override applies correctly
- per-node color override beats theme default
- branch border, tooltip, and legend visuals resolve from theme
- light and dark goldens are stable

## **G. Responsive tests**

- compact legend moves below
- compact suppresses excess labels
- mobile/performance mode reduces detail for many nodes
- pointer uses hover tooltip, touch uses tap tooltip
- cramped layouts degrade honestly or show fallback presentation

## **H. Performance tests**

- large hierarchies layout within acceptable budget
- label suppression avoids excessive measurement
- cached hierarchy/layout invalidates only when necessary
- repeated drill in/out does not leak memory
- many-node treemap remains interactive in performance mode

## **I. Golden tests**

- default treemap
- treemap with drill header
- treemap with selected node
- compact treemap with legend below
- dark theme treemap
- high-contrast treemap
- mobile-simplified treemap with reduced labels

# **13\. Final recommendation for OiTreemap**

OiTreemap should be the canonical obers_ui chart for **hierarchical proportional space-filling analysis**:

- it should preserve the real inventory identity already defined in AI_README: chart, treemap, hierarchy, proportional, space-filling
- it should follow the shared visualization rules in base_concept, especially touch-on-tap tooltips, legend-below on compact, and reduced detail on mobile for complex visualizations like treemap
- it should use mapper-first hierarchy binding with id, parentId, value, and nodeLabel, keeping DX aligned with the rest of the library
- it should treat drill state, label suppression, and hierarchical accessibility as first-class concerns
- it should stay theme-native and consistent with existing obers_ui hierarchy/navigation patterns rather than inventing a chart-only UI language

If done well, OiTreemap becomes the **hierarchical breakdown chart** in obers_ui: compact, information-dense, and still readable because it knows when to simplify.

When you say **continue**, I'll move to the next deep dive: **OiSankey&lt;TNode, TLink&gt;**.

continue 16

I'm moving into OiSankey now. This is the first flow chart, so the main challenge becomes node-link semantics, directional readability, and weighted path interaction rather than axes, cells, or nested rectangles.

Thought for 6s

## **Part 16 - OiSankey&lt;TNode, TLink&gt;**

OiSankey is the first chart where the charting system has to model **directional weighted flow** as the primary visual language.

That changes the architecture meaningfully. A sankey diagram is not driven by x/y axes, slices, or hierarchical area partitioning. It is driven by:

- nodes
- directed links
- weighted thickness
- stage/group ordering
- routing
- path readability
- conservation of flow context

In your real implementation inventory, OiSankey already exists as a composite visualization and is explicitly described as a **flow diagram showing weighted flows between nodes**, so that public identity should remain unchanged while the internal design is rebuilt on a shared flow-chart substrate.

It also needs to stay aligned with the rest of obers_ui:

- readable and declarative props
- mapper-first data binding
- typed theme integration
- responsive simplification
- touch-aware interaction
- accessibility as a real requirement

That direction is also strongly supported by your chart analysis, which treats sankey as a first-class chart type, emphasizes declarative APIs, recommends composable behavior objects, and calls out accessibility and responsive adaptation as places where the ecosystem is still weak.

# **1\. What OiSankey is**

OiSankey&lt;TNode, TLink&gt; is the standard flow chart for showing **weighted movement, allocation, or distribution between nodes**.

It should be the default chart in obers_ui for:

- budget allocation flows
- user journey stage transitions
- energy/material/resource flow
- source-to-destination breakdowns
- funnel-like branching where actual weighted paths matter
- process flow contribution analysis
- "where things go" dashboards

Architecturally:

OiSankey&lt;TNode, TLink&gt; extends OiFlowChart&lt;TNode, TLink&gt;

That matters a lot. Sankey should not be implemented as a one-off painter or as a hacked workflow graph. It belongs to its own flow family with shared concepts like:

- node id
- source id
- target id
- weighted links
- stage/lane ordering
- link routing
- flow aggregation
- node/link hit-testing
- accessibility narration for inbound/outbound flow

It is also important to keep OiSankey distinct from OiFlowGraph. AI_README already positions OiFlowGraph as an interactive node-edge editor for workflows, while OiSankey is specifically a weighted flow visualization. Those should stay separate mentally and architecturally.

# **2\. How it looks, features, and important behavior**

Visually, OiSankey should support these core forms:

- standard left-to-right sankey
- top-to-bottom later if needed
- weighted nodes and links
- multiple stages/layers
- optional node labels
- optional link labels
- optional node totals
- optional highlighted path
- optional selected node or selected link emphasis
- optional grouped small flows
- optional compact simplified mode
- optional color-by-source / color-by-target / custom color policy

The most important visual behaviors are:

### **A. Flow thickness must communicate value clearly**

The thickness of links is the core encoding. Everything else is secondary.

### **B. Direction and stage clarity must stay obvious**

A sankey fails when:

- nodes feel unordered
- links cross excessively
- direction is ambiguous
- labels compete with paths
- tiny flows create noise

### **C. Nodes and links are both first-class interaction targets**

Sometimes the user wants:

- "What is this node's total inbound/outbound?"  
   Other times they want:
- "What exactly is this link from A to B?"

So the chart must make both levels accessible.

### **D. Small-flow handling is critical**

Sankey diagrams naturally produce tiny links that quickly become unreadable. The component needs a deliberate strategy:

- hide tiny link labels
- group small flows if configured
- rely on tooltip for exact detail
- reduce path decoration in dense states

### **E. Mobile/compact modes need real simplification**

base_concept explicitly includes OiSankey among the complex visualizations that should reduce detail on mobile: fewer data labels, simpler paths, reduced animation. It also applies the shared visualization rules: fill container, use LayoutBuilder, tooltip on tap for touch and hover for pointer, legend below on compact, and "View full screen" below minimum useful size.

So sankey must degrade honestly instead of trying to preserve every path label at all sizes.

# **3\. How data input stays easy, logical, and consistent**

This is one of the most important DX decisions.

The cleanest approach is to stay mapper-first and accept separate node and link collections, because that is:

- familiar
- flexible
- easy to derive from APIs
- easy to validate
- easy to extend later

The common case should look like this:

OiSankey&lt;DepartmentNode, BudgetLink&gt;(  
label: 'Budget allocation flow',  
nodes: departments,  
links: allocations,  
nodeId: (node) => node.id,  
nodeLabel: (node) => node.name,  
sourceId: (link) => link.fromId,  
targetId: (link) => link.toId,  
value: (link) => link.amount,  
)

That is exactly the right level of readability.

For richer usage:

OiSankey&lt;DepartmentNode, BudgetLink&gt;(  
label: 'Budget allocation flow',  
nodes: departments,  
links: allocations,  
nodeId: (node) => node.id,  
nodeLabel: (node) => node.name,  
sourceId: (link) => link.fromId,  
targetId: (link) => link.toId,  
value: (link) => link.amount,  
nodeColor: (node, context) => ...,  
linkColor: (link, context) => ...,  
semanticValue: (link) => '\${link.amount} euros',  
)

## **The consistency rule**

Even though sankey is a flow chart, developers should still feel the same obers_ui language:

- raw domain models in
- mapper functions define meaning
- required label
- optional theming, legend, behaviors, accessibility
- readable prop names instead of graph-theory jargon

## **Recommended core mapper contract**

class OiSankey&lt;TNode, TLink&gt; extends StatefulWidget {  
final List&lt;TNode&gt; nodes;  
final List&lt;TLink&gt; links;  
<br/>final String Function(TNode node) nodeId;  
final String Function(TNode node) nodeLabel;  
<br/>final String Function(TLink link) sourceId;  
final String Function(TLink link) targetId;  
final num Function(TLink link) value;  
<br/>final Color? Function(TNode node, OiSankeyNodeContext context)? nodeColor;  
final Color? Function(TLink link, OiSankeyLinkContext context)? linkColor;  
final String? Function(TLink link)? semanticValue;  
}

That is strong, readable, and aligned with the rest of the package.

# **4\. Overall structure, API, props, and callbacks**

## **Public widget shape**

class OiSankey&lt;TNode, TLink&gt; extends StatefulWidget {  
final String label;  
final String? semanticLabel;  
<br/>final List&lt;TNode&gt; nodes;  
final List&lt;TLink&gt; links;  
<br/>final String Function(TNode node) nodeId;  
final String Function(TNode node) nodeLabel;  
<br/>final String Function(TLink link) sourceId;  
final String Function(TLink link) targetId;  
final num Function(TLink link) value;  
<br/>final Color? Function(TNode node, OiSankeyNodeContext context)? nodeColor;  
final Color? Function(TLink link, OiSankeyLinkContext context)? linkColor;  
final String? Function(TNode node)? nodeSemanticLabel;  
final String? Function(TLink link)? semanticValue;  
<br/>final OiSankeyLayoutMode layoutMode;  
final OiSankeyColorMode colorMode;  
final OiSankeyLabelMode labelMode;  
final OiSankeyDrillMode drillMode;  
final bool showNodeValues;  
final bool showLinkValues;  
<br/>final OiChartLegendConfig? legend;  
final List&lt;OiChartBehavior&gt; behaviors;  
final List&lt;OiChartAnnotation&gt; annotations;  
<br/>final OiChartThemeData? theme;  
final OiChartPerformanceConfig? performance;  
final OiChartAnimationConfig? animation;  
final OiChartAccessibilityConfig? accessibility;  
final OiChartSettingsDriverBinding? settings;  
final OiChartController? controller;  
final String? syncGroup;  
<br/>final OiChartLoadingStateConfig? loadingState;  
final OiChartEmptyStateConfig? emptyState;  
final OiChartErrorStateConfig? errorState;  
<br/>final ValueChanged&lt;OiSankeyNodeSelection<TNode&gt;>? onNodeTap;  
final ValueChanged&lt;OiSankeyLinkSelection<TLink&gt;>? onLinkTap;  
}

## **Important enums**

enum OiSankeyLayoutMode {  
automatic,  
preserveInputOrder,  
minimizeCrossings,  
}  
<br/>enum OiSankeyColorMode {  
bySource,  
byTarget,  
byNode,  
custom,  
}  
<br/>enum OiSankeyLabelMode {  
none,  
nodeLabel,  
nodeAndValue,  
tooltipOnly,  
}  
<br/>enum OiSankeyDrillMode {  
none,  
focusBranch,  
isolatePath,  
}

Recommended defaults:

- layoutMode: OiSankeyLayoutMode.automatic
- colorMode: OiSankeyColorMode.bySource
- labelMode: OiSankeyLabelMode.nodeLabel
- drillMode: OiSankeyDrillMode.focusBranch

## **Callback philosophy**

Keep callbacks at the chart domain level:

- onNodeTap
- onLinkTap
- onSelectionChange

Do not leak low-level path-layout events into public API.

# **5\. How it is customized through global obers_ui theming**

OiSankey should resolve through the same typed chart theme system as the rest of the chart family. AI_README already includes OiSankey in the official composite inventory, and the chart analysis explicitly notes that robust theming integration is uncommon but important.

## **Global defaults especially important for sankey**

The chart theme should provide:

- node palette defaults
- link opacity defaults
- link hover/selected emphasis
- node border styling
- label typography
- compact-mode label suppression rules
- tooltip styling
- inactive path fading behavior

## **Theme-derived defaults that matter here**

Without local overrides:

- node fills derive from chart palette
- links derive from node color policy plus transparency rules
- borders derive from subtle surface/border tokens
- labels derive from chart/text theme
- hover/focus derives from interaction tokens
- tooltip derives from overlay theme

A very important design rule:

- link colors should feel visually consistent with the rest of obers_ui, but must still prioritize path readability over strict brand color purity

# **6\. How it can be themed and configured on an element basis**

Use the same layered precedence as the rest of the chart system.

### **Layer 1 - global app theme**

Default sankey appearance everywhere.

### **Layer 2 - local chart theme override**

Per-chart override.

theme: OiChartThemeData(  
legend: ...,  
tooltip: ...,  
)

### **Layer 3 - chart-level explicit config**

For this instance:

- layout mode
- color mode
- label mode
- drill mode
- showing node/link values

### **Layer 4 - per-node / per-link override**

Nodes and links can override:

- color
- semantic text
- emphasis state
- maybe later path style if necessary

## **Sankey-specific style concerns**

The style system should support:

- node fill color
- node border color/width
- link opacity
- selected/focused link glow or outline
- label style
- inactive link fade

A key discipline:

- links should be visually legible but not overpower labels and nodes
- too much saturation or too much stroke detail makes sankeys noisy quickly

# **7\. How the logic works and how exactly it should be implemented**

## **7.1 Data normalization**

Each sankey chart should normalize as follows:

- map node ids and labels
- map link sourceId, targetId, and value
- validate graph structure
- resolve node totals
- assign nodes to stages/layers
- order nodes within each stage
- compute node rects
- compute link thicknesses and routed paths
- compute hit regions and label anchors

The normalized data should track:

### **For nodes**

- raw node
- id
- label
- inbound total
- outbound total
- stage/layer
- order within stage
- rect
- selected/focused state

### **For links**

- raw link
- sourceId
- targetId
- value
- thickness
- routed path
- source/target attachment offsets
- selected/focused state
- semantic text

## **7.2 Graph validation**

This is one of the most important sankey-specific logic problems.  
The chart must handle:

- missing source/target nodes
- duplicate node ids
- zero or negative link values
- cycles if the chosen sankey implementation does not support them
- disconnected subgraphs

Recommended behavior:

- fail clearly in debug/dev with actionable diagnostics
- handle gracefully in production where possible
- document exactly whether cycles are supported or rejected

For v1, I would recommend:

- assume directed acyclic or stage-order-compatible flow
- reject cycles clearly unless you explicitly design for cyclic sankey support later

## **7.3 Stage/layer assignment**

A sankey needs a clear notion of progression.  
Nodes should be assigned to stages based on:

- explicit developer-provided ordering later if needed
- inferred layer from link topology by default

Recommended default:

- infer stage from topology
- preserve developer input order within stage unless crossing minimization needs to reorder and the chosen layout mode allows it

## **7.4 Node sizing**

Node height should correspond to the total visible flow passing through the node.  
Important rule:

- use the larger of inbound/outbound as needed to preserve visual consistency
- make hidden links affect visible totals predictably
- keep minimum visual node size for interaction/labeling if the chart remains above minimum useful size

## **7.5 Link routing**

This is the most important sankey-specific layout problem.

Links should:

- attach to nodes at weighted offsets
- maintain visible continuity
- minimize unnecessary crossings where possible
- remain easy to hover/tap

Recommended path style:

- smooth cubic or bezier-style flow paths
- simplified path curvature in compact/performance mode

base_concept explicitly notes that complex visualizations like OiSankey should reduce path complexity on mobile.

## **7.6 Small-flow handling**

Very small links should not break readability.  
Recommended rules:

- tiny links still contribute to totals
- tiny link labels are suppressed early
- tooltip remains the exact-detail access path
- optional "group minor flows" can come later

## **7.7 Drill behavior**

Sankey drill/focus should remain disciplined.

### **none**

Static sankey, inspect by hover/tap only.

### **focusBranch**

Highlight a node and its inbound/outbound neighborhood while dimming unrelated paths.

### **isolatePath**

Select a node/link and temporarily isolate connected path segments.

Recommended default:

- focusBranch

That gives good analytical utility without completely re-rooting the diagram.

# **8\. How performance is guaranteed even with huge datasets**

Sankey performance is not about hundreds of thousands of points. It is about:

- many nodes
- many links
- complex routing
- label measurement
- relayout cost
- interaction over many paths

base_concept explicitly identifies OiSankey as one of the complex visualizations that should reduce detail on mobile.

## **8.1 Layout is more expensive than paint**

The expensive parts are:

- graph validation
- stage assignment
- crossing minimization
- path routing
- label layout

The actual drawing of paths and node rects is comparatively cheap.

## **8.2 Path simplification in compact/performance mode**

In dense or mobile contexts:

- simplify curve control points
- reduce path detail
- suppress link labels
- reduce animation
- favor node labels over link labels

This directly matches base_concept's "simpler paths, fewer data labels, reduced animation" rule for complex visualizations like sankey.

## **8.3 Cached graph and layout phases**

Cache:

- node/link normalization
- stage/layer assignment
- node positions
- routed link paths
- label fit decisions
- visible focus branch state

Invalidate only when:

- data changes
- visibility changes
- size changes
- theme changes
- layout mode changes
- drill/focus state changes

## **8.4 Hit-testing optimization**

Use:

- node rect hit-testing
- link path bounds + narrowed precise checks
- visible-item-only hit maps
- avoid building semantics nodes for every tiny decorative path when not useful

## **8.5 Compact fallback**

The shared visualization rules still apply:

- touch tooltips on tap
- legend below on compact
- minimum viable size fallback when too cramped

Even though base_concept does not specify a numeric minimum for sankey, it should still participate honestly in the fallback policy when node/link readability collapses.

# **9\. How interactivity works and can be configured**

Sankey should follow the same high-level interaction rules as the rest of obers_ui visualizations:

- hover tooltip on pointer
- tap tooltip on touch
- compact legend below
- minimum viable size fallback

## **Default interaction behavior**

### **Pointer**

- hover highlights node or link
- hover shows tooltip
- click selects/focuses node or link

### **Touch**

- tap highlights node or link
- tap shows tooltip
- tap elsewhere dismisses
- hit regions must be forgiving for thin links

That last point is very important. Thin links still need usable touch selection, which is consistent with obers_ui's broader touch-target philosophy elsewhere in the package.

## **Behavior-based configuration**

behaviors: \[  
OiTooltipBehavior(),  
OiSelectionBehavior(  
selectionMode: OiChartSelectionMode.point,  
),  
\]

Sankey can also benefit from:

- focus behavior
- drill behavior
- keyboard navigation behavior

That still follows the same composable interaction philosophy recommended by the chart analysis.

## **Sankey-specific interaction detail**

The chart should support:

- node selection
- link selection
- branch/path focus
- pinned tooltip
- keyboard traversal of visible nodes and links

Recommended default:

- first-class node and link interaction
- node focus dims unrelated paths
- link focus highlights exact source→target flow

# **10\. How legend and additional information are implemented**

## **Legend**

Sankey legends are useful when color represents:

- source category
- target category
- branch type
- status

If links inherit source-node colors, the legend should show:

- node color
- node/category label
- optional total

If color mode is custom or by target, the legend should still reflect the user-visible color semantics honestly.

## **Tooltip**

Tooltip should support:

### **For nodes**

- node label
- total inbound
- total outbound
- optional share of whole
- optional path context if focused

### **For links**

- source label
- target label
- formatted value
- optional percentage of source / target / whole

Tooltip clarity matters a lot because many paths will not be labelable inline.

## **Additional information layers**

Sankey should support, conservatively:

- focus path highlighting
- selected node neighborhood emphasis
- threshold/status emphasis via color if configured
- maybe light annotations later

But keep v1 disciplined. Sankey becomes visually overwhelming very quickly.

# **11\. How accessibility is guaranteed**

This is a major opportunity because flow charts are often poorly supported in current chart libraries. Your chart analysis explicitly highlights accessibility as an area where the ecosystem is weak and recommends auto-generated descriptions and keyboard exploration.

## **11.1 Required semantics**

At minimum:

- label required
- semanticLabel optional override
- node label/value available semantically
- link source, target, and value available semantically
- focus/drill state explained
- legend items keyboard reachable and labeled if shown

## **11.2 Auto-generated summary**

If not overridden, generate a summary including:

- chart type
- node count
- link count
- total visible flow
- dominant node or dominant path
- whether chart is currently focused on a branch/path

Example:  
"Sankey diagram showing budget allocation across 12 nodes and 18 weighted flows. Operations is the largest source. Most flow goes from Operations to Infrastructure."

That is exactly the kind of generated accessibility support your chart analysis points toward.

## **11.3 Keyboard exploration**

A focused sankey should support:

- arrow keys move between visible nodes in stage order
- secondary navigation moves into connected links
- enter selects/focuses
- escape clears or exits focus state
- narration includes node or link meaning, not just an index

This could become one of the clearest examples of strong chart keyboard exploration in obers_ui.

## **11.4 Non-color-only differentiation**

Because sankey often uses color-coded links and nodes:

- focus/selection should also use outline, glow, thickness, or opacity changes
- high-contrast mode should preserve path readability through stroke contrast and node borders
- link identity must not depend on color alone

## **11.5 Reduced motion**

If reduced motion is active:

- reduce or disable path-flow entrance animations
- keep focus transitions subtle
- avoid flashy link tracing effects

## **11.6 Accessible textual fallback**

A linked tabular/list representation of nodes and flows is especially valuable here and fits naturally with obers_ui's broader data-display ecosystem.

# **12\. Every extensive test needed for OiSankey**

## **A. Rendering and layout tests**

- renders basic sankey correctly
- renders multiple stages correctly
- respects container constraints
- fills available container
- node labels render correctly when space allows
- link paths render correctly
- legend moves below on compact
- compact/performance mode simplifies paths and labels

## **B. Data mapping and graph validation tests**

- mapper-based node/link extraction works correctly
- duplicate node id handling follows spec
- missing source/target handling follows spec
- zero or negative link value handling follows spec
- disconnected subgraphs handling follows spec
- cycle detection behaves according to documented policy

## **C. Layout algorithm tests**

- automatic stage assignment is stable and valid
- preserveInputOrder mode keeps stage ordering correctly
- minimizeCrossings mode reduces crossings compared with naive layout
- node sizes reflect visible flow totals correctly
- link thickness matches values within tolerance

## **D. Interaction tests**

- hover tooltip appears on pointer
- tap tooltip appears on touch
- node tap callback fires correctly
- link tap callback fires correctly
- focusBranch drill mode behaves correctly
- isolatePath drill mode behaves correctly
- tooltip dismisses correctly
- selection updates controller correctly

## **E. Accessibility tests**

- chart exposes semantic label
- auto-generated summary includes node/link counts
- focused node narration includes inbound/outbound totals
- focused link narration includes source, target, and value
- keyboard traversal moves through visible nodes/links correctly
- enter focuses/selects correctly
- escape clears focus correctly
- reduced motion disables nonessential animations
- high-contrast mode preserves perceivable path and node focus

## **F. Theming tests**

- node colors derive from theme palette by default
- link color mode behaves correctly
- local chart theme override applies correctly
- explicit node/link color override beats theme defaults
- tooltip and legend visuals resolve from theme
- light and dark goldens are stable

## **G. Responsive tests**

- compact legend moves below
- compact suppresses link labels
- mobile/performance mode simplifies paths and detail
- pointer uses hover tooltip, touch uses tap tooltip
- cramped layouts degrade honestly or show fallback presentation

## **H. Performance tests**

- many-link sankey layouts within acceptable budget
- cached layout invalidates only when necessary
- repeated focus/drill changes do not leak memory
- hit-testing remains performant with many visible links
- mobile simplification reduces cost predictably

## **I. Golden tests**

- default sankey
- sankey with focused node
- sankey with selected link
- compact sankey with legend below
- dark theme sankey
- high-contrast sankey
- mobile-simplified sankey with fewer link labels

# **13\. Final recommendation for OiSankey**

OiSankey should be the canonical obers_ui chart for **weighted directional flow between nodes**:

- it should preserve the real inventory identity already defined in AI_README: chart, sankey, flow, allocation, distribution and "flow diagram showing weighted flows between nodes"
- it should follow the shared visualization rules in base_concept, especially tap-on-touch tooltips, legend-below on compact, and the explicit simplification guidance for complex visualizations like OiSankey on mobile: fewer data labels, simpler paths, reduced animation
- it should use mapper-first node/link binding with nodeId, nodeLabel, sourceId, targetId, and value, keeping DX aligned with the rest of the library
- it should treat path routing, small-flow handling, node-vs-link interaction, and accessibility narration as first-class concerns
- it should stay theme-native and clearly distinct from workflow-editing widgets like OiFlowGraph

If done well, OiSankey becomes the **flow-allocation chart** in obers_ui: expressive, compact, and still readable because it knows how to reduce detail when the diagram gets dense.

When you say **continue**, I'll move to the next deep dive: **OiFunnelChart&lt;T&gt;**.

continue 17

I'm on OiFunnelChart now. This one looks simpler than sankey, but it needs very clear semantics around stage ordering, drop-off meaning, compact readability, and honesty about what it can and cannot communicate well.

Thought for 7s

## **Part 17 - OiFunnelChart&lt;T&gt;**

OiFunnelChart looks simpler than sankey, but it needs a lot of discipline to be good.

A funnel chart is only useful when it is very clear about:

- stage order
- stage values
- drop-off between stages
- what the width means
- whether conversion is absolute or relative
- how much detail is safe to show in compact space

In your real implementation inventory, OiFunnelChart already exists as a composite visualization with the identity **chart / funnel / conversion / stages / pipeline**, so that public role should stay intact.

It also has to follow the same obers_ui-wide rules as the rest of the chart family:

- readable, declarative props
- mapper-first binding
- theme-native styling
- accessibility-first behavior
- responsive simplification
- the same tooltip and legend conventions already defined for visualization widgets in base_concept

And that direction is supported by the chart analysis as well: funnel is part of the serious chart inventory, declarative APIs are preferred, composable behaviors are the right interaction model, and accessibility plus responsive adaptation are still weak across many chart ecosystems.

# **1\. What OiFunnelChart is**

OiFunnelChart&lt;T&gt; is the standard chart for showing **ordered stage progression and drop-off** across a pipeline.

It should be the default chart in obers_ui for:

- conversion stages
- recruitment pipelines
- sales pipelines
- checkout step completion
- onboarding progression
- lead qualification drop-off
- support process stages
- any "how many remain after each stage" view

Architecturally, it should be treated as a **specialized flow/comparison composite**, not as a fake sankey and not as a pie variant:

OiFunnelChart&lt;T&gt; extends OiChartWidget

Internally it should still reuse shared chart foundation pieces:

- chart theme
- tooltip behavior
- legend rules
- selection behavior
- accessibility summary generation
- responsive fallback logic
- controller/settings hooks where useful

But it does **not** need the full node-link routing complexity of sankey. Its job is much more focused:

- a single ordered sequence
- one value per stage
- optional conversion math between stages

That narrower scope is a strength if the API stays honest.

# **2\. How it looks, features, and important behavior**

Visually, OiFunnelChart should support these core forms:

- classic vertical funnel
- optional horizontal funnel later
- center-aligned trapezoid segments
- equal-height stages by default
- optional proportional-height mode later
- stage labels
- value labels
- conversion / drop-off labels
- selected stage emphasis
- optional compact "step list" fallback
- optional legend if color meaning matters
- optional compare-to-previous or compare-to-first percentages

The most important visual behaviors are:

### **A. Order is everything**

A funnel only makes sense when stage order is explicit and stable.

### **B. Width semantics must be clear**

Developers and users must know whether segment width reflects:

- absolute value
- relative value to first stage
- relative value to previous stage

Recommended default:

- width reflects value relative to the **first stage  
   **That is the most familiar and easiest to read.

### **C. Drop-off must be easy to understand**

The chart should make it easy to show:

- stage value
- percent of first stage
- percent of previous stage
- drop-off amount

### **D. Compact readability matters**

Funnels are often used in dashboards and side panels. Like the rest of the visualization family, they should fill the container, move legends below on compact, use tap tooltips on touch, and fall back to a full-screen action below the minimum useful size.

### **E. It should stay honest about what it is good at**

A funnel is great for ordered stage drop-off.  
It is not the right chart for:

- branching flows
- loops
- multidirectional transitions
- complex route attribution

That is what keeps it distinct from sankey.

# **3\. How data input stays easy, logical, and consistent**

This should be one of the clearest mapper-first APIs in the chart library.

The common case should look like this:

OiFunnelChart&lt;PipelineStage&gt;(  
label: 'Checkout conversion',  
data: stages,  
stageLabel: (item) => item.name,  
value: (item) => item.count,  
)

That is the ideal developer experience.

For richer usage:

OiFunnelChart&lt;PipelineStage&gt;(  
label: 'Checkout conversion',  
data: stages,  
stageLabel: (item) => item.name,  
value: (item) => item.count,  
semanticValue: (item) => '\${item.count} users',  
stageColor: (item, context) => ...,  
)

## **The consistency rule**

Even though funnel is not Cartesian, polar, matrix, or hierarchical, it should still feel like the same package:

- data
- mapper functions
- readable prop names
- optional behaviors
- optional theming/accessibility overrides
- no weird chart-library jargon

## **Recommended mapper contract**

class OiFunnelChart&lt;T&gt; extends StatefulWidget {  
final List&lt;T&gt; data;  
final String Function(T item) stageLabel;  
final num Function(T item) value;  
final Color? Function(T item, OiSeriesPointContext context)? stageColor;  
final String? Function(T item)? semanticValue;  
}

That is simple, readable, and very consistent with the rest of obers_ui.

# **4\. Overall structure, API, props, and callbacks**

## **Public widget shape**

class OiFunnelChart&lt;T&gt; extends StatefulWidget {  
final String label;  
final String? semanticLabel;  
<br/>final List&lt;T&gt; data;  
final String Function(T item) stageLabel;  
final num Function(T item) value;  
<br/>final Color? Function(T item, OiSeriesPointContext context)? stageColor;  
final String? Function(T item)? semanticValue;  
<br/>final OiFunnelWidthMode widthMode;  
final OiFunnelLabelMode labelMode;  
final OiFunnelMetricMode metricMode;  
final OiFunnelOrientation orientation;  
<br/>final bool showDropOff;  
final bool showConversionRate;  
final bool showStageValues;  
<br/>final OiChartLegendConfig? legend;  
final List&lt;OiChartBehavior&gt; behaviors;  
<br/>final OiChartThemeData? theme;  
final OiChartPerformanceConfig? performance;  
final OiChartAnimationConfig? animation;  
final OiChartAccessibilityConfig? accessibility;  
final OiChartSettingsDriverBinding? settings;  
final OiChartController? controller;  
<br/>final OiChartLoadingStateConfig? loadingState;  
final OiChartEmptyStateConfig? emptyState;  
final OiChartErrorStateConfig? errorState;  
<br/>final ValueChanged&lt;OiFunnelStageSelection<T&gt;>? onStageTap;  
}

## **Important enums**

enum OiFunnelWidthMode {  
relativeToFirst,  
relativeToPrevious,  
absoluteNormalized,  
}  
<br/>enum OiFunnelLabelMode {  
none,  
stageOnly,  
stageAndValue,  
stageAndPercentage,  
full,  
}  
<br/>enum OiFunnelMetricMode {  
absolute,  
percentageOfFirst,  
percentageOfPrevious,  
both,  
}  
<br/>enum OiFunnelOrientation {  
vertical,  
horizontal,  
}

Recommended defaults:

- widthMode: OiFunnelWidthMode.relativeToFirst
- labelMode: OiFunnelLabelMode.stageAndValue
- metricMode: OiFunnelMetricMode.both
- orientation: OiFunnelOrientation.vertical

## **Callback philosophy**

Keep callbacks simple:

- onStageTap
- onStageLongPress
- onSelectionChange

No internal geometry callbacks should leak.

# **5\. How it is customized through global obers_ui theming**

OiFunnelChart should resolve through the same typed chart theme extension as the rest of the family. AI_README already places it in the official visualization inventory, and the wider chart analysis explicitly notes that host-theme integration is often weak in chart libraries. obers_ui should be better here.

## **Global defaults especially important for funnel**

The chart theme should provide:

- funnel stage palette defaults
- stage border styling
- drop-off text styling
- value/percentage label styles
- selected/focused stage styling
- compact-mode label suppression rules
- tooltip styling

## **Theme-derived defaults that matter here**

Without local overrides:

- stage fills derive from the chart palette
- borders derive from subtle border tokens
- labels derive from chart/text theme
- selected/focused emphasis derives from interaction tokens
- tooltip derives from overlay theme

A key design rule:

- funnel stages should feel visually modern and restrained, not like glossy sales-dashboard clipart

# **6\. How it can be themed and configured on an element basis**

Use the same layered precedence as the rest of the chart library.

### **Layer 1 - global app theme**

Default funnel appearance everywhere.

### **Layer 2 - local chart theme override**

Per-chart override.

theme: OiChartThemeData(  
tooltip: ...,  
)

### **Layer 3 - chart-level explicit config**

For this instance:

- width mode
- metric mode
- label mode
- orientation
- showing drop-off/conversion

### **Layer 4 - per-stage override**

Each stage can override:

- fill color
- semantic text
- emphasis state

## **Funnel-specific style concerns**

The style system should support:

- stage fill color
- stage border color/width
- selected/focused outline
- label style
- inactive stage fade

Important discipline:

- stage shapes should remain clean and readable
- spacing and text clarity matter more than ornament

# **7\. How the logic works and how exactly it should be implemented**

## **7.1 Data normalization**

Each stage should normalize as follows:

- map stage label
- map value
- validate ordering and values
- compute totals and percentages
- compute segment widths
- compute segment geometry
- compute label anchors and hit regions

The normalized stage should track:

- raw item
- label
- raw value
- percent of first
- percent of previous
- drop-off from previous
- stage polygon/rect
- selected/focused state
- semantic text

## **7.2 Value validation**

A funnel should be strict:

- negative values are invalid
- zero values are allowed but must be rendered and narrated carefully
- null values should be excluded predictably

Recommended default:

- values should generally be non-increasing for a classic funnel
- if they are not, the chart can still render, but it should not silently pretend that is normal
- in debug/dev, warn when stage values increase unexpectedly unless explicitly allowed

## **7.3 Width computation**

This is the most important funnel-specific logic problem.

### **relativeToFirst**

Each stage width is based on value / first-stage value.  
Best default.

### **relativeToPrevious**

Each stage width is based on value / previous-stage value.  
Useful in some conversion narratives, but visually less standard.

### **absoluteNormalized**

All stages use absolute normalized width against global max.  
Useful for some compare-like uses, but less canonical.

Recommended default:

- relativeToFirst

## **7.4 Geometry generation**

For vertical mode:

- stages stack top to bottom
- each stage is center-aligned
- widths taper according to the chosen mode
- heights are equal by default for readability

For horizontal mode:

- same logic rotated conceptually, not hacked through canvas rotation

Equal-height stages should be the default because they make labels and stage comparison cleaner.

## **7.5 Drop-off calculation**

For each stage after the first:

- dropOff = previous - current
- conversion = current / previous
- retainedFromStart = current / first

Those values should be available consistently for:

- labels
- tooltip
- accessibility narration
- custom builders later

## **7.6 Small-stage handling**

Tiny or zero stages need careful treatment.  
Recommended rules:

- still reserve a minimal visible interaction region if possible
- suppress inline labels when too cramped
- rely on tooltip for exact detail
- optionally fall back to a step-list presentation in very tight layouts

## **7.7 Optional compare mode later**

Future versions can support side-by-side funnel comparison, but v1 should stay disciplined and focus on one ordered funnel at a time.

# **8\. How performance is guaranteed even with huge datasets**

Funnels are not a large-data performance problem. They are a **many-small-dashboards** and **layout clarity** problem.

The expensive parts are mostly:

- label layout
- animation over many dashboard instances
- tooltip and semantics churn

## **8.1 Geometry is cheap**

The trapezoids/segments are easy to paint.

## **8.2 Compact simplification matters most**

Like the rest of the visualization family in base_concept, funnel should:

- use LayoutBuilder
- move legend below on compact
- use tap tooltips on touch
- render a full-screen fallback below minimum useful size

For funnel specifically:

- suppress drop-off labels first
- keep stage label + key metric next
- simplify to tooltip-only detail when space is tight

## **8.3 Cache normalized metrics and label layout**

Cache:

- computed percentages
- stage geometry
- label anchors
- value formatting
- tooltip models

Invalidate only when:

- data changes
- theme changes
- size changes
- width/metric mode changes

## **8.4 Dense dashboard use**

When many funnels appear in a dashboard:

- reduce animation
- suppress nonessential secondary labels
- keep the primary value dominant

# **9\. How interactivity works and can be configured**

Funnels should follow the same base visualization rules:

- hover tooltip on pointer
- tap tooltip on touch
- legends below on compact
- minimum viable size fallback below cramped sizes

## **Default interaction behavior**

### **Pointer**

- hover highlights stage
- hover shows tooltip
- click selects stage if enabled

### **Touch**

- tap highlights stage
- tap shows tooltip
- tap elsewhere dismisses

Since funnel stages are relatively large, they are naturally touch-friendly as long as the chart stays within an honest minimum size.

## **Behavior-based configuration**

behaviors: \[  
OiTooltipBehavior(),  
OiSelectionBehavior(  
selectionMode: OiChartSelectionMode.point,  
),  
\]

This keeps funnel aligned with the same behavior-object architecture recommended by the chart analysis.

## **Funnel-specific interaction detail**

The chart should support:

- stage selection
- pinned tooltip
- keyboard traversal by stage order

Recommended default:

- stage-level interaction only
- no unnecessary complexity beyond that

# **10\. How legend and additional information are implemented**

## **Legend**

Funnels often do not need a legend unless:

- stages are color-coded with semantic meaning
- compare mode later introduces more than one group

If used, the legend should show:

- stage color
- stage label
- optional value

On compact, it moves below the chart like other visualization widgets.

## **Tooltip**

Tooltip should support:

- stage label
- raw value
- percent of first
- percent of previous
- drop-off from previous

Tooltip clarity is especially important because compact layouts may suppress some inline text.

## **Additional information layers**

Funnels can use:

- target conversion markers later
- annotations for notable stage changes
- highlighted stages

But v1 should stay focused on the basic conversion story.

# **11\. How accessibility is guaranteed**

This is an area where obers_ui can be better than many chart libraries. The chart analysis explicitly points to auto-generated descriptions and keyboard exploration as major opportunities.

## **11.1 Required semantics**

At minimum:

- label required
- semanticLabel optional override
- each stage label/value available semantically
- drop-off and conversion available semantically
- legend items keyboard reachable if shown

## **11.2 Auto-generated summary**

If not overridden, generate a summary including:

- chart type
- stage count
- first and last stage values
- overall retention/conversion
- largest drop-off

Example:  
"Funnel chart showing checkout conversion across five stages. 12,000 users entered the first stage. 1,840 completed the final stage. The largest drop-off occurs between shipping and payment."

That is exactly the kind of generated narration your chart analysis recommends.

## **11.3 Keyboard exploration**

A focused funnel should support:

- up/down or left/right by stage order depending on orientation
- enter selects
- escape clears selection
- narration includes stage label, value, percent retained, and drop-off

## **11.4 Non-color-only differentiation**

Since stage emphasis may use color:

- selection/focus should also use outline, elevation, or offset
- high-contrast mode should preserve stage boundaries clearly
- the conversion story must not depend on color alone

## **11.5 Reduced motion**

If reduced motion is active:

- reduce stage transition animation
- avoid dramatic shrinking/growing morphs
- keep focus changes subtle

## **11.6 Accessible textual fallback**

A linked step list or metric list representation is especially valuable here and fits naturally with obers_ui's strong data-display ecosystem.

# **12\. Every extensive test needed for OiFunnelChart**

## **A. Rendering and layout tests**

- renders basic vertical funnel correctly
- renders horizontal funnel correctly
- respects container constraints
- fills available container
- stage labels render correctly when space allows
- legend moves below on compact
- compact layout suppresses secondary labels appropriately

## **B. Data mapping and validation tests**

- mapper-based stage label/value extraction works correctly
- negative value handling follows spec
- zero value handling follows spec
- non-monotonic stage values produce documented behavior
- percentages and drop-off metrics compute correctly

## **C. Width and metric tests**

- relativeToFirst computes widths correctly
- relativeToPrevious computes widths correctly
- absoluteNormalized computes widths correctly
- percent-of-first and percent-of-previous are correct
- drop-off values are correct

## **D. Interaction tests**

- hover tooltip appears on pointer
- tap tooltip appears on touch
- stage tap callback fires correctly
- tooltip dismisses correctly
- selection updates controller correctly

## **E. Accessibility tests**

- chart exposes semantic label
- auto-generated summary includes overall conversion
- focused stage narration includes value and conversion metrics
- keyboard traversal moves through stages correctly
- reduced motion disables nonessential animation
- high-contrast mode preserves perceivable stage focus

## **F. Theming tests**

- stage colors derive from theme palette by default
- local chart theme override applies correctly
- per-stage color override beats theme default
- tooltip and legend visuals resolve from theme
- light and dark goldens are stable

## **G. Responsive tests**

- compact legend moves below
- compact suppresses excess text
- pointer uses hover tooltip, touch uses tap tooltip
- cramped layouts degrade honestly or show fallback presentation

## **H. Performance tests**

- repeated value updates do not leak memory
- cached metric/layout invalidates only when necessary
- many small funnels in a dashboard remain efficient
- compact/performance mode reduces complexity predictably

## **I. Golden tests**

- default vertical funnel
- horizontal funnel
- funnel with selected stage
- compact funnel with legend below
- dark theme funnel
- high-contrast funnel

# **13\. Final recommendation for OiFunnelChart**

OiFunnelChart should be the canonical obers_ui chart for **ordered stage conversion and drop-off**:

- it should preserve the real inventory identity already defined in AI_README: chart, funnel, conversion, stages, pipeline
- it should follow the shared visualization rules from base_concept, especially touch-on-tap tooltips, legend-below on compact, and minimum-size fallback when a cramped funnel would become dishonest
- it should use mapper-first input with stageLabel and value, keeping DX aligned with the rest of the library
- it should treat width semantics, drop-off math, and accessibility narration as first-class concerns
- it should stay clearly distinct from sankey by remaining focused on one ordered pipeline rather than weighted branching flow

If done well, OiFunnelChart becomes the **conversion-stage chart** in obers_ui: clear, compact, honest, and very easy to use.

When you say **continue**, I'll move to the next deep dive: **OiCandlestickChart&lt;T&gt;**.

continue 18

I'm on OiCandlestickChart now. This is the first financial/interval chart, so the core challenge becomes OHLC semantics, dense time-series readability, and strict data honesty around ranges and wicks rather than just simple points or bars.

Thought for 8s

## **Part 18 - OiCandlestickChart&lt;T&gt;**

OiCandlestickChart is the first chart where the system has to model a **single time bucket as a structured interval**, not just as one y-value.

That changes both the API and the rendering model. A candlestick chart is not "a bar chart with fancy styling." It carries five distinct semantics:

- open
- high
- low
- close
- time/order

And in your chart analysis, candlestick is explicitly part of the serious target chart inventory, with stronger chart systems already supporting dedicated candle/OHLC series rather than forcing developers to fake them with bars and lines. The same analysis also stresses the architectural points that matter most here: mapper-first binding, first-class mixed-series support, composable behaviors, built-in performance thinking, and stronger accessibility than the existing ecosystem usually provides.

So OiCandlestickChart should become the canonical obers_ui chart for **financial/interval OHLC visualization**:

- honest
- compact
- time-series-friendly
- mixable with other Cartesian series
- highly readable in dense datasets
- consistent with the same package language as everything else

# **1\. What OiCandlestickChart&lt;T&gt; is**

OiCandlestickChart&lt;T&gt; is the standard Cartesian chart for showing **open-high-low-close intervals** over an ordered domain, usually time.

It should be the default chart in obers_ui for:

- price action charts
- OHLC interval visualization
- trading or market dashboards
- time-bucketed interval comparison
- any domain where one bucket has an upper/lower range plus opening/closing state

Architecturally:

OiCandlestickChart&lt;T&gt; extends OiCartesianChart&lt;T&gt;

That is important because candlesticks should not live in a separate financial sub-library. They should share the same core Cartesian infrastructure as line, area, bar, scatter, and combo charts:

- axes
- viewport
- zoom/pan
- tooltip
- selection
- sync
- legend
- annotations
- thresholds
- theme
- accessibility
- performance configuration

This is especially important because the chart analysis explicitly identifies mixed chart support as a major strategic differentiator. Candles should be able to coexist with:

- moving-average lines
- volume bars
- threshold bands
- markers
- later technical indicators  
   inside one shared coordinate system.

# **2\. How it looks, features, and important behavior**

Visually, OiCandlestickChart should support these core forms:

- standard candlestick chart
- bullish/bearish candle styling
- neutral/doji styling
- wicks/high-low lines
- configurable body width
- optional volume overlay later via OiComboChart
- optional markers / annotations
- optional threshold lines
- optional gap handling for missing intervals
- optional dense-mode candle simplification

The most important visual behaviors are:

### **A. OHLC semantics must stay unmistakable**

Each candle must clearly communicate:

- wick = high/low range
- body = open/close interval
- body fill/outline = direction or state

### **B. Time ordering and interval spacing must stay honest**

A financial interval chart becomes misleading if missing buckets are silently collapsed in a confusing way. The axis and spacing rules need to be very explicit.

### **C. Dense readability matters a lot**

Candlestick charts are often used with very large datasets and tight widths. This means:

- candle body widths must adapt
- labels must suppress aggressively
- hover/selection must remain precise
- simplified rendering must kick in before the chart becomes noise

### **D. Visual semantics must not depend only on green/red**

Because accessibility and high-contrast compatibility matter, bullish/bearish/doji state should be readable through more than hue alone:

- fill vs hollow
- outline style
- selected/focused halo
- tooltip narration

# **3\. How data input stays easy, logical, and consistent**

This should stay mapper-first, just like the rest of the chart family.

The chart analysis explicitly recommends Syncfusion-style mapper binding as the strongest Flutter-idiomatic approach and treats candlestick as a dedicated series type in serious libraries. So the common case should look like:

OiCandlestickChart&lt;PriceBar&gt;(  
label: 'Daily price movement',  
data: candles,  
x: (item) => item.date,  
open: (item) => item.open,  
high: (item) => item.high,  
low: (item) => item.low,  
close: (item) => item.close,  
)

That is the correct DX: domain-model-friendly, explicit, and extremely readable.

For richer usage:

OiCandlestickChart&lt;PriceBar&gt;(  
label: 'Daily price movement',  
data: candles,  
x: (item) => item.date,  
open: (item) => item.open,  
high: (item) => item.high,  
low: (item) => item.low,  
close: (item) => item.close,  
semanticValue: (item) =>  
'Open \${item.open}, high \${item.high}, low \${item.low}, close \${item.close}',  
)

For multi-series or combined views, the same candle series should also be usable inside OiComboChart:

OiComboChart&lt;PriceBar&gt;(  
label: 'Price with moving average',  
series: \[  
OiCandlestickSeries&lt;PriceBar&gt;(...),  
OiLineSeries&lt;PriceBar&gt;(...),  
\],  
)

That is exactly the kind of shared-series consistency the chart analysis argues for.

## **The consistency rule**

A developer should still feel the same familiar mental model:

- data
- mapper functions
- optional series
- optional theme/behaviors/accessibility
- readable props

The only difference is that a candle uses four value mappers instead of one.

## **Recommended series contract**

class OiCandlestickSeries&lt;T&gt; extends OiCartesianSeries&lt;T&gt; {  
final Object? Function(T item) x;  
final num Function(T item) open;  
final num Function(T item) high;  
final num Function(T item) low;  
final num Function(T item) close;  
<br/>final String? Function(T item)? pointLabel;  
final String? Function(T item)? semanticValue;  
final OiSeriesStyle? style;  
}

That keeps it fully aligned with the rest of the package.

# **4\. Overall structure, API, props, and callbacks**

## **Public widget shape**

class OiCandlestickChart&lt;T&gt; extends StatefulWidget {  
final String label;  
final String? semanticLabel;  
<br/>final List&lt;T&gt;? data;  
final Object? Function(T item)? x;  
final num Function(T item)? open;  
final num Function(T item)? high;  
final num Function(T item)? low;  
final num Function(T item)? close;  
<br/>final List&lt;OiCandlestickSeries<T&gt;>? series;  
<br/>final OiChartAxis? xAxis;  
final List&lt;OiChartAxis&gt;? yAxes;  
<br/>final OiCandlestickSpacingMode spacingMode;  
final OiCandlestickLabelMode labelMode;  
final bool showWicks;  
final bool showBodies;  
<br/>final OiChartLegendConfig? legend;  
final List&lt;OiChartBehavior&gt; behaviors;  
final List&lt;OiChartAnnotation&gt; annotations;  
final List&lt;OiChartThreshold&gt; thresholds;  
<br/>final OiChartThemeData? theme;  
final OiChartPerformanceConfig? performance;  
final OiChartAnimationConfig? animation;  
final OiChartAccessibilityConfig? accessibility;  
final OiChartSettingsDriverBinding? settings;  
final OiChartController? controller;  
final String? syncGroup;  
<br/>final OiChartLoadingStateConfig? loadingState;  
final OiChartEmptyStateConfig? emptyState;  
final OiChartErrorStateConfig? errorState;  
<br/>final ValueChanged&lt;OiCandlestickSelection<T&gt;>? onCandleTap;  
final ValueChanged&lt;OiChartViewportState&gt;? onViewportChange;  
}

## **Important enums**

enum OiCandlestickSpacingMode {  
preserveDomain,  
compressedMissingIntervals,  
}  
<br/>enum OiCandlestickLabelMode {  
none,  
ohlcTooltipOnly,  
closeOnly,  
}

Recommended defaults:

- spacingMode: OiCandlestickSpacingMode.preserveDomain
- labelMode: OiCandlestickLabelMode.ohlcTooltipOnly
- showWicks: true
- showBodies: true

That keeps the default chart honest and uncluttered.

## **Callback philosophy**

Keep callbacks simple and domain-level:

- onCandleTap
- onCandleLongPress
- onSelectionChange
- onViewportChange

No low-level wick/body geometry callbacks should leak into public API.

# **5\. How it is customized through global obers_ui theming**

OiCandlestickChart should resolve through the same typed chart theme system as the rest of the family, because AI_README and the overall chart architecture require that colors and visual defaults come from theme rather than hardcoded widget-local styling. The chart analysis also explicitly notes that host-theme integration is weak across many chart libraries and should be stronger in a serious spec.

## **Global defaults especially important for candlestick**

The chart theme should provide:

- bullish candle style
- bearish candle style
- doji/neutral style
- wick styling
- selection/focus styling
- axis/grid/tooltip styling
- dense-mode body-width defaults
- compact-mode simplification rules

## **Theme-derived defaults that matter here**

Without local overrides:

- candle colors derive from the chart palette and semantic tokens
- wick color derives from candle style or contrast-aware border tokens
- tooltip derives from overlay theme
- selection/focus derives from interaction tokens
- axis/grid derives from chart theme axis/grid tokens

A key design rule:

- do not force green/red as the only semantic system
- support theme-native bullish/bearish colors, but allow high-contrast-safe differentiation through outline/fill strategy too

# **6\. How it can be themed and configured on an element basis**

Use the same layered precedence as the rest of the chart package.

### **Layer 1 - global app theme**

Default candle appearance everywhere.

### **Layer 2 - local chart theme override**

Per-chart override.

theme: OiChartThemeData(  
tooltip: ...,  
axis: ...,  
)

### **Layer 3 - series style**

Per-series candle style.

OiCandlestickSeries(  
id: 'daily',  
label: 'Daily',  
style: OiSeriesStyle(  
strokeWidth: 1,  
),  
)

### **Layer 4 - per-candle override**

If genuinely needed, a candle can override:

- fill
- outline
- semantic text
- emphasis state

## **Candlestick-specific style concerns**

The style system should support:

- bullish fill/stroke
- bearish fill/stroke
- doji fill/stroke
- wick color/width
- selected/focused halo
- inactive series fade

A strong default rule:

- doji should be visually distinct
- selected/focused candles should remain legible regardless of candle direction color

# **7\. How the logic works and how exactly it should be implemented**

## **7.1 Data normalization**

Each candle should normalize as follows:

- map x
- map open/high/low/close
- validate OHLC integrity
- resolve x-domain ordering
- compute scaled body and wick coordinates
- compute candle state (bullish, bearish, doji)
- build hit regions and tooltip model

The normalized candle should track:

- raw item
- raw x
- open/high/low/close
- scaled x
- scaled open/high/low/close
- body rect
- wick line
- state
- semantic text
- selected/focused state

## **7.2 OHLC validation**

This is one of the most important candlestick-specific logic problems.

Recommended rules:

- high >= max(open, close, low)
- low <= min(open, close, high)
- invalid intervals should fail clearly in debug/dev
- production behavior should be predictable and documented

This chart must be strict, because loose OHLC validation creates misleading financial visuals.

## **7.3 Candle-state resolution**

Each candle should resolve to:

- bullish if close > open
- bearish if close < open
- doji if close == open or within configured visual tolerance

That state controls styling, semantics, and possibly legend samples.

## **7.4 Spacing logic**

This is especially important.

### **preserveDomain**

Actual x-domain spacing is preserved, including meaningful gaps.  
Best default for honest time-series work.

### **compressedMissingIntervals**

Missing buckets collapse visually.  
Useful for some trading-style views, but should be explicit.

Recommended default:

- preserveDomain

## **7.5 Geometry generation**

For each visible candle:

- compute x center and body width
- compute wick line from high to low
- compute body rect from open to close
- ensure minimum visible body thickness for tiny differences/doji
- compute selection/focus overlay geometry

## **7.6 Dense-mode rendering**

When candle density gets high:

- body width shrinks
- labels disappear first
- selection/hover still works
- extremely dense views can simplify to wick-dominant or range-dominant rendering if configured later

## **7.7 Future indicator readiness**

The chart analysis notes that stronger ecosystems provide technical indicators and moving averages over raw OHLC data. obers_ui does not need to build all of those into v1, but OiCandlestickChart should already make them easy to layer through OiComboChart, annotations, and future extensions.

# **8\. How performance is guaranteed even with huge datasets**

This is one of the most important parts for candlestick.

The chart analysis explicitly calls out built-in decimation and progressive rendering as baseline requirements for serious chart systems, especially for dense financial time-series data.

## **8.1 Viewport-first processing**

Only normalize and render visible candles plus overscan.

## **8.2 Geometry batching**

Candles are made of repeated primitives:

- body rects
- wick lines

These should be painted efficiently in batches where possible by state/style group.

## **8.3 Density-aware simplification**

In dense or compact modes:

- suppress labels
- simplify stroke detail
- optionally reduce body decoration
- keep hover/selection precise through indexed lookup rather than heavy repaint logic

## **8.4 Indexed hit testing**

Candlestick charts are ordered-domain charts, so hit testing should use:

- binary search or x-bucket lookup
- nearest visible candle resolution
- visible-series-only participation

## **8.5 Cached geometry**

Cache:

- normalized visible candles
- body/wick geometry
- axis tick layout
- tooltip alignment indexes

Invalidate only when:

- data changes
- viewport changes
- theme changes
- spacing mode changes
- density mode changes

## **8.6 Progressive rendering**

For very large OHLC datasets:

- render visible structure immediately
- refine detail if needed
- downshift interactivity cost under heavy load

This is directly consistent with the chart analysis emphasis on progressive rendering for serious data-heavy charts.

# **9\. How interactivity works and can be configured**

OiCandlestickChart should follow the same shared visualization rules as the rest of the family:

- hover tooltip on pointer
- tap tooltip on touch
- legend below on compact
- full-screen fallback below minimum useful size where necessary for honest reading, consistent with the broader visualization rules in base_concept.

## **Default interaction behavior**

### **Pointer**

- hover highlights nearest candle
- hover shows tooltip
- click selects candle
- wheel/trackpad may zoom if enabled

### **Touch**

- tap selects nearest candle
- tap shows tooltip
- long press can lock focus/crosshair
- pinch zoom if enabled

## **Behavior-based configuration**

behaviors: \[  
OiTooltipBehavior(),  
OiCrosshairBehavior(),  
OiZoomPanBehavior(  
allowPan: true,  
allowPinchZoom: true,  
),  
OiSelectionBehavior(  
selectionMode: OiChartSelectionMode.point,  
),  
\]

That stays fully aligned with the chart analysis recommendation that interactions should be composed from independent behavior objects, not one giant config blob.

## **Candlestick-specific interaction detail**

The chart should support:

- candle selection
- shared-x tooltip mode in combo charts
- crosshair
- keyboard traversal by interval order

Recommended default:

- nearest-candle interaction with clear OHLC tooltip

# **10\. How legend and additional information are implemented**

## **Legend**

Candlestick charts usually do not need a large legend unless:

- multiple OHLC series exist
- overlays/indicators are present
- bullish/bearish semantics need explicit explanation in a theme context

If shown, legend should expose:

- series label
- candle sample style
- optional indicator entries when mixed in combo mode

## **Tooltip**

Tooltip should support:

- x value / interval label
- open
- high
- low
- close
- change from previous close later if configured
- optional custom metadata rows

This is the most important exact-detail surface.

## **Additional information layers**

Candlestick charts should support:

- moving-average overlays via combo
- threshold lines
- event markers
- earnings/release markers later
- range annotations

These should use the shared annotation and threshold system rather than a candle-only overlay API.

# **11\. How accessibility is guaranteed**

This is an area where obers_ui can clearly outperform many chart ecosystems. The chart analysis explicitly notes that accessibility is broadly weak and that no major library really provides keyboard navigation for exploring data points. It recommends generated descriptions and keyboard exploration as first-class features.

## **11.1 Required semantics**

At minimum:

- label required
- semanticLabel optional override
- each candle's OHLC semantics available to assistive tech
- legend items keyboard reachable if shown

## **11.2 Auto-generated summary**

If not overridden, generate a summary including:

- chart type
- visible interval count
- x-range
- visible price range
- notable high/low
- general trend direction if inferable

Example:  
"Candlestick chart showing daily price movement from January to March. Visible range spans 94 to 128. Highest visible candle occurs in mid-February."

## **11.3 Keyboard exploration**

A focused candlestick chart should support:

- left/right move between visible intervals
- home/end jump to first/last visible candle
- enter selects focused candle
- escape clears selection
- narration includes date/time plus open, high, low, close

That would directly address one of the ecosystem gaps the chart analysis calls out.

## **11.4 Non-color-only differentiation**

Because bullish/bearish state is often communicated by color:

- high-contrast mode must not depend on hue alone
- filled vs hollow or outline strategy should remain available
- focus/selection should add halo/outline, not just recolor

## **11.5 Reduced motion**

If reduced motion is active:

- suppress sweeping candle-entry animations
- reduce hover transitions
- keep zoom/selection motion minimal

## **11.6 Accessible textual fallback**

A linked OHLC table or detail list is especially valuable here and fits naturally with obers_ui's broader data-display ecosystem and accessibility ambitions.

# **12\. Every extensive test needed for OiCandlestickChart**

## **A. Rendering and layout tests**

- renders basic candlestick chart correctly
- renders bullish, bearish, and doji candles correctly
- respects container constraints
- fills available container
- legend moves below on compact when shown
- dense-mode candle width adapts correctly
- minimum viable fallback appears when too cramped to remain readable

## **B. Data mapping and validation tests**

- mapper-based x/open/high/low/close extraction works correctly
- shorthand single-series API builds correct default series
- invalid OHLC ordering is handled according to spec
- null or missing OHLC values are handled according to spec
- semantic values map correctly

## **C. Spacing and domain tests**

- preserveDomain respects actual interval spacing
- compressedMissingIntervals behaves according to spec
- time and numeric x domains resolve correctly
- explicit axis override beats inferred scale

## **D. Interaction tests**

- hover tooltip appears on pointer
- tap tooltip appears on touch
- nearest-candle selection works correctly
- crosshair follows expected interval
- selection updates controller correctly
- zoom/pan updates viewport correctly
- sync group propagates shared x focus correctly

## **E. Accessibility tests**

- chart exposes semantic label
- auto-generated summary includes visible range
- keyboard left/right navigates intervals correctly
- focused candle narration includes OHLC values
- reduced motion disables nonessential animation
- high-contrast mode preserves bullish/bearish distinction without color-only reliance

## **F. Theming tests**

- bullish/bearish/doji styles derive from chart theme
- local chart theme override applies correctly
- series style override beats chart theme
- per-candle override beats series style
- tooltip and axis visuals resolve from theme
- light and dark goldens are stable

## **G. Responsive tests**

- compact layout moves legend below when present
- compact layout suppresses labels
- pointer uses hover tooltip, touch uses tap tooltip
- narrow layouts degrade honestly
- fallback presentation appears below cramped sizes

## **H. Performance tests**

- large OHLC datasets remain interactive in balanced mode
- viewport filtering excludes offscreen candles
- indexed hit testing avoids full scans
- cached geometry invalidates only when necessary
- repeated hover and zoom do not leak memory
- progressive rendering behaves correctly under load

## **I. Golden tests**

- default candlestick chart
- chart with bullish/bearish/doji mix
- compact candlestick chart
- selected candle with tooltip
- dark theme candlestick chart
- high-contrast candlestick chart
- candlestick + moving-average combo

# **13\. Final recommendation for OiCandlestickChart**

OiCandlestickChart should be the canonical obers_ui chart for **ordered OHLC interval visualization**:

- it should reflect the serious chart inventory direction where candlestick is a first-class chart type, not a hacked composite
- it should use mapper-first OHLC binding, staying aligned with the rest of the package and the best-practice direction from the chart analysis
- it should be fully mixable with line, bar, and indicator-style overlays inside OiComboChart, because first-class chart mixing is one of the most strategically important architectural goals
- it should treat dense time-series performance, indexed interaction, and viewport-first rendering as first-class concerns, because the chart analysis explicitly calls for built-in decimation and progressive rendering in serious financial/time-series work
- it should be unusually strong on accessibility, especially keyboard interval traversal and narrated OHLC summaries, because that is one of the clearest ecosystem gaps identified in the chart analysis

If done well, OiCandlestickChart becomes the **financial interval chart** in obers_ui: precise, honest, performant, and fully consistent with the rest of the package.

When you say **continue**, I'll move to the next deep dive: **nothing to add**.