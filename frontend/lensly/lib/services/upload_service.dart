import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:lensly/services/auth_service.dart';

class UploadService {
  static const String baseUrl = 'http://172.20.10.2:3000/api';

  static Future<Map<String, dynamic>?> uploadPhoto({
    required File imageFile,
    required int photographerId,
    required String category,
    String? title,
    String? description,
  }) async {
    try {
      final token = await AuthService.getToken();

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/upload/photo'),
      );

      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      request.fields['photographer_id'] = photographerId.toString();
      request.fields['category'] = category;
      request.fields['title'] = title ?? '';
      request.fields['description'] = description ?? '';

      request.files.add(
        await http.MultipartFile.fromPath('image', imageFile.path),
      );

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 201) {
        return jsonDecode(responseBody);
      }
      return null;
    } catch (e) {
      print('Eroare upload: $e');
      return null;
    }
  }
}