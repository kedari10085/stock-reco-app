import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/theme_service.dart';
import '../services/auth_service.dart';
import '../services/revenue_cat_service.dart';
import '../services/newsletter_service.dart';
import 'auth/login_screen.dart';
import 'about_screen.dart';
import 'terms_conditions_screen.dart';
import 'help_center_screen.dart';
import 'edit_profile_screen.dart';
import 'security_screen.dart';
import 'privacy_screen.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeService = Provider.of<ThemeService>(context);
    final authService = Provider.of<AuthService>(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Account & Settings',
                style: GoogleFonts.roboto(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              
              // Profile Card
              _buildProfileCard(context, isDark, authService),
              const SizedBox(height: 24),
              
              // Subscription Section
              _buildSectionTitle('Subscription', isDark),
              const SizedBox(height: 12),
              _buildSubscriptionCard(context, isDark, authService),
              const SizedBox(height: 24),
              
              // Newsletter Section
              _buildSectionTitle('Newsletter', isDark),
              const SizedBox(height: 12),
              _buildNewsletterCard(context, isDark, authService),
              const SizedBox(height: 24),
              
              // Preferences Section
              _buildSectionTitle('Preferences', isDark),
              const SizedBox(height: 12),
              _buildSettingCard(
                context,
                'Dark Mode',
                'Switch between light and dark theme',
                Icons.dark_mode_rounded,
                isDark,
                trailing: Switch(
                  value: themeService.isDarkMode,
                  onChanged: (value) {
                    themeService.toggleTheme();
                  },
                  activeThumbColor: Colors.deepPurple[700],
                ),
              ),
              _buildSettingCard(
                context,
                'Notifications',
                'Manage push notification preferences',
                Icons.notifications_rounded,
                isDark,
              ),
              _buildSettingCard(
                context,
                'Language',
                'English (US)',
                Icons.language_rounded,
                isDark,
              ),
              const SizedBox(height: 24),
              
              // Account Section
              _buildSectionTitle('Account', isDark),
              const SizedBox(height: 12),
              _buildSettingCard(
                context,
                'Edit Profile',
                'Update your personal information',
                Icons.person_rounded,
                isDark,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EditProfileScreen(),
                    ),
                  );
                },
              ),
              _buildSettingCard(
                context,
                'Security',
                'Password and authentication settings',
                Icons.security_rounded,
                isDark,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SecurityScreen(),
                    ),
                  );
                },
              ),
              _buildSettingCard(
                context,
                'Privacy',
                'Control your data and privacy',
                Icons.privacy_tip_rounded,
                isDark,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PrivacyScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              
              // Support Section
              _buildSectionTitle('Support', isDark),
              const SizedBox(height: 12),
              _buildSettingCard(
                context,
                'Help Center',
                'Get help and support',
                Icons.help_rounded,
                isDark,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HelpCenterScreen(),
                    ),
                  );
                },
              ),
              _buildSettingCard(
                context,
                'Terms & Conditions',
                'Read our terms and policies',
                Icons.description_rounded,
                isDark,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TermsConditionsScreen(),
                    ),
                  );
                },
              ),
              _buildSettingCard(
                context,
                'About',
                'App version and information',
                Icons.info_rounded,
                isDark,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AboutScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              
              // Logout Button
              _buildLogoutButton(context, isDark, authService),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context, bool isDark, AuthService authService) {
    final user = authService.currentUser;
    final displayName = user?.displayName ?? 'User';
    final email = user?.email ?? 'user@example.com';
    
    // Safe initials generation
    String initials = 'U';
    try {
      final nameParts = displayName.trim().split(' ').where((part) => part.isNotEmpty).toList();
      if (nameParts.isNotEmpty) {
        initials = nameParts.map((n) => n[0]).take(2).join().toUpperCase();
      }
    } catch (e) {
      initials = 'U'; // Fallback to 'U' for User
    }
    
    // Determine status badge
    String statusText;
    Color statusColor;
    
    if (authService.isAdmin) {
      statusText = 'Admin';
      statusColor = Colors.amber;
    } else if (authService.subscriptionStatus == SubscriptionStatus.freeForever) {
      final userNum = authService.userNumber ?? 0;
      statusText = 'Free Forever (#$userNum)';
      statusColor = Colors.green;
    } else if (authService.subscriptionStatus == SubscriptionStatus.premium) {
      statusText = 'Premium Member';
      statusColor = Colors.green;
    } else if (authService.subscriptionStatus == SubscriptionStatus.trial) {
      statusText = 'Trial (7 days)';
      statusColor = Colors.orange;
    } else {
      statusText = 'Expired';
      statusColor = Colors.red;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.deepPurple[700]!, Colors.deepPurple[500]!],
                ),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  initials,
                  style: const TextStyle(
                    fontSize: 28,
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
                    displayName,
                    style: GoogleFonts.roboto(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email,
                    style: GoogleFonts.roboto(
                      fontSize: 14,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      statusText,
                      style: GoogleFonts.roboto(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit_rounded),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Edit profile feature coming soon!'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionCard(BuildContext context, bool isDark, AuthService authService) {
    final status = authService.subscriptionStatus;
    final userNumber = authService.userNumber ?? 0;
    
    String planTitle;
    String planSubtitle;
    String statusText;
    Color statusColor;
    String? billingInfo;
    bool showUpgradeButton = false;
    
    if (authService.isAdmin) {
      planTitle = 'Admin Account';
      planSubtitle = 'Full access to all features';
      statusText = 'Active';
      statusColor = Colors.amber;
    } else if (status == SubscriptionStatus.freeForever) {
      planTitle = 'Free Forever Plan';
      planSubtitle = 'User #$userNumber - Early adopter benefit';
      statusText = 'Active';
      statusColor = Colors.green;
    } else if (status == SubscriptionStatus.premium) {
      planTitle = 'Premium Plan';
      planSubtitle = '₹299/month';
      statusText = 'Active';
      statusColor = Colors.green;
      billingInfo = 'Next billing: ${DateTime.now().add(const Duration(days: 30)).toString().split(' ')[0]}';
    } else if (status == SubscriptionStatus.trial) {
      planTitle = 'Trial Period';
      planSubtitle = '7-day free trial';
      statusText = 'Trial';
      statusColor = Colors.orange;
      billingInfo = 'Trial ends: ${DateTime.now().add(const Duration(days: 7)).toString().split(' ')[0]}';
      showUpgradeButton = true;
    } else {
      planTitle = 'Subscription Expired';
      planSubtitle = 'Upgrade to access recommendations';
      statusText = 'Expired';
      statusColor = Colors.red;
      showUpgradeButton = true;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        planTitle,
                        style: GoogleFonts.roboto(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        planSubtitle,
                        style: GoogleFonts.roboto(
                          fontSize: 14,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    statusText,
                    style: GoogleFonts.roboto(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            if (billingInfo != null) ...[
              const SizedBox(height: 16),
              Divider(color: isDark ? Colors.grey[700] : Colors.grey[300]),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    size: 16,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                  const SizedBox(width: 8),
                  Text(
                    billingInfo,
                    style: GoogleFonts.roboto(
                      fontSize: 14,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
            if (showUpgradeButton) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    // RevenueCat integration placeholder
                    final error = await authService.upgradeToPremium();
                    if (context.mounted) {
                      if (error != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(error), backgroundColor: Colors.red),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Upgraded to Premium! (Demo)'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple[700],
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Upgrade to Premium - ₹299/month'),
                ),
              ),
              ] else if (!authService.isAdmin) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () async {
                    final revenueCatService = Provider.of<RevenueCatService>(context, listen: false);
                    final success = await revenueCatService.restorePurchases();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(success 
                            ? 'Purchases restored successfully!' 
                            : 'No active purchases found'),
                          backgroundColor: success ? Colors.green : Colors.orange,
                        ),
                      );
                    }
                  },
                  child: const Text('Restore Purchases'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: GoogleFonts.roboto(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildSettingCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    bool isDark, {
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
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
        trailing: trailing ??
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
        onTap: onTap ??
            () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$title feature coming soon!'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, bool isDark, AuthService authService) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(
                'Logout',
                style: GoogleFonts.roboto(fontWeight: FontWeight.bold),
              ),
              content: Text(
                'Are you sure you want to logout?',
                style: GoogleFonts.roboto(),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    final authService = Provider.of<AuthService>(context, listen: false);
                    await authService.signOut();
                    if (context.mounted) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (route) => false,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Logout'),
                ),
              ],
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.logout_rounded),
            const SizedBox(width: 8),
            Text(
              'Logout',
              style: GoogleFonts.roboto(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewsletterCard(BuildContext context, bool isDark, AuthService authService) {
    final newsletterService = NewsletterService();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.email_rounded,
                  color: Colors.blue[600],
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Email Updates',
                        style: GoogleFonts.roboto(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Get weekly market insights and recommendations',
                        style: GoogleFonts.roboto(
                          fontSize: 12,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Subscription Status
            FutureBuilder<bool>(
              future: authService.currentUser?.email != null 
                  ? newsletterService.isUserSubscribed(authService.currentUser!.email!)
                  : Future.value(false),
              builder: (context, snapshot) {
                final isSubscribed = snapshot.data ?? false;
                
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                return Column(
                  children: [
                    if (isSubscribed) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          border: Border.all(color: Colors.green[200]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.green[600], size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'You\'re subscribed to our newsletter',
                              style: GoogleFonts.roboto(
                                color: Colors.green[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () async {
                            final email = authService.currentUser?.email;
                            if (email != null) {
                              final success = await newsletterService.unsubscribeFromNewsletter(email);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(success 
                                        ? 'Unsubscribed successfully' 
                                        : 'Failed to unsubscribe'),
                                    backgroundColor: success ? Colors.orange : Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                          child: const Text('Unsubscribe'),
                        ),
                      ),
                    ] else ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          border: Border.all(color: Colors.blue[200]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Stay Updated!',
                              style: GoogleFonts.roboto(
                                color: Colors.blue[700],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Subscribe to receive:\n• Weekly market analysis\n• New stock recommendations\n• Performance updates',
                              style: GoogleFonts.roboto(
                                color: Colors.blue[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final email = authService.currentUser?.email;
                            if (email != null) {
                              final success = await newsletterService.subscribeToNewsletter(email);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(success 
                                        ? 'Successfully subscribed to newsletter!' 
                                        : 'Failed to subscribe'),
                                    backgroundColor: success ? Colors.green : Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                          icon: const Icon(Icons.mail_outline),
                          label: const Text('Subscribe to Newsletter'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[600],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
            
            const SizedBox(height: 12),
            Text(
              'Privacy: We respect your inbox. Unsubscribe anytime.',
              style: GoogleFonts.roboto(
                fontSize: 10,
                color: isDark ? Colors.grey[500] : Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
