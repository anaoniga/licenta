import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:lensly/services/auth_service.dart';
import 'package:lensly/screens/home/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VerifyScreen extends StatefulWidget {
  final int pendingId;
  final String email;

  const VerifyScreen({
    super.key,
    required this.pendingId,
    required this.email,
  });

  @override
  State<VerifyScreen> createState() => _VerifyScreenState();
}

class _VerifyScreenState extends State<VerifyScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  bool _isLoading = false;
  bool _isResending = false;

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    super.dispose();
  }

  String get _code =>
      _controllers.map((c) => c.text).join();

  Future<void> _verify() async {
    if (_code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Introdu codul de 6 cifre'),
          backgroundColor: Color(0xFFE24B4A),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:3000/api/auth/verify'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'pendingId': widget.pendingId,
          'code': _code,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        await AuthService.saveUserData(data['user']);
        final prefs = await _saveToken(data['token']);

        final isPhotographer = data['user']['role'] == 'photographer';

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => HomeScreen(isPhotographer: isPhotographer),
          ),
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['error'] ?? 'Cod incorect'),
            backgroundColor: const Color(0xFFE24B4A),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Eroare de conexiune'),
          backgroundColor: Color(0xFFE24B4A),
        ),
      );
    }

    setState(() => _isLoading = false);
  }

  Future<void> _resend() async {
    setState(() => _isResending = true);

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:3000/api/auth/resend'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'pendingId': widget.pendingId}),
      );

      final data = jsonDecode(response.body);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(data['message'] ?? 'Cod retrimis!'),
          backgroundColor: const Color(0xFF1D9E75),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Eroare la retrimetere'),
          backgroundColor: Color(0xFFE24B4A),
        ),
      );
    }

    setState(() => _isResending = false);
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1917),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(
                  Icons.arrow_back_ios,
                  color: Color(0xFFC4B9A8),
                  size: 20,
                ),
              ),
              const SizedBox(height: 40),
              const Center(
                child: Text(
                  'Lensly',
                  style: TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.w300,
                    color: Color(0xFFFAF8F5),
                    letterSpacing: 2,
                  ),
                ),
              ),
              const SizedBox(height: 50),
              const Text(
                'Verifică emailul',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w300,
                  color: Color(0xFFFAF8F5),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Am trimis un cod de 6 cifre pe\n${widget.email}',
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF8C7B6B),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),
              // input 6 cifre
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) {
                  return SizedBox(
                    width: 44,
                    child: TextField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      style: const TextStyle(
                        fontSize: 24,
                        color: Color(0xFFFAF8F5),
                        fontWeight: FontWeight.w300,
                      ),
                      decoration: InputDecoration(
                        counterText: '',
                        filled: true,
                        fillColor: const Color(0xFF2C2825),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Color(0xFFC9A96E),
                            width: 1,
                          ),
                        ),
                      ),
                      onChanged: (value) {
                        if (value.isNotEmpty && index < 5) {
                          _focusNodes[index + 1].requestFocus();
                        }
                        if (value.isEmpty && index > 0) {
                          _focusNodes[index - 1].requestFocus();
                        }
                        if (index == 5 && value.isNotEmpty) {
                          _verify();
                        }
                        setState(() {});
                      },
                    ),
                  );
                }),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _verify,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC9A96E),
                    foregroundColor: const Color(0xFF1C1917),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          color: Color(0xFF1C1917),
                          strokeWidth: 2,
                        )
                      : const Text(
                          'Verifică',
                          style: TextStyle(
                            fontSize: 14,
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: _isResending ? null : _resend,
                  child: Text(
                    _isResending ? 'Se trimite...' : 'Retrimite codul',
                    style: const TextStyle(
                      color: Color(0xFF8C7B6B),
                      fontSize: 12,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}