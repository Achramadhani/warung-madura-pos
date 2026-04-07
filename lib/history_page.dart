import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'db_helper.dart';
import 'detail_transaksi_page.dart';
import 'printer_service.dart';
import 'profile_service.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final FocusNode _searchFocusNode = FocusNode();
  String _searchQuery = '';
  bool _isLoading = true;
  List<Map<String, dynamic>> _transactions = [];
  List<Map<String, dynamic>> _filteredTransactions = [];

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadTransactions() async {
    if (mounted) {
      setState(() => _isLoading = true);
    }

    final headers = await DbHelper.instance.getAllTransaksi();
    final List<Map<String, dynamic>> txns = [];

    for (var header in headers) {
      final details = await DbHelper.instance
          .getDetailTransaksiByTransaksiId(header['id'] as int);
      txns.add({
        'id': header['id'],
        'code': '#SS-${((header['id'] as int) + 99278).toString()}',
        'date': header['tgl_transaksi'] ?? '',
        'total': (header['total_harga'] ?? 0).toString(),
        'status': 'Selesai',
        'metode_bayar': header['metode_bayar'] ?? 'Tunai',
        'details': details,
      });
    }

    if (!mounted) return;
    setState(() {
      _transactions = txns;
      _applyFilter();
      _isLoading = false;
    });
  }

  void _applyFilter() {
    if (_searchQuery.isEmpty) {
      _filteredTransactions = List.from(_transactions);
    } else {
      final query = _searchQuery.toLowerCase();
      _filteredTransactions = _transactions.where((txn) {
        final codeMatch =
            txn['code']?.toString().toLowerCase().contains(query) ?? false;
        final itemMatch = (txn['details'] as List<dynamic>).any((detail) {
          return detail['barcode']?.toString().toLowerCase().contains(query) ??
              false;
        });
        return codeMatch || itemMatch;
      }).toList();
    }
  }

  Future<void> _printReceipt(Map<String, dynamic> transaction) async {
    try {
      final profile = await ProfileService.getProfile();
      final storeName = profile['storeName']!;
      final cashierName = profile['name']!;

      final items = transaction['details'] as List<Map<String, dynamic>>? ?? [];
      final totalAmount =
          double.tryParse(transaction['total'].toString()) ?? 0.0;
      final paymentMethod = transaction['metode_bayar'] ?? 'Tunai';

      // Convert items to format expected by printer service
      final formattedItems = items.map((item) {
        return {
          'nama_produk': item['nama_produk'] ?? 'Produk',
          'quantity': item['jumlah'] ?? 1,
          'harga_jual': item['harga_satuan'] ?? 0,
        };
      }).toList();

      await PrinterService().printTransactionReceipt(
        storeName: storeName,
        cashierName: cashierName,
        items: formattedItems,
        totalAmount: totalAmount,
        paymentMethod: paymentMethod,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Struk berhasil dicetak')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mencetak struk: $e')),
      );
    }
  }

  String get _totalOmzet {
    final total = _filteredTransactions.fold<double>(
        0, (sum, txn) => sum + double.tryParse(txn['total'].toString())!);
    return NumberFormat.currency(
            locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
        .format(total);
  }

  String get _transactionCount => '${_filteredTransactions.length} Transaksi';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.red),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Riwayat Penjualan',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.red),
            tooltip: 'Refresh',
            onPressed: _loadTransactions,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSearchBar(),
                  const SizedBox(height: 20),
                  _buildSummaryCard(),
                  const SizedBox(height: 20),
                  _buildTransactionListHeader(),
                  const SizedBox(height: 10),
                  ..._filteredTransactions
                      .map((txn) => _buildTransactionItem(context, txn)),
                  if (_filteredTransactions.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15)),
                      child: const Text(
                          'Tidak ada transaksi yang sesuai dengan pencarian.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey)),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 12)
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Colors.red),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              focusNode: _searchFocusNode,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                  _applyFilter();
                });
              },
              decoration: const InputDecoration(
                hintText: 'Cari kode produk atau transaksi',
                border: InputBorder.none,
              ),
            ),
          ),
          if (_searchQuery.isNotEmpty)
            GestureDetector(
              onTap: () {
                setState(() {
                  _searchQuery = '';
                  _applyFilter();
                });
              },
              child: const Icon(Icons.close, color: Colors.grey),
            ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: const Color(0xFFFFE8E8),
          borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('TOTAL OMZET HARI INI',
              style: TextStyle(
                  color: Colors.black54,
                  fontWeight: FontWeight.bold,
                  fontSize: 12)),
          const SizedBox(height: 10),
          Text(_totalOmzet,
              style: const TextStyle(
                  color: Colors.red,
                  fontSize: 32,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20)),
                child: Text(_transactionCount,
                    style:
                        const TextStyle(color: Colors.black54, fontSize: 12)),
              ),
              const SizedBox(width: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(20)),
                child: const Text('+12% vs Kemarin',
                    style: TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionListHeader() {
    return const Text('DAFTAR TRANSAKSI',
        style: TextStyle(
            fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blueGrey));
  }

  Widget _buildTransactionItem(BuildContext context, Map<String, dynamic> txn) {
    final date = txn['date']?.toString() ?? '';
    final formattedDate = _formatDate(date);

    return GestureDetector(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => DetailTransaksiPage(transaction: txn))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(15)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('ID TRANSAKSI',
                          style: TextStyle(fontSize: 12, color: Colors.grey)),
                      const SizedBox(height: 6),
                      Text(txn['code'].toString(),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                ),
                Text(formattedDate,
                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 18),
            const Text('TOTAL HARGA',
                style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: Text(
                    NumberFormat.currency(
                            locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
                        .format(double.tryParse(txn['total'].toString()) ?? 0),
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.print, size: 16),
                  label: const Text('CETAK',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12))),
                  onPressed: () => _printReceipt(txn),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('d MMM yyyy, HH:mm', 'id').format(date);
    } catch (_) {
      return dateString;
    }
  }
}
