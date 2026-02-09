import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// Service for local SQLite database operations (favourites only).
class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _db;

  /// Get database instance, initializing if needed.
  Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  /// Initialize the database.
  Future<Database> _initDb() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'hadithsearcher.db');

    return openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE favourites (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        hadithtext TEXT NOT NULL,
        hadithinfo TEXT NOT NULL,
        hadithid TEXT NOT NULL UNIQUE
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Drop settings table if upgrading from version 1
    if (oldVersion < 2) {
      await db.execute('DROP TABLE IF EXISTS settings');
    }
  }

  // ==================== FAVOURITES ====================

  /// Get all favourite hadiths.
  Future<List<FavouriteHadith>> getFavourites() async {
    try {
      final db = await database;
      final results = await db.query(
        'favourites',
        orderBy: 'id DESC',
      );

      return results.map((row) => FavouriteHadith.fromDatabase(row)).toList();
    } catch (e) {
      // Return empty list on error to prevent crashes
      return [];
    }
  }

  /// Check if a hadith is in favourites.
  Future<bool> isFavourite(String hadithId) async {
    try {
      final db = await database;
      final results = await db.query(
        'favourites',
        where: 'hadithid = ?',
        whereArgs: [hadithId],
        limit: 1,
      );
      return results.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Add a hadith to favourites.
  Future<bool> addFavourite({
    required String hadithId,
    required String hadithText,
    required String hadithInfo,
  }) async {
    try {
      final db = await database;
      await db.insert(
        'favourites',
        {
          'hadithid': hadithId,
          'hadithtext': hadithText,
          'hadithinfo': hadithInfo,
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Remove a hadith from favourites.
  Future<bool> removeFavourite(String hadithId) async {
    try {
      final db = await database;
      await db.delete(
        'favourites',
        where: 'hadithid = ?',
        whereArgs: [hadithId],
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get all favourite hadith IDs (for bulk checking).
  Future<Set<String>> getFavouriteIds() async {
    try {
      final db = await database;
      final results = await db.query('favourites', columns: ['hadithid']);
      return results.map((row) => row['hadithid'] as String).toSet();
    } catch (e) {
      return {};
    }
  }
}

/// Favourite hadith with stored text and info.
class FavouriteHadith {
  final int id;
  final String hadithId;
  final String hadithText;
  final String hadithInfo;

  const FavouriteHadith({
    required this.id,
    required this.hadithId,
    required this.hadithText,
    required this.hadithInfo,
  });

  factory FavouriteHadith.fromDatabase(Map<String, dynamic> row) {
    return FavouriteHadith(
      id: row['id'] as int,
      hadithId: row['hadithid'] as String,
      hadithText: row['hadithtext'] as String,
      hadithInfo: row['hadithinfo'] as String,
    );
  }

  /// Full text for display.
  String get displayText => '$hadithText\n\n$hadithInfo';

  /// Full text for sharing.
  String get shareText => '$hadithText\n\n$hadithInfo';
}
