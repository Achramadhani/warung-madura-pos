import 'package:flutter/material.dart';

class CartItem {
  final String name;
  final double price;
  final String img;
  final bool isLocal;
  int quantity;

  CartItem({
    required this.name,
    required this.price,
    required this.img,
    required this.isLocal,
    this.quantity = 1,
  });
}

class CartProvider with ChangeNotifier {
  Map<String, CartItem> _items = {};

  Map<String, CartItem> get items => _items;

  double get totalHarga {
    double total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.price * cartItem.quantity;
    });
    return total;
  }

  void addToCart(Map<String, dynamic> produk) {
    // Gunakan barcode sebagai ID unik agar tidak duplikat baris
    String barcode = produk['barcode']?.toString() ?? DateTime.now().toString();
    
    if (_items.containsKey(barcode)) {
      _items.update(
        barcode,
        (existing) => CartItem(
          name: existing.name,
          price: existing.price,
          img: existing.img,
          isLocal: existing.isLocal,
          quantity: existing.quantity + 1,
        ),
      );
    } else {
      _items.putIfAbsent(
        barcode,
        () => CartItem(
          name: produk['nama_produk'] ?? produk['nama'] ?? "Produk",
          price: (produk['harga_jual'] ?? produk['harga'] ?? 0).toDouble(),
          img: produk['img'] ?? "",
          isLocal: produk['isLocal'] == 1 || produk['isLocal'] == true,
        ),
      );
    }
    notifyListeners();
  }

  void addToCartWithQuantity(Map<String, dynamic> produk, {int quantity = 1}) {
    String barcode = produk['barcode']?.toString() ?? DateTime.now().toString();
    
    if (_items.containsKey(barcode)) {
      _items.update(
        barcode,
        (existing) => CartItem(
          name: existing.name,
          price: existing.price,
          img: existing.img,
          isLocal: existing.isLocal,
          quantity: existing.quantity + quantity,
        ),
      );
    } else {
      _items.putIfAbsent(
        barcode,
        () => CartItem(
          name: produk['nama_produk'] ?? produk['nama'] ?? "Produk",
          price: (produk['harga_jual'] ?? produk['harga'] ?? 0).toDouble(),
          img: produk['img'] ?? "",
          isLocal: produk['isLocal'] == 1 || produk['isLocal'] == true,
          quantity: quantity,
        ),
      );
    }
    notifyListeners();
  }

  void removeSingleItem(String barcode) {
    if (!_items.containsKey(barcode)) return;
    if (_items[barcode]!.quantity > 1) {
      _items.update(barcode, (existing) => CartItem(
        name: existing.name,
        price: existing.price,
        img: existing.img,
        isLocal: existing.isLocal,
        quantity: existing.quantity - 1,
      ));
    } else {
      _items.remove(barcode);
    }
    notifyListeners();
  }

  void clearCart() {
    _items = {};
    notifyListeners();
  }
}