import 'package:flutter/material.dart';
import 'produk_ditemukan.dart';

class InputManualPage extends StatefulWidget {
  const InputManualPage({super.key});

  @override
  State<InputManualPage> createState() => _InputManualPageState();
}

class _InputManualPageState extends State<InputManualPage> {
  String code = "";

  void _onTap(String val) {
    setState(() {
      if (val == "C") code = "";
      else if (val == "X") { if (code.isNotEmpty) code = code.substring(0, code.length - 1); }
      else { if (code.length < 13) code += val; }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white, elevation: 0, leading: const BackButton(color: Colors.black), title: const Text("Input Manual", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)), centerTitle: true),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Masukkan Barcode", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 30),
                const Text("Kode Produk", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12)),
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.all(18),
                  width: double.infinity,
                  decoration: BoxDecoration(border: Border.all(color: Colors.red.withOpacity(0.3)), borderRadius: BorderRadius.circular(12)),
                  child: Text(code.isEmpty ? "899xxxxxxx" : code, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: code.isEmpty ? Colors.grey[300] : Colors.black)),
                ),
              ],
            ),
          ),
          const Spacer(),
          _buildNumpad(),
          Padding(
            padding: const EdgeInsets.all(24),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, minimumSize: const Size(double.infinity, 55), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              onPressed: code.isEmpty ? null : () => Navigator.push(context, MaterialPageRoute(builder: (context) => ProdukDitemukanPage(code: code))),
              child: const Text("Cari Produk", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildNumpad() {
    final keys = ["1","2","3","4","5","6","7","8","9","C","0","X"];
    return GridView.builder(
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 2),
      itemCount: keys.length,
      itemBuilder: (context, i) => InkWell(
        onTap: () => _onTap(keys[i]),
        child: Center(child: Text(keys[i], style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: (keys[i] == "C" || keys[i] == "X") ? Colors.red : Colors.black))),
      ),
    );
  }
}