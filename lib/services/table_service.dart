import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/cafe_table.dart';

class TableService {
  final _supabase = Supabase.instance.client;

  Stream<List<CafeTable>> getTablesStream() {
    return _supabase
        .from('cafe_tables')
        .stream(primaryKey: ['id'])
        .order('id', ascending: true)
        .map((data) => data.map((json) => CafeTable.fromJson(json)).toList());
  }
}