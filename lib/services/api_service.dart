import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  static final String _baseUrl = dotenv.env['API_BASE_URL'] ?? 'https://api.example.com';
  static final int _timeout = int.parse(dotenv.env['API_TIMEOUT'] ?? '30000');

  static Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl$endpoint'),
            headers: _getHeaders(),
          )
          .timeout(Duration(milliseconds: _timeout));

      return _handleResponse(response);
    } catch (e) {
      throw ApiException('GET request failed: $e');
    }
  }

  static Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl$endpoint'),
            headers: _getHeaders(),
            body: jsonEncode(data),
          )
          .timeout(Duration(milliseconds: _timeout));

      return _handleResponse(response);
    } catch (e) {
      throw ApiException('POST request failed: $e');
    }
  }

  static Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await http
          .put(
            Uri.parse('$_baseUrl$endpoint'),
            headers: _getHeaders(),
            body: jsonEncode(data),
          )
          .timeout(Duration(milliseconds: _timeout));

      return _handleResponse(response);
    } catch (e) {
      throw ApiException('PUT request failed: $e');
    }
  }

  static Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
      final response = await http
          .delete(
            Uri.parse('$_baseUrl$endpoint'),
            headers: _getHeaders(),
          )
          .timeout(Duration(milliseconds: _timeout));

      return _handleResponse(response);
    } catch (e) {
      throw ApiException('DELETE request failed: $e');
    }
  }

  static Map<String, String> _getHeaders() {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  static Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return {'success': true};
      }
      return jsonDecode(response.body);
    } else {
      throw ApiException(
        'Request failed with status ${response.statusCode}: ${response.body}',
      );
    }
  }

  // Stock API Methods (placeholder - integrate with real stock API)
  static Future<Map<String, dynamic>> getStockPrice(String symbol) async {
    // TODO: Integrate with real stock API (e.g., Yahoo Finance, Alpha Vantage)
    // For now, return mock data
    return {
      'symbol': symbol,
      'price': 100.0 + (symbol.hashCode % 1000),
      'change': (symbol.hashCode % 10) - 5,
      'changePercent': ((symbol.hashCode % 10) - 5) / 100,
    };
  }

  static Future<List<Map<String, dynamic>>> searchStocks(String query) async {
    // TODO: Integrate with real stock search API
    // For now, return mock data
    return [
      {
        'symbol': 'AAPL',
        'name': 'Apple Inc.',
        'exchange': 'NASDAQ',
      },
      {
        'symbol': 'GOOGL',
        'name': 'Alphabet Inc.',
        'exchange': 'NASDAQ',
      },
    ];
  }
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}
