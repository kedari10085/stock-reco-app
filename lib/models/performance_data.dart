class PerformanceData {
  final String ticker;
  final double buyPrice;
  final double currentPrice;
  final double monthlyReturn;
  final double yearlyReturn;
  final double oneLakhProfit;
  final DateTime lastUpdated;

  PerformanceData({
    required this.ticker,
    required this.buyPrice,
    required this.currentPrice,
    required this.monthlyReturn,
    required this.yearlyReturn,
    required this.oneLakhProfit,
    required this.lastUpdated,
  });

  // Convenience getters
  double get returnPercentage => ((currentPrice - buyPrice) / buyPrice) * 100;
  bool get isProfitable => returnPercentage > 0;
  String get formattedReturn => '${returnPercentage >= 0 ? '+' : ''}${returnPercentage.toStringAsFixed(2)}%';
  String get formattedMonthlyReturn => '${monthlyReturn >= 0 ? '+' : ''}${monthlyReturn.toStringAsFixed(2)}%';
  String get formattedYearlyReturn => '${yearlyReturn >= 0 ? '+' : ''}${yearlyReturn.toStringAsFixed(2)}%';
  String get formattedOneLakhProfit => '₹${oneLakhProfit >= 0 ? '+' : ''}${oneLakhProfit.toStringAsFixed(0)}';

  factory PerformanceData.fromJson(Map<String, dynamic> json) {
    return PerformanceData(
      ticker: json['ticker'],
      buyPrice: json['buyPrice'].toDouble(),
      currentPrice: json['currentPrice'].toDouble(),
      monthlyReturn: json['monthlyReturn'].toDouble(),
      yearlyReturn: json['yearlyReturn'].toDouble(),
      oneLakhProfit: json['oneLakhProfit'].toDouble(),
      lastUpdated: DateTime.parse(json['lastUpdated']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ticker': ticker,
      'buyPrice': buyPrice,
      'currentPrice': currentPrice,
      'monthlyReturn': monthlyReturn,
      'yearlyReturn': yearlyReturn,
      'oneLakhProfit': oneLakhProfit,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'PerformanceData(ticker: $ticker, return: $formattedReturn, profit: $formattedOneLakhProfit)';
  }
}
