import 'package:flutter/material.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> _conversations = [
    {
      'name': 'Ana Ionescu',
      'lastMessage': 'Bună ziua! Referitor la sesiunea din iulie...',
      'time': '10:24',
      'unread': 2,
      'color': 0xFFB0A090,
      'isOnline': true,
    },
    {
      'name': 'Mihai Popa',
      'lastMessage': 'Disponibil în 19 iulie, da!',
      'time': 'ieri',
      'unread': 0,
      'color': 0xFFC4B4A4,
      'isOnline': false,
    },
    {
      'name': 'Laura Marinescu',
      'lastMessage': 'Vă trimit oferta în scurt timp',
      'time': 'lun',
      'unread': 0,
      'color': 0xFFD4C4B4,
      'isOnline': true,
    },
    {
      'name': 'Radu Cristea',
      'lastMessage': 'Mulțumesc pentru mesaj!',
      'time': 'lun',
      'unread': 0,
      'color': 0xFF9C8C7C,
      'isOnline': false,
    },
    {
      'name': 'Mara Dumitru',
      'lastMessage': 'Cu plăcere! Aștept confirmarea.',
      'time': 'dum',
      'unread': 1,
      'color': 0xFFBCA898,
      'isOnline': false,
    },
  ];

  List<Map<String, dynamic>> get _filteredConversations {
    if (_searchController.text.isEmpty) return _conversations;
    return _conversations.where((conv) =>
      conv['name'].toString().toLowerCase()
          .contains(_searchController.text.toLowerCase())
    ).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
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
            _buildSearchBar(),
            Expanded(
              child: _buildConversationsList(),
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
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 5,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFEDEAE4),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.edit_outlined,
                  size: 13,
                  color: Color(0xFF8C7B6B),
                ),
                SizedBox(width: 4),
                Text(
                  'Nou',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF8C7B6B),
                  ),
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
        style: const TextStyle(
          fontSize: 13,
          color: Color(0xFF3D3530),
        ),
        decoration: InputDecoration(
          hintText: 'Caută conversație...',
          hintStyle: const TextStyle(
            fontSize: 13,
            color: Color(0xFFC4B9A8),
          ),
          prefixIcon: const Icon(
            Icons.search,
            color: Color(0xFFC4B9A8),
            size: 18,
          ),
          filled: true,
          fillColor: const Color(0xFFEDEAE4),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 10,
          ),
        ),
      ),
    );
  }

  Widget _buildConversationsList() {
    final conversations = _filteredConversations;

    if (conversations.isEmpty) {
      return const Center(
        child: Text(
          'Nicio conversație găsită',
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFFC4B9A8),
          ),
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
    final hasUnread = conversation['unread'] > 0;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ConversationScreen(
              conversation: conversation,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Color(0xFFE8E3DA),
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Color(conversation['color']),
                  child: Text(
                    conversation['name']
                        .toString()
                        .substring(0, 2)
                        .toUpperCase(),
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                if (conversation['isOnline'])
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1D9E75),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFF5F2EC),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            // info conversatie
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        conversation['name'],
                        style: TextStyle(
                          fontSize: 14,
                          color: const Color(0xFF3D3530),
                          fontWeight: hasUnread
                              ? FontWeight.w500
                              : FontWeight.w300,
                        ),
                      ),
                      Text(
                        conversation['time'],
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
                          conversation['lastMessage'],
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
                              '${conversation['unread']}',
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
}


class ConversationScreen extends StatefulWidget {
  final Map<String, dynamic> conversation;

  const ConversationScreen({
    super.key,
    required this.conversation,
  });

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<Map<String, dynamic>> _messages = [
    {
      'role': 'them',
      'text': 'Bună ziua! Cum vă pot ajuta?',
      'time': '10:20',
    },
    {
      'role': 'me',
      'text': 'Bună! Sunt interesată de o sesiune foto în stilul dreamy, outdoor, undeva în iulie',
      'time': '10:22',
    },
    {
      'role': 'them',
      'text': 'Cu plăcere! Am disponibilitate în 15, 16, 18 și 19 iulie. Puteți verifica și calendarul meu pe profil 😊',
      'time': '10:24',
    },
    {
      'role': 'me',
      'text': '19 iulie ar fi ideal! Cât durează o sesiune?',
      'time': '10:25',
    },
    {
      'role': 'them',
      'text': 'De obicei 2-3 ore, include și editarea fotografiilor. Vă trimit detalii despre prețuri pe email.',
      'time': '10:26',
    },
  ];

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;
    setState(() {
      _messages.add({
        'role': 'me',
        'text': _messageController.text.trim(),
        'time': _getCurrentTime(),
      });
      _messageController.clear();
    });
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

  String _getCurrentTime() {
    final now = DateTime.now();
    return '${now.hour}:${now.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F2EC),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildContextCard(),
            Expanded(
              child: _buildMessages(),
            ),
            _buildInputArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 16, 10),
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
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(
              Icons.arrow_back_ios,
              size: 18,
              color: Color(0xFF8C7B6B),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 18,
            backgroundColor: Color(widget.conversation['color']),
            child: Text(
              widget.conversation['name']
                  .toString()
                  .substring(0, 2)
                  .toUpperCase(),
              style: const TextStyle(
                fontSize: 10,
                color: Colors.white,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.conversation['name'],
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF3D3530),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                if (widget.conversation['isOnline'])
                  const Text(
                    'online acum',
                    style: TextStyle(
                      fontSize: 10,
                      color: Color(0xFF1D9E75),
                    ),
                  ),
              ],
            ),
          ),
          const Icon(
            Icons.calendar_today_outlined,
            size: 18,
            color: Color(0xFFC4B9A8),
          ),
        ],
      ),
    );
  }

  Widget _buildContextCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFEDEAE4),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Color(widget.conversation['color']),
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sesiune foto · ${widget.conversation['name']}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF3D3530),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const Text(
                  'Dreamy · outdoor · iulie 2025',
                  style: TextStyle(
                    fontSize: 10,
                    color: Color(0xFF8C7B6B),
                  ),
                ),
              ],
            ),
          ),
          const Text(
            'Vezi →',
            style: TextStyle(
              fontSize: 10,
              color: Color(0xFFC4B9A8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessages() {
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
    final isMe = message['role'] == 'me';
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
              backgroundColor: Color(widget.conversation['color']),
              child: Text(
                widget.conversation['name']
                    .toString()
                    .substring(0, 1)
                    .toUpperCase(),
                style: const TextStyle(
                  fontSize: 9,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 9,
                  ),
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
                  message['time'],
                  style: const TextStyle(
                    fontSize: 9,
                    color: Color(0xFFC4B9A8),
                  ),
                ),
              ],
            ),
          ),
        ],
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
          const Icon(
            Icons.attach_file_outlined,
            size: 20,
            color: Color(0xFFC4B9A8),
          ),
          const SizedBox(width: 8),
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