import 'package:flutter/material.dart';
import 'package:lensly/services/auth_service.dart';
import 'package:lensly/services/user_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _cityController = TextEditingController();
  final _phoneController = TextEditingController();
  final _instagramController = TextEditingController();
  final _bioController = TextEditingController();

  List<String> _selectedSpecializations = [];
  bool _isLoading = true;
  bool _isSaving = false;
  Map<String, dynamic>? _user;

  final List<String> _allSpecializations = [
    'Wedding', 'Dreamy', 'Couple', 'Portrait',
    'Editorial', 'Cinematic', 'Pregnancy', 'Corporate',
    'Family', 'Newborn', 'Events', 'Fashion',
  ];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = await AuthService.getUser();
    if (user == null) return;

    final profile = await UserService.getProfile(user['id']);

    setState(() {
      _user = user;
      _nameController.text = profile?['name'] ?? user['name'] ?? '';
      _cityController.text = profile?['city'] ?? '';
      _phoneController.text = profile?['contact_phone'] ?? '';
      _instagramController.text = profile?['contact_instagram'] ?? '';
      _bioController.text = profile?['bio'] ?? '';

      final specs = profile?['specializations'];
      if (specs != null && specs is List) {
        _selectedSpecializations = List<String>.from(specs);
      }
      _isLoading = false;
    });
  }

  Future<void> _saveProfile() async {
    if (_user == null) return;

    setState(() => _isSaving = true);

    final result = await UserService.updateProfile(
      userId: _user!['id'],
      name: _nameController.text.trim(),
      city: _cityController.text.trim(),
      specializations: _selectedSpecializations,
      contactPhone: _phoneController.text.trim(),
      contactInstagram: _instagramController.text.trim(),
      bio: _bioController.text.trim(),
    );

    setState(() => _isSaving = false);

    if (result != null) {
      // update local user data
      final updatedUser = {
        ..._user!,
        'name': result['name'],
        'city': result['city'],
      };
      await AuthService.saveUserData(updatedUser);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil actualizat cu succes!'),
          backgroundColor: Color(0xFF1D9E75),
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Eroare la salvare. Încearcă din nou.'),
          backgroundColor: Color(0xFFE24B4A),
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cityController.dispose();
    _phoneController.dispose();
    _instagramController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F2EC),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF8C7B6B),
                ),
              )
            : Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSection('INFORMAȚII'),
                          const SizedBox(height: 10),
                          _buildTextField(_nameController, 'Nume complet', Icons.person_outline),
                          const SizedBox(height: 10),
                          _buildTextField(_cityController, 'Oraș', Icons.location_on_outlined),
                          const SizedBox(height: 10),
                          _buildTextField(_bioController, 'Bio — scurtă descriere', Icons.info_outline, maxLines: 3),
                          const SizedBox(height: 20),
                          _buildSection('SPECIALIZĂRI'),
                          const SizedBox(height: 4),
                          const Text(
                            'Selectează stilurile în care lucrezi',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFFC4B9A8),
                            ),
                          ),
                          const SizedBox(height: 10),
                          _buildSpecializations(),
                          const SizedBox(height: 20),
                          _buildSection('CONTACT'),
                          const SizedBox(height: 10),
                          _buildTextField(_phoneController, 'Număr telefon', Icons.phone_outlined),
                          const SizedBox(height: 10),
                          _buildTextField(_instagramController, 'Instagram (@username)', Icons.camera_alt_outlined),
                          const SizedBox(height: 30),
                          _buildSaveButton(),
                          const SizedBox(height: 20),
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
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
          const Text(
            'Editează profil',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w300,
              color: Color(0xFF3D3530),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 9,
        fontWeight: FontWeight.w500,
        letterSpacing: 1.5,
        color: Color(0xFFC4B9A8),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint,
    IconData icon, {
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(
        fontSize: 13,
        color: Color(0xFF3D3530),
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          fontSize: 13,
          color: Color(0xFFC4B9A8),
        ),
        prefixIcon: Icon(icon, size: 18, color: const Color(0xFFC4B9A8)),
        filled: true,
        fillColor: const Color(0xFFEDEAE4),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }

  Widget _buildSpecializations() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _allSpecializations.map((spec) {
        final isSelected = _selectedSpecializations.contains(spec);
        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedSpecializations.remove(spec);
              } else {
                _selectedSpecializations.add(spec);
              }
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF3D3530)
                  : const Color(0xFFEDEAE4),
              borderRadius: BorderRadius.circular(20),
              border: isSelected
                  ? null
                  : Border.all(
                      color: const Color(0xFFD3D1C7),
                      width: 0.5,
                    ),
            ),
            child: Text(
              spec,
              style: TextStyle(
                fontSize: 12,
                color: isSelected
                    ? const Color(0xFFF5F2EC)
                    : const Color(0xFF8C7B6B),
                fontWeight: isSelected
                    ? FontWeight.w400
                    : FontWeight.w300,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _saveProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF3D3530),
          foregroundColor: const Color(0xFFF5F2EC),
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: _isSaving
            ? const CircularProgressIndicator(
                color: Color(0xFFF5F2EC),
                strokeWidth: 2,
              )
            : const Text(
                'Salvează modificările',
                style: TextStyle(
                  fontSize: 14,
                  letterSpacing: 1,
                ),
              ),
      ),
    );
  }
}