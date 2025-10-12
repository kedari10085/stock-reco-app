import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dio/dio.dart';
import '../models/ipo.dart';

class IPOService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Dio _dio = Dio();

  static const String _iposCollection = 'ipos';
  static const String _ipoRecommendationsCollection = 'ipo_recommendations';

  // Get current open IPOs
  Stream<List<IPO>> getOpenIPOsStream() {
    return _firestore
        .collection(_iposCollection)
        .where('status', isEqualTo: 'open')
        .orderBy('open_date', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => IPO.fromFirestore(doc))
            .where((ipo) => ipo.isOpen)
            .toList());
  }

  // Get all IPOs for admin
  Stream<List<IPO>> getAllIPOsStream() {
    return _firestore
        .collection(_iposCollection)
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => IPO.fromFirestore(doc))
            .toList());
  }

  // Get IPO recommendation
  Future<IPORecommendation?> getIPORecommendation(String ipoId) async {
    try {
      final snapshot = await _firestore
          .collection(_ipoRecommendationsCollection)
          .where('ipo_id', isEqualTo: ipoId)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return IPORecommendation.fromFirestore(snapshot.docs.first);
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error getting IPO recommendation: $e');
      return null;
    }
  }

  // Set IPO recommendation (Admin only)
  Future<bool> setIPORecommendation({
    required String ipoId,
    required String recommendation,
    String? comments,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      final now = DateTime.now();
      
      // Check if recommendation already exists
      final existingSnapshot = await _firestore
          .collection(_ipoRecommendationsCollection)
          .where('ipo_id', isEqualTo: ipoId)
          .limit(1)
          .get();

      if (existingSnapshot.docs.isNotEmpty) {
        // Update existing recommendation
        await _firestore
            .collection(_ipoRecommendationsCollection)
            .doc(existingSnapshot.docs.first.id)
            .update({
          'recommendation': recommendation,
          'comments': comments,
          'updated_at': Timestamp.fromDate(now),
        });
      } else {
        // Create new recommendation
        final ipoRecommendation = IPORecommendation(
          id: '',
          ipoId: ipoId,
          recommendation: recommendation,
          comments: comments,
          adminEmail: user.email ?? '',
          createdAt: now,
          updatedAt: now,
        );

        await _firestore
            .collection(_ipoRecommendationsCollection)
            .add(ipoRecommendation.toFirestore());
      }

      debugPrint('✅ IPO recommendation set: $recommendation for $ipoId');
      return true;
    } catch (e) {
      debugPrint('❌ Error setting IPO recommendation: $e');
      return false;
    }
  }

  // Create IPO (Admin only)
  Future<String?> createIPO({
    required String name,
    required String symbol,
    required DateTime openDate,
    required DateTime closeDate,
    required double minPrice,
    required double maxPrice,
    required String lotSize,
    String? description,
  }) async {
    try {
      final ipo = IPO(
        id: '',
        name: name,
        symbol: symbol,
        openDate: openDate,
        closeDate: closeDate,
        minPrice: minPrice,
        maxPrice: maxPrice,
        lotSize: lotSize,
        status: _getIPOStatus(openDate, closeDate),
        description: description,
        createdAt: DateTime.now(),
      );

      final docRef = await _firestore
          .collection(_iposCollection)
          .add(ipo.toFirestore());

      debugPrint('✅ IPO created: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      debugPrint('❌ Error creating IPO: $e');
      return null;
    }
  }

  // Update IPO status based on dates
  String _getIPOStatus(DateTime openDate, DateTime closeDate) {
    final now = DateTime.now();
    
    if (now.isBefore(openDate)) {
      return 'upcoming';
    } else if (now.isAfter(closeDate)) {
      return 'closed';
    } else {
      return 'open';
    }
  }

  // Fetch IPOs from external API (mock implementation)
  Future<void> fetchIPOsFromAPI() async {
    try {
      debugPrint('📊 Fetching IPOs from external API...');
      
      // Mock IPO data for demo - replace with actual API call
      final mockIPOs = [
        {
          'name': 'TechCorp Limited',
          'symbol': 'TECHCORP',
          'open_date': DateTime.now().add(const Duration(days: 2)),
          'close_date': DateTime.now().add(const Duration(days: 5)),
          'min_price': 120.0,
          'max_price': 130.0,
          'lot_size': '100',
          'description': 'Leading technology company specializing in AI solutions',
        },
        {
          'name': 'GreenEnergy Solutions',
          'symbol': 'GREENENERGY',
          'open_date': DateTime.now().subtract(const Duration(days: 1)),
          'close_date': DateTime.now().add(const Duration(days: 3)),
          'min_price': 85.0,
          'max_price': 95.0,
          'lot_size': '150',
          'description': 'Renewable energy company with solar and wind projects',
        },
      ];

      // Create IPOs if they don't exist
      for (final ipoData in mockIPOs) {
        final existingIPO = await _firestore
            .collection(_iposCollection)
            .where('symbol', isEqualTo: ipoData['symbol'])
            .limit(1)
            .get();

        if (existingIPO.docs.isEmpty) {
          await createIPO(
            name: ipoData['name'] as String,
            symbol: ipoData['symbol'] as String,
            openDate: ipoData['open_date'] as DateTime,
            closeDate: ipoData['close_date'] as DateTime,
            minPrice: ipoData['min_price'] as double,
            maxPrice: ipoData['max_price'] as double,
            lotSize: ipoData['lot_size'] as String,
            description: ipoData['description'] as String?,
          );
        }
      }

      debugPrint('✅ IPOs fetched and updated');
    } catch (e) {
      debugPrint('❌ Error fetching IPOs from API: $e');
    }
  }

  // Update IPO statuses based on current date
  Future<void> updateIPOStatuses() async {
    try {
      final snapshot = await _firestore
          .collection(_iposCollection)
          .where('status', whereIn: ['upcoming', 'open'])
          .get();

      final batch = _firestore.batch();
      
      for (final doc in snapshot.docs) {
        final ipo = IPO.fromFirestore(doc);
        final newStatus = _getIPOStatus(ipo.openDate, ipo.closeDate);
        
        if (newStatus != ipo.status) {
          batch.update(doc.reference, {'status': newStatus});
        }
      }

      await batch.commit();
      debugPrint('✅ IPO statuses updated');
    } catch (e) {
      debugPrint('❌ Error updating IPO statuses: $e');
    }
  }

  // Delete IPO (Admin only)
  Future<bool> deleteIPO(String ipoId) async {
    try {
      // Delete IPO
      await _firestore.collection(_iposCollection).doc(ipoId).delete();
      
      // Delete associated recommendations
      final recommendations = await _firestore
          .collection(_ipoRecommendationsCollection)
          .where('ipo_id', isEqualTo: ipoId)
          .get();

      final batch = _firestore.batch();
      for (final doc in recommendations.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      debugPrint('✅ IPO deleted: $ipoId');
      return true;
    } catch (e) {
      debugPrint('❌ Error deleting IPO: $e');
      return false;
    }
  }

  @override
  void dispose() {
    _dio.close();
    super.dispose();
  }
}
