import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:language_cafe/utils/context_extensions.dart';
import 'dart:io';
import '../services/user_service.dart';
import '../constants/app_colors.dart';
import '../utils/error_handler.dart';
import '../widgets/settings_sheet.dart';
import '../widgets/language_dialog.dart';
import '../providers/user_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
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
    // 1. Cache'den veya Provider'dan veriyi al
    // ref.read: Sadece bir kere okur, dinlemez. (Form doldurmak için ideal)
    final asyncProfile = ref.read(userProfileProvider);

    asyncProfile.whenData((profile) {
      _firstNameController.text = profile.firstName;
      _lastNameController.text = profile.lastName;
      _bioController.text = profile.bio;
      _learningLanguages = List.from(profile.learningLanguages);
      _isPublic = profile.isPublic;
    });

    // Eğer provider'da henüz veri yoksa veya hatadaysa, arka planda yenilemesi için zorlayabiliriz
    // Ama genelde HomeScreen açıldığı için veri hazırdır.
  }

  Future<void> _updateProfile() async {
    setState(() => _isLoading = true);
    try {
      final user = _userService.currentUser;
      if (user == null) return;

      // 1. Veritabanını Güncelle
      await _userService.updateProfile(
        userId: user.id,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        bio: _bioController.text.trim(),
        languages: _learningLanguages,
        isPublic: _isPublic,
      );

      // 2. KRİTİK HIZLANDIRMA ADIMI:
      // Invalidate yerine 'refresh' kullanıp sonucu 'await' ile bekliyoruz.
      // Bu sayede, alt satıra geçtiğimizde veri %100 güncel olmuş oluyor.
      // HomeScreen'e döndüğünde yeni ismi anında göreceksin.
      await ref.refresh(userProfileProvider.future);

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

  void _showAddLanguageDialog() async {
    final String? newLanguage = await showDialog<String>(
      context: context,
      builder: (context) => const AddLanguageDialog(),
    );

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
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        title: const Text("Profil Düzenle"),
        backgroundColor: context.backgroundColor,
        iconTheme: IconThemeData(color: context.appTextColor),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: AppColors.transparent,
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
                      backgroundColor: AppColors.brownShade200,
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

            // ... Inputlar (Aynı kalıyor) ...

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
                  label: Text(
                    lang,
                    style: TextStyle(
                      color: context.isDark ? Colors.white : AppColors.primary, // Yazı rengi
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  backgroundColor: context.isDark
                      ? AppColors.primary.withValues(alpha: 0.4) // Karanlıkta şeffaf kahve
                      : Colors.brown.shade100, // Aydınlıkta açık kahve
                  deleteIcon: Icon(
                    Icons.close,
                    size: 18,
                    color: context.isDark ? AppColors.white70 : AppColors.primary, // İkon rengi
                  ),
                  side: BorderSide.none, // Kenarlık olmasın
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  onDeleted: () {
                    setState(() {
                      _learningLanguages.remove(lang);
                    });
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            const Text("Gizlilik Ayarları", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
            const SizedBox(height: 10),

            SwitchListTile(
              title: Text(
                _isPublic ? "Profilim Herkese Açık" : "Profilim Gizli",
                style: TextStyle(
                    color: context.isDark ? Colors.white : Colors.black,
                    fontWeight: FontWeight.normal
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