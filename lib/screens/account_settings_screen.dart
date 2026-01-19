import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';

class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  final _supabase = Supabase.instance.client;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  String _createdAt = '';

  late final StreamSubscription<AuthState> _authSubscription;

  @override
  void initState() {
    super.initState();
    _loadAccountData();

    _authSubscription = _supabase.auth.onAuthStateChange.listen((data) {
      final event = data.event;
      if (event == AuthChangeEvent.userUpdated || event == AuthChangeEvent.signedIn || event == AuthChangeEvent.tokenRefreshed) {
        _loadAccountData();
      }
    });
  }

  Future<void> _loadAccountData() async {
    // 1. DEĞİŞİKLİK: Sadece refreshSession yetmez, doğrudan sunucudan kullanıcıyı çekiyoruz.
    try {
      // Bu komut hafızadaki (cache) kullanıcıyı değil, sunucudaki en güncel kullanıcıyı getirir.
      final response = await _supabase.auth.getUser();
      final user = response.user;

      if (user != null) {
        // İmleç atlamasın diye sadece değişiklik varsa güncelle
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
      // Hata olursa (örn: internet yoksa) eski yöntemle hafızadan dene
      final user = _supabase.auth.currentUser;
      if (user != null && _emailController.text.isEmpty) {
        _emailController.text = user.email ?? '';
        if (mounted) setState(() {});
      }
    }
  }

  Future<void> _updateAccount() async {
    setState(() => _isLoading = true);
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      final newEmail = _emailController.text.trim();
      final newPassword = _passwordController.text;

      // 1. Şifre Uzunluk Kontrolü (Manuel Validasyon)
      if (newPassword.isNotEmpty && newPassword.length < 6) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Yeni şifre en az 6 karakter olmalıdır"),
              backgroundColor: Colors.red,
            ),
          );
        }
        return; // İşlemi durdur
      }

      // Değişiklik var mı kontrol et
      final emailChanged = newEmail != user.email;
      final passwordChanged = newPassword.isNotEmpty;

      final attributes = UserAttributes(
        email: newEmail,
        password: passwordChanged ? newPassword : null,
      );

      if (emailChanged || passwordChanged) {
        await _supabase.auth.updateUser(
          attributes,
          // E-posta değişikliğinden sonra uygulamaya dönüş için
          emailRedirectTo: 'com.emiraslan.language_cafe://login-callback',
        );

        if (mounted) {
          // Duruma göre özel mesaj belirle
          String message = "Bilgiler güncellendi.";
          Color color = Colors.green;

          if (emailChanged && passwordChanged) {
            message = "Şifre güncellendi! E-posta değişikliği için lütfen kutunuza gelen linke tıklayın. 📧";
            color = Colors.orange;
          } else if (emailChanged) {
            message = "E-posta değişikliği isteği alındı! Lütfen yeni adresinize gelen linke tıklayın. 📧";
            color = Colors.orange;
          } else if (passwordChanged) {
            message = "Şifreniz başarıyla güncellendi! 🔒";
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: color,
              duration: const Duration(seconds: 4),
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
    } on AuthException catch (e) {
      // Supabase'den dönen spesifik hataları yakalayıp Türkçeleştiriyoruz
      String errorMessage = "Güncelleme başarısız: ${e.message}";

      if (e.message.contains("different from the old password")) {
        errorMessage = "Yeni şifreniz eskisiyle aynı olamaz.";
      } else if (e.message.contains("Password should be")) {
        errorMessage = "Şifre güvenli değil veya çok kısa.";
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Beklenmedik bir hata: $e"), backgroundColor: Colors.red),
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
      backgroundColor: const Color(0xFFF5F5DC),
      appBar: AppBar(
        title: const Text("Hesap Ayarları"),
        backgroundColor: const Color(0xFFF5F5DC),
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
                color: Colors.brown.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.brown.shade100),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, color: Colors.brown),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Hesap Oluşturulma Tarihi",
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      Text(
                        _createdAt,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.brown),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            const Text(
              "Giriş Bilgileri",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.brown),
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
                  backgroundColor: Colors.brown,
                  foregroundColor: Colors.white,
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