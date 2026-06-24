import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:lensly/services/auth_service.dart';

class MessageService {
  static const String baseUrl = 'http://192.168.1.131:3000/api';
  static const String socketUrl = 'http://192.168.1.131:3000';

  static IO.Socket? _socket;

  static void connectSocket() {
    _socket = IO.io(socketUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });

    _socket!.onConnect((_) {
      print('Socket conectat!');
    });

    _socket!.onDisconnect((_) {
      print('Socket deconectat!');
    });
  }

  static void joinConversation(int conversationId) {
    _socket?.emit('join_conversation', conversationId);
  }

  static void sendMessage({
    required int conversationId,
    required int senderId,
    required String text,
  }) {
    _socket?.emit('send_message', {
      'conversation_id': conversationId,
      'sender_id': senderId,
      'text': text,
    });
  }

  static void onReceiveMessage(Function(Map<String, dynamic>) callback) {
    _socket?.on('receive_message', (data) {
      callback(Map<String, dynamic>.from(data));
    });
  }

  static void disconnect() {
    _socket?.disconnect();
  }

  static Future<List<Map<String, dynamic>>> getConversations(int userId) async {
    try {
      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/messages/conversations/$userId'),
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
      print('Eroare getConversations: $e');
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> getMessages(
      int conversationId) async {
    try {
      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/messages/conversation/$conversationId'),
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
      print('Eroare getMessages: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>?> createConversation({
    required int clientId,
    required int photographerId,
  }) async {
    try {
      final token = await AuthService.getToken();
      final response = await http.post(
        Uri.parse('$baseUrl/messages/conversation'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'client_id': clientId,
          'photographer_id': photographerId,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print('Eroare createConversation: $e');
      return null;
    }
  }
}