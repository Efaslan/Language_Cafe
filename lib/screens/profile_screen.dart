import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'login_screen.dart';
import 'account_settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _supabase = Supabase.instance.client;

  // Controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _bioController = TextEditingController();

  // State Variables
  bool _isLoading = false;
  bool _isPublic = true;
  bool _isDarkMode = false; // Demo for UI switch
  List<String> _learningLanguages = [];
  File? _avatarFile;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  // Fetch user data from DB
  Future<void> _loadUserProfile() async {
    setState(() => _isLoading = true);
    try {
      final user = _supabase.auth.currentUser;
      if (user != null) {
        final data = await _supabase
            .from('profiles')
            .select()
            .eq('id', user.id)
            .single();

        _firstNameController.text = data['first_name'] ?? '';
        _lastNameController.text = data['last_name'] ?? '';
        _bioController.text = data['bio'] ?? '';

        if (data['learning_languages'] != null) {
          _learningLanguages = List<String>.from(data['learning_languages']);
        }

        _isPublic = data['is_public'] ?? true;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Hata: $e")));
      }
    } finally {
      if(mounted) setState(() => _isLoading = false);
    }
  }

  // Update profile logic
  Future<void> _updateProfile() async {
    setState(() => _isLoading = true);
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;

      // Update Profile Table
      await _supabase.from('profiles').update({
        'first_name': _firstNameController.text.trim(),
        'last_name': _lastNameController.text.trim(),
        'bio': _bioController.text.trim(),
        'learning_languages': _learningLanguages,
        'is_public': _isPublic,
      }).eq('id', user.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profil güncellendi! ✅"), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Güncelleme hatası: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if(mounted) setState(() => _isLoading = false);
    }
  }

  // Add Language Dialog
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
            style: ElevatedButton.styleFrom(backgroundColor: Colors.brown, foregroundColor: Colors.white),
            child: const Text("Ekle"),
          ),
        ],
      ),
    );
  }

  // Pick image from gallery
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

  // Sign out logic
  Future<void> _signOut() async {
    await _supabase.auth.signOut();
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
            onPressed: () => Navigator.pop(context), // Close dialog
            child: const Text("İptal", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close settings sheet
              _signOut(); // Perform sign out
            },
            child: const Text("Çıkış Yap", style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  // Bottom Sheet for Settings
  void _showSettingsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allow sheet to be taller if needed
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        // StatefulBuilder allows updating state inside the bottom sheet (e.g. switches)
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setSheetState) {
              return Container(
                padding: const EdgeInsets.all(24),
                // Dynamic height constraint
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.85,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text("Ayarlar", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.brown)),
                      const SizedBox(height: 20),

                      // --- Account Settings ---
                      ListTile(
                        leading: const Icon(Icons.manage_accounts, color: Colors.brown),
                        title: const Text("Hesap Ayarları", style: TextStyle(color: Colors.brown)),
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

                      // --- App Settings (Moved Here) ---
                      const SizedBox(height: 10),
                      const Text("Uygulama Ayarları (Yakında)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey)),
                      const SizedBox(height: 5),

                      SwitchListTile(
                        title: const Text("Gece Görünümü"),
                        secondary: const Icon(Icons.dark_mode, color: Colors.brown),
                        value: _isDarkMode,
                        activeTrackColor: Colors.brown,
                        onChanged: (bool value) {
                          setSheetState(() { // Update sheet state
                            _isDarkMode = value;
                          });
                          setState(() { // Update parent state if needed
                            _isDarkMode = value;
                          });
                        },
                      ),

                      ListTile(
                        leading: const Icon(Icons.language, color: Colors.brown),
                        title: const Text("Uygulama Dili"),
                        subtitle: const Text("Türkçe"),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                      ),

                      SwitchListTile(
                        title: const Text("Bildirimler"),
                        secondary: const Icon(Icons.notifications, color: Colors.brown),
                        value: true,
                        activeTrackColor: Colors.brown,
                        onChanged: (val) {
                          // Notification logic
                        },
                      ),

                      const Divider(),

                      // --- Logout Option ---
                      ListTile(
                        leading: const Icon(Icons.logout, color: Colors.redAccent),
                        title: const Text("Çıkış Yap", style: TextStyle(color: Colors.redAccent)),
                        onTap: () {
                          // Don't close sheet yet, show confirmation first
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
      backgroundColor: const Color(0xFFF5F5DC),
      appBar: AppBar(
        title: const Text("Profil Düzenle"),
        backgroundColor: const Color(0xFFF5F5DC),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showSettingsSheet,
        backgroundColor: Colors.brown,
        child: const Icon(Icons.settings, color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar Section
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
                          ? const Icon(Icons.person, size: 70, color: Colors.white)
                          : null,
                    ),
                    const Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.brown,
                        child: Icon(Icons.camera_alt, size: 18, color: Colors.white),
                      ),
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),

            // --- PERSONAL INFO ---
            const Text("Kişisel Bilgiler", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.brown)),
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

            // Bio Field
            TextFormField(
              controller: _bioController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Hakkımda',
                prefixIcon: Icon(Icons.description),
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            // --- LANGUAGES ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Öğrenilen Diller", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.brown)),
                IconButton(
                  onPressed: _showAddLanguageDialog,
                  icon: const Icon(Icons.add_circle, color: Colors.brown),
                  tooltip: "Dil Ekle",
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Language List (Wrap Widget)
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

            // --- PRIVACY SETTINGS ---
            const Text("Gizlilik Ayarları", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.brown)),
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
              activeTrackColor: Colors.brown,
              onChanged: (bool value) {
                setState(() {
                  _isPublic = value;
                });
              },
            ),

            const SizedBox(height: 40),

            // SAVE BUTTON
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _updateProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.brown,
                  foregroundColor: Colors.white,
                ),
                child: const Text("Değişiklikleri Kaydet", style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 80), // Space for FAB
          ],
        ),
      ),
    );
  }
}