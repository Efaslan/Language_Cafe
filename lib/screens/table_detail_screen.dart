import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/cafe_table.dart';
import '../services/table_service.dart';
import '../services/menu_service.dart';
import '../constants/app_colors.dart';
import '../providers/table_provider.dart';

class TableDetailScreen extends ConsumerStatefulWidget {
  final CafeTable table;

  const TableDetailScreen({super.key, required this.table});

  @override
  ConsumerState<TableDetailScreen> createState() => _TableDetailScreenState();
}

class _TableDetailScreenState extends ConsumerState<TableDetailScreen> {
  final _tableService = TableService();
  final _menuService = MenuService();

  List<Map<String, dynamic>> _participants = [];
  List<Map<String, dynamic>> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDetails();
    // Buradaki state yönetimini kaldırdık, DraggableTableBubble içinde yöneteceğiz.
  }

  Future<void> _fetchDetails() async {
    try {
      final results = await Future.wait([
        _tableService.getTableParticipants(widget.table.id),
        _menuService.getTableOrders(widget.table.id),
      ]);

      if (mounted) {
        setState(() {
          _participants = results[0];
          _orders = results[1];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Hata: $e")));
      }
    }
  }

  Future<void> _leaveTable() async {
    try {
      final userId = _tableService.currentUserId;
      if (userId != null) {
        await _tableService.leaveTable(userId: userId);

        // Provider'ı güncelle (Balonun verisi null olacak ve gizlenecek)
        ref.invalidate(currentTableProvider);

        if (mounted) {
          Navigator.pop(context); // Sayfayı kapat
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Masadan ayrıldınız. 👋"), backgroundColor: Colors.grey),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Hata: $e")));
      }
    }
  }

  void _confirmLeave() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Masadan Ayrıl"),
        content: const Text("Masadan ayrılmak istediğinize emin misiniz?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("İptal", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _leaveTable();
            },
            child: const Text("Evet, Ayrıl", style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text("Masa ${widget.table.tableNumber} Detayı"),
        backgroundColor: AppColors.background,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. MASA BİLGİSİ ---
            Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Icon(Icons.table_restaurant, size: 40, color: AppColors.primary),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Masa Kuralı",
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                        Text(
                          widget.table.currentRule ?? "Kural Yok (Serbest)",
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // --- 2. OTURANLAR ---
            const Text("Masadakiler", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
            const SizedBox(height: 10),
            _participants.isEmpty
                ? const Text("Kimse görünmüyor.", style: TextStyle(color: Colors.grey))
                : Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _participants.map((p) {
                final name = "${p['first_name']} ${p['last_name'] ?? ''}".trim();
                return Chip(
                  avatar: const CircleAvatar(
                    backgroundColor: AppColors.primary,
                    child: Icon(Icons.person, size: 16, color: Colors.white),
                  ),
                  label: Text(name),
                  backgroundColor: Colors.white,
                  side: BorderSide(color: Colors.grey.shade300),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // --- 3. SİPARİŞLER (ADİSYON) ---
            const Text("Açık Siparişler", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
            const SizedBox(height: 10),

            _orders.isEmpty
                ? Container(
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200)
              ),
              child: const Text("Henüz sipariş yok.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
            )
                : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _orders.length,
              itemBuilder: (context, index) {
                final order = _orders[index];
                final productName = order['products']['name'];
                final price = order['products']['price'];
                final quantity = order['quantity'];
                final status = order['status'];

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: const Icon(Icons.fastfood, color: Colors.brown),
                    title: Text("$productName (x$quantity)"),
                    subtitle: Text("Durum: $status"),
                    trailing: Text(
                      "${(price * quantity)} ₺",
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 40),

            // --- 4. AYRIL BUTONU ---
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _confirmLeave,
                icon: const Icon(Icons.exit_to_app),
                label: const Text("Masadan Ayrıl", style: TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}