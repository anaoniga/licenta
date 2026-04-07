import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class SavedScreen extends StatefulWidget {
  const SavedScreen({super.key});

  @override
  State<SavedScreen> createState() => _SavedScreenState();

}

class _SavedScreenState extends State<SavedScreen> {
  int _selectedTab = 0;

  final List<Map<String, dynamic>> _folders = [
    {'name': 'Wedding', 'count': 34, 'color': 0xFFC4B4A4},
    {'name': 'Dreamy', 'count': 22, 'color': 0xFFB0A090},
    {'name': 'Pregnancy', 'count': 15, 'color': 0xFFD4C4B4},
    {'name': 'Portrait', 'count': 16, 'color': 0xFFBCA898},
    {'name': 'Cinematic', 'count': 8, 'color': 0xFF9C8C7C},
    {'name': 'Editorial', 'count': 11, 'color': 0xFFA89888},
  ];

  final List<Map<String, dynamic>> _savedPhotgraphers = [
    {'name': 'Ana Ionescu', 'style': 'Wedding', 'city': 'Cluj', 'rating': '4.9', 'color': 0xFFB0A090},
    {'name': 'Mihai Popa', 'style': 'Dreamy', 'city': 'București', 'rating': '4.8', 'color': 0xFFC4B4A4},
    {'name': 'Laura Marinescu', 'style': 'Editorial', 'city': 'Iași', 'rating': '5.0', 'color': 0xFFD4C4B4},
    {'name': 'Radu Cristea', 'style': 'Couple', 'city': 'Cluj', 'rating': '4.7', 'color': 0xFF9C8C7C},
  ];

  String? _selectedFolder;

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
              child: _selectedTab == 0
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
      if (_selectedFolder == null)
      GestureDetector(
        onTap: _showAddFolderDialog,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 5,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF3DEAE4),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Row(
            children: [
              Icon(Icons.add, size: 14, color: Color(0xFF8C7B6B)),
              SizedBox(width: 3),
              Text(
                'Folder',
                style: TextStyle(
                  fontSize: 11,
                  color: Color(0xFF8C7B6B),
                ),
              ),
            ],
          ),
        ),
      )
    else
      const SizedBox(width:60),     
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
              : const Color(0XFF8C7B6B),
          letterSpacing: 0.3,
        ),
      ),
    ),
  );
}

Widget _buildFoldersGrid() {
  return Padding(
    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${_folders.length} foldere · ${_folders.fold(0, (sum, f) => sum + (f['count'] as int))} fotografii',
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFFC4B9A8),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: GridView.builder(gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.95,
          ),
          itemCount: _folders.length,
          itemBuilder: (context, index) {
            return _buildFolderCard(_folders[index]);
          },
        ),
      ),
    ],
  ),
);
}

Widget _buildFolderCard(Map<String, dynamic> folder) {
  return GestureDetector(
    onTap: () => setState(() => _selectedFolder = folder['name']),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Color(folder['color']),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          folder['name'],
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF3D3530),
            fontWeight: FontWeight.w400,
          ),
        ),
        Text(
          '${folder['count']} fotografii',
          style: const TextStyle(
            fontSize: 10,
            color: Color(0xFFC4B9A8),
          ),
        ),
      ],
    ),
  );
}

Widget _buildFolderContent() {
  return Padding(
    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${_folders.firstWhere((f) => f['name'] == _selectedFolder)['count']} fotografii',
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFFC4B9A8),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: GridView.builder(gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 4,
            mainAxisSpacing: 4,
          ),
          itemCount: 9,
          itemBuilder: (context, index) {
            final colors = [
              0xFFB0A090, 0xFFC4B4A4, 0xFF9C8C7C,
              0xFFD4C4B4, 0xFFA89888, 0xFFBCA898,
              0xFF8C7C6C, 0xFFC8B4A0, 0xFFA09080,
            ];
            return Container(
              decoration: BoxDecoration(
                color: Color(colors[index]),
                borderRadius: BorderRadius.circular(6),
              ),
            );
          },
        ),
      ),
    ],
  ),
);
}

Widget _buildPhotographersList() {
  return ListView.builder(
    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
    itemCount: _savedPhotgraphers.length,
    itemBuilder: (context, index) {
      return _buildPhotographerItem(_savedPhotgraphers[index]);
    },
  );
}

Widget _buildPhotographerItem(Map<String, dynamic> photographer) {
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
          backgroundColor: Color(photographer['color']),
          child: Text(
            photographer['name'].toString().substring(0, 2).toUpperCase(),
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
                photographer['name'],
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF3D3530),
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${photographer['style']} · ${photographer['city']} · ★ ${photographer['rating']}',
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
}

void _showAddFolderDialog() {
  final controller = TextEditingController();
  showDialog(context: context, builder: (_) => AlertDialog(
    backgroundColor: const Color(0xFFFAF8F5),
    title: const Text(
      'Folder nou',
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w300,
        color: Color(0xFF3D3530),
      ),
    ),
    content: TextField(
      controller: controller,
      autofocus: true,
      style: const TextStyle(
        fontSize: 14,
        color: Color(0xFF3D3530),
      ),
      decoration: InputDecoration(
        hintText: 'Numele folderului',
        hintStyle: const TextStyle(color: Color(0xFFC4BA8)),
        filled: true,
        fillColor: const Color(0xFFEDEAE4),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text(
          'Anulează',
          style: TextStyle(color: Color(0xFF8C7B6B)),
        ),
      ),
      TextButton(
        onPressed: () {
          if (controller.text.trim().isNotEmpty) {
            setState(() {
              _folders.add({
                'name': controller.text.trim(),
                'count': 0,
                'color': 0xFFB0A090
              });
            });
            Navigator.pop(context);
          }
        },
        child: const Text(
          'Creează',
          style: TextStyle(color: Color(0xFF3D3530)),
        ),
      ),
    ],
  ),
);
}
}