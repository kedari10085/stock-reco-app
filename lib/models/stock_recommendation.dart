class StockRecommendation {
  final String id;
  final String name;
  final String symbol;
  final RecommendationType type;
  final double entryPrice;
  final double currentPrice;
  final double targetPrice;
  final double stopLoss;
  final String notes;
  final DateTime createdAt;
  final RecommendationStatus status;

  StockRecommendation({
    required this.id,
    required this.name,
    required this.symbol,
    required this.type,
    required this.entryPrice,
    required this.currentPrice,
    required this.targetPrice,
    required this.stopLoss,
    required this.notes,
    required this.createdAt,
    required this.status,
  });

  double get returnPercentage {
    return ((currentPrice - entryPrice) / entryPrice) * 100;
  }

  bool get isProfit => returnPercentage > 0;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'symbol': symbol,
      'type': type.toString(),
      'entryPrice': entryPrice,
      'currentPrice': currentPrice,
      'targetPrice': targetPrice,
      'stopLoss': stopLoss,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'status': status.toString(),
    };
  }

  factory StockRecommendation.fromJson(Map<String, dynamic> json) {
    return StockRecommendation(
      id: json['id'],
      name: json['name'],
      symbol: json['symbol'],
      type: RecommendationType.values.firstWhere(
        (e) => e.toString() == json['type'],
      ),
      entryPrice: json['entryPrice'],
      currentPrice: json['currentPrice'],
      targetPrice: json['targetPrice'],
      stopLoss: json['stopLoss'],
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt']),
      status: RecommendationStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
      ),
    );
  }
}

enum RecommendationType { buy, sell }

enum RecommendationStatus { active, completed, cancelled }
