# Watdagam Project Overview

## Project Purpose
- **Concept**: Digital recreation of travel/tourist graffiti walls where people write "oo왔다감!" (someone was here) messages
- **MVP Goal**: Interactive digital wall where users can create, resize, and position graffiti-style messages
- **Korean Name**: "왔다감" (watdagam)

## Tech Stack
- **Framework**: Flutter 3.35.3 (stable channel)
- **Language**: Dart 3.9.2
- **SDK**: Flutter SDK ^3.9.2
- **Platform**: Cross-platform mobile app (iOS/Android support)
- **UI Framework**: Material Design 3 with custom theme

## Current Implementation Status
- Basic Flutter project structure initialized
- Core UI implemented based on `sample/sample_wall_ui.png` reference
- Features implemented:
  - GraffitiNote data model with position, size, color, text
  - GraffitiWallScreen with draggable notes display
  - Bottom toolbar with drawing tools and color palette
  - Static sample graffiti notes with user profiles

## Architecture
- Single-file architecture in `lib/main.dart`
- StatefulWidget pattern for main screen
- Custom GraffitiNote model class
- Stack-based layout for positioned elements
- Material Design components