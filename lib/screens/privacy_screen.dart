import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({super.key});

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  bool _analyticsEnabled = true;
  bool _personalizedAds = false;
  bool _newsletterEnabled = true;
  bool _notificationSounds = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Privacy & Data',
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
            // Privacy Overview
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                border: Border.all(color: Colors.blue[200]!),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.privacy_tip_rounded, color: Colors.blue[600], size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your Privacy Matters',
                          style: GoogleFonts.roboto(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700],
                          ),
                        ),
                        Text(
                          'Control how your data is used and shared',
                          style: GoogleFonts.roboto(
                            fontSize: 12,
                            color: Colors.blue[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Data Collection
            Text(
              'Data Collection & Usage',
              style: GoogleFonts.roboto(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            _buildPrivacyCard(
              context,
              'Analytics & Performance',
              'Help us improve the app by sharing usage data',
              Icons.analytics_rounded,
              trailing: Switch(
                value: _analyticsEnabled,
                onChanged: (value) {
                  setState(() {
                    _analyticsEnabled = value;
                  });
                },
              ),
            ),

            _buildPrivacyCard(
              context,
              'Personalized Recommendations',
              'Allow personalized stock recommendations based on your activity',
              Icons.person_rounded,
              trailing: Switch(
                value: _personalizedAds,
                onChanged: (value) {
                  setState(() {
                    _personalizedAds = value;
                  });
                },
              ),
            ),

            const SizedBox(height: 24),

            // Communication Preferences
            Text(
              'Communication Preferences',
              style: GoogleFonts.roboto(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            _buildPrivacyCard(
              context,
              'Newsletter Subscription',
              'Receive weekly market insights and updates',
              Icons.email_rounded,
              trailing: Switch(
                value: _newsletterEnabled,
                onChanged: (value) {
                  setState(() {
                    _newsletterEnabled = value;
                  });
                },
              ),
            ),

            _buildPrivacyCard(
              context,
              'Notification Sounds',
              'Play sounds for push notifications',
              Icons.notifications_rounded,
              trailing: Switch(
                value: _notificationSounds,
                onChanged: (value) {
                  setState(() {
                    _notificationSounds = value;
                  });
                },
              ),
            ),

            const SizedBox(height: 24),

            // Data Management
            Text(
              'Data Management',
              style: GoogleFonts.roboto(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            _buildPrivacyCard(
              context,
              'Download My Data',
              'Export all your personal data',
              Icons.download_rounded,
              onTap: () {
                _showDownloadDataDialog();
              },
            ),

            _buildPrivacyCard(
              context,
              'Data Usage Summary',
              'View how your data is being used',
              Icons.summarize_rounded,
              onTap: () {
                _showDataUsageDialog();
              },
            ),

            _buildPrivacyCard(
              context,
              'Clear Cache',
              'Remove locally stored data',
              Icons.cleaning_services_rounded,
              onTap: () {
                _showClearCacheDialog();
              },
            ),

            const SizedBox(height: 24),

            // Legal & Policies
            Text(
              'Legal & Policies',
              style: GoogleFonts.roboto(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            _buildPrivacyCard(
              context,
              'Privacy Policy',
              'Read our complete privacy policy',
              Icons.description_rounded,
              onTap: () {
                _showPrivacyPolicyDialog();
              },
            ),

            _buildPrivacyCard(
              context,
              'Cookie Policy',
              'Learn about our cookie usage',
              Icons.cookie_rounded,
              onTap: () {
                _showCookiePolicyDialog();
              },
            ),

            const SizedBox(height: 24),

            // Contact Privacy Team
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Privacy Concerns?',
                      style: GoogleFonts.roboto(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'If you have any privacy-related questions or concerns, our privacy team is here to help.',
                      style: GoogleFonts.roboto(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _contactPrivacyTeam();
                        },
                        icon: const Icon(Icons.email_rounded),
                        label: const Text('Contact Privacy Team'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple[700],
                        ),
                      ),
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

  Widget _buildPrivacyCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon, {
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
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
        trailing: trailing ??
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: Colors.grey[400],
            ),
        onTap: onTap,
      ),
    );
  }

  void _showDownloadDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Download Your Data',
          style: GoogleFonts.roboto(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'We\'ll prepare a comprehensive report of all your personal data. This process may take a few minutes.',
              style: GoogleFonts.roboto(fontSize: 14),
            ),
            const SizedBox(height: 16),
            Text(
              'Data included:\n• Profile information\n• Investment preferences\n• Newsletter subscriptions\n• Usage statistics',
              style: GoogleFonts.roboto(fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Data export request submitted! You\'ll receive an email when ready.'),
                ),
              );
            },
            child: const Text('Request Export'),
          ),
        ],
      ),
    );
  }

  void _showDataUsageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Data Usage Summary',
          style: GoogleFonts.roboto(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDataUsageItem('Profile Data', 'Used for personalization', '2.1 KB'),
            _buildDataUsageItem('Preferences', 'Investment settings', '1.5 KB'),
            _buildDataUsageItem('Analytics', 'App improvement', '856 B'),
            const Divider(),
            _buildDataUsageItem('Total', 'All data stored', '4.4 KB'),
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

  Widget _buildDataUsageItem(String title, String description, String size) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.roboto(fontWeight: FontWeight.w600),
                ),
                Text(
                  description,
                  style: GoogleFonts.roboto(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Text(
            size,
            style: GoogleFonts.roboto(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple[700],
            ),
          ),
        ],
      ),
    );
  }

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Clear Cache',
          style: GoogleFonts.roboto(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'This will remove locally stored data including cached recommendations and temporary files.',
              style: GoogleFonts.roboto(fontSize: 14),
            ),
            const SizedBox(height: 16),
            Text(
              'Note: This will not affect your account data or cloud-stored information.',
              style: GoogleFonts.roboto(fontSize: 12, color: Colors.orange[600]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cache cleared successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
            child: const Text('Clear Cache'),
          ),
        ],
      ),
    );
  }

  void _showCookiePolicyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Cookie Policy',
          style: GoogleFonts.roboto(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'We use cookies to enhance your experience:',
                style: GoogleFonts.roboto(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildCookieItem('Essential Cookies', 'Required for basic app functionality'),
              _buildCookieItem('Analytics Cookies', 'Help us understand app usage'),
              _buildCookieItem('Preference Cookies', 'Remember your settings'),
              _buildCookieItem('Marketing Cookies', 'Personalized recommendations'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Accept All'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Customize'),
          ),
        ],
      ),
    );
  }

  Widget _buildCookieItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ', style: GoogleFonts.roboto(fontSize: 16)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.roboto(fontWeight: FontWeight.w600),
                ),
                Text(
                  description,
                  style: GoogleFonts.roboto(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _contactPrivacyTeam() {
    final Uri uri = Uri(
      scheme: 'mailto',
      path: 'support@stockreco.com',
      query: 'subject=Privacy%20Concern&body=Please%20describe%20your%20privacy%20question%20or%20issue.',
    );
    launchUrl(uri).then((opened) {
      if (!opened && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to open email client. Please email support@stockreco.com.'),
          ),
        );
      }
    });
  }

  void _showPrivacyPolicyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Privacy Policy',
          style: GoogleFonts.roboto(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'We collect and process limited personal data to deliver personalised stock recommendations, newsletters, and market insights. Key practices include:',
                style: GoogleFonts.roboto(fontSize: 14),
              ),
              const SizedBox(height: 12),
              Text(
                '• Account & Profile: Used to protect access, tailor dashboard content, and deliver admin or premium features.',
                style: GoogleFonts.roboto(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Text(
                '• Investment Preferences: Power personalised and premium recommendations while respecting your analytics choices.',
                style: GoogleFonts.roboto(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Text(
                '• Subscription & Billing: RevenueCat manages purchases; we receive entitlement status only, never full payment details.',
                style: GoogleFonts.roboto(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Text(
                '• Market Activity: Live feeds and notifications rely on aggregated usage metrics to keep services reliable.',
                style: GoogleFonts.roboto(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Text(
                '• Communications: Emails and push notifications are sent only when you opt in, and you can adjust preferences anytime.',
                style: GoogleFonts.roboto(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 12),
              Text(
                'Your data is stored securely with Firebase, and we never sell personal information. To request deletion, export data, or raise a concern, email support@stockreco.com.',
                style: GoogleFonts.roboto(fontSize: 12, color: Colors.grey),
              ),
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
