import 'dart:io';
import 'package:flutter/foundation.dart';

/// Configuration centralisée de l'application
class AppConfig {
  // Empêcher l'instanciation
  AppConfig._();

  /// URL du backend en production (Render.com)
  static const String _productionUrl =
      'https://immobilier-backend.onrender.com/api';

  /// IP LAN de votre machine pour tester en développement local
  static const String _lanIp = '192.168.1.14';
  static const int _backendPort = 3000;

  /// Mode de déploiement - Changer à false pour tests locaux
  static const bool _useProduction = true;

  /// URL de base de l'API
  static String get baseUrl {
    // En production, utiliser l'URL Render pour toutes les plateformes
    if (_useProduction) {
      return _productionUrl;
    }

    // En développement, utiliser localhost/IP LAN
    if (kIsWeb) {
      return const bool.fromEnvironment(
        'CONFIG_WEB_USE_LAN',
        defaultValue: false,
      )
          ? 'http://$_lanIp:$_backendPort/api'
          : 'http://localhost:$_backendPort/api';
    } else if (Platform.isAndroid) {
      // Pour Android, utiliser l'IP LAN en développement
      return 'http://$_lanIp:$_backendPort/api';
    } else if (Platform.isIOS) {
      return const bool.fromEnvironment(
        'CONFIG_IOS_REAL_DEVICE',
        defaultValue: false,
      )
          ? 'http://$_lanIp:$_backendPort/api'
          : 'http://localhost:$_backendPort/api';
    } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      return 'http://localhost:$_backendPort/api';
    }

    return 'http://localhost:$_backendPort/api';
  }

  /// Build a full media URL for a path returned by the backend.
  /// If [path] is already an absolute URL (starts with http), returns it unchanged.
  /// Otherwise it prefixes the API host root (without the `/api` segment).
  static String mediaUrl(String path) {
    if (path.isEmpty) return path;
    if (path.startsWith('http')) return path;
    final root = baseUrl.replaceFirst('/api', '');
    return '$root$path';
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
  static const Duration requestTimeout = Duration(seconds: 180);

  /// Types de propriétés
  static const List<String> propertyTypes = [
    'apartment',
    'house',
    'villa',
    'studio',
  ];

  /// Types de transaction
  static const List<String> transactionTypes = ['sale', 'rent'];
}
