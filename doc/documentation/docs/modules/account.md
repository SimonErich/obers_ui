# Accounts & Settings

These modules are full pages, not small widgets. You drop one into a route and it
renders a complete screen: sign-in, a profile editor, a settings screen, a billing
page, or a role and permission matrix. Each one reads its colors, spacing, and
radius from the theme, adapts to mobile and desktop widths, and ships a `label` for
screen readers.

| Widget | What it does |
| --- | --- |
| `OiAuthPage` | Sign-in, sign-up, and forgot-password forms in one page. |
| `OiProfilePage` | Shows and edits a user profile with linked accounts and a danger zone. |
| `OiSettingsPage` | A grouped, searchable settings screen with toggles, selects, and sliders. |
| `OiSubscriptionManager` | The current plan, usage meters, billing history, and payment method. |
| `OiPermissions` | A role-by-permission matrix of checkboxes. |

## OiAuthPage

The authentication page. It holds the login, register, and forgot-password forms
and switches between them. Every action callback returns a `Future<bool>`. Return
`true` on success. When a callback is `null`, its submit button is disabled, so you
control which flows the page offers by which callbacks you pass.

```dart
OiAuthPage(
  label: 'Sign in',
  onLogin: (email, password) async {
    return await auth.signIn(email, password);
  },
  onRegister: (name, email, password) async {
    return await auth.register(name, email, password);
  },
  onForgotPassword: (email) async {
    return await auth.sendReset(email);
  },
)
```

### Locked modes

Two named constructors lock the page to a single form. Use these when sign-up lives
on its own route.

```dart
OiAuthPage.login(
  label: 'Sign in',
  onLogin: (email, password) async => auth.signIn(email, password),
)

OiAuthPage.register(
  label: 'Create account',
  onRegister: (name, email, password) async => auth.register(name, email, password),
)
```

### Attributes

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `label` | `String` | **required** | Screen-reader label for the page. |
| `initialMode` | `OiAuthMode` | `login` | Which form shows first: `login`, `register`, or `forgotPassword`. |
| `onLogin` | `Future<bool> Function(String email, String password)?` | `null` | Runs the login. Return `true` on success. `null` disables the login button. |
| `onRegister` | `Future<bool> Function(String name, String email, String password)?` | `null` | Runs the registration. `null` hides the sign-up link and disables the button. |
| `onForgotPassword` | `Future<bool> Function(String email)?` | `null` | Sends the reset email. `null` hides the forgot-password link. |
| `onModeChanged` | `ValueChanged<OiAuthMode>?` | `null` | Fires when the user switches forms. |
| `logo` | `Widget?` | `null` | Shown above the form. |
| `footer` | `Widget?` | `null` | Shown below the form. |

!!! note
    The page shows an inline error when a callback returns `false` or throws. You do
    not add your own error banner. Just return the right value.

## OiProfilePage

Shows a user's profile and lets them edit it. It renders an avatar, editable
personal fields, an optional list of linked accounts, any custom sections you add,
and a danger zone for account deletion. On wide screens it splits into a sidebar
and a scrolling content area. You pass the data through `OiProfileData` and react to
changes through the callbacks.

```dart
OiProfilePage(
  label: 'Your profile',
  profile: const OiProfileData(
    name: 'Jane Doe',
    email: 'jane@example.com',
    role: 'Admin',
    phone: '+1 555 0100',
  ),
  onFieldSave: (field, value) async {
    return await api.updateField(field, value);
  },
  onDeleteAccount: () async => api.deleteAccount(),
)
```

### Linked accounts

Pass a list of `OiLinkedAccount` to show external providers. The connect and
disconnect buttons appear only when you supply `onAccountLink` and `onAccountUnlink`.

```dart
OiProfilePage(
  label: 'Your profile',
  profile: profile,
  linkedAccounts: [
    const OiLinkedAccount(
      provider: 'google',
      label: 'Google',
      connected: true,
      username: 'jane@gmail.com',
    ),
    const OiLinkedAccount(provider: 'github', label: 'GitHub'),
  ],
  onAccountLink: (account) => connect(account),
  onAccountUnlink: (account) => disconnect(account),
)
```

