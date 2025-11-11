import 'package:crypto_wallet/screen/price_chart_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../provider/provider.dart';
import '../utilities/widgets/error/error_screen.dart';
import '../utilities/widgets/loader.dart';

class CoinDetailScreen extends ConsumerWidget {
  final String coinId;

  const CoinDetailScreen({super.key, required this.coinId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailState = ref.watch(coinDetailProvider(coinId));
    final favorites = ref.watch(favoritesProvider);
    final isFavorite = favorites.contains(coinId);

    return Scaffold(
      appBar: AppBar(
        title: Text(detailState.detail?.name ?? 'Loading...'),
        actions: [
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.red : null,
            ),
            onPressed: () {
              ref.read(favoritesProvider.notifier).toggleFavorite(coinId);
            },
          ),
        ],
      ),
      body: _buildBody(context, detailState, ref),
    );
  }

  Widget _buildBody(BuildContext context, CoinDetailState state, WidgetRef ref) {
    if (state.isLoading && state.detail == null) {
      return const LoadingShimmer();
    }

    if (state.error != null && state.detail == null) {
      return ErrorView(
        message: state.error!,
        onRetry: () => ref.read(coinDetailProvider(coinId).notifier).loadCoinDetail(),
      );
    }

    final detail = state.detail;
    if (detail == null) {
      return const Center(child: Text('No data available'));
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(coinDetailProvider(coinId).notifier).loadCoinDetail();
        await ref.read(coinDetailProvider(coinId).notifier).loadChartData(forceRefresh: true);
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(detail),
            const SizedBox(height: 24),
            _buildPriceChart(state),
            const SizedBox(height: 24),
            _buildStatistics(detail),
            const SizedBox(height: 24),
            _buildPriceChanges(detail),
            const SizedBox(height: 24),
            _buildSupplyInfo(detail),
            if (detail.description != null && detail.description!.isNotEmpty) ...[
              const SizedBox(height: 24),
              _buildDescription(detail.description!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(detail) {
    final priceChange = detail.priceChangePercentage24h ?? 0;
    final isPositive = priceChange >= 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                if (detail.image.isNotEmpty)
                  Image.network(detail.image, width: 48, height: 48),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        detail.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        detail.symbol,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Current Price',
                      style: TextStyle(color: Colors.grey),
                    ),
                    Text(
                      '\$${NumberFormat('#,##0.00').format(detail.currentPrice)}',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isPositive ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${isPositive ? '+' : ''}${priceChange.toStringAsFixed(2)}%',
                    style: TextStyle(
                      color: isPositive ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceChart(CoinDetailState state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '7 Day Price Chart',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (state.isLoadingChart)
              const Center(child: CircularProgressIndicator())
            else if (state.chartData.isEmpty)
              const Center(child: Text('No chart data available'))
            else
              SizedBox(
                height: 200,
                child: PriceChart(data: state.chartData),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatistics(detail) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Market Statistics',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildStatRow('Market Cap', detail.marketCap != null
                ? '\$${NumberFormat('#,##0').format(detail.marketCap)}'
                : 'N/A'),
            _buildStatRow('Market Cap Rank', detail.marketCapRank?.toString() ?? 'N/A'),
            _buildStatRow('24h Volume', detail.totalVolume != null
                ? '\$${NumberFormat('#,##0').format(detail.totalVolume)}'
                : 'N/A'),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceChanges(detail) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Price Changes',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildChangeRow('24 Hours', detail.priceChangePercentage24h),
            _buildChangeRow('7 Days', detail.priceChangePercentage7d),
            _buildChangeRow('30 Days', detail.priceChangePercentage30d),
          ],
        ),
      ),
    );
  }

  Widget _buildSupplyInfo(detail) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Supply Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildStatRow('Circulating Supply', detail.circulatingSupply != null
                ? NumberFormat('#,##0').format(detail.circulatingSupply)
                : 'N/A'),
            _buildStatRow('Total Supply', detail.totalSupply != null
                ? NumberFormat('#,##0').format(detail.totalSupply)
                : 'N/A'),
            _buildStatRow('Max Supply', detail.maxSupply != null
                ? NumberFormat('#,##0').format(detail.maxSupply)
                : '∞'),
          ],
        ),
      ),
    );
  }

  Widget _buildDescription(String description) {
    final cleanDesc = description.replaceAll(RegExp(r'<[^>]*>'), '').trim();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'About',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              cleanDesc.length > 500 ? '${cleanDesc.substring(0, 500)}...' : cleanDesc,
              style: const TextStyle(height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildChangeRow(String label, double? value) {
    if (value == null) {
      return _buildStatRow(label, 'N/A');
    }
    final isPositive = value >= 0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(
            '${isPositive ? '+' : ''}${value.toStringAsFixed(2)}%',
            style: TextStyle(
              color: isPositive ? Colors.green : Colors.red,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}






