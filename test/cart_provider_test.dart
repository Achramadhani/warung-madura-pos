import 'package:flutter_test/flutter_test.dart';
import 'package:toko_rajawali/cart_provider.dart';

void main() {
  group('CartProvider', () {
    test('addToCart merges items by barcode', () {
      final cart = CartProvider();

      cart.addToCart({
        'barcode': '899001',
        'nama_produk': 'Kopi Sachet',
        'harga_jual': 2500,
        'img': '',
        'isLocal': true,
      });
      cart.addToCart({
        'barcode': '899001',
        'nama_produk': 'Kopi Sachet',
        'harga_jual': 2500,
        'img': '',
        'isLocal': true,
      });

      expect(cart.items.length, 1);
      expect(cart.items['899001']?.quantity, 2);
      expect(cart.totalHarga, 5000);
    });

    test('addToCartWithQuantity respects explicit quantity', () {
      final cart = CartProvider();

      cart.addToCartWithQuantity({
        'barcode': '899002',
        'nama_produk': 'Air Mineral',
        'harga_jual': 4000,
        'img': '',
        'isLocal': false,
      }, quantity: 3);

      expect(cart.items['899002']?.quantity, 3);
      expect(cart.totalHarga, 12000);
    });

    test('removeSingleItem decrements and removes item at zero', () {
      final cart = CartProvider();

      cart.addToCartWithQuantity({
        'barcode': '899003',
        'nama_produk': 'Gula Pasir',
        'harga_jual': 7000,
        'img': '',
        'isLocal': true,
      }, quantity: 2);

      cart.removeSingleItem('899003');
      expect(cart.items['899003']?.quantity, 1);

      cart.removeSingleItem('899003');
      expect(cart.items.containsKey('899003'), isFalse);
      expect(cart.totalHarga, 0);
    });
  });
}
