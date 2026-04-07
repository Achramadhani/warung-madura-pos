import 'dart:developer' as developer;

import 'package:blue_thermal_printer/blue_thermal_printer.dart';

class PrinterService {
  static final PrinterService _instance = PrinterService._internal();

  factory PrinterService() {
    return _instance;
  }

  PrinterService._internal();

  final BlueThermalPrinter _bluetooth = BlueThermalPrinter.instance;
  BluetoothDevice? _connectedDevice;
  bool _isConnected = false;

  // Getters
  bool get isConnected => _isConnected;
  BluetoothDevice? get connectedDevice => _connectedDevice;

  // Scan available devices
  Future<List<BluetoothDevice>> scanDevices() async {
    try {
      List<BluetoothDevice> devices = await _bluetooth.getBondedDevices();
      return devices;
    } catch (e, stackTrace) {
      developer.log('Error scanning devices',
          name: 'PrinterService', error: e, stackTrace: stackTrace);
      return [];
    }
  }

  // Connect to a specific device
  Future<bool> connect(BluetoothDevice device) async {
    try {
      await _bluetooth.connect(device);
      _connectedDevice = device;
      _isConnected = true;
      return true;
    } catch (e, stackTrace) {
      developer.log('Error connecting to device',
          name: 'PrinterService', error: e, stackTrace: stackTrace);
      _isConnected = false;
      return false;
    }
  }

  // Disconnect
  Future<void> disconnect() async {
    try {
      await _bluetooth.disconnect();
      _connectedDevice = null;
      _isConnected = false;
    } catch (e, stackTrace) {
      developer.log('Error disconnecting device',
          name: 'PrinterService', error: e, stackTrace: stackTrace);
    }
  }

  // Check if connected
  Future<bool> checkConnection() async {
    try {
      bool? connected = await _bluetooth.isConnected;
      _isConnected = connected ?? false;
      return _isConnected;
    } catch (e, stackTrace) {
      developer.log('Error checking connection',
          name: 'PrinterService', error: e, stackTrace: stackTrace);
      _isConnected = false;
      return false;
    }
  }

  static const int _lineWidth = 32;

  String _buildLine(String char) {
    return List.filled(_lineWidth, char).join();
  }

  void _printSeparator([String char = '=']) {
    _bluetooth.printCustom(_buildLine(char), 1, 0);
    _bluetooth.printNewLine();
  }

  void _printEmptyLines(int count) {
    for (var i = 0; i < count; i++) {
      _bluetooth.printNewLine();
    }
  }

  // Print test receipt
  Future<void> printTestReceipt() async {
    try {
      if (!_isConnected) {
        throw Exception('Printer tidak terhubung');
      }

// Clear buffer and add top margin
      _printEmptyLines(2);

      // Header
      _bluetooth.printCustom("TOKO RAJAWALI", 3, 1); // size 3, bold
      _bluetooth.printNewLine();
      _bluetooth.printCustom("Test Receipt", 1, 0);
      _bluetooth.printNewLine();

      // Separator
      _printSeparator();

      // Items
      _bluetooth.printLeftRight("Item 1", "Rp 10.000", 1);
      _bluetooth.printLeftRight("Item 2", "Rp 20.000", 1);
      _bluetooth.printNewLine();

      // Separator
      _printSeparator();

      // Total
      _bluetooth.printLeftRight("TOTAL", "Rp 30.000", 1);
      _bluetooth.printNewLine();

      // Footer
      _bluetooth.printCustom("Terima Kasih", 1, 1);
      _bluetooth.printNewLine();
      _bluetooth.printCustom(DateTime.now().toString(), 1, 0);
      _bluetooth.printNewLine();

      // Bottom margin
      _printEmptyLines(2);

      // Cut paper (optional)
      _bluetooth.paperCut();
    } catch (e, stackTrace) {
      developer.log('Error printing test receipt',
          name: 'PrinterService', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // Print transaction receipt
  Future<void> printTransactionReceipt({
    required String storeName,
    required String cashierName,
    required List<Map<String, dynamic>> items,
    required double totalAmount,
    required String paymentMethod,
  }) async {
    try {
      if (!_isConnected) {
        throw Exception('Printer tidak terhubung');
      }

      _printEmptyLines(2);

      // Header
      _bluetooth.printCustom(storeName, 3, 1);
      _bluetooth.printNewLine();
      _bluetooth.printCustom("STRUK PEMBELIAN", 2, 1);
      _bluetooth.printNewLine();

      // Separator
      _printSeparator();

      // Timestamp and cashier
      String timestamp = DateTime.now().toString().substring(0, 19);
      _bluetooth.printCustom("Waktu: $timestamp", 1, 0);
      _bluetooth.printCustom("Kasir: $cashierName", 1, 0);
      _bluetooth.printNewLine();

      // Separator
      _printSeparator();

      // Items
      _bluetooth.printCustom("BARANG", 1, 1);
      for (var item in items) {
        String name = item['nama_produk'] ?? 'Produk';
        int qty = item['quantity'] ?? 1;
        double price = (item['harga_jual'] ?? 0).toDouble();
        double subtotal = price * qty;

        _bluetooth.printLeftRight(
            "$name x$qty", "Rp ${subtotal.toStringAsFixed(0)}", 1);
      }

      _bluetooth.printNewLine();

      // Separator
      _printSeparator();

      // Total
      _bluetooth.printLeftRight(
          "TOTAL", "Rp ${totalAmount.toStringAsFixed(0)}", 1);
      _bluetooth.printNewLine();

      // Payment method
      _bluetooth.printCustom("Metode: $paymentMethod", 1, 0);
      _bluetooth.printNewLine();

      // Footer
      _printSeparator();
      _bluetooth.printCustom("Terima Kasih atas Pembelian Anda", 1, 1);
      _bluetooth.printNewLine();
      _printEmptyLines(2);

      // Cut paper
      _bluetooth.paperCut();
    } catch (e, stackTrace) {
      developer.log('Error printing transaction receipt',
          name: 'PrinterService', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
}
