import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/cafe_table.dart';
import '../services/table_service.dart';

// --- SERVICE PROVIDER ---
final tableServiceProvider = Provider((ref) => TableService());

// --- DATA PROVIDERS ---

// Kullanıcının şu an oturduğu masayı getiren provider
// (Örn: Sipariş verirken hangi masadayım?)
final currentTableProvider = FutureProvider<CafeTable?>((ref) async {
  final service = ref.watch(tableServiceProvider);
  return await service.getCurrentActiveTable();
});

// Tüm masaların listesini stream olarak getiren provider
// (Örn: Ana ekranda canlı masa durumlarını göstermek için)
final allTablesStreamProvider = StreamProvider<List<CafeTable>>((ref) {
  final service = ref.watch(tableServiceProvider);
  return service.getTablesStream();
});