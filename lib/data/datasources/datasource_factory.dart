import '../../config/app_config.dart';
import 'graffiti_datasource.dart';
import 'mock_graffiti_datasource.dart';
import 'api_graffiti_datasource.dart';

/// Factory for creating data source instances based on configuration
class DataSourceFactory {
  /// Create appropriate data source based on current configuration
  static GraffitiDataSource createGraffitiDataSource() {
    switch (AppConfig.currentDataSourceType) {
      case DataSourceType.mock:
        return MockGraffitiDataSource();

      case DataSourceType.api:
        return ApiGraffitiDataSource(AppConfig.currentApiBaseUrl);
    }
  }

  /// Create mock data source (for testing)
  static GraffitiDataSource createMockDataSource() {
    return MockGraffitiDataSource();
  }

  /// Create API data source with custom URL (for testing)
  static GraffitiDataSource createApiDataSource(String baseUrl) {
    return ApiGraffitiDataSource(baseUrl);
  }
}