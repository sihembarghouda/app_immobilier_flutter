/// src/config/app_config.dart
import 'package:flutter/foundation.dart';

/// Configuration centralisée de l'application
class AppConfig {
  // Empêcher l'instanciation
  AppConfig._();

  /// URL de base de l'API
  static String get baseUrl {
    return 'https://backend-immobilier-a6bb.onrender.com/api';
  }

  /// Endpoints de l'API
  static const String authLogin = '/auth/login';
  static const String authRegister = '/auth/register';
  static const String authProfile = '/auth/me';
  static const String authProfileUpdate = '/auth/profile';

  static const String properties = '/properties';
  static const String favorites = '/favorites';
  static const String messages = '/messages';
  static const String upload = '/upload';
  static const String uploadWeb = '/upload/web';
  static const String uploadMultiple = '/upload/multiple';

  /// Clés de stockage local
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String onboardingKey = 'onboarding_complete';
  static const String languageKey = 'app_language';
  static const String themeKey = 'app_theme';

  /// Configuration d'upload
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const int imageQuality = 40; // 40%
  static const int maxImageWidth = 1024;
  static const int maxImageHeight = 1024;

  /// Timeout des requêtes
  static const Duration requestTimeout = Duration(seconds: 30);

  /// Types de propriétés
  static const List<String> propertyTypes = [
    'apartment',
    'house',
    'villa',
    'studio',
  ];

  /// Types de transaction
  static const List<String> transactionTypes = [
    'sale',
    'rent',
  ];
}
