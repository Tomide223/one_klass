import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class Cache {
  int id;
  String type;
  String packet;

  Cache({required this.id, required this.type, required this.packet});
}

class DatabaseCache {
  static Database? _cacheAbles;

  // Create and open the database.
  static Future<Database> _openDatabase() async {
    if (_cacheAbles == null) {
      String dbPath = await getDatabasesPath();
      String path = join(dbPath, 'my_database.db');

      _cacheAbles = await openDatabase(path, version: 1, onCreate: _onCreate);
    }
    return _cacheAbles!;
  }

  // Create the database table.
  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE my_table (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT,
        packet TEXT,
      )
    ''');
  }

  // Insert data into the database.
  static Future<int> insertData(String type, String packet) async {
    Database db = await _openDatabase();
    Map<String, dynamic> row = {
      'type': type,
      'packet': packet,
    };
    return await db.insert('my_table', row);
  }

  Future<void> deleteItem(int id) async {
    Database db = await _openDatabase();
    await db.delete(
      'my_table',
      where: null,
    );
  }

  static Future<int> updateItem(String type, String packet) async {
    Database db = await _openDatabase();
    Map<String, dynamic> row = {
      'type': type,
      'packet': packet,
    };
    return await db.update('my_table', row);
  }

  Future<List<Cache>> getItems() async {
    Database db = await _openDatabase();
    List<Map<String, dynamic>> items = await db.query('my_table');
    return items
        .map((item) =>
            Cache(id: item['id'], type: item['type'], packet: item['packet']))
        .toList();
  }

  // Query all data from the database.
  static Future<List<Map<String, dynamic>>> queryAllData() async {
    Database db = await _openDatabase();
    return await db.query('my_table');
  }
}
// void _loadData() async {
//   List<Item> items = await DatabaseHelper().getItems();
//   setState(() {
//     _items = items;
//   });
// }
//
// void _deleteItem(int id) async {
//   await DatabaseHelper().deleteItem(id);
//   _loadData();
// }
