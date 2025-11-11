import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../provider/provider.dart';
import '../utilities/widgets/coin_card.dart';
import '../utilities/widgets/error/error_state.dart';
import 'coin_detail_screen.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesProvider);
    final allCoins = ref.watch(coinsProvider).coins;
    final favoriteCoins = allCoins.where((coin) => favorites.contains(coin.id)).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
      ),
      body: favoriteCoins.isEmpty
          ? const EmptyState(
        icon: Icons.favorite_border,
        message: 'No favorites yet\nTap the favorite icon to add coins',
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: favoriteCoins.length,
        itemBuilder: (context, index) {
          final coin = favoriteCoins[index];
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
