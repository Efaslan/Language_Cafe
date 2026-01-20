import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/menu_provider.dart';
import '../constants/app_colors.dart';

class MenuScreen extends ConsumerStatefulWidget {
  const MenuScreen({super.key});

  @override
  ConsumerState<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends ConsumerState<MenuScreen> {
  // Sadece ürün ekleme/çıkarma işlemleri kaldı, sipariş verme Global Butona taşındı.

  @override
  Widget build(BuildContext context) {
    // 1. Verileri Riverpod'dan İzle
    final productsAsync = ref.watch(productsProvider);
    final cart = ref.watch(cartProvider);

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
          // Stack kaldırıldı, sadece Liste var.
          return ListView.builder(
            // Sepet butonu üstte kalacağı için listenin altına boşluk bırakıyoruz
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
          );
        },
      ),
    );
  }
}