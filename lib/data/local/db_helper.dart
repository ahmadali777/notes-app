import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  Database? _myDB;

  /// Singleton instance
  static final DBHelper getInstance = DBHelper._();

  DBHelper._();

  final String TABLE_NOTE = 'NOTE';
  final String COLUMN_NOTE_SNO = 'S_NO';
  final String COLUMN_NOTE_TITLE = 'TITLE';    
  final String COLUMN_NOTE_DESC = 'DESC';

  Future<Database> get db async {
    if (_myDB != null) {
      return _myDB!;
    }
    _myDB = await openDB();
    return _myDB!;
  }

  Future<Database> openDB() async {
    Directory appDir = await getApplicationDocumentsDirectory();
    String dbpath = join(appDir.path, 'note.db');
    print(dbpath);
    return await openDatabase(dbpath, onCreate: (db, version) {
      db.execute('''
        CREATE TABLE $TABLE_NOTE (
          $COLUMN_NOTE_SNO INTEGER PRIMARY KEY AUTOINCREMENT,
          $COLUMN_NOTE_TITLE TEXT,
          $COLUMN_NOTE_DESC TEXT
        )
      ''');
    }, version: 1);
  }

  Future<bool> addNote({required String title, required String desc}) async {
    var dbClient = await db;
    int rowsEffected = await dbClient.insert(TABLE_NOTE, {
      COLUMN_NOTE_TITLE: title,
      COLUMN_NOTE_DESC: desc
    });
    return rowsEffected > 0;
  }

  Future<List<Map<String, dynamic>>> getAllNotes() async {
    var dbClient = await db;
    return await dbClient.query(TABLE_NOTE);
  }

  Future<bool> deleteNoteBySNo(int sNo) async {
    var dbClient = await db;
    int rowsEffected = await dbClient.delete(TABLE_NOTE,
        where: '$COLUMN_NOTE_SNO = ?', whereArgs: [sNo]);
    return rowsEffected > 0;
  }

  Future<bool> updateNoteBySNo(
      {required int sNo, required String title, required String desc}) async {
    var dbClient = await db;
    int rowsEffected = await dbClient.update(TABLE_NOTE, {
      COLUMN_NOTE_TITLE: title,
      COLUMN_NOTE_DESC: desc
    }, where: '$COLUMN_NOTE_SNO = ?', whereArgs: [sNo]);
    return rowsEffected > 0;
  }

}
