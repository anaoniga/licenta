import 'package:flutter/material.dart';
import 'package:lensly/services/message_service.dart';
import 'package:lensly/services/auth_service.dart';
import 'package:http/http.dart' as http;

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _conversations = [];
  bool _isLoading = true;
  Map<String, dynamic>? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadData();
    MessageService.connectSocket();
  }

  Future<void> _loadData() async {
    final user = await AuthService.getUser();
    setState(() => _currentUser = user);

    if (user != null) {
      final conversations = await MessageService.getConversations(user['id']);
      setState(() {
        _conversations = conversations;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredConversations {
    if (_searchController.text.isEmpty) return _conversations;
    return _conversations.where((conv) {
      final clientName = conv['client_name']?.toString().toLowerCase() ?? '';
      final photographerName =
          conv['photographer_name']?.toString().toLowerCase() ?? '';
      final search = _searchController.text.toLowerCase();
      return clientName.contains(search) || photographerName.contains(search);
    }).toList();
  }

  String _getOtherPersonName(Map<String, dynamic> conv) {
    if (_currentUser == null) return '';
    final isClient = _currentUser!['id'] == conv['client_id'];
    return isClient
        ? conv['photographer_name'] ?? ''
        : conv['client_name'] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F2EC),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF8C7B6B),
                      ),
                    )
                  : _buildConversationsList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Mesaje',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w300,
              color: Color(0xFF3D3530),
              letterSpacing: 0.5,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFEDEAE4),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              children: [
                Icon(Icons.edit_outlined, size: 13, color: Color(0xFF8C7B6B)),
                SizedBox(width: 4),
                Text(
                  'Nou',
                  style: TextStyle(fontSize: 11, color: Color(0xFF8C7B6B)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: TextField(
        controller: _searchController,
        onChanged: (_) => setState(() {}),
        style: const TextStyle(fontSize: 13, color: Color(0xFF3D3530)),
        decoration: InputDecoration(
          hintText: 'Caută conversație...',
          hintStyle:
              const TextStyle(fontSize: 13, color: Color(0xFFC4B9A8)),
          prefixIcon: const Icon(Icons.search,
              color: Color(0xFFC4B9A8), size: 18),
          filled: true,
          fillColor: const Color(0xFFEDEAE4),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        ),
      ),
    );
  }

  Widget _buildConversationsList() {
    final conversations = _filteredConversations;

    if (conversations.isEmpty) {
      return const Center(
        child: Text(
          'Nicio conversație încă',
          style: TextStyle(fontSize: 14, color: Color(0xFFC4B9A8)),
        ),
      );
    }

    return ListView.builder(
      itemCount: conversations.length,
      itemBuilder: (context, index) {
        return _buildConversationItem(conversations[index]);
      },
    );
  }

  Widget _buildConversationItem(Map<String, dynamic> conversation) {
    final otherName = _getOtherPersonName(conversation);
    final unread = int.tryParse(
            conversation['unread_count']?.toString() ?? '0') ??
        0;
    final hasUnread = unread > 0;
    final initials = otherName.length >= 2
        ? otherName.substring(0, 2).toUpperCase()
        : otherName.toUpperCase();

    return GestureDetector(
      onTap: () async {
        final token = await AuthService.getToken();
        if (token != null) {
          await http.put(
            Uri.parse('http://10.0.2.2:3000/api/messages/read/${conversation['id']}/${_currentUser!['id']}'),
            headers: {'Authorization': 'Bearer $token'},
          );
        }
        
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ConversationScreen(
              conversation: conversation,
              currentUser: _currentUser!,
              otherName: otherName,
            ),
          ),
        ).then((_) => _loadData()); 
      },
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Color(0xFFE8E3DA), width: 0.5),
          ),
        ),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: const Color(0xFFC4B4A4),
                  child: Text(
                    initials,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        otherName,
                        style: TextStyle(
                          fontSize: 14,
                          color: const Color(0xFF3D3530),
                          fontWeight: hasUnread
                              ? FontWeight.w500
                              : FontWeight.w300,
                        ),
                      ),
                      Text(
                        conversation['last_message_time'] != null
                            ? _formatTime(
                                conversation['last_message_time'])
                            : '',
                        style: TextStyle(
                          fontSize: 10,
                          color: hasUnread
                              ? const Color(0xFF3D3530)
                              : const Color(0xFFC4B9A8),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          conversation['last_message'] ?? 'Niciun mesaj',
                          style: TextStyle(
                            fontSize: 12,
                            color: hasUnread
                                ? const Color(0xFF3D3530)
                                : const Color(0xFFC4B9A8),
                            fontWeight: hasUnread
                                ? FontWeight.w400
                                : FontWeight.w300,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                      if (hasUnread)
                        Container(
                          width: 18,
                          height: 18,
                          margin: const EdgeInsets.only(left: 8),
                          decoration: const BoxDecoration(
                            color: Color(0xFF3D3530),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '$unread',
                              style: const TextStyle(
                                fontSize: 10,
                                color: Color(0xFFF5F2EC),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(String timestamp) {
    try {
      final date = DateTime.parse(timestamp);
      final now = DateTime.now();
      final diff = now.difference(date);

      if (diff.inMinutes < 60) return '${diff.inMinutes}m';
      if (diff.inHours < 24) return '${diff.inHours}h';
      if (diff.inDays < 7) return '${diff.inDays}z';
      return '${date.day}.${date.month}';
    } catch (e) {
      return '';
    }
  }
}


class ConversationScreen extends StatefulWidget {
  final Map<String, dynamic> conversation;
  final Map<String, dynamic> currentUser;
  final String otherName;

  const ConversationScreen({
    super.key,
    required this.conversation,
    required this.currentUser,
    required this.otherName,
  });

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> _messages = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    MessageService.joinConversation(widget.conversation['id']);
    MessageService.onReceiveMessage((message) {
      setState(() => _messages.add(message));
      _scrollToBottom();
    });
  }

  Future<void> _loadMessages() async {
    final messages =
        await MessageService.getMessages(widget.conversation['id']);
    setState(() {
      _messages = messages;
      _isLoading = false;
    });
    _scrollToBottom();
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

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    final text = _messageController.text.trim();
    final senderId = widget.currentUser['id'];
    
    print('Trimit mesaj: $text, sender: $senderId, conv: ${widget.conversation['id']}');

    MessageService.sendMessage(
      conversationId: widget.conversation['id'],
      senderId: senderId,
      text: text,
    );

    setState(() {
      _messages.add({
        'sender_id': senderId,
        'text': text,
        'created_at': DateTime.now().toIso8601String(),
      });
    });

    _messageController.clear();
    _scrollToBottom();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F2EC),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF8C7B6B),
                      ),
                    )
                  : _buildMessages(),
            ),
            _buildInputArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final initials = widget.otherName.length >= 2
        ? widget.otherName.substring(0, 2).toUpperCase()
        : widget.otherName.toUpperCase();

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 16, 10),
      decoration: const BoxDecoration(
        color: Color(0xFFFAF8F5),
        border: Border(
          bottom: BorderSide(color: Color(0xFFE8E3DA), width: 0.5),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back_ios,
                size: 18, color: Color(0xFF8C7B6B)),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 18,
            backgroundColor: const Color(0xFFC4B4A4),
            child: Text(
              initials,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.white,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              widget.otherName,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF3D3530),
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          const Icon(Icons.calendar_today_outlined,
              size: 18, color: Color(0xFFC4B9A8)),
        ],
      ),
    );
  }

  Widget _buildMessages() {
    if (_messages.isEmpty) {
      return const Center(
        child: Text(
          'Niciun mesaj încă. Spune Bună! 👋',
          style: TextStyle(fontSize: 13, color: Color(0xFFC4B9A8)),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        return _buildMessageBubble(_messages[index]);
      },
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final isMe = message['sender_id'] == widget.currentUser['id'];

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 14,
              backgroundColor: const Color(0xFFC4B4A4),
              child: Text(
                widget.otherName.substring(0, 1).toUpperCase(),
                style: const TextStyle(fontSize: 9, color: Colors.white),
              ),
            ),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isMe
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 9),
                  decoration: BoxDecoration(
                    color: isMe
                        ? const Color(0xFF3D3530)
                        : const Color(0xFFEDEAE4),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(12),
                      topRight: const Radius.circular(12),
                      bottomLeft: Radius.circular(isMe ? 12 : 2),
                      bottomRight: Radius.circular(isMe ? 2 : 12),
                    ),
                  ),
                  child: Text(
                    message['text'],
                    style: TextStyle(
                      fontSize: 13,
                      color: isMe
                          ? const Color(0xFFF5F2EC)
                          : const Color(0xFF3D3530),
                      height: 1.45,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatTime(message['created_at']),
                  style: const TextStyle(
                      fontSize: 9, color: Color(0xFFC4B9A8)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(String timestamp) {
    try {
      final date = DateTime.parse(timestamp);
      return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return '';
    }
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
      decoration: const BoxDecoration(
        color: Color(0xFFFAF8F5),
        border: Border(
          top: BorderSide(color: Color(0xFFE8E3DA), width: 0.5),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.attach_file_outlined,
              size: 20, color: Color(0xFFC4B9A8)),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _messageController,
              style: const TextStyle(
                  fontSize: 13, color: Color(0xFF3D3530)),
              decoration: InputDecoration(
                hintText: 'Scrie un mesaj...',
                hintStyle: const TextStyle(
                    fontSize: 13, color: Color(0xFFC4B9A8)),
                filled: true,
                fillColor: const Color(0xFFEDEAE4),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(22),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
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
              child: const Icon(Icons.arrow_upward,
                  color: Color(0xFFF5F2EC), size: 18),
            ),
          ),
        ],
      ),
    );
  }
}