import 'package:flutter/material.dart';
import 'package:language_cafe/utils/context_extensions.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';
import '../services/user_service.dart';
import '../utils/validators.dart';
import '../utils/error_handler.dart';
import '../constants/app_colors.dart';

class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  final _userService = UserService();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  String _createdAt = '';

  // Auth state listener
  late final StreamSubscription<AuthState> _authSubscription;

  @override
  void initState() {
    super.initState();
    _loadAccountData();

    // listening to auth through global instance
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      if (event == AuthChangeEvent.userUpdated || event == AuthChangeEvent.signedIn || event == AuthChangeEvent.tokenRefreshed) {
        _loadAccountData();
      }
    });
  }

  Future<void> _loadAccountData() async {
    try {
      // refresh user data to display correct email after change
      final response = await _userService.refreshUser();
      final user = response.user;

      if (user != null) {
        if (_emailController.text != user.email) {
          _emailController.text = user.email ?? '';
        }

        if (user.createdAt.isNotEmpty) {
          try {
            final DateTime created = DateTime.parse(user.createdAt);
            final String day = created.day.toString().padLeft(2, '0');
            final String month = created.month.toString().padLeft(2, '0');
            final String year = created.year.toString();

            _createdAt = "$day.$month.$year";
          } catch (_) {
            _createdAt = "-";
          }
        }

        if (mounted) setState(() {});
      }
    } catch (e) {
      // display last email from cache if the server does not respond
      final user = _userService.currentUser;
      if (user != null && _emailController.text.isEmpty) {
        _emailController.text = user.email ?? '';
        if (mounted) setState(() {});
      }
    }
  }

  Future<void> _updateAccount() async {
    setState(() => _isLoading = true);
    try {
      final user = _userService.currentUser;
      if (user == null) return;

      final newEmail = _emailController.text.trim();
      final newPassword = _passwordController.text;

      if (newPassword.isNotEmpty) {
        final error = Validators.validatePassword(newPassword);
        if (error != null) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(error), backgroundColor: AppColors.error),
            );
          }
          return;
        }
      }

      final emailChanged = newEmail != user.email;
      final passwordChanged = newPassword.isNotEmpty;

      if (emailChanged || passwordChanged) {
        await _userService.updateAccount(
          email: newEmail,
          password: passwordChanged ? newPassword : null,
        );

        if (mounted) {
          String message = "Bilgiler güncellendi.";
          Color color = AppColors.success;

          if (emailChanged && passwordChanged) {
            message = "Şifre güncellendi! E-posta değişikliği için lütfen kutunuza gelen linke tıklayın. 📧";
            color = AppColors.pending;
          } else if (emailChanged) {
            message = "E-posta değişikliği isteği alındı! Lütfen yeni adresinize gelen linke tıklayın. 📧";
            color = AppColors.pending;
          } else if (passwordChanged) {
            message = "Şifreniz başarıyla güncellendi! 🔒";
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: color,
              duration: const Duration(seconds: 6),
            ),
          );
          _passwordController.clear();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Değişiklik yapılmadı.")),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ErrorHandler.getMessage(e)),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        title: const Text("Hesap Ayarları"),
        backgroundColor: context.backgroundColor,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.isDark ? AppColors.primary.withValues(alpha: 0.15) : AppColors.brownShade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: context.isDark
                    ? AppColors.primary.withValues(alpha: 0.3)
                    : AppColors.brownShade100),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Hesap Oluşturulma Tarihi",
                        style: TextStyle(
                            fontSize: 13),
                      ),
                      Text(
                        _createdAt,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            const Text(
              "Giriş Bilgileri",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email),
                helperText: "Değiştirirseniz yeni adresinize doğrulama maili göndereceğiz",
              ),
            ),
            const SizedBox(height: 20),

            TextFormField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Yeni Şifre',
                prefixIcon: Icon(Icons.lock),
                helperText: "Değiştirmek istemiyorsanız boş bırakabilirsiniz",
              ),
            ),
            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _updateAccount,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                ),
                child: const Text("Hesap Bilgilerini Güncelle", style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}