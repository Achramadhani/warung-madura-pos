import 'package:flutter/material.dart';

class DetailProdukPage extends StatelessWidget {
  final String barcode;
  const DetailProdukPage({super.key, required this.barcode});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Produk Ditemukan",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: Colors.green[50],
            child: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green, size: 20),
                SizedBox(width: 8),
                Text("Barcode berhasil dipindai",
                    style: TextStyle(color: Colors.green)),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Placeholder Gambar Produk
                  Center(
                    child: Container(
                      height: 250,
                      width: 250,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(20),
                        image: const DecorationImage(
                          image: AssetImage(
                              'assets/beras.png'), // Sesuaikan assetmu
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Beras Pandan Wangi\n5kg",
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold)),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(5)),
                        child: const Text("PREMIUM",
                            style: TextStyle(
                                color: Colors.red,
                                fontSize: 10,
                                fontWeight: FontWeight.bold)),
                      )
                    ],
                  ),
                  const Text("Kategori: Sembako",
                      style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 15),
                  const Text("Rp 78.500",
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.red)),
                  const SizedBox(height: 5),
                  const Row(
                    children: [
                      Icon(Icons.inventory_2_outlined,
                          size: 16, color: Colors.grey),
                      SizedBox(width: 5),
                      Text("Stok Tersedia: ",
                          style: TextStyle(color: Colors.grey)),
                      Text("24 karung",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Bottom Action
          _buildBottomAction(context),
        ],
      ),
    );
  }

  Widget _buildBottomAction(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            spreadRadius: 1,
            blurRadius: 10,
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Tentukan Jumlah",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Row(
                children: [
                  _qtyBtn(Icons.remove),
                  const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15),
                      child: Text("1")),
                  _qtyBtn(Icons.add),
                ],
              )
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {},
            child: const Text("Tambahkan ke Keranjang",
                style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal & Scan Ulang",
                style: TextStyle(color: Colors.grey)),
          )
        ],
      ),
    );
  }

  Widget _qtyBtn(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(5)),
      child: Icon(icon, size: 18, color: Colors.red),
    );
  }
}
