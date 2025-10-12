import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import '../services/revenue_cat_service.dart';

class PaywallOverlay extends StatefulWidget {
  final VoidCallback? onDismiss;
  
  const PaywallOverlay({
    super.key,
    this.onDismiss,
  });

  @override
  State<PaywallOverlay> createState() => _PaywallOverlayState();
}

class _PaywallOverlayState extends State<PaywallOverlay>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  
  late ConfettiController _confettiController;
  bool _isPurchasing = false;

  @override
  void initState() {
    super.initState();
    
    // Animation controllers
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));
    
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
    
    // Start animations
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 100), () {
      _slideController.forward();
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> _handlePurchase() async {
    if (_isPurchasing) return;
    
    setState(() => _isPurchasing = true);
    
    final revenueCatService = Provider.of<RevenueCatService>(context, listen: false);
    final success = await revenueCatService.purchaseMonthlySubscription();
    
    setState(() => _isPurchasing = false);
    
    if (success) {
      // Show confetti animation
      _confettiController.play();
      
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.celebration, color: Colors.white),
                const SizedBox(width: 8),
                const Text('🎉 Welcome to Premium!'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      
      // Close paywall after delay
      Future.delayed(const Duration(seconds: 2), () {
        _dismissPaywall();
      });
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Purchase failed. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _dismissPaywall() async {
    await _slideController.reverse();
    await _fadeController.reverse();
    if (widget.onDismiss != null) {
      widget.onDismiss!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Stack(
      children: [
        // Background overlay
        FadeTransition(
          opacity: _fadeAnimation,
          child: Container(
            color: Colors.black.withOpacity(0.7),
            child: GestureDetector(
              onTap: _dismissPaywall,
              child: Container(color: Colors.transparent),
            ),
          ),
        ),
        
        // Confetti
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirection: 1.57, // radians - 90 degrees
            particleDrag: 0.05,
            emissionFrequency: 0.05,
            numberOfParticles: 50,
            gravity: 0.05,
            shouldLoop: false,
            colors: const [
              Colors.green,
              Colors.blue,
              Colors.pink,
              Colors.orange,
              Colors.purple,
            ],
          ),
        ),
        
        // Paywall content
        Center(
          child: SlideTransition(
            position: _slideAnimation,
            child: Container(
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[900] : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Close button
                      Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                          onPressed: _dismissPaywall,
                          icon: const Icon(Icons.close),
                        ),
                      ),
                      
                      // Premium icon
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.deepPurple[700]!, Colors.deepPurple[500]!],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.workspace_premium,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Title
                      Text(
                        'Unlock Premium Recommendations',
                        style: GoogleFonts.roboto(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Subtitle
                      Text(
                        'Get access to exclusive stock recommendations and advanced features',
                        style: GoogleFonts.roboto(
                          fontSize: 16,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Benefits list
                      _buildBenefit(
                        Icons.trending_up,
                        'Premium Stock Recommendations',
                        'Access to curated stock picks from experts',
                        isDark,
                      ),
                      const SizedBox(height: 16),
                      
                      _buildBenefit(
                        Icons.notifications_active,
                        'Real-time Notifications',
                        'Get instant alerts for new recommendations',
                        isDark,
                      ),
                      const SizedBox(height: 16),
                      
                      _buildBenefit(
                        Icons.bar_chart,
                        'Advanced Performance Analytics',
                        'Track your portfolio performance with detailed insights',
                        isDark,
                      ),
                      const SizedBox(height: 16),
                      
                      _buildBenefit(
                        Icons.support_agent,
                        'Priority Support',
                        '24/7 customer support for premium members',
                        isDark,
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Price and purchase button
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.deepPurple.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.deepPurple.withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  '₹299',
                                  style: GoogleFonts.roboto(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.deepPurple[700],
                                  ),
                                ),
                                Text(
                                  '/month',
                                  style: GoogleFonts.roboto(
                                    fontSize: 16,
                                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 4),
                            
                            Text(
                              'Cancel anytime',
                              style: GoogleFonts.roboto(
                                fontSize: 12,
                                color: isDark ? Colors.grey[500] : Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Purchase button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isPurchasing ? null : _handlePurchase,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple[700],
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isPurchasing
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : Text(
                                  'Start Premium - ₹299/month',
                                  style: GoogleFonts.roboto(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Terms text
                      Text(
                        'By subscribing, you agree to our Terms of Service and Privacy Policy. Subscription automatically renews unless canceled.',
                        style: GoogleFonts.roboto(
                          fontSize: 11,
                          color: isDark ? Colors.grey[500] : Colors.grey[500],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBenefit(IconData icon, String title, String description, bool isDark) {
    return Row(
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
            size: 20,
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
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: GoogleFonts.roboto(
                  fontSize: 12,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
