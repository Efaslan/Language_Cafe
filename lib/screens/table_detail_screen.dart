import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:language_cafe/utils/context_extensions.dart';
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
            SnackBar(content: Text(context.l10n.leftTable), backgroundColor: AppColors.grey),
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
        title: Text(context.l10n.leaveTable),
        content: Text(context.l10n.confirmLeaveTable),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.l10n.cancelBtn, style: TextStyle(color: AppColors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _leaveTable();
            },
            child: Text(context.l10n.yesLeaveTable, style: TextStyle(color: AppColors.redAccent)),
          ),
        ],
      ),
    );
  }

  String _getLocalizedStatus(String dbStatus) {
    switch (dbStatus) {
      case 'Preparing':
        return context.l10n.statusPreparing;
      case 'Served':
        return context.l10n.statusServed;
      case 'Paid':
        return context.l10n.statusPaid;
      case 'Cancelled':
        return context.l10n.statusCancelled;
      default:
        return dbStatus; // Bilinmeyen bir durumsa olduğu gibi göster
    }
  }

  @override
  Widget build(BuildContext context) {

    final isEnglish = Localizations.localeOf(context).languageCode == 'en';

    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        title: Text(context.l10n.tableDetailTitle(widget.table.tableNumber)),
        backgroundColor: context.backgroundColor,
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
              color: AppColors.white,
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
                          context.l10n.tableRule,
                          style: TextStyle(color: AppColors.greyShade600, fontSize: 12),
                        ),
                        Text(
                          widget.table.currentRule ?? context.l10n.noTableRule,
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
            Text(context.l10n.tableParticipants, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
            const SizedBox(height: 10),
            _participants.isEmpty
                ? Text(context.l10n.noParticipants, style: TextStyle(color: AppColors.grey))
                : Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _participants.map((p) {
                final name = "${p['first_name']} ${p['last_name'] ?? ''}".trim();
                return Chip(
                  avatar: const CircleAvatar(
                    backgroundColor: AppColors.primary,
                    child: Icon(Icons.person, size: 16, color: AppColors.white),
                  ),
                  label: Text(name),
                  backgroundColor: AppColors.white,
                  side: BorderSide(color: AppColors.greyShade300),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // --- 3. SİPARİŞLER (ADİSYON) ---
            Text(context.l10n.openOrders, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
            const SizedBox(height: 10),

            _orders.isEmpty
                ? Container(
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.greyShade200)
              ),
              child: Text(context.l10n.noOrdersYet, textAlign: TextAlign.center, style: TextStyle(color: AppColors.grey)),
            )
                : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _orders.length,
              itemBuilder: (context, index) {
                final order = _orders[index];
                final productData = order['products'];
                String productName = productData['name'];
                if (isEnglish) {
                  productName = productData['name_en'];
                }

                final price = productData['price'];
                final quantity = order['quantity'];
                final localizedStatus = _getLocalizedStatus(order['status']);

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: const Icon(Icons.fastfood, color: AppColors.primary),
                    title: Text("$productName (x$quantity)"),
                    subtitle: Text(context.l10n.orderStatus(localizedStatus)),
                    trailing: Text(
                      "${(price * quantity)} ₺",
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.primary),
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
                label: Text(context.l10n.leaveTable, style: TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.redAccent,
                  foregroundColor: AppColors.white,
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