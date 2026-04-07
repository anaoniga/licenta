import 'package:flutter/material.dart';
import 'package:lensly/screens/profile/profile_screen.dart';
import 'package:lensly/screens/saved/saved_screen.dart';
import 'package:lensly/screens/profile/photographer_profile_screen.dart';
import 'package:lensly/screens/chat/ai_chat_screen.dart';
import 'package:lensly/screens/chat/messages_screen.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Map<String, dynamic>> _photos = [
    {'id': 1, 'photographer': 'Ana Ionescu', 'style': 'Dreamy', 'city': 'Cluj', 'color': 0xFFB0A090, 'height': 220.0},
    {'id': 2, 'photographer': 'Mihai Popa', 'style': 'Wedding', 'city': 'București', 'color': 0xFFC4B4A4, 'height': 180.0},
    {'id': 3, 'photographer': 'Laura M.', 'style': 'Couple', 'city': 'Cluj', 'color': 0xFF9C8C7C, 'height': 200.0},
    {'id': 4, 'photographer': 'Radu C.', 'style': 'Editorial', 'city': 'Iași', 'color': 0xFFD4C4B4, 'height': 160.0},
    {'id': 5, 'photographer': 'Mara D.', 'style': 'Dreamy', 'city': 'Cluj', 'color': 0xFFA89888, 'height': 240.0},
    {'id': 6, 'photographer': 'Ion C.', 'style': 'Pregnancy', 'city': 'Sibiu', 'color': 0xFFBCA898, 'height': 190.0},
    {'id': 7, 'photographer': 'Sofia T.', 'style': 'Solo', 'city': 'București', 'color': 0xFF8C7C6C, 'height': 170.0},
    {'id': 8, 'photographer': 'Elena P.', 'style': 'Wedding', 'city': 'Cluj', 'color': 0xFFC8B4A0, 'height': 210.0},
  ];

  final List<String> _filters = [
    'Toate', 'Dreamy', 'Wedding', 'Couple', 'Pregnancy', 'Portrait', 'Editorial', 'Cinematic'
  ];

  String _selectedFilter = 'Toate';
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> get _filteredPhotos {
    return _photos.where((photo) {
      final matchesFilter = _selectedFilter == 'Toate' ||
          photo['style'] == _selectedFilter;
      final matchesSearch = _searchController.text.isEmpty ||
          photo['photographer']
              .toLowerCase()
              .contains(_searchController.text.toLowerCase()) ||
          photo['style']
              .toLowerCase()
              .contains(_searchController.text.toLowerCase()) ||
          photo['city']
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
            padding: const EdgeInsetsGeometry.only(top: 24),
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
  return GestureDetector(
    onTap: () => _showPhotoDetail(photo),
    child: Container(
      margin: const EdgeInsets.only(bottom: 6),
      height: photo['height'],
      decoration: BoxDecoration(
        color: Color(photo['color']),
        borderRadius: BorderRadius.circular(10),
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
            decoration: BoxDecoration(
              color: Color(photo['color']),
            ),
            child: Stack(
              children: [
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
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.4),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.bookmark_border,
                      color: Colors.white,
                      size: 16,
                    ),
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
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(0),
              bottomRight: Radius.circular(0),
            ),
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
                'Sesiune ${photo['style']}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w300,
                  color: Color(0xFF3D3530),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${photo['style']} · outdoor · natural light · ${photo['city']}',
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
                  _buildTag(photo['style']),
                  _buildTag(photo['city']),
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
                    backgroundColor: Color(photo['color']),
                    child: Text(
                      photo['photographer']
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
                          photo['photographer'],
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF3D3530),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Text(
                          '${photo['city']} · ${photo['style']} · ★ 4.9',
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
                      onPressed: () {},
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
                        style: TextStyle(
                          fontSize: 12,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF8C7B6B),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(
                          color: Color(0xFFE8E3DA),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Disponibilitate',
                        style: TextStyle(
                          fontSize: 12,
                          letterSpacing: 0.5,
                        ),
                      ),                     
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEDEAE4),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.bookmark_border,
                      color: Color(0xFF8C7B6B),
                      size: 18,
                    ),
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
  final items = [
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
              onTap: () {
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MessagesScreen()),
                  );            
                } else {
                  setState(() => _currentIndex = index);
                }
              },

              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
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

}
  

 
