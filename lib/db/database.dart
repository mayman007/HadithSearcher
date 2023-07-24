import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static Database? _db;
  Future<Database?> get db async {
    if (_db == null) {
      _db = await initialDb();
      return _db;
    } else {
      return _db;
    }
  }

  initialDb() async {
    String databasePath = await getDatabasesPath();
    String path = join(databasePath, 'hadithsearcher.db');
    Database myDb = await openDatabase(path,
        onCreate: _onCreate, version: 1, onUpgrade: _onUpgrade);
    return myDb;
  }

  _onUpgrade(Database db, int oldVersion, int newVersion) {}

  _onCreate(Database db, int version) async {
    await db.execute('''
    CREATE TABLE 'favourites' (
      'id' INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
      'hadithtext' TEXT NOT NULL UNIQUE,
      'hadithinfo' TEXT NOT NULL UNIQUE,
      'hadithid' TEXT NOT NULL UNIQUE
    )
''');
    await db.execute('''
    CREATE TABLE 'settings' (
      'id' INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
      'theme' TEXT,
      'fontfamily' TEXT,
      'fontweight' TEXT,
      'fontsize' INTEGER,
      'padding' INTEGER
    )
''');
    await db.rawInsert(
        "INSERT INTO 'settings' ('theme', 'fontfamily', 'fontweight', 'fontsize', 'padding') VALUES ('system', 'Roboto', 'bold', 20, 10)");
  }

  selectData(String sql) async {
    Database? myDb = await db;
    List<Map<String, Object?>>? response = await myDb?.rawQuery(sql);
    return response;
  }

  insertData(String sql) async {
    Database? myDb = await db;
    int? response = await myDb?.rawInsert(sql);
    return response;
  }

  updateData(String sql) async {
    Database? myDb = await db;
    int? response = await myDb?.rawUpdate(sql);
    return response;
  }

  deleteData(String sql) async {
    Database? myDb = await db;
    int? response = await myDb?.rawDelete(sql);
    return response;
  }

  getTheme() async {
    Database? myDb = await db;
    final result =
        await myDb?.rawQuery("SELECT * FROM 'settings' WHERE id = 1");
    try {
      if (result!.isNotEmpty) {
        return result.first['theme'] as String;
      } else {
        // Return a default theme in case no theme is stored in the database yet.
        return 'system';
      }
    } catch (e) {
      return 'system';
    }
  }
}
