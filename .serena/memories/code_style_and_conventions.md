# Code Style and Conventions for Watdagam

## Dart/Flutter Conventions
- **Language**: Dart 3.9.2 with null safety enabled
- **Linting**: Uses `flutter_lints: ^5.0.0` package for recommended lints
- **Analysis**: Configured via `analysis_options.yaml` with `package:flutter_lints/flutter.yaml`

## Naming Conventions
- **Classes**: PascalCase (e.g., `GraffitiNote`, `WatdagamApp`)
- **Variables/Functions**: camelCase (e.g., `notes`, `buildGraffitiNote`)
- **Constants**: lowerCamelCase with `const` keyword
- **Files**: snake_case (e.g., `main.dart`, `widget_test.dart`)

## Code Organization
- **Single File Structure**: Currently using single-file approach in `lib/main.dart`
- **Widget Structure**: StatelessWidget for app, StatefulWidget for interactive screens
- **Private Methods**: Prefix with underscore (e.g., `_buildGraffitiNote`, `_buildBottomToolbar`)

## Flutter-Specific Patterns
- **Widget Constructor**: Use `const` constructors with `super.key`
- **State Management**: Using StatefulWidget with setState for local state
- **Material Design**: Material Design 3 with ColorScheme.fromSeed
- **Layout**: Stack-based positioning for draggable elements

## Documentation
- **Comments**: Minimal inline comments, focus on self-documenting code
- **Widget Documentation**: Brief descriptions for complex custom widgets
- **Model Classes**: Document data structure purpose and usage

## Performance Best Practices
- Use `const` constructors where possible
- Prefer `const` widgets for static content
- Use `ListView.builder` for dynamic lists (when needed)
- Implement proper disposal of controllers and listeners

## Korean Text Handling
- UTF-8 encoding for Korean text ("왔다감", "낙서집")
- Consider text overflow and line breaking for Korean content
- Material Design font support for Korean characters