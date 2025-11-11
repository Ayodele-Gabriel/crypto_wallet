import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api_client/api.dart';
import '../model/coin_detail_model.dart';
import '../model/coin_model.dart';
import '../repo/coin_repository.dart';
import '../utilities/coin_local_service.dart';
import '../utilities/connectivity.dart';

// Services
final apiServiceProvider = Provider((ref) => CoinApiService());
final localServiceProvider = Provider((ref) => CoinLocalService());
final connectivityServiceProvider = Provider((ref) => ConnectivityService());

// Repository
final coinRepositoryProvider = Provider((ref) {
  return CoinRepository(
    apiService: ref.watch(apiServiceProvider),
    localService: ref.watch(localServiceProvider),
  );
});

// Connectivity
final connectivityProvider = StreamProvider<bool>((ref) {
  final service = ref.watch(connectivityServiceProvider);
  return service.connectionStatus;
});

// Coins List State
class CoinsState {
  final List<CoinModel> coins;
  final bool isLoading;
  final String? error;
  final DateTime? lastUpdated;

  CoinsState({
    this.coins = const [],
    this.isLoading = false,
    this.error,
    this.lastUpdated,
  });

  CoinsState copyWith({
    List<CoinModel>? coins,
    bool? isLoading,
    String? error,
    DateTime? lastUpdated,
  }) {
    return CoinsState(
      coins: coins ?? this.coins,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

class CoinsNotifier extends StateNotifier<CoinsState> {
  final CoinRepository repository;

  CoinsNotifier(this.repository) : super(CoinsState()) {
    loadCoins();
  }

  Future<void> loadCoins({bool forceRefresh = false}) async {
    if (!forceRefresh && state.coins.isNotEmpty) {
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final coins = await repository.getCoins(forceRefresh: forceRefresh);
      state = state.copyWith(
        coins: coins,
        isLoading: false,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> refresh() async {
    await loadCoins(forceRefresh: true);
  }
}

final coinsProvider = StateNotifierProvider<CoinsNotifier, CoinsState>((ref) {
  return CoinsNotifier(ref.watch(coinRepositoryProvider));
});

// Coin Detail State
class CoinDetailState {
  final CoinDetailModel? detail;
  final List<PricePoint> chartData;
  final bool isLoading;
  final bool isLoadingChart;
  final String? error;

  CoinDetailState({
    this.detail,
    this.chartData = const [],
    this.isLoading = false,
    this.isLoadingChart = false,
    this.error,
  });

  CoinDetailState copyWith({
    CoinDetailModel? detail,
    List<PricePoint>? chartData,
    bool? isLoading,
    bool? isLoadingChart,
    String? error,
  }) {
    return CoinDetailState(
      detail: detail ?? this.detail,
      chartData: chartData ?? this.chartData,
      isLoading: isLoading ?? this.isLoading,
      isLoadingChart: isLoadingChart ?? this.isLoadingChart,
      error: error,
    );
  }
}

class CoinDetailNotifier extends StateNotifier<CoinDetailState> {
  final CoinRepository repository;
  final String coinId;

  CoinDetailNotifier(this.repository, this.coinId) : super(CoinDetailState()) {
    loadCoinDetail();
    loadChartData();
  }

  Future<void> loadCoinDetail() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final detail = await repository.getCoinDetail(coinId);
      state = state.copyWith(detail: detail, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadChartData({bool forceRefresh = false}) async {
    state = state.copyWith(isLoadingChart: true);

    try {
      final chartData = await repository.getCoinChart(coinId, forceRefresh: forceRefresh);
      state = state.copyWith(chartData: chartData, isLoadingChart: false);
    } catch (e) {
      state = state.copyWith(isLoadingChart: false);
    }
  }
}

final coinDetailProvider = StateNotifierProvider.family<CoinDetailNotifier, CoinDetailState, String>((ref, coinId) {
  return CoinDetailNotifier(ref.watch(coinRepositoryProvider), coinId);
});

// Favorites
class FavoritesNotifier extends StateNotifier<List<String>> {
  final CoinRepository repository;

  FavoritesNotifier(this.repository) : super([]) {
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    state = await repository.getFavorites();
  }

  Future<void> toggleFavorite(String coinId) async {
    if (state.contains(coinId)) {
      await repository.removeFavorite(coinId);
      state = state.where((id) => id != coinId).toList();
    } else {
      await repository.addFavorite(coinId);
      state = [...state, coinId];
    }
  }

  bool isFavorite(String coinId) {
    return state.contains(coinId);
  }
}

final favoritesProvider = StateNotifierProvider<FavoritesNotifier, List<String>>((ref) {
  return FavoritesNotifier(ref.watch(coinRepositoryProvider));
});

// Search
final searchQueryProvider = StateProvider<String>((ref) => '');

final filteredCoinsProvider = Provider<List<CoinModel>>((ref) {
  final coins = ref.watch(coinsProvider).coins;
  final query = ref.watch(searchQueryProvider).toLowerCase();

  if (query.isEmpty) {
    return coins;
  }

  return coins.where((coin) {
    return coin.name.toLowerCase().contains(query) ||
        coin.symbol.toLowerCase().contains(query);
  }).toList();
});