# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Summary
- **Flutter-based mobile app development** (플러터 기반 앱 개발)
- **Graffiti Wall SNS concept**: Digital recreation of travel/tourist graffiti walls where people write "oo왔다감!" (someone was here) messages
- **MVP Goal**: Interactive digital wall where users can create, resize, and position graffiti-style messages

## Development Commands

### Essential Flutter Commands
```bash
flutter pub get                 # Install/update dependencies
flutter run                     # Run app on connected device/emulator
flutter run -d chrome          # Run on web browser for quick testing
flutter test                    # Run all tests
flutter analyze                 # Static analysis and linting
flutter build apk              # Build Android APK
flutter build ios              # Build iOS app (requires Xcode)
```

### Platform-specific Commands
```bash
# Quick web testing (fastest for UI development)
flutter run -d chrome

# iOS Simulator (macOS only)
flutter devices                # List available devices
flutter run -d "iPhone 16e"    # Run on specific simulator

# Android 
flutter run                     # Auto-selects connected Android device
```

## Architecture Overview

### Project Structure
```
lib/
├── main.dart                   # App entry point
├── config/
│   └── app_config.dart        # Environment and data source configuration
├── data/
│   ├── models/
│   │   └── graffiti_note.dart # Core data model with JSON serialization
│   ├── datasources/           # Data layer abstraction
│   ├── repositories/          # Repository pattern implementation
│   └── mock/                  # Mock data for development
└── [screens/widgets/services to be added as needed]
```

### Key Components

**GraffitiNote Model**: Core data structure with properties:
- Position, size, content, author, background color
- JSON serialization support
- AuthorAlignment enum for text positioning
- Opacity and corner radius customization

**Data Layer Pattern**: 
- Repository pattern with datasource abstraction
- Mock datasource for development (uses `lib/features/graffiti_board/data/mock/graffiti_notes.json`)
- API datasource ready for backend integration
- Environment-based configuration in `AppConfig`

**Environment Configuration**:
- Development: Uses mock data
- Staging/Production: Configured for API integration
- Feature flags for testing (force mock data, debug logging)

### Dependencies
- `cupertino_icons`: iOS-style icons
- `dotted_border`: Custom border styling
- `http`: HTTP client for API calls
- `flutter_lints`: Code quality enforcement

## Development Notes

### Current Implementation Status
- Complete MVP Phase 1-3 functionality implemented
- Interactive graffiti wall with drag/resize/edit capabilities
- Clean architecture with separation of concerns
- Mock data system for offline development
- Ready for backend API integration

### Testing Strategy
- Run `flutter test` for unit/widget tests
- Use `flutter run -d chrome` for rapid UI iteration
- Mock data allows full feature testing without backend

### Code Style
- Follows `flutter_lints` standards (configured in `analysis_options.yaml`)
- Use `flutter format .` to format code
- Repository pattern for data access
- Environment-based configuration pattern
