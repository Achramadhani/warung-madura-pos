import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'db_helper.dart';
import 'utils.dart';

class TambahProdukPage extends StatefulWidget {
  final String? barcode;

  const TambahProdukPage({super.key, this.barcode});

  @override
  State<TambahProdukPage> createState() => _TambahProdukPageState();
}

class _TambahProdukPageState extends State<TambahProdukPage> {
  late TextEditingController _barcodeController;
  late TextEditingController _namaController;
  late TextEditingController _hargaController;
  late TextEditingController _stokController;
  String _selectedKategori = 'SEMBAKO';
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _barcodeController = TextEditingController(text: widget.barcode ?? '');
    _namaController = TextEditingController();
    _hargaController = TextEditingController(text: '0');
    _stokController = TextEditingController(text: '0');
  }

  @override
  void dispose() {
    _barcodeController.dispose();
    _namaController.dispose();
    _hargaController.dispose();
    _stokController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  void _openBarcodeScanner() {
    final scannerController = MobileScannerController();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: SizedBox(
          height: 340,
          child: Stack(
            children: [
              MobileScanner(
                controller: scannerController,
                onDetect: (capture) {
                  final List<Barcode> barcodes = capture.barcodes;
                  if (barcodes.isNotEmpty) {
                    final rawBarcode = barcodes.first.rawValue ?? '';
                    final cleanBarcode = normalizeBarcode(rawBarcode);
                    setState(() {
                      _barcodeController.text = cleanBarcode;
                    });
                    Navigator.pop(context);
                  }
                },
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    tooltip: 'Refresh Scanner',
                    onPressed: () async {
                      await scannerController.stop();
                      await scannerController.start();
                    },
                  ),
                ),
              ),
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ).then((_) => scannerController.dispose());
  }

  Future<void> _saveProduct() async {
    final rawInput = _barcodeController.text;
    final barcode = normalizeBarcode(rawInput).isEmpty
        ? DateTime.now().millisecondsSinceEpoch.toString()
        : normalizeBarcode(rawInput);
    final name = _namaController.text.trim();
    final price = int.tryParse(_hargaController.text.trim()) ?? 0;
    final stock = int.tryParse(_stokController.text.trim()) ?? 0;

    if (name.isEmpty) {
      _showErrorSnackBar('Nama produk tidak boleh kosong');
      return;
    }

    if (price <= 0) {
      _showErrorSnackBar('Harga jual harus lebih besar dari 0');
      return;
    }

    try {
      await DbHelper.instance.insertProduk({
        'barcode': barcode,
        'nama_produk': name,
        'harga_jual': price,
        'stok': stock,
        'img': _imageFile?.path ?? '',
        'isLocal': _imageFile != null ? 1 : 0,
        'cat': _selectedKategori,
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Produk berhasil disimpan'),
            backgroundColor: Colors.green),
      );
      Navigator.pop(context, true);
    } catch (e) {
      _showErrorSnackBar('Gagal menyimpan produk: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('TAMBAH PRODUK',
            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        centerTitle: true,
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
            // GAMBAR PRODUK & ICON KAMERA
            Center(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: _imageFile != null
                        ? Image.file(_imageFile!,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover)
                        : Container(
                            height: 200,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: const Icon(Icons.image,
                                size: 80, color: Colors.grey),
                          ),
                  ),
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: const CircleAvatar(
                        backgroundColor: Colors.red,
                        child: Icon(Icons.camera_alt, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // TOMBOL SCAN BARCODE
            Center(
              child: ElevatedButton.icon(
                onPressed: _openBarcodeScanner,
                icon: const Icon(Icons.qr_code_2),
                label: const Text('Scan Barcode'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              ),
            ),
            const SizedBox(height: 30),

            // KODE BARCODE
            _buildLabel('KODE BARCODE'),
            const SizedBox(height: 8),
            _buildBarcodeField(),
            const SizedBox(height: 25),

            // ATAU MASUKKAN MANUAL
            const Center(
              child: Text('ATAU MASUKKAN MANUAL',
                  style: TextStyle(color: Colors.grey, fontSize: 12)),
            ),
            const SizedBox(height: 25),

            // NAMA PRODUK
            _buildLabel('NAMA PRODUK'),
            const SizedBox(height: 8),
            _buildTextField(_namaController, 'misal: Sovereign Noir Edition'),
            const SizedBox(height: 20),

            // HARGA JUAL
            _buildLabel('HARGA JUAL'),
            const SizedBox(height: 8),
            _buildPriceField(),
            const SizedBox(height: 20),

            // STOK
            _buildLabel('STOK'),
            const SizedBox(height: 8),
            _buildTextField(_stokController, '0', isNumber: true),
            const SizedBox(height: 20),

            // KATEGORI
            _buildLabel('KATEGORI'),
            const SizedBox(height: 8),
            _buildCategoryDropdown(),
            const SizedBox(height: 40),

            // TOMBOL AKSI
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      side: const BorderSide(color: Colors.grey),
                    ),
                    child: const Text('BATAL',
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveProduct,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                    ),
                    child: const Text('TAMBAH PRODUK',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Text(label,
        style: TextStyle(
            color: Colors.grey[700],
            fontWeight: FontWeight.bold,
            fontSize: 12));
  }

  Widget _buildTextField(TextEditingController controller, String hint,
      {bool isNumber = false}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFF8F0F1),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildBarcodeField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F0F1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _barcodeController,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: '0000 0000 0000',
              ),
              style: const TextStyle(letterSpacing: 1.5, fontSize: 14),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.grey),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildPriceField() {
    return TextField(
      controller: _hargaController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        hintText: '0',
        prefixText: 'IDR  ',
        filled: true,
        fillColor: const Color(0xFFF8F0F1),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F0F1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedKategori,
          isExpanded: true,
          items: ['SEMBAKO', 'MINUMAN', 'LAINNYA']
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: (value) {
            if (value != null) setState(() => _selectedKategori = value);
          },
        ),
      ),
    );
  }
}
