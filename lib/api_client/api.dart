import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import '../model/coin_detail_model.dart';
import '../model/coin_model.dart';
import 'api_constants.dart';

class CoinApiService {
  final http.Client _client;

  CoinApiService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<CoinModel>> fetchCoins({
    int page = 1,
    int perPage = 100,
  }) async {
    try {
      final uri = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.coinsMarkets}',
      ).replace(queryParameters: {
        'vs_currency': ApiConstants.vsCurrency,
        'order': ApiConstants.order,
        'per_page': perPage.toString(),
        'page': page.toString(),
        'sparkline': 'false',
        'price_change_percentage': '24h',
      });

      final response = await _client
          .get(uri, headers: ApiConstants.headers)
          .timeout(ApiConstants.timeout);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => CoinModel.fromJson(json)).toList();
      } else if (response.statusCode == 429) {
        throw Exception('Rate limit exceeded. Please try again later.');
      } else {
        throw Exception('Failed to load coins: ${response.statusCode}');
      }
    } on SocketException {
      throw Exception('No internet connection');
    } on http.ClientException {
      throw Exception('Connection error');
    } on FormatException {
      throw Exception('Invalid response format');
    } catch (e) {
      throw Exception('Error fetching coins: $e');
    }
  }

  Future<CoinDetailModel> fetchCoinDetail(String coinId) async {
    try {
      final uri = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.coinDetail}/$coinId',
      ).replace(queryParameters: {
        'localization': 'false',
        'tickers': 'false',
        'market_data': 'true',
        'community_data': 'false',
        'developer_data': 'false',
      });

      final response = await _client
          .get(uri, headers: ApiConstants.headers)
          .timeout(ApiConstants.timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return CoinDetailModel.fromJson(data);
      } else if (response.statusCode == 429) {
        throw Exception('Rate limit exceeded. Please try again later.');
      } else {
        throw Exception('Failed to load coin details: ${response.statusCode}');
      }
    } on SocketException {
      throw Exception('No internet connection');
    } on http.ClientException {
      throw Exception('Connection error');
    } on FormatException {
      throw Exception('Invalid response format');
    } catch (e) {
      throw Exception('Error fetching coin detail: $e');
    }
  }

  Future<List<PricePoint>> fetchCoinChart(
      String coinId, {
        int days = 7,
      }) async {
    try {
      final uri = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.coinDetail}/$coinId${ApiConstants.coinMarketChart}',
      ).replace(queryParameters: {
        'vs_currency': ApiConstants.vsCurrency,
        'days': days.toString(),
        'interval': 'daily',
      });

      final response = await _client
          .get(uri, headers: ApiConstants.headers)
          .timeout(ApiConstants.timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final prices = data['prices'] as List<dynamic>;
        return prices.map((price) => PricePoint.fromList(price)).toList();
      } else if (response.statusCode == 429) {
        throw Exception('Rate limit exceeded. Please try again later.');
      } else {
        throw Exception('Failed to load chart data: ${response.statusCode}');
      }
    } on SocketException {
      throw Exception('No internet connection');
    } on http.ClientException {
      throw Exception('Connection error');
    } on FormatException {
      throw Exception('Invalid response format');
    } catch (e) {
      throw Exception('Error fetching chart data: $e');
    }
  }

  void dispose() {
    _client.close();
  }
}