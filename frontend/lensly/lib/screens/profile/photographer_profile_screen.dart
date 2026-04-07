import 'dart:async';

import 'package:flutter/material.dart';

class PhotographerProfileScreen extends StatefulWidget {
  final Map<String, dynamic> photographer;

  const PhotographerProfileScreen({
    super.key,
    required this.photographer,
  });

  @override
  State<PhotographerProfileScreen> createState() =>
      _PhotographerProfileScreenState();
}

class _PhotographerProfileScreenState
    extends State<PhotographerProfileScreen> {
  int _selectedTab = 0;
  bool _isSaved = false;

  final Map<int, String> _calendarEvents = {
    5: 'booked', 6: 'booked',
    12: 'booked', 13: 'booked',
    15: 'available', 16: 'available',
    18: 'available', 19: 'available',
    20: 'booked', 26: 'booked',
    27: 'booked', 29: 'available',
    30: 'available', 31: 'available',
    2: 'available', 3: 'available',
    7: 'available', 8: 'available',
    11: 'available', 21: 'available',
    23: 'available', 24: 'available',
  };

  final List<int> _portofolioColors = [
    0xFFB0A090, 0xFFC4B4A4, 0xFF9C8C7C,
    0xFFD4C4B4, 0xFFA89888, 0xFFBCA898,
    0xFF8C7C6C, 0xFFC8B4A0, 0xFFA09080,
  ];

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
    return Container(
      height: 100,
      color: Color(widget.photographer['color'] ?? 0xFF9C8C7C),
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
              onTap: () => setState(() => _isSaved = !_isSaved),
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
            bottom: -28,
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
                  widget.photographer['name']
                      .toString()
                      .substring(0, 2)
                      .toUpperCase(),
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 36, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.photographer['name'],
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w300,
              color: Color(0xFF3D3530),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            '📍 ${widget.photographer['city']} · ${widget.photographer['style']} · 5+ ani',
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF8C7B6B),
            ),
          ),
          const SizedBox(height: 8),

          Wrap(
            spacing: 5,
            children: [
              widget.photographer['style'],
              'Film look',
              'Natural light',
              'Outdoor',
            ].map((tag) => Container(
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
                  color:  Color(0xFF8C7B6B),
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
          _buildStat('248', 'Lucrări'),
          _buildStatDivider(),
          _buildStat('4.9', 'Rating'),
          _buildStatDivider(),
          _buildStat('5+', 'Ani exp.'),
          _buildStatDivider(),
          _buildStat('12', 'Favorite'),
        ],
      ),
    );
  }

  Widget _buildStat(String value, String label) {
    return Expanded(
      child: Padding(padding: const EdgeInsetsGeometry.symmetric(vertical: 10),
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
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 3, mainAxisSpacing: 3),
      itemCount: _portofolioColors.length,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: Color(_portofolioColors[index]),
            borderRadius: BorderRadius.circular(5),
          ),
        );
      },
    );
  }

  Widget _buildCalendar() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(Icons.chevron_left,
                  color: Color(0xFFC4B9A8), size: 20),
              const Text(
                'Iulie 2025',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                  color: Color(0xFF3D3530),
                ),
              ),
              const Icon(Icons.chevron_right,
                  color: Color(0xFFC4B9A8), size: 20),
            ],
          ),
          const SizedBox(height: 10),

          Row(
            children: ['Lu', 'Ma', 'Mi', 'Jo', 'Vi', 'Sa', 'Du']
                .map((day) => Expanded(child: Text(
                  day,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFFC4BA8),
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
              final day = index -1;
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

    final isToday = day == 10;
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
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        children: [
          _buildContactItem(
            Icons.phone_outlined,
            'Telefon',
            '07xx xxx xxx',
          ),
          _buildContactItem(
            Icons.camera_alt_outlined,
            'Instagram', 
            '@${widget.photographer['name'].toString().split(' ')[0].toLowerCase()}.foto',
          ),
          _buildContactItem(
            Icons.email_outlined,
            'Email',
            '${widget.photographer['name'].toString().split(' ')[0].toLowerCase()}@foto.ro',
          ),
          _buildContactItem(
            Icons.location_on_outlined,
            'Locație',
            widget.photographer['city'],
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
        color: Color(0xFFFAF9F5),
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
              onPressed: () {},
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
                padding: const EdgeInsets.symmetric(vertical: 13),
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
        ],
      ),
    );
  }
}