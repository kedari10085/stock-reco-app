class StockPrice {
  final DateTime date;
  final double open;
  final double high;
  final double low;
  final double close;
  final int volume;

  StockPrice({
    required this.date,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
  });

  factory StockPrice.fromJson(Map<String, dynamic> json) {
    return StockPrice(
      date: DateTime.parse(json['date']),
      open: json['open'].toDouble(),
      high: json['high'].toDouble(),
      low: json['low'].toDouble(),
      close: json['close'].toDouble(),
      volume: json['volume'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'open': open,
      'high': high,
      'low': low,
      'close': close,
      'volume': volume,
    };
  }

  @override
  String toString() {
    return 'StockPrice(date: $date, close: $close, volume: $volume)';
  }
}
