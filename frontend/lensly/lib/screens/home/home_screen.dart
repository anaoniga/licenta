import 'package:flutter/material.dart';
import 'package:lensly/screens/photographer/my_photos_screen.dart';
import 'package:lensly/screens/photographer/photographer_dashboard_screen.dart';
import 'package:lensly/screens/profile/profile_screen.dart';
import 'package:lensly/screens/saved/saved_screen.dart';
import 'package:lensly/screens/profile/photographer_profile_screen.dart';
import 'package:lensly/screens/chat/ai_chat_screen.dart';
import 'package:lensly/screens/chat/messages_screen.dart';
import 'package:lensly/services/photo_service.dart';
import 'package:lensly/services/message_service.dart';
import 'package:lensly/services/auth_service.dart';
import 'package:lensly/services/saved_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  final bool isPhotographer;  
  const HomeScreen({
    super.key,
    this.isPhotographer = false,  
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  List<Map<String, dynamic>> _photos = [];
  bool _isLoading = true;
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _loadPhotos();
    _loadUnreadCount();
  }

  Future<void> _loadPhotos() async {
  setState(() => _isLoading = true);
  try {
    final photos = await PhotoService.getPhotos();
    setState(() {
      _photos = photos;
      _isLoading = false;
    });
  } catch (e) {
    setState(() => _isLoading = false);
  }
}

Future<void> _loadUnreadCount() async {
  final user = await AuthService.getUser();
  if (user == null) return;
  
  final token = await AuthService.getToken();
  final response = await http.get(
    Uri.parse('http://192.168.1.131:3000/api/messages/conversations/${user['id']}'),
    headers: {
      if (token != null) 'Authorization': 'Bearer $token',
    },
  );
  
  if (response.statusCode == 200) {
    final List data = jsonDecode(response.body);
    int total = 0;
    for (final conv in data) {
      total += int.tryParse(conv['unread_count']?.toString() ?? '0') ?? 0;
    }
    if (mounted) setState(() => _unreadCount = total);
  }
}

  final List<String> _filters = [
    'Toate', 'Dreamy', 'Wedding', 'Couple', 'Pregnancy', 'Portrait', 'Editorial', 'Cinematic'
  ];

  String _selectedFilter = 'Toate';
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> get _filteredPhotos {
  return _photos.where((photo) {
    final matchesFilter = _selectedFilter == 'Toate' ||
        photo['category'] == _selectedFilter;
    final matchesSearch = _searchController.text.isEmpty ||
        (photo['photographer_name'] ?? '')
            .toLowerCase()
            .contains(_searchController.text.toLowerCase()) ||
        (photo['category'] ?? '')
            .toLowerCase()
            .contains(_searchController.text.toLowerCase()) ||
        (photo['photographer_city'] ?? '')
            .toLowerCase()
            .contains(_searchController.text.toLowerCase());
    return matchesFilter && matchesSearch;
  }).toList();
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
            _buiuldFilterChips(),
            Expanded(
              child: _buildPinterestWall(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Lensly',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w300,
              color: Color(0xFF3D3530),
              letterSpacing: 1,
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.notifications_outlined,
                  color: Color(0xFF8C7B6B),
                  size: 22,
                ),
                onPressed: () {},
              ),
              const CircleAvatar(
                radius: 16,
                backgroundColor: Color(0xFFE8E3DA),
                child: Text(
                  'AM',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF8C7B6B),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsetsGeometry.fromLTRB(16, 4, 16, 8),
      child: TextField(
        controller: _searchController,
        onChanged: (_) => setState((){}),
        style: const TextStyle(
          color: Color(0xFF3D3530),
          fontSize: 13,
        ),
        decoration: InputDecoration(
          hintText: 'Caută fotograf, stil, localitate...',
          hintStyle: const TextStyle(
            color: Color(0xFFC4B9A8),
            fontSize: 13,
          ),
          prefixIcon: const Icon(
            Icons.search,
            color: Color(0xFFC4B9A8),
            size: 20,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(
                    Icons.close,
                    color: Color(0xFFC4B9A8),
                    size: 18,
                  ),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {});
                  },
                )
              : null,
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

  Widget _buiuldFilterChips() {
    return SizedBox(
      height: 36,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = filter == _selectedFilter;
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: GestureDetector(
              onTap: () => setState(() => _selectedFilter = filter),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF3D3530)
                      : const Color(0xFFE8E3DA),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  filter,
                  style: TextStyle(
                    fontSize: 12,
                    color: isSelected
                        ? const Color(0xFFF5F2EC)
                        : const Color(0xFF8C7B6B),
                    letterSpacing: 0.3,
                ),
              ),           
            ),
          ),
        );
      },
    ),
  );
}

