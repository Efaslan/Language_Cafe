import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'tables_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _supabase = Supabase.instance.client;
  String _userName = "Misafir"; // default name

  @override
  void initState() {
    super.initState();
    _fetchUserName();
  }

  // fetch user name from 'profiles' table
  Future<void> _fetchUserName() async {
    try {
      final userId = _supabase.auth.currentUser!.id;
      final data = await _supabase
          .from('profiles')
          .select('first_name')
          .eq('id', userId)
          .single();

      if (mounted) {
        setState(() {
          _userName = data['first_name'] ?? "Misafir";
        });
      }
    } catch (e) {
      // silent error or debug print
      print("Error fetching name: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5DC),
      // CUSTOM APP BAR
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5DC),
        elevation: 0,
        // Left Side: Welcome Text
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Hoş geldin,",
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            Text(
              _userName,
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown
              ),
            ),
          ],
        ),
        // Right Side: Default User Icon (Goes to Profile)
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ProfileScreen())
                );
              },
              child: const CircleAvatar(
                backgroundColor: Colors.brown,
                child: Icon(Icons.person, color: Colors.white),
              ),
            ),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 10),
            // Dashboard Grid
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  // 1. Tables Card
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

                  // 2. Menu Card (Placeholder)
                  _DashboardCard(
                    title: "Menü & Sipariş",
                    icon: Icons.restaurant_menu,
                    color: Colors.blue.shade100,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Menü çok yakında...")),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
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
            Icon(icon, size: 50, color: Colors.brown),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.brown),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}