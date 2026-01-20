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
  // Seçili kategoriyi tutan değişken (Varsayılan: Hepsi)
  String _selectedCategory = 'Hepsi';

  @override
  Widget build(BuildContext context) {
    // Verileri Riverpod'dan izle
    final productsAsync = ref.watch(productsProvider);
    final cart = ref.watch(cartProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Menü"),
        backgroundColor: AppColors.background,
        centerTitle: true, // Başlığı ortalar
      ),
      body: productsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Hata: $err")),
        data: (allProducts) {

          // --- KATEGORİ MANTIĞI ---
          // 1. Veritabanındaki ürünlerden benzersiz kategorileri çıkar
          final categories = ['Hepsi', ...allProducts.map((e) => e.category).toSet().toList()];

          // 2. Seçili kategoriye göre ürünleri filtrele
          final displayedProducts = _selectedCategory == 'Hepsi'
              ? allProducts
              : allProducts.where((p) => p.category == _selectedCategory).toList();

          return Column(
            children: [
              // --- KATEGORİ LİSTESİ (Yatay) ---
              SizedBox(
                height: 60, // Kategori çubuğunun yüksekliği
                child: ListView.builder(
                  scrollDirection: Axis.horizontal, // Yan yana kaydırma
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    final isSelected = category == _selectedCategory;

                    return Padding(
                      padding: const EdgeInsets.only(right: 10), // Kartlar arası boşluk
                      child: ChoiceChip(
                        label: Text(
                          category,
                          style: TextStyle(
                            color: isSelected ? Colors.white : AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: AppColors.primary, // Seçili renk
                        backgroundColor: Colors.white,    // Seçili olmayan renk
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20), // Kenar yuvarlaklığı
                          side: const BorderSide(color: AppColors.primary), // Çerçeve rengi
                        ),
                        onSelected: (bool selected) {
                          if (selected) {
                            // Tıklanınca kategoriyi güncelle ve ekranı yenile
                            setState(() {
                              _selectedCategory = category;
                            });
                          }
                        },
                      ),
                    );
                  },
                ),
              ),

              // --- ÜRÜN LİSTESİ (Dikey) ---
              Expanded(
                // Kalan tüm boşluğu kapla
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100), // Alttan boşluk (Sepet butonu için)
                  itemCount: displayedProducts.length,
                  itemBuilder: (context, index) {
                    final product = displayedProducts[index];
                    final quantity = cart[product] ?? 0;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12), // Kartlar arası dikey boşluk
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 2, // Gölge efekti
                      child: Padding(
                        padding: const EdgeInsets.all(12.0), // İç boşluk
                        child: Row(
                          children: [
                            // --- Ürün Resmi ---
                            Container(
                              width: 60,  // Resim genişliği
                              height: 60, // Resim yüksekliği
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
                            const SizedBox(width: 16), // Resim ile yazı arası boşluk

                            // --- Ürün Bilgisi ---
                            Expanded(
                              // Yazının sığdığı kadar alan kaplaması için
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

                            // --- Artır/Azalt Butonları ---
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
              ),
            ],
          );
        },
      ),
    );
  }
}