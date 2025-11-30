import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../config/app_config.dart';
import '../services/token_service.dart';
import '../../models/property.dart';
import '../../models/user.dart';

/// Service API centralisé avec gestion automatique du token
class ApiService {
  static ApiService? _instance;
  static TokenService? _tokenService;

  ApiService._();

  /// Singleton instance
  static Future<ApiService> getInstance() async {
    _instance ??= ApiService._();
    _tokenService ??= await TokenService.getInstance();
    return _instance!;
  }

  /// Obtenir les headers avec token
  Future<Map<String, String>> _getHeaders() async {
    await _tokenService!.refresh(); // Rafraîchir le token
    final headers = _tokenService!.getAuthHeaders();

    if (_tokenService!.hasToken) {
      print(
          '📤 Request with token: ${_tokenService!.token!.substring(0, 20)}...');
    } else {
      print('⚠️  Request without token');
    }

    return headers;
  }

  /// Helper pour gérer les réponses
  Map<String, dynamic> _handleResponse(
      http.Response response, String endpoint) {
    print('📡 Response from $endpoint: ${response.statusCode}');
    print(
        '📄 Response body: ${response.body.substring(0, response.body.length > 200 ? 200 : response.body.length)}...');

    try {
      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        print('❌ 401 Unauthorized on $endpoint');
        throw Exception('Session expirée. Veuillez vous reconnecter.');
      } else if (response.statusCode == 403) {
        print('❌ 403 Forbidden on $endpoint');
        final errorBody = _tryDecodeJson(response.body);
        final message =
            errorBody['message'] ?? 'Accès refusé. Permissions insuffisantes.';
        throw Exception(message);
      } else if (response.statusCode == 404) {
        print('❌ 404 Not Found on $endpoint');
        throw Exception('Ressource non trouvée');
      } else if (response.statusCode == 413) {
        print('❌ 413 Payload Too Large on $endpoint');
        throw Exception('Fichier trop volumineux (max 5MB)');
      } else if (response.statusCode == 500) {
        print('❌ 500 Internal Server Error on $endpoint');
        final errorBody = _tryDecodeJson(response.body);
        final message =
            errorBody['message'] ?? 'Erreur serveur. Réessayez plus tard.';
        throw Exception(message);
      } else {
        print('❌ Error ${response.statusCode} on $endpoint');
        final errorBody = _tryDecodeJson(response.body);
        final message = errorBody['message'] ??
            'Erreur inattendue (${response.statusCode})';
        throw Exception(message);
      }
    } catch (e) {
      if (e is Exception) rethrow;
      print('❌ Failed to parse response from $endpoint: $e');
      throw Exception('Erreur de traitement de la réponse');
    }
  }

  /// Tentative de décodage JSON avec fallback
  Map<String, dynamic> _tryDecodeJson(String body) {
    try {
      return json.decode(body);
    } catch (e) {
      return {'message': body};
    }
  }

  // ==================== AUTH ====================

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final url = '${AppConfig.baseUrl}${AppConfig.authLogin}';
      print('🔐 Login request to: $url');

      final response = await http
          .post(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'email': email, 'password': password}),
          )
          .timeout(AppConfig.requestTimeout);

      final data = _handleResponse(response, 'login');

      // Sauvegarder le token
      if (data['data'] != null && data['data']['token'] != null) {
        await _tokenService!.saveToken(data['data']['token']);
      }

      return data;
    } catch (e) {
      print('❌ Login error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
    String role, {
    String? phone,
  }) async {
    try {
      final url = '${AppConfig.baseUrl}${AppConfig.authRegister}';
      print('📝 Register request to: $url');

      final response = await http
          .post(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'name': name,
              'email': email,
              'password': password,
              'role': role,
              if (phone != null && phone.isNotEmpty) 'phone': phone,
            }),
          )
          .timeout(AppConfig.requestTimeout);

      final data = _handleResponse(response, 'register');

      // Sauvegarder le token
      if (data['data'] != null && data['data']['token'] != null) {
        await _tokenService!.saveToken(data['data']['token']);
      }

      return data;
    } catch (e) {
      print('❌ Register error: $e');
      rethrow;
    }
  }

  Future<User> getCurrentUser() async {
    try {
      final url = '${AppConfig.baseUrl}${AppConfig.authProfile}';
      print('👤 Get current user from: $url');

      final headers = await _getHeaders();
      final response = await http
          .get(
            Uri.parse(url),
            headers: headers,
          )
          .timeout(AppConfig.requestTimeout);

      final data = _handleResponse(response, 'getCurrentUser');
      return User.fromJson(data['data'] ?? data);
    } catch (e) {
      print('❌ Get current user error: $e');
      rethrow;
    }
  }

  Future<User> updateProfile(String name, String phone,
      {String? avatar, String? role}) async {
    try {
      final url = '${AppConfig.baseUrl}${AppConfig.authProfileUpdate}';
      print('✏️  Update profile to: $url');

      final headers = await _getHeaders();
      final response = await http
          .put(
            Uri.parse(url),
            headers: headers,
            body: json.encode({
              'name': name,
              'phone': phone,
              if (avatar != null) 'avatar': avatar,
              if (role != null) 'role': role,
            }),
          )
          .timeout(AppConfig.requestTimeout);

      final data = _handleResponse(response, 'updateProfile');
      return User.fromJson(data['data'] ?? data);
    } catch (e) {
      print('❌ Update profile error: $e');
      rethrow;
    }
  }

  // ==================== PROPERTIES ====================

  Future<List<Property>> getProperties({
    String? city,
    String? type,
    String? transactionType,
    double? minPrice,
    double? maxPrice,
    int? minRooms,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (city != null) queryParams['city'] = city;
      if (type != null) queryParams['type'] = type;
      if (transactionType != null)
        queryParams['transaction_type'] = transactionType;
      if (minPrice != null) queryParams['min_price'] = minPrice.toString();
      if (maxPrice != null) queryParams['max_price'] = maxPrice.toString();
      if (minRooms != null) queryParams['min_rooms'] = minRooms.toString();

      final uri = Uri.parse('${AppConfig.baseUrl}${AppConfig.properties}')
          .replace(queryParameters: queryParams);

      print('🏠 Get properties from: $uri');

      final headers = await _getHeaders();
      final response = await http
          .get(uri, headers: headers)
          .timeout(AppConfig.requestTimeout);

      final data = _handleResponse(response, 'getProperties');
      final List<dynamic> propertiesList = data['data'] ?? [];
      return propertiesList.map((json) => Property.fromJson(json)).toList();
    } catch (e) {
      print('❌ Get properties error: $e');
      rethrow;
    }
  }

  Future<Property> getPropertyById(String id) async {
    try {
      final url = '${AppConfig.baseUrl}${AppConfig.properties}/$id';
      print('🏠 Get property by ID from: $url');

      final headers = await _getHeaders();
      final response = await http
          .get(
            Uri.parse(url),
            headers: headers,
          )
          .timeout(AppConfig.requestTimeout);

      final data = _handleResponse(response, 'getPropertyById');
      return Property.fromJson(data['data'] ?? data);
    } catch (e) {
      print('❌ Get property by ID error: $e');
      rethrow;
    }
  }

  Future<Property> createProperty(Property property) async {
    try {
      final url = '${AppConfig.baseUrl}${AppConfig.properties}';
      print('➕ Create property to: $url');

      final headers = await _getHeaders();
      final response = await http
          .post(
            Uri.parse(url),
            headers: headers,
            body: json.encode(property.toJson()),
          )
          .timeout(AppConfig.requestTimeout);

      final data = _handleResponse(response, 'createProperty');
      return Property.fromJson(data['data'] ?? data);
    } catch (e) {
      print('❌ Create property error: $e');
      rethrow;
    }
  }

  Future<void> updateProperty(String id, Property property) async {
    try {
      final url = '${AppConfig.baseUrl}${AppConfig.properties}/$id';
      print('✏️  Update property to: $url');

      final headers = await _getHeaders();
      final response = await http
          .put(
            Uri.parse(url),
            headers: headers,
            body: json.encode(property.toJson()),
          )
          .timeout(AppConfig.requestTimeout);

      _handleResponse(response, 'updateProperty');
    } catch (e) {
      print('❌ Update property error: $e');
      rethrow;
    }
  }

  Future<void> deleteProperty(String id) async {
    try {
      final url = '${AppConfig.baseUrl}${AppConfig.properties}/$id';
      print('🗑️  Delete property from: $url');

      final headers = await _getHeaders();
      final response = await http
          .delete(
            Uri.parse(url),
            headers: headers,
          )
          .timeout(AppConfig.requestTimeout);

      _handleResponse(response, 'deleteProperty');
    } catch (e) {
      print('❌ Delete property error: $e');
      rethrow;
    }
  }

  // ==================== FAVORITES ====================

  Future<List<Property>> getFavorites() async {
    try {
      final url = '${AppConfig.baseUrl}${AppConfig.favorites}';
      print('⭐ Get favorites from: $url');

      final headers = await _getHeaders();
      final response = await http
          .get(
            Uri.parse(url),
            headers: headers,
          )
          .timeout(AppConfig.requestTimeout);

      final data = _handleResponse(response, 'getFavorites');
      final List<dynamic> favoritesList = data['data'] ?? [];
      return favoritesList.map((json) => Property.fromJson(json)).toList();
    } catch (e) {
      print('❌ Get favorites error: $e');
      rethrow;
    }
  }

  Future<void> addFavorite(String propertyId) async {
    try {
      final url = '${AppConfig.baseUrl}${AppConfig.favorites}';
      print('➕ Add favorite to: $url');

      final headers = await _getHeaders();
      final response = await http
          .post(
            Uri.parse(url),
            headers: headers,
            body: json.encode({'property_id': propertyId}),
          )
          .timeout(AppConfig.requestTimeout);

      _handleResponse(response, 'addFavorite');
    } catch (e) {
      print('❌ Add favorite error: $e');
      rethrow;
    }
  }

  Future<void> removeFavorite(String propertyId) async {
    try {
      final url = '${AppConfig.baseUrl}${AppConfig.favorites}/$propertyId';
      print('➖ Remove favorite from: $url');

      final headers = await _getHeaders();
      final response = await http
          .delete(
            Uri.parse(url),
            headers: headers,
          )
          .timeout(AppConfig.requestTimeout);

      _handleResponse(response, 'removeFavorite');
    } catch (e) {
      print('❌ Remove favorite error: $e');
      rethrow;
    }
  }

  // ==================== UPLOAD ====================

  Future<String> uploadImage(dynamic imageData) async {
    if (kIsWeb) {
      return _uploadImageWeb(imageData as String);
    } else {
      return _uploadImageMobile(imageData as String);
    }
  }

  Future<String> _uploadImageMobile(String imagePath) async {
    try {
      final url = '${AppConfig.baseUrl}${AppConfig.upload}';
      print('📱 Mobile upload to: $url');

      var request = http.MultipartRequest('POST', Uri.parse(url));

      // Ajouter le token
      if (_tokenService!.hasToken) {
        request.headers['Authorization'] = 'Bearer ${_tokenService!.token}';
      }

      request.files.add(await http.MultipartFile.fromPath('image', imagePath));

      var streamedResponse =
          await request.send().timeout(AppConfig.requestTimeout);
      var response = await http.Response.fromStream(streamedResponse);

      final data = _handleResponse(response, 'uploadImageMobile');

      if (data['data'] != null && data['data']['url'] != null) {
        return data['data']['url'];
      } else if (data['url'] != null) {
        return data['url'];
      } else {
        throw Exception('No URL in upload response');
      }
    } catch (e) {
      print('❌ Mobile upload error: $e');
      rethrow;
    }
  }

  Future<String> _uploadImageWeb(String base64Data) async {
    try {
      final url = '${AppConfig.baseUrl}${AppConfig.uploadWeb}';
      print('🌐 Web upload to: $url');

      // Convert base64 data URL or raw base64 to bytes
      List<int> bytes;
      String mimeSubtype = 'jpeg';
      if (base64Data.startsWith('data:')) {
        final parts = base64Data.split(',');
        final header = parts[0];
        final base64String = parts[1];
        if (header.contains('image/png')) mimeSubtype = 'png';
        if (header.contains('image/webp')) mimeSubtype = 'webp';
        bytes = base64.decode(base64String);
      } else {
        bytes = base64.decode(base64Data);
      }

      var request = http.MultipartRequest('POST', Uri.parse(url));

      // Add authorization header if available
      if (_tokenService!.hasToken) {
        request.headers['Authorization'] = 'Bearer ${_tokenService!.token}';
      }

      request.files.add(http.MultipartFile.fromBytes(
        'image',
        bytes,
        filename: 'web-${DateTime.now().millisecondsSinceEpoch}.$mimeSubtype',
        contentType: MediaType('image', mimeSubtype),
      ));

      final streamed = await request.send().timeout(AppConfig.requestTimeout);
      final response = await http.Response.fromStream(streamed);
      final data = _handleResponse(response, 'uploadImageWeb');

      if (data['imageUrl'] != null) {
        return data['imageUrl'];
      } else if (data['data'] != null && data['data']['url'] != null) {
        return data['data']['url'];
      } else if (data['url'] != null) {
        return data['url'];
      } else {
        throw Exception('No URL in upload response');
      }
    } catch (e) {
      print('❌ Web upload error: $e');
      rethrow;
    }
  }

  // ==================== MESSAGES ====================

  Future<List<dynamic>> getConversations() async {
    try {
      final url = '${AppConfig.baseUrl}${AppConfig.messages}/conversations';
      print('💬 Get conversations from: $url');

      final headers = await _getHeaders();
      final response = await http
          .get(
            Uri.parse(url),
            headers: headers,
          )
          .timeout(AppConfig.requestTimeout);

      final data = _handleResponse(response, 'getConversations');
      return data['data'] ?? [];
    } catch (e) {
      print('❌ Get conversations error: $e');
      rethrow;
    }
  }

  Future<List<dynamic>> getMessages(String userId) async {
    try {
      final url = '${AppConfig.baseUrl}${AppConfig.messages}/$userId';
      print('💬 Get messages from: $url');

      final headers = await _getHeaders();
      final response = await http
          .get(
            Uri.parse(url),
            headers: headers,
          )
          .timeout(AppConfig.requestTimeout);

      final data = _handleResponse(response, 'getMessages');
      return data['data'] ?? [];
    } catch (e) {
      print('❌ Get messages error: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> sendMessage(
    String receiverId,
    String content, {
    String? propertyId,
  }) async {
    try {
      final url = '${AppConfig.baseUrl}${AppConfig.messages}';
      print('📤 Send message to: $url');

      final headers = await _getHeaders();
      final response = await http
          .post(
            Uri.parse(url),
            headers: headers,
            body: json.encode({
              'receiver_id': receiverId,
              'content': content,
              if (propertyId != null) 'property_id': propertyId,
            }),
          )
          .timeout(AppConfig.requestTimeout);

      final data = _handleResponse(response, 'sendMessage');
      return data['data'] ?? data;
    } catch (e) {
      print('❌ Send message error: $e');
      rethrow;
    }
  }

  Future<void> markMessagesAsRead(String userId) async {
    try {
      final url = '${AppConfig.baseUrl}${AppConfig.messages}/$userId/read';
      print('✅ Mark messages as read to: $url');

      final headers = await _getHeaders();
      final response = await http
          .put(
            Uri.parse(url),
            headers: headers,
          )
          .timeout(AppConfig.requestTimeout);

      _handleResponse(response, 'markMessagesAsRead');
    } catch (e) {
      print('❌ Mark messages as read error: $e');
      rethrow;
    }
  }

  // Upload profile image
  Future<Map<String, dynamic>?> uploadProfileImage(String imagePath) async {
    try {
      final url = '${AppConfig.baseUrl}/api/upload/profile';
      print('📤 Upload profile image to: $url');

      var request = http.MultipartRequest('POST', Uri.parse(url));

      // Add token
      if (_tokenService!.hasToken) {
        request.headers['Authorization'] = 'Bearer ${_tokenService!.token}';
      }

      // Add image file
      request.files.add(await http.MultipartFile.fromPath('image', imagePath));

      var streamedResponse =
          await request.send().timeout(AppConfig.requestTimeout);
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Upload failed: ${response.body}');
      }
    } catch (e) {
      print('❌ Upload profile image error: $e');
      rethrow;
    }
  }

  // Upload property images
  Future<Map<String, dynamic>?> uploadPropertyImages(
      int propertyId, List<String> imagePaths) async {
    try {
      final url = '${AppConfig.baseUrl}/api/upload/property/$propertyId';
      print('📤 Upload property images to: $url');

      var request = http.MultipartRequest('POST', Uri.parse(url));

      // Add token
      if (_tokenService!.hasToken) {
        request.headers['Authorization'] = 'Bearer ${_tokenService!.token}';
      }

      // Add multiple image files
      for (final imagePath in imagePaths) {
        request.files
            .add(await http.MultipartFile.fromPath('images', imagePath));
      }

      var streamedResponse =
          await request.send().timeout(AppConfig.requestTimeout);
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Upload failed: ${response.body}');
      }
    } catch (e) {
      print('❌ Upload property images error: $e');
      rethrow;
    }
  }

  // Delete account
  Future<Map<String, dynamic>?> deleteAccount() async {
    try {
      final url = '${AppConfig.baseUrl}/auth/account';
      print('🗑️  Delete account: $url');

      final headers = await _getHeaders();
      final response = await http
          .delete(
            Uri.parse(url),
            headers: headers,
          )
          .timeout(AppConfig.requestTimeout);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Delete failed: ${response.body}');
      }
    } catch (e) {
      print('❌ Delete account error: $e');
      rethrow;
    }
  }
}
