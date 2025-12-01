// services/upload_service.dart
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'dart:convert';

class UploadService {
  final String baseUrl;
  final String? token;

  UploadService({
    required this.baseUrl,
    this.token,
  });

  // Upload profile image
  Future<Map<String, dynamic>> uploadProfileImage(File imageFile) async {
    try {
      final uri = Uri.parse('$baseUrl/api/upload/profile');
      final request = http.MultipartRequest('POST', uri);

      // Add authorization header
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      // Add image file
      request.files.add(await http.MultipartFile.fromPath(
        'image',
        imageFile.path,
        filename: basename(imageFile.path),
      ));

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['error'] ?? 'Erreur lors de l\'upload');
      }
    } catch (e) {
      throw Exception('Erreur lors de l\'upload: $e');
    }
  }

  // Upload property images
  Future<Map<String, dynamic>> uploadPropertyImages(
    int propertyId,
    List<File> imageFiles,
  ) async {
    try {
      final uri = Uri.parse('$baseUrl/api/upload/property/$propertyId');
      final request = http.MultipartRequest('POST', uri);

      // Add authorization header
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      // Add multiple image files
      for (final imageFile in imageFiles) {
        request.files.add(await http.MultipartFile.fromPath(
          'images',
          imageFile.path,
          filename: basename(imageFile.path),
        ));
      }

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['error'] ?? 'Erreur lors de l\'upload');
      }
    } catch (e) {
      throw Exception('Erreur lors de l\'upload: $e');
    }
  }

  // Delete property image
  Future<Map<String, dynamic>> deletePropertyImage(
    int propertyId,
    String imageUrl,
  ) async {
    try {
      final uri = Uri.parse('$baseUrl/api/upload/property/$propertyId/image');
      final response = await http.delete(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: json.encode({'imageUrl': imageUrl}),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final error = json.decode(response.body);
        throw Exception(error['error'] ?? 'Erreur lors de la suppression');
      }
    } catch (e) {
      throw Exception('Erreur lors de la suppression: $e');
    }
  }
}
