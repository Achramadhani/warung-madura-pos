import 'package:flutter/material.dart';
import 'home_page.dart';
import 'scan_page.dart';
import 'settings_page.dart'; // Menggunakan Settings sesuai keinginan tampilan Anda

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;
  final Map<int, Widget> _pageCache = {};

  Widget _buildPage(int index) {
    return _pageCache.putIfAbsent(index, () {
      switch (index) {
        case 0:
          return const HomePage();
        case 1:
          return const ScanPage();
        case 2:
          return const SettingsPage();
        default:
          return const HomePage();
      }
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack digunakan agar state halaman tidak ter-reset saat pindah tab
      body: IndexedStack(
        index: _selectedIndex,
        children: List<Widget>.generate(3, _buildPage),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedLabelStyle:
            const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner),
            label: 'Scan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
