import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Service centralisé pour la gestion du stockage local
class StorageService {
  static StorageService? _instance;
  static SharedPreferences? _preferences;

  StorageService._();

  /// Singleton instance
  static Future<StorageService> getInstance() async {
    if (_instance == null) {
      _instance = StorageService._();
      _preferences = await SharedPreferences.getInstance();
      print('✅ StorageService initialized');
    }
    return _instance!;
  }

  /// Vérifier si le service est initialisé
  static bool get isInitialized => _preferences != null;

  /// Sauvegarder une chaîne
  Future<bool> setString(String key, String value) async {
    try {
      return await _preferences!.setString(key, value);
    } catch (e) {
      print('❌ Error saving string: $e');
      return false;
    }
  }

  /// Récupérer une chaîne
  String? getString(String key) {
    try {
      return _preferences!.getString(key);
    } catch (e) {
      print('❌ Error getting string: $e');
      return null;
    }
  }

  /// Sauvegarder un objet JSON
  Future<bool> setJson(String key, Map<String, dynamic> value) async {
    try {
      final jsonString = json.encode(value);
      return await _preferences!.setString(key, jsonString);
    } catch (e) {
      print('❌ Error saving JSON: $e');
      return false;
    }
  }

  /// Récupérer un objet JSON
  Map<String, dynamic>? getJson(String key) {
    try {
      final jsonString = _preferences!.getString(key);
      if (jsonString != null) {
        return json.decode(jsonString) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('❌ Error getting JSON: $e');
      return null;
    }
  }

  /// Sauvegarder un booléen
  Future<bool> setBool(String key, bool value) async {
    try {
      return await _preferences!.setBool(key, value);
    } catch (e) {
      print('❌ Error saving bool: $e');
      return false;
    }
  }

  /// Récupérer un booléen
  bool getBool(String key, {bool defaultValue = false}) {
    try {
      return _preferences!.getBool(key) ?? defaultValue;
    } catch (e) {
      print('❌ Error getting bool: $e');
      return defaultValue;
    }
  }

  /// Supprimer une clé
  Future<bool> remove(String key) async {
    try {
      return await _preferences!.remove(key);
    } catch (e) {
      print('❌ Error removing key: $e');
      return false;
    }
  }

  /// Tout supprimer
  Future<bool> clear() async {
    try {
      return await _preferences!.clear();
    } catch (e) {
      print('❌ Error clearing storage: $e');
      return false;
    }
  }

  /// Vérifier si une clé existe
  bool containsKey(String key) {
    return _preferences!.containsKey(key);
  }
}
