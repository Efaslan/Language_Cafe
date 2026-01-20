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
      // created_at otomatik now() olur
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

  Future<CafeTable?> getCurrentActiveTable() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return null;

    try {
      // 1. Find active participation
      final participation = await _supabase
          .from('table_participants')
          .select('table_id')
          .eq('user_id', userId)
          .isFilter('left_at', null) // Only active sessions
          .maybeSingle();

      if (participation == null) return null;

      // 2. Fetch table details
      final tableData = await _supabase
          .from('cafe_tables')
          .select()
          .eq('id', participation['table_id'])
          .single();

      return CafeTable.fromJson(tableData);
    } catch (e) {
      // Log error silently
      return null;
    }
  }
}