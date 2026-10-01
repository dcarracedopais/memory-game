# AGENTS.md

## Project

This is a small personal Flutter Web game called MeriMemory.

Keep the project simple, maintainable, and easy to understand. Avoid unnecessary architecture, abstractions, dependencies, or services.

## Technology

- Flutter / Dart.
- Flutter Web is the primary target.
- No backend or database unless explicitly requested.
- Prefer local assets over external services.
- Keep the application usable on mobile, tablet, and desktop, but focused on mobile devices.
- This project is meant to be used as a PWA

## Architecture

Keep `main.dart` small and organize application code into logical folders such as:

- `models/`
- `screens/`
- `widgets/`
- `services/`
- `theme/`

Adapt this structure when appropriate rather than following it rigidly.

Avoid introducing a state-management framework or other major architectural dependency unless there is a clear need.

## Code quality

- Prefer readable, straightforward Dart code.
- Avoid unnecessary duplication and over-engineering.
- Preserve existing functionality when making changes.
- Do not rewrite working code without a reason.
- Keep dependencies to a minimum.

## Testing

Before considering a significant change complete, run:

```bash
flutter analyze
flutter test
```

For changes affecting the web build, also run:

```bash
flutter build web
```

Fix errors and warnings introduced by the changes.

## Assets

Keep application assets organized under `assets/`.

Do not introduce remote dependencies for core game functionality unless explicitly requested.

## Git

Keep commits focused and use clear commit messages.

Never commit credentials, API keys, access tokens, or machine-specific configuration.

Review `.gitignore` before committing new files.

## Deployment

The project should remain compatible with Flutter Web deployment to Vercel.

Do not introduce server-side infrastructure solely for deployment.

## Development principles

When modifying the project:

1. Inspect the existing implementation first.
2. Make the smallest reasonable change.
3. Reuse existing components and patterns where appropriate.
4. Test the result.
5. Only ask the user when a decision requires their preference, credentials, or an important architectural choice.