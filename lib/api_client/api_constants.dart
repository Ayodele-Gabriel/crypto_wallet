import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  static const String baseUrl = 'https://api.coingecko.com/api/v3';

  // Endpoints
  static const String coinsMarkets = '/coins/markets';
  static const String coinDetail = '/coins';
  static const String coinMarketChart = '/market_chart';

  // Parameters
  static const String vsCurrency = 'usd';
  static const String order = 'market_cap_desc';
  static const int perPage = 100;
  static const int page = 1;

  // Request configuration
  static const Duration timeout = Duration(seconds: 30);
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 2);

  // Optional: Add your CoinGecko Pro API key here
  static final apiKey = null;//dotenv.env['API_KEY'];

  // Headers
  static Map<String, String> get headers {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (apiKey != null) {
      headers['x-cg-pro-api-key'] = apiKey!;
    }

    return headers;
  }
}