import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../constants/app_colors.dart';
import '../screens/login_screen.dart';
import '../screens/account_settings_screen.dart';

class SettingsSheet extends StatefulWidget {
  const SettingsSheet({super.key});

  @override
  State<SettingsSheet> createState() => _SettingsSheetState();
}

class _SettingsSheetState extends State<SettingsSheet> {
  final _authService = AuthService();

  // UI Demo States
  bool _isDarkMode = false;
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
            child: const Text("İptal", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
              _signOut();
            },
            child: const Text("Çıkış Yap", style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      decoration: const BoxDecoration(
        color: Color(0xFFFCFCFC), // Daha yumuşak bir beyaz (Kırık Beyaz)
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
                color: Colors.grey[300],
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
                    subtitle: const Text("Email, Şifre, Üyelik Tarihi", style: TextStyle(color: Colors.grey)),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
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
                  const Text("Uygulama Ayarları (Yakında)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 5),

                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text("Gece Görünümü", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                    secondary: const Icon(Icons.dark_mode, color: AppColors.primary),
                    value: _isDarkMode,
                    activeTrackColor: AppColors.primary,
                    onChanged: (bool value) {
                      setState(() => _isDarkMode = value);
                    },
                  ),

                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.language, color: AppColors.primary),
                    title: const Text("Uygulama Dili", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                    subtitle: const Text("Türkçe"),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
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
                    leading: const Icon(Icons.logout, color: AppColors.error),
                    title: const Text("Çıkış Yap", style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold, fontSize: 16)),
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