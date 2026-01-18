import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_screen.dart';

class TablesScreen extends StatefulWidget {
  const TablesScreen({super.key});

  @override
  State<TablesScreen> createState() => _TablesScreenState();
}

class _TablesScreenState extends State<TablesScreen> {
  final _supabase = Supabase.instance.client;

  // sign out
  Future<void> _signOut() async {
    await _supabase.auth.signOut();
    if (mounted) {
      // back to login
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5DC),
      appBar: AppBar(
        title: const Text("Masalar"),
        backgroundColor: const Color(0xFFF5F5DC),
      ),
      // table list (live stream)
      body: StreamBuilder<List<Map<String, dynamic>>>(
        // listen 'cafe_tables' from Supabase and order by id
        stream: _supabase
            .from('cafe_tables')
            .stream(primaryKey: ['id'])
            .order('id', ascending: true),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final tables = snapshot.data!;

          if (tables.isEmpty) {
            return const Center(child: Text("Henüz masa eklenmemiş."));
          }

          // grid of tables
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // 2 tables next to each other
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2,
            ),
            itemCount: tables.length,
            itemBuilder: (context, index) {
              final table = tables[index];
              final status = table['status']; // 'Empty', 'Occupied', 'Full'
              final tableName = table['name'];
              final chairCount = table['current_chair_count'];
              final activeCount = table['active_count'];

              // colors for table status
              Color cardColor;
              if (status == 'Empty') {
                cardColor = Colors.green.shade100; // empty (green)
              } else if (status == 'Full') {
                cardColor = Colors.red.shade100; // full (red)
              } else {
                cardColor = Colors.orange.shade100; // occupied, not full (orange)
              }

              return Card(
                color: cardColor,
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: InkWell(
                  onTap: () {
                    // read QR detail here, in the future
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Lütfen masadaki QR kodunu okutunuz 📷"),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.table_restaurant, size: 40, color: Colors.brown.shade700),
                      const SizedBox(height: 8),
                      Text(
                        tableName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "$activeCount / $chairCount", // occupancy: 2/4
                        style: TextStyle(color: Colors.brown.shade600),
                      ),
                      const SizedBox(height: 4),
                      // show if there is a rule
                      if (table['current_rule'] != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            table['current_rule'],
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      // QR reading button
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // QR scanner here
        },
        backgroundColor: Colors.brown,
        icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
        label: const Text("Masa Seç", style: TextStyle(color: Colors.white)),
      ),
    );
  }
}