# obers_ui — Missing Implementation from admin_shop_gap_analysis_spec.md

> **Date:** 2026-03-22
> **Source Spec:** `concept/admin_shop_gap_analysis_spec.md`
> **Purpose:** Complete list of unimplemented items from the spec, with full details for AI code generation.

---

## Implementation Status Overview

The spec defines 29 new components + 4 extensions. **24 components and all 4 extensions are fully implemented.** This document covers the **5 missing widgets**, **3 missing model tests**, **missing exports**, and **missing documentation updates**.

### Already Implemented (DO NOT recreate)

All admin-kit Tier 2 (OiFieldDisplay, OiPagination, OiBulkBar, OiSortButton, OiExportButton, OiDateTimeInput, OiArrayInput, OiThemeToggle, OiUserMenu, OiLocaleSwitcher), all shop Tier 2 components (OiPriceTag, OiQuantitySelector, OiProductCard, OiCartItemRow, OiOrderSummaryLine, OiCouponInput, OiPaymentOption, OiShippingOption, OiStockBadge, OiWishlistButton), admin composites (OiDetailView, OiErrorPage), shop composites (OiCartPanel, OiMiniCart, OiOrderSummary, OiProductGallery, OiProductFilters), all modules (OiAppShell, OiResourcePage, OiAuthPage, OiCheckout, OiShopProductDetail), all extensions (OiTagInput suggestions, OiTable bulkActions, OiEmptyState factories, OiForm onCancel/dirtyDetection), and all data models.

---

## Table of Contents

