import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:language_cafe/utils/context_extensions.dart';
import '../services/auth_service.dart';
import '../constants/app_colors.dart';
import '../screens/login_screen.dart';
import '../screens/account_settings_screen.dart';
import '../providers/theme_provider.dart';

class SettingsSheet extends ConsumerStatefulWidget {
  const SettingsSheet({super.key});

  @override
  ConsumerState<SettingsSheet> createState() => _SettingsSheetState();
}

class _SettingsSheetState extends ConsumerState<SettingsSheet> {
  final _authService = AuthService();

  // UI Demo States
  bool _notificationsEnabled = true;

  // Sign out logic
  Future<void> _signOut() async {
    await _authService.signOut();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
      );
    }
  }

  // Confirm Sign Out Dialog
  void _confirmSignOut() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Çıkış Yap"),
        content: const Text("Hesabınızdan çıkış yapmak istediğinize emin misiniz?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("İptal", style: TextStyle(color: AppColors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
              _signOut();
            },
            child: const Text("Çıkış Yap", style: TextStyle(color: AppColors.redAccent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    // 1. Temayı Dinle: Riverpod'dan gelen değeri al
    final themeMode = ref.watch(themeProvider);

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      decoration: BoxDecoration(
        color: context.backgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tutamaç (Handle)
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: AppColors.greyShade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          const Text("Ayarlar", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary)),
          const SizedBox(height: 20),

          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero, // Kenar boşluklarını sıfırla, düz dursun
                    leading: const Icon(Icons.manage_accounts, color: AppColors.primary),
                    title: const Text("Hesap Ayarları", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                    subtitle: const Text("Email, Şifre, Üyelik Tarihi", style: TextStyle(color: AppColors.grey)),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.grey),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AccountSettingsScreen()),
                      );
                    },
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Divider(),
                  ),

                  // --- App Settings Section ---
                  const Text("Uygulama Ayarları (Yakında)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.grey)),
                  const SizedBox(height: 5),

                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text("Gece Görünümü", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                    secondary: const Icon(Icons.dark_mode, color: AppColors.primary),
                    value: context.isDark, // Provider'dan gelen değer
                    activeTrackColor: AppColors.primary,
                    onChanged: (bool value) {
                      // Provider'ı güncelle
                      ref.read(themeProvider.notifier).toggleTheme(value);
                    },
                  ),

                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.language, color: AppColors.primary),
                    title: const Text("Uygulama Dili", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                    subtitle: const Text("Türkçe"),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.grey),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Çok yakında...")),
                      );
                    },
                  ),

                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text("Bildirimler", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                    secondary: const Icon(Icons.notifications, color: AppColors.primary),
                    value: _notificationsEnabled,
                    activeTrackColor: AppColors.primary,
                    onChanged: (val) {
                      setState(() => _notificationsEnabled = val);
                    },
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Divider(),
                  ),

                  // --- Danger Zone ---
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.logout, color: AppColors.redAccent),
                    title: const Text("Çıkış Yap", style: TextStyle(color: AppColors.redAccent, fontWeight: FontWeight.bold, fontSize: 16)),
                    onTap: _confirmSignOut,
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}