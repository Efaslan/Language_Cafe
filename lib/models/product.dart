class Product {
  final int id;
  final String name;
  final double price;
  final String category;
  final String? imageUrl;
  final bool isAvailable;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    this.imageUrl,
    required this.isAvailable,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'] ?? 'Ürün',
      // Supabase numeric/float gelebilir, double'a çeviriyoruz
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      category: json['category'] ?? 'Genel',
      imageUrl: json['image_url'],
      isAvailable: json['is_available'] ?? true,
    );
  }
}