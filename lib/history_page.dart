import 'package:flutter/material.dart';
import 'detail_transaksi_page.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text("Riwayat Penjualan", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        centerTitle: false,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.red), onPressed: () => Navigator.pop(context)),
        actions: [IconButton(icon: const Icon(Icons.settings, color: Colors.red), onPressed: () {})],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filter Periode
            _buildFilterCard(),
            const SizedBox(height: 20),
            
            // Total Omzet Card
            _buildOmzetCard(),
            const SizedBox(height: 15),
            
            // Stats Card
            _buildStatsCard(),
            const SizedBox(height: 25),
            
            const Text("DAFTAR TRANSAKSI", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
            const SizedBox(height: 10),
            
            _buildTransactionItem(context, "#WM-88293", "24 Okt 2023, 14:32", "45.500", "Selesai"),
            _buildTransactionItem(context, "#WM-88291", "24 Okt 2023, 12:15", "128.000", "Berhasil"),
            _buildTransactionItem(context, "#WM-88285", "23 Okt 2023, 19:45", "32.500", "Selesai"),
            
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 15),
              child: Text("22 OKTOBER 2023", style: TextStyle(fontSize: 12, color: Colors.grey)),
            ),
            _buildTransactionItem(context, "#WM-88274", "22 Okt 2023, 22:10", "15.000", "Selesai"),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20),
        child: ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.download),
          label: const Text("Ekspor Laporan (PDF/Excel)"),
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF101828), foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 55), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
        ),
      ),
    );
  }

  Widget _buildFilterCard() => Container(
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
    child: Column(
      children: [
        const Row(
          children: [
            Expanded(child: Text("10/01/2023")),
            Text(" s/d "),
            Expanded(child: Text("10/31/2023")),
          ],
        ),
        const SizedBox(height: 15),
        ElevatedButton.icon(onPressed: () {}, icon: const Icon(Icons.tune), label: const Text("Terapkan"), style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 45))),
      ],
    ),
  );

  Widget _buildOmzetCard() => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(20)),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Total Omzet Periode Ini", style: TextStyle(color: Colors.white70)),
        const Text("Rp 12.450.000", style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)), child: const Text("📈 +12% dari bulan lalu", style: TextStyle(color: Colors.white, fontSize: 12))),
      ],
    ),
  );

  Widget _buildStatsCard() => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
    child: const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Total Transaksi", style: TextStyle(color: Colors.grey)),
        Text("142", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
        Text("Semua Berhasil", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
      ],
    ),
  );

  Widget _buildTransactionItem(BuildContext context, String id, String date, String price, String status) => GestureDetector(
    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const DetailTransaksiPage())),
    child: Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: Row(
        children: [
          Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.red.withOpacity(0.05), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.receipt_long, color: Colors.red)),
          const SizedBox(width: 15),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(id, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(date, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ]),
          ),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text("Rp $price", style: const TextStyle(fontWeight: FontWeight.bold)),
            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(5)), child: Text(status, style: const TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold))),
          ]),
        ],
      ),
    ),
  );
}