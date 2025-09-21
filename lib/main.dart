import 'package:flutter/material.dart';

// New architecture imports
import 'features/graffiti_board/data/repositories/graffiti_repository.dart';
import 'features/graffiti_board/data/datasources/datasource_factory.dart';
import 'config/app_config.dart';
import 'app/app.dart';

void main() {
  // Print configuration for debugging
  AppConfig.printConfig();

  // Create repository with appropriate data source
  final repository = GraffitiRepository(
    DataSourceFactory.createGraffitiDataSource()
  );

  runApp(WatdagamApp(repository: repository));
}
