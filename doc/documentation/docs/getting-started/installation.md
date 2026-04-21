# Installation

## Add the dependency

ObersUI is installed as a Git dependency. Add it to your `pubspec.yaml`
(replace the URL below with the actual ObersUI Git remote for your
organisation):

```yaml
dependencies:
  obers_ui:
    git:
      url: https://github.com/simonerich/obers_ui.git
```

Then fetch packages:

```bash
flutter pub get
```

!!! note "Version pinning"
    To pin a specific commit or tag, add a `ref` field:
    ```yaml
    dependencies:
      obers_ui:
        git:
          url: https://github.com/simonerich/obers_ui.git
          ref: v0.1.0  # or a commit hash
    ```

## For local development

If you're working on ObersUI itself or have it cloned locally:

```yaml
dependencies:
  obers_ui:
    path: ../obers_ui
```

## Requirements

| Requirement | Minimum version |
| --- | --- |
| Flutter | 3.41.0 |
| Dart | 3.11.0 |

## What's included

ObersUI has a small set of external dependencies, all of which are
pulled in transitively when you add `obers_ui`:

- `shared_preferences` — Settings persistence on mobile / desktop
- `intl` — Internationalization utilities (date / number formatting)
- `file_picker` — Native file selection dialogs
- `desktop_drop` — Desktop drag-and-drop for file drop zones
- `unicode_emojis` — Emoji data for `OiEmojiPicker` and related widgets
- `web` — Web-platform interop (used by the web launcher, storage driver,
  etc.)

All UI components are built from scratch — no Material or Cupertino
dependency required.

## Next step

Now that ObersUI is installed, let's [set up your app](quick-start.md).
