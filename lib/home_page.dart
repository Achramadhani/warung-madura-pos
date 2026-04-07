import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'cart_provider.dart';
import 'db_helper.dart';
import 'edit_produk_page.dart';
import 'tambah_produk.dart';
import 'keranjang_page.dart';
import 'scan_cari_produk_page.dart';
import 'profile_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> _allProducts = [];
  bool _isLoadingProducts = true;
  String _storeName = 'Warung Madura Cabang Pusat';
  String _cashierName = 'Ahmad Fauzi';
  String? _profileImagePath;

  String _searchQuery = "";
  String _selectedCategory = "Semua";

  @override
  void initState() {
    super.initState();
    _refreshProducts(showSuccessMessage: false);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _refreshProfileData();
  }

  Future<void> _loadProfileData() async {
    final profile = await ProfileService.getProfile();
    if (!mounted) return;
    setState(() {
      _storeName = profile['storeName']!;
      _cashierName = profile['name']!;
      _profileImagePath = profile['imagePath'];
    });
  }

  Future<void> _refreshProfileData() async {
    await _loadProfileData();
  }

  Future<void> _loadProducts() async {
    final products = await DbHelper.instance.getAllProduk();
    if (!mounted) return;
    setState(() => _allProducts = products);
  }

  Future<void> _refreshProducts({bool showSuccessMessage = true}) async {
    setState(() => _isLoadingProducts = true);
    await _refreshProfileData();
    await _loadProducts();
    if (mounted) {
      setState(() => _isLoadingProducts = false);
      if (showSuccessMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data produk berhasil diperbarui!')),
        );
      }
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
      MaterialPageRoute(
          builder: (_) => EditProdukPage(product: {
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
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Produk berhasil dihapus')));
  }

  List<Map<String, dynamic>> get _filteredProducts {
    return _allProducts.where((product) {
      final matchesSearch = product['nama_produk']
              ?.toString()
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ??
          false;
      final matchesCategory = _selectedCategory == "Semua" ||
          product['cat']?.toString().toUpperCase() ==
              _selectedCategory.toUpperCase();
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
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF5F6368),
                          fontSize: 12,
                          letterSpacing: 0.5)),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _refreshProducts,
                    child: _isLoadingProducts
                        ? const Center(child: CircularProgressIndicator())
                        : _buildProductGrid(),
                  ),
                ),
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
            decoration:
                const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
            child: _profileImagePath != null
                ? ClipOval(
                    child: Image.file(
                      File(_profileImagePath!),
                      width: 24,
                      height: 24,
                      fit: BoxFit.cover,
                    ),
                  )
                : const Icon(Icons.storefront, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_storeName,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18)),
              Text("Kasir: $_cashierName",
                  style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
          const Spacer(),
          IconButton(
            onPressed: _refreshProducts,
            icon: const Icon(Icons.refresh_outlined, color: Colors.black54),
            tooltip: 'Refresh Data',
          ),
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
        decoration: BoxDecoration(
            color: const Color(0xFFEBEEF2),
            borderRadius: BorderRadius.circular(15)),
        child: Row(
          children: [
            Expanded(
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
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ScanCariProdukPage()),
                );
              },
              icon: const Icon(Icons.qr_code_scanner, color: Colors.red),
              tooltip: 'Scan Cari Produk',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    final categories = ["Semua", "Sembako", "Minuman"];
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
              onSelected: (val) =>
                  setState(() => _selectedCategory = categories[index]),
              selectedColor: Colors.red,
              labelStyle:
                  TextStyle(color: isSelected ? Colors.white : Colors.black54),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              side: BorderSide.none,
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductGrid() {
    final cart = Provider.of<CartProvider>(context, listen: false);

    if (_filteredProducts.isEmpty) {
      return ListView(
        children: const [
          Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory_2_outlined,
                      size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Belum ada produk',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Tekan tombol refresh untuk memuat data produk',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return GridView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
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
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03), blurRadius: 10)
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(15)),
                        child: (p['img']?.toString().isNotEmpty ?? false)
                            ? (p['isLocal'] == 1
                                ? Image.file(File(p['img']),
                                    fit: BoxFit.cover, width: double.infinity)
                                : Image.network(p['img'],
                                    fit: BoxFit.cover, width: double.infinity))
                            : Container(
                                color: Colors.grey[200],
                                width: double.infinity,
                                child: const Icon(Icons.image,
                                    size: 50, color: Colors.grey)),
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
                                decoration: BoxDecoration(
                                    color: Colors.white70,
                                    borderRadius: BorderRadius.circular(10)),
                                padding: const EdgeInsets.all(6),
                                child: const Icon(Icons.edit,
                                    size: 18, color: Colors.black87),
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
                                      content: const Text(
                                          'Apakah Anda yakin ingin menghapus produk ini?'),
                                      actions: [
                                        TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: const Text('Batal')),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red),
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
                                decoration: BoxDecoration(
                                    color: Colors.white70,
                                    borderRadius: BorderRadius.circular(10)),
                                padding: const EdgeInsets.all(6),
                                child: const Icon(Icons.delete_outline,
                                    size: 18, color: Colors.red),
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
                      Text(p['cat'] ?? '',
                          style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 10)),
                      Text(p['nama_produk'] ?? '',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Rp ${p['harga_jual']}",
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
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
                                SnackBar(
                                    content: Text(
                                        "${p['nama_produk']} masuk keranjang"),
                                    duration:
                                        const Duration(milliseconds: 500)),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(8)),
                              child: const Icon(Icons.add,
                                  size: 16, color: Colors.white),
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
          bottom: 20,
          left: 15,
          right: 15,
          child: Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: const Color(0xFF101828),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3), blurRadius: 15)
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.shopping_bag_outlined, color: Colors.white),
                const SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("${cart.items.length} Produk",
                        style: const TextStyle(
                            color: Colors.white60, fontSize: 12)),
                    Text("Rp ${cart.totalHarga.toInt()}",
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
                  ],
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const KeranjangPage())),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black),
                  child: const Text("KERANJANG",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
