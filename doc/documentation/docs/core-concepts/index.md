# Core Concepts

Before diving into components, it helps to understand the ideas that hold ObersUI together. These concepts apply everywhere in the library.

## Overview

| Concept | What it means |
| --- | --- |
| [**Component Tiers**](component-tiers.md) | Four layers of abstraction — primitives, components, composites, modules |
| [**Theming**](theming.md) | A token-based design system for colors, typography, spacing, and more |
| [**Responsive Design**](responsive.md) | Five breakpoints with adaptive layouts and responsive values |
| [**Accessibility**](accessibility.md) | WCAG AA compliance, reduced motion, touch targets, semantic labels |
| [**Density**](density.md) | Three density modes that adapt UI sizing to the input device |

These systems work together. A button reads its colors from the theme, adjusts its size based on density, enforces minimum touch targets for accessibility, and adapts its layout at different breakpoints. You don't have to configure any of this — it just works out of the box.

!!! info "Convention over configuration"
    ObersUI is designed to work well with zero configuration. Every system has sensible defaults. Customize only what you need.
