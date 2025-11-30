// utils/constants.dart
class AppConstants {
  // API Configuration
  static const String apiBaseUrl =
      'https://backend-immobilier-a6bb.onrender.com/api'; // Backend local pour web

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
