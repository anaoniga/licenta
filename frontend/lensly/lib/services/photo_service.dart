import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class PhotoService {
  static const String baseUrl = 'http://192.168.1.131:3000/api';

  static Future<List<Map<String, dynamic>>> getPhotos({
    String? category,
    String? search,
  }) async {
    try {
      String url = '$baseUrl/photos';
      final params = <String, String>{};

      if (category != null && category != 'Toate') {
        params['category'] = category;
      }
      if (search != null && search.isNotEmpty) {
        params['search'] = search;
      }

      if (params.isNotEmpty) {
        url += '?' + params.entries
            .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
            .join('&');
      }

      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      print('Eroare getPhotos: $e');
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> getPhotographerPhotos(
      int photographerId) async {
    try {
      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/photos/photographer/$photographerId'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      print('Eroare getPhotographerPhotos: $e');
      return [];
    }
  }
}