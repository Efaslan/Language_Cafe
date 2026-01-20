import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Riverpod
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/table_service.dart';
import '../models/cafe_table.dart';
import '../constants/app_colors.dart';
import '../providers/table_provider.dart'; // Provider'ı çağır

class TablesScreen extends ConsumerStatefulWidget {
  const TablesScreen({super.key});

  @override
  ConsumerState<TablesScreen> createState() => _TablesScreenState();
}

class _TablesScreenState extends ConsumerState<TablesScreen> {
  final _tableService = TableService();
  final _supabase = Supabase.instance.client;

  late final Stream<List<CafeTable>> _tablesStream;

  @override
  void initState() {
    super.initState();
    _tablesStream = _tableService.getTablesStream();
  }

  // Masaya Oturma Mantığı
  Future<void> _handleJoinTable(CafeTable table) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      // 1. Veritabanı İşlemi
      await _tableService.joinTable(table: table, userId: user.id);

      // 2. KRİTİK NOKTA: Riverpod'u Güncelle
      // Bu komut sayesinde "DraggableTableBubble" ve "FloatingCartButton"
      // anında yeni masa bilgisini çeker ve kendini günceller.
      ref.invalidate(currentTableProvider);

      if (mounted) {
        String message = "Masa ${table.tableNumber}'e oturdunuz! İyi sohbetler ☕";
        Color color = AppColors.success;

        if (table.activeCount >= table.currentChairCount) {
          message = "Sandalye çekip katıldınız! Harika ortam 🪑";
          color = AppColors.success;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: color,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Bir sorun oluştu: $e"),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  // Bilgilendirme Penceresi
  void _showInfoDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.1),
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFFFFF8E1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.info, color: AppColors.primary, size: 28),
                  SizedBox(width: 10),
                  Text(
                    "Bilgilendirme",
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              const Text(
                "Masa dolulukları sadece bilgilendirme amaçlıdır.\n\nOturmak istediğiniz yerler dolu da olsa istediğiniz gibi sandalye çekebilirsiniz :)",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text("Tamam", style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Masalar"),
        backgroundColor: AppColors.background,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: AppColors.primary),
            tooltip: "Bilgilendirme",
            onPressed: _showInfoDialog,
          ),
        ],
      ),
      body: StreamBuilder<List<CafeTable>>(
        stream: _tablesStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final tables = snapshot.data!;

          if (tables.isEmpty) {
            return const Center(child: Text("Henüz masa eklenmemiş."));
          }

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
                  onTap: () => _handleJoinTable(table),
                  borderRadius: BorderRadius.circular(16),
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
                        "${table.activeCount} / ${table.currentChairCount}",
                        style: const TextStyle(color: AppColors.primary),
                      ),
                      const SizedBox(height: 4),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("QR Okutma yakında... Şimdilik masaya tıklayın.")),
          );
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.qr_code_scanner, color: AppColors.white),
        label: const Text("QR Okut", style: TextStyle(color: AppColors.white)),
      ),
    );
  }
}