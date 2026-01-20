import 'package:flutter/material.dart';
import '../services/menu_service.dart';
import '../services/table_service.dart';
import '../models/product.dart';
import '../models/cafe_table.dart';
import '../constants/app_colors.dart';
import 'tables_screen.dart'; // Masa yoksa yönlendirmek için

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final _menuService = MenuService();
  final _tableService = TableService();

  List<Product> _products = [];
  bool _isLoading = true;

  // Cart State: Product -> Quantity
  final Map<Product, int> _cart = {};

  // Active Table State
  CafeTable? _currentTable;

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    setState(() => _isLoading = true);
    try {
      // Run both requests in parallel for speed
      final results = await Future.wait([
        _menuService.getProducts(),
        _tableService.getCurrentActiveTable(),
      ]);

      if (mounted) {
        setState(() {
          _products = results[0] as List<Product>;
          _currentTable = results[1] as CafeTable?;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Veri yüklenemedi: $e")),
        );
      }
    }
  }

  // Cart Logic
  void _addToCart(Product product) {
    setState(() {
      _cart[product] = (_cart[product] ?? 0) + 1;
    });
  }

  void _removeFromCart(Product product) {
    setState(() {
      if (_cart.containsKey(product)) {
        if (_cart[product]! > 1) {
          _cart[product] = _cart[product]! - 1;
        } else {
          _cart.remove(product);
        }
      }
    });
  }

  double get _totalPrice {
    double total = 0;
    _cart.forEach((product, quantity) {
      total += product.price * quantity;
    });
    return total;
  }

  int get _totalItems {
    int count = 0;
    _cart.forEach((_, q) => count += q);
    return count;
  }

  // Submit Order
  Future<void> _submitOrder() async {
    if (_currentTable == null) return;

    try {
      // Close cart sheet first
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Sipariş gönderiliyor... ⏳")),
      );

      await _menuService.placeOrder(
        tableId: _currentTable!.id,
        cartItems: _cart,
      );

      setState(() {
        _cart.clear(); // Clear cart after success
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Siparişiniz alındı! Afiyet olsun ☕"), backgroundColor: AppColors.success),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Hata: $e"), backgroundColor: AppColors.error),
      );
    }
  }

  // UI: Cart Drawer
  void _openCartDrawer() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          height: 500,
          child: Column(
            children: [
              const Text("Sepetim", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary)),
              const Divider(),

              // Cart Items List
              Expanded(
                child: _cart.isEmpty
                    ? const Center(child: Text("Sepetiniz boş 🛒", style: TextStyle(color: Colors.grey, fontSize: 16)))
                    : ListView.builder(
                  itemCount: _cart.length,
                  itemBuilder: (context, index) {
                    final product = _cart.keys.elementAt(index);
                    final quantity = _cart[product]!;
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

              // Total Price
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Toplam:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(
                    "${_totalPrice.toStringAsFixed(2)} ₺",
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // ORDER BUTTON LOGIC
              if (_currentTable != null)
              // Case 1: User is seated
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _cart.isEmpty ? null : _submitOrder,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(
                      "Sipariş Ver (Masa ${_currentTable!.tableNumber})",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                )
              else
              // Case 2: User is NOT seated
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
                          Navigator.pop(context); // Close cart
                          // Navigate to Tables Screen (or QR scanner later)
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const TablesScreen()));
                        },
                        icon: const Icon(Icons.qr_code_scanner),
                        label: const Text("QR Okut / Masa Seç"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey, // Disabled look
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Menü"),
        backgroundColor: AppColors.background,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
        children: [
          // PRODUCT LIST
          ListView.builder(
            padding: const EdgeInsets.only(bottom: 100), // Space for cart items
            itemCount: _products.length,
            itemBuilder: (context, index) {
              final product = _products[index];
              final quantity = _cart[product] ?? 0;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      // Placeholder Image
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.brown.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.fastfood, color: Colors.brown),
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

                      // Controls (+ / -)
                      if (quantity == 0)
                        IconButton(
                          onPressed: () => _addToCart(product),
                          icon: const Icon(Icons.add_circle, color: AppColors.primary, size: 30),
                        )
                      else
                        Row(
                          children: [
                            IconButton(
                              onPressed: () => _removeFromCart(product),
                              icon: const Icon(Icons.remove_circle_outline, color: AppColors.primary),
                            ),
                            Text(
                              "$quantity",
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            IconButton(
                              onPressed: () => _addToCart(product),
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

          // FLOATING CART BUTTON (Right Center)
          if (_totalItems > 0)
            Positioned(
              right: 0,
              top: MediaQuery.of(context).size.height / 2 - 40, // Center vertically
              child: GestureDetector(
                onTap: _openCartDrawer,
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
                        "$_totalItems",
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
      ),
    );
  }
}