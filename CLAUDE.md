# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Summary
- **Flutter-based mobile app development** (플러터 기반 앱 개발)
- **Graffiti Wall SNS concept**: Digital recreation of travel/tourist graffiti walls where people write "oo왔다감!" (someone was here) messages
- **MVP Goal**: Interactive digital wall where users can create, resize, and position graffiti-style messages

## Current MVP Requirements
- Implement UI based on `sample/sample_wall_ui.png` design reference
- Core user flow: Create graffiti → Resize (drag to resize) → Position (drag to move) → Edit content
- The reference image shows a wall interface with various colored graffiti notes that can be interacted with

## Development Setup

### Prerequisites
- Flutter SDK must be installed
- This project currently has no Flutter project structure - needs initialization

### Common Development Commands
Since this is a new Flutter project, standard Flutter commands will apply:
```bash
flutter create .                 # Initialize Flutter project structure
flutter pub get                  # Install dependencies  
flutter run                      # Run app on connected device/emulator
flutter build apk               # Build Android APK
flutter build ios               # Build iOS app
flutter test                    # Run tests
flutter analyze                 # Static analysis
```

## Architecture Notes
- **UI Reference**: `sample/sample_wall_ui.png` shows the target interface with:
  - Draggable, resizable graffiti notes with different colors
  - Wall-like background interface
  - Interactive editing tools at bottom (drawing tools, colors, undo/redo)
  - User profile integration ("스케치", "감기라하자" usernames visible)

## Project Status
Repository initialized but requires Flutter project structure setup. Ready for initial Flutter development based on the provided UI mockup.
