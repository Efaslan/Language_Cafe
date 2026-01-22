import 'package:flutter/material.dart';
import 'package:language_cafe/utils/context_extensions.dart';
import '../services/user_service.dart';
import '../constants/app_colors.dart';
import '../utils/validators.dart';
import '../utils/error_handler.dart';
import 'home_screen.dart';

class UpdatePasswordScreen extends StatefulWidget {
  const UpdatePasswordScreen({super.key});

  @override
  State<UpdatePasswordScreen> createState() => _UpdatePasswordScreenState();
}

class _UpdatePasswordScreenState extends State<UpdatePasswordScreen> {
  final _userService = UserService();

  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;

  Future<void> _updatePassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _userService.updateAccount(
        password: _passwordController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Şifreniz başarıyla güncellendi! Giriş yapılıyor... 🔒"),
            backgroundColor: AppColors.success,
          ),
        );

        // return to homescreen and clean the history
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
              (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(ErrorHandler.getMessage(e)),
              backgroundColor: AppColors.error
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        title: const Text("Yeni Şifre Belirle"),
        backgroundColor: context.backgroundColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_open, size: 80, color: AppColors.primary),
              const SizedBox(height: 20),
              const Text(
                "Yeni Şifrenizi Girin",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
              const SizedBox(height: 30),

              // Password Field
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                validator: (val) => Validators.validatePassword(val, message: "Yeni şifreniz en az 6 karakter olmalıdır"),
                decoration: InputDecoration(
                  labelText: 'Yeni Şifre',
                  prefixIcon: const Icon(Icons.lock, color: AppColors.primary),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _updatePassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: AppColors.white)
                      : const Text("Şifreyi Güncelle", style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}