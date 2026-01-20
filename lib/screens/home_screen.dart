import 'package:flutter/material.dart';
import '../services/user_service.dart';
import '../constants/app_colors.dart';
import 'tables_screen.dart';
import 'profile_screen.dart';
import 'menu_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _userService = UserService();
  String _userName = "Misafir";

  @override
  void initState() {
    super.initState();
    // İlk açılışta CACHE'den oku (Anında gelir)
    _loadNameFromCache();
  }

  // Veritabanına gitmeden, direkt eldeki veriden ismi alır
  void _loadNameFromCache() {
    final name = _userService.cachedFirstName;
    if (name != null && mounted) {
      setState(() {
        _userName = name;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        // Sol üst: Karşılama mesajı
        title: Text(
          "Hoş geldin, $_userName",
          style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.primary
          ),
        ),
        // Sağ üst: Profil ikonu
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: InkWell(
              onTap: () {
                // Profil sayfasına git ve dönünce ismi güncelle
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ProfileScreen())
                ).then((_) => _loadNameFromCache());
              },
              child: const CircleAvatar(
                backgroundColor: AppColors.primary,
                child: Icon(Icons.person, color: AppColors.white),
              ),
            ),
          )
        ],
      ),
      // STACK STRUCTURE: Future image overlay için yer tutucu
      body: Stack(
        children: [
          // LAYER 1: Main Content
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const SizedBox(height: 10),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    children: [
                      // Masalar Kartı
                      _DashboardCard(
                        title: "Masalar",
                        icon: Icons.table_bar,
                        color: Colors.orange.shade100,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const TablesScreen()),
                          );
                        },
                      ),
                      // Menü & Sipariş Kartı (GÜNCELLENDİ)
                      _DashboardCard(
                        title: "Menü & Sipariş",
                        icon: Icons.restaurant_menu,
                        color: Colors.blue.shade100,
                        onTap: () {
                          // Menü ekranına yönlendirme
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const MenuScreen()),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // LAYER 2: Placing custom arrow image here later
          /* Positioned(
            bottom: 85,
            right: 30,
            child: Image.asset('assets/arrow_nudge.png', width: 150),
          ),
          */
        ],
      ),

      // LAYER 3: QR Button (FAB)
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Future: Navigate to QR Scanner
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Kamera açılıyor... 📷")),
          );
        },
        backgroundColor: AppColors.primary,
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.qr_code_scanner, color: AppColors.white, size: 30),
      ),
    );
  }
}

// Helper widget for uniform cards
class _DashboardCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      color: color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: AppColors.primary),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}