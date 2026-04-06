import 'package:flutter/material.dart';

class ScanTambahStokResultPage extends StatelessWidget {
  const ScanTambahStokResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text("Hasil Scan Tambah Stok", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white, elevation: 0, centerTitle: true, leading: const BackButton(color: Colors.black)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const CircleAvatar(radius: 40, backgroundColor: Color(0xFFE8F5E9), child: Icon(Icons.check_circle, color: Colors.green, size: 50)),
            const SizedBox(height: 16),
            const Text("Scan Berhasil", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const Text("Produk ditemukan dalam database", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 30),
            // Product Info
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(15)),
              child: Row(children: [
                ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.network('https://via.placeholder.com/70', width: 70, height: 70, fit: BoxFit.cover)),
                const SizedBox(width: 15),
                const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text("Minyak Goreng Bimoli 2L", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text("Stok Saat Ini: 24 Pcs", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                ]),
              ]),
            ),
            const SizedBox(height: 30),
            _inputField("Jumlah Stok Masuk", "Contoh: 12", suffix: "Pcs"),
            const SizedBox(height: 20),
            _inputField("Harga Beli Baru", "Rp 0", optional: true),
            const SizedBox(height: 60),
            // Actions
            ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: Colors.red, minimumSize: const Size(double.infinity, 55), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))), child: const Text("Simpan Stok", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
            const SizedBox(height: 15),
            Row(children: [
              Expanded(child: OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.edit), label: const Text("Ubah Data"))),
              const SizedBox(width: 10),
              Expanded(child: OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.delete, color: Colors.red), label: const Text("Hapus", style: TextStyle(color: Colors.red)))),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _inputField(String label, String hint, {String? suffix, bool optional = false}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        if (optional) const Text("Opsional", style: TextStyle(color: Colors.grey, fontSize: 12)),
      ]),
      const SizedBox(height: 10),
      TextField(decoration: InputDecoration(hintText: hint, suffixText: suffix, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
    ]);
  }
}