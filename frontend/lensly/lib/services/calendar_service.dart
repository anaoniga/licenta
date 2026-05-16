import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class CalendarService {
  static const String baseUrl = 'http://10.0.2.2:3000/api';

  static Future<List<Map<String, dynamic>>> getEvents({
    required int photographerId,
    int? month,
    int? year,
  }) async {
    try {
      String url = '$baseUrl/calendar/photographer/$photographerId';
      if (month != null && year != null) {
        url += '?month=$month&year=$year';
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
      print('Eroare getEvents: $e');
      return [];
    }
  }

  static Future<bool> addEvent({
    required int photographerId,
    required String date,
    required String type,
    String? title,
    bool isPublic = false,
  }) async {
    try {
      final token = await AuthService.getToken();
      final response = await http.post(
        Uri.parse('$baseUrl/calendar'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'photographer_id': photographerId,
          'date': date,
          'type': type,
          'title': title,
          'is_public': isPublic,
        }),
      );
      return response.statusCode == 201;
    } catch (e) {
      print('Eroare addEvent: $e');
      return false;
    }
  }

  static Future<bool> deleteEvent(int eventId) async {
    try {
      final token = await AuthService.getToken();
      final response = await http.delete(
        Uri.parse('$baseUrl/calendar/event/$eventId'),
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Eroare deleteEvent: $e');
      return false;
    }
  }
}