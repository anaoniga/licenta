import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class SavedService {
  static const String baseUrl = 'http://192.168.1.131:3000/api';

  static Future<List<Map<String, dynamic>>> getSavedPhotos(int userId) async {
    try {
      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/saved/$userId'),
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      print('Eroare getSavedPhotos: $e');
      return [];
    }
  }

  static Future<bool> savePhoto({
    required int userId,
    required int photoId,
    String folder = 'General',
  }) async {
    try {
      final token = await AuthService.getToken();
      final response = await http.post(
        Uri.parse('$baseUrl/saved'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'user_id': userId,
          'photo_id': photoId,
          'folder': folder,
        }),
      );
      return response.statusCode == 201;
    } catch (e) {
      print('Eroare savePhoto: $e');
      return false;
    }
  }

  static Future<bool> unsavePhoto({
    required int userId,
    required int photoId,
  }) async {
    try {
      final token = await AuthService.getToken();
      final response = await http.delete(
        Uri.parse('$baseUrl/saved/$userId/$photoId'),
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Eroare unsavePhoto: $e');
      return false;
    }
  }

  static Future<bool> isSaved({
    required int userId,
    required int photoId,
  }) async {
    try {
      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/saved/check/$userId/$photoId'),
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['isSaved'] ?? false;
      }
      return false;
    } catch (e) {
      print('Eroare isSaved: $e');
      return false;
    }
  }
}