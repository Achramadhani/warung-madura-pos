import 'package:flutter/material.dart';

class PrinterSettingsPage extends StatefulWidget {
  const PrinterSettingsPage({super.key});

  @override
  State<PrinterSettingsPage> createState() => _PrinterSettingsPageState();
}

class _PrinterSettingsPageState extends State<PrinterSettingsPage> {
  bool isBluetoothOn = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text("Pengaturan Printer", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.red), onPressed: () => Navigator.pop(context)),
        actions: [IconButton(icon: const Icon(Icons.settings, color: Colors.red), onPressed: () {})],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Switch Bluetooth
            _buildCard(
              child: ListTile(
                leading: CircleAvatar(backgroundColor: Colors.red.withOpacity(0.1), child: const Icon(Icons.bluetooth, color: Colors.red)),
                title: const Text("Bluetooth", style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text("Aktifkan untuk mencari printer thermal", style: TextStyle(fontSize: 12)),
                trailing: Switch(value: isBluetoothOn, activeColor: Colors.red, onChanged: (v) => setState(() => isBluetoothOn = v)),
              ),
            ),
            const SizedBox(height: 20),
            _sectionHeader("PRINTER TERHUBUNG", "Cari Printer"),
            
            // Printer Terhubung Card
            _buildConnectedPrinter(),

            const SizedBox(height: 20),
            _sectionHeader("PRINTER TERSEDIA", ""),
            _buildPrinterItem("Panda PRJ-80-01", "Kekuatan Sinyal: Kuat"),
            _buildPrinterItem("Unknown Thermal Printer", "Kekuatan Sinyal: Lemah"),
            _buildPrinterItem("Epson TM-T82", "Terakhir digunakan 2 hari lalu"),
            
            const SizedBox(height: 20),
            // Tips Card
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(color: Colors.blue.withOpacity(0.05), borderRadius: BorderRadius.circular(15)),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Butuh Bantuan?", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  SizedBox(height: 5),
                  Text("Pastikan printer Anda dalam mode pairing dan berada dalam radius 5 meter.", style: TextStyle(color: Colors.blueGrey, fontSize: 13)),
                ],
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20),
        child: ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.search),
          label: const Text("Pindai Ulang Perangkat"),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child}) => Container(
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)]),
    child: child,
  );

  Widget _sectionHeader(String title, String action) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
      if (action.isNotEmpty) TextButton.icon(onPressed: () {}, icon: const Icon(Icons.refresh, size: 14), label: Text(action, style: const TextStyle(fontSize: 12))),
    ],
  );

  Widget _buildConnectedPrinter() => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(20)),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)), child: const Text("TERHUBUNG", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))),
            const Icon(Icons.print, color: Colors.white, size: 30),
          ],
        ),
        const SizedBox(height: 15),
        const Text("Rongta RP326-U", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const Text("Alamat: 00:11:22:33:FF:EE", style: TextStyle(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(child: ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.red), child: const Text("Tes Print"))),
            const SizedBox(width: 10),
            Expanded(child: OutlinedButton(onPressed: () {}, style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.white), foregroundColor: Colors.white), child: const Text("Putus Koneksi"))),
          ],
        )
      ],
    ),
  );

  Widget _buildPrinterItem(String name, String desc) => Card(
    margin: const EdgeInsets.only(top: 10),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: ListTile(
      leading: const Icon(Icons.print_outlined),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(desc, style: const TextStyle(fontSize: 12)),
      trailing: ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: Colors.white, side: const BorderSide(color: Colors.red), foregroundColor: Colors.red, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))), child: const Text("Hubungkan")),
    ),
  );
}