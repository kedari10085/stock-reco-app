import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/recommendation.dart';
import '../models/stock_price.dart' as model;
import '../models/performance_data.dart';
import 'stock_price_service.dart' as service;

class ReturnsService extends ChangeNotifier {
  static const String _performanceBoxName = 'performance_cache';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final service.StockPriceService _stockPriceService = service.StockPriceService();
  late Box<Map> _performanceCache;

  Timer? _updateTimer;
  bool _isInitialized = false;
  bool _isUpdating = false;

  // Performance data
  Map<String, PerformanceData> _performanceData = {};
  double _totalPortfolioReturn = 0.0;
  double _totalInvestment = 0.0;

  // Getters
  bool get isInitialized => _isInitialized;
  bool get isUpdating => _isUpdating;
  Map<String, PerformanceData> get performanceData => _performanceData;
  double get totalPortfolioReturn => _totalPortfolioReturn;
  double get totalInvestment => _totalInvestment;
  double get portfolioReturnPercentage =>
      _totalInvestment > 0 ? (_totalPortfolioReturn / _totalInvestment) * 100 : 0.0;

  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      debugPrint('📊 Initializing Returns Service...');

      // Initialize performance cache only
      _performanceCache = await Hive.openBox<Map>(_performanceBoxName);

      // Initialize StockPriceService
      await _stockPriceService.initialize();

      // Load cached performance data
      await _loadCachedPerformanceData();

      _isInitialized = true;
      debugPrint('✅ Returns Service initialized successfully');

