import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LiveFeedsService extends ChangeNotifier {
  static const String _cacheKey = 'live_feeds_cache';
  static const String _lastUpdateKey = 'live_feeds_last_update';
  
  final Dio _dio = Dio();
  Timer? _updateTimer;
  
  // Market data
  MarketData? _niftyData;
  MarketData? _sensexData;
  MarketData? _nifty50Data;
  GoldData? _goldData;
  
  bool _isLoading = false;
  String? _errorMessage;
  DateTime? _lastUpdate;
  
  // Getters
  MarketData? get niftyData => _niftyData;
  MarketData? get sensexData => _sensexData;
  MarketData? get nifty50Data => _nifty50Data;
  GoldData? get goldData => _goldData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  DateTime? get lastUpdate => _lastUpdate;
  
  LiveFeedsService() {
    _loadCachedData();
    startLiveUpdates();
  }
  
  // Start live updates every 2 minutes
  void startLiveUpdates() {
    _updateTimer?.cancel();
    _updateTimer = Timer.periodic(const Duration(minutes: 2), (_) {
      fetchAllData();
    });
    
    // Initial fetch
    fetchAllData();
  }
  
  // Stop live updates
  void stopLiveUpdates() {
    _updateTimer?.cancel();
  }
  
  // Fetch all market data
  Future<void> fetchAllData() async {
    if (_isLoading) return;
    
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      debugPrint('📊 Fetching live market data...');
      
      // Fetch all data concurrently
      final results = await Future.wait([
        _fetchNiftyData(),
        _fetchSensexData(),
        _fetchNifty50Data(),
        _fetchGoldData(),
      ]);
      
      _niftyData = results[0] as MarketData?;
      _sensexData = results[1] as MarketData?;
      _nifty50Data = results[2] as MarketData?;
      _goldData = results[3] as GoldData?;
      
      _lastUpdate = DateTime.now();
      await _cacheData();
      
      debugPrint('✅ Live market data updated successfully');
      
    } catch (e) {
      _errorMessage = 'Failed to fetch market data: $e';
      debugPrint('❌ Error fetching market data: $e');
      
      // Load cached data on error
      await _loadCachedData();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Fetch Nifty data from Alpha Vantage
  Future<MarketData?> _fetchNiftyData() async {
    try {
      // Using a free API endpoint for Indian market data
      // Note: Replace with your Alpha Vantage API key
      const apiKey = 'demo'; // Replace with actual API key
      final response = await _dio.get(
        'https://www.alphavantage.co/query',
        queryParameters: {
          'function': 'GLOBAL_QUOTE',
          'symbol': 'NSEI.BSE', // Nifty 50 symbol
          'apikey': apiKey,
        },
        options: Options(
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        final quote = data['Global Quote'];
        
        if (quote != null) {
          return MarketData(
            symbol: 'NIFTY',
            name: 'Nifty 50',
            price: double.tryParse(quote['05. price'] ?? '0') ?? 0,
            change: double.tryParse(quote['09. change'] ?? '0') ?? 0,
            changePercent: double.tryParse(quote['10. change percent']?.replaceAll('%', '') ?? '0') ?? 0,
            lastUpdate: DateTime.now(),
          );
        }
      }
    } catch (e) {
      debugPrint('❌ Error fetching Nifty data: $e');
      
      // Return mock data for demo purposes
      return MarketData(
        symbol: 'NIFTY',
        name: 'Nifty 50',
        price: 19800.50,
        change: 125.30,
        changePercent: 0.64,
        lastUpdate: DateTime.now(),
      );
    }
    return null;
  }
  
  // Fetch Sensex data
  Future<MarketData?> _fetchSensexData() async {
    try {
      // Mock data for demo - replace with actual API call
      return MarketData(
        symbol: 'SENSEX',
        name: 'BSE Sensex',
        price: 66500.25,
        change: -85.75,
        changePercent: -0.13,
        lastUpdate: DateTime.now(),
      );
    } catch (e) {
      debugPrint('❌ Error fetching Sensex data: $e');
    }
    return null;
  }
  
  // Fetch Nifty 50 data
  Future<MarketData?> _fetchNifty50Data() async {
    try {
      // Mock data for demo - replace with actual API call
      return MarketData(
        symbol: 'NIFTY50',
        name: 'Nifty 50 Stocks',
        price: 19750.80,
        change: 95.20,
        changePercent: 0.48,
        lastUpdate: DateTime.now(),
      );
    } catch (e) {
      debugPrint('❌ Error fetching Nifty 50 data: $e');
    }
    return null;
  }
  
  // Fetch Gold data from GoldAPI
  Future<GoldData?> _fetchGoldData() async {
    try {
      final response = await _dio.get(
        'https://api.metals.live/v1/spot/gold',
        options: Options(
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        
        // Convert USD to INR (approximate rate: 1 USD = 83 INR)
        final priceUSD = double.tryParse(data['price']?.toString() ?? '0') ?? 0;
        final priceINR = priceUSD * 83; // Approximate conversion
        
        return GoldData(
          pricePerOunce: priceINR,
          currency: 'INR',
          change: 0, // Calculate from previous price if available
          changePercent: 0,
          lastUpdate: DateTime.now(),
        );
      }
    } catch (e) {
      debugPrint('❌ Error fetching Gold data: $e');
      
      // Return mock data for demo
      return GoldData(
        pricePerOunce: 5850.75,
        currency: 'INR',
        change: 25.50,
        changePercent: 0.44,
        lastUpdate: DateTime.now(),
      );
    }
    return null;
  }
  
  // Cache data locally
  Future<void> _cacheData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final cacheData = {
        'nifty': _niftyData?.toJson(),
        'sensex': _sensexData?.toJson(),
        'nifty50': _nifty50Data?.toJson(),
        'gold': _goldData?.toJson(),
        'last_update': _lastUpdate?.toIso8601String(),
      };
      
      await prefs.setString(_cacheKey, jsonEncode(cacheData));
      await prefs.setString(_lastUpdateKey, DateTime.now().toIso8601String());
      
    } catch (e) {
      debugPrint('❌ Error caching market data: $e');
    }
  }
  
  // Load cached data
  Future<void> _loadCachedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedString = prefs.getString(_cacheKey);
      final lastUpdateString = prefs.getString(_lastUpdateKey);
      
      if (cachedString != null) {
        final cacheData = jsonDecode(cachedString);
        
        if (cacheData['nifty'] != null) {
          _niftyData = MarketData.fromJson(cacheData['nifty']);
        }
        if (cacheData['sensex'] != null) {
          _sensexData = MarketData.fromJson(cacheData['sensex']);
        }
        if (cacheData['nifty50'] != null) {
          _nifty50Data = MarketData.fromJson(cacheData['nifty50']);
        }
        if (cacheData['gold'] != null) {
          _goldData = GoldData.fromJson(cacheData['gold']);
        }
        
        if (lastUpdateString != null) {
          _lastUpdate = DateTime.parse(lastUpdateString);
        }
        
        debugPrint('📦 Loaded cached market data');
        notifyListeners();
      }
    } catch (e) {
      debugPrint('❌ Error loading cached market data: $e');
    }
  }
  
  // Manual refresh
  Future<void> refresh() async {
    await fetchAllData();
  }
  
  @override
  void dispose() {
    _updateTimer?.cancel();
    _dio.close();
    super.dispose();
  }
}

