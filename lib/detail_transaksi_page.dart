import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'printer_service.dart';
import 'profile_service.dart';

class DetailTransaksiPage extends StatefulWidget {
  final Map<String, dynamic>? transaction;

  const DetailTransaksiPage({super.key, this.transaction});

  @override
  State<DetailTransaksiPage> createState() => _DetailTransaksiPageState();
}

class _DetailTransaksiPageState extends State<DetailTransaksiPage> {
  String _storeName = 'Warung Madura Cabang Pusat';
  String _cashierName = 'Ahmad Fauzi';
  final NumberFormat _currencyFormatter =
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final profile = await ProfileService.getProfile();
    setState(() {
      _storeName = profile['storeName']!;
      _cashierName = profile['name']!;
    });
  }

  Future<void> _printReceipt() async {
    try {
      // Prepare transaction data for printing
      final transaction = widget.transaction;
      if (transaction == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data transaksi tidak tersedia')),
        );
        return;
      }

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
        storeName: _storeName,
        cashierName: _cashierName,
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

  Future<void> _refreshPage() async {
    await _loadProfileData();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Detail transaksi diperbarui')),
    );
  }

  String _buildShareText() {
    final transaction = widget.transaction ?? <String, dynamic>{};
    final code = transaction['code']?.toString() ??
        'TRX-${transaction['id']?.toString() ?? '-'}';
    final tanggal = _formatDate(transaction['tgl_transaksi']?.toString() ??
        transaction['date']?.toString() ??
        '');
    final metode = transaction['metode_bayar']?.toString() ?? 'Tunai';
    final details = transaction['details'] as List<dynamic>? ?? [];

    final itemLines = details.map((item) {
      final name = item['nama_produk']?.toString() ?? 'Produk';
      final qty = item['jumlah'] ?? 1;
      final price = (item['harga_satuan'] ?? 0).toDouble();
      final subtotal = price * qty;
      return '- $name (${qty}x) ${_currencyFormatter.format(subtotal)}';
    }).join('\n');

    final total = _currencyFormatter.format(
      double.tryParse(
            transaction['total_harga']?.toString() ??
                transaction['total']?.toString() ??
                '',
          ) ??
          0,
    );

    return 'Bukti Pembayaran $_storeName\n'
        'No. Transaksi: $code\n'
        'Tanggal: $tanggal\n'
        'Metode Bayar: $metode\n\n'
        'Rincian Pesanan:\n'
        '${itemLines.isEmpty ? '- Tidak ada item' : itemLines}\n\n'
        'Total: $total';
  }

  Future<void> _shareTransaction() async {
    try {
      await Share.share(_buildShareText(), subject: 'Detail Transaksi');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal membagikan transaksi: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text("Detail Transaksi",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.red),
            onPressed: () => Navigator.pop(context)),
        actions: [
          IconButton(
              icon: const Icon(Icons.refresh, color: Colors.red),
              tooltip: 'Refresh',
              onPressed: _refreshPage)
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            Center(
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child:
                    const Icon(Icons.receipt_long, color: Colors.red, size: 28),
              ),
            ),
            const SizedBox(height: 10),
            const Center(
              child: Text(
                'Bukti Pembayaran',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Center(
              child: Text(
                _storeName.toUpperCase(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.05,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.04),
                    blurRadius: 14,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('NOMOR TRANSAKSI',
                                style: TextStyle(
                                    fontSize: 10, color: Colors.grey)),
                            const SizedBox(height: 2),
                            Text(
                              widget.transaction?['code']?.toString() ??
                                  'TRX-${widget.transaction?['id'] ?? ''}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text('TANGGAL',
                                style: TextStyle(
                                    fontSize: 10, color: Colors.grey)),
                            const SizedBox(height: 2),
                            Text(
                              _formatDate(
                                  widget.transaction?['tgl_transaksi'] ?? ''),
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 12),
                              textAlign: TextAlign.right,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text('RINCIAN PESANAN',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                          letterSpacing: 0.4)),
                  const SizedBox(height: 8),
                  if (widget.transaction != null &&
                      widget.transaction!['details'] != null)
                    ..._buildOrderItems(widget.transaction!['details'] as List)
                  else
                    _buildOrderItem(
                      name: 'Produk Tidak Tersedia',
                      description: '',
                      amount: 0,
                    ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('TOTAL HARGA',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 13)),
                        Text(
                          _currencyFormatter.format(double.tryParse(widget
                                      .transaction?['total_harga']
                                      ?.toString() ??
                                  '') ??
                              0),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Terima Kasih Atas Kunjungan Anda. Kepuasan Anda adalah prioritas kami. Sampai jumpa di kunjungan berikutnya!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        color: Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton.icon(
              onPressed: _printReceipt,
              icon: const Icon(Icons.print, size: 18),
              label: const Text("Cetak Struk"),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 44),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10))),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                    child: OutlinedButton.icon(
                        onPressed: _shareTransaction,
                        icon: const Icon(Icons.share, size: 16),
                        label: const Text("Bagikan"),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(40),
                        ))),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItem({
    required String name,
    required String description,
    required double amount,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        height: 1.15)),
                if (description.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(description,
                        style: const TextStyle(
                            fontSize: 11, color: Colors.grey, height: 1.2)),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(_currencyFormatter.format(amount),
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 13, height: 1.2)),
        ],
      ),
    );
  }

  List<Widget> _buildOrderItems(List<dynamic> details) {
    return details.map((item) {
      final name = item['nama_produk'] ?? 'Produk';
      final qty = item['jumlah'] ?? 1;
      final price = (item['harga_satuan'] ?? 0).toDouble();
      final subtotal = price * qty;
      return _buildOrderItem(
        name: name,
        description: '$qty x ${_currencyFormatter.format(price)}',
        amount: subtotal,
      );
    }).toList();
  }

  String _formatDate(String rawDate) {
    try {
      final date = DateTime.parse(rawDate);
      return DateFormat('d MMM yyyy', 'id').format(date);
    } catch (_) {
      return rawDate;
    }
  }
}
