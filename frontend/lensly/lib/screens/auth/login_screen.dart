import 'package:flutter/material.dart';
import 'register_screen.dart';
import '../../services/auth_service.dart';
import '../home/home_screen.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor : const Color(0xFF1C1917),
      body: SafeArea(
        child: SingleChildScrollView(
          padding : const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              const Center(
                child: Text(
                  'discover · book · inspire',
                  style: TextStyle(
                    fontSize: 11,
                    letterSpacing: 3,
                    color: Color(0xFFC4B9A8),
                  ),
                ),
              ),

              const SizedBox(height: 60),

              const Text(
                'EMAIL',
                style: TextStyle(
                  fontSize: 10,
                  letterSpacing: 2,
                  color: Color(0xFFC4B9A8),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(
                  color: Color(0xFFFAF8F5),
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  hintText: 'adresa@email.com',
                  hintStyle: const TextStyle(
                    color: Color(0xFF8C7B6B),
                    fontSize: 14,
                  ),
                  filled: true,
                  fillColor: const Color(0xFF2C2825),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'PAROLĂ',
                style: TextStyle(
                  fontSize: 10,
                  letterSpacing: 2,
                  color: Color(0xFFC4B9A8),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                style: const TextStyle(
                  color: Color(0xFFFAF8F5),
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  hintText: '••••••••',
                  hintStyle: const TextStyle(
                    color: Color(0xFF8C7B6B),
                    fontSize: 14,
                  ),
                  filled: true,
                  fillColor: const Color(0xFF2C2825),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: const Color(0xFF8C7B6B),
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
                      return;
                    }

                    final result = await AuthService.login(
                      email: _emailController.text.trim(),
                      password: _passwordController.text,
                    );

                    if (result['success']) {
                      final user = result['user'];
                      final isPhotographer = user['role'] == 'photographer';

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => HomeScreen(isPhotographer: isPhotographer),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(result['error'] ?? 'Eroare la login'),
                          backgroundColor: const Color(0xFFE24B4A),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC9A96E),
                    foregroundColor: const Color(0xFF1C1917),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Intră în cont',
                    style: TextStyle(
                      fontSize: 14,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.w500,
                    ),
                  )
                ),
              ),

              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RegisterScreen()),
                    );

                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFC4B9A8),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(
                      color: Color(0xFF3D3530),
                      width: 0.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Cont nou',
                    style: TextStyle(
                      fontSize: 14,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              Center(
                child: TextButton(
                  onPressed: () {},
                  child: const Text(
                    'Ai uitat parola? Resetează',
                    style: TextStyle(
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