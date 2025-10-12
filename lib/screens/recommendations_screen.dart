import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/recommendation_service.dart';
import '../services/auth_service.dart';
import '../services/revenue_cat_service.dart';
import '../widgets/paywall_overlay.dart';
import 'package:intl/intl.dart';

class RecommendationsScreen extends StatefulWidget {
  const RecommendationsScreen({super.key});

  @override
  State<RecommendationsScreen> createState() => _RecommendationsScreenState();
}

class _RecommendationsScreenState extends State<RecommendationsScreen> {
  final RecommendationService _recommendationService = RecommendationService();
  bool _isInitialized = false;
  bool _isOffline = false;
  bool _showPaywall = false;

  @override
  void initState() {
    super.initState();
    _initializeService();
  }

  Future<void> _initializeService() async {
    try {
      await _recommendationService.initialize();
      setState(() => _isInitialized = true);
    } catch (e) {
      debugPrint('Error initializing recommendation service: $e');
      setState(() {
        _isInitialized = true;
        _isOffline = true;
      });
    }
  }

  @override
  void dispose() {
    _recommendationService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authService = Provider.of<AuthService>(context);
    final revenueCatService = Provider.of<RevenueCatService>(context);

    if (!_isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Check if user needs paywall
    final needsPaywall = !authService.hasFullAccess && authService.needsSubscription;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Stock Recommendations',
                        style: GoogleFonts.roboto(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh_rounded),
                        onPressed: () async {
                          await _recommendationService.refreshPrices();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Prices refreshed!'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        tooltip: 'Refresh Prices',
                      ),
                    ],
                  ),
                  if (_isOffline)
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.cloud_off_rounded, 
                            color: Colors.orange, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            'Offline Mode - Showing cached data',
                            style: GoogleFonts.roboto(
                              fontSize: 12,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            // Recommendations List
            Expanded(
              child: Stack(
                children: [
                  _isOffline
                      ? _buildOfflineList(isDark)
                      : _buildOnlineList(isDark, authService),
                  
                  // Paywall overlay
                  if (needsPaywall && _showPaywall)
                    PaywallOverlay(
                      onDismiss: () {
                        setState(() => _showPaywall = false);
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOnlineList(bool isDark, AuthService authService) {
    // Check if user is authenticated before showing stream
    if (!authService.isAuthenticated) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.login_rounded,
              size: 64,
              color: isDark ? Colors.grey[700] : Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Please log in to view recommendations',
              style: GoogleFonts.roboto(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    return StreamBuilder<List<RecommendationData>>(
      stream: _recommendationService.getRecommendationsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          // Handle permission denied error specifically
          final errorMessage = snapshot.error.toString();
          if (errorMessage.contains('PERMISSION_DENIED') || errorMessage.contains('Missing or insufficient permissions')) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock_outline, size: 64, color: Colors.orange[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Access Restricted',
                    style: GoogleFonts.roboto(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please log in to view recommendations',
                    style: GoogleFonts.roboto(
                      fontSize: 12,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                const SizedBox(height: 16),
                Text(
                  'Error loading recommendations',
                  style: GoogleFonts.roboto(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  errorMessage,
                  style: GoogleFonts.roboto(
                    fontSize: 12,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        final recommendations = snapshot.data ?? [];

        if (recommendations.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inbox_rounded,
                  size: 64,
                  color: isDark ? Colors.grey[700] : Colors.grey[300],
                ),
                const SizedBox(height: 16),
                Text(
                  'No recommendations yet',
                  style: GoogleFonts.roboto(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  authService.isAdmin
                      ? 'Add your first recommendation from the admin panel'
                      : 'Check back soon for new recommendations',
                  style: GoogleFonts.roboto(
                    fontSize: 14,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        // Show paywall for non-premium users
        if (!authService.hasFullAccess && authService.needsSubscription) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!_showPaywall) {
              setState(() => _showPaywall = true);
            }
          });
        }

        return RefreshIndicator(
          onRefresh: () async {
            await _recommendationService.refreshPrices();
          },
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: recommendations.length,
            itemBuilder: (context, index) {
              return _buildRecommendationCard(
                context,
                recommendations[index],
                isDark,
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildOfflineList(bool isDark) {
    return FutureBuilder<List<RecommendationData>>(
      future: _recommendationService.getCachedRecommendations(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final recommendations = snapshot.data ?? [];

        if (recommendations.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.cloud_off_rounded, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No cached data available',
                  style: GoogleFonts.roboto(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  'Connect to internet to load recommendations',
                  style: GoogleFonts.roboto(
                    fontSize: 12,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: recommendations.length,
          itemBuilder: (context, index) {
            return _buildRecommendationCard(
              context,
              recommendations[index],
              isDark,
            );
          },
        );
      },
    );
  }

  Widget _buildRecommendationCard(
    BuildContext context,
    RecommendationData recommendation,
    bool isDark,
  ) {
    final returnColor = recommendation.isProfit ? Colors.green : Colors.red;
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showRecommendationDetails(context, recommendation, isDark),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          recommendation.stockName,
                          style: GoogleFonts.roboto(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          recommendation.ticker,
                          style: GoogleFonts.roboto(
                            fontSize: 12,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (recommendation.currentPrice != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: returnColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${recommendation.isProfit ? '+' : ''}${recommendation.returnPercent.toStringAsFixed(2)}%',
                        style: GoogleFonts.roboto(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: returnColor,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // Price Information
              Row(
                children: [
                  Expanded(
                    child: _buildPriceInfo(
                      'Buy Price',
                      '₹${recommendation.buyPrice.toStringAsFixed(2)}',
                      isDark,
                    ),
                  ),
                  Expanded(
                    child: _buildPriceInfo(
                      'Current',
                      recommendation.currentPrice != null
                          ? '₹${recommendation.currentPrice!.toStringAsFixed(2)}'
                          : 'Loading...',
                      isDark,
                      color: returnColor,
                    ),
                  ),
                  Expanded(
                    child: _buildPriceInfo(
                      'Target',
                      '₹${recommendation.targetPrice.toStringAsFixed(2)}',
                      isDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Rationale Preview
              Text(
                recommendation.rationale.length > 100
                    ? '${recommendation.rationale.substring(0, 97)}...'
                    : recommendation.rationale,
                style: GoogleFonts.roboto(
                  fontSize: 13,
                  color: isDark ? Colors.grey[300] : Colors.grey[700],
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),

              // Footer Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 14,
                        color: isDark ? Colors.grey[500] : Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        dateFormat.format(recommendation.addedDate),
                        style: GoogleFonts.roboto(
                          fontSize: 12,
                          color: isDark ? Colors.grey[500] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  if (recommendation.lastPriceUpdate != null)
                    Row(
                      children: [
                        Icon(
                          Icons.update_rounded,
                          size: 14,
                          color: isDark ? Colors.grey[500] : Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _getTimeAgo(recommendation.lastPriceUpdate!),
                          style: GoogleFonts.roboto(
                            fontSize: 12,
                            color: isDark ? Colors.grey[500] : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriceInfo(String label, String value, bool isDark, {Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.roboto(
            fontSize: 11,
            color: isDark ? Colors.grey[500] : Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.roboto(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  void _showRecommendationDetails(
    BuildContext context,
    RecommendationData recommendation,
    bool isDark,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[700] : Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Stock Name
                Text(
                  recommendation.stockName,
                  style: GoogleFonts.roboto(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  recommendation.ticker,
                  style: GoogleFonts.roboto(
                    fontSize: 14,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 24),

                // Price Details
                _buildDetailRow('Buy Price', '₹${recommendation.buyPrice.toStringAsFixed(2)}', isDark),
                _buildDetailRow('Current Price', 
                  recommendation.currentPrice != null 
                    ? '₹${recommendation.currentPrice!.toStringAsFixed(2)}'
                    : 'Loading...', 
                  isDark),
                _buildDetailRow('Target Price', '₹${recommendation.targetPrice.toStringAsFixed(2)}', isDark),
                _buildDetailRow('Return', 
                  '${recommendation.isProfit ? '+' : ''}${recommendation.returnPercent.toStringAsFixed(2)}%',
                  isDark,
                  valueColor: recommendation.isProfit ? Colors.green : Colors.red),
                _buildDetailRow('Target Return', 
                  '+${recommendation.targetReturnPercent.toStringAsFixed(2)}%',
                  isDark,
                  valueColor: Colors.blue),
                
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),

                // Rationale
                Text(
                  'Rationale',
                  style: GoogleFonts.roboto(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  recommendation.rationale,
                  style: GoogleFonts.roboto(
                    fontSize: 14,
                    height: 1.6,
                    color: isDark ? Colors.grey[300] : Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 24),

                // Additional Info
                _buildDetailRow('Added By', recommendation.addedBy, isDark),
                _buildDetailRow('Exchange', recommendation.exchange, isDark),
                _buildDetailRow('Added Date', 
                  DateFormat('MMM dd, yyyy HH:mm').format(recommendation.addedDate),
                  isDark),
                if (recommendation.lastPriceUpdate != null)
                  _buildDetailRow('Last Updated', 
                    DateFormat('MMM dd, yyyy HH:mm').format(recommendation.lastPriceUpdate!),
                    isDark),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, bool isDark, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.roboto(
              fontSize: 14,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: GoogleFonts.roboto(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}
