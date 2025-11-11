class CoinDetailModel {
  final String id;
  final String symbol;
  final String name;
  final String image;
  final double currentPrice;
  final double? marketCap;
  final int? marketCapRank;
  final double? totalVolume;
  final double? circulatingSupply;
  final double? totalSupply;
  final double? maxSupply;
  final double? athPrice;
  final double? athChangePercentage;
  final DateTime? athDate;
  final double? atlPrice;
  final double? atlChangePercentage;
  final DateTime? atlDate;
  final double? priceChangePercentage24h;
  final double? priceChangePercentage7d;
  final double? priceChangePercentage30d;
  final String? description;
  final List<PricePoint>? sparklineData;

  CoinDetailModel({
    required this.id,
    required this.symbol,
    required this.name,
    required this.image,
    required this.currentPrice,
    this.marketCap,
    this.marketCapRank,
    this.totalVolume,
    this.circulatingSupply,
    this.totalSupply,
    this.maxSupply,
    this.athPrice,
    this.athChangePercentage,
    this.athDate,
    this.atlPrice,
    this.atlChangePercentage,
    this.atlDate,
    this.priceChangePercentage24h,
    this.priceChangePercentage7d,
    this.priceChangePercentage30d,
    this.description,
    this.sparklineData,
  });

  factory CoinDetailModel.fromJson(Map<String, dynamic> json) {
    final marketData = json['market_data'] as Map<String, dynamic>?;

    return CoinDetailModel(
      id: json['id'] as String,
      symbol: (json['symbol'] as String).toUpperCase(),
      name: json['name'] as String,
      image: json['image']?['large'] as String? ?? '',
      currentPrice: marketData?['current_price']?['usd'] != null
          ? (marketData!['current_price']['usd'] as num).toDouble()
          : 0.0,
      marketCap: marketData?['market_cap']?['usd'] != null
          ? (marketData!['market_cap']['usd'] as num).toDouble()
          : null,
      marketCapRank: marketData?['market_cap_rank'] as int?,
      totalVolume: marketData?['total_volume']?['usd'] != null
          ? (marketData!['total_volume']['usd'] as num).toDouble()
          : null,
      circulatingSupply: marketData?['circulating_supply'] != null
          ? (marketData!['circulating_supply'] as num).toDouble()
          : null,
      totalSupply: marketData?['total_supply'] != null
          ? (marketData!['total_supply'] as num).toDouble()
          : null,
      maxSupply: marketData?['max_supply'] != null
          ? (marketData!['max_supply'] as num).toDouble()
          : null,
      athPrice: marketData?['ath']?['usd'] != null
          ? (marketData!['ath']['usd'] as num).toDouble()
          : null,
      athChangePercentage: marketData?['ath_change_percentage']?['usd'] != null
          ? (marketData!['ath_change_percentage']['usd'] as num).toDouble()
          : null,
      athDate: marketData?['ath_date']?['usd'] != null
          ? DateTime.parse(marketData!['ath_date']['usd'] as String)
          : null,
      atlPrice: marketData?['atl']?['usd'] != null
          ? (marketData!['atl']['usd'] as num).toDouble()
          : null,
      atlChangePercentage: marketData?['atl_change_percentage']?['usd'] != null
          ? (marketData!['atl_change_percentage']['usd'] as num).toDouble()
          : null,
      atlDate: marketData?['atl_date']?['usd'] != null
          ? DateTime.parse(marketData!['atl_date']['usd'] as String)
          : null,
      priceChangePercentage24h: marketData?['price_change_percentage_24h'] != null
          ? (marketData!['price_change_percentage_24h'] as num).toDouble()
          : null,
      priceChangePercentage7d: marketData?['price_change_percentage_7d'] != null
          ? (marketData!['price_change_percentage_7d'] as num).toDouble()
          : null,
      priceChangePercentage30d: marketData?['price_change_percentage_30d'] != null
          ? (marketData!['price_change_percentage_30d'] as num).toDouble()
          : null,
      description: json['description']?['en'] as String?,
      sparklineData: null,
    );
  }
}

class PricePoint {
  final DateTime timestamp;
  final double price;

  PricePoint({
    required this.timestamp,
    required this.price,
  });

  factory PricePoint.fromList(List<dynamic> data) {
    return PricePoint(
      timestamp: DateTime.fromMillisecondsSinceEpoch(data[0] as int),
      price: (data[1] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.millisecondsSinceEpoch,
      'price': price,
    };
  }
}