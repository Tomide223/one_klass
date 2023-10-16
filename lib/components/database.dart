import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class Attendance {
  final int? id;
  final String type;
  final String packet;

  const Attendance({required this.type, required this.packet, this.id});

  factory Attendance.fromJson(Map<String, dynamic> json) =>
      Attendance(id: json['id'], type: json['type'], packet: json['packet']);

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'packet': packet,
      };
}

class DatabaseAttendance {
  static const int _version = 1;
  static const String _dbname = 'Attendance.db';

  static Future<Database> _getDB() async {
    return openDatabase(join(await getDatabasesPath(), _dbname),
        onCreate: (db, version) async => await db.execute(
              "CREATE TABLE Attend_table (id INTEGER PRIMARY KEY AUTOINCREMENT, type TEXT NOT NULL, packet TEXT NOT NULL)",
            ),
        version: _version);
  }

  static Future<int> addAttendance(Attendance attendance) async {
    final db = await _getDB();
    return await db.insert('Attend_table', attendance.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<int> updateAttendance(Attendance cache) async {
    final db = await _getDB();
    return await db.update('Attend_table', cache.toJson(),
        where: 'id = ?',
        whereArgs: [cache.id],
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<int> deleteAttendance(Attendance cache) async {
    final db = await _getDB();
    return await db.delete(
      'Attend_table',
      where: 'id = ?',
      whereArgs: [cache.id],
    );
  }

  static Future<List<Attendance>?> getAllAttendance() async {
    final db = await _getDB();
    final List<Map<String, dynamic>> maps = await db.query('Attend_table');

    if (maps.isEmpty) {
      print(maps);
      return null;
    }
    print(maps);
    return List.generate(
        maps.length, (index) => Attendance.fromJson(maps[index]));
  }

  static Future<List<Attendance>?> getAttendance() async {
    final db = await _getDB();
    final List<Map<String, dynamic>> maps = await db
        .query("Attend_table", where: 'type =?', whereArgs: ['attendance']);

    if (maps.isEmpty) {
      print(maps);
      return null;
    }
    print(maps);
    return List.generate(
        maps.length, (index) => Attendance.fromJson(maps[index]));
  }
// static Future<List<Attendance>?> getTimeAttendance() async {
//   final db = await _getDB();
//   final List<Map<String, dynamic>> maps =
//   await db.query("Attend_table", where: 'type =?', whereArgs: ['time']);
//
//   if (maps.isEmpty) {
//     // print(maps);
//     return null;
//   }
//   // print(maps);
//   return List.generate(maps.length, (index) => Attendance.fromJson(maps[index]));
// }
}
