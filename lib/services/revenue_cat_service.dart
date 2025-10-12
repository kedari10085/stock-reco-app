import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RevenueCatService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isPremium = false;
  bool _isInitialized = false;

  bool get isPremium => _isPremium;
  bool get isInitialized => _isInitialized;

  /// Initialize RevenueCat (Demo Mode)
  Future<void> initialize() async {
    try {
      debugPrint('🛒 Initializing RevenueCat (Demo Mode)...');
      
      // Demo mode - just mark as initialized
      _isInitialized = true;
      notifyListeners();
      
      debugPrint('✅ RevenueCat initialized successfully (Demo Mode)');
    } catch (e) {
      debugPrint('❌ RevenueCat initialization error: $e');
    }
  }

  /// Login user to RevenueCat (Demo Mode)
  Future<void> loginUser(String userId) async {
    debugPrint('🛒 User logged in to RevenueCat (Demo Mode): $userId');
    // Demo mode - no actual RevenueCat calls
  }

  /// Purchase monthly subscription (Demo Mode)
  Future<bool> purchaseMonthlySubscription() async {
    debugPrint('🛒 Purchase attempt (Demo Mode) - would show success');
    // In demo mode, simulate successful purchase
    return true;
  }

  /// Restore purchases (Demo Mode)
  Future<bool> restorePurchases() async {
    debugPrint('🛒 Restore purchases (Demo Mode) - no purchases found');
    return false;
  }

  /// Check for free forever eligibility (Demo Mode)
  Future<bool> checkFreeForeverEligibility() async {
    debugPrint('🛒 Free forever check (Demo Mode) - checking Firestore only');
    
    try {
      final user = _auth.currentUser;
      if (user == null) {
        debugPrint('🛒 No authenticated user for free forever check');
        return false;
      }

      final userDoc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        final userNumber = userDoc.data()?['user_number'] as int?;
        final subscriptionStatus = userDoc.data()?['subscription_status'] as String?;
        
        debugPrint('🛒 Free forever check - User #$userNumber, Status: $subscriptionStatus');
        
        if (userNumber != null && userNumber <= 1000) {
          debugPrint('✅ User #$userNumber has free forever access');
          _isPremium = true;
          notifyListeners();
          return true;
        }
      }
      return false;
    } catch (e) {
      debugPrint('❌ Error checking free forever eligibility: $e');
      return false;
    }
  }

  /// Logout user from RevenueCat (Demo Mode)
  Future<void> logout() async {
    debugPrint('🛒 User logged out from RevenueCat (Demo Mode)');
    _isPremium = false;
    notifyListeners();
  }
}
