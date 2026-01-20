import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/cafe_table.dart';
import '../services/table_service.dart';

// --- SERVICE PROVIDER ---
final tableServiceProvider = Provider((ref) => TableService());

// --- DATA PROVIDERS ---

// Kullanıcının şu an oturduğu masayı getiren provider
final currentTableProvider = FutureProvider<CafeTable?>((ref) async {
  final service = ref.watch(tableServiceProvider);
  return await service.getCurrentActiveTable();
});

// Tüm masaların listesini stream olarak getiren provider
final allTablesStreamProvider = StreamProvider<List<CafeTable>>((ref) {
  final service = ref.watch(tableServiceProvider);
  return service.getTablesStream();
});

// --- UI STATE NOTIFIER (Masa Detayı Açık mı?) ---
// Bu değişken TableDetailScreen açıldığında true, kapandığında false olur.
class IsTableDetailOpenNotifier extends Notifier<bool> {
  @override
  bool build() {
    return false; // Varsayılan: Kapalı
  }

  void set(bool value) => state = value;
}

final isTableDetailOpenProvider = NotifierProvider<IsTableDetailOpenNotifier, bool>(IsTableDetailOpenNotifier.new);