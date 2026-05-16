import 'package:flutter/material.dart';
import 'package:lensly/services/calendar_service.dart';
import 'package:lensly/services/auth_service.dart';

class CalendarEditScreen extends StatefulWidget {
  const CalendarEditScreen({super.key});

  @override
  State<CalendarEditScreen> createState() => _CalendarEditScreenState();
}

class _CalendarEditScreenState extends State<CalendarEditScreen> {
  bool _isEditMode = true;
  int _currentMonth = DateTime.now().month;
  int _currentYear = DateTime.now().year;

  Map<String, Map<String, dynamic>> _events = {};
  bool _isLoading = true;
  int? _photographerId;

  int? _selectedDay;
  String _selectedType = 'available';
  final TextEditingController _titleController = TextEditingController();

  final List<String> _monthNames = [
    '', 'Ianuarie', 'Februarie', 'Martie', 'Aprilie',
    'Mai', 'Iunie', 'Iulie', 'August', 'Septembrie',
    'Octombrie', 'Noiembrie', 'Decembrie'
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final user = await AuthService.getUser();
    if (user != null) {
      _photographerId = user['id'];
      await _loadEvents();
    }
    setState(() => _isLoading = false);
  }

  Future<void> _loadEvents() async {
    if (_photographerId == null) return;
    final events = await CalendarService.getEvents(
      photographerId: _photographerId!,
      month: _currentMonth,
      year: _currentYear,
    );
    setState(() {
      _events = {};
      for (final event in events) {
        final date = DateTime.parse(event['date']);
        final key = '${date.year}-${date.month}-${date.day}';
        _events[key] = event;
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  String _getEventKey(int day) {
    return '$_currentYear-$_currentMonth-$day';
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
                        children: [
                          _buildCalendar(),
                          const SizedBox(height: 12),
                          _buildLegend(),
                          if (_isEditMode && _selectedDay != null) ...[
                            const SizedBox(height: 16),
                            _buildAddEventPanel(),
                          ],
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
                'Calendar',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w300,
                  color: Color(0xFF3D3530),
                ),
              ),
            ],
          ),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFE8E3DA),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                _buildToggleBtn('Editare', true),
                _buildToggleBtn('Preview', false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleBtn(String label, bool isEdit) {
    final isSelected = _isEditMode == isEdit;
    return GestureDetector(
      onTap: () => setState(() => _isEditMode = isEdit),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFAF8F5) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isSelected
                ? const Color(0xFF3D3530)
                : const Color(0xFFC4B9A8),
            fontWeight: isSelected ? FontWeight.w500 : FontWeight.w300,
          ),
        ),
      ),
    );
  }

  Widget _buildCalendar() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF8F5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
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
                  await _loadEvents();
                },
                child: const Icon(
                  Icons.chevron_left,
                  color: Color(0xFFC4B9A8),
                  size: 22,
                ),
              ),
              Text(
                '${_monthNames[_currentMonth]} $_currentYear',
                style: const TextStyle(
                  fontSize: 15,
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
                  await _loadEvents();
                },
                child: const Icon(
                  Icons.chevron_right,
                  color: Color(0xFFC4B9A8),
                  size: 22,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
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
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
              crossAxisSpacing: 3,
              mainAxisSpacing: 3,
            ),
            itemCount: 35,
            itemBuilder: (context, index) {
              final day = index - 1;
              if (day <= 0 || day > 31) {
                return const SizedBox.shrink();
              }
              return _buildDayCell(day);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDayCell(int day) {
    final key = _getEventKey(day);
    final event = _events[key];
    final status = event?['type'];
    final isSelected = _selectedDay == day;
    final isToday = day == DateTime.now().day &&
        _currentMonth == DateTime.now().month &&
        _currentYear == DateTime.now().year;

    Color bgColor = Colors.transparent;
    Color textColor = const Color(0xFF3D3530);

    if (isSelected) {
      bgColor = const Color(0xFF3D3530);
      textColor = const Color(0xFFF5F2EC);
    } else if (status == 'booked') {
      bgColor = const Color(0xFFFAE8E8);
      textColor = const Color(0xFF8B2E2E);
    } else if (status == 'available') {
      bgColor = const Color(0xFFD4EDE1);
      textColor = const Color(0xFF2D6A4F);
    } else if (status == 'unavailable') {
      bgColor = const Color(0xFFE8E3DA);
      textColor = const Color(0xFFC4B9A8);
    }

    return GestureDetector(
      onTap: () {
        if (_isEditMode) {
          setState(() {
            _selectedDay = day;
            _titleController.clear();
            if (event != null) {
              _selectedType = event['type'];
              _titleController.text = event['title'] ?? '';
            } else {
              _selectedType = 'available';
            }
          });
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(5),
          border: isToday && !isSelected
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
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      children: [
        _buildLegendItem(const Color(0xFFD4EDE1), 'Disponibil'),
        const SizedBox(width: 14),
        _buildLegendItem(const Color(0xFFFAE8E8), 'Rezervat'),
        const SizedBox(width: 14),
        _buildLegendItem(const Color(0xFFE8E3DA), 'Indisponibil'),
      ],
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
          style: const TextStyle(fontSize: 10, color: Color(0xFF8C7B6B)),
        ),
      ],
    );
  }

  Widget _buildAddEventPanel() {
    final key = _getEventKey(_selectedDay!);
    final existingEvent = _events[key];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEDEAE4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ZIUA $_selectedDay ${_monthNames[_currentMonth].toUpperCase()}',
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w500,
              letterSpacing: 1.5,
              color: Color(0xFFC4B9A8),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _titleController,
            style: const TextStyle(fontSize: 13, color: Color(0xFF3D3530)),
            decoration: InputDecoration(
              hintText: 'Titlu privat (ex: Nuntă Popescu)',
              hintStyle: const TextStyle(
                fontSize: 12,
                color: Color(0xFFC4B9A8),
              ),
              filled: true,
              fillColor: const Color(0xFFFAF8F5),
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
          const SizedBox(height: 10),
          Row(
            children: [
              _buildTypeButton('available', 'Disponibil',
                  const Color(0xFFD4EDE1), const Color(0xFF2D6A4F)),
              const SizedBox(width: 6),
              _buildTypeButton('booked', 'Rezervat',
                  const Color(0xFFFAE8E8), const Color(0xFF8B2E2E)),
              const SizedBox(width: 6),
              _buildTypeButton('unavailable', 'Indisponibil',
                  const Color(0xFFE8E3DA), const Color(0xFF8C7B6B)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    if (_photographerId == null) return;

                    final dateStr =
                        '$_currentYear-${_currentMonth.toString().padLeft(2, '0')}-${_selectedDay.toString().padLeft(2, '0')}';

                    final success = await CalendarService.addEvent(
                      photographerId: _photographerId!,
                      date: dateStr,
                      type: _selectedType,
                      title: _titleController.text.isEmpty
                          ? null
                          : _titleController.text,
                      isPublic: false,
                    );

                    if (success) {
                      await _loadEvents();
                      setState(() {
                        _selectedDay = null;
                        _titleController.clear();
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3D3530),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Salvează',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFFF5F2EC),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (existingEvent != null)
                GestureDetector(
                  onTap: () async {
                    final eventId = existingEvent['id'];
                    if (eventId != null) {
                      await CalendarService.deleteEvent(eventId);
                      await _loadEvents();
                      setState(() {
                        _selectedDay = null;
                        _titleController.clear();
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAE8E8),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Șterge',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF8B2E2E),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTypeButton(
    String type,
    String label,
    Color bgColor,
    Color textColor,
  ) {
    final isSelected = _selectedType == type;
    return GestureDetector(
      onTap: () => setState(() => _selectedType = type),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(6),
          border: isSelected
              ? Border.all(color: textColor, width: 1)
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: textColor,
            fontWeight: isSelected ? FontWeight.w500 : FontWeight.w300,
          ),
        ),
      ),
    );
  }
}