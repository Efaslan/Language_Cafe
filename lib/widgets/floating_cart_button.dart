import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:language_cafe/utils/context_extensions.dart';
import '../constants/app_colors.dart';
import '../providers/menu_provider.dart';
import '../providers/table_provider.dart';
import '../models/cafe_table.dart';
import '../screens/tables_screen.dart';
import '../main.dart'; // navigatorKey'e erişmek için import et

class FloatingCartButton extends ConsumerStatefulWidget {
  const FloatingCartButton({super.key});

  @override
  ConsumerState<FloatingCartButton> createState() => _FloatingCartButtonState();
}

class _FloatingCartButtonState extends ConsumerState<FloatingCartButton> {
  // Dialog açmak için kullanılacak Context'i getiren yardımcı
  BuildContext? get _navContext => navigatorKey.currentContext;

  Future<void> _submitOrder(CafeTable currentTable) async {
    final cart = ref.read(cartProvider);
    final menuService = ref.read(menuServiceProvider);

    if (_navContext == null) return;

    try {
      Navigator.pop(_navContext!); // Sepeti kapat

      ScaffoldMessenger.of(_navContext!).showSnackBar(
        SnackBar(content: Text(context.l10n.preparingOrder)),
      );

      await menuService.placeOrder(
        tableId: currentTable.id,
        cartItems: cart,
      );

      ref.read(cartProvider.notifier).clear(); // Sepeti temizle

      if (mounted && _navContext != null) {
        ScaffoldMessenger.of(_navContext!).showSnackBar(
          SnackBar(content: Text(context.l10n.bonAppetit), backgroundColor: AppColors.success),
        );
      }
    } catch (e) {
      if (mounted && _navContext != null) {
        ScaffoldMessenger.of(_navContext!).showSnackBar(
          SnackBar(content: Text("Hata: $e"), backgroundColor: AppColors.error),
        );
      }
    }
  }

  void _openCartDrawer() {
    if (_navContext == null) return;
    ref.read(isCartOpenProvider.notifier).set(true);

    // Tablo bilgisini tazeleyelim
    ref.refresh(currentTableProvider);

    showModalBottomSheet(
      context: _navContext!,
      backgroundColor: context.isDark ? AppColors.darkBackground : AppColors.white,
      isScrollControlled: true, // Tam boy kontrolü için
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Consumer(
            builder: (context, ref, child) {
              final cart = ref.watch(cartProvider);
              final totalPrice = ref.watch(cartTotalProvider);
              final tableAsync = ref.watch(currentTableProvider);

              return Container(
                padding: const EdgeInsets.all(24),
                // Yüksekliği biraz artırdık, içerik sığsın
                height: 600,
                child: Column(
                  children: [
                    Text(context.l10n.myCart, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary)),
                    const Divider(),

                    Expanded(
                      child: cart.isEmpty
                          ? Center(child: Text(context.l10n.cartEmpty, style: TextStyle(color: AppColors.grey, fontSize: 16)))
                          : ListView.separated(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        itemCount: cart.length,
                        separatorBuilder: (ctx, i) => const Divider(),
                        itemBuilder: (context, index) {
                          final product = cart.keys.elementAt(index);
                          final quantity = cart[product]!;

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              children: [
                                // 1. Ürün Resmi
                                Container(
                                  width: 65,
                                  height: 65,
                                  decoration: BoxDecoration(
                                    color: AppColors.brownShade50,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: product.imageUrl != null
                                      ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(product.imageUrl!, fit: BoxFit.cover),
                                  )
                                      : const Icon(Icons.fastfood, color: AppColors.primary, size: 24),
                                ),
                                const SizedBox(width: 12),

                                // 2. Ürün Adı ve Kontroller
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product.name,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      // Artırma / Azaltma Butonları (Menüdeki gibi)
                                      Row(
                                        children: [
                                          InkWell(
                                            onTap: () => ref.read(cartProvider.notifier).removeFromCart(product),
                                            child: Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                color: AppColors.greyShade200,
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(Icons.remove, size: 16, color: AppColors.primary),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                            child: Text(
                                              "$quantity",
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                            ),
                                          ),
                                          InkWell(
                                            onTap: () => ref.read(cartProvider.notifier).addToCart(product),
                                            child: Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                color: AppColors.primary,
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(Icons.add, size: 16, color: AppColors.white),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                // 3. Urun Toplam Fiyat (Sağ Köşe)
                                Text(
                                  "${(product.price * quantity).toStringAsFixed(2)} ₺",
                                  style: const TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                    const Divider(),

                    // Alt Kısım (Toplam ve Buton) - Değişmedi
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(context.l10n.totalLabel, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text(
                          "${totalPrice.toStringAsFixed(2)} ₺",
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    tableAsync.when(
                      data: (currentTable) {
                        if (currentTable != null) {
                          return SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: cart.isEmpty ? null : () => _submitOrder(currentTable),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: AppColors.white,
                              ),
                              child: Text(
                                context.l10n.orderBtn(currentTable.tableNumber),
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                          );
                        } else {
                          return _buildQrButton(context);
                        }
                      },
                      loading: () => const CircularProgressIndicator(),
                      error: (err, stack) => _buildQrButton(context),
                    ),
                  ],
                ),
              );
            }
        );
      },
    ).whenComplete(() async {
      // Sepet KAPANDI: Animasyonun bitmesini bekle ve butonu geri getir
      await Future.delayed(const Duration(milliseconds: 200));

      if (mounted) {
        // Global provider'ı güncelle: Sepet kapandı, butonu göster
        ref.read(isCartOpenProvider.notifier).set(false);
      }
    });
  }

  Widget _buildQrButton(BuildContext context) {
    return Column(
      children: [
        const Text(
          "Lütfen sipariş vermeden önce masanızdaki QR kodunu okutun",
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.redAccent),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              if (_navContext != null) {
                Navigator.push(_navContext!, MaterialPageRoute(builder: (context) => const TablesScreen()));
              }
            },
            icon: const Icon(Icons.qr_code_scanner),
            label: const Text("QR Okut"),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.grey,
              foregroundColor: AppColors.white,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalItems = ref.watch(cartItemCountProvider);

    final isCartOpen = ref.watch(isCartOpenProvider);

    // Eğer sepet boşsa VEYA sepet paneli açıksa butonu gösterme
    if (totalItems == 0 || isCartOpen) return const SizedBox.shrink();

    return Positioned(
      right: 0,
      top: MediaQuery.of(context).size.height / 2,
      child: Material(
        color: AppColors.transparent,
        child: InkWell(
          onTap: _openCartDrawer,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            bottomLeft: Radius.circular(30),
          ),
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
                  color: AppColors.black26,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                )
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.shopping_cart, color: AppColors.white),
                const SizedBox(width: 4),
                Text(
                  "$totalItems",
                  style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_back_ios_new, size: 16, color: AppColors.white70),
              ],
            ),
          ),
        ),
      ),
    );
  }
}