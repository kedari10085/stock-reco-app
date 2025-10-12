import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/biometric_service.dart';
import '../services/auth_service.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  bool _isLoading = false;
  bool _loginAlerts = true;
  bool _fingerprintEnabled = false;
  late BiometricService _biometricService;

  @override
  void initState() {
    super.initState();
    _biometricService = Provider.of<BiometricService>(context, listen: false);
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    await _biometricService.initialize();
    setState(() {
      _loginAlerts = true; // Default value, can be loaded from preferences if needed
      _fingerprintEnabled = _biometricService.isBiometricEnabled;
    });
  }

  Future<void> _savePreferences() async {
    // Preferences are saved in BiometricService
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Security',
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
            // Security Overview
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[50],
                border: Border.all(color: Colors.green[200]!),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.security_rounded, color: Colors.green[600], size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Account Security',
                          style: GoogleFonts.roboto(
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                          ),
                        ),
                        Text(
                          'Your account is protected with email authentication${_fingerprintEnabled ? ' and fingerprint' : ''}',
                          style: GoogleFonts.roboto(
                            fontSize: 12,
                            color: Colors.green[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Password Section
            Text(
              'Password & Authentication',
              style: GoogleFonts.roboto(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildSecurityCard(
              context,
              'Change Password',
              'Update your account password',
              Icons.lock_rounded,
              onTap: () {
                _showChangePasswordDialog();
              },
            ),

            _buildSecurityCard(
              context,
              'Fingerprint Authentication',
              'Use fingerprint to unlock the app',
              Icons.fingerprint_rounded,
              subtitle2: _fingerprintEnabled ? 'Enabled' : 'Disabled',
              trailing: Switch(
                value: _fingerprintEnabled,
                onChanged: (value) {
                  _toggleFingerprint(value);
                },
              ),
              onTap: () {
                _toggleFingerprint(!_fingerprintEnabled);
              },
            ),

            _buildSecurityCard(
              context,
              'Login Sessions',
              'Manage active sessions',
              Icons.devices_rounded,
              subtitle2: '1 active session',
              onTap: () {
                _showActiveSessions();
              },
            ),
            const SizedBox(height: 24),

            // Account Security
            Text(
              'Account Security',
              style: GoogleFonts.roboto(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildSecurityCard(
              context,
              'Email Verification',
              'Verify your email address',
              Icons.email_rounded,
              onTap: () {
                _verifyEmail();
              },
            ),

            _buildSecurityCard(
              context,
              'Security Questions',
              'Set up security questions for account recovery',
              Icons.question_answer_rounded,
              subtitle2: 'Not set up',
              onTap: () {
                _showSecurityQuestionsDialog();
              },
            ),

            _buildSecurityCard(
              context,
              'Login Alerts',
              'Get notified of new login attempts',
              Icons.notifications_active_rounded,
              trailing: Switch(
                value: _loginAlerts,
                onChanged: (value) {
                  setState(() {
                    _loginAlerts = value;
                  });
                  _savePreferences();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Login alerts ${value ? 'enabled' : 'disabled'}')),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // Danger Zone
            Text(
              'Danger Zone',
              style: GoogleFonts.roboto(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 12),
            _buildSecurityCard(
              context,
              'Delete Account',
              'Permanently delete your account and all data',
              Icons.delete_forever_rounded,
              isDanger: true,
              onTap: () {
                _showDeleteAccountDialog();
              },
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon, {
    String? subtitle2,
    Widget? trailing,
    bool isDanger = false,
    VoidCallback? onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDanger
                ? Colors.red.withOpacity(0.1)
                : Colors.deepPurple.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: isDanger ? Colors.red : Colors.deepPurple[700],
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: GoogleFonts.roboto(
            fontWeight: FontWeight.w600,
            color: isDanger ? Colors.red : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              subtitle,
              style: GoogleFonts.roboto(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            if (subtitle2 != null)
              Text(
                subtitle2,
                style: GoogleFonts.roboto(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
          ],
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

  Future<void> _toggleFingerprint(bool value) async {
    if (value) {
      // Enable fingerprint
      try {
        await _biometricService.enableBiometrics();
        setState(() {
          _fingerprintEnabled = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fingerprint authentication enabled')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to enable fingerprint: $e')),
        );
      }
    } else {
      // Disable fingerprint
      await _biometricService.disableBiometrics();
      setState(() {
        _fingerprintEnabled = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fingerprint authentication disabled')),
      );
    }
  }

  void _showChangePasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Change Password',
          style: GoogleFonts.roboto(fontWeight: FontWeight.bold),
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: currentPasswordController,
                decoration: InputDecoration(
                  labelText: 'Current Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.lock),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your current password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: newPasswordController,
                decoration: InputDecoration(
                  labelText: 'New Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.lock_outline),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: confirmPasswordController,
                decoration: InputDecoration(
                  labelText: 'Confirm New Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.lock_outline),
                ),
                obscureText: true,
                validator: (value) {
                  if (value != newPasswordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                setState(() {
                  _isLoading = true;
                });

                try {
                  // Note: Firebase Auth doesn't support changing password directly
                  // You would need to reauthenticate and update
                  // For now, show a message that this feature needs backend implementation
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Password change requires re-authentication. Please use forgot password for now.'),
                      duration: Duration(seconds: 4),
                    ),
                  );
                  Navigator.pop(context);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to change password: $e')),
                  );
                } finally {
                  setState(() {
                    _isLoading = false;
                  });
                }
              }
            },
            child: const Text('Change Password'),
          ),
        ],
      ),
    );
  }

  void _showActiveSessions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Active Sessions',
          style: GoogleFonts.roboto(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSessionItem(
              'Current Session',
              'Android App • Active now',
              true,
            ),
            const Divider(),
            _buildSessionItem(
              'Web Browser',
              'Chrome on Windows • 2 hours ago',
              false,
            ),
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

  Widget _buildSessionItem(String title, String subtitle, bool isCurrent) {
    return ListTile(
      title: Text(
        title,
        style: GoogleFonts.roboto(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.roboto(fontSize: 12),
      ),
      trailing: isCurrent
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green[100],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Current',
                style: GoogleFonts.roboto(
                  fontSize: 10,
                  color: Colors.green[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : IconButton(
              icon: const Icon(Icons.logout_rounded, size: 20),
              onPressed: () {},
            ),
    );
  }

  Future<void> _verifyEmail() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      await authService.sendEmailVerification();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification email sent! Check your inbox.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send verification email: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSecurityQuestionsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Security Questions',
          style: GoogleFonts.roboto(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Security questions help us verify your identity for account recovery. This feature will be available in a future update.',
              style: GoogleFonts.roboto(fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete Account',
          style: GoogleFonts.roboto(
            fontWeight: FontWeight.bold,
            color: Colors.red,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Are you sure you want to delete your account? This action cannot be undone and will permanently remove all your data.',
              style: GoogleFonts.roboto(fontSize: 14),
            ),
            const SizedBox(height: 16),
            Text(
              'Type "DELETE" to confirm:',
              style: GoogleFonts.roboto(fontSize: 12),
            ),
            const SizedBox(height: 8),
            TextField(
              decoration: InputDecoration(
                hintText: 'Type DELETE to confirm',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
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
              // Delete account logic here
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Account deletion feature coming soon!'),
                ),
              );
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete Account'),
          ),
        ],
      ),
    );
  }
}

