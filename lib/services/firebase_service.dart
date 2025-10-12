import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/stock_recommendation.dart';
import '../models/user_model.dart';

class FirebaseService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collections
  static const String _usersCollection = 'users';
  static const String _recommendationsCollection = 'recommendations';

  // Auth Methods
  static User? get currentUser => _auth.currentUser;
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  static Future<UserCredential> signInWithEmailPassword(
    String email,
    String password,
  ) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  static Future<UserCredential> signUpWithEmailPassword(
    String email,
    String password,
  ) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  static Future<void> signOut() async {
    await _auth.signOut();
  }

  static Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // User Methods
  static Future<void> createUser(UserModel user) async {
    await _firestore.collection(_usersCollection).doc(user.id).set(user.toJson());
  }

  static Future<UserModel?> getUser(String userId) async {
    final doc = await _firestore.collection(_usersCollection).doc(userId).get();
    if (doc.exists) {
      return UserModel.fromJson(doc.data()!);
    }
    return null;
  }

  static Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    await _firestore.collection(_usersCollection).doc(userId).update(data);
  }

  static Stream<UserModel?> getUserStream(String userId) {
    return _firestore
        .collection(_usersCollection)
        .doc(userId)
        .snapshots()
        .map((doc) {
      if (doc.exists) {
        return UserModel.fromJson(doc.data()!);
      }
      return null;
    });
  }

  // Recommendation Methods
  static Future<void> createRecommendation(StockRecommendation recommendation) async {
    await _firestore
        .collection(_recommendationsCollection)
        .doc(recommendation.id)
        .set(recommendation.toJson());
  }

  static Future<List<StockRecommendation>> getRecommendations({
    RecommendationStatus? status,
    int limit = 50,
  }) async {
    Query query = _firestore
        .collection(_recommendationsCollection)
        .orderBy('createdAt', descending: true)
        .limit(limit);

    if (status != null) {
      query = query.where('status', isEqualTo: status.toString());
    }

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => StockRecommendation.fromJson(doc.data() as Map<String, dynamic>))
        .toList();
  }

  static Stream<List<StockRecommendation>> getRecommendationsStream({
    RecommendationStatus? status,
    int limit = 50,
  }) {
    Query query = _firestore
        .collection(_recommendationsCollection)
        .orderBy('createdAt', descending: true)
        .limit(limit);

    if (status != null) {
      query = query.where('status', isEqualTo: status.toString());
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => StockRecommendation.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  static Future<void> updateRecommendation(
    String recommendationId,
    Map<String, dynamic> data,
  ) async {
    await _firestore
        .collection(_recommendationsCollection)
        .doc(recommendationId)
        .update(data);
  }

  static Future<void> deleteRecommendation(String recommendationId) async {
    await _firestore
        .collection(_recommendationsCollection)
        .doc(recommendationId)
        .delete();
  }

  // Analytics Methods
  static Future<Map<String, dynamic>> getPerformanceStats() async {
    final recommendations = await getRecommendations();
    
    final totalRecos = recommendations.length;
    final profitableRecos = recommendations.where((r) => r.isProfit).length;
    final successRate = totalRecos > 0 ? (profitableRecos / totalRecos) * 100 : 0.0;
    
    final avgReturn = totalRecos > 0
        ? recommendations.map((r) => r.returnPercentage).reduce((a, b) => a + b) / totalRecos
        : 0.0;

    return {
      'totalRecommendations': totalRecos,
      'profitableRecommendations': profitableRecos,
      'successRate': successRate,
      'averageReturn': avgReturn,
    };
  }
}
