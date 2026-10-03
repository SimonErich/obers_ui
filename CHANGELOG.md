# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - Unreleased

- Icon buttons honor their requested variant surface, border and interaction
  colors while preserving square bounds. Detailed steppers can opt into an
  intrinsic connected timeline rail, with appearance from `OiStepperThemeData`;
  ordinary layouts retain their defaults.
- Scrollable page layouts can opt compact headings/navigation into the body
  scroll while retaining a pinned footer and unchanged desktop layout.

- Navigation items can show contextual branches and semantic code identifiers;
  ordinary nested groups retain their previous presentation. Contextual groups
  stay visible and their decorative stroke has an independent theme color. Breadcrumbs honor
  the text link role and optional shell link overrides.
- Chart axis themes expose an optional plot-to-label gap, retaining existing
  defaults when omitted. Radio tiles expose optional title typography.
- Dialog action groups wrap at narrow widths while retaining action order,
  spacing and callbacks at desktop widths.

- Button themes expose optional `iconLabelPadding` for directional icon/label
  insets and `smallIconGap`, preserving global/default
  spacing for other sizes and reducing compact toolbar gaps independently.

- `OiFieldLabel` supports themed semantic edit markers without owning draft
  state. Input labels expose configurable typography and supporting spacing;
  quantity selectors accept an optional width and radio groups a heading gap.

- Labelled segmented controls honor themed label typography and spacing;
  choosing another segment keeps geometry stable. Distributed pagination uses
  natural-width groups with equal free gaps and retains compact wrapping.
- Theme documentation shows palette, semantic decoration and effect updates
  together; independent explicit decoration overrides retain precedence.

- Solid filter facets use full-size checkmarks, tabular numerals and semantic
  selected/inactive foregrounds; dashed filter triggers retain their density.
  Action-menu geometry and rounded table-row surfaces follow theme tokens.

- Chart legends expose separate inline/value-list marker and typography tokens;
  sectioned bars honor fixed widths and spacing, dashed grids and emphasized
  categories. Radial charts share painted geometry with pointer hit testing.

- Desktop shell titles/breadcrumbs fit the width left by search and account
  actions, preserving the configured search size without header overflow.

- Collapsible card header gaps collapse with their content; closed cards retain
  no phantom spacing. Underlined tab dividers occupy their own layout pixel
  below tab controls instead of painting over the active indicator.

- Sortable table headings retain their themed typography on hover. Color
  emphasis no longer changes text geometry or introduces truncation.

- Cards expose `headerGap` and preserve bounded child constraints when they have
  no header or footer. Segmented controls expose each segment as one named button
  with selected state, including icon-only controls. Bar charts honor axis
  typography/color and plot-padding tokens,
  including the numeric tick painter, instead of forcing small fallback fonts.

- Radio controls and rich radio cards share a themed indicator. Configure size,
  dot, stroke, colors and choice-heading typography once. Selection cards gain
  themed radius, padding, minimum height and state outlines; changing outline
  width never shifts content. Removed phantom empty-label spacing from tiles.

- `OiWizardLayout.stepHeader` pins the current heading above its independently
  scrolling body. Header padding and minimum height are configurable; short
  frames scroll the heading to preserve input access. Step changes reset the
  body scroll position without owning or replacing form state.

- Badge themes can opt into explicit semantic muted/dark/foreground swatches with `useSwatchColors`; default translucent badges retain their existing appearance. Fixed-height badges stay sized to their content.

### Added

- `OiBadge.showDot` adds a decorative status marker while retaining its visible
  and accessible text label across filled, soft and outline styles.

- `OiPageHeader.actionAlignment` positions the action group vertically beside
  its title, description and metadata while preserving stacked narrow layouts.

- Pagination applies its configured `buttonSize` consistently to arrows,
  numbered pages and the page-size selector. Number labels use compact padding;
  long labels and accessible text scaling can still grow without clipping.

- Navigation rail focus rings repaint immediately on keyboard entry and exit.
- Navigation rails style hover independently from selection through
  `hoverIconColor`, `hoverColor`, and `hoverLabelStyle`. Hover preserves configured
  unselected foregrounds, preventing dark selected icons from disappearing on
  dark rails when their light selection indicator is absent.

- `OiSheet.showHeader` supplies a pinned title and accessible close action.
  Compact page and wizard summaries enable it automatically and inset their
  scrollable content, keeping dismissal available on touch screens.

- `OiAppShell.onSearch` and `searchLabel` provide a labelled compact search
  button, preserving discoverability and keyboard access in narrow headers.
- Popovers label their open content independently of their trigger. Theme and
  account-menu triggers expose one accessible name, including custom avatars.
- App-shell content isolates nested route barriers so routed pages retain
  accessible header actions and navigation on every screen size.
- Closed navigation drawers retain their animation while excluding hidden
  content from pointer handling, keyboard focus and accessibility traversal.

- Narrow pagination stacks its page-size selector and total, keeping long
  localized labels and wrapped middle-page navigation within the available width.

- Checkbox rich labels retain one accessible name and keyboard activation;
  compact radio cards can omit indicator space. Disclosures expose one toggle
  name and a separate helper hint while preserving collapsed editor state.