Widget _buildPinterestWall() {
  if (_isLoading) {
    return const Center(
      child: CircularProgressIndicator(
        color: Color(0xFF8C7B6B),
      ),
    );
  }

  final photos = _filteredPhotos;

  if (photos.isEmpty) {
    return const Center(
      child: Text(
        'Nicio fotografie găsită',
        style: TextStyle(
          color: Color(0xFFC4B9A8),
          fontSize: 14,
        ),
      ),
    );
  }

  final leftColumn = <Map<String, dynamic>>[];
  final rightColumn = <Map<String, dynamic>>[];

  for (int i = 0; i < photos.length; i++) {
    if (i % 2 == 0) {
      leftColumn.add(photos[i]);
    } else {
      rightColumn.add(photos[i]);
    }
  }

  return SingleChildScrollView(
    padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            children: leftColumn
                .map((photo) => _buildPhotoCard(photo))
                .toList(),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 24),
            child: Column(
              children: rightColumn
                  .map((photo) => _buildPhotoCard(photo))
                  .toList(),
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _buildPhotoCard(Map<String, dynamic> photo) {
  final isOwn = widget.isPhotographer &&
      photo['photographer_name'] == 'Ana Ionescu';

  // calculam inaltimea random bazata pe id
  final height = photo['id'] != null
      ? 150.0 + (photo['id'] % 5) * 30.0
      : 180.0;

  return GestureDetector(
    onTap: () => _showPhotoDetail(photo),
    child: Container(
      margin: const EdgeInsets.only(bottom: 6),
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFC4B9A8),
        borderRadius: BorderRadius.circular(10),
        border: isOwn
            ? Border.all(color: const Color(0xFFC9A96E), width: 1.5)
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: photo['image_url'] != null
            ? Image.network(
                photo['image_url'],
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: const Color(0xFFC4B9A8),
                ),
              )
            : Container(color: const Color(0xFFC4B9A8)),
      ),
    ),
  );
}

void _showPhotoDetail(Map<String, dynamic> photo) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _buildPhotoDetailSheet(photo),
  );
}

Widget _buildPhotoDetailSheet(Map<String, dynamic> photo) {
  return Container(
    height: MediaQuery.of(context).size.height * 0.85,
    decoration: const BoxDecoration(
      color: Colors.transparent,
    ),
    child: Column(
      children: [
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFF9C8C7C),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (photo['image_url'] != null)
                  Image.network(
                    photo['image_url'],
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: const Color(0xFF9C8C7C),
                    ),
                  ),
                Positioned(
                  top: 16,
                  left: 16,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.4),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ),
                ),
              Positioned(
                top: 16,
                right: 16,
                child: _BookmarkButton(
                  photoId: photo['id'],
                  onSave: (userId, photoId) {
                    _showSaveFolderDialog(userId, photoId, () {});
                  },
                ),
              ),
              ],
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          decoration: const BoxDecoration(
            color: Color(0xFFFAF8F5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 32,
                  height: 3,
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8E3DA),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                'Sesiune ${photo['category'] ?? ''}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w300,
                  color: Color(0xFF3D3530),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${photo['category'] ?? ''} · outdoor · natural light · ${photo['photographer_city'] ?? ''}',
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF8C7B6B),
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                children: [
                  _buildTag(photo['category'] ?? ''),
                  _buildTag(photo['photographer_city'] ?? ''),
                  _buildTag('Natural light'),
                ],
              ),
              const Divider(
                color: Color(0xFFE8E3DA),
                height: 24,
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PhotographerProfileScreen(
                        photographer: photo,
                      ),
                    ),
                  );
                },
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: const Color(0xFF9C8C7C),
                      child: Text(
                        (photo['photographer_name'] ?? 'NA')
                            .toString()
                            .substring(0, 2)
                            .toUpperCase(),
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            photo['photographer_name'] ?? '',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF3D3530),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          Text(
                            '${photo['photographer_city'] ?? ''} · ${photo['category'] ?? ''} · ★ 4.9',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Color(0xFF8C7B6B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: Color(0xFFC4B9A8),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final currentUser = await AuthService.getUser();
                        if (currentUser == null) return;

                        final photographerId = photo['photographer_id'];
                        if (photographerId == null) return;

                        final conversation =
                            await MessageService.createConversation(
                          clientId: currentUser['id'],
                          photographerId: photographerId,
                        );

                        if (conversation != null) {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ConversationScreen(
                                conversation: conversation,
                                currentUser: currentUser,
                                otherName: photo['photographer_name'] ?? '',
                              ),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3D3530),
                        foregroundColor: const Color(0xFFF5F2EC),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Scrie-i',
                        style: TextStyle(fontSize: 12, letterSpacing: 1),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PhotographerProfileScreen(
                              photographer: photo,
                              initialTab: 1,
                            ),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF8C7B6B),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: Color(0xFFE8E3DA)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Disponibilitate',
                        style: TextStyle(fontSize: 12, letterSpacing: 0.5),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _PhotographerBookmarkButton(
                    photographerId: photo['photographer_id'] ?? 0,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _buildTag(String text) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: const Color(0xFFEDEAE4),
      borderRadius: BorderRadius.circular(4),
    ),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 10,
        color: Color(0xFF8C7B6B),
      ),
    ),
  );
}

