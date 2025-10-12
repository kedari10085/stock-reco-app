import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Terms & Conditions',
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
            // Last Updated
            Center(
              child: Text(
                'Last updated: January 9, 2025',
                style: GoogleFonts.roboto(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Terms Content
            _buildSectionTitle('1. Acceptance of Terms'),
            _buildSectionContent(
              'By accessing and using StockReco, you accept and agree to be bound by the terms and provision of this agreement. If you do not agree to abide by the above, please do not use this service.',
            ),
            const SizedBox(height: 20),

            _buildSectionTitle('2. Investment Disclaimer'),
            _buildSectionContent(
              'StockReco provides stock recommendations and market analysis for informational purposes only. The recommendations do not constitute investment advice, and we do not guarantee the accuracy, completeness, or timeliness of the information provided. Always conduct your own research and consult with a qualified financial advisor before making investment decisions.',
            ),
            const SizedBox(height: 20),

            _buildSectionTitle('3. User Accounts'),
            _buildSectionContent(
              'You are responsible for maintaining the confidentiality of your account and password. You agree to accept responsibility for all activities that occur under your account or password. StockReco reserves the right to terminate accounts, remove or edit content at our sole discretion.',
            ),
            const SizedBox(height: 20),

            _buildSectionTitle('4. Subscription and Billing'),
            _buildSectionContent(
              'Premium subscriptions are billed monthly. You can cancel your subscription at any time. Refunds are provided at our discretion for unused portions of paid subscriptions. Free Forever accounts are granted to early adopters and cannot be transferred.',
            ),
            const SizedBox(height: 20),

            _buildSectionTitle('5. Data Privacy'),
            _buildSectionContent(
              'We collect and use personal information in accordance with our Privacy Policy. By using our service, you consent to such collection and use. We implement appropriate security measures to protect your personal information.',
            ),
            const SizedBox(height: 20),

            _buildSectionTitle('6. Intellectual Property'),
            _buildSectionContent(
              'The StockReco app, website, and all related content are protected by copyright, trademark, and other intellectual property laws. You may not reproduce, distribute, or create derivative works without our express written consent.',
            ),
            const SizedBox(height: 20),

            _buildSectionTitle('7. Limitation of Liability'),
            _buildSectionContent(
              'StockReco shall not be liable for any indirect, incidental, special, consequential, or punitive damages resulting from your use of our service. Our total liability shall not exceed the amount paid by you for the service.',
            ),
            const SizedBox(height: 20),

            _buildSectionTitle('8. Service Availability'),
            _buildSectionContent(
              'We strive to maintain continuous service availability but do not guarantee that the service will be uninterrupted or error-free. We reserve the right to modify, suspend, or discontinue the service at any time.',
            ),
            const SizedBox(height: 20),

            _buildSectionTitle('9. User Conduct'),
            _buildSectionContent(
              'You agree not to use the service for any unlawful purposes or to conduct any unlawful activity, including but not limited to fraud, embezzlement, money laundering, or insider trading.',
            ),
            const SizedBox(height: 20),

            _buildSectionTitle('10. Modifications to Terms'),
            _buildSectionContent(
              'We reserve the right to modify these terms at any time. Changes will be effective immediately upon posting. Your continued use of the service constitutes acceptance of the modified terms.',
            ),
            const SizedBox(height: 20),

            _buildSectionTitle('11. Governing Law'),
            _buildSectionContent(
              'These terms shall be governed by and construed in accordance with the laws of India. Any disputes arising from these terms shall be subject to the exclusive jurisdiction of the courts in Mumbai, Maharashtra.',
            ),
            const SizedBox(height: 20),

            _buildSectionTitle('12. Contact Information'),
            _buildSectionContent(
              'If you have any questions about these Terms and Conditions, please contact us at support@stockreco.com or +91 98765 43210.',
            ),
            const SizedBox(height: 32),

            // Agreement
            Center(
              child: Text(
                'By using StockReco, you acknowledge that you have read, understood, and agree to be bound by these Terms and Conditions.',
                style: GoogleFonts.roboto(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.roboto(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildSectionContent(String content) {
    return Text(
      content,
      style: GoogleFonts.roboto(
        fontSize: 16,
        height: 1.6,
        color: Colors.grey[700],
      ),
    );
  }
}
