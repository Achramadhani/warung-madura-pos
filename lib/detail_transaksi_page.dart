import 'package:flutter/material.dart';

class DetailTransaksiPage extends StatelessWidget {
  const DetailTransaksiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text("Detail Transaksi", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.red), onPressed: () => Navigator.pop(context)),
        actions: [IconButton(icon: const Icon(Icons.settings, color: Colors.red), onPressed: () {})],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 60),
            const SizedBox(height: 10),
            const Text("Pembayaran Berhasil", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const Text("12 Okt 2023, 14:25 • TRN-9928310", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 30),
            
            // Tampilan Struk
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey.withOpacity(0.1))),
              child: Column(
                children: [
                  const Text("Warung Madura", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.red)),
                  const Text("Jl. Kebon Jeruk No. 24, Jakarta Barat", textAlign: TextAlign.center),
                  const Text("Telp: 0812-3456-7890"),
                  const Divider(height: 40, thickness: 1, color: Colors.grey),
                  
                  _rowStruk("KASIR", "Abdurrahman"),
                  _rowStruk("METODE", "Tunai"),
                  const Divider(height: 40, thickness: 1, color: Colors.grey),

                  _itemBelanja("Indomie Goreng Original", "3 x 3.000", "9.000"),
                  _itemBelanja("Telur Ayam Negeri", "0.5kg x 28.000", "14.000"),
                  _itemBelanja("Minyak Goreng Bimoli 1L", "1 x 18.500", "18.500"),
                  _itemBelanja("Kopi Kapal Api Sachet", "5 x 1.500", "7.500"),
                  
                  const Divider(height: 40, thickness: 1, color: Colors.grey),
                  _rowStruk("Subtotal", "Rp 49.000"),
                  _rowStruk("Diskon", "- Rp 0"),
                  const SizedBox(height: 10),
                  _rowStruk("Total Bayar", "Rp 49.000", isBold: true, color: Colors.red),
                  const Divider(height: 40, thickness: 1, color: Colors.grey),
                  
                  _rowStruk("Bayar (Tunai)", "Rp 50.000"),
                  _rowStruk("Kembalian", "Rp 1.000"),
                  const SizedBox(height: 30),
                  const Text("TERIMA KASIH TELAH BELANJA", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  const Text("Barang yang sudah dibeli tidak dapat ditukar", style: TextStyle(fontSize: 10, color: Colors.grey)),
                  const SizedBox(height: 20),
                  const Icon(Icons.barcode_reader, size: 50, color: Colors.grey),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        color: Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.print),
              label: const Text("Cetak Struk"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.share), label: const Text("Bagikan"))),
                const SizedBox(width: 10),
                Expanded(child: OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.picture_as_pdf), label: const Text("Simpan PDF"))),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _rowStruk(String label, String value, {bool isBold = false, Color color = Colors.black}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: isBold ? Colors.black : Colors.grey, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        Text(value, style: TextStyle(color: color, fontWeight: isBold ? FontWeight.bold : FontWeight.normal, fontSize: isBold ? 18 : 14)),
      ],
    ),
  );

  Widget _itemBelanja(String name, String qty, String total) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(qty, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ]),
        Text("Rp $total", style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    ),
  );
}