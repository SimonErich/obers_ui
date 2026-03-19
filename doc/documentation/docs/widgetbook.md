# Widgetbook

ObersUI ships with a **Widgetbook** — an interactive playground where you can explore every component, toggle props, switch themes, and see widgets respond in real time.

## Try it online

The Widgetbook is deployed alongside this documentation:

[Launch Widgetbook :material-open-in-new:](/obers_ui/widgetbook/){ .md-button .md-button--primary }

## Run locally

```bash
cd widgetbook
flutter pub get
flutter run -d chrome
```

This launches the Widgetbook as a web app in your browser. You can also run it on desktop:

```bash
flutter run -d macos   # or -d windows, -d linux
```

## What's inside

The Widgetbook contains use cases for every tier:

- **Foundation** — Theme preview, color swatches, spacing, typography
- **Primitives** — Layout, animation, interaction, scroll widgets
- **Components** — Buttons, inputs, display, navigation, overlays
- **Composites** — Tables, forms, charts, search, media
- **Modules** — File explorer, chat, dashboard, kanban

Each use case lets you:

- Toggle props via knobs (booleans, strings, enums, numbers)
- Switch between light and dark themes
- Resize the viewport to test responsive behavior
- View source code alongside the rendered widget

## When to use it

- **Exploring** — "What components are available?"
- **Designing** — "How does this button look with these props?"
- **Testing** — "Does this component respond correctly at 600dp?"
- **Communicating** — Share the Widgetbook URL with designers or stakeholders

!!! tip "Complement to docs"
    The Widgetbook shows *how things look*. This documentation explains *how things work*. Use both together for the full picture.
