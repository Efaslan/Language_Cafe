import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_colors.dart';
import '../providers/table_provider.dart';
import '../providers/menu_provider.dart';
import '../models/cafe_table.dart';
import '../screens/table_detail_screen.dart';
import '../main.dart'; // navigatorKey için

class DraggableTableBubble extends ConsumerStatefulWidget {
  const DraggableTableBubble({super.key});

  @override
  ConsumerState<DraggableTableBubble> createState() => _DraggableTableBubbleState();
}

class _DraggableTableBubbleState extends ConsumerState<DraggableTableBubble> {
  Offset _position = const Offset(20, 500);
  BuildContext? get _navContext => navigatorKey.currentContext;

  @override
  Widget build(BuildContext context) {
    final tableAsync = ref.watch(currentTableProvider);
    final isCartOpen = ref.watch(isCartOpenProvider);
    final isTableDetailOpen = ref.watch(isTableDetailOpenProvider);

    if (isCartOpen || isTableDetailOpen) return const SizedBox.shrink();

    return tableAsync.when(
      data: (table) {
        if (table == null) return const SizedBox.shrink();

        return Positioned(
          left: _position.dx,
          top: _position.dy,

          child: Draggable(
            feedback: _buildBubble(table, isDragging: true),
            childWhenDragging: Container(),
            onDraggableCanceled: (velocity, offset) {
              setState(() {
                _position = offset;
              });
            },
            child: GestureDetector(
              onTap: () async { // ASYNC EKLENDİ
                if (_navContext != null) {
                  // 1. Gizle (State'i güncelle)
                  ref.read(isTableDetailOpenProvider.notifier).set(true);

                  // 2. Git ve Sayfanın Kapanmasını BEKLE (AWAIT)
                  // Bu satır, TableDetailScreen kapanana kadar kodu durdurur.
                  await Navigator.push(
                    _navContext!,
                    MaterialPageRoute(
                      builder: (context) => TableDetailScreen(table: table),
                    ),
                  );

                  await Future.delayed(const Duration(milliseconds: 210));
                  // 3. Sayfa kapandı, kodu devam ettir ve butonu geri getir
                  // (Eğer masadan ayrıldıysa table null döneceği için zaten gizli kalır)
                  if (mounted) {
                    ref.read(isTableDetailOpenProvider.notifier).set(false);
                  }
                }
              },
              child: _buildBubble(table),
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (err, stack) => const SizedBox.shrink(),
    );
  }

  Widget _buildBubble(CafeTable table, {bool isDragging = false}) {
    return Material(
      color: AppColors.transparent,
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: isDragging ? 0.8 : 1.0),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: AppColors.white, width: 2),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Icon(
                Icons.table_restaurant,
                color: AppColors.white,
                size: 32
            ),

            Positioned(
              top: 3,
              right: 9,
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: const BoxDecoration(
                  color: AppColors.redAccent,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  "${table.tableNumber}",
                  style: const TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
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