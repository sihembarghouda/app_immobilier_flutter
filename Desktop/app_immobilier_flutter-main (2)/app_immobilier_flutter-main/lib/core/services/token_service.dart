import 'storage_service.dart';
import '../config/app_config.dart';

/// Service centralisé pour la gestion du token JWT
class TokenService {
  static TokenService? _instance;
  static StorageService? _storage;

  String? _cachedToken;

  TokenService._();

  /// Singleton instance
  static Future<TokenService> getInstance() async {
    if (_instance == null) {
      _instance = TokenService._();
      _storage = await StorageService.getInstance();
      await _instance!._loadToken();
      print('✅ TokenService initialized');
    }
    return _instance!;
  }

  /// Forcer le rechargement du token depuis le storage
  Future<void> forceReload() async {
    await _loadToken();
  }

  /// Charger le token depuis le stockage
  Future<void> _loadToken() async {
    _cachedToken = _storage!.getString(AppConfig.tokenKey);
    if (_cachedToken != null) {
      print(
          '✅ Token loaded from storage: ${_cachedToken!.substring(0, 20)}...');
    } else {
      print('⚠️  No token found in storage');
    }
  }

  /// Obtenir le token actuel
  String? get token => _cachedToken;

  /// Vérifier si un token existe
  bool get hasToken => _cachedToken != null && _cachedToken!.isNotEmpty;

  /// Sauvegarder le token
  Future<bool> saveToken(String token) async {
    try {
      _cachedToken = token;
      final saved = await _storage!.setString(AppConfig.tokenKey, token);
      if (saved) {
        print('✅ Token saved successfully: ${token.substring(0, 20)}...');
      }
      return saved;
    } catch (e) {
      print('❌ Error saving token: $e');
      return false;
    }
  }

  /// Supprimer le token
  Future<bool> deleteToken() async {
    try {
      _cachedToken = null;
      final deleted = await _storage!.remove(AppConfig.tokenKey);
      if (deleted) {
        print('✅ Token deleted successfully');
      }
      return deleted;
    } catch (e) {
      print('❌ Error deleting token: $e');
      return false;
    }
  }

  /// Rafraîchir le token depuis le stockage
  Future<void> refresh() async {
    await _loadToken();
  }

  /// Obtenir les headers d'authentification
  Map<String, String> getAuthHeaders() {
    if (hasToken) {
      return {
        'Authorization': 'Bearer $_cachedToken',
        'Content-Type': 'application/json',
      };
    }
    return {
      'Content-Type': 'application/json',
    };
  }
}