- Standard buttons expose their accessible name once. Ghost and icon buttons
  use the same keyboard activation as other buttons, including Enter and Space.
- Tooltips can omit a duplicate semantic label when their child already has an
  accessible name; buttons do this automatically for matching tooltip text.

- Text inputs accept a stable `semanticLabel`; visual placeholders become
  hints for labelled inputs instead of changing their accessible names.
- Checkbox themes can style inactive checked indicators with `disabledColor`.

- Trailing `OiKeyValue` summaries reserve only the width their values need,
  while bounding long values on narrow surfaces and preserving custom slots.

- `OiDisclosure` provides a controlled, borderless form expander with keyboard
  interaction, retained child state and reduced-motion support.
- Quantity selectors expose item-specific accessible action labels and increase/
  decrease semantics. Combo boxes can hide visual labels while retaining their
  accessible field identity for compact tables.

- `OiFilterChip` provides reusable dashed filter triggers, selected facets and
  separate value-removal actions with keyboard and touch support.
- Segmented controls support an inset track with individually rounded selection
  pills. Pagination wraps its informational controls in constrained panels.
- Sidebar themes support plain count labels, label/item spacing and separate
  selected icon/outline colors. Pagination consumes all typography/spacing
  overrides and adds distributed layout, themed active pages and dimensions.
- Tabs accept trailing metadata and accessible names, with independent tab
  spacing. Date inputs support accessible hidden labels and leading icons;
  switches support leading labels and honor configured track dimensions.

- `OiBanner.inlineTitle` keeps a title and message on one wrapping line without
  changing existing stacked banners, semantics or dismissal behavior.

- `OiKeyValue` supports trailing-aligned values and custom label content for
  compact totals; groups preserve those slots and row padding. Capacity tracks
  can hide duplicate visual headings while retaining accessible labels and
  values, with an optional explanatory caption below the track.
- User menus accept an avatar override; tables support shrink-wrapped height.
  Resizable panels synchronize updated configured sizes.
- Bulk bars support compact/inverse presentation, optional select-all, dismissal
  callbacks and localized dismissal labels, with existing defaults preserved.
- Controlled card expansion, pinned aside footer slots and radio-card body
  widgets. Search inputs expose configurable placeholders. Table selection uses
  named keyboard-operable checkboxes with checked/mixed semantics and Space/Enter
  activation; row-selection labels are configurable through `OiTableLabels`.

- `OiStepper` supports detailed milestone content, configurable indicator size,
  outlined current steps, and an explicit completed color while retaining the
  existing compact/default presentations.

- Component theme propagation for shells, navigation rails, cards, tables,
  buttons, inputs and sheets. `OiTextTheme.headingScale` and themed default text
  styles preserve variable-font axes.
- `OiIconThemeData` maps icons to SVG, asset or font sources through the shared
  renderer; `OiAppShell` supports separate primary and contextual rails.
- `OiPageLayout` and extended page headers, plus controlled wizard layouts with
  readable connected steps, a pinned footer, full-height aside and compact sheet.
- Rich `OiRadioTile.card` slots, checked indicators and merged selection
  semantics; controlled table expansion; inset sheet headers/footers and typed
  reusable filter-panel editors.
- Horizontal capacity indicators with a hatched remainder and configurable
  avatar foregrounds. Chart presentations add bar patterns, category colors,
  grouping, legend values, and donut center/legend slots.

- Initial package scaffold with directory structure
- Test infrastructure (widget tests, golden tests)
- Example catalog app
- GitHub Actions CI (analyze, test, golden tests, docs)
- Documentation setup (dartdoc, README, CONTRIBUTING)

### Fixed

- Toggle buttons size to their natural content width.
- Combobox clear buttons expose independent named keyboard actions, preserving
  the field’s accessible open action. Radio options expose checked, mutually
  exclusive semantics with Space/Enter activation; horizontal and empty groups
  remain valid. Checkbox labels wrap within narrow filter panels.
- `OiDateInput` uses locale-aware `OiFormatters.dateTime`; bundled intl date
  symbols initialize automatically without an application startup hook.

- Date and date-time inputs accept an explicit locale alongside their intl date
  pattern, keeping textual month names consistent with surrounding formatted
  values.
- `OiDateInput` uses the existing intl date-pattern formatter, correctly rendering
  textual months, weekdays and quoted literals instead of replacing `MM` inside
  longer tokens such as `MMM`.
- Dialog result futures complete after their route/overlay subtree is removed,
  keeping caller-owned form controllers alive through close animations and focus
  teardown.
- Hidden floating portals no longer leave invisible interactive surfaces behind.
- Badges use semantic muted/foreground colors and respect intrinsic content width.
- Raw inputs retain stable controllers and expose enabled/focus semantics.
- Disabling a raw input releases focus and prevents new focus requests without
  changing its controller, selection or caller-owned focus policy. Reenabled
  inputs establish a fresh editing connection instead of retaining a stale
  read-only browser editor after an asynchronous action.
- Donut charts apply inner-radius geometry correctly, and bar charts honor
  explicitly configured axis bounds.
