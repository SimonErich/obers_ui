# ObersUI

**The creamiest Flutter UI kit.**

*"Obers"* is the Austrian word for cream — the kind you pour into coffee or whip into something wonderful. Just like Obers makes everything richer, ObersUI gives your Flutter apps a smooth, polished foundation to build on.

---

## What is ObersUI?

ObersUI is a comprehensive, open-source Flutter UI library built for modern, complex applications. It ships with **100+ components** across four carefully designed tiers — from low-level primitives to full-featured modules you can drop into your app.

<div class="grid cards" markdown>

- :material-rocket-launch:{ .lg .middle } **Getting Started**

    ---

    Install ObersUI, set up `OiApp`, and render your first widget in under 5 minutes.

    [:octicons-arrow-right-24: Get started](getting-started/index.md)

- :material-palette-outline:{ .lg .middle } **Theming**

    ---

    One line for brand colors, full control when you need it. Design tokens for everything.

    [:octicons-arrow-right-24: Explore theming](theming/index.md)

- :material-view-grid-outline:{ .lg .middle } **Components**

    ---

    Buttons, tables, charts, file explorers, kanban boards — browse the full catalog.

    [:octicons-arrow-right-24: Browse components](components/index.md)

</div>

---

## Highlights

| Feature | Details |
| --- | --- |
| **100+ widgets** | Primitives, components, composites, and full modules |
| **Design tokens** | Colors, typography, spacing, radius, shadows, animations |
| **Responsive** | 5 breakpoints, adaptive layouts, density modes |
| **Accessible** | WCAG AA, reduced motion, 48dp touch targets, semantic labels |
| **Persistent settings** | User preferences auto-saved via pluggable drivers |
| **Platform-adaptive** | Web, iOS, Android, macOS, Windows, Linux |
| **Zero Material dependency** | Pure widgets — no `MaterialApp` required |

---

## Quick taste

```dart
import 'package:obers_ui/obers_ui.dart';

void main() {
  runApp(
    OiApp(
      theme: OiThemeData.fromBrand(color: Color(0xFF8B6914)),
      home: Center(
        child: OiButton(
          label: 'Pour some Obers',
          onPressed: () {},
        ),
      ),
    ),
  );
}
```

That's it. One import, one theme, one app widget. Creamy smooth.

---

## Explore more

- [**API Reference**](/obers_ui/api/) — Full generated dart doc
- [**GitHub**](https://github.com/simonerich/obers_ui) — Source code & issues
