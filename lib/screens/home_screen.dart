import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dashboard_screen.dart';
import 'recommendations_screen.dart';
import 'performance_screen.dart';
import 'account_screen.dart';
import 'admin/admin_panel_screen.dart';
import 'admin/newsletter_admin_screen.dart';
import '../services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  int _notificationCount = 3; // Placeholder notification count

  @override
  void initState() {
    super.initState();
  }

  List<Widget> _buildScreens() {
    return [
      const DashboardScreen(),
      const RecommendationsScreen(),
      const PerformanceScreen(),
      const AccountScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screens = _buildScreens();

    return Scaffold(
      appBar: AppBar(
        leading: authService.isAdmin
            ? Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu_rounded),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              )
            : null,
        title: const Text(
          'StockReco Pro',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_rounded),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Notifications feature coming soon!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
              if (_notificationCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Text(
                      _notificationCount > 9 ? '9+' : '$_notificationCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: authService.isAdmin ? _buildAdminDrawer(context, isDark) : null,
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.deepPurple[700],
        unselectedItemColor: Colors.grey,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.recommend_rounded),
            label: 'Recos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_rounded),
            label: 'Performance',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Account',
          ),
        ],
      ),
    );
  }

  Widget _buildAdminDrawer(BuildContext context, bool isDark) {
    final authService = Provider.of<AuthService>(context, listen: false);

    return Drawer(
      child: Column(
        children: [
          // Admin Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepPurple[700]!, Colors.deepPurple[500]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.admin_panel_settings_rounded,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Admin Panel',
                  style: GoogleFonts.roboto(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  authService.currentUser?.email ?? '',
                  style: GoogleFonts.roboto(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),

          // Admin Menu Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ListTile(
                  leading: const Icon(Icons.dashboard_rounded),
                  title: const Text('Dashboard'),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _currentIndex = 0;
                    });
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.add_circle_rounded),
                  title: const Text('Add Recommendation'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AdminPanelScreen(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.newspaper_rounded),
                  title: const Text('Newsletter Admin'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const NewsletterAdminScreen(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.people_rounded),
                  title: const Text('Manage Users'),
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('User management coming soon!'),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.notifications_active_rounded),
                  title: const Text('Send Notification'),
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Notification feature coming soon!'),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.analytics_rounded),
                  title: const Text('Analytics'),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _currentIndex = 2;
                    });
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.settings_rounded),
                  title: const Text('Settings'),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _currentIndex = 3;
                    });
                  },
                ),
              ],
            ),
          ),

          // Admin Badge
          Container(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber, width: 2),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.verified_rounded, color: Colors.amber, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'ADMIN ACCESS',
                    style: GoogleFonts.roboto(
                      fontWeight: FontWeight.bold,
                      color: Colors.amber,
                      fontSize: 12,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

}
