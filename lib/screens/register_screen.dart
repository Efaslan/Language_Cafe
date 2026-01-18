import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Key for form validation
  final _formKey = GlobalKey<FormState>();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  final _supabase = Supabase.instance.client;

  Future<void> _signUp() async {
    // 1. Validate form inputs before sending request
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 2. Send data to Supabase (Names are separated)
      final AuthResponse res = await _supabase.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        emailRedirectTo: 'com.emiraslan.language_cafe://login-callback',
        data: {
          'first_name': _firstNameController.text.trim(), // Required
          'last_name': _lastNameController.text.trim(),   // Optional
        },
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Kayıt Başarılı! Lütfen email adresinizi doğrulayın. 📧"),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 10),
          ),
        );
      }
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Beklenmedik bir hata oluştu."),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5DC),
      appBar: AppBar(
        title: const Text("Kayıt Ol"),
        backgroundColor: const Color(0xFFF5F5DC),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          // Wrap with Form for validation
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.person_add, size: 80, color: Colors.brown),
                const SizedBox(height: 20),
                const Text(
                  'Aramıza Katıl',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.brown),
                ),
                const SizedBox(height: 30),

                // Name Fields Row
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _firstNameController,
                        keyboardType: TextInputType.name,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Size nasıl hitap edelim?'; // required message
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: 'Ad*',
                          prefixIcon: const Icon(Icons.person, color: Colors.brown),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.brown, width: 2)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _lastNameController,
                        keyboardType: TextInputType.name,
                        decoration: InputDecoration(
                          labelText: 'Soyad', // optional
                          prefixIcon: const Icon(Icons.person_outline, color: Colors.brown),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.brown, width: 2)),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Email Field
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Size bir mail göndermemiz gerekiyor!';
                    }
                    if (!value.contains('@')) {
                      return 'Doğru yazdığınıza emin misiniz?';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Email*',
                    prefixIcon: const Icon(Icons.email_outlined, color: Colors.brown),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.brown, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Password Field
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Lütfen unutmayın!';
                    }
                    if (value.length < 6) {
                      return 'Şifreniz en az 6 karakter olmalı';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Şifre*',
                    prefixIcon: const Icon(Icons.lock_outline, color: Colors.brown),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.brown, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Sign Up Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _signUp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.brown,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Kayıt Ol', style: TextStyle(fontSize: 18)),
                  ),
                ),

                const SizedBox(height: 16),

                // Back to Login Link
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "Zaten hesabın var mı? Giriş Yap",
                      style: TextStyle(color: Colors.brown),
                    )
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}