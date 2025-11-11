class CoinModel {
  final String id;
  final String symbol;
  final String name;
  final String image;
  final double currentPrice;
  final double? marketCap;
  final int? marketCapRank;
  final double? totalVolume;
  final double? priceChangePercentage24h;
  final double? high24h;
  final double? low24h;
  final DateTime? lastUpdated;

  CoinModel({
    required this.id,
    required this.symbol,
    required this.name,
    required this.image,
    required this.currentPrice,
    this.marketCap,
    this.marketCapRank,
    this.totalVolume,
    this.priceChangePercentage24h,
    this.high24h,
    this.low24h,
    this.lastUpdated,
  });

  factory CoinModel.fromJson(Map<String, dynamic> json) {
    return CoinModel(
      id: json['id'] as String,
      symbol: (json['symbol'] as String).toUpperCase(),
      name: json['name'] as String,
      image: json['image'] as String,
      currentPrice: (json['current_price'] as num).toDouble(),
      marketCap: json['market_cap'] != null
          ? (json['market_cap'] as num).toDouble()
          : null,
      marketCapRank: json['market_cap_rank'] as int?,
      totalVolume: json['total_volume'] != null
          ? (json['total_volume'] as num).toDouble()
          : null,
      priceChangePercentage24h: json['price_change_percentage_24h'] != null
          ? (json['price_change_percentage_24h'] as num).toDouble()
          : null,
      high24h: json['high_24h'] != null
          ? (json['high_24h'] as num).toDouble()
          : null,
      low24h: json['low_24h'] != null
          ? (json['low_24h'] as num).toDouble()
          : null,
      lastUpdated: json['last_updated'] != null
          ? DateTime.parse(json['last_updated'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'symbol': symbol,
      'name': name,
      'image': image,
      'current_price': currentPrice,
      'market_cap': marketCap,
      'market_cap_rank': marketCapRank,
      'total_volume': totalVolume,
      'price_change_percentage_24h': priceChangePercentage24h,
      'high_24h': high24h,
      'low_24h': low24h,
      'last_updated': lastUpdated?.toIso8601String(),
    };
  }

  Map<String, dynamic> toDatabase() {
    return {
      'id': id,
      'symbol': symbol,
      'name': name,
      'image': image,
      'current_price': currentPrice,
      'market_cap': marketCap,
      'market_cap_rank': marketCapRank,
      'total_volume': totalVolume,
      'price_change_percentage_24h': priceChangePercentage24h,
      'high_24h': high24h,
      'low_24h': low24h,
      'last_updated': lastUpdated?.millisecondsSinceEpoch,
    };
  }

  factory CoinModel.fromDatabase(Map<String, dynamic> map) {
    return CoinModel(
      id: map['id'] as String,
      symbol: map['symbol'] as String,
      name: map['name'] as String,
      image: map['image'] as String,
      currentPrice: (map['current_price'] as num).toDouble(),
      marketCap: map['market_cap'] != null
          ? (map['market_cap'] as num).toDouble()
          : null,
      marketCapRank: map['market_cap_rank'] as int?,
      totalVolume: map['total_volume'] != null
          ? (map['total_volume'] as num).toDouble()
          : null,
      priceChangePercentage24h: map['price_change_percentage_24h'] != null
          ? (map['price_change_percentage_24h'] as num).toDouble()
          : null,
      high24h: map['high_24h'] != null
          ? (map['high_24h'] as num).toDouble()
          : null,
      low24h: map['low_24h'] != null
          ? (map['low_24h'] as num).toDouble()
          : null,
      lastUpdated: map['last_updated'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['last_updated'] as int)
          : null,
    );
  }

  CoinModel copyWith({
    String? id,
    String? symbol,
    String? name,
    String? image,
    double? currentPrice,
    double? marketCap,
    int? marketCapRank,
    double? totalVolume,
    double? priceChangePercentage24h,
    double? high24h,
    double? low24h,
    DateTime? lastUpdated,
  }) {
    return CoinModel(
      id: id ?? this.id,
      symbol: symbol ?? this.symbol,
      name: name ?? this.name,
      image: image ?? this.image,
      currentPrice: currentPrice ?? this.currentPrice,
      marketCap: marketCap ?? this.marketCap,
      marketCapRank: marketCapRank ?? this.marketCapRank,
      totalVolume: totalVolume ?? this.totalVolume,
      priceChangePercentage24h: priceChangePercentage24h ?? this.priceChangePercentage24h,
      high24h: high24h ?? this.high24h,
      low24h: low24h ?? this.low24h,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}