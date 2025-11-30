// lib/screens/services/api_service.dart
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../core/config/app_config.dart';
import '../../models/property.dart';
import '../../models/user.dart';
import '../../core/services/token_service.dart';

class ApiService {
  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final String baseUrl = AppConfig.baseUrl;
  String? _token;

  // Set authentication token
  void setToken(String token) {
    _token = token;
    print(
        '🔑 Token set in ApiService: ${token.length > 20 ? token.substring(0, 20) : token}...');
  }

  // Clear token on logout
  void clearToken() {
    _token = null;
    print('🔓 Token cleared from ApiService');
  }

  // Get headers with authentication (auto-load token)
  Map<String, String> _baseJsonHeaders() => {
        'Content-Type': 'application/json',
      };

  Future<Map<String, String>> _getHeaders() async {
    final headers = _baseJsonHeaders();
    if (_token != null && _token!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_token';
      print('📤 Sending request with in-memory token');
      return headers;
    }
    try {
      final tokenService = await TokenService.getInstance();
      if (tokenService.hasToken) {
        headers['Authorization'] = 'Bearer ${tokenService.token}';
        print('📤 Sending request with stored token');
      } else {
        print('⚠️  No token available for request');
      }
    } catch (e) {
      print('❌ Failed loading token for headers: $e');
    }
    return headers;
  }

