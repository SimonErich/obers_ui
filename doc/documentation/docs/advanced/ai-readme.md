# AI Integration Guide

If you use an AI coding assistant (Claude, Copilot, Cursor, and the like) to build
with ObersUI, point it at the single-file reference that ships with the library:
[`AI_README.md`](https://github.com/simonerich/obers_ui/blob/main/AI_README.md) at
the repo root.

## What it is

`AI_README.md` is one long, structured document written for machines to read. It
lists every widget with its parameters, tags, tier, and usage rules, plus a
decision matrix, best practices, and anti-patterns. It is the same source of truth
these docs are built from, in a format an assistant can load in one shot.

## How to use it

Add it to your assistant's context. A few common ways:

- Drop the file into the chat or project context directly.
- Reference it from a rules file (for example a `CLAUDE.md`, `.cursorrules`, or
  similar) so the assistant reads it on every session.
- Paste the relevant section when you ask for a specific widget.

## The rules it enforces

The reference tells an assistant to:

- Prefer an existing ObersUI widget over hand-rolled UI.
- Use the highest tier that fits (modules over composites over components over primitives).
- Never use Material or Cupertino widgets. Use `OiApp`, not `MaterialApp`.
- Read all colors and spacing from the theme, never hardcode them.
- Use `OiLabel` for text and `OiRow` / `OiColumn` / `OiGrid` for layout.
- Give every interactive widget a `label` or `semanticLabel`.

## Keeping it current

`AI_README.md` is kept in sync with the codebase. When widgets are added, changed,
or removed, the reference and these docs are updated together. If you fork the
library, regenerate or edit the reference so your assistant does not suggest
widgets that no longer exist.