### Attributes

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `profile` | `OiProfileData` | **required** | The profile data to show. |
| `label` | `String` | **required** | Screen-reader label for the page. |
| `onFieldSave` | `Future<bool> Function(String field, String value)?` | `null` | Saves one field. A save button appears per field only when set. |
| `onAvatarChange` | `Future<void> Function(Object imageData)?` | `null` | Runs when the user taps the avatar camera badge. |
| `onPasswordChange` | `Future<bool> Function(String current, String newPassword)?` | `null` | Changes the password. |
| `linkedAccounts` | `List<OiLinkedAccount>?` | `null` | External accounts to list. |
| `onAccountLink` | `void Function(OiLinkedAccount)?` | `null` | Connects an account. |
| `onAccountUnlink` | `void Function(OiLinkedAccount)?` | `null` | Disconnects an account. |
| `onDeleteAccount` | `Future<bool> Function()?` | `null` | Deletes the account. The delete button asks for a second tap to confirm. |
| `sections` | `List<OiProfileSection>` | `const []` | Extra custom sections below linked accounts. |
| `showDangerZone` | `bool` | `true` | Set `false` to hide the account-deletion block. |

`OiProfileData` takes `name` and `email` (both required), plus optional `avatarUrl`,
`role`, `phone`, and `bio`.

## OiSettingsPage

A settings screen built from groups of items. Each group is collapsible. Each item
renders as a toggle, a navigation row, a select, a slider, or a custom widget, based
on its `type`. When search is on, a search bar filters items by title, subtitle, and
keywords, and expands the matching groups.

```dart
OiSettingsPage(
  label: 'Settings',
  groups: [
    OiSettingsGroup(
      key: 'general',
      title: 'General',
      icon: OiIcons.settings,
      items: [
        const OiSettingsItem(
          key: 'notifications',
          title: 'Push notifications',
          type: OiSettingsItemType.toggle,
          value: true,
        ),
        const OiSettingsItem(
          key: 'theme',
          title: 'Theme',
          type: OiSettingsItemType.select,
          value: 'System',
          options: ['Light', 'Dark', 'System'],
        ),
      ],
    ),
  ],
  onSettingChanged: (groupKey, itemKey, value) {
    prefs.set(itemKey, value);
  },
)
```

### Item types

`OiSettingsItem.type` picks the control. The `value` field holds the current value
and its type follows the control.

| Type | Control | `value` type |
| --- | --- | --- |
| `toggle` | On/off switch | `bool` |
| `navigation` | Tappable row with a chevron, fires `onNavigate` | none |
| `select` | Dropdown, needs `options` | `String` |
| `slider` | Slider, honors `min` and `max` | `double` |
| `custom` | Your widget from `customBuilder` | any |

### Attributes

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `groups` | `List<OiSettingsGroup>` | **required** | The settings groups to render. |
| `label` | `String` | **required** | Screen-reader label for the page. |
| `onSettingChanged` | `void Function(String groupKey, String itemKey, dynamic value)?` | `null` | Fires when a toggle, select, or slider changes. |
| `onNavigate` | `void Function(OiSettingsItem item)?` | `null` | Fires when a navigation item is tapped. |
| `onResetGroup` | `void Function(String groupKey)?` | `null` | Fires when a group's reset button is tapped. |
| `onResetAll` | `VoidCallback?` | `null` | Fires when "Reset All Settings" is tapped. |
| `searchEnabled` | `bool` | `true` | Show the search bar. |
| `showResetButtons` | `bool` | `true` | Show per-group and global reset buttons. |

`OiSettingsGroup` takes `key`, `title`, and `items` (required), plus optional `icon`
and `description`. `OiSettingsItem` takes `key`, `title`, and `type` (required), plus
`subtitle`, `icon`, `value`, `options`, `min`, `max`, `customBuilder`, and
`searchKeywords`.

!!! note
    The page keeps its own copy of each value so controls stay interactive even with
    const data. Treat `onSettingChanged` as the source of truth and persist from
    there.

## OiSubscriptionManager

A billing page. It shows the current plan and status, usage meters, billing history,
and the payment method. Sections appear only when you give them data, so a plan with
no invoices simply omits the history block. This one is a `StatelessWidget`, so you
own all the state and just feed it fresh data.

