import 'package:flutter/material.dart';

class MyPhotosScreen extends StatefulWidget {
  const MyPhotosScreen({super.key});

  @override
  State<MyPhotosScreen> createState() => _MyPhotosScreenState();
}

class _MyPhotosScreenState extends State<MyPhotosScreen> {
  String _selectedFilter = 'Toate';

  final List<String> _filters = [
    'Toate', 'Wedding', 'Dreamy', 'Couple', 'Editorial', 'Portrait'
  ];

  final List<Map<String, dynamic>> _photos = [
    {'color': 0xFFB0A090, 'category': 'Wedding'},
    {'color': 0xFFC4B4A4, 'category': 'Dreamy'},
    {'color': 0xFF9C8C7C, 'category': 'Couple'},
    {'color': 0xFFD4C4B4, 'category': 'Wedding'},
    {'color': 0xFFA89888, 'category': 'Dreamy'},
    {'color': 0xFFBCA898, 'category': 'Editorial'},
    {'color': 0xFF8C7C6C, 'category': 'Portrait'},
    {'color': 0xFFC8B4A0, 'category': 'Couple'},
    {'color': 0xFFA09080, 'category': 'Wedding'},
  ];

  List<Map<String, dynamic>> get _filteredPhotos {
    if (_selectedFilter == 'Toate') return _photos;
    return _photos.where((p) => p['category'] == _selectedFilter).toList();
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
            Expanded(child: _buildGrid()),
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
          Container(
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
        Container(
          decoration: BoxDecoration(
            color: Color(photo['color']),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        // overlay con opzioni
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
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE8E3DA),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: const Color(0xFFC4B9A8),
          width: 1,
          style: BorderStyle.solid,
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
            '${_photos.length} fotografii · ${_filters.length - 1} categorii',
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
            _buildOption(Icons.edit_outlined, 'Editează categoria', () {
              Navigator.pop(context);
            }),
            _buildOption(Icons.delete_outline, 'Șterge fotografia', () {
              setState(() => _photos.remove(photo));
              Navigator.pop(context);
            }, isDestructive: true),
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