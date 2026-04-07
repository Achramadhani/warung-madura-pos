import 'package:flutter/material.dart';
import 'db_helper.dart';

class DebugDatabasePage extends StatefulWidget {
  const DebugDatabasePage({super.key});

  @override
  State<DebugDatabasePage> createState() => _DebugDatabasePageState();
}

class _DebugDatabasePageState extends State<DebugDatabasePage> {
  List<Map<String, dynamic>> _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final products = await DbHelper.instance.getAllProduk();
    setState(() {
      _products = products;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Database'),
        backgroundColor: Colors.red,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _products.length,
              itemBuilder: (context, index) {
                final product = _products[index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('ID: ${product['id']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text('Barcode: ${product['barcode']}'),
                        Text('Nama: ${product['nama_produk']}'),
                        Text('Harga: ${product['harga_jual']}'),
                        Text('Stok: ${product['stok']}'),
                        Text('Kategori: ${product['cat']}'),
                        Text('isLocal: ${product['isLocal']}'),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}