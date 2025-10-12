import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/newsletter.dart';

class NewsletterService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const String _newslettersCollection = 'newsletters';
  static const String _subscribersCollection = 'subscribers';

  // Newsletter Management (Admin only)
  
  /// Create a new newsletter
  Future<String?> createNewsletter({
    required String title,
    required String body,
    required DateTime publishDate,
    List<String> tags = const [],
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        debugPrint('❌ User not authenticated');
        return null;
      }

      final newsletter = Newsletter(
        id: '', // Will be set by Firestore
        title: title,
        body: body,
        publishDate: publishDate,
        createdAt: DateTime.now(),
        authorEmail: user.email ?? '',
        isPublished: true,
        tags: tags,
      );

      final docRef = await _firestore
          .collection(_newslettersCollection)
          .add(newsletter.toFirestore());

      debugPrint('✅ Newsletter created with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      debugPrint('❌ Error creating newsletter: $e');
      return null;
    }
  }

  /// Update existing newsletter
  Future<bool> updateNewsletter(String id, Newsletter newsletter) async {
    try {
      await _firestore
          .collection(_newslettersCollection)
          .doc(id)
          .update(newsletter.toFirestore());

      debugPrint('✅ Newsletter updated: $id');
      return true;
    } catch (e) {
      debugPrint('❌ Error updating newsletter: $e');
      return false;
    }
  }

  /// Delete newsletter
  Future<bool> deleteNewsletter(String id) async {
    try {
      await _firestore
          .collection(_newslettersCollection)
          .doc(id)
          .delete();

      debugPrint('✅ Newsletter deleted: $id');
      return true;
    } catch (e) {
      debugPrint('❌ Error deleting newsletter: $e');
      return false;
    }
  }

  /// Get newsletters stream for dashboard
  Stream<List<Newsletter>> getNewslettersStream() {
    return _firestore
        .collection(_newslettersCollection)
        .where('is_published', isEqualTo: true)
        .orderBy('publish_date', descending: true)
        .limit(20)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Newsletter.fromFirestore(doc))
            .toList());
  }

  /// Get all newsletters for admin
  Stream<List<Newsletter>> getAllNewslettersStream() {
    return _firestore
        .collection(_newslettersCollection)
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Newsletter.fromFirestore(doc))
            .toList());
  }

  // Subscription Management

  /// Subscribe user to newsletter
  Future<bool> subscribeToNewsletter(String email) async {
    try {
      // Check if already subscribed
      final existingSubscriber = await _firestore
          .collection(_subscribersCollection)
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (existingSubscriber.docs.isNotEmpty) {
        // Reactivate if previously unsubscribed
        await _firestore
            .collection(_subscribersCollection)
            .doc(existingSubscriber.docs.first.id)
            .update({'is_active': true});
        
        debugPrint('✅ Newsletter subscription reactivated for: $email');
        return true;
      }

      // Create new subscription
      final subscriber = Subscriber(
        id: '', // Will be set by Firestore
        email: email,
        subscribedAt: DateTime.now(),
        isActive: true,
        preferences: {
          'weekly_digest': true,
          'new_recommendations': true,
          'market_updates': true,
        },
      );

      await _firestore
          .collection(_subscribersCollection)
          .add(subscriber.toFirestore());

      debugPrint('✅ Newsletter subscription created for: $email');
      return true;
    } catch (e) {
      debugPrint('❌ Error subscribing to newsletter: $e');
      return false;
    }
  }

  /// Unsubscribe from newsletter
  Future<bool> unsubscribeFromNewsletter(String email) async {
    try {
      final subscriber = await _firestore
          .collection(_subscribersCollection)
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (subscriber.docs.isNotEmpty) {
        await _firestore
            .collection(_subscribersCollection)
            .doc(subscriber.docs.first.id)
            .update({'is_active': false});

        debugPrint('✅ Newsletter unsubscribed: $email');
        return true;
      }

      return false;
    } catch (e) {
      debugPrint('❌ Error unsubscribing from newsletter: $e');
      return false;
    }
  }

  /// Get subscriber count (Admin only)
  Future<int> getSubscriberCount() async {
    try {
      final snapshot = await _firestore
          .collection(_subscribersCollection)
          .where('is_active', isEqualTo: true)
          .count()
          .get();

      return snapshot.count ?? 0;
    } catch (e) {
      debugPrint('❌ Error getting subscriber count: $e');
      return 0;
    }
  }

  /// Get all subscribers (Admin only)
  Stream<List<Subscriber>> getSubscribersStream() {
    return _firestore
        .collection(_subscribersCollection)
        .where('is_active', isEqualTo: true)
        .orderBy('subscribed_at', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Subscriber.fromFirestore(doc))
            .toList());
  }

  /// Check if user is subscribed
  Future<bool> isUserSubscribed(String email) async {
    try {
      final subscriber = await _firestore
          .collection(_subscribersCollection)
          .where('email', isEqualTo: email)
          .where('is_active', isEqualTo: true)
          .limit(1)
          .get();

      return subscriber.docs.isNotEmpty;
    } catch (e) {
      debugPrint('❌ Error checking subscription status: $e');
      return false;
    }
  }

  /// Generate newsletter digest from recent recommendations (Admin feature)
  Future<String?> generateRecommendationDigest() async {
    try {
      // Get recent recommendations (last 7 days)
      final weekAgo = DateTime.now().subtract(const Duration(days: 7));
      final recentRecos = await _firestore
          .collection('recommendations')
          .where('created_at', isGreaterThan: Timestamp.fromDate(weekAgo))
          .where('status', isEqualTo: 'active')
          .orderBy('created_at', descending: true)
          .get();

      if (recentRecos.docs.isEmpty) {
        return null;
      }

      final StringBuffer digest = StringBuffer();
      digest.writeln('# Weekly Stock Recommendations Digest\n');
      digest.writeln('Here are the latest stock recommendations from our experts:\n');

      for (final doc in recentRecos.docs) {
        final data = doc.data();
        final ticker = data['ticker'] ?? 'Unknown';
        final buyPrice = data['buy_price'] ?? 0.0;
        final targetPrice = data['target_price'] ?? 0.0;
        final reasoning = data['reasoning'] ?? 'No reasoning provided';

        digest.writeln('## $ticker');
        digest.writeln('**Buy Price:** ₹$buyPrice');
        digest.writeln('**Target Price:** ₹$targetPrice');
        digest.writeln('**Analysis:** $reasoning\n');
      }

      digest.writeln('---');
      digest.writeln('*This digest was auto-generated from recent recommendations.*');

      return digest.toString();
    } catch (e) {
      debugPrint('❌ Error generating digest: $e');
      return null;
    }
  }
}
