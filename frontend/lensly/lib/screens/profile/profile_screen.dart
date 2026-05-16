import 'package:flutter/material.dart';
import 'package:lensly/services/auth_service.dart';
import 'package:lensly/screens/auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _userName = '';
  String _userEmail = '';

  final List<Map<String, dynamic>> _notes = [
    {
      'text': 'Sesiune couple cu Ana Ionescu',
      'date': '19 iulie 2025 · outdoor dreamy',
      'isImportant': false,
    },
    {
      'text': 'Idei pentru shoot de toamnă',
      'date': 'Octombrie 2025 · de discutat',
      'isImportant': false,
    },
    {
      'text': 'Nuntă - fotograf de rezervat',
      'date': 'Iunie 2026 · urgent',
      'isImportant': true,
    },
  ];

  final TextEditingController _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await AuthService.getUser();
    if (user != null) {
      setState(() {
        _userName = user['name'] ?? '';
        _userEmail = user['email'] ?? '';
      });
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _addNote() {
    if (_noteController.text.trim().isEmpty) return;
    setState(() {
      _notes.add({
        'text': _noteController.text.trim(),
        'date': 'Acum',
        'isImportant': false,
      });
      _noteController.clear();
    });
  }

  void _deleteNote(int index) {
    setState(() {
      _notes.removeAt(index);
    });
  }

  void _toggleImportant(int index) {
    setState(() {
      _notes[index]['isImportant'] = !_notes[index]['isImportant'];
    });
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    _buildNotesSection(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final initials = _userName.length >= 2
        ? _userName.substring(0, 2).toUpperCase()
        : _userName.toUpperCase();

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      child: Column(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: const Color(0xFFE8E3DA),
            child: Text(
              initials,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w300,
                color: Color(0xFF8C7B6B),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _userName,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w300,
              color: Color(0xFF3D3530),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _userEmail,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFFC4B9A8),
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildHeaderButton('Editează profil', Icons.edit_outlined),
              const SizedBox(width: 10),
              _buildHeaderButton('Ieșire cont', Icons.logout_outlined),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderButton(String label, IconData icon) {
    return GestureDetector(
      onTap: () async {
        if (label == 'Ieșire cont') {
          await AuthService.logout();
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: const Color(0xFFEDEAE4),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(icon, size: 13, color: const Color(0xFF8C7B6B)),
            const SizedBox(width: 5),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF8C7B6B),
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesSection() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFEDEAE4),
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.edit_note_outlined,
                size: 18,
                color: Color(0xFF8C7B6B),
              ),
              const SizedBox(width: 6),
              const Text(
                'NOTIȚELE MELE',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 2,
                  color: Color(0xFFC4B9A8),
                ),
              ),
              const Spacer(),
              Text(
                '${_notes.length} notițe',
                style: const TextStyle(
                  fontSize: 10,
                  color: Color(0xFFC4B9A8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ..._notes.asMap().entries.map((entry) {
            final index = entry.key;
            final note = entry.value;
            return _buildNoteItem(note, index);
          }),
          const SizedBox(height: 8),
          const Divider(color: Color(0xFFD3D1C7), height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.add,
                size: 18,
                color: Color(0xFFC4B0A8),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _noteController,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF3D3530),
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Adaugă o notiță...',
                    hintStyle: TextStyle(
                      fontSize: 13,
                      color: Color(0xFFC4B9A8),
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  onSubmitted: (_) => _addNote(),
                ),
              ),
              GestureDetector(
                onTap: _addNote,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: const Color(0xFF3D3530),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.arrow_upward,
                    size: 14,
                    color: Color(0xFFF5F2EC),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNoteItem(Map<String, dynamic> note, int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => _toggleImportant(index),
            child: Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(top: 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: note['isImportant']
                    ? const Color(0xFFC9A96E)
                    : const Color(0xFFC4B9A8),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  note['text'],
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF3D3530),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  note['date'],
                  style: TextStyle(
                    fontSize: 10,
                    color: note['isImportant']
                        ? const Color(0xFFC9A96E)
                        : const Color(0xFFC4B0A8),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _deleteNote(index),
            child: const Padding(
              padding: EdgeInsets.only(left: 8),
              child: Icon(
                Icons.close,
                size: 14,
                color: Color(0xFFC4B9A8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}