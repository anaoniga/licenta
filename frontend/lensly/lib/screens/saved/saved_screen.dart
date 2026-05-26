import 'package:flutter/material.dart';
import 'package:lensly/services/saved_service.dart';
import 'package:lensly/services/auth_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class SavedScreen extends StatefulWidget {
  const SavedScreen({super.key});

  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
  int _selectedTab = 0;
  String? _selectedFolder;
  List<Map<String, dynamic>> _savedPhotos = [];
  bool _isLoading = true;
  Map<String, dynamic>? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final user = await AuthService.getUser();
    setState(() => _currentUser = user);

    if (user != null) {
      final photos = await SavedService.getSavedPhotos(user['id']);
      setState(() {
        _savedPhotos = photos;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  // grupam pozele pe foldere
  Map<String, List<Map<String, dynamic>>> get _folders {
    final Map<String, List<Map<String, dynamic>>> folders = {};
    for (final photo in _savedPhotos) {
      final folder = photo['folder'] ?? 'General';
      folders.putIfAbsent(folder, () => []);
      folders[folder]!.add(photo);
    }
    return folders;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F2EC),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildTabs(),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF8C7B6B),
                      ),
                    )
                  : _selectedTab == 0
                      ? _selectedFolder == null
                          ? _buildFoldersGrid()
                          : _buildFolderContent()
                      : _buildPhotographersList(),
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
          if (_selectedFolder != null)
            GestureDetector(
              onTap: () => setState(() => _selectedFolder = null),
              child: const Icon(
                Icons.arrow_back_ios,
                size: 18,
                color: Color(0xFF8C7B6B),
              ),
            )
          else
            const SizedBox(width: 18),
          Text(
            _selectedFolder ?? 'Salvate',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w300,
              color: Color(0xFF3D3530),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(width: 60),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    if (_selectedFolder != null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        children: [
          _buildTab('Foldere', 0),
          const SizedBox(width: 8),
          _buildTab('Fotografi', 1),
        ],
      ),
    );
  }

  Widget _buildTab(String label, int index) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF3D3530)
              : const Color(0xFFEDEAE4),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isSelected
                ? const Color(0xFFF5F2EC)
                : const Color(0xFF8C7B6B),
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }

  Widget _buildFoldersGrid() {
    final folders = _folders;

    if (folders.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bookmark_border,
              size: 48,
              color: Color(0xFFC4B9A8),
            ),
            SizedBox(height: 12),
            Text(
              'Nicio fotografie salvată încă',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFFC4B9A8),
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Începe să salvezi fotografii',
              style: TextStyle(
                fontSize: 11,
                color: Color(0xFFC4B9A8),
              ),
            ),
          ],
        ),
      );
    }

    final folderList = folders.entries.toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${folderList.length} foldere · ${_savedPhotos.length} fotografii',
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFFC4B9A8),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.95,
              ),
              itemCount: folderList.length,
              itemBuilder: (context, index) {
                final entry = folderList[index];
                final folderPhotos = entry.value;
                final firstPhoto = folderPhotos.isNotEmpty
                    ? folderPhotos.first
                    : null;

                return GestureDetector(
                  onTap: () =>
                      setState(() => _selectedFolder = entry.key),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: firstPhoto?['image_url'] != null
                              ? Image.network(
                                  firstPhoto!['image_url'],
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  errorBuilder: (_, __, ___) => Container(
                                    color: const Color(0xFFC4B4A4),
                                  ),
                                )
                              : Container(
                                  color: const Color(0xFFC4B4A4),
                                ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        entry.key,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF3D3530),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Text(
                        '${folderPhotos.length} fotografii',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFFC4B9A8),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFolderContent() {
    final photos = _folders[_selectedFolder] ?? [];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${photos.length} fotografii',
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFFC4B9A8),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              itemCount: photos.length,
              itemBuilder: (context, index) {
                final photo = photos[index];
                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: photo['image_url'] != null
                          ? Image.network(
                              photo['image_url'],
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              errorBuilder: (_, __, ___) => Container(
                                color: const Color(0xFFC4B9A8),
                              ),
                            )
                          : Container(
                              color: const Color(0xFFC4B9A8),
                            ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () async {
                          if (_currentUser == null) return;
                          await SavedService.unsavePhoto(
                            userId: _currentUser!['id'],
                            photoId: photo['photo_id'],
                          );
                          await _loadData();
                        },
                        child: Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.4),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.bookmark,
                            color: Color(0xFFC9A96E),
                            size: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotographersList() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _currentUser != null
          ? _loadSavedPhotographers()
          : Future.value([]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF8C7B6B),
            ),
          );
        }

        final photographers = snapshot.data ?? [];

        if (photographers.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.person_outline,
                  size: 48,
                  color: Color(0xFFC4B9A8),
                ),
                SizedBox(height: 12),
                Text(
                  'Niciun fotograf salvat încă',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFFC4B9A8),
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          itemCount: photographers.length,
          itemBuilder: (context, index) {
            final photographer = photographers[index];
            final name = photographer['name'] ?? '';
            final city = photographer['city'] ?? '';
            final specs = photographer['specializations'];
            final specText = specs != null && specs is List && specs.isNotEmpty
                ? specs.first.toString()
                : '';

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFEDEAE4),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: const Color(0xFFC4B4A4),
                    child: Text(
                      name.length >= 2
                          ? name.substring(0, 2).toUpperCase()
                          : name.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF3D3530),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$specText · $city',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFF8C7B6B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.favorite,
                    size: 18,
                    color: Color(0xFFC9A96E),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<List<Map<String, dynamic>>> _loadSavedPhotographers() async {
    final token = await AuthService.getToken();
    final response = await http.get(
      Uri.parse('http://10.0.2.2:3000/api/saved/photographers/${_currentUser!['id']}'),
      headers: {
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    }
    return [];
  }
}