import 'package:flutter/material.dart';
import 'package:lensly/services/calendar_service.dart';
import 'package:lensly/services/auth_service.dart';
import 'package:lensly/services/message_service.dart';
import 'package:lensly/screens/chat/messages_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class PhotographerProfileScreen extends StatefulWidget {
  final Map<String, dynamic> photographer;
  final int initialTab;

  const PhotographerProfileScreen({
    super.key,
    required this.photographer,
    this.initialTab = 0,
  });

  @override
  State<PhotographerProfileScreen> createState() =>
      _PhotographerProfileScreenState();
}

class _PhotographerProfileScreenState
    extends State<PhotographerProfileScreen> {
  late int _selectedTab;
  bool _isSaved = false;
  Map<int, String> _calendarEvents = {};
  bool _calendarLoading = true;
  int _currentMonth = DateTime.now().month;
  int _currentYear = DateTime.now().year;
  List<String> _specializations = [];
  List<Map<String, dynamic>> _portfolioPhotos = [];
  String _contactPhone = '';
  String _contactInstagram = '';
  String _bio = '';

  Map<String, dynamic> _stats = {
    'photos': 0,
    'conversations': 0,
    'saved': 0,
  };

  final List<String> _monthNames = [
    '', 'Ianuarie', 'Februarie', 'Martie', 'Aprilie',
    'Mai', 'Iunie', 'Iulie', 'August', 'Septembrie',
    'Octombrie', 'Noiembrie', 'Decembrie'
  ];

  final List<int> _portfolioColors = [
    0xFFB0A090, 0xFFC4B4A4, 0xFF9C8C7C,
    0xFFD4C4B4, 0xFFA89888, 0xFFBCA898,
    0xFF8C7C6C, 0xFFC8B4A0, 0xFFA09080,
  ];

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.initialTab;
    _loadCalendar();
    _checkIfSaved();
  }

  Future<void> _checkIfSaved() async {
    final user = await AuthService.getUser();
    if (user == null) return;

    final photographerId = widget.photographer['photographer_id']
        ?? widget.photographer['id'];
    if (photographerId == null) return;

    final token = await AuthService.getToken();
    final response = await http.get(
      Uri.parse('http://172.20.10.2:3000/api/saved/photographers/${user['id']}'),
      headers: {
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      final saved = data.any((p) => p['photographer_id'] == photographerId);
      if (mounted) setState(() => _isSaved = saved);
    }
  }

  Future<void> _loadCalendar() async {
    setState(() => _calendarLoading = true);

    final photographerId = widget.photographer['photographer_id']
        ?? widget.photographer['id'];

    if (photographerId == null) {
      setState(() => _calendarLoading = false);
      return;
    }

    final events = await CalendarService.getEvents(
      photographerId: photographerId,
      month: _currentMonth,
      year: _currentYear,
    );

    setState(() {
      _calendarEvents = {};
      for (final event in events) {
        final date = DateTime.parse(event['date']).toLocal();
        _calendarEvents[date.day] = event['type'];
      }
      _calendarLoading = false;
    });

    try {
      final token = await AuthService.getToken();

      final response = await http.get(
        Uri.parse('http://172.20.10.2:3000/api/users/$photographerId'),
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final specs = data['specializations'];
        if (specs != null && specs is List) {
          setState(() {
            _specializations = List<String>.from(specs);
          });
        }
        final statsResponse = await http.get(
          Uri.parse('http://172.20.10.2:3000/api/users/$photographerId/stats'),
          headers: {
            if (token != null) 'Authorization': 'Bearer $token',
          },
        );
        if (statsResponse.statusCode == 200) {
          final statsData = jsonDecode(statsResponse.body);
          setState(() => _stats = statsData);
        }
        setState(() {
          _contactPhone = data['contact_phone'] ?? '';
          _contactInstagram = data['contact_instagram'] ?? '';
          _bio = data['bio'] ?? '';
        });
      }

      final photosResponse = await http.get(
        Uri.parse('http://172.20.10.2:3000/api/photos/photographer/$photographerId'),
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      if (photosResponse.statusCode == 200) {
        final photosData = jsonDecode(photosResponse.body);
        setState(() {
          _portfolioPhotos = List<Map<String, dynamic>>.from(photosData);
        });
      }
    } catch (e) {
      print('Eroare profil: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F2EC),
      body: SafeArea(
        child: Column(
          children: [
            _buildCover(),
            _buildInfo(),
            _buildStats(),
            _buildTabs(),
            Expanded(
              child: _selectedTab == 0
                  ? _buildPortfolio()
                  : _selectedTab == 1
                      ? _buildCalendar()
                      : _buildContact(),
            ),
            _buildCTA(),
          ],
        ),
      ),
    );
  }

  Widget _buildCover() {
    final photographerName = widget.photographer['photographer_name']
        ?? widget.photographer['name']
        ?? 'NA';

    return Container(
      height: 120,
      color: const Color(0xFF9C8C7C),
      child: Stack(
        children: [
          Positioned(
            top: 12,
            left: 12,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
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
            top: 12,
            right: 12,
            child: GestureDetector(
              onTap: () async {
                final user = await AuthService.getUser();
                if (user == null) return;

                final photographerId = widget.photographer['photographer_id']
                    ?? widget.photographer['id'];
                if (photographerId == null) return;

                final token = await AuthService.getToken();

                if (_isSaved) {
                  await http.delete(
                    Uri.parse('http://172.20.10.2:3000/api/saved/photographer/${user['id']}/$photographerId'),
                    headers: {
                      if (token != null) 'Authorization': 'Bearer $token',
                    },
                  );
                  setState(() => _isSaved = false);
                } else {
                  final response = await http.post(
                    Uri.parse('http://172.20.10.2:3000/api/saved/photographer'),
                    headers: {
                      'Content-Type': 'application/json',
                      if (token != null) 'Authorization': 'Bearer $token',
                    },
                    body: jsonEncode({
                      'user_id': user['id'],
                      'photographer_id': photographerId,
                    }),
                  );
                  if (response.statusCode == 201) {
                    setState(() => _isSaved = true);
                  }
                }
              },
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isSaved ? Icons.favorite : Icons.favorite_border,
                  color: _isSaved
                      ? const Color(0xFFC9A96E)
                      : Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -20,
            left: 16,
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFFF5F2EC),
                  width: 3,
                ),
                color: const Color(0xFFE8E3DA),
              ),
              child: Center(
                child: Text(
                  photographerName.length >= 2
                      ? photographerName.substring(0, 2).toUpperCase()
                      : photographerName.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w300,
                    color: Color(0xFF8C7B6B),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfo() {
    final name = widget.photographer['photographer_name']
        ?? widget.photographer['name']
        ?? '';
    final city = widget.photographer['photographer_city']
        ?? widget.photographer['city']
        ?? '';
    final category = widget.photographer['category']
        ?? widget.photographer['style']
        ?? '';

    final tags = _specializations.isNotEmpty
        ? _specializations
        : [category, 'Natural light', 'Outdoor'];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 36, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w300,
              color: Color(0xFF3D3530),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            '📍 $city · $category · 5+ ani',
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF8C7B6B),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 5,
            runSpacing: 5,
            children: tags.map((tag) => Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 3,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFEDEAE4),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                tag,
                style: const TextStyle(
                  fontSize: 10,
                  color: Color(0xFF8C7B6B),
                ),
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      decoration: BoxDecoration(
        color: const Color(0xFFEDEAE4),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          _buildStat('${_stats['photos']}', 'Lucrări'),
          _buildStatDivider(),
          _buildStat('4.9', 'Rating'),
          _buildStatDivider(),
          _buildStat('5+', 'Ani exp.'),
          _buildStatDivider(),
          _buildStat('${_stats['saved']}', 'Favorite'),
        ],
      ),
    );
  }

  Widget _buildStat(String value, String label) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w300,
                color: Color(0xFF3D3530),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 8,
                color: Color(0xFFC4B9A8),
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(
      width: 0.5,
      height: 30,
      color: const Color(0xFFD3D1C7),
    );
  }

  Widget _buildTabs() {
    final tabs = ['Portofoliu', 'Calendar', 'Contact'];
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Row(
        children: tabs.asMap().entries.map((entry) {
          final index = entry.key;
          final label = entry.value;
          final isSelected = _selectedTab == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTab = index),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isSelected
                          ? const Color(0xFF3D3530)
                          : const Color(0xFFE8E3DA),
                      width: isSelected ? 1.5 : 0.5,
                    ),
                  ),
                ),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    letterSpacing: 0.5,
                    color: isSelected
                        ? const Color(0xFF3D3530)
                        : const Color(0xFFC4B9A8),
                    fontWeight: isSelected
                        ? FontWeight.w500
                        : FontWeight.w300,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPortfolio() {
    if (_portfolioPhotos.isEmpty) {
      return const Center(
        child: Text(
          'Nicio fotografie încă',
          style: TextStyle(
            fontSize: 13,
            color: Color(0xFFC4B9A8),
          ),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 3,
        mainAxisSpacing: 3,
      ),
      itemCount: _portfolioPhotos.length,
      itemBuilder: (context, index) {
        final photo = _portfolioPhotos[index];
        return GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (_) => Dialog(
                backgroundColor: Colors.transparent,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    photo['image_url'],
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: photo['image_url'] != null
                ? Image.network(
                    photo['image_url'],
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: const Color(0xFFC4B9A8),
                    ),
                  )
                : Container(color: const Color(0xFFC4B9A8)),
          ),
        );
      },
    );
  }

  Widget _buildCalendar() {
    if (_calendarLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF8C7B6B),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () async {
                  setState(() {
                    if (_currentMonth == 1) {
                      _currentMonth = 12;
                      _currentYear--;
                    } else {
                      _currentMonth--;
                    }
                  });
                  await _loadCalendar();
                },
                child: const Icon(
                  Icons.chevron_left,
                  color: Color(0xFFC4B9A8),
                  size: 20,
                ),
              ),
              Text(
                '${_monthNames[_currentMonth]} $_currentYear',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                  color: Color(0xFF3D3530),
                ),
              ),
              GestureDetector(
                onTap: () async {
                  setState(() {
                    if (_currentMonth == 12) {
                      _currentMonth = 1;
                      _currentYear++;
                    } else {
                      _currentMonth++;
                    }
                  });
                  await _loadCalendar();
                },
                child: const Icon(
                  Icons.chevron_right,
                  color: Color(0xFFC4B9A8),
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: ['Lu', 'Ma', 'Mi', 'Jo', 'Vi', 'Sa', 'Du']
                .map((day) => Expanded(
                      child: Text(
                        day,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFFC4B9A8),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 6),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
              crossAxisSpacing: 2,
              mainAxisSpacing: 2,
            ),
            itemCount: 35,
            itemBuilder: (context, index) {
              final day = index - 1;
              if (day <= 0 || day > 31) {
                return const SizedBox.shrink();
              }
              final status = _calendarEvents[day];
              return _buildCalendarDay(day, status);
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildLegendItem(const Color(0xFFD4EDE1), 'Disponibil'),
              const SizedBox(width: 16),
              _buildLegendItem(const Color(0xFFFAE8E8), 'Rezervat'),
              const SizedBox(width: 16),
              _buildLegendItem(const Color(0xFFE8E3DA), 'Azi'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarDay(int day, String? status) {
    Color bgColor = Colors.transparent;
    Color textColor = const Color(0xFF3D3530);

    if (status == 'booked') {
      bgColor = const Color(0xFFFAE8E8);
      textColor = const Color(0xFF8B2E2E);
    } else if (status == 'available') {
      bgColor = const Color(0xFFD4EDE1);
      textColor = const Color(0xFF2D6A4F);
    }

    final isToday = day == DateTime.now().day &&
        _currentMonth == DateTime.now().month &&
        _currentYear == DateTime.now().year;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(5),
        border: isToday
            ? Border.all(color: const Color(0xFF3D3530), width: 1)
            : null,
      ),
      child: Center(
        child: Text(
          '$day',
          style: TextStyle(
            fontSize: 11,
            color: textColor,
            fontWeight: isToday ? FontWeight.w500 : FontWeight.w300,
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Color(0xFF8C7B6B),
          ),
        ),
      ],
    );
  }

  Widget _buildContact() {
    final city = widget.photographer['photographer_city']
        ?? widget.photographer['city']
        ?? '';

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        children: [
          if (_bio.isNotEmpty)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFEDEAE4),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                _bio,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF3D3530),
                  height: 1.5,
                ),
              ),
            ),
          if (_contactPhone.isNotEmpty)
            _buildContactItem(
              Icons.phone_outlined,
              'Telefon',
              _contactPhone,
            ),
          if (_contactInstagram.isNotEmpty)
            _buildContactItem(
              Icons.camera_alt_outlined,
              'Instagram',
              _contactInstagram,
            ),
          if (city.isNotEmpty)
            _buildContactItem(
              Icons.location_on_outlined,
              'Locație',
              city,
            ),
          if (_contactPhone.isEmpty && _contactInstagram.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'Fotograful nu a adăugat date de contact încă',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFFC4B9A8),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEDEAE4),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF8C7B6B)),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: const TextStyle(
                  fontSize: 9,
                  letterSpacing: 1.5,
                  color: Color(0xFFC4B9A8),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF3D3530),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCTA() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
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
          Expanded(
            child: ElevatedButton(
              onPressed: () async {
                final currentUser = await AuthService.getUser();
                if (currentUser == null) return;

                final photographerId = widget.photographer['photographer_id']
                    ?? widget.photographer['id'];

                final conversation = await MessageService.createConversation(
                  clientId: currentUser['id'],
                  photographerId: photographerId,
                );

                if (conversation != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ConversationScreen(
                        conversation: conversation,
                        currentUser: currentUser,
                        otherName: widget.photographer['photographer_name']
                            ?? widget.photographer['name']
                            ?? '',
                      ),
                    ),
                  );
                }
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
                'Trimite mesaj',
                style: TextStyle(fontSize: 12, letterSpacing: 1),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                setState(() => _selectedTab = 1);
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF8C7B6B),
                padding: const EdgeInsets.symmetric(vertical: 13),
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
        ],
      ),
    );
  }
}