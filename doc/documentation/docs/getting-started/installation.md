# Installation

## Add the dependency

ObersUI is installed as a Git dependency. Add it to your `pubspec.yaml`:

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

ObersUI has minimal external dependencies:

- `shared_preferences` — Settings persistence on all platforms
- `intl` — Internationalization utilities
- `file_picker` — Native file selection dialogs
- `web` — Web platform support

All UI components are built from scratch — no Material or Cupertino dependency required.

## Next step

Now that ObersUI is installed, let's [set up your app](quick-start.md).
