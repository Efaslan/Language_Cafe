import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:language_cafe/utils/context_extensions.dart';
import '../services/auth_service.dart';
import '../constants/app_colors.dart';
import '../screens/login_screen.dart';
import '../screens/account_settings_screen.dart';
import '../providers/theme_provider.dart';
import '../providers/locale_provider.dart';

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
        title: Text(context.l10n.logoutLabel),
        content: Text(context.l10n.confirmLogoutMsg),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.cancelBtn, style: TextStyle(color: AppColors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _signOut();
            },
            child: Text(context.l10n.logoutLabel, style: TextStyle(color: AppColors.redAccent)),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: Text(context.l10n.languageLabel),
          children: [
            SimpleDialogOption(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: const Text("Türkçe", style: TextStyle(fontSize: 16)),
              onPressed: () {
                // Dili Türkçe yap ve pencereyi kapat
                ref.read(localeProvider.notifier).setLocale(const Locale('tr'));
                Navigator.pop(context);
              },
            ),
            SimpleDialogOption(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: const Text("English", style: TextStyle(fontSize: 16)),
              onPressed: () {
                // Dili İngilizce yap ve pencereyi kapat
                ref.read(localeProvider.notifier).setLocale(const Locale('en'));
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

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

          Text(context.l10n.settingsTitle, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary)),
          const SizedBox(height: 20),

          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero, // Kenar boşluklarını sıfırla, düz dursun
                    leading: const Icon(Icons.manage_accounts, color: AppColors.primary),
                    title: Text(context.l10n.accountSettings, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                    subtitle: Text(context.l10n.accountSubtitle, style: TextStyle(color: AppColors.grey)),
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
                  Text(context.l10n.appSettings, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.grey)),
                  const SizedBox(height: 5),

                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(context.l10n.darkMode, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
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
                    title: Text(context.l10n.appLanguage, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                    subtitle: Text(context.l10n.languageLabel),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.grey),
                    onTap: _showLanguageDialog,
                  ),

                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(context.l10n.notifications, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
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
                    title: Text(context.l10n.logoutLabel, style: TextStyle(color: AppColors.redAccent, fontWeight: FontWeight.bold, fontSize: 16)),
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