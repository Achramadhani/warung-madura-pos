import 'package:flutter/material.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'cart_provider.dart';

class ProdukDitemukanPage extends StatefulWidget {
  final Map<String, dynamic> produk;
  const ProdukDitemukanPage({super.key, required this.produk});

  @override
  State<ProdukDitemukanPage> createState() => _ProdukDitemukanPageState();
}

class _ProdukDitemukanPageState extends State<ProdukDitemukanPage> {
  int quantity = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Produk Ditemukan",
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Banner Status Berhasil (Sesuai Desain)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            color: const Color(0xFFE8F5E9), // Hijau sangat muda
            child: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 18),
                SizedBox(width: 8),
                Text(
                  "Barcode berhasil dipindai",
                  style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                      fontSize: 13),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Gambar Produk
                  Center(
                    child: Container(
                      height: 280,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: widget.produk['img'] != null &&
                                widget.produk['img'].toString().isNotEmpty
                            ? (widget.produk['isLocal'] == 1
                                ? Image.file(
                                    File(widget.produk['img']),
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(Icons.image,
                                                size: 100, color: Colors.grey),
                                  )
                                : Image.network(
                                    widget.produk['img'],
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(Icons.image,
                                                size: 100, color: Colors.grey),
                                  ))
                            : const Icon(Icons.image,
                                size: 100, color: Colors.grey),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Info Nama & Label Premium
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.produk['nama_produk'] ?? 'Nama Produk',
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            height: 1.2),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEBEE),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          "PREMIUM",
                          style: TextStyle(
                              color: Colors.red,
                              fontSize: 10,
                              fontWeight: FontWeight.bold),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text("Kategori: ${widget.produk['cat'] ?? 'Tidak diketahui'}",
                      style: const TextStyle(color: Colors.grey, fontSize: 14)),
                  const SizedBox(height: 16),

                  // Harga
                  Text(
                    "Rp ${widget.produk['harga_jual']?.toString() ?? '0'}",
                    style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.red),
                  ),
                  const SizedBox(height: 8),

                  // Info Stok
                  Row(
                    children: [
                      const Icon(Icons.inventory_2_outlined,
                          size: 16, color: Colors.grey),
                      const SizedBox(width: 6),
                      const Text("Stok Tersedia: ",
                          style: TextStyle(color: Colors.grey, fontSize: 13)),
                      Text("${widget.produk['stok']?.toString() ?? '0'} pcs",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 13)),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Bottom Action Panel
          _buildBottomPanel(),
        ],
      ),
    );
  }

  Widget _buildBottomPanel() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Penentuan Jumlah
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Tentukan Jumlah",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[200]!),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    _qtyBtn(Icons.remove, () {
                      if (quantity > 1) setState(() => quantity--);
                    }),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text("$quantity",
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                    _qtyBtn(Icons.add, () {
                      setState(() => quantity++);
                    }),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 20),

          // Tombol Tambah ke Keranjang
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              minimumSize: const Size(double.infinity, 55),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            onPressed: () {
              final cart = Provider.of<CartProvider>(context, listen: false);
              cart.addToCartWithQuantity({
                'barcode': widget.produk['barcode'],
                'nama_produk': widget.produk['nama_produk'],
                'harga_jual': widget.produk['harga_jual'],
                'img': widget.produk['img'],
                'isLocal': widget.produk['isLocal'] == 1,
              }, quantity: quantity);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      '${widget.produk['nama_produk']} ($quantity pcs) ditambahkan ke keranjang'),
                  backgroundColor: Colors.green,
                ),
              );

              // Kembali ke halaman sebelumnya setelah delay
              Future.delayed(const Duration(seconds: 1), () {
                if (mounted) {
                  Navigator.pop(context);
                }
              });
            },
            icon:
                const Icon(Icons.shopping_cart, color: Colors.white, size: 20),
            label: const Text(
              "Tambahkan ke Keranjang",
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15),
            ),
          ),
          const SizedBox(height: 10),

          // Tombol Scan Produk Lain
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              side: const BorderSide(color: Colors.red),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(context),
            icon:
                const Icon(Icons.qr_code_scanner, color: Colors.red, size: 20),
            label: const Text(
              "Scan Produk Lain",
              style: TextStyle(
                  color: Colors.red, fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
          const SizedBox(height: 5),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal & Scan Ulang",
                style: TextStyle(color: Colors.grey, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Icon(icon, color: Colors.red, size: 20),
      ),
    );
  }
}
