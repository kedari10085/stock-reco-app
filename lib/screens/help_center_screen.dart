import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Help Center',
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
            // Header
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.help_outline_rounded,
                    size: 64,
                    color: Colors.deepPurple[700],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'How can we help you?',
                    style: GoogleFonts.roboto(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Find answers to common questions and get support',
                    style: GoogleFonts.roboto(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Quick Actions
            Text(
              'Quick Actions',
              style: GoogleFonts.roboto(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildQuickActionCard(
              context,
              'Contact Support',
              'Get in touch with our support team',
              Icons.email_rounded,
              Colors.blue,
              () => _launchEmail('support@stockreco.com'),
            ),
            _buildQuickActionCard(
              context,
              'Call Us',
              '+91 98765 43210',
              Icons.phone_rounded,
              Colors.green,
              () => _launchPhone('+919876543210'),
            ),
            const SizedBox(height: 32),

            // FAQ Section
            Text(
              'Frequently Asked Questions',
              style: GoogleFonts.roboto(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildFAQItem(
              'How do I get stock recommendations?',
              'Stock recommendations are available in the main dashboard. Premium users get access to curated recommendations with detailed analysis.',
            ),
            _buildFAQItem(
              'How accurate are the recommendations?',
              'Our recommendations are based on thorough market analysis, but stock market investments carry risk. Always do your own research before investing.',
            ),
            _buildFAQItem(
              'Can I track my portfolio?',
              'Yes! The app includes portfolio tracking features where you can monitor your investments and view performance analytics.',
            ),
            _buildFAQItem(
              'How do I upgrade to Premium?',
              'Go to your Account screen and tap on "Upgrade to Premium". You\'ll get access to advanced features and curated recommendations.',
            ),
            _buildFAQItem(
              'What\'s included in the newsletter?',
              'Our weekly newsletter includes market insights, stock analysis, and performance updates on our recommendations.',
            ),
            _buildFAQItem(
              'How do I unsubscribe from notifications?',
              'Go to Account > Preferences > Notifications to manage your notification settings.',
            ),
            const SizedBox(height: 32),

            // Getting Started Guide
            Text(
              'Getting Started',
              style: GoogleFonts.roboto(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildStepItem(
              1,
              'Create Account',
              'Sign up with your email to get started',
            ),
            _buildStepItem(
              2,
              'Explore Dashboard',
              'View market data and stock recommendations',
            ),
            _buildStepItem(
              3,
              'Upgrade (Optional)',
              'Get premium features for advanced analysis',
            ),
            _buildStepItem(
              4,
              'Track Portfolio',
              'Monitor your investments and performance',
            ),
            const SizedBox(height: 32),

            // Contact Support Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Still need help?',
                      style: GoogleFonts.roboto(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Our support team is here to help you with any questions or issues.',
                      style: GoogleFonts.roboto(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _launchEmail('support@stockreco.com'),
                            icon: const Icon(Icons.email_rounded),
                            label: const Text('Email Support'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple[700],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _launchPhone('+919876543210'),
                            icon: const Icon(Icons.phone_rounded),
                            label: const Text('Call Us'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: GoogleFonts.roboto(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.roboto(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
        onTap: onTap,
      ),
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Text(
          question,
          style: GoogleFonts.roboto(
            fontWeight: FontWeight.w600,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              answer,
              style: GoogleFonts.roboto(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepItem(int step, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.deepPurple[700],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                step.toString(),
                style: GoogleFonts.roboto(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
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
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {
        'subject': 'StockReco Support Request',
      },
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  Future<void> _launchPhone(String phone) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phone);

    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }
}
