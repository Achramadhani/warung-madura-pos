import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'cart_provider.dart';
import 'db_helper.dart';
import 'edit_produk_page.dart';
import 'tambah_produk.dart';
import 'keranjang_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> _allProducts = [];

  final List<Map<String, dynamic>> _defaultProducts = [
    {
      "barcode": "8881",
      "cat": "GORENGAN",
      "name": "Tempe Goreng",
      "harga_jual": 1000,
      "stok": 20,
      "img": "https://images.unsplash.com/photo-1567188040759-fb8a883dc6d8?q=80&w=1000",
      "isLocal": 0,
    },
    {
      "barcode": "8882",
      "cat": "MINUMAN",
      "name": "Es Teh Manis",
      "harga_jual": 3000,
      "stok": 15,
      "img": "https://images.unsplash.com/photo-1556679343-c7306c1976bc?q=80&w=1000",
      "isLocal": 0,
    },
    {
      "barcode": "8883",
      "cat": "SEMBAKO",
      "name": "Indomie Goreng",
      "harga_jual": 3500,
      "stok": 30,
      "img": "https://images.unsplash.com/photo-1591814448473-7f47c2153210?q=80&w=1000",
      "isLocal": 0,
    },
    {
      "barcode": "8884",
      "cat": "MINUMAN",
      "name": "Le Minerale 600ml",
      "harga_jual": 4000,
      "stok": 25,
      "img": "https://images.unsplash.com/photo-1548839140-29a749e1cf4d?q=80&w=1000",
      "isLocal": 0,
    },
  ];

  String _searchQuery = "";
  String _selectedCategory = "Semua";

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final products = await DbHelper.instance.getAllProduk();
    if (products.isEmpty) {
      await _seedDefaultProducts();
      final seeded = await DbHelper.instance.getAllProduk();
      setState(() => _allProducts = seeded);
    } else {
      setState(() => _allProducts = products);
    }
  }

  Future<void> _seedDefaultProducts() async {
    for (var item in _defaultProducts) {
      await DbHelper.instance.insertProduk(item);
    }
  }

  Future<void> _openAddProductPage() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const TambahProdukPage()),
    );

    if (result == true) {
      await _loadProducts();
    }
  }

  Future<void> _showEditProdukPage(Map<String, dynamic> product) async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (_) => EditProdukPage(product: {
        'id': product['id'],
        'barcode': product['barcode'],
        'name': product['nama_produk'],
        'price': product['harga_jual'],
        'stok': product['stok'],
        'cat': product['cat'],
        'img': product['img'] ?? '',
        'isLocal': product['isLocal'] == 1,
      })),
    );

    if (result != null) {
      await DbHelper.instance.updateProduk({
        'id': result['id'],
        'barcode': result['barcode'],
        'nama_produk': result['name'],
        'harga_jual': result['price'],
        'stok': result['stok'],
        'img': result['img'],
        'isLocal': result['isLocal'] ? 1 : 0,
        'cat': result['cat'],
      });
      await _loadProducts();
    }
  }

  Future<void> _deleteProduct(String barcode) async {
    await DbHelper.instance.deleteProduk(barcode);
    await _loadProducts();
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Produk berhasil dihapus')));
  }

  List<Map<String, dynamic>> get _filteredProducts {
    return _allProducts.where((product) {
      final matchesSearch = product['nama_produk']?.toString().toLowerCase().contains(_searchQuery.toLowerCase()) ?? false;
      final matchesCategory = _selectedCategory == "Semua" || 
                              product['cat']?.toString().toUpperCase() == _selectedCategory.toUpperCase();
      return matchesSearch && matchesCategory;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                _buildSearchBar(),
                _buildCategoryFilter(),
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 15, 20, 10),
                  child: Text("PRODUK POPULER", 
                    style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF5F6368), fontSize: 12, letterSpacing: 0.5)),
                ),
                Expanded(child: _buildProductGrid()),
              ],
            ),
            _buildFloatingCartBottom(), // Tombol melayang di bawah
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
            child: const Icon(Icons.storefront, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Warung Madura", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              Text("Kasir: Ahmad Fauzi", style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
          const Spacer(),
          IconButton(
            onPressed: _openAddProductPage,
            icon: const Icon(Icons.add_circle_outline, color: Colors.black54),
            tooltip: 'Tambah Produk',
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: Container(
        decoration: BoxDecoration(color: const Color(0xFFEBEEF2), borderRadius: BorderRadius.circular(15)),
        child: TextField(
          onChanged: (value) => setState(() => _searchQuery = value),
          decoration: const InputDecoration(
            hintText: "Cari produk...",
            prefixIcon: Icon(Icons.search, color: Colors.grey),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 15),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    final categories = ["Semua", "Sembako", "Minuman", "Gorengan"];
    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          bool isSelected = _selectedCategory == categories[index];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(categories[index]),
              selected: isSelected,
              onSelected: (val) => setState(() => _selectedCategory = categories[index]),
              selectedColor: Colors.red,
              labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black54),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              side: BorderSide.none,
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductGrid() {
    final cart = Provider.of<CartProvider>(context, listen: false);

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(20, 5, 20, 100),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.72,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
      ),
      itemCount: _filteredProducts.length,
      itemBuilder: (context, index) {
        final p = _filteredProducts[index];
        return GestureDetector(
          onTap: () => _showEditProdukPage(p),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                        child: (p['img']?.toString().isNotEmpty ?? false)
                            ? (p['isLocal'] == 1
                                ? Image.file(File(p['img']), fit: BoxFit.cover, width: double.infinity)
                                : Image.network(p['img'], fit: BoxFit.cover, width: double.infinity))
                            : Container(color: Colors.grey[200], width: double.infinity, child: const Icon(Icons.image, size: 50, color: Colors.grey)),
                      ),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                _showEditProdukPage(p);
                              },
                              child: Container(
                                decoration: BoxDecoration(color: Colors.white70, borderRadius: BorderRadius.circular(10)),
                                padding: const EdgeInsets.all(6),
                                child: const Icon(Icons.edit, size: 18, color: Colors.black87),
                              ),
                            ),
                            const SizedBox(width: 6),
                            GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: const Text('Hapus Produk'),
                                      content: const Text('Apakah Anda yakin ingin menghapus produk ini?'),
                                      actions: [
                                        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                          onPressed: () {
                                            Navigator.pop(context);
                                            _deleteProduct(p['barcode']);
                                          },
                                          child: const Text('Hapus'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(color: Colors.white70, borderRadius: BorderRadius.circular(10)),
                                padding: const EdgeInsets.all(6),
                                child: const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p['cat'] ?? '', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 10)),
                      Text(p['nama_produk'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Rp ${p['harga_jual']}", style: const TextStyle(fontWeight: FontWeight.bold)),
                          GestureDetector(
                            onTap: () {
                              cart.addToCart({
                                'barcode': p['barcode'],
                                'nama_produk': p['nama_produk'],
                                'harga_jual': p['harga_jual'],
                                'img': p['img'],
                                'isLocal': p['isLocal'] == 1,
                              });

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("${p['nama_produk']} masuk keranjang"), duration: const Duration(milliseconds: 500)),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(8)),
                              child: const Icon(Icons.add, size: 16, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFloatingCartBottom() {
    return Consumer<CartProvider>(
      builder: (context, cart, child) {
        if (cart.items.isEmpty) return const SizedBox.shrink();
        return Positioned(
          bottom: 20, left: 15, right: 15,
          child: Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: const Color(0xFF101828),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 15)],
            ),
            child: Row(
              children: [
                const Icon(Icons.shopping_bag_outlined, color: Colors.white),
                const SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("${cart.items.length} Produk", style: const TextStyle(color: Colors.white60, fontSize: 12)),
                    Text("Rp ${cart.totalHarga.toInt()}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const KeranjangPage())),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black),
                  child: const Text("KERANJANG", style: TextStyle(fontWeight: FontWeight.bold)),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}