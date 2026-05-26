import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  final List<Map<String, dynamic>> _messages = [
    {
      'role': 'ai',
      'text': 'Bună! sunt asistentul tău foto. Descrie-mi stilul de poze pe care îl cauți și îți găsesc fotografii potriviți.',
      'time': '10:20',
    },
  ];

  final List<Map<String, dynamic>> _suggestedPhotographers = [];

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() async {
  if (_messageController.text.trim().isEmpty) return;

  final userMessage = _messageController.text.trim();
  _messageController.clear();

  setState(() {
    _messages.add({
      'role': 'user',
      'text': userMessage,
      'time': _getCurrentTime(),
    });
    _isLoading = true;
    _suggestedPhotographers.clear();
  });

  _scrollToBottom();

  try {
    final response = await http.post(
      Uri.parse('http://10.0.2.2:3000/api/ai/chat'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'message': userMessage}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _isLoading = false;
        _messages.add({
          'role': 'ai',
          'text': data['message'],
          'time': _getCurrentTime(),
        });

        if (data['photographers'] != null) {
          _suggestedPhotographers.addAll(
            List<Map<String, dynamic>>.from(data['photographers']),
          );
        }
      });
    } else {
      setState(() {
        _isLoading = false;
        _messages.add({
          'role': 'ai',
          'text': 'Îmi pare rău, am întâmpinat o eroare. Încearcă din nou.',
          'time': _getCurrentTime(),
        });
      });
    }
  } catch (e) {
    setState(() {
      _isLoading = false;
      _messages.add({
        'role': 'ai',
        'text': 'Nu mă pot conecta la server. Verifică conexiunea.',
        'time': _getCurrentTime(),
      });
    });
  }

  _scrollToBottom();
}


  String _getCurrentTime() {
    final now = DateTime.now();
    return '${now.hour}:${now.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0XFFF5F2EC),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _buildMessages(),
            ),
            if (_suggestedPhotographers.isNotEmpty)
              _buildSuggestedPhotographers(),
            _buildInputArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      decoration: const BoxDecoration(
        color: Color(0xFFFAF8F5),
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFE8E3DA),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFFEDEAE4),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.auto_awesome_outlined,
              size: 16,
              color: Color(0xFF8C7B6B),
            ),
          ),
          const SizedBox(width: 10),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Asistent foto',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF3D3530),
                ),
              ),
              Text(
                'powered by AI',
                style: TextStyle(
                  fontSize: 10,
                  color: Color(0xFFC4B9A8),
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {
              setState(() {
                _messages.clear();
                _suggestedPhotographers.clear();
                _messages.add({
                  'role': 'ai',
                  'text': 'Bună! Sunt asistentul tău foto. Descrie-mi stilul de poze pe care îl cauți și îți găsesc fotografii potriviți.',
                  'time': _getCurrentTime(),
                });
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFEDEAE4),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Conversație nouă',
                style: TextStyle(
                  fontSize: 10,
                  color: Color(0xFF8C7B6B),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessages() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      itemCount: _messages.length + (_isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _messages.length && _isLoading) {
          return _buildTypingIndicator();
        }
        return _buildMessageBubble(_messages[index]);
      },
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final isAi = message['role'] == 'ai';
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: 
          isAi ? MainAxisAlignment.start : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (isAi) ...[
            Container(
              width: 24,
              height: 24,
              margin: const EdgeInsets.only(right: 6, bottom: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFEDEAE4),
                borderRadius: BorderRadius.circular(7),
              ),
              child: const Icon(
                Icons.auto_awesome_outlined,
                size: 12,
                color: Color(0xFF8C7B6B),
              ),
            ),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isAi
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: isAi
                        ? const Color(0xFFEDEAE4)
                        : const Color(0xFF3D3530),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(12),
                      topRight: const Radius.circular(12),
                      bottomLeft: Radius.circular(isAi ? 2 : 12),
                      bottomRight: Radius.circular(isAi ? 12 : 2),
                    ),
                  ),
                  child: Text(
                    message['text'],
                    style: TextStyle(
                      fontSize: 13,
                      color: isAi
                          ? const Color(0xFF3D3530)
                          : const Color(0XFFF5F2EC),
                      height: 1.45,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  message['time'],
                  style: const TextStyle(
                    fontSize: 9,
                    color: Color(0xFFC4B0A8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            margin: const EdgeInsets.only(right: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFEDEAE4),
              borderRadius: BorderRadius.circular(7),
            ),
            child: const Icon(
              Icons.auto_awesome_outlined,
              size: 12,
              color: Color(0xFF8C7B6B),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFEDEAE4),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
                bottomRight: Radius.circular(12),
                bottomLeft: Radius.circular(2),
              ),
            ),
            child: Row(
              children: List.generate(3, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Color(0xFFC4B9A8),
                    shape: BoxShape.circle,
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

Widget _buildSuggestedPhotographers() {
  return SizedBox(
    height: 88,
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      itemCount: _suggestedPhotographers.length,
      itemBuilder: (context, index) {
        final photographer = _suggestedPhotographers[index];
        return Container(
          width: 65,
          margin: const EdgeInsets.only(right: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: const Color(0xFF9C8C7C),
                child: Text(
                  (photographer['photographer_name'] ?? photographer['name'] ?? 'NA')
                      .toString()
                      .substring(0, 2)
                      .toUpperCase(),
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.white,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                (photographer['photographer_name'] ?? photographer['name'] ?? '')
                    .toString()
                    .split(' ')[0],
                style: const TextStyle(
                  fontSize: 9,
                  color: Color(0xFF3D3530),
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              Text(
                photographer['city'] ?? '',
                style: const TextStyle(
                  fontSize: 8,
                  color: Color(0xFFC4B9A8),
                ),
                maxLines: 1,
              ),
            ],
          ),
        );
      },
    ),
  );
}

Widget _buildInputArea() {
  return Container(
    padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
    decoration: const BoxDecoration(
      color: Color(0xFFFAF8F5),
      border: Border(
        top: BorderSide(
          color: Color(0xFFE8E3DA),
          width: 0.5,
        ),
      ),
    ),
    child: Row(
      children: [
        Expanded(
          child: TextField(
            controller: _messageController,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF3D3530),
            ),
            decoration: InputDecoration(
              hintText: 'Scrie un mesaj...',
              hintStyle: const TextStyle(
                fontSize: 13,
                color: Color(0xFFC4B9A8),
              ),
              filled: true,
              fillColor: const Color(0xFFEDEAE4),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(22),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
            ),
            onSubmitted: (_) => _sendMessage(),
            maxLines: null,
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: _sendMessage,
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFF3D3530),
              borderRadius: BorderRadius.circular(19),
            ),
            child: const Icon(
              Icons.arrow_upward,
              color: Color(0xFFF5F2EC),
              size: 18,
            ),
          ),
        ),
      ],
    ),
  );
} 
}
      
  
    
  