  // ========== Authentication APIs ==========

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl${AppConfig.authLogin}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Login failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Login error: $e');
    }
  }

  Future<Map<String, dynamic>> register(
      String name, String email, String password, String role,
      {String? phone}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl${AppConfig.authRegister}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': name,
          'email': email,
          'password': password,
          'role': role,
          if (phone != null && phone.isNotEmpty) 'phone': phone,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final errorBody = json.decode(response.body);
        throw Exception(errorBody['message'] ??
            'Registration failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Registration error: $e');
    }
  }

  Future<User> getCurrentUser() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl${AppConfig.authProfile}'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        return User.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to get user data');
      }
    } catch (e) {
      throw Exception('Get user error: $e');
    }
  }

  Future<User> updateProfile(String name, String phone,
      {String? avatar, String? role}) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl${AppConfig.authProfileUpdate}'),
        headers: await _getHeaders(),
        body: json.encode({
          'name': name,
          'phone': phone,
          if (avatar != null) 'avatar': avatar,
          if (role != null) 'role': role,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return User.fromJson(data['data'] ?? data);
      } else {
        throw Exception('Failed to update profile');
      }
    } catch (e) {
      throw Exception('Update profile error: $e');
    }
  }

  // ========== Property APIs ==========

  Future<List<Property>> getProperties({
    String? city,
    String? type,
    String? transactionType,
    double? minPrice,
    double? maxPrice,
    int? minRooms,
  }) async {
    try {
      // Build query parameters
      final queryParams = <String, String>{};
      if (city != null) queryParams['city'] = city;
      if (type != null) queryParams['type'] = type;
      if (transactionType != null) {
        queryParams['transaction_type'] = transactionType;
      }
      if (minPrice != null) queryParams['min_price'] = minPrice.toString();
      if (maxPrice != null) queryParams['max_price'] = maxPrice.toString();
      if (minRooms != null) queryParams['min_rooms'] = minRooms.toString();

      final uri = Uri.parse('$baseUrl${AppConfig.properties}')
          .replace(queryParameters: queryParams);

      final response = await http.get(uri, headers: await _getHeaders());

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> data = responseData['data'] ?? [];
        return data.map((json) => Property.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load properties');
      }
    } catch (e) {
      throw Exception('Get properties error: $e');
    }
  }

  Future<Property> getPropertyById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl${AppConfig.properties}/$id'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return Property.fromJson(responseData['data'] ?? responseData);
      } else {
        throw Exception('Failed to load property');
      }
    } catch (e) {
      throw Exception('Get property error: $e');
    }
  }

  Future<Property> createProperty(Property property) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl${AppConfig.properties}'),
        headers: await _getHeaders(),
        body: json.encode(property.toJson()),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return Property.fromJson(responseData['data'] ?? responseData);
      } else {
        throw Exception('Failed to create property');
      }
    } catch (e) {
      throw Exception('Create property error: $e');
    }
  }

  Future<void> updateProperty(String id, Property property) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl${AppConfig.properties}/$id'),
        headers: await _getHeaders(),
        body: json.encode(property.toJson()),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update property');
      }
    } catch (e) {
      throw Exception('Update property error: $e');
    }
  }

  Future<void> deleteProperty(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl${AppConfig.properties}/$id'),
        headers: await _getHeaders(),
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete property');
      }
    } catch (e) {
      throw Exception('Delete property error: $e');
    }
  }

  // ========== Favorites APIs ==========

  Future<List<Property>> getFavorites() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl${AppConfig.favorites}'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> data = responseData['data'] ?? [];
        return data.map((json) => Property.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load favorites');
      }
    } catch (e) {
      throw Exception('Get favorites error: $e');
    }
  }

  Future<void> addFavorite(String propertyId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl${AppConfig.favorites}'),
        headers: await _getHeaders(),
        body: json.encode({'property_id': propertyId}),
      );

      if (response.statusCode != 201 && response.statusCode != 200) {
        throw Exception('Failed to add favorite');
      }
    } catch (e) {
      throw Exception('Add favorite error: $e');
    }
  }

  Future<void> removeFavorite(String propertyId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl${AppConfig.favorites}/$propertyId'),
        headers: await _getHeaders(),
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to remove favorite');
      }
    } catch (e) {
      throw Exception('Remove favorite error: $e');
    }
  }

  // ========== Upload Image ==========

  Future<String> uploadImage(String imagePath) async {
    if (kIsWeb) {
      return _uploadImageWeb(imagePath);
    } else {
      return _uploadImageMobile(imagePath);
    }
  }

  // Mobile upload using MultipartRequest
  Future<String> _uploadImageMobile(String imagePath) async {
    try {
      print('📱 Mobile upload starting for: $imagePath');
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl${AppConfig.upload}'),
      );

      // Add authorization header
      final headers = await _getHeaders();
      if (headers['Authorization'] != null) {
        request.headers['Authorization'] = headers['Authorization']!;
      }

      request.files.add(await http.MultipartFile.fromPath('image', imagePath));

      var response = await request.send();

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = await response.stream.bytesToString();
        final data = json.decode(responseData);

        // Extract URL from response
        if (data['data'] != null && data['data']['url'] != null) {
          print('✅ Mobile upload successful: ${data['data']['url']}');
          return data['data']['url'];
        } else if (data['url'] != null) {
          print('✅ Mobile upload successful: ${data['url']}');
          return data['url'];
        } else {
          throw Exception('No URL in upload response');
        }
      } else {
        final responseData = await response.stream.bytesToString();
        final error = json.decode(responseData);
        throw Exception(error['message'] ?? 'Failed to upload image');
      }
    } catch (e) {
      print('❌ Mobile upload error: $e');
      throw Exception('Mobile upload error: $e');
    }
  }

  // Web upload using MultipartRequest with bytes
  Future<String> _uploadImageWeb(String base64DataOrBytes) async {
    try {
      print('🌐 Web upload starting');

      // Convert base64 to bytes if needed
      List<int> bytes;
      String mimeSubtype = 'jpeg';
      if (base64DataOrBytes.startsWith('data:')) {
        // Base64 data URL
        final parts = base64DataOrBytes.split(',');
        final header = parts[0];
        final base64String = parts[1];
        if (header.contains('image/png')) mimeSubtype = 'png';
        if (header.contains('image/webp')) mimeSubtype = 'webp';
        bytes = base64.decode(base64String);
      } else {
        // Already bytes as string (fallback)
        bytes = base64.decode(base64DataOrBytes);
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl${AppConfig.uploadWeb}'),
      );

      // Add authorization header
      final headers = await _getHeaders();
      if (headers['Authorization'] != null) {
        request.headers['Authorization'] = headers['Authorization']!;
      }

      // Add file from bytes
      request.files.add(http.MultipartFile.fromBytes(
        'image', // Field name expected by multer
        bytes,
        filename: 'web-${DateTime.now().millisecondsSinceEpoch}.$mimeSubtype',
        contentType: MediaType('image', mimeSubtype),
      ));

      var response = await request.send();

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = await response.stream.bytesToString();
        final data = json.decode(responseData);

        print('📦 Web upload response: $responseData');

        // Extract URL from response
        if (data['imageUrl'] != null) {
          print('✅ Web upload successful: ${data['imageUrl']}');
          return data['imageUrl'];
        } else if (data['url'] != null) {
          print('✅ Web upload successful: ${data['url']}');
          return data['url'];
        } else if (data['data'] != null && data['data']['url'] != null) {
          print('✅ Web upload successful: ${data['data']['url']}');
          return data['data']['url'];
        } else {
          throw Exception('No URL in upload response');
        }
      } else {
        final responseData = await response.stream.bytesToString();
        print('❌ Web upload failed (${response.statusCode}): $responseData');
        final error = json.decode(responseData);
        throw Exception(
            error['message'] ?? error['error'] ?? 'Failed to upload image');
      }
    } catch (e) {
      print('❌ Web upload error: $e');
      throw Exception('Web upload error: $e');
    }
  }

  // ========== Messaging APIs ==========

  Future<List<dynamic>> getConversations() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl${AppConfig.messages}/conversations'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData['data'] ?? [];
      } else {
        throw Exception('Failed to load conversations');
      }
    } catch (e) {
      throw Exception('Get conversations error: $e');
    }
  }

  Future<List<dynamic>> getMessages(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl${AppConfig.messages}/$userId'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData['data'] ?? [];
      } else {
        throw Exception('Failed to load messages');
      }
    } catch (e) {
      throw Exception('Get messages error: $e');
    }
  }

  Future<Map<String, dynamic>> sendMessage(
    String receiverId,
    String content, {
    String? propertyId,
  }) async {
    try {
      // Convert receiverId to int for backend validation
      final receiverIdInt = int.tryParse(receiverId);
      if (receiverIdInt == null) {
        throw Exception('Invalid receiver ID: must be a number');
      }

      final response = await http.post(
        Uri.parse('$baseUrl${AppConfig.messages}'),
        headers: await _getHeaders(),
        body: json.encode({
          'receiver_id': receiverIdInt,
          'content': content,
          'property_id': propertyId != null ? int.tryParse(propertyId) : null,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData['data'] ?? responseData;
      } else {
        throw Exception('Failed to send message');
      }
    } catch (e) {
      throw Exception('Send message error: $e');
    }
  }

  Future<void> markMessagesAsRead(String userId) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl${AppConfig.messages}/$userId/read'),
        headers: await _getHeaders(),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to mark messages as read');
      }
    } catch (e) {
      throw Exception('Mark as read error: $e');
    }
  }
}
