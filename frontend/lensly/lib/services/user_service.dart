import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class UserService {
  static const String baseUrl = 'http://192.168.1.131:3000/api';

  static Future<Map<String, dynamic>?> getProfile(int userId) async {
    try {
      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/users/$userId'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print('Eroare getProfile: $e');
      return null;
    }
  }

  static Future<Map<String, dynamic>?> updateProfile({
    required int userId,
    required String name,
    required String city,
    required List<String> specializations,
    String? contactPhone,
    String? contactInstagram,
    String? bio,
  }) async {
    try {
      final token = await AuthService.getToken();
      final response = await http.put(
        Uri.parse('$baseUrl/users/$userId'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'name': name,
          'city': city,
          'specializations': specializations,
          'contact_phone': contactPhone,
          'contact_instagram': contactInstagram,
          'bio': bio,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print('Eroare updateProfile: $e');
      return null;
    }
  }
}