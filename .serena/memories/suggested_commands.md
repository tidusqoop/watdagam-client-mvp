# Suggested Commands for Watdagam Development

## Essential Flutter Commands
```bash
# Development workflow
flutter pub get                 # Install/update dependencies
flutter run                     # Run app on connected device/emulator
flutter run -d chrome          # Run on web browser
flutter run --hot-reload       # Enable hot reload (default)

# Testing & Quality
flutter test                    # Run all tests
flutter analyze                 # Static analysis and linting
flutter format .                # Format all Dart files

# Building
flutter build apk               # Build Android APK
flutter build appbundle        # Build Android App Bundle
flutter build ios              # Build iOS app (requires Xcode)
flutter build web              # Build web version

# Device management
flutter devices                 # List connected devices
flutter emulators               # List available emulators
flutter doctor                  # Check Flutter installation
```

## Darwin/macOS Specific Commands
```bash
# System utilities
ls -la                          # List files with details
grep -r "pattern" .             # Search for patterns recursively
find . -name "*.dart"           # Find Dart files
open .                          # Open current directory in Finder
which flutter                   # Show Flutter binary location
```

## Git Workflow
```bash
git status                      # Check repository status
git add .                       # Stage all changes
git commit -m "message"         # Commit changes
git push origin main            # Push to remote
git pull origin main            # Pull latest changes
```

## Development Tools
```bash
# Dependency management
flutter pub deps                # Show dependency tree
flutter pub outdated            # Check for outdated packages

# Debugging
flutter logs                    # Show device logs
flutter screenshot              # Take screenshot of running app
```