import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/foundation.dart';
import 'stock_price_service.dart';

class RecommendationService {
  static const String _cacheBoxName = 'recommendations_cache';
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final StockPriceService _priceService = StockPriceService();
  
  Box<dynamic>? _cacheBox;
  Timer? _priceUpdateTimer;
  
  // Singleton pattern
  static final RecommendationService _instance = RecommendationService._internal();
  factory RecommendationService() => _instance;
  RecommendationService._internal();

  /// Initialize service
  Future<void> initialize() async {
    try {
      // Initialize price service
      await _priceService.initialize();
      
      // Open cache box
      if (!Hive.isBoxOpen(_cacheBoxName)) {
        _cacheBox = await Hive.openBox(_cacheBoxName);
      } else {
        _cacheBox = Hive.box(_cacheBoxName);
      }
      
      // Start periodic price updates (every 60 seconds)
      _startPriceUpdateTimer();
      
      debugPrint('RecommendationService initialized');
    } catch (e) {
      debugPrint('Error initializing RecommendationService: $e');
    }
  }

  /// Start timer for periodic price updates
  void _startPriceUpdateTimer() {
    _priceUpdateTimer?.cancel();
    _priceUpdateTimer = Timer.periodic(
      const Duration(seconds: 60),
      (timer) => _updateAllPrices(),
    );
    debugPrint('Started price update timer (60s interval)');
  }

  /// Stop price update timer
  void dispose() {
    _priceUpdateTimer?.cancel();
    debugPrint('Stopped price update timer');
  }

  /// Get recommendations stream with real-time updates
  Stream<List<RecommendationData>> getRecommendationsStream() {
    return _firestore
        .collection('recommendations')
        .where('status', isEqualTo: 'active')
        .orderBy('added_date', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      final recommendations = <RecommendationData>[];
      
      for (final doc in snapshot.docs) {
        try {
          final data = doc.data();
          final ticker = data['ticker'] as String;
          
          // Get current price
          final priceData = await _priceService.getStockPrice(ticker);
          
          final recommendation = RecommendationData(
            id: data['id'] ?? doc.id,
            ticker: ticker,
            stockName: data['stock_name'] ?? ticker,
            buyPrice: (data['buy_price'] as num).toDouble(),
            targetPrice: (data['target_price'] as num).toDouble(),
            rationale: data['rationale'] ?? '',
            status: data['status'] ?? 'active',
            addedDate: (data['added_date'] as Timestamp?)?.toDate() ?? DateTime.now(),
            addedBy: data['added_by'] ?? 'admin',
            exchange: data['exchange'] ?? 'NSE',
            currentPrice: priceData,
            priceChange: null, // These fields are no longer available
            priceChangePercent: null,
            lastPriceUpdate: priceData != null ? DateTime.now() : null,
          );
          
          recommendations.add(recommendation);
          
          // Cache recommendation
          await _cacheRecommendation(recommendation);
        } catch (e) {
          debugPrint('Error processing recommendation ${doc.id}: $e');
        }
      }
      
      return recommendations;
    });
  }

  /// Get cached recommendations (for offline mode)
  Future<List<RecommendationData>> getCachedRecommendations() async {
    try {
      if (_cacheBox == null) return [];
      
      final recommendations = <RecommendationData>[];
      
      for (final key in _cacheBox!.keys) {
        try {
          final cached = _cacheBox!.get(key);
          if (cached != null) {
            final data = Map<String, dynamic>.from(cached);
            recommendations.add(RecommendationData.fromJson(data));
          }
        } catch (e) {
          debugPrint('Error reading cached recommendation: $e');
        }
      }
      
      // Sort by date
      recommendations.sort((a, b) => b.addedDate.compareTo(a.addedDate));
      
      debugPrint('Loaded ${recommendations.length} cached recommendations');
      return recommendations;
    } catch (e) {
      debugPrint('Error getting cached recommendations: $e');
      return [];
    }
  }

  /// Cache recommendation
  Future<void> _cacheRecommendation(RecommendationData recommendation) async {
    try {
      if (_cacheBox == null) return;
      await _cacheBox!.put(recommendation.id, recommendation.toJson());
    } catch (e) {
      debugPrint('Error caching recommendation: $e');
    }
  }

  /// Update prices for all active recommendations
  Future<void> _updateAllPrices() async {
    try {
      final snapshot = await _firestore
          .collection('recommendations')
          .where('status', isEqualTo: 'active')
          .get();

      for (final doc in snapshot.docs) {
        try {
          final ticker = doc.data()['ticker'] as String;
          final priceData = await _priceService.getStockPrice(ticker);
          
          if (priceData != null) {
            // Update Firestore with latest price
            await doc.reference.update({
              'current_price': priceData,
              'last_price_update': FieldValue.serverTimestamp(),
            });
            
            debugPrint('Updated price for $ticker: ₹$priceData');
          }
        } catch (e) {
          debugPrint('Error updating price for ${doc.id}: $e');
        }
        
        // Small delay to avoid rate limiting
        await Future.delayed(const Duration(milliseconds: 500));
      }
    } catch (e) {
      debugPrint('Error updating all prices: $e');
    }
  }

  /// Manually trigger price update
  Future<void> refreshPrices() async {
    debugPrint('Manually refreshing prices...');
    await _updateAllPrices();
  }

  /// Clear cache
  Future<void> clearCache() async {
    try {
      await _cacheBox?.clear();
      debugPrint('Cleared recommendations cache');
    } catch (e) {
      debugPrint('Error clearing cache: $e');
    }
  }
}

