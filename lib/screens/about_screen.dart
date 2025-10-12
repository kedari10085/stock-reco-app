import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'About',
          style: GoogleFonts.roboto(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App Logo/Icon
            Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.deepPurple[700],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.trending_up_rounded,
                  size: 40,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // App Name and Version
            Center(
              child: Column(
                children: [
                  Text(
                    'StockReco',
                    style: GoogleFonts.roboto(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Version 1.0.0',
                    style: GoogleFonts.roboto(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // App Description
            Text(
              'About StockReco',
              style: GoogleFonts.roboto(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'StockReco is your intelligent stock market companion, designed to help you make informed investment decisions. We provide curated stock recommendations, real-time market insights, and comprehensive portfolio tracking tools.',
              style: GoogleFonts.roboto(
                fontSize: 16,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 24),

            // Features Section
            Text(
              'Key Features',
              style: GoogleFonts.roboto(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildFeatureItem(
              Icons.analytics_rounded,
              'Smart Recommendations',
              'AI-powered stock analysis and curated investment suggestions',
            ),
            _buildFeatureItem(
              Icons.trending_up_rounded,
              'Live Market Data',
              'Real-time stock prices, market indices, and portfolio tracking',
            ),
            _buildFeatureItem(
              Icons.notifications_rounded,
              'Push Notifications',
              'Stay updated with market alerts and recommendation updates',
            ),
            _buildFeatureItem(
              Icons.email_rounded,
              'Newsletter',
              'Weekly market insights and performance reports',
            ),
            const SizedBox(height: 32),

            // Contact Information
            Text(
              'Contact Us',
              style: GoogleFonts.roboto(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildContactItem(
              Icons.email_rounded,
              'Email',
              'support@stockreco.com',
            ),
            _buildContactItem(
              Icons.phone_rounded,
              'Phone',
              '+91 98765 43210',
            ),
            _buildContactItem(
              Icons.location_on_rounded,
              'Location',
              'Mumbai, Maharashtra, India',
            ),
            const SizedBox(height: 32),

            // Copyright
            Center(
              child: Text(
                '© 2025 StockReco. All rights reserved.',
                style: GoogleFonts.roboto(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.deepPurple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Colors.deepPurple[700],
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.roboto(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.roboto(
                    fontSize: 14,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.grey[600],
            size: 20,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.roboto(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.roboto(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
