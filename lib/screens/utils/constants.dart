// utils/constants.dart
class AppConstants {
  // API Configuration
  static const String apiBaseUrl =
      'http://192.168.12.254:3000/api'; // Backend local pour tests

  // Endpoints
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  static const String propertiesEndpoint = '/properties';
  static const String favoritesEndpoint = '/favorites';
  static const String messagesEndpoint = '/messages';

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';

  // Property Types
  static const List<String> propertyTypes = [
    'apartment',
    'house',
    'villa',
    'studio',
  ];

  // Transaction Types
  static const List<String> transactionTypes = [
    'sale',
    'rent',
  ];
}
