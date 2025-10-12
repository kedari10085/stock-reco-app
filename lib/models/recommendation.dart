import 'package:cloud_firestore/cloud_firestore.dart';

class Recommendation {
  final String id;
  final String ticker;
  final String companyName;
  final double buyPrice;
  final double? targetPrice;
  final String recommendation; // 'buy', 'sell', 'hold'
  final String status; // 'active', 'completed', 'cancelled'
  final String? description;
  final String? sector;
  final DateTime createdAt;
  final DateTime? updatedAt;
  
  // Performance fields (updated by ReturnsService)
  final double? currentPrice;
  final double? monthlyReturn;
  final double? yearlyReturn;
  final double? oneLakhProfit;
  final DateTime? lastPriceUpdate;

  Recommendation({
    required this.id,
    required this.ticker,
    required this.companyName,
    required this.buyPrice,
    this.targetPrice,
    required this.recommendation,
    required this.status,
    this.description,
    this.sector,
    required this.createdAt,
    this.updatedAt,
    this.currentPrice,
    this.monthlyReturn,
    this.yearlyReturn,
    this.oneLakhProfit,
    this.lastPriceUpdate,
  });

  factory Recommendation.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return Recommendation(
      id: doc.id,
      ticker: data['ticker'] ?? '',
      companyName: data['company_name'] ?? '',
      buyPrice: (data['buy_price'] ?? 0).toDouble(),
      targetPrice: data['target_price']?.toDouble(),
      recommendation: data['recommendation'] ?? 'buy',
      status: data['status'] ?? 'active',
      description: data['description'],
      sector: data['sector'],
      createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updated_at'] as Timestamp?)?.toDate(),
      currentPrice: data['current_price']?.toDouble(),
      monthlyReturn: data['monthly_return']?.toDouble(),
      yearlyReturn: data['yearly_return']?.toDouble(),
      oneLakhProfit: data['one_lakh_profit']?.toDouble(),
      lastPriceUpdate: (data['last_price_update'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'ticker': ticker,
      'company_name': companyName,
      'buy_price': buyPrice,
      'target_price': targetPrice,
      'recommendation': recommendation,
      'status': status,
      'description': description,
      'sector': sector,
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'current_price': currentPrice,
      'monthly_return': monthlyReturn,
      'yearly_return': yearlyReturn,
      'one_lakh_profit': oneLakhProfit,
      'last_price_update': lastPriceUpdate != null ? Timestamp.fromDate(lastPriceUpdate!) : null,
    };
  }

  // Convenience getters
  double get returnPercentage {
    if (currentPrice == null) return 0.0;
    return ((currentPrice! - buyPrice) / buyPrice) * 100;
  }

  bool get isProfitable => returnPercentage > 0;

  String get formattedReturn {
    return '${returnPercentage >= 0 ? '+' : ''}${returnPercentage.toStringAsFixed(2)}%';
  }

  String get formattedOneLakhProfit {
    if (oneLakhProfit == null) return '₹0';
    return '₹${oneLakhProfit! >= 0 ? '+' : ''}${oneLakhProfit!.toStringAsFixed(0)}';
  }

  @override
  String toString() {
    return 'Recommendation(ticker: $ticker, buyPrice: $buyPrice, currentPrice: $currentPrice, status: $status)';
  }
}
