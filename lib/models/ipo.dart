import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class IPO {
  final String id;
  final String name;
  final String symbol;
  final DateTime openDate;
  final DateTime closeDate;
  final double minPrice;
  final double maxPrice;
  final String lotSize;
  final String status; // 'upcoming', 'open', 'closed'
  final String? description;
  final DateTime createdAt;

  IPO({
    required this.id,
    required this.name,
    required this.symbol,
    required this.openDate,
    required this.closeDate,
    required this.minPrice,
    required this.maxPrice,
    required this.lotSize,
    required this.status,
    this.description,
    required this.createdAt,
  });

  factory IPO.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return IPO(
      id: doc.id,
      name: data['name'] ?? '',
      symbol: data['symbol'] ?? '',
      openDate: (data['open_date'] as Timestamp).toDate(),
      closeDate: (data['close_date'] as Timestamp).toDate(),
      minPrice: (data['min_price'] ?? 0).toDouble(),
      maxPrice: (data['max_price'] ?? 0).toDouble(),
      lotSize: data['lot_size'] ?? '',
      status: data['status'] ?? 'upcoming',
      description: data['description'],
      createdAt: (data['created_at'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'symbol': symbol,
      'open_date': Timestamp.fromDate(openDate),
      'close_date': Timestamp.fromDate(closeDate),
      'min_price': minPrice,
      'max_price': maxPrice,
      'lot_size': lotSize,
      'status': status,
      'description': description,
      'created_at': Timestamp.fromDate(createdAt),
    };
  }

  bool get isOpen {
    final now = DateTime.now();
    return now.isAfter(openDate) && now.isBefore(closeDate) && status == 'open';
  }

  bool get isClosed {
    return DateTime.now().isAfter(closeDate) || status == 'closed';
  }

  String get priceRange => '₹${minPrice.toInt()} - ₹${maxPrice.toInt()}';
}

class IPORecommendation {
  final String id;
  final String ipoId;
  final String recommendation; // 'apply', 'neutral', 'avoid'
  final String? comments;
  final String adminEmail;
  final DateTime createdAt;
  final DateTime updatedAt;

  IPORecommendation({
    required this.id,
    required this.ipoId,
    required this.recommendation,
    this.comments,
    required this.adminEmail,
    required this.createdAt,
    required this.updatedAt,
  });

  factory IPORecommendation.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return IPORecommendation(
      id: doc.id,
      ipoId: data['ipo_id'] ?? '',
      recommendation: data['recommendation'] ?? 'neutral',
      comments: data['comments'],
      adminEmail: data['admin_email'] ?? '',
      createdAt: (data['created_at'] as Timestamp).toDate(),
      updatedAt: (data['updated_at'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'ipo_id': ipoId,
      'recommendation': recommendation,
      'comments': comments,
      'admin_email': adminEmail,
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': Timestamp.fromDate(updatedAt),
    };
  }

  Color get recommendationColor {
    switch (recommendation) {
      case 'apply':
        return Colors.green;
      case 'avoid':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  String get recommendationText {
    switch (recommendation) {
      case 'apply':
        return 'APPLY';
      case 'avoid':
        return 'AVOID';
      default:
        return 'NEUTRAL';
    }
  }
}

