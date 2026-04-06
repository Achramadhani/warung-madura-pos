import 'package:flutter/material.dart';
// Pastikan file-file ini sudah ada di project Anda
import 'profile_page.dart'; 
import 'printer_settings_page.dart';
import 'history_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  
  // Dialog Konfirmasi Keluar sesuai desain Anda
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.all(28.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFEBEE),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.logout_rounded, color: Colors.red, size: 40),
                ),
                const SizedBox(height: 24),
                const Text(
                  "Konfirmasi Keluar",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
                ),
                const SizedBox(height: 12),
                const Text(
                  "Apakah Anda yakin ingin keluar dari akun Anda?",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF6B7280), fontSize: 15, height: 1.5),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  onPressed: () {
                    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                  },
                  child: const Text(
                    "Keluar",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      "Batal",
                      style: TextStyle(color: Color(0xFF9CA3AF), fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Background abu-abu sangat muda
      appBar: AppBar(
        title: const Text("Profil Saya", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.red),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            
            // --- HEADER PROFIL (Lingkaran + Edit Badge) ---
            Center(
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.red.withOpacity(0.1), width: 4),
                    ),
                    child: const CircleAvatar(
                      radius: 60,
                      backgroundImage: NetworkImage('https://via.placeholder.com/150'),
                    ),
                  ),
                  Positioned(
                    bottom: 5,
                    right: 5,
                    child: GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfilePage())),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                        child: const Icon(Icons.edit, color: Colors.white, size: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
            const Text(
              "Budi Setiawan",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF101828)),
            ),
            const Text(
              "Warung Madura Cabang Pusat",
              style: TextStyle(fontSize: 16, color: Colors.red, fontWeight: FontWeight.w500),
            ),
            const Text(
              "budi.warung@example.com",
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            
            const SizedBox(height: 35),

            // --- GRUP PENGATURAN AKUN ---
            _sectionLabel("PENGATURAN AKUN"),
            _buildMenuTile(
              icon: Icons.person_outline, 
              title: "Edit Profil", 
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfilePage())),
            ),
            _buildMenuTile(
              icon: Icons.history, 
              title: "Riwayat Penjualan", 
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const HistoryPage())),
            ),
            _buildMenuTile(
              icon: Icons.print_outlined, 
              title: "Pengaturan Printer", 
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PrinterSettingsPage())),
            ),
            _buildMenuTile(
              icon: Icons.lock_outline, 
              title: "Keamanan", 
              onTap: () {},
            ),

            const SizedBox(height: 25),

            // --- GRUP LAINNYA ---
            _sectionLabel("LAINNYA"),
            _buildMenuTile(
              icon: Icons.help_outline, 
              title: "Pusat Bantuan", 
              onTap: () {},
            ),
            _buildMenuTile(
              icon: Icons.logout, 
              title: "Keluar", 
              iconColor: Colors.red,
              textColor: Colors.red,
              onTap: () => _showLogoutDialog(context),
            ),
            
            const SizedBox(height: 30),
            const Text(
              "Versi 2.4.0 (Build 129)",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Widget Label Section (Huruf Kapital Abu-abu)
  Widget _sectionLabel(String text) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.only(left: 5, bottom: 15),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12, 
          fontWeight: FontWeight.bold, 
          color: Colors.blueGrey,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  // Widget Card Menu Tile
  Widget _buildMenuTile({
    required IconData icon, 
    required String title, 
    required VoidCallback onTap,
    Color iconColor = Colors.red,
    Color textColor = Colors.black87,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        title: Text(
          title, 
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: textColor),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
        onTap: onTap,
      ),
    );
  }
}