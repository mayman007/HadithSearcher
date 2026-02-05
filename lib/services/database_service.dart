import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/settings.dart';

/// Service for local SQLite database operations.
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
      version: 1,
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

    await db.execute('''
      CREATE TABLE settings (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        theme TEXT,
        colorscheme TEXT,
        fontfamily TEXT,
        fontweight TEXT,
        fontsize INTEGER,
        padding INTEGER
      )
    ''');

    // Insert default settings
    await db.insert('settings', {
      'theme': 'system',
      'colorscheme': 'blue',
      'fontfamily': 'Roboto',
      'fontweight': 'bold',
      'fontsize': 20,
      'padding': 10,
    });
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle migrations here if needed
  }

  // ==================== FAVOURITES ====================

  /// Get all favourite hadiths.
  Future<List<FavouriteHadith>> getFavourites() async {
    final db = await database;
    final results = await db.query(
      'favourites',
      orderBy: 'id DESC',
    );

    return results.map((row) => FavouriteHadith.fromDatabase(row)).toList();
  }

  /// Check if a hadith is in favourites.
  Future<bool> isFavourite(String hadithId) async {
    final db = await database;
    final results = await db.query(
      'favourites',
      where: 'hadithid = ?',
      whereArgs: [hadithId],
      limit: 1,
    );
    return results.isNotEmpty;
  }

  /// Add a hadith to favourites.
  Future<void> addFavourite({
    required String hadithId,
    required String hadithText,
    required String hadithInfo,
  }) async {
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
  }

  /// Remove a hadith from favourites.
  Future<void> removeFavourite(String hadithId) async {
    final db = await database;
    await db.delete(
      'favourites',
      where: 'hadithid = ?',
      whereArgs: [hadithId],
    );
  }

  /// Get all favourite hadith IDs (for bulk checking).
  Future<Set<String>> getFavouriteIds() async {
    final db = await database;
    final results = await db.query('favourites', columns: ['hadithid']);
    return results.map((row) => row['hadithid'] as String).toSet();
  }

  // ==================== SETTINGS ====================

  /// Get app settings.
  Future<AppSettings> getSettings() async {
    final db = await database;
    final results = await db.query('settings', where: 'id = 1');

    if (results.isEmpty) {
      return AppSettings.defaults;
    }

    return AppSettings.fromDatabase(results.first);
  }

  /// Get theme string (for initial app load before full settings).
  Future<String> getTheme() async {
    final db = await database;
    final results = await db.query(
      'settings',
      columns: ['theme'],
      where: 'id = 1',
    );

    if (results.isEmpty) {
      return 'system';
    }

    return results.first['theme'] as String? ?? 'system';
  }

  /// Update theme setting.
  Future<void> updateTheme(ThemePreference theme) async {
    final db = await database;
    await db.update(
      'settings',
      {'theme': theme.toDbString()},
      where: 'id = 1',
    );
  }

  /// Update color scheme setting.
  Future<void> updateColorScheme(ColorSchemePreference colorScheme) async {
    final db = await database;
    await db.update(
      'settings',
      {'colorscheme': colorScheme.toDbString()},
      where: 'id = 1',
    );
  }

  /// Update font family setting.
  Future<void> updateFontFamily(String fontFamily) async {
    final db = await database;
    await db.update(
      'settings',
      {'fontfamily': fontFamily},
      where: 'id = 1',
    );
  }

  /// Update font weight setting.
  Future<void> updateFontWeight(FontWeightPreference fontWeight) async {
    final db = await database;
    await db.update(
      'settings',
      {'fontweight': fontWeight.toDbString()},
      where: 'id = 1',
    );
  }

  /// Update font size setting.
  Future<void> updateFontSize(int fontSize) async {
    final db = await database;
    await db.update(
      'settings',
      {'fontsize': fontSize},
      where: 'id = 1',
    );
  }

  /// Update padding setting.
  Future<void> updatePadding(int padding) async {
    final db = await database;
    await db.update(
      'settings',
      {'padding': padding},
      where: 'id = 1',
    );
  }

  /// Reset all settings to defaults.
  Future<void> resetSettings() async {
    final db = await database;
    await db.update(
      'settings',
      {
        'theme': 'system',
        'colorscheme': 'blue',
        'fontfamily': 'Roboto',
        'fontweight': 'bold',
        'fontsize': 20,
        'padding': 10,
      },
      where: 'id = 1',
    );
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
