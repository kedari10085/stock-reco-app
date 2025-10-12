import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tickerController = TextEditingController();
  final _buyPriceController = TextEditingController();
  final _targetPriceController = TextEditingController();
  final _rationaleController = TextEditingController();
  
  bool _isLoading = false;
  String? _selectedExchange = 'NSE';
  
  final List<String> _exchanges = ['NSE', 'BSE'];

  @override
  void dispose() {
    _tickerController.dispose();
    _buyPriceController.dispose();
    _targetPriceController.dispose();
    _rationaleController.dispose();
    super.dispose();
  }

  Future<void> _saveRecommendation() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final adminEmail = authService.currentUser?.email ?? 'admin';

      // Prepare ticker with exchange suffix
      final tickerSymbol = _selectedExchange == 'NSE'
          ? '${_tickerController.text.toUpperCase()}.NS'
          : '${_tickerController.text.toUpperCase()}.BO';

      // Create recommendation document
      final docRef = FirebaseFirestore.instance.collection('recommendations').doc();
      
      final recommendationData = {
        'id': docRef.id,
        'ticker': tickerSymbol,
        'stock_name': _tickerController.text.toUpperCase(),
        'buy_price': double.parse(_buyPriceController.text),
        'target_price': double.parse(_targetPriceController.text),
        'rationale': _rationaleController.text,
        'status': 'active',
        'added_date': FieldValue.serverTimestamp(),
        'added_by': adminEmail,
        'exchange': _selectedExchange,
        'current_price': null, // Will be updated by price service
        'last_price_update': null,
      };

      // Save to Firestore
      await docRef.set(recommendationData);

      // Send FCM notification to all users
      await _sendNotificationToAllUsers(
        ticker: tickerSymbol,
        rationale: _rationaleController.text,
        recoId: docRef.id,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Recommendation added successfully!'),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'View',
              textColor: Colors.white,
              onPressed: () => Navigator.pop(context),
            ),
          ),
        );

        // Clear form
        _tickerController.clear();
        _buyPriceController.clear();
        _targetPriceController.clear();
        _rationaleController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _sendNotificationToAllUsers({
    required String ticker,
    required String rationale,
    required String recoId,
  }) async {
    try {
      // Get FCM instance
      final messaging = FirebaseMessaging.instance;

      // Subscribe to topic (if not already subscribed)
      await messaging.subscribeToTopic('all_users');

      // Note: Actual FCM notification sending requires a backend server
      // This is a placeholder for the notification data structure
      // In production, you would call a Cloud Function or backend API
      
      final notificationData = {
        'title': 'New Reco: $ticker',
        'body': rationale.length > 100 
            ? '${rationale.substring(0, 97)}...' 
            : rationale,
        'data': {
          'screen': 'recos',
          'reco_id': recoId,
          'ticker': ticker,
          'click_action': 'FLUTTER_NOTIFICATION_CLICK',
        },
      };

      // TODO: Call Cloud Function to send FCM notification
      // Example: await http.post('your-cloud-function-url', body: notificationData);
      
      debugPrint('Notification prepared: $notificationData');
      
    } catch (e) {
      debugPrint('Error sending notification: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded),
            onPressed: () {
              // TODO: Navigate to recommendations history
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('History feature coming soon!')),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(
                  'Add Stock Recommendation',
                  style: GoogleFonts.roboto(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Create a new stock recommendation for all users',
                  style: GoogleFonts.roboto(
                    fontSize: 14,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 32),

                // Stock Ticker Field
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextFormField(
                        controller: _tickerController,
                        decoration: InputDecoration(
                          labelText: 'Stock Ticker *',
                          hintText: 'e.g., RELIANCE, TCS, INFY',
                          prefixIcon: const Icon(Icons.trending_up_rounded),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        textCapitalization: TextCapitalization.characters,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z]')),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter stock ticker';
                          }
                          if (value.length < 2) {
                            return 'Ticker too short';
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 1,
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedExchange,
                        decoration: InputDecoration(
                          labelText: 'Exchange',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: _exchanges.map((exchange) {
                          return DropdownMenuItem(
                            value: exchange,
                            child: Text(exchange),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => _selectedExchange = value);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Buy Price Field
                TextFormField(
                  controller: _buyPriceController,
                  decoration: InputDecoration(
                    labelText: 'Buy Price (₹) *',
                    hintText: 'e.g., 2500.50',
                    prefixIcon: const Icon(Icons.currency_rupee_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter buy price';
                    }
                    final price = double.tryParse(value);
                    if (price == null || price <= 0) {
                      return 'Enter valid price';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Target Price Field
                TextFormField(
                  controller: _targetPriceController,
                  decoration: InputDecoration(
                    labelText: 'Target Price (₹) *',
                    hintText: 'e.g., 3000.00',
                    prefixIcon: const Icon(Icons.flag_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter target price';
                    }
                    final targetPrice = double.tryParse(value);
                    final buyPrice = double.tryParse(_buyPriceController.text);
                    
                    if (targetPrice == null || targetPrice <= 0) {
                      return 'Enter valid price';
                    }
                    if (buyPrice != null && targetPrice <= buyPrice) {
                      return 'Target must be higher than buy price';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Rationale Field
                TextFormField(
                  controller: _rationaleController,
                  decoration: InputDecoration(
                    labelText: 'Rationale *',
                    hintText: 'Why is this a good recommendation?',
                    prefixIcon: const Icon(Icons.notes_rounded),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 4,
                  maxLength: 500,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter rationale';
                    }
                    if (value.length < 20) {
                      return 'Rationale too short (min 20 characters)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Info Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_rounded, color: Colors.blue[700]),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'All users will receive a push notification when you save this recommendation.',
                          style: GoogleFonts.roboto(
                            fontSize: 13,
                            color: isDark ? Colors.blue[200] : Colors.blue[900],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveRecommendation,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple[700],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.send_rounded),
                              const SizedBox(width: 8),
                              Text(
                                'Save & Notify Users',
                                style: GoogleFonts.roboto(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
