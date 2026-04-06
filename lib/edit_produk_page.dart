import 'dart:io'; // Penting untuk File
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditProdukPage extends StatefulWidget {
  final Map<String, dynamic> product;

  const EditProdukPage({super.key, required this.product});

  @override
  State<EditProdukPage> createState() => _EditProdukPageState();
}

class _EditProdukPageState extends State<EditProdukPage> {
  late TextEditingController _nameController;
  late TextEditingController _sellPriceController;
  late int _stock;
  late String _selectedCategory;
  
  // Variabel untuk menyimpan gambar baru dari galeri
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product['name']);
    _sellPriceController = TextEditingController(text: widget.product['price'].toString());
    _stock = widget.product['stok'] != null ? int.tryParse(widget.product['stok'].toString()) ?? 0 : 0;
    _selectedCategory = widget.product['cat'];
  }

  // Fungsi untuk mengambil gambar dari galeri
  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text("Edit Produk", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
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
            // Preview Gambar & Tombol Kamera
            Center(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: _imageFile != null
                        ? Image.file(_imageFile!, height: 180, width: double.infinity, fit: BoxFit.cover)
                        : (widget.product['isLocal'] == true && widget.product['img']?.toString().isNotEmpty == true)
                            ? Image.file(File(widget.product['img']), height: 180, width: double.infinity, fit: BoxFit.cover)
                            : Image.network(widget.product['img'] ?? '', height: 180, width: double.infinity, fit: BoxFit.cover),
                  ),
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: GestureDetector(
                      onTap: _pickImage, // Klik icon kamera buka galeri
                      child: const CircleAvatar(
                        backgroundColor: Colors.red,
                        child: Icon(Icons.camera_alt, color: Colors.white),
                      ),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 25),
            _buildField("Nama Produk", _nameController),
            _buildCategoryDropdown(),
            _buildStockCounter(),
            const SizedBox(height: 20),
            _buildPriceSection(),
            const SizedBox(height: 30),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  // ... (Widget _buildField, _buildCategoryDropdown, _buildStockCounter, _buildPriceSection tetap sama seperti sebelumnya) ...
  // Saya persingkat ke tombol Simpan untuk logika pengiriman datanya:

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 15)),
            child: const Text("Batal"),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(vertical: 15),
            ),
            onPressed: () {
              final name = _nameController.text.trim();
              final price = int.tryParse(_sellPriceController.text) ?? 0;

              if (name.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Nama produk tidak boleh kosong')),
                );
                return;
              }

              if (price <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Harga jual harus lebih besar dari 0')),
                );
                return;
              }

              Map<String, dynamic> updatedData = {
                "id": widget.product['id'],
                "barcode": widget.product['barcode'],
                "name": name,
                "price": price,
                "cat": _selectedCategory,
                "stok": _stock,
                // Jika user pilih gambar baru, kirim path-nya. Jika tidak, pakai URL lama.
                "img": _imageFile != null ? _imageFile!.path : widget.product['img'],
                "isLocal": _imageFile != null || widget.product['isLocal'] == true,
              };
              Navigator.pop(context, updatedData);
            },
            child: const Text("Simpan Perubahan", style: TextStyle(color: Colors.white)),
          ),
        ),
      ],
    );
  }

  // Widget pendukung lainnya (Field, Dropdown, dll)
  Widget _buildField(String label, TextEditingController controller) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      TextField(controller: controller, decoration: InputDecoration(filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade300)))),
      const SizedBox(height: 15),
    ]);
  }

  Widget _buildCategoryDropdown() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text("Kategori", style: TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      Container(padding: const EdgeInsets.symmetric(horizontal: 12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey.shade300)),
        child: DropdownButtonHideUnderline(child: DropdownButton<String>(
          value: _selectedCategory, isExpanded: true,
          items: ["GORENGAN", "MINUMAN", "SEMBAKO", "LAINNYA"].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: (val) => setState(() => _selectedCategory = val!),
        ))),
      const SizedBox(height: 15),
    ]);
  }

  Widget _buildStockCounter() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text("Stok Saat Ini", style: TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      Row(children: [
        IconButton(onPressed: () => setState(() => _stock--), icon: const Icon(Icons.remove_circle_outline, color: Colors.red)),
        Text("$_stock", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        IconButton(onPressed: () => setState(() => _stock++), icon: const Icon(Icons.add_circle_outline, color: Colors.red)),
      ]),
    ]);
  }

  Widget _buildPriceSection() {
    return Container(padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: const Color(0xFFF1F4F8), borderRadius: BorderRadius.circular(15)),
      child: _buildField("Harga Jual (Rp)", _sellPriceController));
  }
}