import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/menu_provider.dart';
import '../providers/table_provider.dart';
import '../models/cafe_table.dart';
import '../constants/app_colors.dart';
import 'tables_screen.dart';

class MenuScreen extends ConsumerStatefulWidget {
  const MenuScreen({super.key});

  @override
  ConsumerState<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends ConsumerState<MenuScreen> {

  // Sipariş gönderme işlemi (Backend)
  Future<void> _submitOrder(CafeTable currentTable) async {
    final cart = ref.read(cartProvider); // Anlık sepeti oku
    final menuService = ref.read(menuServiceProvider); // Servisi al

    try {
      Navigator.pop(context); // Sepeti kapat

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Sipariş gönderiliyor... ⏳")),
      );

      await menuService.placeOrder(
        tableId: currentTable.id,
        cartItems: cart,
      );

      // Başarılı olursa sepeti temizle (Riverpod üzerinden)
      ref.read(cartProvider.notifier).clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Siparişiniz alındı! Afiyet olsun ☕"), backgroundColor: AppColors.success),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Hata: $e"), backgroundColor: AppColors.error),
        );
      }
    }
  }

  // UI: Cart Drawer
  void _openCartDrawer(CafeTable? currentTable) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        // BottomSheet içinde Riverpod dinlemek için Consumer kullanıyoruz
        return Consumer(
            builder: (context, ref, child) {
              // Anlık sepet verilerini dinle
              final cart = ref.watch(cartProvider);
              final totalPrice = ref.watch(cartTotalProvider);

              return Container(
                padding: const EdgeInsets.all(24),
                height: 500,
                child: Column(
                  children: [
                    const Text("Sepetim", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary)),
                    const Divider(),

                    Expanded(
                      child: cart.isEmpty
                          ? const Center(child: Text("Sepetiniz boş 🛒", style: TextStyle(color: Colors.grey, fontSize: 16)))
                          : ListView.builder(
                        itemCount: cart.length,
                        itemBuilder: (context, index) {
                          final product = cart.keys.elementAt(index);
                          final quantity = cart[product]!;
                          return ListTile(
                            title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text("${product.price} ₺ x $quantity"),
                            trailing: Text(
                              "${(product.price * quantity).toStringAsFixed(2)} ₺",
                              style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                            ),
                          );
                        },
                      ),
                    ),

                    const Divider(),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Toplam:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text(
                          "${totalPrice.toStringAsFixed(2)} ₺",
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    if (currentTable != null)
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: cart.isEmpty ? null : () => _submitOrder(currentTable),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                          ),
                          child: Text(
                            "Sipariş Ver (Masa ${currentTable.tableNumber})",
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      )
                    else
                      Column(
                        children: [
                          const Text(
                            "Lütfen sipariş vermeden önce masanızdaki QR kodunu okutun",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.redAccent),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                                Navigator.push(context, MaterialPageRoute(builder: (context) => const TablesScreen()));
                              },
                              icon: const Icon(Icons.qr_code_scanner),
                              label: const Text("QR Okut / Masa Seç"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              );
            }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // 1. Verileri Riverpod'dan İzle
    final productsAsync = ref.watch(productsProvider);
    final currentTableAsync = ref.watch(currentTableProvider);

    // Sepet verileri
    final cart = ref.watch(cartProvider);
    final totalItems = ref.watch(cartItemCountProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Menü"),
        backgroundColor: AppColors.background,
      ),
      body: productsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Hata: $err")),
        data: (products) {
          // DÜZELTME: valueOrNull yerine asData?.value kullanıldı
          final currentTable = currentTableAsync.asData?.value;

          return Stack(
            children: [
              // PRODUCT LIST
              ListView.builder(
                padding: const EdgeInsets.only(bottom: 100),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  final quantity = cart[product] ?? 0;

                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          // Image
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.brown.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: product.imageUrl != null
                                ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(product.imageUrl!, fit: BoxFit.cover),
                            )
                                : const Icon(Icons.fastfood, color: Colors.brown),
                          ),
                          const SizedBox(width: 16),

                          // Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.name,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                Text(
                                  "${product.price} ₺",
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),

                          // Controls (+ / -) using Riverpod
                          // ref.read(cartProvider.notifier) -> StateNotifier'ın metodlarına erişim sağlar
                          if (quantity == 0)
                            IconButton(
                              onPressed: () => ref.read(cartProvider.notifier).addToCart(product),
                              icon: const Icon(Icons.add_circle, color: AppColors.primary, size: 30),
                            )
                          else
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () => ref.read(cartProvider.notifier).removeFromCart(product),
                                  icon: const Icon(Icons.remove_circle_outline, color: AppColors.primary),
                                ),
                                Text(
                                  "$quantity",
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                IconButton(
                                  onPressed: () => ref.read(cartProvider.notifier).addToCart(product),
                                  icon: const Icon(Icons.add_circle, color: AppColors.primary),
                                ),
                              ],
                            )
                        ],
                      ),
                    ),
                  );
                },
              ),

              // FLOATING CART BUTTON
              if (totalItems > 0)
                Positioned(
                  right: 0,
                  top: MediaQuery.of(context).size.height / 2 - 40,
                  child: GestureDetector(
                    onTap: () => _openCartDrawer(currentTable),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          bottomLeft: Radius.circular(30),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          )
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.shopping_cart, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            "$totalItems",
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.arrow_back_ios_new, size: 16, color: Colors.white70),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}