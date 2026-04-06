import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'cart_provider.dart';
import 'db_helper.dart'; // Import DbHelper untuk akses database lokal

class KeranjangPage extends StatelessWidget {
  const KeranjangPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Format mata uang Rupiah
    final currencyFormatter = NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text("Sovereign Cart", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<CartProvider>(
        builder: (context, cart, child) {
          // Validasi jika keranjang kosong
          if (cart.items.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey),
                  SizedBox(height: 10),
                  Text("Keranjang masih kosong", style: TextStyle(fontSize: 16, color: Colors.grey)),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: cart.items.length,
                  itemBuilder: (context, index) {
                    var itemsList = cart.items.values.toList();
                    var keysList = cart.items.keys.toList();
                    
                    var item = itemsList[index];
                    var barcode = keysList[index];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 15),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
                        ],
                      ),
                      child: Row(
                        children: [
                          // Tampilan Gambar (Local File atau Network)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: item.isLocal 
                                ? Image.file(File(item.img), width: 70, height: 70, fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Icon(Icons.image, size: 70))
                                : Image.network(item.img, width: 70, height: 70, fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Icon(Icons.image, size: 70)),
                          ),
                          const SizedBox(width: 15),
                          // Nama Produk & Harga
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                Text(currencyFormatter.format(item.price), style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                          // Kontrol Jumlah
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                                onPressed: () => cart.removeSingleItem(barcode),
                              ),
                              Text("${item.quantity}", style: const TextStyle(fontWeight: FontWeight.bold)),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline, color: Colors.green),
                                onPressed: () => cart.addToCart({
                                  'barcode': barcode,
                                  'nama_produk': item.name,
                                  'harga_jual': item.price,
                                  'img': item.img,
                                  'isLocal': item.isLocal,
                                }),
                              ),
                            ],
                          )
                        ],
                      ),
                    );
                  },
                ),
              ),
              // Panel Total & Tombol Simpan
              _buildBottomPanel(context, cart, currencyFormatter),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBottomPanel(BuildContext context, CartProvider cart, NumberFormat formatter) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("GRAND TOTAL", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                Text(formatter.format(cart.totalHarga), 
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // Fungsi Cetak (Opsional)
                    },
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white),
                    ),
                    child: const Text("CETAK STRUK", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      // --- FUNGSI TOMBOL SIMPAN ---
                      if (cart.items.isNotEmpty) {
                        try {
                          // 1. Simpan ke Database SQLite
                          await DbHelper.instance.simpanTransaksi(
                            cart.totalHarga, 
                            cart.items
                          );
                          
                          // 2. Kosongkan Keranjang di Provider
                          cart.clearCart(); 
                          
                          if (!context.mounted) return;
                          
                          // 3. Notifikasi Berhasil
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Transaksi Berhasil Disimpan & Stok Diperbarui!"),
                              backgroundColor: Colors.green,
                              duration: Duration(seconds: 2),
                            ),
                          );
                        } catch (e) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Gagal menyimpan transaksi: $e"), backgroundColor: Colors.orange),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
                    child: const Text("SIMPAN", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}