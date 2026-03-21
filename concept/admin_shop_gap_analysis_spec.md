# obers_ui — Admin Kit Parity & Shop Checkout Modules Specification

> **Date:** 2026-03-21
> **Extends:** `base_concept.md` v4
> **Scope:** Gap analysis (shadcn-admin-kit → obers_ui), new components, extensions, OiShopCart module

---

## Table of Contents

- [Part 1: Gap Analysis — shadcn-admin-kit vs obers_ui](#part-1-gap-analysis)
  - [Methodology](#methodology)
  - [Component Inventory Crosswalk](#component-inventory-crosswalk)
  - [Gap Summary by Category](#gap-summary-by-category)
- [Part 2: New Components & Extensions](#part-2-new-components--extensions)
  - [Tier 2: New Components](#tier-2-new-components)
  - [Tier 2: Extensions to Existing Components](#tier-2-extensions-to-existing-components)
  - [Tier 3: New Composites](#tier-3-new-composites)
  - [Tier 4: New Modules](#tier-4-new-modules)
- [Part 3: OiShopCart Module System](#part-3-oishopcart-module-system)
  - [Data Models](#shop-data-models)
  - [Tier 2: Shop Components](#tier-2-shop-components)
  - [Tier 3: Shop Composites](#tier-3-shop-composites)
  - [Tier 4: Shop Modules](#tier-4-shop-modules)
- [Part 4: Package Structure Additions](#part-4-package-structure-additions)
- [Part 5: Composition Map Additions](#part-5-composition-map-additions)
- [Part 6: Theme Extensions](#part-6-theme-extensions)

---

# Part 1: Gap Analysis

## Methodology

Every component in the shadcn-admin-kit documentation (88 total across Page Components, Data Display, Data Edition, UI & Layout, and Misc categories) was mapped against the existing obers_ui inventory. Components were classified as:

- **✅ Covered** — Equivalent exists in obers_ui with comparable or superior capability.
- **🔶 Partial** — Functional overlap exists but the obers_ui version lacks specific features the admin kit provides.
- **❌ Missing** — No equivalent in obers_ui. Needs new component or extension.
- **⊘ Not Applicable** — The shadcn-admin-kit component is framework-specific plumbing (React Router, ra-core context) that has no UI-library analogue in Flutter.

## Component Inventory Crosswalk

### Application Configuration (shadcn-admin-kit)

| shadcn-admin-kit | obers_ui Equivalent | Status | Notes |
|---|---|---|---|
| `<Admin>` | `OiApp` | ⊘ | App root. OiApp provides theme/overlay/undo but not data provider injection. Data provider is app-layer concern, not UI kit concern. |
| `<Resource>` | — | ⊘ | Route/CRUD mapping. Framework-level, not UI kit. |
| `<CustomRoutes>` | — | ⊘ | Router config. Out of scope for UI kit. |
| Data Providers | — | ⊘ | API abstraction. Out of scope. |
| Auth Providers | — | ⊘ | Auth logic. Out of scope. |
| I18N | — | ⊘ | Translation system. Out of scope (OiApp supports locale but translation is app-layer). |

### Page Components

| shadcn-admin-kit | obers_ui Equivalent | Status | Notes |
|---|---|---|---|
| `<List>` | `OiListView` (Tier 4) | 🔶 | OiListView exists but lacks integrated filter bar, action toolbar, and title area. Needs **OiResourceList** wrapper. |
| `<Edit>` | — | ❌ | No record-edit page scaffold. Needs **OiResourceEdit**. |
| `<Show>` | — | ❌ | No record-detail page scaffold. Needs **OiResourceShow**. |
| `<Create>` | — | ❌ | No record-create page scaffold. Needs **OiResourceCreate**. |

### Data Display — Fields

| shadcn-admin-kit | obers_ui Equivalent | Status | Notes |
|---|---|---|---|
| `<TextField>` | `OiLabel` | ✅ | OiLabel handles all text rendering. |
| `<NumberField>` | `OiLabel` + formatter | 🔶 | OiLabel renders text but has no built-in number/currency formatting. Needs **OiFieldDisplay** or **OiNumberDisplay**. |
| `<DateField>` | `OiLabel` + formatter | 🔶 | Same — no built-in date formatting widget. |
| `<BooleanField>` | — | ❌ | No read-only boolean display (check/cross icon). |
| `<EmailField>` | — | ❌ | No email display with mailto link. |
| `<UrlField>` | — | ❌ | No URL display with clickable link. |
| `<FileField>` | — | ❌ | No file display with download link. |
| `<ImageField>` | `OiImage` | ✅ | OiImage covers this. |
| `<BadgeField>` | `OiBadge` | ✅ | OiBadge with color mapping. |
| `<SelectField>` | `OiLabel` | 🔶 | Needs value→label resolution from choices. |
| `<ArrayField>` | — | ❌ | No array-of-records display wrapper. |
| `<ReferenceField>` | — | ❌ | Reference resolution is data-layer. But a **display wrapper** pattern is useful. |
| `<ReferenceArrayField>` | — | ❌ | Same as above for arrays. |
| `<ReferenceManyField>` | — | ❌ | Same. |
| `<RecordField>` | — | ❌ | No generic record-field renderer. Needs **OiFieldDisplay**. |
| `<SingleFieldList>` | — | ❌ | Horizontal list of field values (e.g., tag chips). Covered by `OiWrapLayout` + mapping, but no dedicated widget. |
| `<Count>` | `OiMetric` | 🔶 | OiMetric shows value + label but doesn't integrate with data fetching. |

### Data Display — Controls

| shadcn-admin-kit | obers_ui Equivalent | Status | Notes |
|---|---|---|---|
| `<DataTable>` | `OiTable` (Tier 3) | ✅ | OiTable is feature-superior (virtual scroll, inline edit, column freeze, drag reorder). |
| `<ListPagination>` | Part of `OiTable` | 🔶 | Pagination is embedded in OiTable. Needs **standalone OiPagination** (Tier 2) for non-table contexts. |
| `<BulkActionsToolbar>` | — | ❌ | No floating toolbar on row selection. Needs **OiBulkBar** (Tier 2). |
| `<ColumnsButton>` | Part of `OiTable` | ✅ | OiTable has column management panel. |
| `<SortButton>` | — | ❌ | No standalone sort control for non-table lists. Needs **OiSortButton** (Tier 2). |
| `<ToggleFilterButton>` | Part of `OiFilterBar` | 🔶 | OiFilterBar exists but no standalone toggle. Minor — covered by OiFilterBar. |
| `<ExportButton>` | — | ❌ | No data export button. Needs **OiExportButton** (Tier 2). |

### Data Edition — Inputs

| shadcn-admin-kit | obers_ui Equivalent | Status | Notes |
|---|---|---|---|
| `<TextInput>` | `OiTextInput` | ✅ | Full parity. |
| `<NumberInput>` | `OiNumberInput` | ✅ | Full parity. |
| `<DateInput>` | `OiDateInput` | ✅ | |
| `<DateTimeInput>` | `OiDateInput` + `OiTimeInput` | 🔶 | No combined DateTime input. Needs **OiDateTimeInput** (Tier 2). |
| `<BooleanInput>` | `OiSwitch`, `OiCheckbox` | ✅ | |
| `<SelectInput>` | `OiSelect` | ✅ | |
| `<AutocompleteInput>` | `OiComboBox` | ✅ | |
| `<AutocompleteArrayInput>` | `OiTagInput` + `OiComboBox` | 🔶 | OiTagInput handles tags; no autocomplete-sourced multi-select. Extend OiTagInput with `suggestions` + async source. |
| `<RadioButtonGroupInput>` | `OiRadio` | ✅ | |
| `<FileInput>` | `OiFileInput` | ✅ | |
| `<RichTextInput>` | `OiRichEditor` | ✅ | |
| `<SearchInput>` | `OiTextInput.search` | ✅ | |
| `<ArrayInput>` | — | ❌ | No repeatable form field group. Needs **OiArrayInput** (Tier 2). |
| `<SimpleFormIterator>` | — | ❌ | Part of ArrayInput — add/remove/reorder rows. |
| `<TextArrayInput>` | `OiTagInput` | ✅ | OiTagInput covers string-array input. |
| `<SimpleForm>` | `OiForm` | ✅ | |
| `<ReferenceInput>` | `OiComboBox` + data source | ⊘ | Data-fetching wrapper, not UI. |
| `<ReferenceArrayInput>` | `OiTagInput` + data source | ⊘ | Same. |

### Data Edition — Action Buttons

| shadcn-admin-kit | obers_ui Equivalent | Status | Notes |
|---|---|---|---|
| `<SaveButton>` | `OiButton.primary` | 🔶 | OiButton can do this, but a **semantic action button set** with loading/success states would be valuable. |
| `<DeleteButton>` | `OiButton.confirm` (destructive) | ✅ | OiButton.confirm with destructive variant covers this exactly. |
| `<EditButton>` | `OiButton.ghost` + icon | ✅ | Composition of existing. |
| `<ShowButton>` | `OiButton.ghost` + icon | ✅ | Composition of existing. |
| `<CreateButton>` | `OiButton.primary` + icon | ✅ | Composition of existing. |
| `<CancelButton>` | `OiButton.ghost` | ✅ | |
| `<BulkDeleteButton>` | — | ❌ | Covered by OiBulkBar (new). |
| `<BulkExportButton>` | — | ❌ | Covered by OiBulkBar (new). |
| `<RefreshButton>` | `OiIconButton` | ✅ | Trivial composition. |

### UI & Layout

| shadcn-admin-kit | obers_ui Equivalent | Status | Notes |
|---|---|---|---|
| `<Layout>` | — | ❌ | No admin shell layout (sidebar + header + breadcrumb + content). Needs **OiAppShell** (Tier 4 Module). |
| `<AppSidebar>` | `OiSidebar` | ✅ | OiSidebar covers this. |
| `<Breadcrumb>` | `OiBreadcrumbs` | ✅ | |
| `<Confirm>` | `OiDialog` + `OiButton.confirm` | ✅ | |
| `<Error>` | `OiEmptyState` | 🔶 | OiEmptyState is generic. Needs **OiErrorPage** (Tier 3) for 404/403/500. |
| `<Loading>` | `OiSkeletonGroup`, `OiShimmer` | ✅ | |
| `<LocalesMenuButton>` | — | ❌ | No locale switcher. Needs **OiLocaleSwitcher** (Tier 2). |
| `<LoginPage>` | — | ❌ | No auth page templates. Needs **OiAuthPage** (Tier 4 Module). |
| `<Notification>` | `OiToast` | ✅ | |
| `<Ready>` | `OiEmptyState` | ✅ | Composition of OiEmptyState. |
| `<ThemeModeToggle>` | — | ❌ | No dedicated theme toggle widget. Needs **OiThemeToggle** (Tier 2). |
| `<UserMenu>` | — | ❌ | No user account dropdown. Needs **OiUserMenu** (Tier 2). |

### Misc

| shadcn-admin-kit | obers_ui Equivalent | Status | Notes |
|---|---|---|---|
| Real-time | `OiCursorPresence`, `OiSelectionPresence`, `OiTypingIndicator`, `OiLiveRing` | 🔶 | obers_ui has presence widgets but no record-level live update/lock system. Real-time data sync is data-layer. |
| Soft Delete | — | ⊘ | Data-layer concern, not UI kit. |

## Gap Summary by Category

| Category | Total Components | ✅ Covered | 🔶 Partial | ❌ Missing | ⊘ N/A |
|---|---|---|---|---|---|
| App Config | 6 | 0 | 0 | 0 | 6 |
| Page Components | 4 | 0 | 1 | 3 | 0 |
| Data Display — Fields | 16 | 3 | 4 | 9 | 0 |
| Data Display — Controls | 7 | 2 | 2 | 3 | 0 |
| Data Edition — Inputs | 17 | 10 | 2 | 2 | 3 |
| Data Edition — Buttons | 8 | 5 | 1 | 2 | 0 |
| UI & Layout | 13 | 5 | 1 | 4 | 3 |
| Misc | 2 | 0 | 1 | 0 | 1 |
| **Total** | **73** | **25** | **12** | **23** | **13** |

**Net action items:** 23 new components/modules + 12 extensions. After deduplication and grouping into our tier system, this reduces to the concrete items in Part 2.

---

# Part 2: New Components & Extensions

The gaps are addressed by the following additions, organized by tier. Each component is designed to fit the existing `Oi` naming conventions, composition rules, and theming system.

---

## Tier 2: New Components

---

### OiFieldDisplay

**What it is:** A universal read-only field renderer. Given a value and a field type, it renders the value with appropriate formatting, icons, and link behavior. This is the obers_ui answer to shadcn-admin-kit's entire "Field" component family — one widget with a `variant` instead of 15 separate widgets.

**Why one widget:** In obers_ui, we avoid proliferating tiny single-purpose widgets. `OiFieldDisplay` with variants is more discoverable than `OiEmailField`, `OiUrlField`, `OiBooleanField`, etc. Developers learn one API.

**Composes:** `OiLabel` (text rendering), `OiIcon` (boolean check/cross, type icons), `OiImage` (image variant), `OiBadge` (enum/select variant), `OiTappable` (link variants), `OiCopyable` (optional copy), `OiTooltip` (overflow/truncated values)

```dart
OiFieldDisplay({
  required String label,         // Field name / a11y label
  required dynamic value,        // The value to display
  OiFieldType type = OiFieldType.text,
  String? emptyText,             // Shown when value is null — default: "—"
  bool copyable = false,         // Wraps in OiCopyable
  int? maxLines,                 // Truncation
  // Type-specific props:
  String? dateFormat,            // For date/dateTime — e.g. "MMM dd, yyyy"
  String? numberFormat,          // For number — e.g. "#,##0.00"
  String? currencyCode,          // For currency — e.g. "EUR", "USD"
  String? currencySymbol,        // For currency — e.g. "€", "$"
  int? decimalPlaces,            // For number/currency
  Map<dynamic, String>? choices, // For select — value→label mapping
  Map<dynamic, Color>? choiceColors, // For select — value→color for badge
  String Function(dynamic)? formatValue, // Custom formatter override
  VoidCallback? onTap,           // For link variants — fires on tap
  Widget? leading,               // Custom leading widget
})

OiFieldDisplay.pair({
  required String label,
  required dynamic value,
  OiFieldType type = OiFieldType.text,
  // ...same props as above
  Axis direction = Axis.horizontal,  // label : value layout
  double labelWidth = 120,           // Fixed label width for alignment in horizontal
})

enum OiFieldType {
  text,       // Plain text via OiLabel
  number,     // Formatted number
  currency,   // Currency-formatted number with symbol
  date,       // Formatted date
  dateTime,   // Formatted date + time
  boolean,    // Check icon (true) / cross icon (false) / dash (null)
  email,      // Tappable mailto link with icon
  url,        // Tappable link, truncated with icon
  phone,      // Tappable tel link with icon
  file,       // Filename with download icon and size
  image,      // Thumbnail via OiImage
  select,     // Badge from choices map
  tags,       // Horizontal wrap of OiBadge chips for List<String>
  color,      // Color swatch + hex code
  json,       // Formatted JSON in OiCodeBlock
  custom,     // Uses formatValue callback, falls back to .toString()
}
```

**The `.pair()` factory** renders label and value side by side (or stacked) — the building block for detail/show views. Multiple `.pair()` widgets in an `OiColumn` replicate `<Show>` field lists.

**States:** None (read-only). Links show hover via `OiTappable`.

**Tests:**

| Test | What it verifies |
|------|-----------------|
| text renders value via OiLabel | String displays |
| number formats with grouping | 1234567 → "1,234,567" |
| currency adds symbol | 42.5 → "$42.50" |
| date formats correctly | ISO string → "Mar 21, 2026" |
| dateTime includes time | ISO → "Mar 21, 2026 14:30" |
| boolean true shows check icon | Green check visible |
| boolean false shows cross icon | Red cross visible |
| boolean null shows dash | "—" or custom emptyText |
| email renders mailto link | Tappable, icon present |
| url renders clickable link | Tappable, truncated |
| phone renders tel link | Tappable, phone icon |
| file shows filename + size | "report.pdf (2.3 MB)" |
| image renders OiImage thumbnail | Image visible |
| select maps value to label badge | Badge with correct color |
| tags renders multiple badges | OiWrapLayout of OiBadge |
| color shows swatch + hex | Color swatch visible |
| json renders in OiCodeBlock | Formatted JSON |
| custom uses formatValue | Custom string returned |
| emptyText shows for null | Fallback visible |
| copyable wraps in OiCopyable | Copy on click |
| maxLines truncates | Ellipsis visible |
| pair horizontal layout | Label left, value right |
| pair vertical layout | Label top, value bottom |
| pair labelWidth aligns | Fixed-width labels align |
| a11y: label announced | Semantics label present |
| Theme change updates formatting | Colors/fonts update |
| Golden: every field type | Visual regression |

---

### OiPagination

**What it is:** A standalone pagination control — usable outside OiTable. Renders page numbers, prev/next arrows, "items per page" selector, and total count. The same widget OiTable uses internally, now exported.

**Composes:** `OiRow`, `OiButton.ghost` (page numbers, arrows), `OiSelect` (per-page), `OiLabel` (count), `OiIcon` (arrows)

```dart
OiPagination({
  required int totalItems,
  required int currentPage,
  required String label,
  int perPage = 25,
  List<int> perPageOptions = const [10, 25, 50, 100],
  ValueChanged<int>? onPageChange,
  ValueChanged<int>? onPerPageChange,
  bool showPerPage = true,
  bool showTotal = true,
  bool showFirstLast = true,
  int siblingCount = 1,            // Pages shown around current
  OiPaginationVariant variant = OiPaginationVariant.pages,
})

OiPagination.loadMore({
  required int loadedCount,
  required int totalItems,
  required String label,
  VoidCallback? onLoadMore,
  bool loading = false,
})

enum OiPaginationVariant { pages, compact } // compact = "1 / 12" with arrows only
```

**Tests:**

| Test | What it verifies |
|------|-----------------|
| Renders correct page count | totalItems / perPage |
| Current page highlighted | Active style on current |
| Prev/next arrows navigate | onPageChange fires |
| First/last buttons jump | Page 1 / last page |
| Ellipsis for large page counts | "1 ... 5 6 7 ... 20" |
| Per-page selector changes | onPerPageChange fires |
| Total count shows | "1–25 of 150" |
| Compact variant shows "X / Y" | Minimal display |
| loadMore variant shows button | "Load more" button |
| loadMore loading state | Spinner on button |
| Disabled prev on first page | Arrow disabled |
| Disabled next on last page | Arrow disabled |
| Keyboard: arrow keys navigate | Focus management |
| a11y: navigation landmark | Semantics label |
| Golden: both variants | Visual regression |

---

### OiBulkBar

**What it is:** A floating toolbar that appears when one or more items are selected in a list or table. Shows the selection count and action buttons. Animates in from bottom.

**Composes:** `OiSurface` (elevated bar), `OiLabel` (count), `OiButton` (action buttons), `OiRow`, `OiAnimatedList` (slide in/out), `OiCheckbox` (select all toggle)

```dart
OiBulkBar({
  required int selectedCount,
  required int totalCount,
  required String label,
  required List<OiBulkAction> actions,
  VoidCallback? onSelectAll,
  VoidCallback? onDeselectAll,
  bool allSelected = false,
})

class OiBulkAction {
  final String label;
  final IconData? icon;
  final VoidCallback onTap;
  final OiButtonVariant variant;  // default ghost, destructive for delete
  final bool loading;
  final bool confirm;             // if true, uses OiButton.confirm behavior
}
```

**Tests:**

| Test | What it verifies |
|------|-----------------|
| Bar appears when selectedCount > 0 | Slide-in animation |
| Bar disappears when selectedCount = 0 | Slide-out animation |
| Count displays correctly | "3 selected" |
| Select all toggle | Checkbox + onSelectAll |
| Deselect all | onDeselectAll fires |
| Action buttons render | Each action visible |
| Destructive action shows confirm | Two-press pattern |
| Loading state on action | Spinner in button |
| a11y: toolbar role | Semantics toolbar |
| Golden: bar with actions | Visual regression |

---

### OiSortButton

**What it is:** A dropdown button for sorting non-table lists (e.g., card grids, activity feeds). Shows current sort field and direction.

**Composes:** `OiButton.outline` (trigger), `OiPopover`, `OiRadio` (sort field options), `OiToggleButton` (asc/desc)

```dart
OiSortButton({
  required List<OiSortOption> options,
  required OiSortOption currentSort,
  required String label,
  ValueChanged<OiSortOption>? onSortChange,
})

class OiSortOption {
  final String field;
  final String label;
  final OiSortDirection direction;
}

enum OiSortDirection { asc, desc }
```

**Tests:**

| Test | What it verifies |
|------|-----------------|
| Button shows current sort | Label + arrow |
| Dropdown lists options | All options visible |
| Selecting option fires callback | onSortChange |
| Direction toggle works | asc ↔ desc |
| a11y: button + listbox | Semantics roles |

---

### OiExportButton

**What it is:** A button that exports data in various formats. Shows a dropdown for format selection if multiple formats are available.

**Composes:** `OiButton.outline` or `OiButton.split` (if multiple formats), `OiIcon`, `OiPopover`

```dart
OiExportButton({
  required String label,
  required Future<void> Function(OiExportFormat format) onExport,
  List<OiExportFormat> formats = const [OiExportFormat.csv],
  bool loading = false,
})

enum OiExportFormat { csv, xlsx, json, pdf }
```

**Tests:**

| Test | What it verifies |
|------|-----------------|
| Single format: direct button | No dropdown |
| Multiple formats: split button | Dropdown shows formats |
| Loading state | Spinner, disabled |
| onExport fires with format | Correct format passed |

---

### OiDateTimeInput

**What it is:** A combined date + time input. Renders `OiDateInput` and `OiTimeInput` side by side in a single form field with one label and one error message.

**Composes:** `OiDateInput`, `OiTimeInput`, `OiRow`, `OiLabel` (shared label), `OiLabel` (shared error)

```dart
OiDateTimeInput({
  required String label,
  DateTime? value,
  ValueChanged<DateTime?>? onChange,
  DateTime? min,
  DateTime? max,
  String? error,
  String? hint,
  bool required = false,
  bool readOnly = false,
  bool disabled = false,
})
```

**Tests:**

| Test | What it verifies |
|------|-----------------|
| Renders date and time side by side | Both inputs visible |
| Changing date updates value | DateTime date portion |
| Changing time updates value | DateTime time portion |
| Single error for both | Error below both inputs |
| min/max enforced | Invalid dates rejected |
| a11y: single group label | Semantics group |

---

### OiThemeToggle

**What it is:** A toggle button that switches between light, dark, and system theme modes. Shows sun/moon/monitor icon.

**Composes:** `OiIconButton` or `OiToggleButton`, `OiIcon`, `OiPopover` (if three-way toggle), `OiTooltip`

```dart
OiThemeToggle({
  required ThemeMode currentMode,
  required ValueChanged<ThemeMode> onModeChange,
  String label = 'Toggle theme',
  bool showSystemOption = true,
})
```

**Tests:**

| Test | What it verifies |
|------|-----------------|
| Light mode shows sun icon | Correct icon |
| Dark mode shows moon icon | Correct icon |
| System mode shows monitor icon | Correct icon |
| Tapping cycles modes | onModeChange fires |
| Three-way with popover | All three options |
| Two-way without system | Light ↔ dark only |
| a11y: label announced | Semantics |
| Tooltip shows current mode | Tooltip text |

---

### OiUserMenu

**What it is:** An avatar-triggered dropdown menu showing user info and account actions (profile, settings, logout). The standard "top-right user menu" pattern.

**Composes:** `OiAvatar` (trigger), `OiTappable` (trigger wrapper), `OiPopover`, `OiLabel` (user name, email), `OiDivider`, `OiListTile` (menu items), `OiIcon`

```dart
OiUserMenu({
  required String label,
  required String userName,
  String? userEmail,
  String? avatarUrl,
  String? avatarInitials,        // Fallback when no URL
  required List<OiMenuItem> items,
  Widget? header,                // Custom header widget above items
})
```

`OiMenuItem` already exists in the base concept (used by `OiContextMenu`). Reused here.

**Tests:**

| Test | What it verifies |
|------|-----------------|
| Avatar renders | Image or initials |
| Tap opens popover | Menu visible |
| User name and email shown | Text in header |
| Menu items render | All items visible |
| Item tap fires callback + closes | onTap + dismiss |
| Dividers render between groups | Visual separation |
| a11y: menu role | Semantics |
| Keyboard: Enter opens, Escape closes | Focus management |
| Golden: open state | Visual regression |

---

### OiLocaleSwitcher

**What it is:** A dropdown for switching application locale. Shows flag/code for current locale, dropdown of available locales.

**Composes:** `OiButton.ghost` (trigger), `OiPopover`, `OiListTile` (locale options), `OiLabel`, `OiIcon`

```dart
OiLocaleSwitcher({
  required Locale currentLocale,
  required List<OiLocaleOption> locales,
  required ValueChanged<Locale> onLocaleChange,
  String label = 'Language',
  bool showFlag = true,
  bool showCode = true,           // "EN", "DE", etc.
  bool showName = true,           // "English", "Deutsch"
})

class OiLocaleOption {
  final Locale locale;
  final String name;              // Display name in that language
  final String? flagEmoji;        // 🇬🇧, 🇩🇪, etc.
}
```

**Tests:**

| Test | What it verifies |
|------|-----------------|
| Trigger shows current locale | Code/flag visible |
| Dropdown lists all locales | All options |
| Selection fires callback | onLocaleChange |
| Active locale highlighted | Check mark or bold |
| a11y: combobox role | Semantics |

---

### OiArrayInput

**What it is:** A repeatable form field group. Each row contains a set of form inputs, with add/remove/reorder controls. This fills the gap of shadcn-admin-kit's `<ArrayInput>` + `<SimpleFormIterator>`.

**Composes:** `OiColumn` (rows), `OiRow` (each row layout), `OiReorderable` (drag-to-reorder), `OiButton.ghost` (add/remove), `OiIcon` (drag handle, delete), `OiDivider` (between rows), `OiAnimatedList` (add/remove animation)

```dart
OiArrayInput<T>({
  required String label,
  required List<T> items,
  required Widget Function(T item, int index, ValueChanged<T> onItemChange) itemBuilder,
  required T Function() createEmpty,   // Factory for new blank row
  ValueChanged<List<T>>? onChange,
  bool reorderable = true,
  bool addable = true,
  bool removable = true,
  int? minItems,
  int? maxItems,
  String addLabel = 'Add',
  String? error,
})
```

**Tests:**

| Test | What it verifies |
|------|-----------------|
| Renders all items | itemBuilder called per item |
| Add button creates new row | createEmpty + animation |
| Remove button deletes row | Item removed + animation |
| Reorder via drag | onChanged with new order |
| minItems prevents removal | Remove disabled at min |
| maxItems prevents addition | Add disabled at max |
| onChange fires on any change | Updated list passed |
| Error displays below all rows | Error text visible |
| a11y: list with label | Semantics |
| Keyboard: Tab through rows | Focus order correct |
| Golden: multiple rows | Visual regression |

---

## Tier 2: Extensions to Existing Components

---

### OiTagInput — Add `suggestions` and `asyncSuggestions`

**Current:** OiTagInput accepts free-text tags.
**Extension:** Add autocomplete suggestions (like shadcn-admin-kit's `<AutocompleteArrayInput>`).

```dart
// New props added to OiTagInput:
OiTagInput({
  // ...existing props...
  List<String>? suggestions,                           // Static list
  Future<List<String>> Function(String query)? asyncSuggestions, // Async search
  Duration suggestionDebounce = const Duration(milliseconds: 300),
  bool allowCustomTags = true,   // false = only from suggestions
})
```

**New tests:**

| Test | What it verifies |
|------|-----------------|
| Suggestions dropdown appears on type | Popover with matches |
| Async suggestions fire with debounce | Future called after delay |
| Selecting suggestion adds tag | Tag chip appears |
| allowCustomTags=false blocks free text | Only suggestion items accepted |
| Loading indicator during async | Shimmer in dropdown |

---

### OiTable — Add `bulkBar` slot

**Current:** OiTable has `onSelectionChange` but no built-in bulk action UI.
**Extension:** Add optional `bulkBar` prop for automatic `OiBulkBar` integration.

```dart
// New prop on OiTable:
OiTable({
  // ...existing props...
  List<OiBulkAction>? bulkActions,  // When provided, shows OiBulkBar on selection
})
```

---

### OiEmptyState — Add `variant` for error pages

**Current:** OiEmptyState is generic.
**Extension:** Add factory constructors for common error states.

```dart
OiEmptyState.notFound({
  String title = 'Page not found',
  String? description,
  String? actionLabel,
  VoidCallback? onAction,
})

OiEmptyState.forbidden({
  String title = 'Access denied',
  String? description,
  String? actionLabel,
  VoidCallback? onAction,
})

OiEmptyState.error({
  String title = 'Something went wrong',
  String? description,
  String? actionLabel,
  VoidCallback? onAction,
  Object? error,                  // Optional error object for dev mode display
})
```

---

### OiForm — Add `onSubmitSuccess` / `onSubmitError` callbacks

**Current:** OiForm has `onSubmit`.
**Extension:** Add lifecycle callbacks for save/cancel patterns matching admin CRUD.

```dart
// New props on OiForm:
OiForm({
  // ...existing props...
  Future<void> Function(Map<String, dynamic> values)? onSubmitAsync, // Async save
  VoidCallback? onCancel,
  bool showCancelButton = false,
  bool showSaveButton = true,
  String saveLabel = 'Save',
  String cancelLabel = 'Cancel',
  bool warnOnUnsavedChanges = false,  // Shows confirm dialog on navigate away
})
```

---

## Tier 3: New Composites

---

### OiDetailView

**What it is:** A read-only record detail layout. Renders a list of `OiFieldDisplay.pair()` widgets in a structured layout with sections, matching the `<Show>` page content area in shadcn-admin-kit.

**Composes:** `OiColumn`, `OiFieldDisplay.pair`, `OiLabel` (section headers), `OiDivider`, `OiCard` (optional wrapping), `OiSurface`

```dart
OiDetailView({
  required String label,
  required List<OiDetailSection> sections,
  int columns = 1,                // 1 = single column, 2 = two-column grid
  double columnGap = 24,
  double rowGap = 16,
})

class OiDetailSection {
  final String? title;
  final List<OiDetailField> fields;
}

class OiDetailField {
  final String label;
  final dynamic value;
  final OiFieldType type;
  final int columnSpan;            // 1 or 2 for two-column layouts
  // All OiFieldDisplay props forwarded:
  final String? dateFormat;
  final String? numberFormat;
  final String? currencyCode;
  final Map<dynamic, String>? choices;
  final Map<dynamic, Color>? choiceColors;
  final String Function(dynamic)? formatValue;
  final bool copyable;
}
```

**Tests:**

| Test | What it verifies |
|------|-----------------|
| Renders all sections | Section titles + fields |
| Single column layout | Fields stacked |
| Two-column layout | Fields in grid |
| Column span = 2 takes full width | Field spans both columns |
| Section dividers render | Visual separation |
| All field types render correctly | Delegates to OiFieldDisplay |
| Empty value shows emptyText | Dash for null |
| a11y: labeled region per section | Semantics |
| Golden: single column, two column | Visual regression |

---

### OiErrorPage

**What it is:** A full-page error display for 404, 403, 500, and custom errors. Shows illustration area, title, description, and action button.

**Composes:** `OiEmptyState` (variant factories), `OiContainer` (centering), `OiButton` (action)

```dart
OiErrorPage({
  required String title,
  required String label,
  String? description,
  String? errorCode,              // "404", "403", "500" — shown large
  Widget? illustration,           // Custom illustration/icon
  String? actionLabel,
  VoidCallback? onAction,         // e.g., "Go Home"
})

OiErrorPage.notFound({...})
OiErrorPage.forbidden({...})
OiErrorPage.serverError({...})
```

---

## Tier 4: New Modules

---

### OiAppShell

**What it is:** The master layout scaffold for admin-style applications. Composes sidebar, top bar (with breadcrumbs, user menu, theme toggle, locale switcher), and content area. This is the obers_ui equivalent of shadcn-admin-kit's `<Layout>`.

**Composes:** `OiSidebar` (navigation), `OiRow` / `OiColumn` (layout), `OiBreadcrumbs` (path), `OiUserMenu` (account), `OiThemeToggle`, `OiLocaleSwitcher` (optional), `OiLabel` (page title), `OiSurface` (top bar), `OiDrawer` (mobile sidebar), `OiResponsive` (breakpoint switching)

```dart
OiAppShell({
  required Widget child,
  required String label,
  required List<OiNavItem> navigation,
  // Top bar slots:
  Widget? leading,                // Logo / app name area
  Widget? title,                  // Page title (usually from route)
  List<Widget>? actions,          // Right side of top bar — theme toggle, locale, etc.
  Widget? userMenu,               // OiUserMenu widget
  // Sidebar config:
  bool sidebarCollapsible = true,
  bool sidebarDefaultCollapsed = false,
  double sidebarWidth = 256,
  double sidebarCollapsedWidth = 64,
  // Breadcrumbs:
  List<OiBreadcrumbItem>? breadcrumbs,
  bool showBreadcrumbs = true,
  // Responsive:
  OiBreakpoint mobileBreakpoint = OiBreakpoint.md,
})

class OiNavItem {
  final String label;
  final IconData icon;
  final String? route;
  final List<OiNavItem>? children;  // Nested navigation
  final Widget? badge;              // Notification badge
  final bool dividerBefore;
  final String? section;            // Group label — "Main", "Settings", etc.
}
```

**Behavior:**
- On desktop (≥ mobileBreakpoint): Sidebar on left, top bar with breadcrumbs and actions on top, content fills remaining space.
- On mobile (< mobileBreakpoint): Sidebar becomes `OiDrawer`, hamburger icon in top bar. Breadcrumbs collapse to current page only.
- Sidebar collapse/expand animates width change. Navigation items show icon-only when collapsed.
- Active route highlighted in sidebar automatically (matches `route` against current path).
- Children items expand as nested accordion within sidebar.

**Tests:**

| Test | What it verifies |
|------|-----------------|
| Desktop: sidebar + topbar + content | Full layout renders |
| Sidebar shows navigation items | All items visible |
| Active route highlighted | Current item styled |
| Nested items expand/collapse | Accordion behavior |
| Sidebar collapses to icons | Width animates, labels hidden |
| Breadcrumbs render in topbar | Path visible |
| Actions render in topbar right | Theme toggle, etc. |
| User menu renders in topbar | Avatar visible |
| Mobile: drawer replaces sidebar | Hamburger + drawer |
| Mobile: breadcrumbs collapse | Current page only |
| Section labels group items | "Main", "Settings" |
| Badge on nav item | Badge visible |
| a11y: navigation landmark | Semantics nav |
| a11y: sidebar label | Semantics label |
| Keyboard: Tab through nav | Focus management |
| Golden: desktop expanded | Visual regression |
| Golden: desktop collapsed | Visual regression |
| Golden: mobile with drawer | Visual regression |

---

### OiResourcePage

**What it is:** A generic CRUD page scaffold that provides the layout wrapper for list, show, edit, and create views. It handles the page chrome (title, breadcrumb, action buttons) and delegates content rendering to children.

This is NOT a data-fetching component (that's app-layer). It's pure layout — title area, action bar, content area, and pagination area — matching the standard admin page anatomy.

**Composes:** `OiColumn`, `OiRow`, `OiLabel` (title), `OiBreadcrumbs`, `OiButton` (actions), `OiCard` (content wrapper), `OiPagination`, `OiSurface`

```dart
OiResourcePage({
  required String title,
  required String label,
  required Widget child,
  OiResourcePageVariant variant = OiResourcePageVariant.list,
  List<Widget>? actions,          // Top-right action buttons
  Widget? filters,                // Filter bar below title (list variant)
  Widget? pagination,             // Bottom pagination (list variant)
  List<OiBreadcrumbItem>? breadcrumbs,
  bool wrapInCard = true,         // Wraps child in OiCard
})

enum OiResourcePageVariant { list, show, edit, create }
```

**Variant-specific defaults:**
- `list`: Shows CreateButton in actions, filters slot, pagination slot.
- `show`: Shows EditButton + DeleteButton in actions.
- `edit`: Shows SaveButton + CancelButton in actions, wraps in form card.
- `create`: Shows SaveButton + CancelButton in actions, wraps in form card.

**Tests:**

| Test | What it verifies |
|------|-----------------|
| Title renders | OiLabel with correct text |
| Actions render top-right | Buttons aligned right |
| List variant shows filters | Filter slot populated |
| List variant shows pagination | Bottom pagination |
| Show variant default actions | Edit + Delete |
| Edit variant default actions | Save + Cancel |
| Breadcrumbs render | Path above title |
| Card wrapping | OiCard around child |
| a11y: main landmark | Semantics main |

---

### OiAuthPage

**What it is:** Pre-built authentication page layouts — login, register, forgot password, reset password. Fully themed, responsive (centered card on large screens, full-screen on mobile), with customizable branding.

**Composes:** `OiSurface` (page background), `OiCard` (form container), `OiForm`, `OiTextInput`, `OiButton`, `OiLabel`, `OiImage` (logo), `OiDivider.withLabel` ("or"), `OiCheckbox` ("remember me")

```dart
OiAuthPage.login({
  required String label,
  required Future<void> Function(String email, String password) onLogin,
  Widget? logo,
  String? title,
  String? subtitle,
  bool showRememberMe = true,
  bool showForgotPassword = true,
  VoidCallback? onForgotPassword,
  VoidCallback? onRegister,
  List<OiSocialLogin>? socialLogins,  // Google, GitHub, etc.
  Widget? footer,
})

OiAuthPage.register({
  required String label,
  required Future<void> Function(String name, String email, String password) onRegister,
  Widget? logo,
  String? title,
  VoidCallback? onLogin,
  List<OiSocialLogin>? socialLogins,
  List<Widget>? extraFields,      // Additional form fields
  Widget? terms,                  // Terms & conditions checkbox
})

OiAuthPage.forgotPassword({
  required String label,
  required Future<void> Function(String email) onSubmit,
  Widget? logo,
  VoidCallback? onBackToLogin,
})

OiAuthPage.resetPassword({
  required String label,
  required Future<void> Function(String password) onSubmit,
  Widget? logo,
  VoidCallback? onBackToLogin,
})

class OiSocialLogin {
  final String label;             // "Continue with Google"
  final IconData icon;
  final VoidCallback onTap;
}
```

**Tests:**

| Test | What it verifies |
|------|-----------------|
| Login form renders | Email + password fields |
| Login onSubmit fires | Correct credentials passed |
| Login loading state | Button shows spinner |
| Login error display | Error message below form |
| Remember me checkbox | Renders, toggles |
| Forgot password link | onForgotPassword fires |
| Register link | onRegister fires |
| Social login buttons | Render, fire callbacks |
| Register form with extra fields | Custom fields visible |
| Forgot password flow | Email → submit → success |
| Reset password with validation | Passwords must match |
| Responsive: card centered on desktop | Max-width centered |
| Responsive: full-width on mobile | No card, full form |
| a11y: form landmark | Semantics form |
| a11y: labels on all inputs | Semantics labels |
| Golden: login light | Visual regression |
| Golden: login dark | Visual regression |

---

# Part 3: OiShopCart Module System

A full e-commerce cart and checkout system built from obers_ui primitives. Organized bottom-up: data models → Tier 2 components → Tier 3 composites → Tier 4 modules.

---

## Shop Data Models

All models are immutable with `copyWith`. No direct coupling to any backend — all data flows in via props.

```dart
class OiProductData {
  final Object key;
  final String name;
  final String? description;
  final double price;
  final double? compareAtPrice;       // Strike-through "was" price
  final String? currencyCode;         // "EUR", "USD" — default from OiShopTheme
  final String? imageUrl;
  final List<String>? imageUrls;      // Gallery images
  final List<OiProductVariant>? variants;
  final Map<String, String>? attributes; // "Color": "Red", "Size": "M"
  final bool inStock;
  final int? stockCount;
  final double? rating;
  final int? reviewCount;
  final List<String>? tags;
  final String? sku;
}

class OiProductVariant {
  final Object key;
  final String label;                  // "Red / Large"
  final double? price;                 // Override, null = use parent price
  final String? imageUrl;
  final bool inStock;
  final int? stockCount;
  final Map<String, String> attributes; // "Color": "Red", "Size": "L"
}

class OiCartItem {
  final Object productKey;
  final Object? variantKey;
  final String name;
  final String? variantLabel;
  final double unitPrice;
  final int quantity;
  final String? imageUrl;
  final int? maxQuantity;             // Stock limit
  final Map<String, String>? attributes;
}

class OiCartSummary {
  final double subtotal;
  final double? discount;
  final String? discountLabel;        // "SUMMER20 (-20%)"
  final double? shipping;
  final String? shippingLabel;        // "Express Shipping"
  final double? tax;
  final String? taxLabel;             // "VAT 20%"
  final double total;
  final String currencyCode;
}

class OiShippingMethod {
  final Object key;
  final String label;
  final String? description;
  final double price;
  final String? estimatedDelivery;    // "2–4 business days"
  final IconData? icon;
}

class OiPaymentMethod {
  final Object key;
  final String label;
  final IconData? icon;
  final String? lastFour;             // "•••• 4242" for saved cards
  final String? expiryDate;           // "12/27"
  final Widget? logo;                 // Visa, Mastercard, etc.
}

class OiAddressData {
  final String? firstName;
  final String? lastName;
  final String? company;
  final String line1;
  final String? line2;
  final String city;
  final String? state;
  final String postalCode;
  final String country;               // ISO country code
  final String? phone;
}

class OiOrderData {
  final Object key;
  final String orderNumber;
  final DateTime createdAt;
  final OiOrderStatus status;
  final List<OiCartItem> items;
  final OiCartSummary summary;
  final OiAddressData? shippingAddress;
  final OiAddressData? billingAddress;
  final OiPaymentMethod? paymentMethod;
  final OiShippingMethod? shippingMethod;
  final List<OiOrderEvent>? timeline;
}

class OiOrderEvent {
  final DateTime timestamp;
  final String title;
  final String? description;
  final OiOrderStatus status;
}

enum OiOrderStatus {
  pending,
  confirmed,
  processing,
  shipped,
  delivered,
  cancelled,
  refunded,
}
```

---

## Tier 2: Shop Components

---

### OiPriceTag

**What it is:** A formatted price display with optional compare-at (strikethrough) price and currency symbol.

**Composes:** `OiRow`, `OiLabel`

```dart
OiPriceTag({
  required double price,
  required String label,
  double? compareAtPrice,
  String? currencyCode,
  String? currencySymbol,
  int decimalPlaces = 2,
  OiPriceTagSize size = OiPriceTagSize.medium,
})

enum OiPriceTagSize { small, medium, large }
```

**Behavior:**
- When `compareAtPrice` is provided and > price: shows compare-at with strikethrough styling in muted color, current price in primary/bold.
- Currency symbol placed per locale convention (€ after in DE, $ before in US).
- Negative prices (discounts) shown in success color.

**Tests:**

| Test | What it verifies |
|------|-----------------|
| Renders formatted price | "€42.99" |
| Compare-at price with strikethrough | "~~€59.99~~ €42.99" |
| Currency symbol positioning | Locale-aware |
| Decimal places respected | "€42.90" not "€42.9" |
| Size variants | small/medium/large text |
| Zero price shows "Free" | Special case |
| a11y: announces full price | "42 euros and 99 cents" |
| Golden: all sizes with compare | Visual regression |

---

### OiQuantitySelector

**What it is:** A number stepper designed for product quantities. Minus button, display value, plus button. Compact and touch-friendly.

**Composes:** `OiRow`, `OiIconButton` (minus, plus), `OiLabel` (count), `OiSurface` (border wrapper)

```dart
OiQuantitySelector({
  required int value,
  required String label,
  ValueChanged<int>? onChange,
  int min = 1,
  int max = 99,
  bool compact = false,           // Smaller for cart rows
  bool disabled = false,
})
```

**Tests:**

| Test | What it verifies |
|------|-----------------|
| Displays current value | Number visible |
| Plus increments | onChange fires with value + 1 |
| Minus decrements | onChange fires with value - 1 |
| Min boundary disables minus | Button disabled at min |
| Max boundary disables plus | Button disabled at max |
| Compact variant smaller | Reduced padding/size |
| Disabled blocks interaction | Both buttons disabled |
| a11y: spinbutton role | Semantics |
| Keyboard: arrow up/down | Increment/decrement |

---

### OiProductCard

**What it is:** A product display card for grid/list layouts. Shows image, name, price, rating, and quick-action buttons.

**Composes:** `OiCard` (container), `OiImage` (product photo), `OiLabel` (name, description), `OiPriceTag`, `OiStarRating` (optional), `OiBadge` (sale, new, out of stock), `OiButton` (add to cart), `OiTappable` (click to detail)

```dart
OiProductCard({
  required OiProductData product,
  required String label,
  VoidCallback? onTap,
  VoidCallback? onAddToCart,
  VoidCallback? onWishlist,
  bool showRating = true,
  bool showAddToCart = true,
  bool showWishlist = false,
  OiProductCardVariant variant = OiProductCardVariant.vertical,
})

OiProductCard.horizontal({...}) // Image left, details right — for list views

enum OiProductCardVariant { vertical, horizontal, compact }
```

**Tests:**

| Test | What it verifies |
|------|-----------------|
| Image renders | Product image visible |
| Name renders | Product name text |
| Price tag renders | Formatted price |
| Compare-at price shows | Strikethrough price |
| Rating shows stars | OiStarRating visible |
| Out of stock badge | "Out of Stock" badge |
| Sale badge | "Sale" badge when compareAtPrice |
| Add to cart fires | onAddToCart callback |
| Card tap fires onTap | Navigation callback |
| Wishlist button fires | onWishlist callback |
| Horizontal variant | Image left layout |
| Compact variant | Minimal info |
| Skeleton loading | OiShimmer placeholder |
| a11y: card label | Product name + price |
| Golden: vertical, horizontal, compact | Visual regression |

---

### OiCartItemRow

**What it is:** A single line item in the shopping cart. Shows thumbnail, name, variant info, quantity selector, line total, and remove button.

**Composes:** `OiRow`, `OiImage` (thumbnail), `OiLabel` (name, variant), `OiQuantitySelector`, `OiPriceTag` (line total), `OiButton.ghost` (remove), `OiSwipeable` (swipe to remove on mobile)

```dart
OiCartItemRow({
  required OiCartItem item,
  required String label,
  ValueChanged<int>? onQuantityChange,
  VoidCallback? onRemove,
  VoidCallback? onTap,
  bool editable = true,           // false for order confirmation view
  bool compact = false,           // Smaller for mini-cart
  String currencyCode = 'EUR',
})
```

**Tests:**

| Test | What it verifies |
|------|-----------------|
| Thumbnail renders | Product image |
| Name and variant shown | "T-Shirt — Red / L" |
| Quantity selector works | onQuantityChange fires |
| Line total = unitPrice × quantity | Correct calculation |
| Remove button fires | onRemove callback |
| Swipe to remove on mobile | OiSwipeable behavior |
| Max quantity enforced | Selector capped |
| Compact variant smaller | Reduced layout |
| Non-editable hides controls | No selector, no remove |
| a11y: item description | Full item info announced |

---

### OiOrderSummaryLine

**What it is:** A single summary row (subtotal, discount, shipping, tax, total) with label on the left and amount on the right.

**Composes:** `OiRow`, `OiLabel`, `OiPriceTag`

```dart
OiOrderSummaryLine({
  required String label,
  required double amount,
  String? currencyCode,
  bool bold = false,              // true for total row
  bool negative = false,          // true for discounts (shows in green with minus)
  bool loading = false,           // Shimmer for shipping calculation
  String? subtitle,               // "SUMMER20" below discount label
})
```

---

### OiCouponInput

**What it is:** An input for applying discount/coupon codes. Text field with "Apply" button, shows success/error inline.

**Composes:** `OiRow`, `OiTextInput`, `OiButton`, `OiLabel` (result message), `OiIcon` (check/error)

```dart
OiCouponInput({
  required String label,
  required Future<OiCouponResult> Function(String code) onApply,
  VoidCallback? onRemove,
  String? appliedCode,
  bool loading = false,
})

class OiCouponResult {
  final bool valid;
  final String? message;          // "20% off applied!" or "Invalid code"
  final double? discountAmount;
}
```

**Tests:**

| Test | What it verifies |
|------|-----------------|
| Input + apply button render | Both visible |
| Submit fires onApply | Code passed |
| Loading state on button | Spinner |
| Valid code shows success | Green check + message |
| Invalid code shows error | Red message |
| Applied code shows with remove | Code visible + X button |
| Empty submit prevented | Button disabled when empty |
| a11y: input labeled | Semantics |

---

### OiAddressForm

**What it is:** A standardized address form with fields for name, company, address lines, city, state/province, postal code, country, and phone.

**Composes:** `OiColumn`, `OiRow`, `OiTextInput`, `OiSelect` (country, state), `OiForm`

```dart
OiAddressForm({
  required String label,
  OiAddressData? initialValue,
  ValueChanged<OiAddressData>? onChange,
  ValueChanged<OiAddressData>? onSubmit,
  List<OiCountryOption>? countries,
  bool showCompany = true,
  bool showPhone = true,
  bool showName = true,
  bool readOnly = false,
  String? error,
})

class OiCountryOption {
  final String code;              // "AT", "DE", "US"
  final String name;
  final List<String>? states;     // Sub-regions
}
```

**Tests:**

| Test | What it verifies |
|------|-----------------|
| All fields render | Name, address, city, etc. |
| Country select shows options | Dropdown with countries |
| State select appears for relevant countries | US, CA, AU |
| onChange fires on any field | Updated address |
| Validation: required fields | Error on empty submit |
| Read-only mode | All fields non-editable |
| Initial value populates | Fields pre-filled |
| a11y: address group | Semantics group |
| Responsive: two-column on wide | City + State side by side |
| Responsive: single column on narrow | Stacked |

---

### OiShippingMethodPicker

**What it is:** A radio-style selector for shipping methods showing label, price, and estimated delivery.

**Composes:** `OiColumn`, `OiRadio` (conceptual — each option is tappable), `OiSurface` (selected border), `OiTappable`, `OiLabel`, `OiPriceTag`, `OiIcon`

```dart
OiShippingMethodPicker({
  required List<OiShippingMethod> methods,
  required String label,
  Object? selectedKey,
  ValueChanged<OiShippingMethod>? onSelect,
  bool loading = false,
})
```

---

### OiPaymentMethodPicker

**What it is:** A selector for payment methods (credit card, PayPal, bank transfer, saved cards). Each option is a tappable card.

**Composes:** `OiColumn`, `OiTappable`, `OiSurface` (selected state), `OiLabel`, `OiIcon`, `OiImage` (logos)

```dart
OiPaymentMethodPicker({
  required List<OiPaymentMethod> methods,
  required String label,
  Object? selectedKey,
  ValueChanged<OiPaymentMethod>? onSelect,
  Widget? addNewCard,             // Slot for "Add new card" form/button
})
```

---

### OiOrderStatusBadge

**What it is:** A badge that displays order status with appropriate color coding.

**Composes:** `OiBadge`

```dart
OiOrderStatusBadge({
  required OiOrderStatus status,
  required String label,
  Map<OiOrderStatus, String>? statusLabels,   // i18n overrides
  Map<OiOrderStatus, Color>? statusColors,    // Theme overrides
})
```

**Default colors:** pending → warning, confirmed → info, processing → info, shipped → primary, delivered → success, cancelled → error, refunded → muted.

---

## Tier 3: Shop Composites

---

### OiCartPanel

**What it is:** The full shopping cart view — list of cart items, coupon input, and order summary. Used as the content of a side panel, a full page, or a sheet.

**Composes:** `OiColumn`, `OiVirtualList` or `OiColumn` (items), `OiCartItemRow` (each item), `OiDivider`, `OiCouponInput`, `OiOrderSummaryLine` (subtotal, discount, shipping, tax, total), `OiButton.primary` (checkout), `OiEmptyState` (empty cart)

```dart
OiCartPanel({
  required List<OiCartItem> items,
  required OiCartSummary summary,
  required String label,
  void Function(OiCartItem, int quantity)? onQuantityChange,
  ValueChanged<OiCartItem>? onRemove,
  Future<OiCouponResult> Function(String code)? onApplyCoupon,
  VoidCallback? onRemoveCoupon,
  String? appliedCouponCode,
  VoidCallback? onCheckout,
  VoidCallback? onContinueShopping,
  String checkoutLabel = 'Proceed to Checkout',
  String currencyCode = 'EUR',
  bool loading = false,
})
```

**Tests:**

| Test | What it verifies |
|------|-----------------|
| All items render | OiCartItemRow per item |
| Empty cart shows empty state | "Your cart is empty" |
| Quantity change fires | onQuantityChange callback |
| Remove item fires | onRemove callback |
| Coupon input works | onApplyCoupon fires |
| Summary lines render | Subtotal, tax, total |
| Checkout button fires | onCheckout callback |
| Continue shopping link | onContinueShopping |
| Loading state | Shimmer on summary |
| a11y: cart region | Semantics |
| Golden: full cart, empty cart | Visual regression |

---

### OiMiniCart

**What it is:** A compact cart widget — an icon button with badge count that opens a popover or sheet showing a condensed cart preview.

**Composes:** `OiIconButton` (cart icon with `OiBadge`), `OiPopover` or `OiSheet`, `OiColumn`, `OiCartItemRow` (compact variant), `OiPriceTag` (total), `OiButton` (view cart, checkout), `OiLabel`

```dart
OiMiniCart({
  required List<OiCartItem> items,
  required OiCartSummary summary,
  required String label,
  VoidCallback? onViewCart,
  VoidCallback? onCheckout,
  ValueChanged<OiCartItem>? onRemove,
  int maxVisibleItems = 3,
  OiMiniCartDisplay display = OiMiniCartDisplay.popover,
  String currencyCode = 'EUR',
})

enum OiMiniCartDisplay { popover, sheet }
```

**Tests:**

| Test | What it verifies |
|------|-----------------|
| Icon with badge count | Cart icon + number |
| Tap opens popover/sheet | Cart preview visible |
| Items shown (limited) | Max 3 items + "X more" |
| Total shown | Summary total |
| View cart button | onViewCart fires |
| Checkout button | onCheckout fires |
| Remove from mini cart | onRemove fires |
| Empty shows "Cart is empty" | Empty state |
| Badge hidden at 0 | No badge when empty |
| a11y: cart button | "Cart, 3 items" |

---

### OiOrderSummary

**What it is:** A complete order summary card showing all line items (subtotal, discount, shipping, tax, total) with optional expandable item list.

**Composes:** `OiCard`, `OiColumn`, `OiOrderSummaryLine`, `OiDivider`, `OiAccordion` (expandable items), `OiCartItemRow` (read-only), `OiLabel`

```dart
OiOrderSummary({
  required OiCartSummary summary,
  required String label,
  List<OiCartItem>? items,        // Expandable item list
  bool showItems = true,
  bool expandedByDefault = false,
  String currencyCode = 'EUR',
})
```

---

### OiProductGallery

**What it is:** A product image gallery with main image + thumbnail strip, zoom on hover, and lightbox on click.

**Composes:** `OiImage` (main), `OiRow` / `OiColumn` (thumbnails), `OiTappable` (thumbnail selection), `OiPinchZoom` (zoom), `OiLightbox` (fullscreen), `OiSwipeable` (mobile swipe between images)

```dart
OiProductGallery({
  required List<String> imageUrls,
  required String label,
  int initialIndex = 0,
  bool showThumbnails = true,
  bool zoomOnHover = true,
  bool lightboxOnTap = true,
  Axis thumbnailDirection = Axis.horizontal,
})
```

**Tests:**

| Test | What it verifies |
|------|-----------------|
| Main image renders | First image visible |
| Thumbnails render | All images as thumbnails |
| Thumbnail tap changes main | Image swaps |
| Zoom on hover | Magnified area follows cursor |
| Lightbox on click | Full-screen overlay |
| Swipe on mobile | OiSwipeable navigation |
| a11y: image labels | "Product image 1 of 5" |

---

### OiOrderTracker

**What it is:** A visual order status tracker showing the progression of an order through statuses (pending → confirmed → processing → shipped → delivered) as a horizontal stepper.

**Composes:** `OiStepper` / `OiProgress.steps`, `OiLabel`, `OiIcon`, `OiTimeline` (optional detailed view)

```dart
OiOrderTracker({
  required OiOrderStatus currentStatus,
  required String label,
  List<OiOrderEvent>? timeline,   // Detailed event history
  bool showTimeline = false,      // Expandable detailed view
  Map<OiOrderStatus, String>? statusLabels,
})
```

---

## Tier 4: Shop Modules

---

### OiCheckout

**What it is:** A complete multi-step checkout flow. Orchestrates address entry, shipping selection, payment selection, and order review as a wizard. The crown jewel of the shop module system.

**Composes:** `OiWizard` (step orchestration), `OiStepper` (progress indicator), `OiAddressForm` (shipping/billing), `OiShippingMethodPicker`, `OiPaymentMethodPicker`, `OiOrderSummary`, `OiCartItemRow` (review), `OiButton` (navigation), `OiCheckbox` ("same as shipping"), `OiForm` (each step is a form), `OiDialog` (payment confirmation)

```dart
OiCheckout({
  required List<OiCartItem> items,
  required OiCartSummary summary,
  required String label,
  // Step configuration:
  List<OiCheckoutStep> steps = const [
    OiCheckoutStep.address,
    OiCheckoutStep.shipping,
    OiCheckoutStep.payment,
    OiCheckoutStep.review,
  ],
  // Callbacks:
  ValueChanged<OiAddressData>? onShippingAddressChange,
  ValueChanged<OiAddressData>? onBillingAddressChange,
  ValueChanged<OiShippingMethod>? onShippingMethodChange,
  ValueChanged<OiPaymentMethod>? onPaymentMethodChange,
  Future<OiOrderData> Function(OiCheckoutData data)? onPlaceOrder,
  VoidCallback? onCancel,
  // Data:
  OiAddressData? initialShippingAddress,
  OiAddressData? initialBillingAddress,
  List<OiShippingMethod>? shippingMethods,
  List<OiPaymentMethod>? paymentMethods,
  List<OiCountryOption>? countries,
  // Display:
  bool showSummary = true,        // Persistent right column on desktop
  bool sameBillingDefault = true,
  String currencyCode = 'EUR',
  String placeOrderLabel = 'Place Order',
})

enum OiCheckoutStep { address, shipping, payment, review }

class OiCheckoutData {
  final OiAddressData shippingAddress;
  final OiAddressData billingAddress;
  final OiShippingMethod shippingMethod;
  final OiPaymentMethod paymentMethod;
}
```

**Layout:**
- **Desktop:** Two-column layout. Left = wizard steps (address → shipping → payment → review). Right = persistent OiOrderSummary card.
- **Mobile:** Single column. Order summary collapsible at top, wizard steps below.
- Each step is validated before advancing (via OiForm validation).
- Review step shows all selections as read-only with "Edit" links that jump back to the relevant step.

**Tests:**

| Test | What it verifies |
|------|-----------------|
| All steps render | Wizard shows 4 steps |
| Stepper shows progress | Current step highlighted |
| Address form validates | Required fields enforced |
| Shipping methods load | Options displayed |
| Shipping selection persists | Survives step changes |
| Payment methods load | Options displayed |
| Payment selection persists | Survives step changes |
| "Same as shipping" checkbox | Copies address |
| Review shows all selections | Address + shipping + payment |
| Edit links jump to step | Wizard navigates back |
| Place order fires callback | onPlaceOrder with full data |
| Loading state during submit | Button shows spinner |
| Error handling on submit | Error toast |
| Order summary visible (desktop) | Right column |
| Order summary collapsible (mobile) | Accordion at top |
| Cancel fires onCancel | Callback |
| Keyboard: Tab through steps | Focus management |
| a11y: wizard + form landmarks | Semantics |
| Golden: each step, desktop | Visual regression |
| Golden: each step, mobile | Visual regression |

---

### OiShopProductDetail

**What it is:** A complete product detail page layout. Shows gallery, title, price, description, variant selectors, quantity, add to cart, and related info.

**Composes:** `OiColumn` / `OiRow`, `OiProductGallery`, `OiLabel` (title, description), `OiPriceTag`, `OiStarRating`, `OiBadge` (tags, stock status), `OiSelect` (variant attributes), `OiQuantitySelector`, `OiButton.primary` (add to cart), `OiButton.outline` (wishlist), `OiAccordion` (description sections), `OiTabs` (reviews, specs)

```dart
OiShopProductDetail({
  required OiProductData product,
  required String label,
  VoidCallback? onAddToCart,
  ValueChanged<OiProductVariant>? onVariantChange,
  ValueChanged<int>? onQuantityChange,
  VoidCallback? onWishlist,
  OiProductVariant? selectedVariant,
  int quantity = 1,
  Widget? description,            // Rich description widget
  Widget? reviews,                // Reviews tab content
  Widget? specifications,         // Specs tab content
  List<OiProductData>? related,   // Related products grid
})
```

**Tests:**

| Test | What it verifies |
|------|-----------------|
| Gallery renders | Product images |
| Title and price show | Name + OiPriceTag |
| Variant selectors show | One OiSelect per attribute |
| Variant change updates price | OiPriceTag reflects variant |
| Variant change updates image | Gallery updates |
| Quantity selector works | onQuantityChange |
| Add to cart fires | onAddToCart |
| Out of stock disables button | "Out of Stock" shown |
| Description section | Content visible |
| Tabs for reviews/specs | OiTabs renders |
| Related products grid | OiProductCard grid |
| Responsive: side-by-side desktop | Gallery left, info right |
| Responsive: stacked mobile | Gallery top, info below |
| a11y: product details | Semantics |
| Golden: desktop, mobile | Visual regression |

---

# Part 4: Package Structure Additions

```
packages/
  obers_ui/
    lib/
      src/
        components/
          display/
            oi_field_display.dart          # NEW — Tier 2
            oi_pagination.dart             # NEW — Tier 2
          buttons/
            oi_export_button.dart          # NEW — Tier 2
            oi_sort_button.dart            # NEW — Tier 2
          inputs/
            oi_date_time_input.dart        # NEW — Tier 2
            oi_array_input.dart            # NEW — Tier 2
          feedback/
            oi_bulk_bar.dart               # NEW — Tier 2
          navigation/
            oi_user_menu.dart              # NEW — Tier 2
            oi_locale_switcher.dart         # NEW — Tier 2
            oi_theme_toggle.dart           # NEW — Tier 2

        composites/
          data/
            oi_detail_view.dart            # NEW — Tier 3
          navigation/
            oi_error_page.dart             # NEW — Tier 3
          shop/
            oi_cart_panel.dart             # NEW — Tier 3
            oi_mini_cart.dart              # NEW — Tier 3
            oi_order_summary.dart          # NEW — Tier 3
            oi_product_gallery.dart        # NEW — Tier 3
            oi_order_tracker.dart          # NEW — Tier 3

        modules/
          oi_app_shell.dart                # NEW — Tier 4
          oi_resource_page.dart            # NEW — Tier 4 (wraps list/show/edit/create)
          oi_auth_page.dart                # NEW — Tier 4
          oi_checkout.dart                 # NEW — Tier 4
          oi_shop_product_detail.dart      # NEW — Tier 4

        components/shop/
          oi_price_tag.dart                # NEW — Tier 2
          oi_quantity_selector.dart         # NEW — Tier 2
          oi_product_card.dart             # NEW — Tier 2
          oi_cart_item_row.dart            # NEW — Tier 2
          oi_order_summary_line.dart       # NEW — Tier 2
          oi_coupon_input.dart             # NEW — Tier 2
          oi_address_form.dart             # NEW — Tier 2
          oi_shipping_method_picker.dart   # NEW — Tier 2
          oi_payment_method_picker.dart    # NEW — Tier 2
          oi_order_status_badge.dart       # NEW — Tier 2

        models/
          oi_product_data.dart             # NEW
          oi_cart_item.dart                # NEW
          oi_cart_summary.dart             # NEW
          oi_shipping_method.dart          # NEW
          oi_payment_method.dart           # NEW
          oi_address_data.dart             # NEW
          oi_order_data.dart               # NEW
```

---

# Part 5: Composition Map Additions

```
OiFieldDisplay (read-only field renderer)
 ├── OiDetailView (renders multiple OiFieldDisplay.pair in sections)
 ├── OiResourcePage.show (uses OiDetailView for record detail)
 └── OiCartItemRow (uses OiFieldDisplay internally for variant info)

OiPagination (standalone pagination)
 ├── OiTable (uses internally — now extracted)
 ├── OiResourcePage.list (bottom pagination)
 └── OiListView (uses for list pagination)

OiBulkBar (selection action toolbar)
 ├── OiTable (via bulkActions prop)
 └── OiListView (via bulkActions prop)

OiArrayInput (repeatable field groups)
 ├── OiForm (embedded as a form field)
 └── OiCheckout (address lines, multiple items)

OiUserMenu
 └── OiAppShell (top bar, right side)

OiThemeToggle
 └── OiAppShell (top bar action slot)

OiLocaleSwitcher
 └── OiAppShell (top bar action slot)

OiPriceTag
 ├── OiProductCard
 ├── OiCartItemRow (line total)
 ├── OiOrderSummaryLine
 ├── OiMiniCart (total)
 └── OiShopProductDetail

OiQuantitySelector
 ├── OiCartItemRow
 └── OiShopProductDetail

OiProductCard
 ├── OiShopProductDetail (related products grid)
 └── App-level product grids

OiCartItemRow
 ├── OiCartPanel
 ├── OiMiniCart
 └── OiCheckout (review step)

OiOrderSummaryLine
 ├── OiCartPanel
 ├── OiOrderSummary
 └── OiCheckout (summary column)

OiAddressForm
 └── OiCheckout (shipping/billing steps)

OiShippingMethodPicker
 └── OiCheckout (shipping step)

OiPaymentMethodPicker
 └── OiCheckout (payment step)

OiOrderTracker
 └── App-level order detail pages

OiAppShell
 └── Wraps entire admin application

OiResourcePage
 ├── OiResourcePage.list (table + filters + pagination)
 ├── OiResourcePage.show (detail view + actions)
 ├── OiResourcePage.edit (form + save/cancel)
 └── OiResourcePage.create (form + save/cancel)

OiAuthPage
 ├── OiAuthPage.login
 ├── OiAuthPage.register
 ├── OiAuthPage.forgotPassword
 └── OiAuthPage.resetPassword

OiCheckout
 └── OiWizard (address → shipping → payment → review)
      ├── Step 1: OiAddressForm
      ├── Step 2: OiShippingMethodPicker
      ├── Step 3: OiPaymentMethodPicker
      └── Step 4: OiOrderSummary + OiCartItemRow (read-only)
```

---

# Part 6: Theme Extensions

New `OiComponentThemes` entries for the new components:

```dart
class OiComponentThemes {
  // ...existing entries...

  // Admin components
  final OiFieldDisplayThemeData? fieldDisplay;
  final OiPaginationThemeData? pagination;
  final OiBulkBarThemeData? bulkBar;
  final OiUserMenuThemeData? userMenu;
  final OiAppShellThemeData? appShell;
  final OiResourcePageThemeData? resourcePage;
  final OiAuthPageThemeData? authPage;

  // Shop components
  final OiPriceTagThemeData? priceTag;
  final OiQuantitySelectorThemeData? quantitySelector;
  final OiProductCardThemeData? productCard;
  final OiCartItemRowThemeData? cartItemRow;
  final OiCartPanelThemeData? cartPanel;
  final OiCheckoutThemeData? checkout;
}
```

Each theme data class follows the established pattern:

```dart
// Example: OiPriceTagThemeData
class OiPriceTagThemeData {
  final TextStyle? priceStyle;
  final TextStyle? compareAtStyle;
  final Color? discountColor;
  final Color? compareAtColor;

  const OiPriceTagThemeData({
    this.priceStyle,
    this.compareAtStyle,
    this.discountColor,
    this.compareAtColor,
  });

  OiPriceTagThemeData copyWith({...});
  OiPriceTagThemeData merge(OiPriceTagThemeData? other);
}

// Example: OiAppShellThemeData
class OiAppShellThemeData {
  final Color? sidebarBackground;
  final Color? topBarBackground;
  final double? sidebarWidth;
  final double? sidebarCollapsedWidth;
  final double? topBarHeight;
  final List<BoxShadow>? topBarShadow;
  final OiBorderStyle? sidebarBorder;

  const OiAppShellThemeData({...});
  OiAppShellThemeData copyWith({...});
  OiAppShellThemeData merge(OiAppShellThemeData? other);
}
```

All theme data classes support `copyWith` and `merge` for composition, and are scoped via `OiXxxThemeScope` widgets per the base concept pattern.

---

# Summary

## Total New Components: 29

| Tier | Count | Components |
|------|-------|------------|
| Tier 2 (Components) | 19 | OiFieldDisplay, OiPagination, OiBulkBar, OiSortButton, OiExportButton, OiDateTimeInput, OiArrayInput, OiThemeToggle, OiUserMenu, OiLocaleSwitcher, OiPriceTag, OiQuantitySelector, OiProductCard, OiCartItemRow, OiOrderSummaryLine, OiCouponInput, OiAddressForm, OiShippingMethodPicker, OiPaymentMethodPicker, OiOrderStatusBadge |
| Tier 3 (Composites) | 6 | OiDetailView, OiErrorPage, OiCartPanel, OiMiniCart, OiOrderSummary, OiProductGallery, OiOrderTracker |
| Tier 4 (Modules) | 5 | OiAppShell, OiResourcePage, OiAuthPage, OiCheckout, OiShopProductDetail |

## Extensions to Existing: 4

- OiTagInput: `suggestions`, `asyncSuggestions`, `allowCustomTags`
- OiTable: `bulkActions` prop → OiBulkBar integration
- OiEmptyState: `.notFound()`, `.forbidden()`, `.error()` factories
- OiForm: `onSubmitAsync`, `onCancel`, `warnOnUnsavedChanges`

---

End of specification.
