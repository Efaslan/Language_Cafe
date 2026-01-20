import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product.dart';
import '../services/menu_service.dart';

// --- SERVICE PROVIDER ---
final menuServiceProvider = Provider<MenuService>((ref) => MenuService());

// --- DATA PROVIDER (Ürünler) ---
final productsProvider = FutureProvider<List<Product>>((ref) async {
  final service = ref.watch(menuServiceProvider);
  return await service.getProducts();
});

// --- UI STATE NOTIFIER (Sepet Açık mı?) ---
class IsCartOpenNotifier extends Notifier<bool> {
  @override
  bool build() {
    return false; // Varsayılan değer
  }

  // Değeri değiştirmek için fonksiyonlar
  void set(bool value) => state = value;
  void toggle() => state = !state;
}
final isCartOpenProvider = NotifierProvider<IsCartOpenNotifier, bool>(IsCartOpenNotifier.new);

// --- NOTIFIER (Sepet Mantığı - Riverpod 2.0 Modern Yapı) ---
// StateNotifier yerine Notifier kullanıyoruz. Bu sınıf doğrudan paketin içindedir.
class CartNotifier extends Notifier<Map<Product, int>> {

  @override
  Map<Product, int> build() {
    // Başlangıç değeri (Initial State) burada tanımlanır
    return <Product, int>{};
  }

  // Ürün Ekle
  void addToCart(Product product) {
    // State immutable olduğu için kopyalayıp güncelliyoruz
    final newState = Map<Product, int>.from(state);
    newState[product] = (newState[product] ?? 0) + 1;
    state = newState;
  }

  // Ürün Çıkar
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
  }

  // Sepeti Temizle
  void clear() {
    state = <Product, int>{};
  }
}

// Sepet Provider'ı (NotifierProvider kullanıyoruz)
final cartProvider = NotifierProvider<CartNotifier, Map<Product, int>>(CartNotifier.new);

// --- YARDIMCI PROVIDERLAR (Hesaplamalar) ---

// Toplam Fiyat
final cartTotalProvider = Provider<double>((ref) {
  final cart = ref.watch(cartProvider);
  double total = 0;
  cart.forEach((product, qty) {
    total += product.price * qty;
  });
  return total;
});

// Toplam Ürün Sayısı
final cartItemCountProvider = Provider<int>((ref) {
  final cart = ref.watch(cartProvider);
  int count = 0;
  cart.forEach((_, qty) => count += qty);
  return count;
});