Widget _buildBottomNav() {
  final items = widget.isPhotographer
    ? [
        {'icon': Icons.home_outlined, 'label': 'Acasă'},
        {'icon': Icons.photo_library_outlined, 'label': 'Fotografii'},
        {'icon': Icons.chat_bubble_outline, 'label': 'Mesaje'},
        {'icon': Icons.person_outline, 'label': 'Profil'},
      ]
    : [
        {'icon': Icons.home_outlined, 'label': 'Acasă'},
        {'icon': Icons.bookmark_border, 'label': 'Salvate'},
        {'icon': Icons.auto_awesome_outlined, 'label': 'AI Chat'},
        {'icon': Icons.chat_bubble_outline, 'label': 'Mesaje'},
        {'icon': Icons.person_outline, 'label': 'Profil'},
      ];

  return Container(
    decoration: const BoxDecoration(
      color: Color(0xFFFAF8F5),
      border: Border(
        top: BorderSide(
          color: Color(0xFFE8E3DA),
          width: 0.5,
        ),
      ),
    ),
    child: SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(items.length, (index) {
            final isActive = index == _currentIndex;
            return GestureDetector(
              onTap: () async {
                if (widget.isPhotographer) {
                  if (index == 1) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MyPhotosScreen(),
                      ));
                  } else if (index == 2) {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MessagesScreen()),
                    );
                    await _loadUnreadCount();
                  } else if (index == 3) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PhotographerDashboardScreen(),
                      ));
                  } else {
                    setState(() => _currentIndex = index);
                  }    
                } else {
                if (index == 4) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProfileScreen()),
                  );
                } else if (index == 1) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => SavedScreen()),
                  );
                } else if (index == 2) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AiChatScreen()),
                  );
                } else if (index == 3) {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MessagesScreen()),
                  );     
                  await _loadUnreadCount();       
                } else {
                  setState(() => _currentIndex = index);
                }
              }
              },

              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  index == (widget.isPhotographer ? 2 : 3)
                      ? Badge(
                          isLabelVisible: _unreadCount > 0,
                          label: Text('$_unreadCount'),
                          backgroundColor: const Color(0xFFE24B4A),
                          child: Icon(
                            items[index]['icon'] as IconData,
                            size: 22,
                            color: isActive
                                ? const Color(0xFF3D3530)
                                : const Color(0xFFC4B9A8),
                          ),
                        )
                      : Icon(
                          items[index]['icon'] as IconData,
                          size: 22,
                          color: isActive
                              ? const Color(0xFF3D3530)
                              : const Color(0xFFC4B9A8),
                        ),
                  const SizedBox(height: 2),
                  Text(
                    items[index]['label'] as String,
                    style: TextStyle(
                      fontSize: 9,
                      color: isActive
                          ? const Color(0xFF3D3530)
                          : const Color(0xFFC4B9A8),
                      fontWeight: isActive
                          ? FontWeight.w500
                          : FontWeight.w300,
                      letterSpacing: 0.3,
                    ),
                  ),
                  if (isActive)
                  Container(
                    margin: const EdgeInsets.only(top: 3),
                    width: 4,
                    height: 4,
                    decoration: const BoxDecoration(
                      color: Color(0xFF3D3530),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    ),
  );
}
void _showSaveFolderDialog(int userId, int photoId, VoidCallback onSaved) {
  final folders = ['General', 'Wedding', 'Dreamy', 'Couple', 'Portrait', 'Editorial'];
  
  showModalBottomSheet(
    context: context,
    backgroundColor: const Color(0xFFFAF8F5),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) => Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 32,
              height: 3,
              decoration: BoxDecoration(
                color: const Color(0xFFE8E3DA),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'SALVEAZĂ ÎN',
            style: TextStyle(
              fontSize: 9,
              letterSpacing: 1.5,
              color: Color(0xFFC4B9A8),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: folders.map((folder) => GestureDetector(
              onTap: () async {
                Navigator.pop(context);
                await SavedService.savePhoto(
                  userId: userId,
                  photoId: photoId,
                  folder: folder,
                );
                onSaved();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Salvat în $folder!'),
                    backgroundColor: const Color(0xFF1D9E75),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEDEAE4),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  folder,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF3D3530),
                  ),
                ),
              ),
            )).toList(),
          ),
          const SizedBox(height: 20),
        ],
      ),
    ),
  );
}

}
class _BookmarkButton extends StatefulWidget {
  final int photoId;
  final Function(int userId, int photoId) onSave;

