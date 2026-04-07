import 'dart:math';

import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isPhotographer = false;

  bool get _hasMinLength => _passwordController.text.length >= 8;
  bool get _hasUppercase => _passwordController.text.contains(RegExp(r'[A-Z]'));
  bool get _hasNumber => _passwordController.text.contains(RegExp(r'[0-9]'));
  bool get _hasSymbol => _passwordController.text.contains(RegExp(r'[!@#\$%^&*]'));
  bool get _isPasswordValid => _hasMinLength && _hasUppercase && _hasNumber && _hasSymbol;

  int get _passwordStrength {
    int score = 0;
    if (_hasMinLength) score ++;
    if (_hasUppercase) score ++;
    if (_hasNumber) score ++;
    if (_hasSymbol) score ++;
    return score;
  } 

  Color get _strengthColor {
    if (_passwordStrength <= 1) return const Color(0xFFE24B4A);
    if (_passwordStrength <= 2) return const Color(0xFFEF9F27);
    if (_passwordStrength <= 3) return const Color(0xFF9FE1CB);
    return const Color(0xFF1D9E75);
  }

  String get _strengthText {
    if (_passwordController.text.isEmpty) return '';
    if (_passwordStrength <= 1) return 'Slabă';
    if (_passwordStrength <= 2) return 'Medie';
    if (_passwordStrength <= 3) return 'Bună';
    return 'Puternică';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1917),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(
                  Icons.arrow_back_ios,
                  color: Color(0xFFC4B9A8),
                  size: 20,
                ),
                padding: EdgeInsets.zero,
                ),

                const SizedBox(height: 16),

                const Text(
                  'Cont nou',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w300,
                    color: Color(0xFFFAF8F5),
                    letterSpacing: 1,
                  ),
                ),
                const Text(
                  'alege tipul de cont',
                  style: TextStyle(
                    fontSize: 11,
                    letterSpacing: 2,
                    color: Color(0xFFC4B9A8),
                  ),
                ),

                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isPhotographer = false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: !_isPhotographer
                                ? const Color(0xFF2C2825)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: !_isPhotographer
                                  ? const Color(0xFFC9A96E)
                                  : const Color(0xFF3D3530),
                              width: !_isPhotographer ? 1 : 0.5,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.person_outline,
                                color: !_isPhotographer
                                    ? const Color(0xFFC9A96E)
                                    : const Color(0xFF8C7B6B),
                                size: 28,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Client',
                                style: TextStyle(
                                  fontSize: 12,
                                  letterSpacing: 1,
                                  color: !_isPhotographer
                                      ? const Color(0xFFC9A96E)
                                      : const Color(0xFF8C7B6B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isPhotographer = true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: _isPhotographer
                                ? const Color(0xFF2C2825)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: _isPhotographer
                                  ? const Color(0xFFC9A96E)
                                  : const Color(0xFF3D3530),
                              width: _isPhotographer ? 1 : 0.5,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.camera_alt_outlined,
                                color: _isPhotographer
                                    ? const Color(0xFFC9A96E)
                                    : const Color(0xFF8C7B6B),
                                size: 28,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Fotograf',
                                style: TextStyle(
                                  fontSize: 12,
                                  letterSpacing: 1,
                                  color: _isPhotographer
                                      ? const Color(0xFFC9A96E)
                                      : const Color(0xFF8C7B6B),
                                ),
                              ),
                            ],
                          ),
                        ),                         
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                _buildLabel('NUME COMPLET'),
                const SizedBox(height: 8),
                _buildTextField(_nameController, 'Ana Ionescu'),

                const SizedBox(height: 18),

                _buildLabel('EMAIL'),
                const SizedBox(height: 8),
                _buildTextField(_emailController, 'adresa@email.com',
                    keyboardType: TextInputType.emailAddress),

                const SizedBox(height: 18),

                _buildLabel('PAROLĂ'),
                const SizedBox(height: 8),
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  onChanged: (_) => setState(() {}),
                  style: const TextStyle(
                    color: Color(0xFFFAF8F5),
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Minim 8 caractere',
                    hintStyle: const TextStyle(
                      color: Color(0xFF8C7B66B),
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
                        color: Color(0xFF8C7B6B),
                        size: 20,                        
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                ),

                if (_passwordController.text.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      ...List.generate(4, (i) => Expanded(
                        child: Container(
                          margin: const EdgeInsets.only(right: 4),
                          height: 3,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                            color: i < _passwordStrength
                                ? _strengthColor
                                : const Color(0xFF3D3530),
                          ),                          
                        ),
                      )),
                      const SizedBox(width: 4),
                      Text(
                        _strengthText,
                        style: TextStyle(
                          fontSize: 11,
                          color: _strengthColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  if (!_isPasswordValid)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPasswordHint('Minim 8 caractere', _hasMinLength),
                      _buildPasswordHint('O literă mare (A-Z)', _hasUppercase),
                      _buildPasswordHint('O cifră (0-9)', _hasNumber),
                      _buildPasswordHint('Un simbol (!@#\$%^&*)', _hasSymbol),
                    ],
                  ),
              ],

              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isPasswordValid
                      ? () {

                      }
                    : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC9A96E),
                    disabledBackgroundColor: const Color(0xFF3D3530),
                    foregroundColor: const Color(0xFF1C1917),
                    disabledForegroundColor: const Color(0xFF8C7B6B),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadiusGeometry.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Creează cont',
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
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Ai cont? Intră în cont',
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

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 10,
        letterSpacing: 2,
        color: Color(0xFFC4B9A8),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint, {
      TextInputType keyboardType = TextInputType.text,
    }) {
      return TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(color: Color(0xFFFAF8F5), fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Color(0xFF8C7B6B), fontSize: 14),
          filled: true,
          fillColor: const Color(0xFF2C2825),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      );
    }

    Widget _buildPasswordHint(String text, bool met) {
      return Padding(
        padding: const EdgeInsetsGeometry.only(bottom: 2),
        child: Row(
          children: [
            Icon(
              met ? Icons.check_circle_outline : Icons.radio_button_unchecked,
              size: 13,
              color: met ? const Color(0xFF1D9E75) : const Color(0xFF8C7B6B),             
            ),
            const SizedBox(width: 6),
            Text(
              text,
              style: TextStyle(
                fontSize: 11,
                color: met ? const Color(0xFF1D9E75) : const Color(0xFF8C7B6B),
              ),
            ),
          ],
        ),
      );
    }
  }
