import 'package:flutter/material.dart';
import '../services/table_service.dart';
import '../models/cafe_table.dart';
import '../constants/app_colors.dart';

class TablesScreen extends StatefulWidget {
  const TablesScreen({super.key});

  @override
  State<TablesScreen> createState() => _TablesScreenState();
}

class _TablesScreenState extends State<TablesScreen> {
  final _tableService = TableService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Canlı Masalar"),
        backgroundColor: AppColors.background,
      ),
      body: StreamBuilder<List<CafeTable>>(
        stream: _tableService.getTablesStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final tables = snapshot.data!;
          tables.sort((a, b) => a.tableNumber.compareTo(b.tableNumber));

          if (tables.isEmpty) {
            return const Center(child: Text("Henüz masa eklenmemiş."));
          }

          // draw tables
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2,
            ),
            itemCount: tables.length,
            itemBuilder: (context, index) {
              final table = tables[index];

              // empty = green, full = red, occupied = orange
              Color cardColor;
              if (table.status == 'Empty') {
                cardColor = Colors.green.shade100;
              } else if (table.status == 'Full') {
                cardColor = Colors.red.shade100;
              } else {
                cardColor = Colors.orange.shade100;
              }

              return Card(
                color: cardColor,
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: InkWell(
                  onTap: () {
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
                      Icon(Icons.table_restaurant, size: 40, color: AppColors.primary),
                      const SizedBox(height: 8),
                      Text(
                        "Masa ${table.tableNumber}",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black87
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${table.activeCount} / ${table.chairCount}",
                        style: const TextStyle(color: AppColors.primary),
                      ),
                      const SizedBox(height: 4),
                      // show if there is a rule
                      if (table.currentRule != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            table.currentRule!,
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
      // QR Button
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // todo qr scanner route
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.qr_code_scanner, color: AppColors.white),
        label: const Text("QR Okut", style: TextStyle(color: AppColors.white)),
      ),
    );
  }
}