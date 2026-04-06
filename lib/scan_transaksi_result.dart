import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'cart_provider.dart';

class ScanTransaksiResultPage extends StatefulWidget {
  final Map<String, dynamic> produk; 

  const ScanTransaksiResultPage({super.key, required this.produk});

  @override
  State<ScanTransaksiResultPage> createState() => _ScanTransaksiResultPageState();
}

class _ScanTransaksiResultPageState extends State<ScanTransaksiResultPage> {
  int qty = 1;

  @override
  Widget build(BuildContext context) {
    final p = widget.produk;
    // Menggunakan listen: false karena kita hanya butuh memanggil fungsi action
    final cart = Provider.of<CartProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text("Hasil Scan", 
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: const BackButton(color: Colors.black),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          const CircleAvatar(
            radius: 35,
            backgroundColor: Color(0xFFFFEBEE),
            child: Icon(Icons.check_circle, color: Colors.red, size: 45),
          ),
          const SizedBox(height: 12),
          const Text("Produk Ditemukan!", 
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text("Barcode: ${p['barcode'] ?? '-'}", 
            style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 25),
          
          // Product Card
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05), 
                  blurRadius: 10, 
                  offset: const Offset(0, 5)
                )
              ],
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _buildProductImage(p['img'], p['isLocal'] == 1 || p['isLocal'] == true),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p['cat']?.toString().toUpperCase() ?? "UMUM", 
                        style: const TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(p['nama'] ?? p['nama_produk'] ?? "Produk Tanpa Nama", 
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text("Rp ${p['harga'] ?? p['harga_jual'] ?? 0}", 
                        style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 18)),
                      const SizedBox(height: 4),
                      Text("Stok: ${p['stok'] ?? '-'}", 
                        style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),

          // Qty Controller
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Jumlah Beli", 
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade200),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => setState(() => qty > 1 ? qty-- : null),
                        icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text("$qty", 
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      ),
                      IconButton(
                        onPressed: () => setState(() => qty++),
                        icon: const Icon(Icons.add_circle_outline, color: Colors.red),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          const Spacer(),

          // Bottom Action Bar
          Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))
              ],
              borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween, 
                  children: [
                    const Text("Total Pembayaran", style: TextStyle(color: Colors.grey)),
                    Text("Rp ${(p['harga'] ?? p['harga_jual'] ?? 0) * qty}", 
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.red)),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          // PERBAIKAN LOGIC: Menggunakan format yang sama dengan HomePage
                          // Jika CartProvider Anda memiliki fungsi addToCart(Map):
                          for (int i = 0; i < qty; i++) {
                            cart.addToCart({
                              'barcode': p['barcode'],
                              'nama_produk': p['nama'] ?? p['nama_produk'],
                              'harga_jual': p['harga'] ?? p['harga_jual'],
                              'kategori': p['cat'],
                              'img': p['img'],
                              'isLocal': p['isLocal'],
                            });
                          }
                          
                          Navigator.pop(context); 
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("$qty ${p['nama'] ?? p['nama_produk']} masuk keranjang"),
                              backgroundColor: Colors.green,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red, width: 1.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text("TAMBAH", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // Logika bayar langsung atau ke halaman transaksi
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text("BAYAR SEKARANG", style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildProductImage(String? url, bool isLocal) {
    if (url == null || url.isEmpty) {
      return Container(
        width: 85, height: 85, 
        color: Colors.grey[100], 
        child: const Icon(Icons.image_not_supported, color: Colors.grey)
      );
    }
    return isLocal
        ? Image.file(File(url), width: 85, height: 85, fit: BoxFit.cover)
        : Image.network(
            url,
            width: 85,
            height: 85,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              width: 85, height: 85, 
              color: Colors.grey[100], 
              child: const Icon(Icons.broken_image, color: Colors.grey),
            ),
          );
  }
}