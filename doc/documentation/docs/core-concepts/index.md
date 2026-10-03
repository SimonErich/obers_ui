# Core Concepts

These pages cover the ideas that run through the whole library. You do not need to
read them all before building. Skim them once, then come back when a topic comes up.

- [**The Four Tiers**](component-tiers.md) shows how the library is layered, from primitives to full modules, and how to pick the right level.
- [**Theming**](theming.md) is a short intro to the token system. The full detail lives in the [Theming section](../theming/index.md).
- [**Responsive Design**](responsive.md) covers breakpoints and adaptive layouts.
- [**Density**](density.md) explains the comfortable, compact, and dense modes.
- [**Accessibility**](accessibility.md) covers labels, touch targets, and reduced motion.
- [**Icons**](icons.md) introduces `OiIcons` and the `OiIcon` widget.
- [**Overlays & Z-Order**](overlays.md) explains how dialogs, sheets, toasts, and menus stack.
- [**Navigation & Routing**](navigation-and-routing.md) covers `OiApp`, `OiApp.router`, and page transitions.
- [**State, Undo & Persistence**](state-and-persistence.md) covers saved settings, undo, and optimistic updates.

Everything here fits together. A button reads its colors from the theme, sizes
itself for the current density, keeps a minimum touch target for accessibility, and
adapts to the breakpoint. You get all of that without configuring anything.
