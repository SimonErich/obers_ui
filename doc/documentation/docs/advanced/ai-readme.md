# AI Integration Guide

ObersUI ships with an **AI-optimized reference document** (`AI_README.md`) designed to enable coding AIs to implement ObersUI into applications fully automatically.

## What is AI_README.md?

`AI_README.md` is a comprehensive markdown file at the project root that documents:

- **Every single widget** in the library with parameters, usage patterns, and tags
- **Theme system** with complete token reference
- **Decision matrix** — "I need X → use Y" lookup table
- **Best practices and anti-patterns** — what to do and what to avoid
- **Searchable tags index** — keyword → widget mapping for quick lookup
- **Planned widgets** — what's coming but not yet available

## Where to Find It

The file lives at the project root:

```text
obers_ui/
├── AI_README.md    ← This file
├── CLAUDE.md
├── lib/
└── ...
```

## How to Use It

Pass `AI_README.md` as context to any coding AI (Claude, GPT, Copilot, etc.) along with your design requirements:

```text
"Here is the ObersUI reference: [AI_README.md contents]

Build this design: [your design description]"
```

The AI will automatically:

1. Select the best available widgets for each part of the design
2. Use the correct constructors and parameters
3. Follow ObersUI conventions (no Material widgets, theme-driven colors, etc.)
4. Compose higher-tier widgets where appropriate (modules > composites > components)

## Maintenance

`AI_README.md` must be kept in sync with the codebase. When you:

- **Add a widget** — add its entry to the catalog and tags index
- **Modify a widget** — update its parameters and description
- **Remove a widget** — remove its entry and update the tags index
- **Implement a planned widget** — move it from "Planned" to the main catalog

This file is the AI's single source of truth. If it's out of date, the AI will generate incorrect code.

## Claude Code Skill

If you use [Claude Code](https://claude.com/claude-code), you can invoke the `/obers-ui` skill to get widget recommendations based on a design description. The skill reads `AI_README.md` and provides guidance on which widgets to use.