```dart
OiSubscriptionManager(
  label: 'Subscription',
  currentPlan: OiSubscriptionPlan(
    key: 'pro',
    name: 'Pro',
    price: 29,
    renewalDate: DateTime(2026, 8, 1),
    status: OiSubscriptionStatus.active,
    features: const ['Unlimited projects', 'Priority support'],
  ),
  usage: const [
    OiUsageQuota(label: 'Storage', used: 12, limit: 50, unit: 'GB'),
    OiUsageQuota(label: 'API calls', used: 8200, limit: 10000),
  ],
  onUpgrade: () => openUpgradeFlow(),
  onCancel: () async => confirmCancel(),
)
```

The usage meter color shifts on its own: green under 80 percent, amber over 80, red
over 95. You do not set it.

### Attributes

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `currentPlan` | `OiSubscriptionPlan` | **required** | The plan shown at the top. |
| `label` | `String` | **required** | Screen-reader label for the page. |
| `usage` | `List<OiUsageQuota>` | `const []` | Usage meters. Empty hides the section. |
| `invoices` | `List<OiInvoice>` | `const []` | Billing history rows. Empty hides the section. |
| `paymentMethod` | `OiPaymentMethodInfo?` | `null` | Card on file. `null` hides the section. |
| `onUpgrade` | `VoidCallback?` | `null` | Shows the Upgrade button when set. |
| `onDowngrade` | `VoidCallback?` | `null` | Shows the Downgrade button when set. |
| `onCancel` | `Future<bool> Function()?` | `null` | Shows the Cancel button. Return `true` when the user confirms. |
| `onUpdatePayment` | `VoidCallback?` | `null` | Shows the Update button on the payment card. |
| `onInvoiceDownload` | `void Function(OiInvoice)?` | `null` | Shows a download icon per invoice. |
| `currencySymbol` | `String` | `'$'` | Prefix used to format prices. |

`OiSubscriptionPlan` takes `key`, `name`, and `price` (required), plus `billingCycle`
(default `OiBillingCycle.monthly`), `renewalDate`, `status` (default
`OiSubscriptionStatus.active`), and `features`. `OiUsageQuota` takes `label`, `used`,
and `limit` (required), plus `unit` and `icon`.

## OiPermissions

A role-based access editor. Permissions are rows, roles are columns, and each
intersection is a checkbox. Tapping a checkbox grants or revokes that permission for
that role. The `matrix` maps each role key to the set of permission keys it holds.
On every toggle, `onChange` fires with a fresh, fully updated matrix. Store that and
pass it back in.

```dart
OiPermissions(
  label: 'Role permissions',
  permissions: const [
    OiPermissionItem(key: 'read', label: 'View content'),
    OiPermissionItem(key: 'write', label: 'Edit content'),
    OiPermissionItem(key: 'delete', label: 'Delete content'),
  ],
  roles: const [
    OiRole(key: 'admin', label: 'Admin'),
    OiRole(key: 'editor', label: 'Editor'),
    OiRole(key: 'viewer', label: 'Viewer'),
  ],
  matrix: _matrix,
  onChange: (updated) => setState(() => _matrix = updated),
)
```

### Attributes

| Parameter | Type | Default | Description |
| --- | --- | --- | --- |
| `permissions` | `List<OiPermissionItem>` | **required** | The rows. Each has `key`, `label`, and optional `description`. |
| `roles` | `List<OiRole>` | **required** | The columns. Each has `key`, `label`, optional `description` and `color`. |
| `matrix` | `Map<String, Set<String>>` | **required** | Role key to its set of granted permission keys. |
| `onChange` | `ValueChanged<Map<String, Set<String>>>` | **required** | Fires with the full updated matrix on each toggle. |
| `label` | `String` | **required** | Screen-reader label for the matrix. |
| `enabled` | `bool` | `true` | Set `false` to make the matrix read-only. |

!!! tip
    Give each `OiRole` a `color` from the theme, like `context.colors.primary.base`,
    to tell roles apart at a glance in a wide matrix.

## Related

- [Commerce](../widgets/commerce.md) for pricing tables and plan pickers.
- [Text Inputs](../widgets/text-inputs.md) for the fields these pages build on.
- [Selection Controls](../widgets/selection-controls.md) for switches, selects, and sliders.
- [Buttons & Actions](../widgets/buttons.md) for the buttons used across these pages.
