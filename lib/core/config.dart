class Config {
  // Firebase Configuration
  static const String firebaseApiKey = String.fromEnvironment('FIREBASE_API_KEY', defaultValue: '');
  static const String firebaseAppId = String.fromEnvironment('FIREBASE_APP_ID', defaultValue: '');
  static const String firebaseMessagingSenderId =
      String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID', defaultValue: '');
  static const String firebaseProjectId = String.fromEnvironment('FIREBASE_PROJECT_ID', defaultValue: '');

  // Google Maps Configuration
  static const String googleMapsApiKey = String.fromEnvironment('GOOGLE_MAPS_API_KEY', defaultValue: '');

  // App Configuration
  static const String appName = 'Online Market';
  static const String appVersion = '1.0.0';

  // API Endpoints
  static const String baseUrl = String.fromEnvironment('BASE_URL', defaultValue: 'https://api.onlinemarket.com');

  // Storage Keys
  static const String userTokenKey = 'user_token';
  static const String userDataKey = 'user_data';
  static const String cartDataKey = 'cart_data';
  static const String settingsKey = 'app_settings';

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxImageUploadSize = 5 * 1024 * 1024; // 5MB

  // Validation
  static const int minPasswordLength = 6;
  static const int maxNameLength = 50;

  // Development flags
  static const bool isDebugMode = bool.fromEnvironment('DEBUG_MODE', defaultValue: false);
  static const bool enableLogging = bool.fromEnvironment('ENABLE_LOGGING', defaultValue: true);
}
