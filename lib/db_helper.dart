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
      version: 2,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      try {
        // Coba tambah kolom
        await db.execute('ALTER TABLE produk ADD COLUMN cat TEXT DEFAULT "SEMBAKO"');
      } catch (e) {
        // Jika kolom sudah ada atau error lain, rebuild table
        try {
          await db.execute('DROP TABLE IF EXISTS produk');
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
        } catch (rebuildError) {
          // Jika rebuild gagal, database mungkin ada error
          print('Error upgrading database: $rebuildError');
        }
      }
    }
  }

  Future _createDB(Database db, int version) async {
    // 1. Tabel Produk
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
    return await db.insert('produk', row, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getAllProduk() async {
    Database db = await instance.database;
    return await db.query('produk');
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
    return await db.delete('produk', where: 'barcode = ?', whereArgs: [barcode]);
  }

  // --- FUNGSI UNTUK TRANSAKSI (SIMPAN DARI KERANJANG) ---
  Future<void> simpanTransaksi(double total, Map<String, dynamic> items) async {
    Database db = await instance.database;

    await db.transaction((txn) async {
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
    });
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}