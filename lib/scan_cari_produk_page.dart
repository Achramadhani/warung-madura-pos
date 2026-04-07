import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'db_helper.dart';
import 'produk_ditemukan.dart';
import 'utils.dart';

class ScanCariProdukPage extends StatefulWidget {
  const ScanCariProdukPage({super.key});

  @override
  State<ScanCariProdukPage> createState() => _ScanCariProdukPageState();
}

class _ScanCariProdukPageState extends State<ScanCariProdukPage> {
  bool isScanCompleted = false;
  late MobileScannerController cameraController;

  @override
  void initState() {
    super.initState();
    cameraController = MobileScannerController();
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  void _prosesHasilScan(String code) async {
    final cleanCode = normalizeBarcode(code);
    if (isScanCompleted) return;
    setState(() => isScanCompleted = true);

    try {
      final produkList = await DbHelper.instance.getAllProduk();
      final produk = produkList.firstWhere(
        (p) => p['barcode'] == cleanCode,
        orElse: () => {},
      );

      if (!mounted) return;

      if (produk.isNotEmpty) {
        // Produk ditemukan, navigasi ke halaman detail produk
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ProdukDitemukanPage(produk: produk),
          ),
        );
      } else {
        // Produk tidak ditemukan
        _showErrorPopup(
          barcode: code,
          onConfirm: () {
            setState(() => isScanCompleted = false);
          },
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
      setState(() => isScanCompleted = false);
    }
  }

  void _showErrorPopup(
      {required String barcode, required VoidCallback onConfirm}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error, color: Colors.red, size: 60),
              const SizedBox(height: 15),
              const Text('Produk Tidak Ditemukan!',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 10),
              Text('Barcode: $barcode',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 10),
              const Text(
                  'Produk dengan barcode ini tidak terdaftar dalam database.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        onConfirm();
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        foregroundColor: Colors.red,
                      ),
                      child: const Text('Scan Lagi'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context); // Kembali ke halaman sebelumnya
                      },
                      style:
                          ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: const Text('Kembali',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Scan Cari Produk',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: cameraController,
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              if (barcodes.isNotEmpty) {
                final rawBarcode = barcodes.first.rawValue ?? '';
                final cleanBarcode = normalizeBarcode(rawBarcode);
                if (cleanBarcode.isNotEmpty) {
                  _prosesHasilScan(cleanBarcode);
                }
              }
            },
          ),
          // Overlay untuk frame scanner
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.red, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.qr_code_scanner, color: Colors.red, size: 50),
                  SizedBox(height: 10),
                  Text(
                    'Arahkan kamera ke barcode produk',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          // Loading indicator saat scan
          if (isScanCompleted)
            Container(
              color: Colors.black.withOpacity(0.7),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.red),
              ),
            ),
        ],
      ),
    );
  }
}
