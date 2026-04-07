# Commit Message Guidelines

This project follows the Conventional Commits specification to maintain a readable commit history and help automate changelog generation. For full details, see the [official Conventional Commits website](https://www.conventionalcommits.org/). The benefits of this approach include creating a more readable project history and enabling automated tooling for changelogs, versioning, and releases.

## Format

A commit message consists of a header, an optional body, and an optional footer:

```html
<type>(<scope>): <subject>
<BLANK LINE>
<body>
<BLANK LINE>
<footer>
```

1. **Header (Mandatory)**: Contains the type, optional scope, and subject describing the change
2. **Body (Optional)**: Provides detailed explanation of what changed and why
3. **Footer (Optional)**: Used for issue tracking (e.g., `Closes #123`) or breaking change notifications (e.g., `BREAKING CHANGE: ...`)

## How to Choose the Right `<type>`

Use this decision tree to select the appropriate commit type:

1. **Are you adding a new user-facing feature?** → `feat`
2. **Are you fixing a user-facing bug?** → `fix`
3. **Are you only updating documentation?** → `docs`
4. **Are you only changing code style or formatting (no logic changes)?** → `style`
5. **Are you only adding or fixing tests?** → `test`
6. **Are you improving code structure without adding features or fixing bugs?** → `refactor`
7. **Are you making tooling, dependency, or CI/CD changes?** → `chore`

## How to Choose the Right `<scope>`

The scope is optional but recommended to provide additional context. Think of the scope as a "tag" that tells you which part of the codebase you changed:

1. **If you change something inside `features/auth/`...** → Use `auth`

   - Example: `feat(auth): Add sign out button`

2. **If you change something inside `features/videos/`...** → Use `videos`

   - Example: `fix(videos): Correct playback pause issue`

3. **If you change a shared widget inside `core/widgets/`...** → Use `core` or `widgets`

   - Example: `style(widgets): Update primary button color`

4. **If you change something related to development setup** (like `pubspec.yaml` or `.vscode/` files)... → Use `dev`

   - Example: `chore(dev): Upgrade riverpod to latest version`

5. **If none of the above apply or it's an app-wide change** → Omit the scope

The scope gives a quick, at-a-glance hint about where to find the code that was changed.

## Commit Granularity

Keep commits focused and structured:

- Prefer **one logical item/refactor per commit**.
- Avoid mixing unrelated changes in the same commit.
- If a broader task has multiple independent improvements, split them into separate commits.
- Use the subject line to describe the single intent of that commit.
