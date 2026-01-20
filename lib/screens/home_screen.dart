import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_colors.dart';
import '../providers/user_provider.dart';
import 'tables_screen.dart';
import 'profile_screen.dart';
import 'menu_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    // If the data is loading, error, or available, 'userProfileAsync' handles it.
    // 1. Provider'ı izliyoruz
    final userProfileAsync = ref.watch(userProfileProvider);

    // 2. AKILLI İSİM GÖSTERİMİ (Cache-First)
    // Eğer veri geldiyse (AsyncData) değerini al, yoksa null dön.
    final profile = userProfileAsync.asData?.value;

    final displayName = (profile?.firstName.isNotEmpty == true)
        ? profile!.firstName
        : "Misafir";

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        // Left: Welcome Text
        title: Text(
          "Hoş geldin, $displayName",
          style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.primary
          ),
        ),
        // Right: Profile Icon
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: InkWell(
              onTap: () {
                // Navigate to Profile
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ProfileScreen())
                ).then((_) {
                  // When returning from profile, simply invalidate the provider.
                  // Riverpod will automatically re-fetch the data in the background.
                  ref.invalidate(userProfileProvider);
                });
              },
              child: const CircleAvatar(
                backgroundColor: AppColors.primary,
                child: Icon(Icons.person, color: AppColors.white),
              ),
            ),
          )
        ],
      ),
      body: Stack( // stack structure
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
                      // Tables Card
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
                      // Menu & Order Card
                      _DashboardCard(
                        title: "Menü & Sipariş",
                        icon: Icons.restaurant_menu,
                        color: Colors.blue.shade100,
                        onTap: () {
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

          // Custom arrow image placeholder
          /* Positioned(
            bottom: 85,
            right: 30,
            child: Image.asset('assets/arrow_nudge.png', width: 150),
          ), */
        ],
      ),

      // LAYER 2: QR Button (FAB)
      floatingActionButton: FloatingActionButton(
        onPressed: () {
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