  const _BookmarkButton({
    required this.photoId,
    required this.onSave,
  });

  @override
  State<_BookmarkButton> createState() => _BookmarkButtonState();
}

class _BookmarkButtonState extends State<_BookmarkButton> {
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    _checkSaved();
  }

  Future<void> _checkSaved() async {
    final user = await AuthService.getUser();
    if (user == null) return;
    final saved = await SavedService.isSaved(
      userId: user['id'],
      photoId: widget.photoId,
    );
    if (mounted) setState(() => _isSaved = saved);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final user = await AuthService.getUser();
        if (user == null) return;

        if (_isSaved) {
          await SavedService.unsavePhoto(
            userId: user['id'],
            photoId: widget.photoId,
          );
          setState(() => _isSaved = false);
        } else {
          widget.onSave(user['id'], widget.photoId);
          setState(() => _isSaved = true);
        }
      },
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.4),
          shape: BoxShape.circle,
        ),
        child: Icon(
          _isSaved ? Icons.bookmark : Icons.bookmark_border,
          color: _isSaved
              ? const Color(0xFFC9A96E)
              : Colors.white,
          size: 16,
        ),
      ),
    );
  }
}

class _PhotographerBookmarkButton extends StatefulWidget {
  final int photographerId;

  const _PhotographerBookmarkButton({
    required this.photographerId,
  });

  @override
  State<_PhotographerBookmarkButton> createState() =>
      _PhotographerBookmarkButtonState();
}

class _PhotographerBookmarkButtonState
    extends State<_PhotographerBookmarkButton> {
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    _checkSaved();
  }

  Future<void> _checkSaved() async {
    final user = await AuthService.getUser();
    if (user == null) return;
    final token = await AuthService.getToken();
    final response = await http.get(
      Uri.parse(
          'http://192.168.1.131:3000/api/saved/photographers/${user['id']}'),
      headers: {
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      final saved = data.any(
          (p) => p['photographer_id'] == widget.photographerId);
      if (mounted) setState(() => _isSaved = saved);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final user = await AuthService.getUser();
        if (user == null) return;
        final token = await AuthService.getToken();

        if (_isSaved) {
          await http.delete(
            Uri.parse(
                'http://192.168.1.131:3000/api/saved/photographer/${user['id']}/${widget.photographerId}'),
            headers: {
              if (token != null) 'Authorization': 'Bearer $token',
            },
          );
          setState(() => _isSaved = false);
        } else {
          final response = await http.post(
            Uri.parse('http://192.168.1.131:3000/api/saved/photographer'),
            headers: {
              'Content-Type': 'application/json',
              if (token != null) 'Authorization': 'Bearer $token',
            },
            body: jsonEncode({
              'user_id': user['id'],
              'photographer_id': widget.photographerId,
            }),
          );
          if (response.statusCode == 201 ||
              response.statusCode == 400) {
            setState(() => _isSaved = true);
          }
        }
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: _isSaved
              ? const Color(0xFF3D3530)
              : const Color(0xFFEDEAE4),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          _isSaved ? Icons.bookmark : Icons.bookmark_border,
          color: _isSaved
              ? const Color(0xFFC9A96E)
              : const Color(0xFF8C7B6B),
          size: 18,
        ),
      ),
    );
  }
}
  

 
