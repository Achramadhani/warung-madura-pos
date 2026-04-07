import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DbHelper {
  static final DbHelper instance = DbHelper._init();
  static Database? _database;

  DbHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('toko_rajawali.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 3,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 3 && newVersion >= 3) {
      await db
          .execute('CREATE INDEX IF NOT EXISTS idx_barcode ON produk(barcode)');
    }
    if (oldVersion < 2 && newVersion >= 2) {
      // Pastikan tabel produk ada.
      final tableExists = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='produk'",
      );

      if (tableExists.isEmpty) {
        await _createProdukTable(db);
        await _seedInitialProducts(db);
        return;
      }

      // Tambahkan kolom cat hanya jika belum ada.
      final columns = await db.rawQuery('PRAGMA table_info(produk)');
      final hasCat =
          columns.any((col) => col['name']?.toString().toLowerCase() == 'cat');
      if (!hasCat) {
        await db.execute(
            'ALTER TABLE produk ADD COLUMN cat TEXT DEFAULT "SEMBAKO"');
      }
    }
  }

  Future<void> _createProdukTable(Database db) async {
    await db.execute('''
      CREATE TABLE produk (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        barcode TEXT UNIQUE NOT NULL,
        nama_produk TEXT NOT NULL,
        harga_jual REAL NOT NULL,
        stok INTEGER NOT NULL,
        img TEXT,
        isLocal INTEGER DEFAULT 1,
        cat TEXT DEFAULT "SEMBAKO"
      )
    ''');
  }

  Future<void> _seedInitialProducts(Database db) async {
    const initialProducts = [
      {
        "barcode": "8881",
        "cat": "LAINNYA",
        "nama_produk": "Tempe Goreng",
        "harga_jual": 1000,
        "stok": 20,
        "img":
            "https://images.unsplash.com/photo-1567188040759-fb8a883dc6d8?q=80&w=1000",
        "isLocal": 0,
      },
      {
        "barcode": "8882",
        "cat": "MINUMAN",
        "nama_produk": "Es Teh Manis",
        "harga_jual": 3000,
        "stok": 15,
        "img":
            "https://images.unsplash.com/photo-1556679343-c7306c1976bc?q=80&w=1000",
        "isLocal": 0,
      },
      {
        "barcode": "8883",
        "cat": "SEMBAKO",
        "nama_produk": "Indomie Goreng",
        "harga_jual": 3500,
        "stok": 30,
        "img":
            "https://images.unsplash.com/photo-1591814448473-7f47c2153210?q=80&w=1000",
        "isLocal": 0,
      },
      {
        "barcode": "8884",
        "cat": "MINUMAN",
        "nama_produk": "Le Minerale 600ml",
        "harga_jual": 4000,
        "stok": 25,
        "img":
            "https://images.unsplash.com/photo-1548839140-29a749e1cf4d?q=80&w=1000",
        "isLocal": 0,
      },
    ];

    for (var item in initialProducts) {
      await db.insert('produk', item,
          conflictAlgorithm: ConflictAlgorithm.ignore);
    }
  }

  Future _createDB(Database db, int version) async {
    // 1. Tabel Produk
    await _createProdukTable(db);
    await db
        .execute('CREATE INDEX IF NOT EXISTS idx_barcode ON produk(barcode)');
    await _seedInitialProducts(db);

    // 2. Tabel Transaksi (Header)
    await db.execute('''
      CREATE TABLE transaksi (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tgl_transaksi TEXT NOT NULL,
        total_harga REAL NOT NULL,
        metode_bayar TEXT
      )
    ''');

    // 3. Tabel Detail Transaksi (Rincian barang per transaksi)
    await db.execute('''
      CREATE TABLE detail_transaksi (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        id_transaksi INTEGER NOT NULL,
        barcode TEXT NOT NULL,
        nama_produk TEXT NOT NULL,
        harga_satuan REAL NOT NULL,
        jumlah INTEGER NOT NULL,
        subtotal REAL NOT NULL,
        FOREIGN KEY (id_transaksi) REFERENCES transaksi (id) ON DELETE CASCADE
      )
    ''');
  }

  // --- FUNGSI UNTUK PRODUK ---
  Future<int> insertProduk(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert('produk', row,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getAllProduk() async {
    Database db = await instance.database;
    return await db.query('produk');
  }

  Future<Map<String, dynamic>?> getProdukByBarcode(String barcode) async {
    Database db = await instance.database;
    final List<Map<String, dynamic>> results = await db.query(
      'produk',
      where: 'barcode = ?',
      whereArgs: [barcode],
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<int> updateProduk(Map<String, dynamic> row) async {
    Database db = await instance.database;
    final id = row['id'] as int;
    return await db.update(
      'produk',
      row,
      where: 'id = ?',
      whereArgs: [id],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> deleteProduk(String barcode) async {
    Database db = await instance.database;
    return await db
        .delete('produk', where: 'barcode = ?', whereArgs: [barcode]);
  }

  Future<List<Map<String, dynamic>>> getAllTransaksi() async {
    Database db = await instance.database;
    return await db.query('transaksi', orderBy: 'id DESC');
  }

  Future<List<Map<String, dynamic>>> getDetailTransaksiByTransaksiId(
      int idTransaksi) async {
    Database db = await instance.database;
    return await db.query('detail_transaksi',
        where: 'id_transaksi = ?', whereArgs: [idTransaksi]);
  }

  Future<int> deleteTransaksi(int idTransaksi) async {
    Database db = await instance.database;
    return await db
        .delete('transaksi', where: 'id = ?', whereArgs: [idTransaksi]);
  }

  // --- FUNGSI UNTUK TRANSAKSI (SIMPAN DARI KERANJANG) ---
  Future<int> simpanTransaksi(double total, Map<String, dynamic> items) async {
    Database db = await instance.database;

    return await db.transaction((txn) async {
      // 1. Simpan ke tabel transaksi utama
      int idTransaksi = await txn.insert('transaksi', {
        'tgl_transaksi': DateTime.now().toIso8601String(),
        'total_harga': total,
        'metode_bayar': 'Tunai'
      });

      // 2. Simpan setiap item keranjang ke detail_transaksi
      for (var entry in items.entries) {
        String barcode = entry.key;
        var item = entry.value;
        await txn.insert('detail_transaksi', {
          'id_transaksi': idTransaksi,
          'barcode': barcode,
          'nama_produk': item.name,
          'harga_satuan': item.price,
          'jumlah': item.quantity,
          'subtotal': item.price * item.quantity,
        });

        // 3. Opsional: Kurangi stok di tabel produk
        await txn.execute(
          'UPDATE produk SET stok = stok - ? WHERE barcode = ?',
          [item.quantity, barcode],
        );
      }

      return idTransaksi;
    });
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }

  Future<Map<String, dynamic>> exportDatabaseToJson() async {
    final db = await instance.database;
    final products = await db.query('produk');
    final transactions = await db.query('transaksi');
    final details = await db.query('detail_transaksi');

    return {
      'backup_time': DateTime.now().toIso8601String(),
      'products': products,
      'transactions': transactions,
      'detail_transaksi': details,
    };
  }

  Future<void> restoreDatabaseFromJson(Map<String, dynamic> data) async {
    final db = await instance.database;

    final products = List<Map<String, dynamic>>.from(
      (data['products'] as List<dynamic>)
          .map((item) => Map<String, dynamic>.from(item as Map)),
    );
    final transactions = List<Map<String, dynamic>>.from(
      (data['transactions'] as List<dynamic>)
          .map((item) => Map<String, dynamic>.from(item as Map)),
    );
    final details = List<Map<String, dynamic>>.from(
      (data['detail_transaksi'] as List<dynamic>)
          .map((item) => Map<String, dynamic>.from(item as Map)),
    );

    await db.transaction((txn) async {
      await txn.delete('detail_transaksi');
      await txn.delete('transaksi');
      await txn.delete('produk');

      for (var product in products) {
        await txn.insert('produk', product,
            conflictAlgorithm: ConflictAlgorithm.replace);
      }

      for (var transaction in transactions) {
        await txn.insert('transaksi', transaction,
            conflictAlgorithm: ConflictAlgorithm.replace);
      }

      for (var detail in details) {
        await txn.insert('detail_transaksi', detail,
            conflictAlgorithm: ConflictAlgorithm.replace);
      }
    });
  }
}
