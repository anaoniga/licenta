import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lensly/services/upload_service.dart';
import 'package:lensly/services/auth_service.dart';
import 'package:lensly/services/photo_service.dart';
import 'package:http/http.dart' as http;

class MyPhotosScreen extends StatefulWidget {
  const MyPhotosScreen({super.key});

  @override
  State<MyPhotosScreen> createState() => _MyPhotosScreenState();
}

class _MyPhotosScreenState extends State<MyPhotosScreen> {
  String _selectedFilter = 'Toate';
  List<Map<String, dynamic>> _photos = [];
  bool _isLoading = true;
  Map<String, dynamic>? _currentUser;

  final List<String> _filters = [
    'Toate', 'Wedding', 'Dreamy', 'Couple',
    'Editorial', 'Portrait', 'Cinematic', 'Pregnancy'
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final user = await AuthService.getUser();
    setState(() => _currentUser = user);

    if (user != null) {
      await _loadPhotos(user['id']);
    }
  }

  Future<void> _loadPhotos(int photographerId) async {
    setState(() => _isLoading = true);
    final photos = await PhotoService.getPhotographerPhotos(photographerId);
    setState(() {
      _photos = photos;
      _isLoading = false;
    });
  }

  List<Map<String, dynamic>> get _filteredPhotos {
    if (_selectedFilter == 'Toate') return _photos;
    return _photos
        .where((p) => p['category'] == _selectedFilter)
        .toList();
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (picked == null) return;

    _showUploadDialog(File(picked.path));
  }

  void _showUploadDialog(File imageFile) {
    final titleController = TextEditingController();
    String selectedCategory = 'Dreamy';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFFAF8F5),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
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
              // preview imagine
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.file(
                  imageFile,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 16),
              // titlu
              const Text(
                'TITLU',
                style: TextStyle(
                  fontSize: 9,
                  letterSpacing: 1.5,
                  color: Color(0xFFC4B9A8),
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: titleController,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF3D3530),
                ),
                decoration: InputDecoration(
                  hintText: 'ex: Lumini de toamnă',
                  hintStyle: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFFC4B9A8),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFEDEAE4),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 14),
              // categorie
              const Text(
                'CATEGORIE',
                style: TextStyle(
                  fontSize: 9,
                  letterSpacing: 1.5,
                  color: Color(0xFFC4B9A8),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: _filters.skip(1).map((cat) {
                  final isSelected = cat == selectedCategory;
                  return GestureDetector(
                    onTap: () => setModalState(
                        () => selectedCategory = cat),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF3D3530)
                            : const Color(0xFFEDEAE4),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        cat,
                        style: TextStyle(
                          fontSize: 11,
                          color: isSelected
                              ? const Color(0xFFF5F2EC)
                              : const Color(0xFF8C7B6B),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              // buton upload
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    await _uploadPhoto(
                      imageFile,
                      titleController.text,
                      selectedCategory,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3D3530),
                    foregroundColor: const Color(0xFFF5F2EC),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Publică în portofoliu',
                    style: TextStyle(
                      fontSize: 13,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _uploadPhoto(
      File imageFile, String title, String category) async {
    if (_currentUser == null) return;

    // aratam loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF8C7B6B),
        ),
      ),
    );

    final result = await UploadService.uploadPhoto(
      imageFile: imageFile,
      photographerId: _currentUser!['id'],
      category: category,
      title: title.isEmpty ? null : title,
    );

    Navigator.pop(context); // inchidem loading

    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Fotografie publicată cu succes!'),
          backgroundColor: Color(0xFF1D9E75),
        ),
      );
      await _loadPhotos(_currentUser!['id']);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Eroare la upload. Încearcă din nou.'),
          backgroundColor: Color(0xFFE24B4A),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F2EC),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildFilters(),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF8C7B6B),
                      ),
                    )
                  : _buildGrid(),
            ),
            _buildFooter(),
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
          Row(
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
              const Text(
                'Fotografiile mele',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w300,
                  color: Color(0xFF3D3530),
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: _pickAndUploadImage,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFF3D3530),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.add,
                color: Color(0xFFF5F2EC),
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
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
                    fontSize: 11,
                    color: isSelected
                        ? const Color(0xFFF5F2EC)
                        : const Color(0xFF8C7B6B),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGrid() {
    final photos = _filteredPhotos;
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: photos.length + 1,
      itemBuilder: (context, index) {
        if (index == photos.length) {
          return _buildAddCell();
        }
        return _buildPhotoCell(photos[index]);
      },
    );
  }

  Widget _buildPhotoCell(Map<String, dynamic> photo) {
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
            onTap: () => _showPhotoOptions(photo),
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.4),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.more_vert,
                color: Colors.white,
                size: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddCell() {
    return GestureDetector(
      onTap: _pickAndUploadImage,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFE8E3DA),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: const Color(0xFFC4B9A8),
            width: 1,
          ),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, color: Color(0xFFC4B9A8), size: 22),
            SizedBox(height: 2),
            Text(
              'Adaugă',
              style: TextStyle(
                fontSize: 9,
                color: Color(0xFFC4B9A8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Color(0xFFE8E3DA), width: 0.5),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '${_photos.length} fotografii',
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFFC4B9A8),
            ),
          ),
          const Text(
            'Sortează ↕',
            style: TextStyle(
              fontSize: 11,
              color: Color(0xFF8C7B6B),
            ),
          ),
        ],
      ),
    );
  }

  void _showPhotoOptions(Map<String, dynamic> photo) {
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
          children: [
            Container(
              width: 32,
              height: 3,
              decoration: BoxDecoration(
                color: const Color(0xFFE8E3DA),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            _buildOption(
              Icons.delete_outline,
              'Șterge fotografia',
              () async {
                Navigator.pop(context);
                // stergere din backend
                final token = await AuthService.getToken();
                if (token != null && photo['id'] != null) {
                  await http.delete(
                    Uri.parse(
                        'http://10.0.2.2:3000/api/photos/${photo['id']}'),
                    headers: {'Authorization': 'Bearer $token'},
                  );
                  await _loadPhotos(_currentUser!['id']);
                }
              },
              isDestructive: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(IconData icon, String label, VoidCallback onTap,
      {bool isDestructive = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Color(0xFFE8E3DA), width: 0.5),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: isDestructive
                  ? const Color(0xFFE24B4A)
                  : const Color(0xFF8C7B6B),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: isDestructive
                    ? const Color(0xFFE24B4A)
                    : const Color(0xFF3D3530),
                fontWeight: FontWeight.w300,
              ),
            ),
          ],
        ),
      ),
    );
  }
}