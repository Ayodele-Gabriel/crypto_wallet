import '../api_client/api.dart';
import '../model/coin_detail_model.dart';
import '../model/coin_model.dart';
import '../utilities/coin_local_service.dart';

class CoinRepository {
  final CoinApiService _apiService;
  final CoinLocalService _localService;

  CoinRepository({
    required CoinApiService apiService,
    required CoinLocalService localService,
  })  : _apiService = apiService,
        _localService = localService;

  /// Fetches coins from API or cache
  Future<List<CoinModel>> getCoins({bool forceRefresh = false}) async {
    try {
      // Check if cache is valid
      if (!forceRefresh) {
        final isCacheValid = await _localService.isCoinsCacheValid();
        if (isCacheValid) {
          final cachedCoins = await _localService.getCoins();
          if (cachedCoins.isNotEmpty) {
            return cachedCoins;
          }
        }
      }

      // Fetch from API
      final coins = await _apiService.fetchCoins();

      // Save to cache
      await _localService.insertCoins(coins);

      return coins;
    } catch (e) {
      // If API fails, try to return cached data
      final cachedCoins = await _localService.getCoins();
      if (cachedCoins.isNotEmpty) {
        return cachedCoins;
      }
      rethrow;
    }
  }

  /// Fetches a single coin by ID
  Future<CoinModel?> getCoinById(String id) async {
    try {
      // Try cache first
      final cachedCoin = await _localService.getCoinById(id);
      if (cachedCoin != null) {
        return cachedCoin;
      }

      // If not in cache, fetch all coins
      await getCoins(forceRefresh: true);
      return await _localService.getCoinById(id);
    } catch (e) {
      rethrow;
    }
  }

  /// Fetches detailed coin information
  Future<CoinDetailModel> getCoinDetail(String coinId) async {
    try {
      return await _apiService.fetchCoinDetail(coinId);
    } catch (e) {
      rethrow;
    }
  }

  /// Fetches chart data for a coin
  Future<List<PricePoint>> getCoinChart(String coinId, {bool forceRefresh = false}) async {
    try {
      // Check if cache is valid
      if (!forceRefresh) {
        final isCacheValid = await _localService.isChartCacheValid(coinId);
        if (isCacheValid) {
          final cachedData = await _localService.getChartData(coinId);
          if (cachedData.isNotEmpty) {
            return cachedData;
          }
        }
      }

      // Fetch from API
      final chartData = await _apiService.fetchCoinChart(coinId);

      // Save to cache
      await _localService.insertChartData(coinId, chartData);

      return chartData;
    } catch (e) {
      // If API fails, try to return cached data
      final cachedData = await _localService.getChartData(coinId);
      if (cachedData.isNotEmpty) {
        return cachedData;
      }
      rethrow;
    }
  }

  /// Favorites management
  Future<void> addFavorite(String coinId) async {
    await _localService.addFavorite(coinId);
  }

  Future<void> removeFavorite(String coinId) async {
    await _localService.removeFavorite(coinId);
  }

  Future<List<String>> getFavorites() async {
    return await _localService.getFavorites();
  }

  Future<bool> isFavorite(String coinId) async {
    return await _localService.isFavorite(coinId);
  }

  Future<List<CoinModel>> getFavoriteCoins() async {
    final favoriteIds = await getFavorites();
    final allCoins = await getCoins();
    return allCoins.where((coin) => favoriteIds.contains(coin.id)).toList();
  }

  /// Clear cache
  Future<void> clearCache() async {
    await _localService.clearCache();
  }

  /// Clear old cache
  Future<void> clearOldCache() async {
    await _localService.clearOldCache();
  }
}