      // Start real-time updates with delay
      Future.delayed(const Duration(seconds: 5), () {
        if (_isInitialized) {
          _startRealTimeUpdates();
          updateAllRecommendations();
        }
      });

    } catch (e) {
      debugPrint('❌ Error initializing Returns Service: $e');
    }
  }

  void _startRealTimeUpdates() {
    _updateTimer?.cancel();
    _updateTimer = Timer.periodic(const Duration(seconds: 60), (timer) {
      if (_isInitialized && !_isUpdating) {
        updateAllRecommendations();
      }
    });
    debugPrint('🔄 Started real-time updates (60s interval)');
  }

  Future<void> updateAllRecommendations() async {
    if (_isUpdating) return;

    try {
      _isUpdating = true;
      notifyListeners();

      debugPrint('📊 Updating all recommendations...');

      // Fetch active recommendations
      final recoSnapshot = await _firestore
          .collection('recommendations')
          .where('status', isEqualTo: 'active')
          .get();

      if (recoSnapshot.docs.isEmpty) {
        debugPrint('📭 No active recommendations found');
        return;
      }

      final recommendations = recoSnapshot.docs
          .map((doc) => Recommendation.fromFirestore(doc))
          .toList();

      debugPrint('📈 Found ${recommendations.length} active recommendations');

      // Update each recommendation
      for (final reco in recommendations) {
        await _updateRecommendationReturns(reco);

        // Small delay between updates to avoid overwhelming the system
        await Future.delayed(const Duration(milliseconds: 500));
      }

      // Calculate portfolio totals
      _calculatePortfolioTotals();

      // Cache performance data
      await _cachePerformanceData();

      debugPrint('✅ All recommendations updated successfully');

    } catch (e) {
      debugPrint('❌ Error updating recommendations: $e');
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
  }

  Future<void> _updateRecommendationReturns(Recommendation reco) async {
    try {
      debugPrint('📊 Updating returns for ${reco.ticker}...');

      // Get current price
      final currentPrice = await _getCurrentPrice(reco.ticker);
      if (currentPrice == null) {
        debugPrint('⚠️ Could not fetch current price for ${reco.ticker}');
        return;
      }

      // Get historical prices for monthly calculation
      final monthlyPrices = await _getMonthlyPrices(reco.ticker);

      // Calculate returns
      final performance = _calculateReturns(reco, currentPrice, monthlyPrices);

      // Update Firestore
      await _updateFirestoreRecommendation(reco.id, performance);

      // Store in local cache
      _performanceData[reco.ticker] = performance;

      debugPrint('✅ Updated returns for ${reco.ticker}: ${performance.monthlyReturn.toStringAsFixed(2)}%');

    } catch (e) {
      debugPrint('❌ Error updating returns for ${reco.ticker}: $e');
    }
  }

  Future<double?> _getCurrentPrice(String ticker) async {
    try {
      debugPrint('📊 Fetching current price for $ticker using StockPriceService...');
      
      // Use StockPriceService instead of direct API calls
      final stockPrice = await _stockPriceService.getStockPrice(ticker);
      
      if (stockPrice != null) {
        debugPrint('✅ Got price for $ticker: ₹$stockPrice');
        return stockPrice;
      } else {
        debugPrint('⚠️ Could not fetch price for $ticker from StockPriceService');
        return null;
      }
    } catch (e) {
      debugPrint('❌ Error fetching current price for $ticker: $e');
      return null;
    }
  }

  Future<List<model.StockPrice>> _getMonthlyPrices(String ticker) async {
    try {
      debugPrint('📊 Monthly price data not implemented yet for $ticker');
      // For now, return empty list - monthly calculations will use basic returns
      return [];
    } catch (e) {
      debugPrint('❌ Error fetching monthly data for $ticker: $e');
      return [];
    }
  }

  PerformanceData _calculateReturns(Recommendation reco, double currentPrice, List<model.StockPrice> monthlyPrices) {
    // Basic return calculation
    final buyPrice = reco.buyPrice;
    final basicReturn = ((currentPrice - buyPrice) / buyPrice) * 100;

    // Monthly return (average of last 30 days)
    double monthlyReturn = basicReturn;
    if (monthlyPrices.isNotEmpty) {
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      final recentPrices = monthlyPrices.where((p) => p.date.isAfter(thirtyDaysAgo)).toList();

      if (recentPrices.isNotEmpty) {
        final avgRecentPrice = recentPrices.map((p) => p.close).reduce((a, b) => a + b) / recentPrices.length;
        monthlyReturn = ((currentPrice - avgRecentPrice) / avgRecentPrice) * 100;
      }
    }

    // Yearly return (annualized)
    final daysSinceBuy = DateTime.now().difference(reco.createdAt).inDays;
    double yearlyReturn = basicReturn;
    if (daysSinceBuy > 0) {
      final annualizationFactor = 365.0 / daysSinceBuy;
      yearlyReturn = pow(1 + (basicReturn / 100), annualizationFactor).toDouble() - 1;
      yearlyReturn *= 100;
    }

    // One lakh profit
    final oneLakhProfit = (basicReturn / 100) * 100000;

    return PerformanceData(
      ticker: reco.ticker,
      buyPrice: buyPrice,
      currentPrice: currentPrice,
      monthlyReturn: monthlyReturn,
      yearlyReturn: yearlyReturn,
      oneLakhProfit: oneLakhProfit,
      lastUpdated: DateTime.now(),
    );
  }

  Future<void> _updateFirestoreRecommendation(String recoId, PerformanceData performance) async {
    try {
      await _firestore.collection('recommendations').doc(recoId).update({
        'current_price': performance.currentPrice,
        'monthly_return': performance.monthlyReturn,
        'yearly_return': performance.yearlyReturn,
        'one_lakh_profit': performance.oneLakhProfit,
        'last_price_update': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('❌ Error updating Firestore for $recoId: $e');
    }
  }

  void _calculatePortfolioTotals() {
    _totalInvestment = 0.0;
    _totalPortfolioReturn = 0.0;

    for (final performance in _performanceData.values) {
      _totalInvestment += 100000; // ₹1 lakh per recommendation
      _totalPortfolioReturn += performance.oneLakhProfit;
    }

    debugPrint('💰 Portfolio: Investment=₹${_totalInvestment.toStringAsFixed(0)}, Return=₹${_totalPortfolioReturn.toStringAsFixed(0)}');
  }

  Future<void> _cachePerformanceData() async {
    try {
      final cacheData = _performanceData.map((key, value) => MapEntry(key, value.toJson()));
      await _performanceCache.put('performance_data', {
        'data': cacheData,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('❌ Error caching performance data: $e');
    }
  }

  Future<void> _loadCachedPerformanceData() async {
    try {
      final cached = _performanceCache.get('performance_data');
      if (cached != null) {
        final Map<String, dynamic> data = Map<String, dynamic>.from(cached['data']);
        _performanceData = data.map((key, value) =>
            MapEntry(key, PerformanceData.fromJson(Map<String, dynamic>.from(value))));

        _calculatePortfolioTotals();
        debugPrint('📦 Loaded cached performance data for ${_performanceData.length} stocks');
      }
    } catch (e) {
      debugPrint('❌ Error loading cached performance data: $e');
    }
  }


  // Get performance data for a specific ticker
  PerformanceData? getPerformanceData(String ticker) {
    return _performanceData[ticker];
  }

  // Get all performance data as a list
  List<PerformanceData> getAllPerformanceData() {
    return _performanceData.values.toList();
  }

  // Force refresh a specific ticker
  Future<void> refreshTicker(String ticker) async {
    try {
      final recoSnapshot = await _firestore
          .collection('recommendations')
          .where('ticker', isEqualTo: ticker)
          .where('status', isEqualTo: 'active')
          .limit(1)
          .get();

      if (recoSnapshot.docs.isNotEmpty) {
        final reco = Recommendation.fromFirestore(recoSnapshot.docs.first);
        await _updateRecommendationReturns(reco);
        _calculatePortfolioTotals();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('❌ Error refreshing ticker $ticker: $e');
    }
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }
}
