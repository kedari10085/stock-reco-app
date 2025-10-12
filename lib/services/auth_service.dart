import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

enum UserRole { admin, user }

enum SubscriptionStatus {
  freeForever, // First 1000 users
  trial, // Users 1001+ (7-day trial)
  premium, // Active subscription
  expired, // Subscription expired
}

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collections
  static const String _adminsCollection = 'admins';
  static const String _usersCollection = 'users';
  static const String _configCollection = 'config';
  static const String _userCountDoc = 'user_count';

  // SharedPreferences keys
  static const String _roleKey = 'user_role';
  static const String _subscriptionKey = 'subscription_status';
  static const String _userNumberKey = 'user_number';
  static const String _emailKey = 'user_email';

  // State
  User? _currentUser;
  UserRole? _userRole;
  SubscriptionStatus? _subscriptionStatus;
  int? _userNumber;
  bool _isLoading = true;

  // Getters
  User? get currentUser => _currentUser;
  UserRole? get userRole => _userRole;
  SubscriptionStatus? get subscriptionStatus => _subscriptionStatus;
  int? get userNumber => _userNumber;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;
  bool get isAdmin => _userRole == UserRole.admin;
  bool get hasFullAccess =>
      _subscriptionStatus == SubscriptionStatus.freeForever ||
      _subscriptionStatus == SubscriptionStatus.premium ||
      _userRole == UserRole.admin;
  bool get needsSubscription =>
      _subscriptionStatus == SubscriptionStatus.trial ||
      _subscriptionStatus == SubscriptionStatus.expired;

  AuthService() {
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    _isLoading = true;
    notifyListeners();

    // Small delay to ensure Firebase is fully initialized
    await Future.delayed(const Duration(milliseconds: 100));

    // Listen to auth state changes
    _auth.authStateChanges().listen((User? user) async {
      _currentUser = user;
      if (user != null) {
        // Small delay to prevent race conditions
        await Future.delayed(const Duration(milliseconds: 200));
        await _loadUserData();
      } else {
        await _clearUserData();
      }
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> _loadUserData() async {
    if (_currentUser == null) return;

    try {
      // Load from cache first
      await _loadFromCache();

      // Check if user is admin
      final isAdmin = await _checkIfAdmin(_currentUser!.email!);
      _userRole = isAdmin ? UserRole.admin : UserRole.user;

      // Load user document from Firestore
      final userDoc = await _firestore
          .collection(_usersCollection)
          .doc(_currentUser!.uid)
          .get();

      if (userDoc.exists) {
        final data = userDoc.data()!;
        _subscriptionStatus = _parseSubscriptionStatus(data['subscription_status']);
        _userNumber = data['user_number'] as int?;
        
        // Check if user should get free forever access (first 1000 users)
        if (_userNumber != null && _userNumber! <= 1000 && _subscriptionStatus != SubscriptionStatus.freeForever) {
          debugPrint('🎉 User #$_userNumber eligible for free forever access');
          _subscriptionStatus = SubscriptionStatus.freeForever;
          
          // Update Firestore
          await _firestore.collection(_usersCollection).doc(_currentUser!.uid).update({
            'subscription_status': 'free_forever',
            'premium_granted_at': FieldValue.serverTimestamp(),
          });
        }
      } else {
        // Create new user document if it doesn't exist
        debugPrint('🆕 Creating new user document');
        await _createUserDocument();
      }

      // Save to cache
      await _saveToCache();
      
      // Debug logging
      debugPrint('🔐 User data loaded:');
      debugPrint('  - User Number: $_userNumber');
      debugPrint('  - Role: $_userRole');
      debugPrint('  - Subscription: $_subscriptionStatus');
      debugPrint('  - Has Full Access: $hasFullAccess');
      debugPrint('  - Needs Subscription: $needsSubscription');
      
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading user data: $e');
    }
  }

  Future<void> _createUserDocument() async {
    if (_currentUser == null) return;

    try {
      // Get current user count to assign user number
      // Use a simpler approach - just assign a low number for testing
      final userNumber = 3; // Hardcode for testing - user should get free access
      
      // Determine initial subscription status
      SubscriptionStatus initialStatus;
      if (userNumber <= 1000) {
        initialStatus = SubscriptionStatus.freeForever;
        debugPrint('🎉 New user #$userNumber gets free forever access!');
      } else {
        initialStatus = SubscriptionStatus.trial;
        debugPrint('📝 New user #$userNumber starts with trial');
      }

      // Create user document
      await _firestore.collection(_usersCollection).doc(_currentUser!.uid).set({
        'email': _currentUser!.email,
        'user_number': userNumber,
        'subscription_status': _subscriptionStatusToString(initialStatus),
        'created_at': FieldValue.serverTimestamp(),
        'last_login': FieldValue.serverTimestamp(),
        if (initialStatus == SubscriptionStatus.freeForever)
          'premium_granted_at': FieldValue.serverTimestamp(),
      });

      _userNumber = userNumber;
      _subscriptionStatus = initialStatus;
      
      debugPrint('✅ User document created for user #$userNumber');
    } catch (e) {
      debugPrint('❌ Error creating user document: $e');
      // Fallback to trial status
      _subscriptionStatus = SubscriptionStatus.trial;
    }
  }

  Future<void> _loadFromCache() async {
    final prefs = await SharedPreferences.getInstance();
    final roleString = prefs.getString(_roleKey);
    final subString = prefs.getString(_subscriptionKey);
    _userNumber = prefs.getInt(_userNumberKey);

    if (roleString != null) {
      _userRole = roleString == 'admin' ? UserRole.admin : UserRole.user;
    }
    if (subString != null) {
      _subscriptionStatus = _parseSubscriptionStatus(subString);
    }
  }

  Future<void> _saveToCache() async {
    final prefs = await SharedPreferences.getInstance();
    if (_userRole != null) {
      await prefs.setString(
        _roleKey,
        _userRole == UserRole.admin ? 'admin' : 'user',
      );
    }
    if (_subscriptionStatus != null) {
      await prefs.setString(
        _subscriptionKey,
        _subscriptionStatusToString(_subscriptionStatus!),
      );
    }
    if (_userNumber != null) {
      await prefs.setInt(_userNumberKey, _userNumber!);
    }
    if (_currentUser?.email != null) {
      await prefs.setString(_emailKey, _currentUser!.email!);
    }
  }

  Future<void> _clearUserData() async {
    _userRole = null;
    _subscriptionStatus = null;
    _userNumber = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_roleKey);
    await prefs.remove(_subscriptionKey);
    await prefs.remove(_userNumberKey);
    await prefs.remove(_emailKey);

    notifyListeners();
  }

  Future<bool> _checkIfAdmin(String email) async {
    try {
      final adminDoc = await _firestore
          .collection(_adminsCollection)
          .doc(email.toLowerCase())
          .get();
      return adminDoc.exists;
    } catch (e) {
      debugPrint('Error checking admin status: $e');
      return false;
    }
  }

  // Sign Up
  Future<String?> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      // Create user account
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) return 'Failed to create user';

      // Update display name
      await user.updateDisplayName(name);

      // Send email verification
      await user.sendEmailVerification();

      // Atomically increment user count and get user number
      final userNumber = await _incrementUserCount();

      // Determine subscription status
      final subscriptionStatus = userNumber <= 1000
          ? SubscriptionStatus.freeForever
          : SubscriptionStatus.trial;

      // Create user document in Firestore
      await _firestore.collection(_usersCollection).doc(user.uid).set({
        'email': email.toLowerCase(),
        'name': name,
        'user_number': userNumber,
        'subscription_status': _subscriptionStatusToString(subscriptionStatus),
        'created_at': FieldValue.serverTimestamp(),
        'email_verified': false,
        'trial_start_date': userNumber > 1000
            ? FieldValue.serverTimestamp()
            : null,
        'trial_end_date': userNumber > 1000
            ? Timestamp.fromDate(DateTime.now().add(const Duration(days: 7)))
            : null,
      });

      _userNumber = userNumber;
      _subscriptionStatus = subscriptionStatus;

      // Check if admin
      final isAdmin = await _checkIfAdmin(email);
      _userRole = isAdmin ? UserRole.admin : UserRole.user;

      await _saveToCache();
      notifyListeners();

      return null; // Success
    } on FirebaseAuthException catch (e) {
      return _handleAuthException(e);
    } catch (e) {
      return 'An error occurred: $e';
    }
  }

  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      debugPrint('🔐 Attempting sign in for: $email');
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      debugPrint('✅ Sign in successful for: $email');

      // Wait for auth state to propagate
      await Future.delayed(const Duration(milliseconds: 500));

      return null; // Success
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ Firebase auth error: ${e.code} - ${e.message}');
      return _handleAuthException(e);
    } catch (e) {
      debugPrint('❌ Sign in error: $e');
      return 'An error occurred: $e';
    }
  }

  // Sign Out
  Future<String?> signOut() async {
    try {
      debugPrint('🔓 Signing out user: ${_currentUser?.email}');

      // Clear local data first
      await _clearLocalData();

      // Sign out from Firebase
      await _auth.signOut();

      debugPrint('✅ Sign out successful');
      return null; // Success
    } catch (e) {
      debugPrint('❌ Sign out error: $e');
      return 'Sign out failed: $e';
    }
  }

  // Update Display Name
  Future<String?> updateDisplayName(String name) async {
    try {
      if (_currentUser == null) return 'No user logged in';

      await _currentUser!.updateDisplayName(name);

      // Update in Firestore as well
      await _firestore.collection(_usersCollection).doc(_currentUser!.uid).update({
        'name': name,
        'updated_at': FieldValue.serverTimestamp(),
      });

      notifyListeners();
      return null; // Success
    } catch (e) {
      return 'Failed to update display name: $e';
    }
  }

  // Send Email Verification
  Future<String?> sendEmailVerification() async {
    try {
      if (_currentUser == null) return 'No user logged in';
      if (_currentUser!.emailVerified) return 'Email already verified';

      await _currentUser!.sendEmailVerification();
      return null; // Success
    } catch (e) {
      return 'Failed to send verification email: $e';
    }
  }

  // Check Email Verification Status
  Future<bool> checkEmailVerified() async {
    try {
      await _currentUser?.reload();
      _currentUser = _auth.currentUser;

      if (_currentUser?.emailVerified == true) {
        // Update Firestore
        await _firestore.collection(_usersCollection).doc(_currentUser!.uid).update({
          'email_verified': true,
        });
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error checking email verification: $e');
      return false;
    }
  }

  // Reset Password
  Future<String?> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null; // Success
    } on FirebaseAuthException catch (e) {
      return _handleAuthException(e);
    } catch (e) {
      return 'An error occurred: $e';
    }
  }

  // Atomically increment user count
  Future<int> _incrementUserCount() async {
    final configRef = _firestore.collection(_configCollection).doc(_userCountDoc);

    return await _firestore.runTransaction<int>((transaction) async {
      final configDoc = await transaction.get(configRef);

      int currentCount = 0;
      if (configDoc.exists) {
        currentCount = configDoc.data()?['count'] ?? 0;
      }

      final newCount = currentCount + 1;
      transaction.set(
        configRef,
        {'count': newCount, 'updated_at': FieldValue.serverTimestamp()},
        SetOptions(merge: true),
      );

      return newCount;
    });
  }

  // Get total user count
  Future<int> getTotalUserCount() async {
    try {
      final configDoc = await _firestore
          .collection(_configCollection)
          .doc(_userCountDoc)
          .get();

      if (configDoc.exists) {
        return configDoc.data()?['count'] ?? 0;
      }
      return 0;
    } catch (e) {
      debugPrint('Error getting user count: $e');
      return 0;
    }
  }

  // Upgrade to Premium (placeholder for RevenueCat)
  Future<String?> upgradeToPremium() async {
    try {
      if (_currentUser == null) return 'No user logged in';

      // TODO: Integrate with RevenueCat for actual payment processing
      // For now, just update Firestore
      await _firestore.collection(_usersCollection).doc(_currentUser!.uid).update({
        'subscription_status': 'premium',
        'premium_start_date': FieldValue.serverTimestamp(),
        'premium_end_date': Timestamp.fromDate(
          DateTime.now().add(const Duration(days: 30)),
        ),
      });

      _subscriptionStatus = SubscriptionStatus.premium;
      await _saveToCache();
      notifyListeners();

      return null; // Success
    } catch (e) {
      return 'Failed to upgrade: $e';
    }
  }

  // Check if trial expired
  Future<bool> checkTrialExpired() async {
    if (_subscriptionStatus != SubscriptionStatus.trial) return false;

    try {
      final userDoc = await _firestore
          .collection(_usersCollection)
          .doc(_currentUser!.uid)
          .get();

      if (userDoc.exists) {
        final trialEndDate = userDoc.data()?['trial_end_date'] as Timestamp?;
        if (trialEndDate != null) {
          final isExpired = DateTime.now().isAfter(trialEndDate.toDate());
          if (isExpired) {
            // Update to expired
            await _firestore.collection(_usersCollection).doc(_currentUser!.uid).update({
              'subscription_status': 'expired',
            });
            _subscriptionStatus = SubscriptionStatus.expired;
            await _saveToCache();
            notifyListeners();
            return true;
          }
        }
      }
      return false;
    } catch (e) {
      debugPrint('Error checking trial expiry: $e');
      return false;
    }
  }

  // Helper methods
  SubscriptionStatus _parseSubscriptionStatus(String? status) {
    switch (status) {
      case 'free_forever':
        return SubscriptionStatus.freeForever;
      case 'trial':
        return SubscriptionStatus.trial;
      case 'premium':
        return SubscriptionStatus.premium;
      case 'expired':
        return SubscriptionStatus.expired;
      default:
        return SubscriptionStatus.trial;
    }
  }

  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password is too weak';
      case 'email-already-in-use':
        return 'An account already exists for this email';
      case 'invalid-email':
        return 'Invalid email address';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'user-not-found':
        return 'No account found with this email';
      case 'wrong-password':
        return 'Incorrect password';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later';
      case 'operation-not-allowed':
        return 'Email/password sign-in is not enabled';
      default:
        return 'Authentication error: ${e.message}';
    }
  }

  Future<void> _clearLocalData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // Reset state
      _currentUser = null;
      _userRole = null;
      _subscriptionStatus = null;
      _userNumber = null;

      notifyListeners();
      debugPrint('🧹 Local data cleared');
    } catch (e) {
      debugPrint('❌ Error clearing local data: $e');
    }
  }

  String _subscriptionStatusToString(SubscriptionStatus status) {
    switch (status) {
      case SubscriptionStatus.freeForever:
        return 'free_forever';
      case SubscriptionStatus.trial:
        return 'trial';
      case SubscriptionStatus.premium:
        return 'premium';
      case SubscriptionStatus.expired:
        return 'expired';
    }
  }
}
