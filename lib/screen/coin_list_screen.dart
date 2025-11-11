import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../provider/provider.dart';
import '../utilities/widgets/error/error_screen.dart';
import '../utilities/widgets/error/error_state.dart';
import '../utilities/widgets/loader.dart';
import '../utilities/widgets/coin_card.dart';
import 'coin_detail_screen.dart';
import 'favorites_screen.dart';

class CoinsListScreen extends ConsumerStatefulWidget {
  const CoinsListScreen({super.key});

  @override
  ConsumerState<CoinsListScreen> createState() => _CoinsListScreenState();
}

class _CoinsListScreenState extends ConsumerState<CoinsListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final coinsState = ref.watch(coinsProvider);
    final filteredCoins = ref.watch(filteredCoinsProvider);
    final connectivity = ref.watch(connectivityProvider);
    final searchQuery = ref.watch(searchQueryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crypto Wallet'),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FavoritesScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: coinsState.isLoading
                ? null
                : () => ref.read(coinsProvider.notifier).refresh(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Offline banner
          connectivity.when(
            data: (isConnected) => !isConnected
                ? Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              color: Colors.orange,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.wifi_off, color: Colors.white, size: 16),
                  SizedBox(width: 8),
                  Text(
                    'Offline - Showing cached data',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            )
                : const SizedBox.shrink(),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),

          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search coins...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    ref.read(searchQueryProvider.notifier).state = '';
                  },
                )
                    : null,
              ),
              onChanged: (value) {
                ref.read(searchQueryProvider.notifier).state = value;
              },
            ),
          ),

          // Content
          Expanded(
            child: _buildContent(coinsState, filteredCoins, searchQuery),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(CoinsState state, List coins, String searchQuery) {
    if (state.isLoading && state.coins.isEmpty) {
      return const LoadingShimmer();
    }

    if (state.error != null && state.coins.isEmpty) {
      return ErrorView(
        message: state.error!,
        onRetry: () => ref.read(coinsProvider.notifier).refresh(),
      );
    }

    if (coins.isEmpty && searchQuery.isNotEmpty) {
      return const EmptyState(
        icon: Icons.search_off,
        message: 'No coins found matching your search',
      );
    }

    if (coins.isEmpty) {
      return const EmptyState(
        icon: Icons.currency_bitcoin,
        message: 'No coins available',
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(coinsProvider.notifier).refresh(),
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 16),
        itemCount: coins.length,
        itemBuilder: (context, index) {
          final coin = coins[index];
          return CoinCard(
            coin: coin,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CoinDetailScreen(coinId: coin.id),
                ),
              );
            },
          );
        },
      ),
    );
  }
}