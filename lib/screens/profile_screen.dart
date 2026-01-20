import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/user_service.dart';
import '../constants/app_colors.dart';
import '../utils/error_handler.dart';
import '../models/user_profile.dart';
// Widget Imports
import '../widgets/settings_sheet.dart';
import '../widgets/language_dialog.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Sadece User Service lazım
  final _userService = UserService();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _bioController = TextEditingController();

  bool _isLoading = false;
  bool _isPublic = true;
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
        // Cache First mantığı (Serviste implemente ettiğimiz gibi çalışır)
        UserProfile profile = await _userService.fetchUserProfile(user.id);

        _firstNameController.text = profile.firstName;
        _lastNameController.text = profile.lastName;
        _bioController.text = profile.bio;
        _learningLanguages = List.from(profile.learningLanguages);
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

  // Yeni Widget Kullanımı: Dil Ekleme
  Future<void> _openAddLanguageDialog() async {
    // Diyalogdan gelen sonucu bekliyoruz
    final String? newLanguage = await showDialog<String>(
      context: context,
      builder: (context) => const AddLanguageDialog(),
    );

    // Eğer sonuç geldiyse listeye ekle
    if (newLanguage != null && newLanguage.isNotEmpty) {
      setState(() {
        _learningLanguages.add(newLanguage);
      });
    }
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
      // Yeni Widget Kullanımı: Ayarlar Menüsü
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent, // Sheet'in kenarları için şeffaf
            builder: (context) => FractionallySizedBox(
              heightFactor: 0.6,
              child: const SettingsSheet(),
            ),
          );
        },
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
                  onPressed: _openAddLanguageDialog, // Yeni diyaloğu açan fonksiyon
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