import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/newsletter_service.dart';
import '../services/live_feeds_service.dart';
import '../services/ipo_service.dart';
import '../models/newsletter.dart';
import '../models/ipo.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
              _buildWelcomeCard(context, isDark),
              const SizedBox(height: 20),
              
              // Live Market Feeds
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Live Market',
                    style: GoogleFonts.roboto(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () {
                      Provider.of<LiveFeedsService>(context, listen: false).refresh();
                    },
                    tooltip: 'Refresh',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildLiveFeeds(context, isDark),
              const SizedBox(height: 24),
              
              // Quick Stats
              Text(
                'Quick Overview',
                style: GoogleFonts.roboto(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _buildQuickStats(context, isDark),
              const SizedBox(height: 24),
              
              // Recent Recommendations
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Recommendations',
                    style: GoogleFonts.roboto(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text('View All'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildRecentRecommendations(context, isDark),
              const SizedBox(height: 24),
              
              // Newsletter Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Latest Updates',
                    style: GoogleFonts.roboto(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text('View All'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildNewsletterSection(context, isDark),
              const SizedBox(height: 24),
              
              // IPO Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Current IPOs',
                    style: GoogleFonts.roboto(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text('View All'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildIPOSection(context, isDark),
              const SizedBox(height: 24),
              
              // Performance Summary
              Text(
                'Performance Summary',
                style: GoogleFonts.roboto(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _buildPerformanceSummary(context, isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(BuildContext context, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [Colors.deepPurple[800]!, Colors.deepPurple[600]!]
              : [Colors.deepPurple[700]!, Colors.deepPurple[500]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome Back!',
            style: GoogleFonts.roboto(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Track your stock recommendations and performance',
            style: GoogleFonts.roboto(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.trending_up, color: Colors.green[300], size: 20),
              const SizedBox(width: 8),
              Text(
                'Market is Open',
                style: GoogleFonts.roboto(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context, bool isDark) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            'Active Recos',
            '12',
            Icons.recommend_rounded,
            Colors.blue,
            isDark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            'Avg Return',
            '+15.2%',
            Icons.trending_up,
            Colors.green,
            isDark,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
    bool isDark,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 24),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    value,
                    style: GoogleFonts.roboto(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.roboto(
                fontSize: 12,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentRecommendations(BuildContext context, bool isDark) {
    final recommendations = [
      {
        'name': 'TCS',
        'type': 'BUY',
        'return': '+8.5%',
        'date': '2 days ago',
      },
      {
        'name': 'Reliance',
        'type': 'SELL',
        'return': '+12.3%',
        'date': '5 days ago',
      },
      {
        'name': 'Infosys',
        'type': 'BUY',
        'return': '+5.7%',
        'date': '1 week ago',
      },
    ];

    return Column(
      children: recommendations
          .map((reco) => _buildRecommendationCard(context, reco, isDark))
          .toList(),
    );
  }

  Widget _buildRecommendationCard(
    BuildContext context,
    Map<String, String> reco,
    bool isDark,
  ) {
    final isBuy = reco['type'] == 'BUY';
    final returnValue = reco['return']!;
    final isProfit = returnValue.startsWith('+');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isBuy ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            isBuy ? Icons.arrow_upward : Icons.arrow_downward,
            color: isBuy ? Colors.green : Colors.red,
            size: 20,
          ),
        ),
        title: Text(
          reco['name']!,
          style: GoogleFonts.roboto(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          reco['date']!,
          style: GoogleFonts.roboto(
            fontSize: 12,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isProfit
                ? Colors.green.withOpacity(0.1)
                : Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            returnValue,
            style: GoogleFonts.roboto(
              fontWeight: FontWeight.bold,
              color: isProfit ? Colors.green : Colors.red,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPerformanceSummary(BuildContext context, bool isDark) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildPerformanceItem('Success Rate', '75%', Colors.green, isDark),
                Container(
                  width: 1,
                  height: 40,
                  color: isDark ? Colors.grey[700] : Colors.grey[300],
                ),
                _buildPerformanceItem('Total Recos', '48', Colors.blue, isDark),
                Container(
                  width: 1,
                  height: 40,
                  color: isDark ? Colors.grey[700] : Colors.grey[300],
                ),
                _buildPerformanceItem('This Month', '8', Colors.orange, isDark),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceItem(
    String label,
    String value,
    Color color,
    bool isDark,
  ) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.roboto(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.roboto(
            fontSize: 12,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildLiveFeeds(BuildContext context, bool isDark) {
    return Consumer<LiveFeedsService>(
      builder: (context, feedsService, child) {
        if (feedsService.isLoading && feedsService.niftyData == null) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        if (feedsService.errorMessage != null && feedsService.niftyData == null) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                  const SizedBox(height: 8),
                  Text(
                    'Failed to load market data',
                    style: GoogleFonts.roboto(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    feedsService.errorMessage!,
                    style: GoogleFonts.roboto(
                      fontSize: 12,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          children: [
            // Market indices row
            Row(
              children: [
                Expanded(
                  child: _buildMarketCard(
                    context,
                    feedsService.niftyData,
                    Icons.trending_up,
                    Colors.blue,
                    isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMarketCard(
                    context,
                    feedsService.sensexData,
                    Icons.bar_chart,
                    Colors.green,
                    isDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Nifty 50 and Gold row
            Row(
              children: [
                Expanded(
                  child: _buildMarketCard(
                    context,
                    feedsService.nifty50Data,
                    Icons.show_chart,
                    Colors.purple,
                    isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildGoldCard(
                    context,
                    feedsService.goldData,
                    isDark,
                  ),
                ),
              ],
            ),
            if (feedsService.lastUpdate != null) ...[
              const SizedBox(height: 8),
              Text(
                'Last updated: ${_formatTime(feedsService.lastUpdate!)}',
                style: GoogleFonts.roboto(
                  fontSize: 10,
                  color: isDark ? Colors.grey[500] : Colors.grey[500],
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildMarketCard(
    BuildContext context,
    MarketData? data,
    IconData icon,
    Color color,
    bool isDark,
  ) {
    if (data == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Icon(icon, color: Colors.grey, size: 20),
              const SizedBox(height: 4),
              Text(
                'Loading...',
                style: GoogleFonts.roboto(fontSize: 10),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: InkWell(
        onTap: () {
          // Show detailed view
          _showMarketDetails(context, data);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: 16),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      data.symbol,
                      style: GoogleFonts.roboto(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '₹${data.price.toStringAsFixed(2)}',
                style: GoogleFonts.roboto(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Icon(
                    data.isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                    size: 12,
                    color: data.isPositive ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    '${data.change >= 0 ? '+' : ''}${data.change.toStringAsFixed(2)}',
                    style: GoogleFonts.roboto(
                      fontSize: 10,
                      color: data.isPositive ? Colors.green : Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '(${data.changePercent >= 0 ? '+' : ''}${data.changePercent.toStringAsFixed(2)}%)',
                    style: GoogleFonts.roboto(
                      fontSize: 9,
                      color: data.isPositive ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGoldCard(BuildContext context, GoldData? data, bool isDark) {
    if (data == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Icon(Icons.monetization_on, color: Colors.grey, size: 20),
              const SizedBox(height: 4),
              Text(
                'Loading...',
                style: GoogleFonts.roboto(fontSize: 10),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: InkWell(
        onTap: () {
          _showGoldDetails(context, data);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.monetization_on, color: Colors.amber[700], size: 16),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'GOLD',
                      style: GoogleFonts.roboto(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '₹${data.pricePerOunce.toStringAsFixed(2)}',
                style: GoogleFonts.roboto(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Icon(
                    data.isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                    size: 12,
                    color: data.isPositive ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    '${data.change >= 0 ? '+' : ''}${data.change.toStringAsFixed(2)}',
                    style: GoogleFonts.roboto(
                      fontSize: 10,
                      color: data.isPositive ? Colors.green : Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '(${data.changePercent >= 0 ? '+' : ''}${data.changePercent.toStringAsFixed(2)}%)',
                    style: GoogleFonts.roboto(
                      fontSize: 9,
                      color: data.isPositive ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMarketDetails(BuildContext context, MarketData data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          data.name,
          style: GoogleFonts.roboto(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Symbol', data.symbol),
            _buildDetailRow('Current Price', '₹${data.price.toStringAsFixed(2)}'),
            _buildDetailRow('Change', '${data.change >= 0 ? '+' : ''}${data.change.toStringAsFixed(2)}'),
            _buildDetailRow('Change %', '${data.changePercent >= 0 ? '+' : ''}${data.changePercent.toStringAsFixed(2)}%'),
            _buildDetailRow('Last Update', _formatTime(data.lastUpdate)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showGoldDetails(BuildContext context, GoldData data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Gold Price',
          style: GoogleFonts.roboto(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Price per Ounce', '₹${data.pricePerOunce.toStringAsFixed(2)}'),
            _buildDetailRow('Currency', data.currency),
            _buildDetailRow('Change', '${data.change >= 0 ? '+' : ''}${data.change.toStringAsFixed(2)}'),
            _buildDetailRow('Change %', '${data.changePercent >= 0 ? '+' : ''}${data.changePercent.toStringAsFixed(2)}%'),
            _buildDetailRow('Last Update', _formatTime(data.lastUpdate)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.roboto(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: GoogleFonts.roboto(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${time.day}/${time.month}/${time.year} ${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    }
  }

  Widget _buildIPOSection(BuildContext context, bool isDark) {
    final ipoService = IPOService();
    
    return StreamBuilder<List<IPO>>(
      stream: ipoService.getOpenIPOsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        if (snapshot.hasError) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Error loading IPOs: ${snapshot.error}'),
            ),
          );
        }

        final ipos = snapshot.data ?? [];

        if (ipos.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Icon(
                    Icons.business_center,
                    size: 48,
                    color: isDark ? Colors.grey[600] : Colors.grey[400],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No IPOs currently open',
                    style: GoogleFonts.roboto(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: ipos.take(5).length,
            itemBuilder: (context, index) {
              final ipo = ipos[index];
              return Container(
                width: 280,
                margin: const EdgeInsets.only(right: 12),
                child: Card(
                  child: InkWell(
                    onTap: () => _showIPODetails(context, ipo),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.business_center,
                                size: 20,
                                color: Colors.blue[600],
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  ipo.name,
                                  style: GoogleFonts.roboto(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            ipo.symbol,
                            style: GoogleFonts.roboto(
                              fontSize: 12,
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Price: ${ipo.priceRange}',
                            style: GoogleFonts.roboto(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Lot Size: ${ipo.lotSize}',
                            style: GoogleFonts.roboto(
                              fontSize: 12,
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                          const Spacer(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Closes: ${ipo.closeDate.day}/${ipo.closeDate.month}',
                                style: GoogleFonts.roboto(
                                  fontSize: 10,
                                  color: Colors.red[600],
                                ),
                              ),
                              FutureBuilder<IPORecommendation?>(
                                future: IPOService().getIPORecommendation(ipo.id),
                                builder: (context, recSnapshot) {
                                  final recommendation = recSnapshot.data;
                                  if (recommendation != null) {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: recommendation.recommendationColor.withOpacity(0.1),
                                        border: Border.all(color: recommendation.recommendationColor),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        recommendation.recommendationText,
                                        style: GoogleFonts.roboto(
                                          fontSize: 9,
                                          color: recommendation.recommendationColor,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    );
                                  }
                                  return const SizedBox.shrink();
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _showIPODetails(BuildContext context, IPO ipo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          ipo.name,
          style: GoogleFonts.roboto(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Symbol', ipo.symbol),
              _buildDetailRow('Price Range', ipo.priceRange),
              _buildDetailRow('Lot Size', ipo.lotSize),
              _buildDetailRow('Open Date', '${ipo.openDate.day}/${ipo.openDate.month}/${ipo.openDate.year}'),
              _buildDetailRow('Close Date', '${ipo.closeDate.day}/${ipo.closeDate.month}/${ipo.closeDate.year}'),
              if (ipo.description != null) ...[
                const SizedBox(height: 12),
                Text(
                  'Description',
                  style: GoogleFonts.roboto(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  ipo.description!,
                  style: GoogleFonts.roboto(fontSize: 12),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsletterSection(BuildContext context, bool isDark) {
    final newsletterService = NewsletterService();
    
    return StreamBuilder<List<Newsletter>>(
      stream: newsletterService.getNewslettersStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        if (snapshot.hasError) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Error loading updates: ${snapshot.error}'),
            ),
          );
        }

        final newsletters = snapshot.data ?? [];

        if (newsletters.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Icon(
                    Icons.newspaper,
                    size: 48,
                    color: isDark ? Colors.grey[600] : Colors.grey[400],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No updates yet',
                    style: GoogleFonts.roboto(
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: newsletters.take(5).length,
            itemBuilder: (context, index) {
              final newsletter = newsletters[index];
              return Container(
                width: 280,
                margin: const EdgeInsets.only(right: 12),
                child: Card(
                  child: InkWell(
                    onTap: () => _showNewsletterDialog(context, newsletter),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.article,
                                size: 20,
                                color: Colors.blue[600],
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  newsletter.title,
                                  style: GoogleFonts.roboto(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Expanded(
                            child: Text(
                              newsletter.body,
                              style: GoogleFonts.roboto(
                                fontSize: 12,
                                color: isDark ? Colors.grey[400] : Colors.grey[600],
                              ),
                              maxLines: 4,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${newsletter.publishDate.day}/${newsletter.publishDate.month}/${newsletter.publishDate.year}',
                                style: GoogleFonts.roboto(
                                  fontSize: 10,
                                  color: isDark ? Colors.grey[500] : Colors.grey[500],
                                ),
                              ),
                              if (newsletter.tags.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.blue[100],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    newsletter.tags.first,
                                    style: GoogleFonts.roboto(
                                      fontSize: 10,
                                      color: Colors.blue[800],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _showNewsletterDialog(BuildContext context, Newsletter newsletter) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          newsletter.title,
          style: GoogleFonts.roboto(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Published: ${newsletter.publishDate.day}/${newsletter.publishDate.month}/${newsletter.publishDate.year}',
                style: GoogleFonts.roboto(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                newsletter.body,
                style: GoogleFonts.roboto(fontSize: 14),
              ),
              if (newsletter.tags.isNotEmpty) ...[
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  children: newsletter.tags.map((tag) => Chip(
                    label: Text(
                      tag,
                      style: GoogleFonts.roboto(fontSize: 12),
                    ),
                    backgroundColor: Colors.blue[100],
                  )).toList(),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
