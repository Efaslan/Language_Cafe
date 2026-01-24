import 'package:flutter/widgets.dart';

class Product {
  final int id;
  final String name;
  final String nameEn;
  final double price;
  final String category;
  final String categoryEn;
  final String? imageUrl;
  final bool isAvailable;

  Product({
    required this.id,
    required this.name,
    required this.nameEn,
    required this.price,
    required this.category,
    required this.categoryEn,
    this.imageUrl,
    required this.isAvailable,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      nameEn: json['name_en'],
      // Supabase numeric/float gelebilir, double'a çeviriyoruz
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      category: json['category'],
      categoryEn: json['category_en'],
      imageUrl: json['image_url'],
      isAvailable: json['is_available'],
    );
  }

  // YENİ: Objeyi JSON'a çevir (Kaydetmek için)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'name_en': nameEn,
      'price': price,
      'category': category,
      'category_en': categoryEn,
      'image_url': imageUrl,
      'is_available': isAvailable,
    };
  }

  // Eşitlik kontrolü (Map içinde anahtar olarak kullanabilmek için şart)
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Product && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  String getLocalizedName(BuildContext context) {
    // Dil kodunu al (tr, en)
    final languageCode = Localizations.localeOf(context).languageCode;

    if (languageCode == 'en') {
      return nameEn;
    }
    return name; // Varsayılan (Türkçe)
  }

  // O anki dile göre kategoriyi getir
  String getLocalizedCategory(BuildContext context) {
    final languageCode = Localizations.localeOf(context).languageCode;

    if (languageCode == 'en') {
      return categoryEn;
    }
    return category; // Varsayılan (Türkçe)
  }
}