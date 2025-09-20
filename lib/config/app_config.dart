/// Application configuration for different environments and data sources
class AppConfig {
  // Environment configuration
  static const Environment environment = Environment.development;

  // Data source type mapping by environment
  static const Map<Environment, DataSourceType> _dataSourceMapping = {
    Environment.development: DataSourceType.mock,
    Environment.staging: DataSourceType.api,
    Environment.production: DataSourceType.api,
  };

  // Feature flags (can be modified at runtime)
  static bool _forceUseMockData = false;
  static bool _enableDebugLogging = true;

  // API configuration
  static const Map<Environment, String> _apiBaseUrls = {
    Environment.development: 'http://localhost:3000',
    Environment.staging: 'https://dev-api.watdagam.com',
    Environment.production: 'https://api.watdagam.com',
  };

  /// Get current data source type
  static DataSourceType get currentDataSourceType {
    if (_forceUseMockData) return DataSourceType.mock;
    return _dataSourceMapping[environment] ?? DataSourceType.mock;
  }

  /// Get current API base URL
  static String get currentApiBaseUrl {
    return _apiBaseUrls[environment] ?? _apiBaseUrls[Environment.development]!;
  }

  /// Force use mock data (useful for testing)
  static bool get forceUseMockData => _forceUseMockData;
  static set forceUseMockData(bool value) => _forceUseMockData = value;

  /// Debug logging flag
  static bool get enableDebugLogging => _enableDebugLogging;
  static set enableDebugLogging(bool value) => _enableDebugLogging = value;

  /// Check if running in development
  static bool get isDevelopment => environment == Environment.development;

  /// Check if running in production
  static bool get isProduction => environment == Environment.production;

  /// Check if using mock data
  static bool get isUsingMockData => currentDataSourceType == DataSourceType.mock;

  /// Configuration summary for debugging
  static Map<String, dynamic> get summary => {
    'environment': environment.name,
    'dataSourceType': currentDataSourceType.name,
    'apiBaseUrl': currentApiBaseUrl,
    'forceUseMockData': forceUseMockData,
    'enableDebugLogging': enableDebugLogging,
  };

  /// Print configuration summary
  static void printConfig() {
    if (!enableDebugLogging) return;

    print('🔧 App Configuration:');
    summary.forEach((key, value) {
      print('   $key: $value');
    });
  }
}

/// Application environments
enum Environment {
  development,
  staging,
  production,
}

/// Data source types
enum DataSourceType {
  mock,
  api,
  // Future extensions:
  // local,  // SQLite/Hive
  // hybrid, // Local + API sync
}