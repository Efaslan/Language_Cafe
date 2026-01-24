import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/context_extensions.dart';
import '../providers/menu_provider.dart';
import '../constants/app_colors.dart';

class MenuScreen extends ConsumerStatefulWidget {
  const MenuScreen({super.key});

  @override
  ConsumerState<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends ConsumerState<MenuScreen> {
  // Seçili kategori (Her zaman veritabanındaki orijinal/Türkçe değer tutulur)
  // Boş string = Hepsi
  String _selectedCategoryRaw = '';

  @override
  Widget build(BuildContext context) {
    // Verileri Riverpod'dan izle
    final productsAsync = ref.watch(productsProvider);
    final cart = ref.watch(cartProvider);

    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        title: Text(context.l10n.menuLabel),
        backgroundColor: context.backgroundColor,
        centerTitle: true, // Başlığı ortalar
      ),
      body: productsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Hata: $err")),
        data: (allProducts) {

          // --- KATEGORİ MANTIĞI ---
          // 1. Veritabanındaki ürünlerden benzersiz kategorileri çıkar
          final rawCategories = ['', ...allProducts.map((e) => e.category).toSet()];

          // Filtreleme (Orijinal isme göre yapılır)
          final displayedProducts = _selectedCategoryRaw.isEmpty
              ? allProducts
              : allProducts.where((p) => p.category == _selectedCategoryRaw).toList();

          return Column(
            children: [
              // --- KATEGORİ LİSTESİ (Yatay) ---
              SizedBox(
                height: 60, // Kategori çubuğunun yüksekliği
                child: ListView.builder(
                  scrollDirection: Axis.horizontal, // Yan yana kaydırma
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  itemCount: rawCategories.length,
                  itemBuilder: (context, index) {
                    final rawCategory = rawCategories[index];
                    final isSelected = rawCategory == _selectedCategoryRaw;

                    // GÖRÜNTÜLEME İSMİ (Label)
                    String displayLabel;
                    if (rawCategory.isEmpty) {
                      displayLabel = context.l10n.allCategories; // "Hepsi" veya "All" (.arb dosyasından)
                    } else {
                      // Orijinal kategorinin İngilizce karşılığını bulmamız lazım.
                      // Listeden bu kategoriye sahip ilk ürünü bulup onun çeviri metodunu kullanıyoruz.
                      // (Biraz hileli ama pratik bir yöntemdir)
                      final productExample = allProducts.firstWhere((p) => p.category == rawCategory);
                      displayLabel = productExample.getLocalizedCategory(context);
                    }

                    return Padding(
                      padding: const EdgeInsets.only(right: 10), // Kartlar arası boşluk
                      child: ChoiceChip(
                        label: Text(
                          displayLabel,
                          style: TextStyle(
                            color: isSelected ? AppColors.white : AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: AppColors.primary, // Seçili renk
                        backgroundColor: AppColors.white,    // Seçili olmayan renk
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20), // Kenar yuvarlaklığı
                          side: const BorderSide(color: AppColors.primary), // Çerçeve rengi
                        ),
                        onSelected: (bool selected) {
                          if (selected) {
                            // Tıklanınca kategoriyi güncelle ve ekranı yenile
                            setState(() {
                              _selectedCategoryRaw = rawCategory;
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
                                color: AppColors.brownShade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: product.imageUrl != null
                                  ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(product.imageUrl!, fit: BoxFit.cover),
                              )
                                  : const Icon(Icons.fastfood, color: AppColors.primary),
                            ),
                            const SizedBox(width: 16), // Resim ile yazı arası boşluk

                            // --- Ürün Bilgisi ---
                            Expanded(
                              // Yazının sığdığı kadar alan kaplaması için
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.getLocalizedName(context),
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  Text(
                                    "${product.price} ₺",
                                    style: const TextStyle(color: AppColors.grey),
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