import 'package:flutter/material.dart';
import 'package:lensly/services/auth_service.dart';
import 'my_photos_screen.dart';
import 'calendar_edit_screen.dart';
import 'package:lensly/screens/auth/login_screen.dart';
import 'package:lensly/screens/photographer/edit_profile_screen.dart';

class PhotographerDashboardScreen extends StatefulWidget {
  const PhotographerDashboardScreen({super.key});

  @override
  State<PhotographerDashboardScreen> createState() =>
      _PhotographerDashboardScreenState();
}

class _PhotographerDashboardScreenState
    extends State<PhotographerDashboardScreen> {
  Map<String, dynamic>? _user;

  final List<Map<String, dynamic>> _recentActivity = [
    {
      'text': 'Ana Maria te-a salvat la favorite',
      'time': '2m',
      'type': 'favorite',
    },
    {
      'text': 'Mesaj nou de la Elena P.',
      'time': '1h',
      'type': 'message',
    },
    {
      'text': 'Profil vizualizat de 14 persoane',
      'time': 'azi',
      'type': 'view',
    },
  ];

  final List<Map<String, dynamic>> _upcomingSessions = [
    {
      'day': '19',
      'month': 'Iul',
      'name': 'Sesiune couple — Radu & Ana',
      'type': 'Dreamy · outdoor · 3h',
      'status': 'confirmed',
    },
    {
      'day': '26',
      'month': 'Iul',
      'name': 'Nuntă — Familia Popescu',
      'type': 'Wedding · full day',
      'status': 'new',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await AuthService.getUser();
    setState(() => _user = user);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F2EC),
      body: SafeArea(
        child: Column(
          children: [
            _buildDarkHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Activitate recentă'),
                    const SizedBox(height: 8),
                    _buildActivityList(),
                    const SizedBox(height: 20),
                    _buildSectionTitle('Acțiuni rapide'),
                    const SizedBox(height: 8),
                    _buildQuickActions(),
                    const SizedBox(height: 20),
                    _buildSectionTitle('Următoarele sesiuni'),
                    const SizedBox(height: 8),
                    _buildSessionsList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDarkHeader() {
    final name = _user?['name'] ?? 'Fotograf';
    final city = _user?['city'] ?? '';
    final initials = name.length >= 2
        ? name.substring(0, 2).toUpperCase()
        : name.toUpperCase();

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      color: const Color(0xFF1C1917),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: const Color(0xFF3D3530),
                    child: Text(
                      initials,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFFC4B9A8),
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w300,
                          color: Color(0xFFFAF8F5),
                        ),
                      ),
                      Text(
                        city.isNotEmpty
                            ? 'FOTOGRAF · ${city.toUpperCase()}'
                            : 'FOTOGRAF',
                        style: const TextStyle(
                          fontSize: 8,
                          letterSpacing: 1.5,
                          color: Color(0xFFC4B9A8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const EditProfileScreen(),
                        ),
                      );
                      // reincarcam datele dupa ce ne intoarcem
                      await _loadUser();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFF3D3530),
                          width: 0.5,
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Editează',
                        style: TextStyle(
                          fontSize: 10,
                          color: Color(0xFFC4B9A8),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () async {
                      await AuthService.logout();
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (route) => false,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFF3D3530),
                          width: 0.5,
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Ieșire',
                        style: TextStyle(
                          fontSize: 10,
                          color: Color(0xFFC4B9A8),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildDarkStat('248', 'Lucrări'),
              _buildDarkStatDivider(),
              _buildDarkStat('3', 'Mesaje'),
              _buildDarkStatDivider(),
              _buildDarkStat('12', 'Favorite'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDarkStat(String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w300,
              color: Color(0xFFFAF8F5),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 8,
              letterSpacing: 1,
              color: Color(0xFFC4B9A8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDarkStatDivider() {
    return Container(
      width: 0.5,
      height: 28,
      color: const Color(0xFF3D3530),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        fontSize: 9,
        fontWeight: FontWeight.w500,
        letterSpacing: 1.5,
        color: Color(0xFFC4B9A8),
      ),
    );
  }

  Widget _buildActivityList() {
    return Column(
      children: _recentActivity.map((activity) {
        Color dotColor;
        switch (activity['type']) {
          case 'favorite':
            dotColor = const Color(0xFFD4EDE1);
            break;
          case 'message':
            dotColor = const Color(0xFFB5D4F4);
            break;
          default:
            dotColor = const Color(0xFFFAC775);
        }
        return Container(
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFEDEAE4),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  activity['text'],
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF3D3530),
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
              Text(
                activity['time'],
                style: const TextStyle(
                  fontSize: 10,
                  color: Color(0xFFC4B9A8),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      {'icon': Icons.add_photo_alternate_outlined, 'label': 'Adaugă foto'},
      {'icon': Icons.calendar_today_outlined, 'label': 'Calendar'},
      {'icon': Icons.edit_outlined, 'label': 'Editează'},
    ];

    return Row(
      children: actions.map((action) {
        return Expanded(
          child: GestureDetector(
            onTap: () async {
              if (action['label'] == 'Adaugă foto') {
                Navigator.push(context, MaterialPageRoute(
                  builder: (_) => const MyPhotosScreen(),
                ));
              } else if (action['label'] == 'Calendar') {
                Navigator.push(context, MaterialPageRoute(
                  builder: (_) => const CalendarEditScreen(),
                ));
              } else if (action['label'] == 'Editează') {
                Navigator.push(context, MaterialPageRoute(
                  builder: (_) => const EditProfileScreen(),
                ));
                await _loadUser();
              }
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFEDEAE4),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Icon(
                    action['icon'] as IconData,
                    size: 22,
                    color: const Color(0xFF8C7B6B),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    action['label'] as String,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF8C7B6B),
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSessionsList() {
    return Column(
      children: _upcomingSessions.map((session) {
        final isNew = session['status'] == 'new';
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFEDEAE4),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 40,
                child: Column(
                  children: [
                    Text(
                      session['day'],
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w300,
                        color: Color(0xFF3D3530),
                        height: 1,
                      ),
                    ),
                    Text(
                      session['month'],
                      style: const TextStyle(
                        fontSize: 9,
                        color: Color(0xFFC4B9A8),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 0.5,
                height: 36,
                color: const Color(0xFFD3D1C7),
                margin: const EdgeInsets.symmetric(horizontal: 10),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session['name'],
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF3D3530),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Text(
                      session['type'],
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF8C7B6B),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: isNew
                      ? const Color(0xFFD4EDE1)
                      : const Color(0xFFE8E3DA),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  isNew ? 'Nou' : 'Conf.',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                    color: isNew
                        ? const Color(0xFF2D6A4F)
                        : const Color(0xFF8C7B6B),
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}