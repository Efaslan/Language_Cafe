import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_colors.dart';
import '../providers/table_provider.dart';
import '../services/table_service.dart';
import '../models/cafe_table.dart';

import '../providers/menu_provider.dart';

class DraggableTableBubble extends ConsumerStatefulWidget {
  const DraggableTableBubble({super.key});

  @override
  ConsumerState<DraggableTableBubble> createState() => _DraggableTableBubbleState();
}

class _DraggableTableBubbleState extends ConsumerState<DraggableTableBubble> {
  // Balonun ekrandaki başlangıç konumu (Sol Alt taraf)
  Offset _position = const Offset(20, 500);
  final _tableService = TableService();

  // Masadan Ayrılma Mantığı
  Future<void> _leaveTable(int tableId, String userId) async {
    try {
      // 1. Servisi çağır: Veritabanından çıkış yap
      await _tableService.leaveTable(userId: userId);

      // 2. Provider'ı yenile: Balonun kaybolmasını sağla (Veri null döneceği için)
      ref.invalidate(currentTableProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Masadan ayrıldınız. Güle güle! 👋"),
            backgroundColor: Colors.grey,
          ),
        );
        Navigator.pop(context); // Diyaloğu kapat
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Hata: $e"), backgroundColor: AppColors.error),
        );
      }
    }
  }

  // Ayrılma Onay Penceresi (Dialog)
  void _showLeaveDialog(CafeTable table, String userId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Masa ${table.tableNumber}", style: const TextStyle(color: AppColors.primary)),
        content: const Text("Masadan ayrılmak istediğinize emin misiniz?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Hayır", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => _leaveTable(table.id, userId),
            child: const Text("Evet, Ayrıl", style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Riverpod'dan aktif masa bilgisini dinle
    final tableAsync = ref.watch(currentTableProvider);

    // Sepet durumunu dinle
    final isCartOpen = ref.watch(isCartOpenProvider);

    // Eğer sepet açıksa balonu gizle
    if (isCartOpen) return const SizedBox.shrink();

    return tableAsync.when(
      data: (table) {
        // Eğer kullanıcı bir masada oturmuyorsa (null), balonu hiç gösterme
        if (table == null) return const SizedBox.shrink();

        return Positioned(
          // Balonun anlık konumu
          left: _position.dx,
          top: _position.dy,

          // Sürüklenebilir Widget (Draggable)
          child: Draggable(
            feedback: _buildBubble(table, isDragging: true), // Sürüklerken parmağın altındaki görüntü
            childWhenDragging: Container(), // Sürüklerken eski yerinde kalan (Boşluk)
            onDraggableCanceled: (velocity, offset) {
              // Sürükleme bitince (bırakınca) yeni konumu kaydet
              setState(() {
                _position = offset;
              });
            },
            // Normal duran hali (Sürüklenmediği zaman)
            child: GestureDetector(
              onTap: () {
                // Tıklanınca masadan ayrılma diyaloğunu aç
                final userId = _tableService.currentUserId;
                if (userId != null) {
                  _showLeaveDialog(table, userId);
                }
              },
              child: _buildBubble(table),
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(), // Yüklenirken gizle
      error: (err, stack) => const SizedBox.shrink(), // Hata varsa gizle
    );
  }

  // Yuvarlak Balonun Tasarımı (GÜNCELLENDİ)
  Widget _buildBubble(CafeTable table, {bool isDragging = false}) {
    return Material(
      color: Colors.transparent, // Arka plan şeffaf, sadece yuvarlak gözüksün
      child: Container(
        width: 70, // Balonun genişliği (Biraz daha büyük)
        height: 70, // Balonun yüksekliği
        decoration: BoxDecoration(
          // Sürükleniyorsa biraz şeffaf yap, değilse tam renk
          color: AppColors.primary.withOpacity(isDragging ? 0.8 : 1.0),
          shape: BoxShape.circle, // Şekli tam yuvarlak
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3), // Hafif gölge
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: Colors.white, width: 2), // Beyaz çerçeve
        ),
        // Stack: İkon ve Numarayı üst üste bindirmek için
        child: Stack(
          alignment: Alignment.center, // İçerikleri merkeze hizala
          children: [
            // 1. KATMAN: Büyük Masa İkonu
            const Icon(
                Icons.table_restaurant,
                color: Colors.white,
                size: 32 // İkon boyutu büyüdü, ortayı kaplıyor
            ),

            // 2. KATMAN: Masa Numarası (Sağ Üst Köşe)
            Positioned(
              top: 0, // Üstten biraz boşluk
              right: 9, // Sağdan biraz boşluk (İkonun üzerine hafif binmesi için)
              child: Container(
                padding: const EdgeInsets.all(7), // Numara etrafındaki dolgu
                decoration: const BoxDecoration(
                  color: Colors.redAccent, // Numara arka planı (Kırmızı Rozet)
                  shape: BoxShape.circle, // Numara kutusu da yuvarlak
                ),
                child: Text(
                  "${table.tableNumber}", // Masa numarası
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14, // Küçük font (Üs gibi durması için)
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}