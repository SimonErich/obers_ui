# Minimal media designs

The standalone `example/lib/minimal_designs.dart` demonstrates Quiet Album's
warm editorial treatment and an unrelated blue, square-cornered Workshop UI.
Both use the same public modules; neither imports an application's UIKit, models,
state management or render backend.

```sh
cd example
flutter pub get
flutter run -t lib/minimal_designs.dart -d chrome
flutter test test/minimal_designs_test.dart
```

The example uses real bundled media and licensed Figtree/Newsreader fonts. Its
controlled actions select a level, include/exclude media, save the selection and
switch the design without losing state. It demonstrates UI composition; saving
a selection does not claim to export a video. The production reday application
supplies actual import, persistence, editing and Fluvie rendering.

## Shared modules

| API | Responsibility | Caller owns |
| --- | --- | --- |
| `OiBalancedText` | Measured, balanced headings; locale, RTL, text scaling, struts and leading | Text, variant and optional style |
| `OiChoiceScale<T>` | Labelled radio scale, roving focus, Left/Right/Up/Down, Home/End, disabled skipping and narrow/large-text reflow | Options, selected value and change callback |
| `OiMediaTile` | Stable source-independent image framing, selection semantics, dimming/grayscale, outlines and opaque overlays | Image child, label, selection and overlays |
| `OiMediaStrip` | Bounded horizontal square items with unclipped external selection outlines | Children, item extent and optional scroll controller |
| `OiDockedPage` | Header, independently scrolling content and fixed dock, safe areas and keyboard inset | Presentational slots and optional scroll controller |

Configure `components.choiceScale`, `components.mediaTile` and
`components.dockedPage` in `OiThemeData`. Styling stays in tokens; album/film
concepts stay in application code. `OiDockedPage` composes `OiPageLayout` rather
than implementing a second page layout engine. Give it bounded height and do
not consume the same keyboard inset in its parent.

For large collections, use `OiDockedPage.slivers(slivers: [...])` with
`OiSliverList` / `OiSliverGrid` builders. It shares the intrinsic page's theme,
content width, padding, header and dock, while building viewport/cache items
on demand. Keep selection in caller state, not in recycled tiles. The library
regression uses 1,000 items, checks bounded construction before/after scrolling,
and confirms that the dock stays fixed. Reday additionally verifies that a
selection survives leaving and re-entering the viewport.

Use `OiTappable.semanticContainer: true` when an action must remain a distinct
semantic node inside an indexed sliver header. `semanticHint` associates context
with that action without lengthening its name. The default container behavior
remains mergeable for surrounding checkbox/radio flags.
`OiButton` owns a fitted semantic boundary so ordinary primary/ghost actions
also remain independently named inside indexed headers, without expanding their
action bounds to the enclosing layout.

`OiMediaTileThemeData.selectedBorder` can use `BorderSide.strokeAlignOutside`.
`OiMediaStrip.outlinePadding` reserves bleed without moving the first item away
from the surrounding gutter. Overlays stay opaque when image content is dimmed.
Null change callbacks are read-only/disabled as documented by each component.

## Typography and scoped controls

Use `OiTextTheme.headingScale` for responsive headings; a constant `1` preserves
explicit design sizes. Shared `textHeightBehavior` controls leading.
`OiLabel.variant` and `OiBalancedText` additionally accept `strutStyle` and
`textHeightBehavior`. Balancing uses the exact resolved style and system text
scaler, preserving the original accessible text and intentional newlines.
One-line, unbounded or long paragraphs fall back to ordinary label wrapping.

`OiButtonThemeScope` resolves partial overrides over the global button theme,
including nested size/variant styles. Partial text styles merge. Unspecified
colors, state styles and geometry are retained. Existing subclass `copyWith`
signatures remain valid; `copyWith` carries size styles, and `merge` overrides
size styles. This avoids copying the full theme for every compact/link action.

## Decode bounds and verification

`OiImage`, `.decorative` and `.provider` accept physical `cacheWidth` /
`cacheHeight` decode bounds. For thumbnails multiply logical dimensions by DPR,
with deliberate overscan for cropped media. Resize policy preserves aspect
ratio, fits both limits and avoids upscaling. Originals remain available to the
render/export backend. This bounds each UI decode; it is not a promise about
aggregate GPU memory or platform-specific cache reclamation.

The example tests capture eight real-font/image goldens across phone, desktop,
RTL at 200% text and DPR 2, plus actual state interaction. Library tests cover
keyboard selection, disabled groups, external focus ownership, stable media
frames, image decoding, baseline alignment and keyboard/safe-area dock geometry.
Reday's browser harness additionally exercises both examples at seven viewport
settings, including breakpoint edges and landscape.

`OiVisualSnapshot.capture(root, viewport: rect)` is a read-only diagnostic for
completed frames. It captures visible painted paragraphs even when excluded
from semantics, with logical layout/clip bounds, tight line boxes and resolved
font/color tokens. It skips offstage, transparent and clipped children.
RenderView roots are measured in logical pixels. Tight font boxes describe
metrics, not individual ink pixels; CSS and Flutter can rasterize them differently.
Keep any web bridge in the host application's explicit capture build, not in
production or the generic library.


For portrait carousels, set `OiMediaStrip.itemAspectRatio` (width / height).
`contentPadding` supplies directional content gutters and independent vertical
space; `horizontalBleed` supplies extra paint space around a narrow parent.
To keep visible card edges tappable, put the carousel inside a full-width body
and supply its gutters through `contentPadding`. Overflow beyond a narrow
ancestor does not enlarge that ancestor's hit area. `OiDockedPage.bodyPadding`
can remove body-wide gutters while retaining the themed header and dock insets;
ordinary sections then supply their own padding. Square filmstrips retain their
existing default geometry.


`OiListTile.titleMaxLines` and `subtitleMaxLines` retain compact one/two-line
defaults. Set either to null for unrestricted wrapping; overflow then clips
rather than applying an ellipsis to the first overflowing line. Row height grows
with the content, preserving complete dates and localized text at large scales.
