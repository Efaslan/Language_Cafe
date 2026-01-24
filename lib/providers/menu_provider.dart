import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // JSON işlemleri için
import '../models/product.dart';
import '../services/menu_service.dart';

// --- SERVICE PROVIDER ---
final menuServiceProvider = Provider<MenuService>((ref) => MenuService());

// --- DATA PROVIDER ---
final productsProvider = FutureProvider<List<Product>>((ref) async {
  final service = ref.watch(menuServiceProvider);
  return await service.getProducts();
});

// --- UI STATE NOTIFIER ---
class IsCartOpenNotifier extends Notifier<bool> {
  @override
  bool build() => false;
  void set(bool value) => state = value;
}
final isCartOpenProvider = NotifierProvider<IsCartOpenNotifier, bool>(IsCartOpenNotifier.new);

// --- CART NOTIFIER (Kalıcı Sepet) ---
class CartNotifier extends Notifier<Map<Product, int>> {
  static const _cartKey = 'user_cart';

  @override
  Map<Product, int> build() {
    // 1. Başlangıçta hafızayı kontrol et ve yükle
    _loadCart();
    return <Product, int>{};
  }

  Future<void> _loadCart() async {
    final prefs = await SharedPreferences.getInstance();
    final String? cartJson = prefs.getString(_cartKey);

    if (cartJson != null) {
      try {
        final List<dynamic> decodedList = jsonDecode(cartJson);
        final Map<Product, int> loadedCart = {};

        for (var item in decodedList) {
          final product = Product.fromJson(item['product']);
          final int quantity = item['quantity'];
          loadedCart[product] = quantity;
        }
        state = loadedCart; // State'i güncelle
      } catch (e) {
        // Hata olursa (eski veri formatı vs.) sepeti sıfırla
        await prefs.remove(_cartKey);
      }
    }
  }

  Future<void> _saveCart(Map<Product, int> cart) async {
    final prefs = await SharedPreferences.getInstance();

    // Sepeti listeye çevir: [{'product': {...}, 'quantity': 2}, ...]
    final List<Map<String, dynamic>> cartList = cart.entries.map((entry) {
      return {
        'product': entry.key.toJson(),
        'quantity': entry.value,
      };
    }).toList();

    await prefs.setString(_cartKey, jsonEncode(cartList));
  }

  void addToCart(Product product) {
    final newState = Map<Product, int>.from(state);
    newState[product] = (newState[product] ?? 0) + 1;
    state = newState;
    _saveCart(newState); // Kaydet
  }

  void removeFromCart(Product product) {
    final newState = Map<Product, int>.from(state);
    if (newState.containsKey(product)) {
      if (newState[product]! > 1) {
        newState[product] = newState[product]! - 1;
      } else {
        newState.remove(product);
      }
    }
    state = newState;
    _saveCart(newState); // Kaydet
  }

  void clear() async {
    state = <Product, int>{};
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cartKey); // Hafızadan da sil
  }
}

final cartProvider = NotifierProvider<CartNotifier, Map<Product, int>>(CartNotifier.new);

// --- YARDIMCI PROVIDERLAR ---
final cartTotalProvider = Provider<double>((ref) {
  final cart = ref.watch(cartProvider);
  double total = 0;
  cart.forEach((product, qty) {
    total += product.price * qty;
  });
  return total;
});

final cartItemCountProvider = Provider<int>((ref) {
  final cart = ref.watch(cartProvider);
  int count = 0;
  cart.forEach((_, qty) => count += qty);
  return count;
});