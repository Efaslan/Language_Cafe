import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'login_screen.dart';
import 'account_settings_screen.dart';
import '../services/user_service.dart';
import '../services/auth_service.dart';
import '../constants/app_colors.dart';
import '../utils/error_handler.dart';
import '../models/user_profile.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _userService = UserService();
  final _authService = AuthService();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _bioController = TextEditingController();

  bool _isLoading = false;
  bool _isPublic = true;
  bool _isDarkMode = false;
  List<String> _learningLanguages = [];
  File? _avatarFile;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() => _isLoading = true);
    try {
      final user = _userService.currentUser;
      if (user != null) {
        UserProfile profile = await _userService.fetchUserProfile(user.id);

        _firstNameController.text = profile.firstName;
        _lastNameController.text = profile.lastName;
        _bioController.text = profile.bio;
        _learningLanguages = List.from(profile.learningLanguages); // Kopyasını al
        _isPublic = profile.isPublic;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(ErrorHandler.getMessage(e)), backgroundColor: AppColors.error)
        );
      }
    } finally {
      if(mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _updateProfile() async {
    setState(() => _isLoading = true);
    try {
      final user = _userService.currentUser;
      if (user == null) return;

      await _userService.updateProfile(
        userId: user.id,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        bio: _bioController.text.trim(),
        languages: _learningLanguages,
        isPublic: _isPublic,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profil güncellendi! ✅"), backgroundColor: AppColors.success),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(ErrorHandler.getMessage(e)), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if(mounted) setState(() => _isLoading = false);
    }
  }

  void _showAddLanguageDialog() {
    final languageController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Dil Ekle"),
        content: TextField(
          controller: languageController,
          decoration: const InputDecoration(hintText: "Örn: İngilizce, Fransızca"),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("İptal"),
          ),
          ElevatedButton(
            onPressed: () {
              if (languageController.text.isNotEmpty) {
                setState(() {
                  _learningLanguages.add(languageController.text.trim());
                });
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: AppColors.white),
            child: const Text("Ekle"),
          ),
        ],
      ),
    );
  }

  Future<void> _pickAvatar() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _avatarFile = File(image.path);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Resim seçildi (Henüz sunucuya yüklenmedi)")),
        );
      }
    }
  }

  Future<void> _signOut() async {
    await _authService.signOut();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
      );
    }
  }

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

  void _showSettingsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setSheetState) {
              return Container(
                padding: const EdgeInsets.all(24),
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.85,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text("Ayarlar", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary)),
                      const SizedBox(height: 20),

                      ListTile(
                        leading: const Icon(Icons.manage_accounts, color: AppColors.primary),
                        title: const Text("Hesap Ayarları", style: TextStyle(color: AppColors.primary)),
                        subtitle: const Text("Email, Şifre, Üyelik Tarihi"),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const AccountSettingsScreen()),
                          );
                        },
                      ),
                      const Divider(),

                      const SizedBox(height: 10),
                      const Text("Uygulama Ayarları (Yakında)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey)),
                      const SizedBox(height: 5),

                      SwitchListTile(
                        title: const Text("Gece Görünümü"),
                        secondary: const Icon(Icons.dark_mode, color: AppColors.primary),
                        value: _isDarkMode,
                        activeTrackColor: AppColors.primary,
                        onChanged: (bool value) {
                          setSheetState(() => _isDarkMode = value);
                          setState(() => _isDarkMode = value);
                        },
                      ),

                      ListTile(
                        leading: const Icon(Icons.language, color: AppColors.primary),
                        title: const Text("Uygulama Dili"),
                        subtitle: const Text("Türkçe"),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                      ),

                      SwitchListTile(
                        title: const Text("Bildirimler"),
                        secondary: const Icon(Icons.notifications, color: AppColors.primary),
                        value: true,
                        activeTrackColor: AppColors.primary,
                        onChanged: (val) {},
                      ),

                      const Divider(),

                      ListTile(
                        leading: const Icon(Icons.logout, color: AppColors.error),
                        title: const Text("Çıkış Yap", style: TextStyle(color: AppColors.error)),
                        onTap: () {
                          _confirmSignOut();
                        },
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              );
            }
        );
      },
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Profil Düzenle"),
        backgroundColor: AppColors.background,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showSettingsSheet,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.settings, color: AppColors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar
            Center(
              child: GestureDetector(
                onTap: _pickAvatar,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.brown.shade200,
                      backgroundImage: _avatarFile != null
                          ? FileImage(_avatarFile!)
                          : null,
                      child: _avatarFile == null
                          ? const Icon(Icons.person, size: 70, color: AppColors.white)
                          : null,
                    ),
                    const Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: AppColors.primary,
                        child: Icon(Icons.camera_alt, size: 18, color: AppColors.white),
                      ),
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),

            const Text("Kişisel Bilgiler", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _firstNameController,
                    decoration: const InputDecoration(labelText: 'Ad', prefixIcon: Icon(Icons.person)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _lastNameController,
                    decoration: const InputDecoration(labelText: 'Soyad', prefixIcon: Icon(Icons.person_outline)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _bioController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Hakkımda',
                prefixIcon: Icon(Icons.description, color: AppColors.primary),
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Öğrenilen Diller", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
                IconButton(
                  onPressed: _showAddLanguageDialog,
                  icon: const Icon(Icons.add_circle, color: AppColors.primary),
                  tooltip: "Dil Ekle",
                ),
              ],
            ),
            const SizedBox(height: 8),

            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: _learningLanguages.map((lang) {
                return Chip(
                  label: Text(lang),
                  backgroundColor: Colors.brown.shade100,
                  deleteIcon: const Icon(Icons.close, size: 18),
                  onDeleted: () {
                    setState(() {
                      _learningLanguages.remove(lang);
                    });
                  },
                );
              }).toList(),
            ),
            if (_learningLanguages.isEmpty)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text("Henüz dil eklenmemiş.", style: TextStyle(color: Colors.grey)),
              ),

            const SizedBox(height: 24),

            const Text("Gizlilik Ayarları", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
            const SizedBox(height: 10),

            SwitchListTile(
              title: Text(
                _isPublic ? "Profilim Herkese Açık" : "Profilim Gizli",
                style: TextStyle(
                    color: _isPublic ? Colors.black : Colors.grey,
                    fontWeight: _isPublic ? FontWeight.normal : FontWeight.bold
                ),
              ),
              subtitle: const Text("Kapalıyken diğer kullanıcılar profilinizi göremez."),
              value: _isPublic,
              activeTrackColor: AppColors.primary,
              onChanged: (bool value) {
                setState(() {
                  _isPublic = value;
                });
              },
            ),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _updateProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                ),
                child: const Text("Değişiklikleri Kaydet", style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}