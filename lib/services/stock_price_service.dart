import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart';

class StockPriceService {
  static const String _cacheBoxName = 'stock_prices_cache';
  static const Duration _cacheExpiry = Duration(minutes: 15);

  // Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Hive box for caching
  Box<dynamic>? _cacheBox;

  // Singleton pattern
  static final StockPriceService _instance = StockPriceService._internal();
  factory StockPriceService() => _instance;
  StockPriceService._internal();

  /// Initialize Hive cache
  Future<void> initialize() async {
    try {
      debugPrint('🔧 Initializing StockPriceService...');
      
      if (!Hive.isBoxOpen(_cacheBoxName)) {
        _cacheBox = await Hive.openBox(_cacheBoxName);
      } else {
        _cacheBox = Hive.box(_cacheBoxName);
      }
      
      debugPrint('✅ StockPriceService initialized successfully');
    } catch (e) {
      debugPrint('❌ Error initializing stock price cache: $e');
      _cacheBox = null;
    }
  }

  /// Get stock price from Firestore (admin-managed prices)
  Future<double?> getStockPrice(String symbol) async {
    try {
      // Auto-initialize if not done
      if (_cacheBox == null) {
        debugPrint('⚠️ StockPriceService not initialized, attempting auto-initialization...');
        await initialize();
        if (_cacheBox == null) {
          debugPrint('❌ Failed to auto-initialize StockPriceService');
          return _getDefaultPrice(symbol);
        }
      }

      debugPrint('📊 Fetching stock price for $symbol...');

      // Check cache first
      final cachedData = _getCachedPrice(symbol);
      if (cachedData != null) {
        debugPrint('💾 Using cached price for $symbol: ₹${cachedData.toStringAsFixed(2)}');
        return cachedData;
      }

      // Try Firestore first
      try {
        final doc = await _firestore
            .collection('stock_prices')
            .doc(symbol)
            .get();

        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>;
          final price = (data['current_price'] ?? 0).toDouble();
          
          if (price > 0) {
            await _cachePrice(symbol, price);
            debugPrint('✅ Fetched price for $symbol from Firestore: ₹${price.toStringAsFixed(2)}');
            return price;
          }
        }
      } catch (e) {
        debugPrint('⚠️ Firestore error for $symbol: $e');
      }

      // Fallback to default price
      final defaultPrice = _getDefaultPrice(symbol);
      if (defaultPrice != null) {
        debugPrint('⚠️ Using default price for $symbol: ₹${defaultPrice.toStringAsFixed(2)}');
        return defaultPrice;
      }

      debugPrint('❌ No price found for $symbol');
      return null;

    } catch (e) {
      debugPrint('❌ Error fetching price for $symbol: $e');
      return _getDefaultPrice(symbol);
    }
  }

  /// Get default price for common stocks (fallback)
  double? _getDefaultPrice(String symbol) {
    final defaultPrices = {
      'SCL.NS': 850.0,
      'RELIANCE.NS': 2500.0,
      'TCS.NS': 3800.0,
      'INFY.NS': 1600.0,
      'HDFCBANK.NS': 1650.0,
      'ITC.NS': 450.0,
      'HINDUNILVR.NS': 2400.0,
      'SBIN.NS': 750.0,
      'BHARTIARTL.NS': 900.0,
      'KOTAKBANK.NS': 1750.0,
    };
    
    return defaultPrices[symbol];
  }

  /// Get cached price if available and not expired
  double? _getCachedPrice(String symbol) {
    if (_cacheBox == null) return null;
    
    try {
      final cachedData = _cacheBox!.get('${symbol}_data');
      if (cachedData != null) {
        final timestamp = DateTime.fromMillisecondsSinceEpoch(cachedData['timestamp']);
        if (DateTime.now().difference(timestamp) < _cacheExpiry) {
          return cachedData['price']?.toDouble();
        } else {
          _cacheBox!.delete('${symbol}_data');
        }
      }
    } catch (e) {
      debugPrint('❌ Error reading cache for $symbol: $e');
    }
    
    return null;
  }

  /// Cache price with timestamp
  Future<void> _cachePrice(String symbol, double price) async {
    if (_cacheBox == null) return;
    
    try {
      await _cacheBox!.put('${symbol}_data', {
        'price': price,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      debugPrint('❌ Error caching price for $symbol: $e');
    }
  }

  /// Admin method to update stock price in Firestore
  Future<bool> updateStockPrice(String symbol, double price) async {
    try {
      await _firestore.collection('stock_prices').doc(symbol).set({
        'current_price': price,
        'last_updated': FieldValue.serverTimestamp(),
        'symbol': symbol,
      }, SetOptions(merge: true));
      
      // Clear cache for this symbol
      if (_cacheBox != null) {
        await _cacheBox!.delete('${symbol}_data');
      }
      
      debugPrint('✅ Updated price for $symbol: ₹${price.toStringAsFixed(2)}');
      return true;
    } catch (e) {
      debugPrint('❌ Error updating price for $symbol: $e');
      return false;
    }
  }

  /// Clear all cached prices
  Future<void> clearCache() async {
    if (_cacheBox != null) {
      await _cacheBox!.clear();
      debugPrint('🧹 Cleared stock price cache');
    }
  }
}
