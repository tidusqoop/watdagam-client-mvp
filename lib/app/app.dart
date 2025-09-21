import 'package:flutter/material.dart';
import '../features/graffiti_board/data/repositories/graffiti_repository.dart';
import '../features/graffiti_board/presentation/screens/graffiti_wall_screen.dart';
import '../core/theme/app_theme.dart';
import '../core/constants/app_constants.dart';

/// Main application widget
class WatdagamApp extends StatelessWidget {
  final GraffitiRepository repository;

  const WatdagamApp({super.key, required this.repository});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.APP_NAME,
      theme: AppTheme.lightTheme,
      home: GraffitiWallScreen(repository: repository),
    );
  }
}