import 'package:flutter/material.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'printer_service.dart';

class PrinterSettingsPage extends StatefulWidget {
  const PrinterSettingsPage({super.key});

  @override
  State<PrinterSettingsPage> createState() => _PrinterSettingsPageState();
}

class _PrinterSettingsPageState extends State<PrinterSettingsPage> {
  bool _autoPrintEnabled = true;
  bool _bluetoothEnabled = true;
  String _connectedPrinter = '';
  String _selectedPrinterId = '';
  List<BluetoothDevice> _availableDevices = [];
  bool _isScanning = false;
  final PrinterService _printerService = PrinterService();

  @override
  void initState() {
    super.initState();
    _loadConnectedPrinter();
    _scanDevices(); // Auto-scan devices on page load
  }

  Future<void> _loadConnectedPrinter() async {
    final isConnected = await _printerService.checkConnection();
    if (isConnected && _printerService.connectedDevice != null) {
      setState(() {
        _connectedPrinter = _printerService.connectedDevice!.name ?? 'Tidak diketahui';
        _selectedPrinterId = _printerService.connectedDevice!.address ?? '';
      });
    }
  }

  Future<void> _scanDevices() async {
    setState(() => _isScanning = true);
    try {
      List<BluetoothDevice> devices = await _printerService.scanDevices();
      setState(() {
        _availableDevices = devices;
        _isScanning = false;
      });
      if (devices.isEmpty) {
        _showSnackBar('Tidak ada printer Bluetooth yang ditemukan. Pastikan printer sudah dipair di pengaturan.');
      }
    } catch (e) {
      setState(() => _isScanning = false);
      _showSnackBar('Error saat scanning: $e');
    }
  }

  void _testPrint() {
    try {
      if (!_printerService.isConnected) {
        _showSnackBar('Printer tidak terhubung. Silakan hubungkan printer terlebih dahulu.');
        return;
      }
      _showSnackBar('Mengirim print test ke $_connectedPrinter...');
      _printerService.printTestReceipt().then((_) {
        _showSnackBar('Test print berhasil dikirim!');
      }).catchError((e) {
        _showSnackBar('Error: $e');
      });
    } catch (e) {
      _showSnackBar('Error: $e');
    }
  }

  Future<void> _connectPrinter(BluetoothDevice device) async {
    try {
      _showSnackBar('Menghubungkan ke ${device.name}...');
      bool success = await _printerService.connect(device);
      if (success) {
        setState(() {
          _connectedPrinter = device.name ?? 'Tidak diketahui';
          _selectedPrinterId = device.address ?? '';
        });
        _showSnackBar('Berhasil terhubung ke ${device.name}');
      } else {
        _showSnackBar('Gagal terhubung ke ${device.name}');
      }
    } catch (e) {
      _showSnackBar('Error: $e');
    }
  }

  Future<void> _disconnectPrinter() async {
    try {
      await _printerService.disconnect();
      setState(() {
        _connectedPrinter = '';
        _selectedPrinterId = '';
      });
      _showSnackBar('Terputus dari printer');
    } catch (e) {
      _showSnackBar('Error: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text("Printer Settings", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 24)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- SISTEM SECTION ---
            _sectionLabel('SISTEM'),
            _buildToggleTile(
              title: 'Auto-print Struk',
              value: _autoPrintEnabled,
              onChanged: (val) => setState(() => _autoPrintEnabled = val),
            ),
            const SizedBox(height: 25),

            // --- NIRKABEL SECTION ---
            _sectionLabel('NIRKABEL'),
            _buildToggleTile(
              title: 'Bluetooth',
              value: _bluetoothEnabled,
              onChanged: (val) {
                setState(() => _bluetoothEnabled = val);
                if (val) {
                  _showSnackBar('Bluetooth diaktifkan');
                } else {
                  _disconnectPrinter();
                }
              },
            ),
            const SizedBox(height: 25),

            // --- PERANGKAT TERSEDIA SECTION ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _sectionLabel('PERANGKAT TERSEDIA'),
                IconButton(
                  icon: _isScanning
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                          ),
                        )
                      : const Icon(Icons.refresh, color: Colors.red),
                  onPressed: _isScanning ? null : _scanDevices,
                ),
              ],
            ),
            
            // Show connected printer first
            if (_selectedPrinterId.isNotEmpty)
              _buildConnectedPrinterCard(),
            
            const SizedBox(height: 15),

            // Show available printers
            if (_availableDevices.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: const Text(
                  'Tidak ada printer ditemukan. Pastikan printer sudah dipair di Bluetooth settings.',
                  style: TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              )
            else
              ..._availableDevices.map((device) {
                if (device.address == _selectedPrinterId) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildPrinterItemBluetooth(device: device),
                );
              }).toList(),

            const SizedBox(height: 30),

            // --- PANDUAN PENGATURAN SECTION ---
            _sectionLabel('PANDUAN PENGATURAN'),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'PANDUAN PENGATURAN',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Pelajari cara menghubungkan printer thermal dalam 3 langkah mudah.',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.blueGrey,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildToggleTile({
    required String title,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          Switch(
            value: value,
            activeColor: Colors.red,
            activeTrackColor: Colors.red.withOpacity(0.5),
            inactiveThumbColor: Colors.grey,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildConnectedPrinterCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE8E8),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Terhubung',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.print, color: Colors.white, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _connectedPrinter,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: Colors.green,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Text(
                                    'Terhubung',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.green,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _testPrint,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text(
                'Test Print',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrinterItemBluetooth({required BluetoothDevice device}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
      ),
      child: Row(
        children: [
          const Icon(Icons.print, color: Colors.grey, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  device.name ?? 'Tidak diketahui',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Text(
                  device.address ?? '',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => _connectPrinter(device),
            child: const Text(
              'Hubungkan',
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