1. [Missing Widget 1: OiAddressForm](#1-oiaddressform)
2. [Missing Widget 2: OiShippingMethodPicker](#2-oishippingmethodpicker)
3. [Missing Widget 3: OiPaymentMethodPicker](#3-oipaymentmethodpicker)
4. [Missing Widget 4: OiOrderStatusBadge](#4-oiorderstatusbadge)
5. [Missing Widget 5: OiOrderTracker](#5-oiordertracker)
6. [Missing Model Tests](#6-missing-model-tests)
7. [Missing Barrel Exports](#7-missing-barrel-exports)
8. [Missing Documentation Updates](#8-missing-documentation-updates)

---

## 1. OiAddressForm

### Overview

**Tier:** 2 (Component)
**Category:** Shop
**File:** `lib/src/components/shop/oi_address_form.dart`
**Test:** `test/src/components/shop/oi_address_form_test.dart`

A standardized, reusable address form with fields for name, company, address lines, city, state/province, postal code, country, and phone. Currently, the `OiCheckout` module builds address forms inline with raw `OiTextInput` + `OiSelect` widgets and manual `TextEditingController` management (see `lib/src/modules/oi_checkout.dart` lines 166–229). This widget extracts that pattern into a standalone reusable component.

### Existing Dependencies (already implemented — reuse these)

- `OiColumn` — `lib/src/primitives/layout/oi_column.dart` (layout)
- `OiRow` — `lib/src/primitives/layout/oi_row.dart` (side-by-side fields)
- `OiTextInput` — `lib/src/components/inputs/oi_text_input.dart` (text fields)
- `OiSelect` — `lib/src/components/inputs/oi_select.dart` (country/state dropdowns)
- `OiLabel` — `lib/src/primitives/display/oi_label.dart` (section labels)
- `OiAddressData` — `lib/src/models/oi_address_data.dart` (data model)
- `OiCountryOption` — `lib/src/models/oi_country_option.dart` (country model)
- `OiResponsive` — `lib/src/foundation/oi_responsive.dart` (responsive layout)
- `OiTheme` — `lib/src/foundation/theme/oi_theme.dart` (theming via `context.spacing`, `context.colors`, `context.breakpoint`)

### API Specification

```dart
import 'package:flutter/widgets.dart';

/// A standardized address form with name, company, address lines, city,
/// state/province, postal code, country, and phone fields.
///
/// Coverage: REQ-0006, REQ-0014
///
/// Composes [OiColumn], [OiRow], [OiTextInput], [OiSelect].
///
/// {@category Components}
class OiAddressForm extends StatefulWidget {
  const OiAddressForm({
    required this.label,
    this.initialValue,
    this.onChange,
    this.onSubmit,
    this.countries,
    this.showCompany = true,
    this.showPhone = true,
    this.showName = true,
    this.readOnly = false,
    this.error,
    super.key,
  });

  /// Accessibility label announced by screen readers.
  final String label;

  /// Initial address to pre-fill fields with.
  final OiAddressData? initialValue;

  /// Called whenever any field changes, with the updated address.
  final ValueChanged<OiAddressData>? onChange;

  /// Called when the form is submitted (e.g. via keyboard action).
  final ValueChanged<OiAddressData>? onSubmit;

  /// Country options for the country selector dropdown.
  /// When provided, the country field renders as an OiSelect populated
  /// from these options. When a selected country has `states`, a state
  /// dropdown appears automatically.
  final List<OiCountryOption>? countries;

  /// Whether to show the company field. Defaults to true.
  final bool showCompany;

  /// Whether to show the phone field. Defaults to true.
  final bool showPhone;

  /// Whether to show first/last name fields. Defaults to true.
  final bool showName;

  /// Whether all fields are read-only. Defaults to false.
  final bool readOnly;

  /// Error message displayed below the form.
  final String? error;
}
```

### Implementation Details

- **StatefulWidget** — manages `TextEditingController` instances for each field internally (like OiCheckout does at lines 166–228), synchronizing them with `OiAddressData` via `onChange`.
- **Responsive layout:**
  - On wide breakpoints (≥ `OiBreakpoint.md`): First name + Last name side by side in `OiRow`, City + State side by side, Postal code + Country side by side.
  - On narrow breakpoints (< `OiBreakpoint.md`): All fields stacked vertically in `OiColumn`.
- **Country dropdown:** When `countries` is provided, render country as `OiSelect` with `OiCountryOption.name` as label and `.code` as value. When a selected country has non-null `states`, show a state `OiSelect` dropdown instead of a text input for the state field.
- **Field order:** First name, Last name, Company (optional), Address line 1, Address line 2, City, State, Postal code, Country, Phone (optional).
- **Validation:** Required fields (line1, city, postalCode, country) show error styling on empty when a parent form triggers validation. Use the same validation pattern as OiCheckout lines 306–354.
- **Read-only mode:** When `readOnly = true`, all fields render with `readOnly: true` on `OiTextInput` and `disabled: true` on `OiSelect`.
- **`onChange` fires** on every field change, constructing a new `OiAddressData` from current field values (mirroring `_syncShippingAddress()` pattern at OiCheckout line 258).

### Test Scenarios

| # | Test | What it verifies |
|---|------|-----------------|
| 1 | All default fields render | firstName, lastName, line1, line2, city, state, postalCode, country, phone inputs visible |
| 2 | showName=false hides name fields | firstName + lastName not rendered |
| 3 | showCompany=false hides company | Company field not rendered |
| 4 | showPhone=false hides phone | Phone field not rendered |
| 5 | Country select shows options | OiSelect dropdown with OiCountryOption names |
| 6 | State dropdown appears for country with states | e.g., select "US" → state dropdown appears with state names |
| 7 | State reverts to text input for country without states | e.g., select "DE" → state is OiTextInput |
| 8 | onChange fires on any field change | Updated OiAddressData passed with correct values |
| 9 | initialValue populates fields | All fields show pre-filled data |
| 10 | readOnly mode disables all fields | All inputs non-editable |
| 11 | Validation: required fields show errors on empty | line1, city, postalCode, country show error |
| 12 | Error message displays below form | error text visible |
| 13 | Responsive: two-column on wide | firstName+lastName side by side |
| 14 | Responsive: single column on narrow | All fields stacked |
| 15 | a11y: form group with label | Semantics group with label |
| 16 | Golden: default form, pre-filled form | Visual regression |

---

## 2. OiShippingMethodPicker

### Overview

**Tier:** 2 (Component)
**Category:** Shop
**File:** `lib/src/components/shop/oi_shipping_method_picker.dart`
**Test:** `test/src/components/shop/oi_shipping_method_picker_test.dart`

A radio-style selector that renders a list of `OiShippingOption` widgets with managed selection state. The `OiShippingOption` component already exists (`lib/src/components/shop/oi_shipping_option.dart`) and renders a single selectable row — this picker wraps multiple options into a group with proper radio-group semantics.

### Existing Dependencies (already implemented — reuse these)

- `OiShippingOption` — `lib/src/components/shop/oi_shipping_option.dart` (individual option row)
- `OiShippingMethod` — `lib/src/models/oi_shipping_method.dart` (data model)
- `OiColumn` — `lib/src/primitives/layout/oi_column.dart` (layout)
- `OiLabel` — `lib/src/primitives/display/oi_label.dart` (group label)
- `OiShimmer` — `lib/src/primitives/feedback/oi_shimmer.dart` (loading state)
- `OiResponsive` — `lib/src/foundation/oi_responsive.dart`
- `OiTheme` — `lib/src/foundation/theme/oi_theme.dart`

### API Specification

```dart
/// A radio-style selector for shipping methods.
///
/// Renders a list of [OiShippingOption] widgets with managed single-selection.
/// Displays label, price, and estimated delivery for each method.
///
/// Coverage: REQ-0014, REQ-0067
///
/// Composes [OiColumn], [OiShippingOption], [OiLabel].
///
/// {@category Components}
class OiShippingMethodPicker extends StatelessWidget {
  const OiShippingMethodPicker({
    required this.methods,
    required this.label,
    this.selectedKey,
    this.onSelect,
    this.currencyCode = 'EUR',
    this.loading = false,
    super.key,
  });

  /// Available shipping methods to display.
  final List<OiShippingMethod> methods;

  /// Accessibility label for the group.
  final String label;

  /// The `key` of the currently selected shipping method.
  final Object? selectedKey;

  /// Called when the user selects a shipping method.
  final ValueChanged<OiShippingMethod>? onSelect;

  /// ISO 4217 currency code for price formatting. Defaults to 'EUR'.
  final String currencyCode;

  /// Whether to show shimmer loading placeholders. Defaults to false.
  final bool loading;
}
```

### Implementation Details

- **StatelessWidget** — selection state is managed externally (parent passes `selectedKey`, receives `onSelect`).
- **Renders:** `Semantics` wrapper with `label`, then `OiColumn` with `gap: OiResponsive(context.spacing.xs)` containing one `OiShippingOption` per method.
- **Selection:** Each `OiShippingOption` gets `selected: method.key == selectedKey` and `onSelect: onSelect != null ? (_) => onSelect!(method) : null`.
- **Loading state:** When `loading = true`, show 3 shimmer placeholder rows (use `OiShimmer` with the same height as an `OiShippingOption` row). Hide actual methods.
- **Empty state:** If `methods` is empty and not loading, show nothing (or a subtle "No shipping methods available" via `OiLabel.bodySmall`).
- **Forward `currencyCode`** to each `OiShippingOption`.

### Test Scenarios

| # | Test | What it verifies |
|---|------|-----------------|
| 1 | All methods render | One OiShippingOption per method |
| 2 | Selected method highlighted | OiShippingOption with matching key has `selected: true` |
| 3 | Tapping unselected method fires onSelect | Correct OiShippingMethod passed |
| 4 | Loading shows shimmer placeholders | 3 shimmer rows visible, methods hidden |
| 5 | Empty methods shows no items | Empty or "no methods" text |
| 6 | currencyCode forwarded | Price formatted with correct currency |
| 7 | a11y: radio group semantics | Semantics label wraps group |
| 8 | Golden: 3 methods with one selected | Visual regression |

---

## 3. OiPaymentMethodPicker

### Overview

**Tier:** 2 (Component)
**Category:** Shop
**File:** `lib/src/components/shop/oi_payment_method_picker.dart`
**Test:** `test/src/components/shop/oi_payment_method_picker_test.dart`

A selector for payment methods that renders a list of `OiPaymentOption` widgets with managed single-selection, plus an optional slot for an "Add new card" button or form.

### Existing Dependencies (already implemented — reuse these)

- `OiPaymentOption` — `lib/src/components/shop/oi_payment_option.dart` (individual option row)
- `OiPaymentMethod` — `lib/src/models/oi_payment_method.dart` (data model)
- `OiColumn` — `lib/src/primitives/layout/oi_column.dart` (layout)
- `OiLabel` — `lib/src/primitives/display/oi_label.dart` (group label)
- `OiDivider` — `lib/src/primitives/display/oi_divider.dart` (separator before addNewCard)
- `OiResponsive` — `lib/src/foundation/oi_responsive.dart`
- `OiTheme` — `lib/src/foundation/theme/oi_theme.dart`

### API Specification

```dart
/// A selector for payment methods (credit card, PayPal, bank transfer, etc.).
///
/// Renders a list of [OiPaymentOption] widgets with managed single-selection.
/// Optionally shows an "Add new card" slot below the options.
///
/// Coverage: REQ-0014, REQ-0067
///
/// Composes [OiColumn], [OiPaymentOption], [OiLabel], [OiDivider].
///
/// {@category Components}
class OiPaymentMethodPicker extends StatelessWidget {
  const OiPaymentMethodPicker({
    required this.methods,
    required this.label,
    this.selectedKey,
    this.onSelect,
    this.addNewCard,
    super.key,
  });

  /// Available payment methods to display.
  final List<OiPaymentMethod> methods;

  /// Accessibility label for the group.
  final String label;

  /// The `key` of the currently selected payment method.
  final Object? selectedKey;

  /// Called when the user selects a payment method.
  final ValueChanged<OiPaymentMethod>? onSelect;

  /// Optional widget displayed below the payment options, separated by a
  /// divider. Typically an "Add new card" button or inline card form.
  final Widget? addNewCard;
}
```

### Implementation Details

- **StatelessWidget** — selection managed externally.
- **Renders:** `Semantics` wrapper with `label`, then `OiColumn` with `gap: OiResponsive(context.spacing.xs)` containing:
  1. One `OiPaymentOption` per method with `selected: method.key == selectedKey`.
  2. If `addNewCard != null`: `OiDivider()` + the `addNewCard` widget.
- **Default selection from `isDefault`:** The parent is responsible for passing `selectedKey`. However, the `OiPaymentMethod` model has an `isDefault` field — the `OiCheckout` module already handles pre-selecting the default at line 200.
- **Empty state:** If `methods` is empty, show only the `addNewCard` slot (if provided).

### Test Scenarios

| # | Test | What it verifies |
|---|------|-----------------|
| 1 | All methods render | One OiPaymentOption per method |
| 2 | Selected method highlighted | OiPaymentOption with matching key has `selected: true` |
| 3 | Tapping unselected method fires onSelect | Correct OiPaymentMethod passed |
| 4 | addNewCard slot renders below divider | Widget visible after OiDivider |
| 5 | addNewCard absent: no divider | Clean layout with options only |
| 6 | Empty methods with addNewCard | Only addNewCard widget shown |
| 7 | a11y: radio group semantics | Semantics label wraps group |
| 8 | Keyboard: arrow keys navigate options | Focus moves between options |
| 9 | Golden: 3 methods with one selected + addNewCard | Visual regression |

---

## 4. OiOrderStatusBadge

### Overview

**Tier:** 2 (Component)
**Category:** Shop
**File:** `lib/src/components/shop/oi_order_status_badge.dart`
**Test:** `test/src/components/shop/oi_order_status_badge_test.dart`

A badge that displays order status with appropriate color coding. Wraps `OiBadge` with a default color mapping for each `OiOrderStatus` value.

### Existing Dependencies (already implemented — reuse these)

- `OiBadge` — `lib/src/components/display/oi_badge.dart` (the underlying badge widget)
- `OiOrderStatus` enum — `lib/src/models/oi_order_data.dart` (status values: pending, confirmed, processing, shipped, delivered, cancelled, refunded)
- `OiTheme` — `lib/src/foundation/theme/oi_theme.dart` (for `context.colors`)

### API Specification

```dart
/// A badge that displays [OiOrderStatus] with appropriate color coding.
///
/// Coverage: REQ-0071
///
/// Default color mapping:
/// - pending → warning
/// - confirmed → info
/// - processing → info
/// - shipped → primary
/// - delivered → success
/// - cancelled → error
/// - refunded → muted
///
/// Composes [OiBadge].
///
/// {@category Components}
class OiOrderStatusBadge extends StatelessWidget {
  const OiOrderStatusBadge({
    required this.status,
    required this.label,
    this.statusLabels,
    this.statusColors,
    super.key,
  });

  /// The order status to display.
  final OiOrderStatus status;

  /// Accessibility label announced by screen readers.
  final String label;

  /// Optional i18n overrides for status display text.
  /// Keys are OiOrderStatus values, values are display strings.
  /// Defaults: pending→"Pending", confirmed→"Confirmed", etc. (title case).
  final Map<OiOrderStatus, String>? statusLabels;

  /// Optional color overrides per status.
  /// When null, uses the default color mapping from the theme.
  final Map<OiOrderStatus, Color>? statusColors;
}
```

### Implementation Details

- **StatelessWidget** — pure rendering.
- **Default label mapping:**
  ```dart
  static const _defaultLabels = {
    OiOrderStatus.pending: 'Pending',
    OiOrderStatus.confirmed: 'Confirmed',
    OiOrderStatus.processing: 'Processing',
    OiOrderStatus.shipped: 'Shipped',
    OiOrderStatus.delivered: 'Delivered',
    OiOrderStatus.cancelled: 'Cancelled',
    OiOrderStatus.refunded: 'Refunded',
  };
  ```
- **Default color mapping** uses `context.colors`:
  ```dart
  Color _resolveColor(BuildContext context) {
    if (statusColors != null && statusColors!.containsKey(status)) {
      return statusColors![status]!;
    }
    final colors = context.colors;
    return switch (status) {
      OiOrderStatus.pending => colors.warning,
      OiOrderStatus.confirmed => colors.info,
      OiOrderStatus.processing => colors.info,
      OiOrderStatus.shipped => colors.primary,
      OiOrderStatus.delivered => colors.success,
      OiOrderStatus.cancelled => colors.error,
      OiOrderStatus.refunded => colors.muted,
    };
  }
  ```
- **Renders:** `OiBadge.soft(label: displayLabel, color: resolvedColor)` wrapped in `Semantics(label: label)`.
  - Check OiBadge API — use the appropriate factory. `OiBadge.soft()` is the typical choice for status badges. If `OiBadge.soft` doesn't accept a `color` directly, use the factory that supports color customization.
- **Display text:** `statusLabels?[status] ?? _defaultLabels[status]!`

### Test Scenarios

| # | Test | What it verifies |
|---|------|-----------------|
| 1 | Each status renders correct default label | "Pending", "Confirmed", etc. |
| 2 | Each status uses correct default color | warning for pending, success for delivered, etc. |
| 3 | Custom statusLabels override text | e.g., pending → "Ausstehend" |
| 4 | Custom statusColors override color | Custom color used instead of default |
| 5 | a11y: label announced | Semantics label present |
| 6 | Golden: all 7 statuses | Visual regression showing all color variants |

---

## 5. OiOrderTracker

### Overview

**Tier:** 3 (Composite)
**Category:** Shop
**File:** `lib/src/composites/shop/oi_order_tracker.dart`
**Test:** `test/src/composites/shop/oi_order_tracker_test.dart`

A visual order status tracker showing the progression of an order through statuses as a horizontal stepper. Optionally shows a detailed timeline of events.

### Existing Dependencies (already implemented — reuse these)

- `OiStepper` — `lib/src/composites/forms/oi_stepper.dart` (step progress indicator)
- `OiOrderStatus` enum — `lib/src/models/oi_order_data.dart`
- `OiOrderEvent` class — `lib/src/models/oi_order_data.dart`
- `OiOrderStatusBadge` — the widget from section 4 above (NEW — implement section 4 first)
- `OiLabel` — `lib/src/primitives/display/oi_label.dart`
- `OiColumn` — `lib/src/primitives/layout/oi_column.dart`
- `OiRow` — `lib/src/primitives/layout/oi_row.dart`
- `OiIcon` — `lib/src/primitives/display/oi_icon.dart`
- `OiAccordion` — `lib/src/components/navigation/oi_accordion.dart` (expandable timeline)
- `OiDivider` — `lib/src/primitives/display/oi_divider.dart`
- `OiTheme` — `lib/src/foundation/theme/oi_theme.dart`
- `OiResponsive` — `lib/src/foundation/oi_responsive.dart`

### API Specification

```dart
/// A visual order status tracker showing order progression as a horizontal
/// stepper with optional detailed event timeline.
///
/// Coverage: REQ-0071
///
/// The tracker shows the standard order flow: pending → confirmed → processing
/// → shipped → delivered. Cancelled and refunded statuses are displayed as
/// terminal states with appropriate styling.
///
/// Composes [OiStepper], [OiLabel], [OiIcon], [OiColumn], [OiAccordion].
///
/// {@category Composites}
class OiOrderTracker extends StatelessWidget {
  const OiOrderTracker({
    required this.currentStatus,
    required this.label,
    this.timeline,
    this.showTimeline = false,
    this.statusLabels,
    super.key,
  });

  /// The current order status.
  final OiOrderStatus currentStatus;

  /// Accessibility label announced by screen readers.
  final String label;

  /// Optional list of order events for the detailed timeline view.
  final List<OiOrderEvent>? timeline;

  /// Whether to show the expandable detailed timeline below the stepper.
  /// Defaults to false.
  final bool showTimeline;

  /// Optional i18n overrides for status display text in the stepper steps.
  final Map<OiOrderStatus, String>? statusLabels;
}
```

### Implementation Details

- **Standard flow steps:** `[pending, confirmed, processing, shipped, delivered]` — these are the 5 steps shown in the stepper.
- **Step completion logic:** All steps up to and including the `currentStatus` are marked as completed. Steps after are incomplete.
  - Example: `currentStatus = OiOrderStatus.shipped` → pending ✓, confirmed ✓, processing ✓, shipped ✓ (current), delivered ○.
- **Terminal statuses (cancelled, refunded):** When `currentStatus` is `cancelled` or `refunded`, show the last reached step in the normal flow as the terminal point, with an `OiOrderStatusBadge` showing the terminal status below the stepper.
- **Stepper integration:** Use `OiStepper` (check its API in `lib/src/composites/forms/oi_stepper.dart`). Each step gets a label from `statusLabels` or the default title-case name.
- **Timeline section:** When `showTimeline = true` and `timeline` is not null:
  - Render an `OiAccordion` below the stepper with title "Order History" or similar.
  - Inside, render each `OiOrderEvent` as a row: timestamp (formatted via `intl` or manual formatting), title, optional description.
  - Events should be sorted newest-first.
  - Each event row: `OiRow` with a small colored dot (status color), `OiColumn` with title as `OiLabel.bodyStrong` and timestamp + description as `OiLabel.bodySmall`.
  - Use vertical line connectors between events (timeline visual pattern).
- **Responsive:** On narrow breakpoints, the stepper may need to be vertical instead of horizontal. Check `OiStepper` for an `axis` or `direction` parameter.

### Test Scenarios

| # | Test | What it verifies |
|---|------|-----------------|
| 1 | All 5 standard steps render | pending through delivered visible |
| 2 | Steps up to currentStatus are completed | Correct visual completion |
| 3 | Current step is highlighted | Active step styling |
| 4 | Steps after current are incomplete | Unfilled/grey |
| 5 | Cancelled status shows terminal badge | OiOrderStatusBadge with "Cancelled" |
| 6 | Refunded status shows terminal badge | OiOrderStatusBadge with "Refunded" |
| 7 | Custom statusLabels override step text | Custom labels shown |
| 8 | showTimeline=true renders accordion | "Order History" expandable section |
| 9 | Timeline events render in order | Newest first with timestamps |
| 10 | Timeline event shows title + description | Both text elements visible |
| 11 | showTimeline=false hides timeline | No accordion |
| 12 | Empty timeline with showTimeline=true | No events, accordion empty or hidden |
| 13 | a11y: tracker labeled | Semantics label present |
| 14 | Golden: delivered status with timeline | Visual regression |
| 15 | Golden: shipped status without timeline | Visual regression |

---

## 6. Missing Model Tests

The following models exist but lack corresponding test files. Tests should follow the pattern established in existing model tests (e.g., `test/src/models/oi_cart_item_test.dart`).

### 6a. OiCouponResult Test

**Model file:** `lib/src/models/oi_coupon_result.dart`
**Test file to create:** `test/src/models/oi_coupon_result_test.dart`

Read the model file to see its fields: `valid` (bool), `message` (String?), `discountAmount` (double?).

| # | Test | What it verifies |
|---|------|-----------------|
| 1 | Constructor sets all fields | valid, message, discountAmount |
| 2 | copyWith replaces fields | Each field independently |
| 3 | copyWith preserves unset fields | Original values retained |
| 4 | Equality: same values are equal | == returns true |
| 5 | Equality: different values not equal | == returns false |
| 6 | hashCode: equal objects same hash | Consistent hashing |
| 7 | toString includes all fields | String contains field values |
| 8 | Null optional fields | message and discountAmount can be null |

### 6b. OiCheckoutData Test

**Model file:** `lib/src/models/oi_checkout_data.dart`
**Test file to create:** `test/src/models/oi_checkout_data_test.dart`

Fields: `shippingAddress` (OiAddressData), `billingAddress` (OiAddressData), `shippingMethod` (OiShippingMethod), `paymentMethod` (OiPaymentMethod).

| # | Test | What it verifies |
|---|------|-----------------|
| 1 | Constructor sets all required fields | All 4 fields set |
| 2 | copyWith replaces fields | Each field independently |
| 3 | copyWith preserves unset fields | Original values retained |
| 4 | Equality: same values are equal | == returns true |
| 5 | Equality: different values not equal | == returns false |
| 6 | hashCode: equal objects same hash | Consistent hashing |
| 7 | toString includes all fields | String contains field values |

### 6c. OiCountryOption Test

**Model file:** `lib/src/models/oi_country_option.dart`
**Test file to create:** `test/src/models/oi_country_option_test.dart`

Fields: `code` (String), `name` (String), `states` (List<String>?).

| # | Test | What it verifies |
|---|------|-----------------|
| 1 | Constructor sets all fields | code, name, states |
| 2 | copyWith replaces fields | Each field independently |
| 3 | copyWith with explicit null for states | States set to null |
| 4 | copyWith preserves unset fields | Original values retained |
| 5 | Equality: same values are equal | == returns true |
| 6 | Equality: different values not equal | == returns false |
| 7 | Equality: different states lists not equal | Deep list comparison |
| 8 | hashCode: equal objects same hash | Consistent hashing |
| 9 | toString includes all fields | String contains field values |
| 10 | Null states field | states can be null |

---

## 7. Missing Barrel Exports

**File to update:** `lib/obers_ui.dart`

Add the following exports in the appropriate sections (maintain alphabetical order within each section):

### Shop Components section (after existing shop component exports ~lines 113–124):

```dart
export 'src/components/shop/oi_address_form.dart';
export 'src/components/shop/oi_order_status_badge.dart';
export 'src/components/shop/oi_payment_method_picker.dart';
export 'src/components/shop/oi_shipping_method_picker.dart';
```

### Shop Composites section (after existing shop composite exports ~lines 177–183):

```dart
export 'src/composites/shop/oi_order_tracker.dart';
```

### Models section (check if OiCheckoutData and OiCountryOption are exported — add if not):

```dart
export 'src/models/oi_checkout_data.dart';   // verify — may already exist
export 'src/models/oi_country_option.dart';  // verify — may already exist
```

---

## 8. Missing Documentation Updates

### 8a. AI_README.md

**File:** `AI_README.md`

Add entries for the 5 new widgets following the existing format in the file. Each entry should include:
- Widget name and tier
- One-line description
- Constructor parameters (required and optional)
- Factory constructors (for OiOrderStatusBadge if applicable)
- Usage example
- Tags for searchability

### 8b. Documentation Site

**Directory:** `doc/documentation/docs/components/`

Update the following files:

1. **`components.md`** — Add sections for:
   - OiAddressForm (under Shop Components)
   - OiShippingMethodPicker (under Shop Components)
   - OiPaymentMethodPicker (under Shop Components)
   - OiOrderStatusBadge (under Shop Components)

2. **`composites.md`** — Add section for:
   - OiOrderTracker (under Shop Composites)

Follow the existing documentation pattern: description, parameters table, usage example, related components.

---

## Implementation Order

Implement in this order due to dependencies:

1. **OiOrderStatusBadge** — no new dependencies, simple wrapper
2. **OiAddressForm** — no new dependencies, standalone form
3. **OiShippingMethodPicker** — wraps existing OiShippingOption
4. **OiPaymentMethodPicker** — wraps existing OiPaymentOption
5. **OiOrderTracker** — depends on OiOrderStatusBadge (step 1)
6. **Model tests** (OiCouponResult, OiCheckoutData, OiCountryOption) — independent, can be done in parallel
7. **Barrel exports** — after all widgets are created
8. **Documentation** — after all widgets are created

---

## Testing Conventions Reminder

- Test files mirror source path: `lib/src/components/shop/oi_address_form.dart` → `test/src/components/shop/oi_address_form_test.dart`
- Use `pumpObers(widget)` helper to wrap widgets in `OiApp` for testing
- Use `pumpTouchApp()` / `pumpPointerApp()` for platform-specific tests
- Use `pumpAtBreakpoint()` for responsive tests
- Golden tests go in `test/src/golden/`
- All tests use `flutter_test` and `mocktail` for mocking
- Import widgets via `package:obers_ui/obers_ui.dart`

---

## Verification

After all implementations:

```bash
# Run all tests
flutter test

# Run only new tests
flutter test test/src/components/shop/oi_address_form_test.dart
flutter test test/src/components/shop/oi_shipping_method_picker_test.dart
flutter test test/src/components/shop/oi_payment_method_picker_test.dart
flutter test test/src/components/shop/oi_order_status_badge_test.dart
flutter test test/src/composites/shop/oi_order_tracker_test.dart
flutter test test/src/models/oi_coupon_result_test.dart
flutter test test/src/models/oi_checkout_data_test.dart
flutter test test/src/models/oi_country_option_test.dart

# Analyze for issues
dart analyze

# Format
dart format .
```

---

End of missing features specification.
