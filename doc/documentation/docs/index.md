# ObersUI

**A Flutter UI kit with everything you need to build a real app.**

*"Obers"* is the Austrian word for cream, the kind you pour into coffee or whip into something nice. ObersUI works the same way. Pour it into your Flutter app and you get a smooth, consistent foundation to build on.

---

## What is ObersUI?

ObersUI is an open-source Flutter UI library for modern, data-heavy applications. It ships 250+ widgets across five tiers, from small primitives to full-screen modules you can drop straight into your app. It has no Material or Cupertino dependency. Everything is built from scratch and styled by a single theme.

<div class="grid cards" markdown>

- :material-rocket-launch:{ .lg .middle } **Getting Started**

    ---

    Install ObersUI, set up `OiApp`, and render your first screen in a few minutes.

    [:octicons-arrow-right-24: Get started](getting-started/index.md)

- :material-palette-outline:{ .lg .middle } **Theming**

    ---

    One line for brand colors, full control when you want it. Tokens for everything.

    [:octicons-arrow-right-24: Explore theming](theming/index.md)

- :material-view-grid-outline:{ .lg .middle } **Widgets**

    ---

    Buttons, inputs, tables, file explorers, kanban boards, and more. Browse the catalog.

    [:octicons-arrow-right-24: Browse widgets](widgets/index.md)

- :material-chart-line:{ .lg .middle } **Charts**

    ---

    30+ chart types in the companion package, built on the same theme.

    [:octicons-arrow-right-24: See charts](charts/index.md)

</div>

---

## Why teams pick it

| Feature | Details |
| --- | --- |
| **250+ widgets** | Primitives, components, composites, and full modules. |
| **Design tokens** | Colors, typography, spacing, radius, shadows, motion. |
| **Responsive** | 5 breakpoints, adaptive layouts, density modes. |
| **Accessible** | Required labels, 48dp touch targets, reduced-motion support. |
| **Persistent settings** | User preferences saved through pluggable drivers. |
| **Platform-adaptive** | Web, iOS, Android, macOS, Windows, Linux. |
| **No Material required** | Pure widgets, no `MaterialApp`. |

---

## A quick taste

```dart
import 'package:obers_ui/obers_ui.dart';

void main() {
  runApp(
    OiApp(
      theme: OiThemeData.fromBrand(color: Color(0xFF8B6914)),
      home: OiPage(
        breakpoint: OiBreakpoint.compact,
        children: [
          OiLabel.h1('Pour some Obers'),
          OiButton.primary(label: 'Get started', onTap: () {}),
        ],
      ),
    ),
  );
}
```

One import, one theme, one app widget. From here, every widget you add reads its colors and spacing from the theme.

---

## Find your way around

- **New here?** Read [Getting Started](getting-started/index.md), then [Core Ideas](getting-started/core-ideas.md).
- **Looking for a widget?** The [Widgets catalog](widgets/index.md) groups everything by what it does.
- **Building a full screen?** See the [Modules](modules/index.md) that wrap whole features.
- **Styling the app?** Start with [Quick Brand Setup](theming/quick-brand.md).
- **Need the reference?** The [AI Integration Guide](advanced/ai-readme.md) points to the full single-file catalog.

---

- [**GitHub**](https://github.com/simonerich/obers_ui) for source and issues.
