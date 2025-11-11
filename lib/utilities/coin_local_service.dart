import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../model/coin_detail_model.dart';
import '../model/coin_model.dart';
import 'app_constants.dart';

class CoinLocalService {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, AppConstants.databaseName);

    return await openDatabase(
      path,
      version: AppConstants.databaseVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Coins table
    await db.execute('''
      CREATE TABLE ${AppConstants.coinsTable} (
        id TEXT PRIMARY KEY,
        symbol TEXT NOT NULL,
        name TEXT NOT NULL,
        image TEXT NOT NULL,
        current_price REAL NOT NULL,
        market_cap REAL,
        market_cap_rank INTEGER,
        total_volume REAL,
        price_change_percentage_24h REAL,
        high_24h REAL,
        low_24h REAL,
        last_updated INTEGER,
        cached_at INTEGER NOT NULL
      )
    ''');

    // Favorites table
    await db.execute('''
      CREATE TABLE ${AppConstants.favoritesTable} (
        coin_id TEXT PRIMARY KEY,
        added_at INTEGER NOT NULL
      )
    ''');

    // Chart data table
    await db.execute('''
      CREATE TABLE ${AppConstants.chartDataTable} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        coin_id TEXT NOT NULL,
        timestamp INTEGER NOT NULL,
        price REAL NOT NULL,
        cached_at INTEGER NOT NULL,
        UNIQUE(coin_id, timestamp)
      )
    ''');

    // Create indexes
    await db.execute('CREATE INDEX idx_coin_symbol ON ${AppConstants.coinsTable}(symbol)');
    await db.execute('CREATE INDEX idx_coin_rank ON ${AppConstants.coinsTable}(market_cap_rank)');
    await db.execute('CREATE INDEX idx_chart_coin_id ON ${AppConstants.chartDataTable}(coin_id)');
  }

  // Coins CRUD
  Future<void> insertCoins(List<CoinModel> coins) async {
    final db = await database;
    final batch = db.batch();
    final now = DateTime.now().millisecondsSinceEpoch;

    for (final coin in coins) {
      final data = coin.toDatabase();
      data['cached_at'] = now;
      batch.insert(
        AppConstants.coinsTable,
        data,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  Future<List<CoinModel>> getCoins() async {
    final db = await database;
    final maps = await db.query(
      AppConstants.coinsTable,
      orderBy: 'market_cap_rank ASC',
    );
    return maps.map((map) => CoinModel.fromDatabase(map)).toList();
  }

  Future<CoinModel?> getCoinById(String id) async {
    final db = await database;
    final maps = await db.query(
      AppConstants.coinsTable,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isEmpty) return null;
    return CoinModel.fromDatabase(maps.first);
  }

  Future<bool> isCoinsCacheValid() async {
    final db = await database;
    final result = await db.query(
      AppConstants.coinsTable,
      columns: ['cached_at'],
      limit: 1,
    );

    if (result.isEmpty) return false;

    final cachedAt = result.first['cached_at'] as int;
    final now = DateTime.now().millisecondsSinceEpoch;
    final cacheAge = now - cachedAt;

    return cacheAge < AppConstants.cacheDuration.inMilliseconds;
  }

  // Favorites CRUD
  Future<void> addFavorite(String coinId) async {
    final db = await database;
    await db.insert(
      AppConstants.favoritesTable,
      {
        'coin_id': coinId,
        'added_at': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> removeFavorite(String coinId) async {
    final db = await database;
    await db.delete(
      AppConstants.favoritesTable,
      where: 'coin_id = ?',
      whereArgs: [coinId],
    );
  }

  Future<List<String>> getFavorites() async {
    final db = await database;
    final maps = await db.query(
      AppConstants.favoritesTable,
      orderBy: 'added_at DESC',
    );
    return maps.map((map) => map['coin_id'] as String).toList();
  }

  Future<bool> isFavorite(String coinId) async {
    final db = await database;
    final result = await db.query(
      AppConstants.favoritesTable,
      where: 'coin_id = ?',
      whereArgs: [coinId],
      limit: 1,
    );
    return result.isNotEmpty;
  }

  // Chart data CRUD
  Future<void> insertChartData(String coinId, List<PricePoint> data) async {
    final db = await database;
    final batch = db.batch();
    final now = DateTime.now().millisecondsSinceEpoch;

    // Delete old data for this coin
    batch.delete(
      AppConstants.chartDataTable,
      where: 'coin_id = ?',
      whereArgs: [coinId],
    );

    // Insert new data
    for (final point in data) {
      batch.insert(
        AppConstants.chartDataTable,
        {
          'coin_id': coinId,
          'timestamp': point.timestamp.millisecondsSinceEpoch,
          'price': point.price,
          'cached_at': now,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  Future<List<PricePoint>> getChartData(String coinId) async {
    final db = await database;
    final maps = await db.query(
      AppConstants.chartDataTable,
      where: 'coin_id = ?',
      whereArgs: [coinId],
      orderBy: 'timestamp ASC',
    );

    return maps.map((map) {
      return PricePoint(
        timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
        price: (map['price'] as num).toDouble(),
      );
    }).toList();
  }

  Future<bool> isChartCacheValid(String coinId) async {
    final db = await database;
    final result = await db.query(
      AppConstants.chartDataTable,
      columns: ['cached_at'],
      where: 'coin_id = ?',
      whereArgs: [coinId],
      limit: 1,
    );

    if (result.isEmpty) return false;

    final cachedAt = result.first['cached_at'] as int;
    final now = DateTime.now().millisecondsSinceEpoch;
    final cacheAge = now - cachedAt;

    return cacheAge < AppConstants.chartCacheDuration.inMilliseconds;
  }

  // Clear all cache
  Future<void> clearCache() async {
    final db = await database;
    await db.delete(AppConstants.coinsTable);
    await db.delete(AppConstants.chartDataTable);
  }

  // Clear old cache (older than 1 day)
  Future<void> clearOldCache() async {
    final db = await database;
    final oneDayAgo = DateTime.now().subtract(const Duration(days: 1)).millisecondsSinceEpoch;

    await db.delete(
      AppConstants.coinsTable,
      where: 'cached_at < ?',
      whereArgs: [oneDayAgo],
    );

    await db.delete(
      AppConstants.chartDataTable,
      where: 'cached_at < ?',
      whereArgs: [oneDayAgo],
    );
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}