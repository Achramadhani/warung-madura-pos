import 'dart:io';

import 'package:flutter/material.dart';
// Pastikan file-file ini sudah ada di project Anda
import 'profile_page.dart';
import 'printer_settings_page.dart';
import 'history_page.dart';
import 'pusat_bantuan_page.dart';
import 'profile_service.dart';
import 'backup_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _profileName = 'Budi Setiawan';
  String _profileTitle = 'Warung Madura Cabang Pusat';
  String _profileEmail = 'budi.warung@example.com';
  String? _profileImagePath;

  final BackupService _backupService = BackupService();

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final profile = await ProfileService.getProfile();
    setState(() {
      _profileName = profile['name']!;
      _profileTitle = profile['storeName']!;
      _profileEmail = profile['email']!;
      _profileImagePath = profile['imagePath'];
    });
  }

  Future<void> _openProfilePage() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (context) => const ProfilePage()),
    );

    if (result != null && mounted) {
      setState(() {
        _profileName = result['name'] as String? ?? _profileName;
        _profileTitle = result['storeName'] as String? ?? _profileTitle;
        _profileEmail = result['email'] as String? ?? _profileEmail;
        _profileImagePath = result['imagePath'] as String? ?? _profileImagePath;
      });
    }
  }

  Future<void> _backupData() async {
    try {
      final path = await _backupService.backupData();
      if (!mounted) return;
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Backup berhasil disimpan di:\n$path'),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Backup gagal: $e')),
      );
    }
  }

  Future<void> _confirmRestoreBackup() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Restore Backup'),
          content: const Text(
              'Restore akan menggantikan data saat ini dengan backup terakhir. Lanjutkan?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Restore'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await _restoreData();
    }
  }

  Future<void> _restoreData() async {
    try {
      await _backupService.restoreLatestBackup();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Restore backup berhasil')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Restore gagal: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF8F9FA), // Background abu-abu sangat muda
      appBar: AppBar(
        title: const Text("Profil Saya",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
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
                      border: Border.all(
                          color: Colors.red.withOpacity(0.1), width: 4),
                    ),
                    child: CircleAvatar(
                      radius: 60,
                      backgroundImage: _profileImagePath != null
                          ? FileImage(File(_profileImagePath!)) as ImageProvider
                          : const NetworkImage(
                              'https://via.placeholder.com/150'),
                    ),
                  ),
                  Positioned(
                    bottom: 5,
                    right: 5,
                    child: GestureDetector(
                      onTap: _openProfilePage,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                            color: Colors.red, shape: BoxShape.circle),
                        child: const Icon(Icons.edit,
                            color: Colors.white, size: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
            Text(
              _profileName,
              style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF101828)),
            ),
            Text(
              _profileTitle,
              style: const TextStyle(
                  fontSize: 16, color: Colors.red, fontWeight: FontWeight.w500),
            ),
            Text(
              _profileEmail,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),

            const SizedBox(height: 35),

            // --- GRUP PENGATURAN AKUN ---
            _sectionLabel("PENGATURAN AKUN"),
            _buildMenuTile(
              icon: Icons.person_outline,
              title: "Edit Profil",
              onTap: _openProfilePage,
            ),
            _buildMenuTile(
              icon: Icons.history,
              title: "Riwayat Penjualan",
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const HistoryPage())),
            ),
            _buildMenuTile(
              icon: Icons.print_outlined,
              title: "Pengaturan Printer",
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const PrinterSettingsPage())),
            ),
            _buildMenuTile(
              icon: Icons.save_alt,
              title: "Backup Data",
              onTap: _backupData,
            ),
            _buildMenuTile(
              icon: Icons.restore,
              title: "Restore Backup",
              onTap: _confirmRestoreBackup,
            ),

            const SizedBox(height: 25),

            // --- GRUP LAINNYA ---
            _sectionLabel("LAINNYA"),
            _buildMenuTile(
              icon: Icons.help_outline,
              title: "Pusat Bantuan",
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const PusatBantuanPage())),
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
          style: TextStyle(
              fontWeight: FontWeight.w600, fontSize: 15, color: textColor),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
        onTap: onTap,
      ),
    );
  }
}