// Market data model
class MarketData {
  final String symbol;
  final String name;
  final double price;
  final double change;
  final double changePercent;
  final DateTime lastUpdate;
  
  MarketData({
    required this.symbol,
    required this.name,
    required this.price,
    required this.change,
    required this.changePercent,
    required this.lastUpdate,
  });
  
  bool get isPositive => change >= 0;
  
  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'name': name,
      'price': price,
      'change': change,
      'changePercent': changePercent,
      'lastUpdate': lastUpdate.toIso8601String(),
    };
  }
  
  factory MarketData.fromJson(Map<String, dynamic> json) {
    return MarketData(
      symbol: json['symbol'] ?? '',
      name: json['name'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      change: (json['change'] ?? 0).toDouble(),
      changePercent: (json['changePercent'] ?? 0).toDouble(),
      lastUpdate: DateTime.parse(json['lastUpdate'] ?? DateTime.now().toIso8601String()),
    );
  }
}

// Gold data model
class GoldData {
  final double pricePerOunce;
  final String currency;
  final double change;
  final double changePercent;
  final DateTime lastUpdate;
  
  GoldData({
    required this.pricePerOunce,
    required this.currency,
    required this.change,
    required this.changePercent,
    required this.lastUpdate,
  });
  
  bool get isPositive => change >= 0;
  
  Map<String, dynamic> toJson() {
    return {
      'pricePerOunce': pricePerOunce,
      'currency': currency,
      'change': change,
      'changePercent': changePercent,
      'lastUpdate': lastUpdate.toIso8601String(),
    };
  }
  
  factory GoldData.fromJson(Map<String, dynamic> json) {
    return GoldData(
      pricePerOunce: (json['pricePerOunce'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'INR',
      change: (json['change'] ?? 0).toDouble(),
      changePercent: (json['changePercent'] ?? 0).toDouble(),
      lastUpdate: DateTime.parse(json['lastUpdate'] ?? DateTime.now().toIso8601String()),
    );
  }
}
