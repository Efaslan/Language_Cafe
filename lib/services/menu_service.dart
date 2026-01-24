import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product.dart';

class MenuService {
  final _supabase = Supabase.instance.client;

  /// Tüm aktif ürünleri getirir
  Future<List<Product>> getProducts() async {
    final data = await _supabase
        .from('products')
        .select()
        .eq('is_available', true) // Sadece stokta olanlar
        .order('category', ascending: true);

    return (data as List).map((json) => Product.fromJson(json)).toList();
  }

  /// Siparişi veritabanına kaydeder
  Future<void> placeOrder({
    required int tableId,
    required Map<Product, int> cartItems, // Hangi üründen kaç tane
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) throw Exception("Kullanıcı oturumu yok");

    final List<Map<String, dynamic>> orderRows = [];

    cartItems.forEach((product, quantity) {
      // Her ürün için veritabanına bir satır ekliyoruz
      orderRows.add({
        'table_id': tableId,
        'user_id': userId,
        'product_id': product.id,
        'quantity': quantity,
        'price_at_order': product.price, // O anki fiyatı kilitliyoruz
        'status': 'Preparing',
      });
    });

    if (orderRows.isNotEmpty) {
      await _supabase.from('orders').insert(orderRows);
    }
  }

  Future<List<Map<String, dynamic>>> getTableOrders(int tableId) async {
    final data = await _supabase
        .from('orders')
        .select('quantity, status, products(name, name_en, price)') // İlişkili ürün bilgilerini de çek
        .eq('table_id', tableId)
        .inFilter('status', ['Preparing', 'Served'])
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(data);
  }
}