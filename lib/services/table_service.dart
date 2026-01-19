import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/cafe_table.dart';

class TableService {
  final _supabase = Supabase.instance.client;

  Stream<List<CafeTable>> getTablesStream() {
    return _supabase
        .from('cafe_tables')
        .stream(primaryKey: ['id'])
        .order('table_number', ascending: true) // Numaraya göre sırala
        .map((data) => data.map((json) => CafeTable.fromJson(json)).toList());
  }

  /// Masaya Oturma İşlemi
  /// Business Logic: Kapasite kontrolü burada yapılır.
  Future<void> joinTable({required CafeTable table, required String userId}) async {

    // 2. Veritabanı İşlemi
    await _supabase.from('table_participants').insert({
      'table_id': table.id,
      'user_id': userId,
      // joined_at otomatik now() olur
      // left_at null olur (aktif)
    });
  }

  /// Masadan Kalkma İşlemi
  Future<void> leaveTable({required String userId}) async {
    await _supabase
        .from('table_participants')
        .update({'left_at': DateTime.now().toIso8601String()})
        .eq('user_id', userId)
        .isFilter('left_at', null); // Sadece aktif olanı kapat
  }
}