/// Recommendation data model
class RecommendationData {
  final String id;
  final String ticker;
  final String stockName;
  final double buyPrice;
  final double targetPrice;
  final String rationale;
  final String status;
  final DateTime addedDate;
  final String addedBy;
  final String exchange;
  final double? currentPrice;
  final double? priceChange;
  final double? priceChangePercent;
  final DateTime? lastPriceUpdate;

  RecommendationData({
    required this.id,
    required this.ticker,
    required this.stockName,
    required this.buyPrice,
    required this.targetPrice,
    required this.rationale,
    required this.status,
    required this.addedDate,
    required this.addedBy,
    required this.exchange,
    this.currentPrice,
    this.priceChange,
    this.priceChangePercent,
    this.lastPriceUpdate,
  });

  double get returnPercent {
    if (currentPrice == null) return 0.0;
    return ((currentPrice! - buyPrice) / buyPrice) * 100;
  }

  double get targetReturnPercent {
    return ((targetPrice - buyPrice) / buyPrice) * 100;
  }

  bool get isProfit => returnPercent > 0;
  bool get isTargetReached => currentPrice != null && currentPrice! >= targetPrice;
  
  String get statusDisplay {
    if (isTargetReached) return 'Target Reached';
    if (isProfit) return 'In Profit';
    return 'Active';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ticker': ticker,
      'stock_name': stockName,
      'buy_price': buyPrice,
      'target_price': targetPrice,
      'rationale': rationale,
      'status': status,
      'added_date': addedDate.toIso8601String(),
      'added_by': addedBy,
      'exchange': exchange,
      'current_price': currentPrice,
      'price_change': priceChange,
      'price_change_percent': priceChangePercent,
      'last_price_update': lastPriceUpdate?.toIso8601String(),
    };
  }

  factory RecommendationData.fromJson(Map<String, dynamic> json) {
    return RecommendationData(
      id: json['id'],
      ticker: json['ticker'],
      stockName: json['stock_name'],
      buyPrice: (json['buy_price'] as num).toDouble(),
      targetPrice: (json['target_price'] as num).toDouble(),
      rationale: json['rationale'],
      status: json['status'],
      addedDate: DateTime.parse(json['added_date']),
      addedBy: json['added_by'],
      exchange: json['exchange'],
      currentPrice: json['current_price'] != null 
          ? (json['current_price'] as num).toDouble() 
          : null,
      priceChange: json['price_change'] != null 
          ? (json['price_change'] as num).toDouble() 
          : null,
      priceChangePercent: json['price_change_percent'] != null 
          ? (json['price_change_percent'] as num).toDouble() 
          : null,
      lastPriceUpdate: json['last_price_update'] != null 
          ? DateTime.parse(json['last_price_update']) 
          : null,
    );
  }
}
